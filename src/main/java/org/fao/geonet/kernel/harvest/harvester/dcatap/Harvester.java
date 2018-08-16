//=============================================================================
//===	Copyright (C) 2001-2013 Food and Agriculture Organization of the
//===	United Nations (FAO-UN), United Nations World Food Programme (WFP)
//===	and United Nations Environment Programme (UNEP)
//===
//===	This program is free software; you can redistribute it and/or modify
//===	it under the terms of the GNU General Public License as published by
//===	the Free Software Foundation; either version 2 of the License, or (at
//===	your option) any later version.
//===
//===	This program is distributed in the hope that it will be useful, but
//===	WITHOUT ANY WARRANTY; without even the implied warranty of
//===	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//===	General Public License for more details.
//===
//===	You should have received a copy of the GNU General Public License
//===	along with this program; if not, write to the Free Software
//===	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
//===
//===	Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
//===	Rome - Italy. email: geonetwork@osgeo.org
//==============================================================================

package org.fao.geonet.kernel.harvest.harvester.dcatap;

import jeeves.server.context.ServiceContext;

import org.fao.geonet.Logger;
import org.fao.geonet.domain.ISODate;
import org.fao.geonet.exceptions.BadServerResponseEx;
import org.fao.geonet.exceptions.OperationAbortedEx;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.harvest.harvester.HarvestError;
import org.fao.geonet.kernel.harvest.harvester.HarvestResult;
import org.fao.geonet.kernel.harvest.harvester.IHarvester;
import org.fao.geonet.kernel.harvest.harvester.dcatap.Aligner;
import org.fao.geonet.kernel.harvest.harvester.dcatap.DCATAPParams;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.services.harvesting.notifier.SendNotification;
import org.fao.geonet.util.MailUtil;
import org.fao.geonet.utils.Xml;
import org.jdom.Element;
import org.jdom.JDOMException;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.file.Path;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.jena.query.Query;
import org.apache.jena.query.QueryExecution;
import org.apache.jena.query.QueryExecutionFactory;
import org.apache.jena.query.QueryFactory;
import org.apache.jena.query.QuerySolution;
import org.apache.jena.query.ResultSet;
import org.apache.jena.query.ResultSetFormatter;
import org.apache.jena.rdf.model.Model;
import org.apache.jena.rdf.model.ModelFactory;
import org.apache.jena.riot.RDFDataMgr;

//=============================================================================

class Harvester implements IHarvester<HarvestResult> {
	private final AtomicBoolean cancelMonitor;
	// --------------------------------------------------------------------------
	// ---
	// --- Constructor
	// ---
	// --------------------------------------------------------------------------
	// ---------------------------------------------------------------------------
	// ---
	// --- Variables
	// ---
	// ---------------------------------------------------------------------------
	private Logger log;

	// ---------------------------------------------------------------------------
	// ---
	// --- API methods
	// ---
	// ---------------------------------------------------------------------------
	private DCATAPParams params;

	// ---------------------------------------------------------------------------
	private ServiceContext context;

	// ---------------------------------------------------------------------------
	/**
	 * Contains a list of accumulated errors during the executing of this
	 * harvest.
	 */
	private List<HarvestError> errors = new LinkedList<HarvestError>();
	
	private Path xslFile;

	public Harvester(AtomicBoolean cancelMonitor, Logger log, ServiceContext context, DCATAPParams params) {

		this.cancelMonitor = cancelMonitor;
		this.log = log;
		this.context = context;
		this.params = params;
		this.xslFile = context.getApplicationContext().getBean(DataManager.class).getSchemaDir("dcat-ap")
				.resolve("import/rdf-to-xml.xsl");
	}

	public HarvestResult harvest(Logger log) throws Exception {

		this.log = log;

		Set<DCATAPRecordInfo> recordsInfo = new HashSet<DCATAPRecordInfo>();

		try {
			// Retrieve all DCAT-AP records and normalize them via SPARQL+XSL
			// transformation
			recordsInfo.addAll(search());
			// Create, update, delete all records
			Aligner aligner = new Aligner(cancelMonitor, log, context, params);
			log.info("Total records processed in all searches :" + recordsInfo.size());
			return aligner.align(recordsInfo, errors);

		} catch (Exception t) {
			log.error("Unknown error trying to harvest");
			log.error(t.getMessage());
			BadServerResponseEx et = new BadServerResponseEx(t.getMessage());
			errors.add(new HarvestError(context, et, log));
		} catch (Throwable t) {
			log.fatal("Something unknown and terrible happened while harvesting");
			log.fatal(t.getMessage());
			BadServerResponseEx et = new BadServerResponseEx(t.getMessage());
			errors.add(new HarvestError(context, et, log));
		}

		// return empty harvest result in case of errors
		return new HarvestResult();

	}
	
	/**
	 * Does DCAT-AP search request. Executes a SPARQL query to retrieve all
	 * UUIDs and add them to a Set with RecordInfo
	 */
	private Set<DCATAPRecordInfo> search() {

		Set<DCATAPRecordInfo> records = new HashSet<DCATAPRecordInfo>();

		try {
			int maxResults = params.maxResults;

			// Create an empty in-memory model and populate it from the graph
			Model model = ModelFactory.createMemModelMaker().createDefaultModel();
			RDFDataMgr.read(model, params.baseUrl);

			// Get all dataset URIs
			String queryStringIds = "PREFIX dcat: <http://www.w3.org/ns/dcat#> \n"
					+ "PREFIX dct: <http://purl.org/dc/terms/> \n" + "SELECT ?datasetid ?modified \n"
					+ " WHERE {?datasetid a dcat:Dataset. \n" + " OPTIONAL {?datasetid dcat:record ?record. \n"
					+ " ?record dct:modified ?modified}}";
			Query queryIds = QueryFactory.create(queryStringIds);
			QueryExecution qe = QueryExecutionFactory.create(queryIds, model);
			ResultSet resultIds = qe.execSelect();

			while (resultIds.hasNext()) {
				QuerySolution result = resultIds.nextSolution();
				String datasetId = result.getResource("datasetid").toString();

				// System.out.println(datasetId);

				if (log.isDebugEnabled())
					log.debug("Dataset in response: " + datasetId);

				if (cancelMonitor.get()) {
					return Collections.emptySet();
				}
				DCATAPRecordInfo recInfo = getRecordInfo(result, model);
				if (recInfo != null)
					records.add(recInfo);

				if (records.size() > maxResults) {
					log.warning("Forcing harvest end since maximum records to be harvested is reached");
					break;
				}

			}

			qe.close();
			model.close();
			log.info("Records added to result list : " + records.size());

		} catch (Exception e) {
			HarvestError harvestError = new HarvestError(context, e, log);
			harvestError.setDescription(harvestError.getDescription());
			BadServerResponseEx et = new BadServerResponseEx(e.getMessage());
			errors.add(new HarvestError(context, et, log));
		}

		return records;

	}

	private DCATAPRecordInfo getRecordInfo(QuerySolution solution, Model model) {
		try {
			String datasetId = solution.getResource("datasetid").toString();
			String modified = "";
			Date modDate = null;
			// convert the pubDate to a known format (ISOdate)
			if (solution.getResource("modified") != null) {
				modDate = parseDate(solution.getResource("modified").toString());
			}
			if (modDate != null) {

				modified = new ISODate(modDate.getTime(), false).toString();
			}
			if (modified != null && modified.length() == 0)
				modified = null;

			if (log.isDebugEnabled())
				log.debug("getRecordInfo: adding " + datasetId + " with modification date " + modified);

			// Retrieve all triples about a specific dataset URI
			String queryStringRecord = "PREFIX dcat: <http://www.w3.org/ns/dcat#> \n"
					+ "PREFIX apf: <http://jena.hpl.hp.com/ARQ/property#> \n"
					+ "PREFIX afn: <http://jena.hpl.hp.com/ARQ/function#> \n"
					+ "SELECT DISTINCT ?subject ?predicate ?pAsQName ?object \n" + "WHERE { \n"
					// Triples on a specific dataset
					+ "{?subject ?predicate ?object. \n" + "FILTER(?subject = <" + datasetId + "> || ?object = <"
					+ datasetId + "> )} \n"
					// Triples on a specific dataset's "child" resources
					// (publisher, distribution, ed.)
					+ "UNION \n" + "{?subject ?predicate ?object. \n" + "<" + datasetId + "> ?p ?subject.} \n"
					// Triples on a dct:Catalog instance
					+ "UNION \n" + "{?subject ?predicate ?object. \n" + "?subject a dcat:Catalog. \n"
					+ "?subject dcat:dataset <" + datasetId + ">. \n" + "FILTER (?predicate != dcat:dataset)} \n"
					// Triples on a dct:Catalog instance's "child" resources
					// (publisher, distribution, ed.)
					+ "UNION \n" + "{?subject ?predicate ?object. \n" + "?s a dcat:Catalog. \n" + "?s dcat:dataset <"
					+ datasetId + ">. \n" + "?s ?p ?subject. \n" + "FILTER (?p != dcat:dataset)} \n"
					+ "BIND(afn:namespace(?predicate) as ?pns) \n" + "BIND (\n" + "			COALESCE(\n"
					+ "				    IF(?pns = 'http://www.w3.org/ns/dcat#', 'dcat:', 1/0), \n"
					+ "				    IF(?pns = 'http://purl.org/dc/terms/', 'dct:', 1/0), \n"
					+ "				    IF(?pns = 'http://spdx.org/rdf/terms#', 'spdx:', 1/0),\n"
					+ "				    IF(?pns = 'http://www.w3.org/2004/02/skos/core#', 'skos:', 1/0), \n"
					+ "				    IF(?pns = 'http://www.w3.org/ns/adms#', 'adms:', 1/0), \n"
					+ "				    IF(?pns = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#', 'rdf:', 1/0), \n"
					+ "				    IF(?pns = 'http://www.w3.org/2006/vcard/ns#', 'vcard:', 1/0), \n"
					+ "				    IF(?pns = 'http://xmlns.com/foaf/0.1/', 'foaf:', 1/0), \n"
					+ "				    IF(?pns = 'http://www.w3.org/2002/07/owl#', 'owl:', 1/0), \n"
					+ "				    IF(?pns = 'http://schema.org/', 'schema:', 1/0), \n"
					+ "				    IF(?pns = 'http://www.w3.org/2000/01/rdf-schema#', 'rdfs:', 1/0), \n"
					+ "				    IF(?pns = 'http://www.w3.org/ns/locn#', 'locn:', 1/0), \n"
					+ "				    IF(?pns = 'http://purl.org/dc/elements/1.1/', 'dc:', 1/0), \n"
					+ " 				'unkown:' \n" + "				   )AS ?pprefix \n" + " 				)\n"
					+ "BIND (CONCAT(?pprefix,afn:localname(?predicate)) AS ?pAsQName) \n" + "}";

			// System.out.println(queryStringRecord);

			// Execute the query and obtain results
			Query queryRecord = QueryFactory.create(queryStringRecord);
			QueryExecution qe = QueryExecutionFactory.create(queryRecord, model);
			ResultSet results = qe.execSelect();

			// Output query results
			ByteArrayOutputStream outxml = new ByteArrayOutputStream();
			ResultSetFormatter.outputAsXML(outxml, results);

			// Apply XSLT transformation
			Element sparqlResults = Xml.loadStream(new ByteArrayInputStream(outxml.toByteArray()));
			/*
			 * Issue: GeoNetwork works best (only?) with UUIDs as dataset
			 * identifiers. The following lines of code extract a uuid from the
			 * dataset URI. If no UUID is found, the dataset URIs are converted
			 * into a (unique) UUID using generateUUID. Note that URL encoding
			 * does not work, as the GeoNetwork URLs still clash and don't work
			 * in all situations.
			 * //java.net.URLEncoder.encode(datasetId,"utf-8");
			 */
			Pattern pattern = Pattern
					.compile("([a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}){1}");
			Matcher matcher = pattern.matcher(datasetId);
			String datasetUuid;
			if (matcher.find()) {
				datasetUuid = datasetId.substring(matcher.start(), matcher.end());
			} else {
				datasetUuid = UUID.nameUUIDFromBytes(datasetId.getBytes()).toString();
			}
			Map<String, Object> params = new HashMap<String, Object>();
			params.put("identifier", datasetUuid);
			Element dcatXML = Xml.transform(sparqlResults, xslFile, params);
			qe.close();

			/*
			 * XMLOutputter xmlOutputter = new
			 * XMLOutputter(Format.getPrettyFormat());
			 * System.out.println("SPARQL result:");
			 * xmlOutputter.output(sparqlResults,System.out);
			 * System.out.println("DCAT result:");
			 * xmlOutputter.output(dcatXML,System.out);
			 */

			return new DCATAPRecordInfo(datasetUuid, datasetId, modified, "dcat-ap", "TODO: source?", dcatXML);

		} catch (ParseException e) {
			HarvestError harvestError = new HarvestError(context, e, log);
			harvestError.setDescription(harvestError.getDescription());
			errors.add(new HarvestError(context, e, log));
		} catch (JDOMException e) {
			HarvestError harvestError = new HarvestError(context, e, log);
			harvestError.setDescription(harvestError.getDescription());
			errors.add(new HarvestError(context, e, log));
		} catch (IOException e) {
			HarvestError harvestError = new HarvestError(context, e, log);
			harvestError.setDescription(harvestError.getDescription());
			errors.add(new HarvestError(context, e, log));
		} catch (Exception e) {
			HarvestError harvestError = new HarvestError(context, e, log);
			harvestError.setDescription(harvestError.getDescription());
			BadServerResponseEx et = new BadServerResponseEx(e.getMessage());
			errors.add(new HarvestError(context, et, log));
		}

		// we get here if we couldn't get the UUID or date modified
		return null;

	}

	/**
	 * Parse the date provided in the pubDate field.
	 *
	 * @param modifiedDate
	 *            the date to parse
	 * @return
	 */
	protected Date parseDate(String modifiedDate) throws ParseException {

		SimpleDateFormat sdf = new SimpleDateFormat("YYYY-MM-DD'T'HH:mm:ss");
		try {
			return sdf.parse(modifiedDate.toUpperCase());
		} catch (Exception e) {
			log.debug("Date '" + modifiedDate + "' is not parsable");
		}
		return null;
	}

	public List<HarvestError> getErrors() {
		return errors;
	}

}

// =============================================================================

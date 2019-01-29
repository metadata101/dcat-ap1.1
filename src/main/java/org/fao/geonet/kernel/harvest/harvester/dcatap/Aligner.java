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

import jeeves.server.UserSession;
import jeeves.server.context.ServiceContext;

import org.fao.geonet.GeonetContext;
import org.fao.geonet.Logger;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.domain.ISODate;
import org.fao.geonet.domain.Metadata;
import org.fao.geonet.domain.MetadataType;
import org.fao.geonet.domain.OperationAllowedId_;
import org.fao.geonet.domain.ReservedGroup;
import org.fao.geonet.domain.ReservedOperation;
import org.fao.geonet.domain.Schematron;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.GeonetworkDataDirectory;
import org.fao.geonet.kernel.UpdateDatestamp;
import org.fao.geonet.kernel.harvest.BaseAligner;
import org.fao.geonet.kernel.harvest.harvester.CategoryMapper;
import org.fao.geonet.kernel.harvest.harvester.GroupMapper;
import org.fao.geonet.kernel.harvest.harvester.HarvestError;
import org.fao.geonet.kernel.harvest.harvester.HarvestResult;
import org.fao.geonet.kernel.harvest.harvester.RecordInfo;
import org.fao.geonet.kernel.harvest.harvester.UUIDMapper;
import org.fao.geonet.kernel.harvest.harvester.dcatap.DCATAPParams;
import org.fao.geonet.kernel.schema.MetadataSchema;
import org.fao.geonet.repository.MetadataRepository;
import org.fao.geonet.repository.OperationAllowedRepository;
import org.fao.geonet.repository.SchematronRepository;
import org.fao.geonet.utils.IO;
import org.fao.geonet.utils.Xml;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.input.SAXBuilder;
import org.jdom.output.Format;
import org.jdom.output.XMLOutputter;
import org.jdom.transform.JDOMSource;

import java.io.IOException;
import java.io.InputStream;
import java.io.StringWriter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.atomic.AtomicBoolean;

import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import static org.fao.geonet.api.records.formatters.XsltFormatter.getSchemaLocalization;
import static org.fao.geonet.api.records.MetadataValidateApi.restructureReportToHavePatternRuleHierarchy;

//=============================================================================

public class Aligner extends BaseAligner {
	// --------------------------------------------------------------------------
	// ---
	// --- Constructor
	// ---
	// --------------------------------------------------------------------------

	private Logger log;

	// --------------------------------------------------------------------------
	// ---
	// --- Alignment method
	// ---
	// --------------------------------------------------------------------------
	private ServiceContext context;


	// --------------------------------------------------------------------------
	// ---
	// --- Private methods : updateMetadata
	// ---
	// --------------------------------------------------------------------------
	private DCATAPParams params;

	// --------------------------------------------------------------------------
	// ---
	// --- Private methods
	// ---
	// --------------------------------------------------------------------------
	private DataManager dataMan;

	// --------------------------------------------------------------------------
	private CategoryMapper localCateg;

	// --------------------------------------------------------------------------
	// ---
	// --- Variables
	// ---
	// --------------------------------------------------------------------------
	private GroupMapper localGroups;
	private UUIDMapper localUuids;
	private HarvestResult result;
	private Path xslFile;

	public Aligner(AtomicBoolean cancelMonitor, Logger log, ServiceContext sc, DCATAPParams params) throws Exception {
		super(cancelMonitor);
		this.log = log;
		this.context = sc;
		this.params = params;
		this.xslFile = context.getApplicationContext().getBean(DataManager.class).getSchemaDir("dcat-ap")
				.resolve("import/validation-report-to-text.xsl");

		GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
		dataMan = gc.getBean(DataManager.class);
		result = new HarvestResult();

	}

	public HarvestResult align(Set<DCATAPRecordInfo> recordsInfo, List<HarvestError> errors) throws Exception {
		log.info("Start of alignment for : " + params.getName());

		// -----------------------------------------------------------------------
		// --- retrieve all local categories and groups
		// --- retrieve harvested uuids for given harvesting node

		localCateg = new CategoryMapper(context);
		localGroups = new GroupMapper(context);
		localUuids = new UUIDMapper(context.getBean(MetadataRepository.class), params.getUuid());

		dataMan.flush();

		// -----------------------------------------------------------------------
		// --- remove old metadata records that no longer occur in the harvest
		// source

		for (String uuid : localUuids.getUUIDs()) {
			if (cancelMonitor.get()) {
				return result;
			}

			if (!exists(recordsInfo, uuid)) {
				String id = localUuids.getID(uuid);

				if (log.isDebugEnabled())
					log.debug("  - Removing old metadata with local id:" + id);
				dataMan.deleteMetadata(context, id);

				dataMan.flush();

				result.locallyRemoved++;
			}
		}

		// -----------------------------------------------------------------------
		// --- insert/update new metadata

		for (DCATAPRecordInfo ri : recordsInfo) {
			if (cancelMonitor.get()) {
				return result;
			}

			try {
				log.info("Importing record: " + ri.uri);
				String id = dataMan.getMetadataId(ri.uuid);

				if (id == null) {
					addMetadata(ri);
				} else {
					ri.id = id;
					updateMetadata(ri, id);
				}

				result.totalMetadata++;

			} catch (Throwable t) {
				errors.add(new HarvestError(context, t));
				log.error("Unable to process record from (" + this.params.getName() + ")");
				log.error("   Record failed: " + ri.uuid);
			}
		}

		dataMan.forceIndexChanges();

		log.info("End of alignment for : " + params.getName());
		log.info("Number of records that did not fully validate: " + result.doesNotValidate);

		return result;
	}

	private void addMetadata(DCATAPRecordInfo ri) throws Exception {
		Element md = ri.metadata;

		if (md == null)
			return;

		String schema = dataMan.autodetectSchema(md, null);

		if (schema == null) {
			if (log.isDebugEnabled()) {
				log.debug("  - Metadata skipped due to unknown schema. uuid:" + ri.uuid);
			}
			result.unknownSchema++;
			return;
		}

		if (log.isDebugEnabled())
			log.debug("  - Adding metadata with remote uuid:" + ri.uuid + " schema:" + schema);

		// insert metadata
		int userid = 1;
		Metadata metadata = new Metadata().setUuid(ri.uuid);
		metadata.getDataInfo().setSchemaId(schema).setRoot(md.getQualifiedName()).setType(MetadataType.METADATA)
				.setChangeDate(new ISODate(ri.changeDate)).setCreateDate(new ISODate(ri.changeDate));
		metadata.getSourceInfo().setSourceId(params.getUuid()).setOwner(userid);
		metadata.getHarvestInfo().setHarvested(true).setUuid(params.getUuid());

		addCategories(metadata, params.getCategories(), localCateg, context,null, false);

		metadata = dataMan.insertMetadata(context, metadata, md, true, false, false, UpdateDatestamp.NO, false, false);

		String id = String.valueOf(metadata.getId());
		ri.id = id;

		addPrivileges(id, params.getPrivileges(), localGroups, dataMan, context);

		dataMan.indexMetadata(id, Math.random() < 0.01, null);
		result.addedMetadata++;

		System.out.println("metadata imported: " + ri.id);
		// XMLOutputter xmlOutputter = new
		// XMLOutputter(Format.getPrettyFormat());
		// xmlOutputter.output(ri.metadata,System.out);

		Element validationReport = validateMetadata(ri, metadata);
		log.info("VALIDATION REPORT for dataset with UUID: " + ri.uuid + " and with URI: " + ri.uri + transformReportToString(validationReport));
		XMLOutputter xmlOutputter = new XMLOutputter(Format.getPrettyFormat());
		//log.info(xmlOutputter.outputString(validationReport));
	}

	private void updateMetadata(DCATAPRecordInfo ri, String id) throws Exception {
		String date = localUuids.getChangeDate(ri.uuid);

		if (date == null) {
			if (log.isDebugEnabled()) {
				log.debug("  - Skipped metadata managed by another harvesting node. uuid:" + ri.uuid + ", name:"
						+ params.getName());
			}
		} else {
			if (log.isDebugEnabled()) {
				log.debug("  - Comparing date " + date + " with harvested date " + ri.changeDate + " Comparison: "
						+ ri.isMoreRecentThan(date));
			}
			if (!ri.isMoreRecentThan(date)) {
				if (log.isDebugEnabled()) {
					log.debug("  - Metadata XML not changed for uuid:" + ri.uuid);
				}
				result.unchangedMetadata++;
			} else {
				if (log.isDebugEnabled()) {
					log.debug("  - Updating local metadata for uuid:" + ri.uuid);
				}
				// Here, the acutal metadata is retrieved.
				Element md = ri.metadata;

				if (md == null)
					return;

				//
				// update metadata
				//
				boolean validate = false;
				boolean ufo = false;
				boolean index = false;
				String language = context.getLanguage();
				final Metadata metadata = dataMan.updateMetadata(context, id, md, validate, ufo, index, language,
						ri.changeDate, false);

				OperationAllowedRepository repository = context.getBean(OperationAllowedRepository.class);
				repository.deleteAllByIdAttribute(OperationAllowedId_.metadataId, Integer.parseInt(id));
				addPrivileges(id, params.getPrivileges(), localGroups, dataMan, context);

				metadata.getMetadataCategories().clear();
				addCategories(metadata, params.getCategories(), localCateg, context, null, true);
				dataMan.flush();

				dataMan.indexMetadata(id, Math.random() < 0.01, null);
				result.updatedMetadata++;

				Element validationReport = validateMetadata(ri, metadata);
				log.info("VALIDATION REPORT for dataset with UUID: " + ri.uuid + " and with URI: " + ri.uri + transformReportToString(validationReport));
				//XMLOutputter xmlOutputter = new XMLOutputter(Format.getPrettyFormat());
				//log.info(xmlOutputter.outputString(validationReport));
			}
		}
	}

	/**
	 * Validate a record after import. 
	 * 
	 * @param ri
	 * @param metadata
	 * @return
	 * @throws Exception
	 */
	private Element validateMetadata(DCATAPRecordInfo ri, Metadata metadata) throws Exception {

		// --- validate metadata
		UserSession session = context.getUserSession();
		Element errorReport = dataMan
				.doValidate(session, ri.schema, ri.id, metadata.getXmlData(false), context.getLanguage(), false).one();
		restructureReportToHavePatternRuleHierarchy(errorReport);
		
		Element elResp = new Element("root");
		elResp.addContent(new Element(Geonet.Elem.ID).setText(ri.uuid));
		elResp.addContent(new Element("language").setText(context.getLanguage()));
		elResp.addContent(new Element("schema").setText(ri.schema));
		elResp.addContent(errorReport);
		Element schematronTranslations = new Element("schematronTranslations");

		final SchematronRepository schematronRepository = context.getBean(SchematronRepository.class);
		// --- add translations for schematrons
		final List<Schematron> schematrons = schematronRepository.findAllBySchemaName(ri.schema);

		MetadataSchema metadataSchema = dataMan.getSchema(ri.schema);
		Path schemaDir = metadataSchema.getSchemaDir();
		SAXBuilder builder = new SAXBuilder();

		for (Schematron schematron : schematrons) {
			// it contains absolute path to the xsl file
			String rule = schematron.getRuleName();

			Path file = schemaDir.resolve("loc").resolve(context.getLanguage()).resolve(rule + ".xml");

			Document document;
			if (Files.isRegularFile(file)) {
				try (InputStream in = IO.newInputStream(file)) {
					document = builder.build(in);
				}
				Element element = document.getRootElement();

				Element s = new Element(rule);
				element.detach();
				s.addContent(element);
				schematronTranslations.addContent(s);
			}
		}
		elResp.addContent(schematronTranslations);

		// TODO: Avoid XSL
		GeonetworkDataDirectory dataDirectory = context.getBean(GeonetworkDataDirectory.class);
		Path validateXsl = dataDirectory.getWebappDir().resolve("xslt/services/metadata/validate.xsl");
		Map<String, Object> params = new HashMap<>();
		params.put("rootTag", "reports");

		List<Element> elementList = getSchemaLocalization(metadata.getDataInfo().getSchemaId(), context.getLanguage());
		for (Element e : elementList) {
			elResp.addContent(e);
		}

		final Element validationReport = Xml.transform(elResp, validateXsl, params);
		
		//calculate the total number of validation errors in the report against DCAT-AP v1.1
		int iId = Integer.parseInt(ri.id);
		int errors = 0;
		for (Object report : validationReport.getChildren("report") ) {			
			String errorText = ((Element) report).getChild("error").getText();
			Element reportLabel = ((Element) report).getChild("label");
			if (reportLabel != null && reportLabel.getText().equalsIgnoreCase("DCAT-AP Rules v1.1")){
				errors =+ Integer.parseInt(errorText);					
				}
		}
		//Make the records publicly visible when valid.
		if (errors > 0 ){
			result.doesNotValidate++;
			dataMan.unsetOperation(context, iId, ReservedGroup.all.getId(), ReservedOperation.view.getId());
			dataMan.unsetOperation(context, iId, ReservedGroup.all.getId(), ReservedOperation.download.getId());
			dataMan.unsetOperation(context, iId, ReservedGroup.all.getId(), ReservedOperation.dynamic.getId());			
			}
		else {			
			dataMan.setOperation(context, iId, ReservedGroup.all.getId(), ReservedOperation.view.getId());
			dataMan.setOperation(context, iId, ReservedGroup.all.getId(), ReservedOperation.download.getId());
			dataMan.setOperation(context, iId, ReservedGroup.all.getId(), ReservedOperation.dynamic.getId());
		}
		
		return validationReport;
	}

	/**
	 * Transforms the GeoNetwork validation report to a text version
	 * 
	 * @param validationReport An XML version of the validation report
	 * @return A text-version of the validation report
	 */
	private String transformReportToString(Element validationReport) {
		try {
			StreamResult validationReportAsText = new StreamResult(new StringWriter());
			Source validationReportSource = new JDOMSource(new Document((Element) validationReport.detach()));
			Source xslSource = new StreamSource(IO.newInputStream(xslFile), xslFile.toUri().toASCIIString());
			Transformer transformer = TransformerFactory.newInstance().newTransformer(xslSource);
			transformer.transform(validationReportSource, validationReportAsText);
			return validationReportAsText.getWriter().toString();
		} catch (TransformerException e) {
			log.error("Error writing XML Validation report: " + e.getMessage());
		} catch (IOException e) {
			log.error("Error writing XML Validation report: " + e.getMessage());
		}
		return "";
	}

	/**
	 * Returns true if the uuid is present in the remote node.
	 */
	private boolean exists(Set<DCATAPRecordInfo> recordsInfo, String uuid) {
		for (RecordInfo ri : recordsInfo) {
			if (uuid.equals(ri.uuid))
				return true;
		}

		return false;
	}

}

// =============================================================================

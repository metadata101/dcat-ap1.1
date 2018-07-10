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
import org.fao.geonet.exceptions.OperationAbortedEx;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.harvest.harvester.HarvestError;
import org.fao.geonet.kernel.harvest.harvester.HarvestResult;
import org.fao.geonet.kernel.harvest.harvester.IHarvester;
import org.fao.geonet.kernel.harvest.harvester.dcatap.Aligner;
import org.fao.geonet.kernel.harvest.harvester.dcatap.DCATAPParams;
import org.fao.geonet.kernel.harvest.harvester.dcatap.Search;
import org.fao.geonet.utils.GeonetHttpRequestFactory;
import org.fao.geonet.utils.HttpRequest;
import org.fao.geonet.utils.Xml;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.output.Format;
import org.jdom.output.XMLOutputter;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
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

import org.apache.jena.query.Query;
import org.apache.jena.query.QueryExecution;
import org.apache.jena.query.QueryExecutionFactory;
import org.apache.jena.query.QueryFactory;
import org.apache.jena.query.QuerySolution;
import org.apache.jena.query.ResultSet;
import org.apache.jena.query.ResultSetFormatter;
import org.apache.jena.rdf.model.Model;
import org.apache.jena.rdf.model.ModelFactory;

//=============================================================================

class Harvester implements IHarvester<HarvestResult> {
    private final AtomicBoolean cancelMonitor;
    //--------------------------------------------------------------------------
    //---
    //--- Constructor
    //---
    //--------------------------------------------------------------------------
    //---------------------------------------------------------------------------
    //---
    //--- Variables
    //---
    //---------------------------------------------------------------------------
    private Logger log;

    //---------------------------------------------------------------------------
    //---
    //--- API methods
    //---
    //---------------------------------------------------------------------------
    private DCATAPParams params;

    //---------------------------------------------------------------------------
    private ServiceContext context;

    //---------------------------------------------------------------------------
    /**
     * Contains a list of accumulated errors during the executing of this harvest.
     */
    private List<HarvestError> errors = new LinkedList<HarvestError>();

    public Harvester(AtomicBoolean cancelMonitor, Logger log, ServiceContext context, DCATAPParams params) {

        this.cancelMonitor = cancelMonitor;
        this.log = log;
        this.context = context;
        this.params = params;

    }

    public HarvestResult harvest(Logger log) throws Exception {

        this.log = log;

        HttpRequest request = context.getBean(GeonetHttpRequestFactory.class).createHttpRequest(new URL(params.baseUrl)); 

        Set<DCATAPRecordInfo> recordsInfo = new HashSet<DCATAPRecordInfo>();

        for (Search s : params.getSearches()) {
            if (cancelMonitor.get()) {
                return new HarvestResult();
            }

            try {
                recordsInfo.addAll(search(request, s));
            } catch (Exception t) {
                log.error("Unknown error trying to harvest");
                log.error(t.getMessage());
                t.printStackTrace();
                errors.add(new HarvestError(context, t, log));
            } catch (Throwable t) {
                log.fatal("Something unknown and terrible happened while harvesting");
                log.fatal(t.getMessage());
                t.printStackTrace();
                errors.add(new HarvestError(context, t, log));
            }
        }

        if (params.isSearchEmpty()) {
            try {
                log.debug("Doing an empty search");
                recordsInfo.addAll(search(request, Search.createEmptySearch()));
            } catch (Exception t) {
                log.error("Unknown error trying to harvest");
                log.error(t.getMessage());
                t.printStackTrace();
                errors.add(new HarvestError(context, t, log));
            } catch(Throwable t) {
                log.fatal("Something unknown and terrible happened while harvesting");
                log.fatal(t.getMessage());
                t.printStackTrace();
                errors.add(new HarvestError(context, t, log));
            }
        }

        
        log.info("Total records processed in all searches :" + recordsInfo.size());

        //--- align local node

        Aligner aligner = new Aligner(cancelMonitor, log, context, params);

        return aligner.align(recordsInfo, errors);
    }

    /**
     * Does DCAT-AP search request.
     * Executes a SPARQL query to retrieve all UUIDs and add them to a Set with RecordInfo
     */
    private Set<DCATAPRecordInfo> search(HttpRequest request, Search s) throws Exception {
    	Set<DCATAPRecordInfo> records = new HashSet<DCATAPRecordInfo>();
        int maxResults = params.maxResults;
               
        request.clearParams();

        //Do HTTP request
        byte[] response = doSearch(request);
    	// Open the RDF graph
    	InputStream in = new ByteArrayInputStream(response);	        

    	// Create an empty in-memory model and populate it from the graph
    	Model model = ModelFactory.createMemModelMaker().createModel("dcat");
    	model.read(in,null,params.rdfSyntax);
    	in.close();
    	
    	// Get all dataset URIs
    	String queryStringIds =
    			"PREFIX dcat: <http://www.w3.org/ns/dcat#> \n"
    		  + "PREFIX dct: <http://purl.org/dc/terms/> \n"		    			
    		  +	"SELECT ?datasetid ?modified \n"
    		  + " WHERE {?datasetid a <http://www.w3.org/ns/dcat#Dataset>. \n"
    		  + " OPTIONAL {?datasetid dcat:record ?record. \n"
    		  + " ?record dct:modified ?modified}}";
    	Query queryIds = QueryFactory.create(queryStringIds);
    	QueryExecution qeIds = QueryExecutionFactory.create(queryIds, model);
    	ResultSet resultIds = qeIds.execSelect();
    	
    	    	
    	while (resultIds.hasNext()) {
    		QuerySolution result = resultIds.nextSolution();
    		String datasetId = result.getResource("datasetid").toString();
    		
    		System.out.print(datasetId);

	        if (log.isDebugEnabled())
	            log.debug("Dataset in response: " + datasetId);
	        
            if (cancelMonitor.get()) {
                return Collections.emptySet();
            }
            DCATAPRecordInfo recInfo = getRecordInfo(result,model);
            if (recInfo != null) records.add(recInfo);
            
            if (records.size() > maxResults) {
                log.warning("Forcing harvest end since maximum records to be harvested is reached");
                break;
            }	            
    		
    	}
	
        log.info("Records added to result list : " + records.size());

        return records;
    }

    private byte[] doSearch(HttpRequest request) throws OperationAbortedEx {
        try {
            System.out.println("Sent request " + request.getSentData());
            log.info("Searching on : " + params.getName());
            byte[] response = request.execute();
            if (log.isDebugEnabled()) {
                log.debug("Sent request " + request.getSentData());
            }
            return response;
        } catch (IOException e) {
            errors.add(new HarvestError(context, e, log));
            throw new OperationAbortedEx("Raised exception when searching: "
                + e.getMessage(), e);
        }
    }

    private DCATAPRecordInfo getRecordInfo(QuerySolution solution, Model model) {
        // get uuid and date modified
        try {
        	String datasetId = solution.getResource("datasetid").toString();
            String modified = "";
            Date modDate=null;
            // convert the pubDate to a known format (ISOdate)
            if (solution.getResource("modified")!=null){
            	modDate = parseDate(solution.getResource("modified").toString());
            }
            if (modDate!=null) {
            	
	            modified = new ISODate(modDate.getTime(), false).toString();
            }
            if (modified != null && modified.length() == 0) modified = null;

            if (log.isDebugEnabled())
                log.debug("getRecordInfo: adding " + datasetId + " with modification date " + modified);
            
        	// Retrieve all triples about a specific dataset URI
        	String queryStringRecord = 
        		"PREFIX apf: <http://jena.hpl.hp.com/ARQ/property#> \n" 	
        		+ "PREFIX afn: <http://jena.hpl.hp.com/ARQ/function#> \n"	
        	    + "SELECT ?subject ?predicate ?pAsQName ?object \n"
        	    + "WHERE { \n"
        	    + "{ ?subject ?predicate ?object. \n"
        	    + "BIND(afn:namespace(?predicate) as ?pns) \n"
        	    + "BIND (\n"
        	    + "			COALESCE(\n"
        	    + "				    IF(?pns = 'http://www.w3.org/ns/dcat#', 'dcat:', 1/0), \n"
        	    + "				    IF(?pns = 'http://purl.org/dc/terms/', 'dct:', 1/0), \n"
        	    + "				    IF(?pns = 'http://spdx.org/rdf/terms#', 'spdx:', 1/0), \n"
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
        	    + " 				'unkown:' \n"
        	    + "				   )AS ?pprefix \n"
        	    + " 				)\n"
        	    + "BIND (CONCAT(?pprefix,afn:localname(?predicate)) AS ?pAsQName) \n"
        	    + "FILTER(?subject = <" + datasetId + "> || ?object = <" + datasetId + ">)} \n"
        	    + "UNION {\n"
        	    + "?s ?p ?subject. \n"
        	    + "?subject ?predicate ?object. \n"
        	    + "BIND(afn:namespace(?predicate) as ?pns) \n"
        	    + "BIND (\n"
        	    + "			COALESCE(\n"
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
        	    + " 				'unkown:' \n"
        	    + "				   )AS ?pprefix \n"
        	    + " 				)\n"
        	    + "BIND (CONCAT(?pprefix,afn:localname(?predicate)) AS ?pAsQName) \n"        	    
        	    + "FILTER(?s = <" + datasetId + ">)}\n"
        	    + "}";        	    
        	
        	// Execute the query and obtain results
        	Query queryRecord = QueryFactory.create(queryStringRecord);
        	QueryExecution qe = QueryExecutionFactory.create(queryRecord, model);
        	ResultSet results = qe.execSelect();
        	
        	// Output query results 
        	ByteArrayOutputStream outxml = new ByteArrayOutputStream();
        	ResultSetFormatter.outputAsXML(outxml,results);
        	
        	// Apply XSLT transformation
            Path xslFile = context.getApplicationContext().getBean(DataManager.class).getSchemaDir("dcat-ap").resolve("import/rdf-to-xml.xsl");
        	Element sparqlResults = Xml.loadStream(new ByteArrayInputStream(outxml.toByteArray()));
        	/*
        	 * Issue: GeoNetwork works best (only?) with UUIDs as dataset identifiers.
        	 * Therefore, URIs are converted into a (unique) UUID using generateUUID.
        	 * UUID.nameUUIDFromBytes(aString.getBytes()).toString();
        	 * URL encoding does not work, as the GeoNetwork URLs still clash and don't work in all situations. //java.net.URLEncoder.encode(datasetId,"utf-8"); 
        	 */   	
        	String datasetIdEnc = UUID.nameUUIDFromBytes(datasetId.getBytes()).toString();        	
        	Map<String, Object> params = new HashMap<String, Object>();
        	params.put("identifier", datasetIdEnc);
        	Element dcatXML = Xml.transform(sparqlResults, xslFile, params);
        	
        	//XMLOutputter xmlOutputter = new XMLOutputter(Format.getPrettyFormat());
        	//xmlOutputter.output(sparqlResults,System.out);
        	//xmlOutputter.output(dcatXML,System.out);  
        	
            return new DCATAPRecordInfo(datasetIdEnc, modified,"dcat-ap","TODO: source?",dcatXML);
            
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
            errors.add(new HarvestError(context, e, log));
		}

        // we get here if we couldn't get the UUID or date modified
        return null;

    }

    /**
     * Parse the date provided in the pubDate field.
     *
     * @param modifiedDate the date to parse
     * @return
     */
    protected Date parseDate(String modifiedDate) throws ParseException {

    	SimpleDateFormat sdf = new SimpleDateFormat("YYYY-MM-DD'T'HH:mm:ss");
        try {
            return sdf.parse(modifiedDate.toUpperCase());
        } catch (Exception e) {
            log.debug("Date '"+modifiedDate+"' is not parsable");
        }
        return null;
    }

    public List<HarvestError> getErrors() {
        return errors;
    }
    
    
}

// =============================================================================


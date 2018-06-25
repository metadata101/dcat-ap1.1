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

import org.apache.commons.lang.StringUtils;
import org.fao.geonet.Constants;
import org.fao.geonet.Logger;
import org.fao.geonet.domain.ISODate;
import org.fao.geonet.exceptions.BadSoapResponseEx;
import org.fao.geonet.exceptions.BadXmlResponseEx;
import org.fao.geonet.exceptions.OperationAbortedEx;
import org.fao.geonet.kernel.harvest.harvester.HarvestError;
import org.fao.geonet.kernel.harvest.harvester.HarvestResult;
import org.fao.geonet.kernel.harvest.harvester.IHarvester;
import org.fao.geonet.kernel.harvest.harvester.RecordInfo;
import org.fao.geonet.kernel.harvest.harvester.dcatap.Aligner;
import org.fao.geonet.kernel.harvest.harvester.dcatap.DCATAPParams;
import org.fao.geonet.kernel.harvest.harvester.dcatap.Search;
import org.fao.geonet.schema.dcatap.DCATAPNamespaces;
import org.fao.geonet.schema.dcatap.DCATAPSchemaPlugin;
import org.fao.geonet.utils.GeonetHttpRequestFactory;
import org.fao.geonet.utils.Xml;
import org.fao.geonet.utils.XmlRequest;
import org.jdom.Element;
import org.jdom.Namespace;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URL;
import java.net.URLDecoder;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.Date;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.concurrent.atomic.AtomicBoolean;


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
        //--- perform all searches

//        XmlRequest request = context.getBean(GeonetHttpRequestFactory.class).createXmlRequest(new URL(params.baseUrl + "/catalog.rdf"));
        XmlRequest request = context.getBean(GeonetHttpRequestFactory.class).createXmlRequest(new URL("http://localhost:8080/geonetwork/catalogs/catalog.rdf"));

        Set<RecordInfo> records = new HashSet<RecordInfo>();

        for (Search s : params.getSearches()) {
            if (cancelMonitor.get()) {
                return new HarvestResult();
            }

            try {
                records.addAll(search(request, s));
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
                records.addAll(search(request, Search.createEmptySearch()));
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

        log.info("Total records processed in all searches :" + records.size());

        //--- align local node

        Aligner aligner = new Aligner(cancelMonitor, log, context, params);

        return aligner.align(records, errors);
    }

    /**
     * Does DCAT-AP search request.
     */
    private Set<RecordInfo> search(XmlRequest request, Search s) throws Exception {

        Set<RecordInfo> records = new HashSet<RecordInfo>();
        int firstPageSize = 0;
        int startPage = 1;
        int maxResults = params.maxResults;
        while (true) {
            request.clearParams();
//            request.addParam("page", startPage);
	        Element response = doSearch(request);
	
	        if (log.isDebugEnabled())
	            log.debug("Number of child elements in response: " + response.getChildren().size());

	        String rdf = response.getName();
	        if (!rdf.equals("RDF")) {
	            throw new OperationAbortedEx("Missing 'RDF' element in\n", Xml.getString(response));
	        }
	
	        Element catalog = response.getChild("Catalog", DCATAPNamespaces.DCAT);
	        if (catalog == null) {
	            throw new OperationAbortedEx("Missing 'Catalog' element in \n", Xml.getString(response));
	        }

	        @SuppressWarnings("unchecked")
	        List<Element> list = catalog.getChildren();
	        int returnedCount = list.size();
	
	        if (firstPageSize==0) {
	        	firstPageSize = returnedCount;
	        }
	        
	        for (Element record : list) {
	            if (cancelMonitor.get()) {
	                return Collections.emptySet();
	            }
	
	            if (!record.getName().equals("dataset")) continue; // skip all the other crap
	            RecordInfo recInfo = getRecordInfo((Element) record.clone());
	            if (recInfo != null) records.add(recInfo);

	        }
            if (returnedCount != firstPageSize) {
                break;
            }

            // Another way to escape from an infinite loop

            if (returnedCount == 0) {
                log.warning("Forcing harvest end since numberOfRecordsReturned = 0");
                break;
            }

            if (records.size() > maxResults) {
                log.warning("Forcing harvest end since maximum records to be harvested is reached");
                break;
            }

            // Start page of next records.
            startPage++;
        }

        log.info("Records added to result list : " + records.size());

        return records;
    }

    private Element doSearch(XmlRequest request) throws OperationAbortedEx {
        try {
            System.out.println("Sent request " + request.getSentData());
            log.info("Searching on : " + params.getName());
            Element response = request.execute();
            if (log.isDebugEnabled()) {
                log.debug("Sent request " + request.getSentData());
                log.debug("Search results:\n" + Xml.getString(response));
            }
            return response;
        } catch (BadSoapResponseEx e) {
            errors.add(new HarvestError(context, e, log));
            throw new OperationAbortedEx("Raised exception when searching: "
                + e.getMessage(), e);
        } catch (BadXmlResponseEx e) {
            errors.add(new HarvestError(context, e, log));
            throw new OperationAbortedEx("Raised exception when searching: "
                + e.getMessage(), e);
        } catch (IOException e) {
            errors.add(new HarvestError(context, e, log));
            throw new OperationAbortedEx("Raised exception when searching: "
                + e.getMessage(), e);
        }
    }

    private RecordInfo getRecordInfo(Element record) {
        if (log.isDebugEnabled()) log.debug("getRecordInfo : " + Xml.getString(record));

        String identif = "";

        // get uuid and date modified
        try {
	        Element dataset = record.getChild("Dataset", DCATAPNamespaces.DCAT);
	        if (dataset == null) {
                log.warning("Missing 'Dataset' element in \n" + Xml.getString(record));
                return null;
	        }
            // uuid is in <guid> child
            String about = dataset.getAttributeValue("about", DCATAPNamespaces.RDF);
            if (about != null) {
                String aboutLink = URLDecoder.decode(about, Constants.ENCODING);
                identif = StringUtils.substringAfterLast(aboutLink, "/");
            }
            if (identif.length() == 0) {
                log.warning("Record doesn't have a uuid : " + Xml.getString(record));
                return null; // skip this one
            }

            String modified = dataset.getChildText("modified", DCATAPNamespaces.DCT);
            // convert the pubDate to a known format (ISOdate)
            Date modDate = parseDate(modified);
            if (modDate!=null) {
	            modified = new ISODate(modDate.getTime(), false).toString();
            }
            if (modified != null && modified.length() == 0) modified = null;

            if (log.isDebugEnabled())
                log.debug("getRecordInfo: adding " + identif + " with modification date " + modified);
            return new RecordInfo(identif, modified);
        } catch (UnsupportedEncodingException e) {
            HarvestError harvestError = new HarvestError(context, e, log);
            harvestError.setDescription(harvestError.getDescription() + "\n record: " + Xml.getString(record));
            errors.add(harvestError);
        } catch (ParseException e) {
            HarvestError harvestError = new HarvestError(context, e, log);
            harvestError.setDescription(harvestError.getDescription() + "\n record: " + Xml.getString(record));
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


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

import org.apache.jena.riot.RDFLanguages;
import org.fao.geonet.Util;
import org.fao.geonet.exceptions.BadInputEx;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.harvest.harvester.AbstractParams;
import org.jdom.Element;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;

//=============================================================================

public class DCATAPParams extends AbstractParams {
    //---------------------------------------------------------------------------
    //---
    //--- Create : called when a new entry must be added. Reads values from the
    //---          provided entry, providing default values
    //---
    //---------------------------------------------------------------------------
    public String baseUrl;

    //---------------------------------------------------------------------------
    //---
    //--- See also: https://jena.apache.org/documentation/io/rdf-input.html
    //---  	RDFXML
    //---   TURTLE
    //---------------------------------------------------------------------------
    public String rdfSyntax;

    //---------------------------------------------------------------------------
    //---
    //--- Update : called when an entry has changed and variables must be updated
    //---
    //---------------------------------------------------------------------------
    public String icon;

    //---------------------------------------------------------------------------
    //---
    //--- Other API methods
    //---
    //---------------------------------------------------------------------------
    public int maxResults;

    //---------------------------------------------------------------------------
    //private List<Search> alSearches = new ArrayList<Search>();

    //---------------------------------------------------------------------------

    public DCATAPParams(DataManager dm) {
        super(dm);
    }

    //---------------------------------------------------------------------------
    //---
    //--- Private methods
    //---
    //---------------------------------------------------------------------------

    public void create(Element node) throws BadInputEx {
        super.create(node);

        Element site = node.getChild("site");
        //Element searches = node.getChild("searches");

        baseUrl = Util.getParam(site, "baseUrl", "");
        rdfSyntax = Util.getParam(site, "rdfSyntax", RDFLanguages.RDFXML.toLongString());
        maxResults = Util.getParam(site, "maxResults", 10000); //MAX_HARVEST_RESULTS;

        try {
            baseUrl = safeDecode(baseUrl);
        } catch (UnsupportedEncodingException x) {
            System.out.println(x.getMessage());
            x.printStackTrace();
        }
        icon = Util.getParam(site, "icon", "default.gif");

        //addSearches(searches);
    }

    //---------------------------------------------------------------------------
    //---
    //--- Variables
    //---
    //---------------------------------------------------------------------------

    public void update(Element node) throws BadInputEx {
        super.update(node);

        Element site = node.getChild("site");
        //Element searches = node.getChild("searches");

        baseUrl = Util.getParam(site, "baseUrl", baseUrl);
        rdfSyntax = Util.getParam(site, "rdfSyntax", "RDFXML");
        maxResults = Util.getParam(site, "maxResults", 10000); //MAX_HARVEST_RESULTS;

        Element content = node.getChild("content");
        super.setImportXslt(Util.getParam(content, "importxslt", "none"));

        try {
            baseUrl = safeDecode(baseUrl);
            rdfSyntax = safeDecode(rdfSyntax);
        } catch (UnsupportedEncodingException x) {
            System.out.println(x.getMessage());
            x.printStackTrace();
        }

        icon = Util.getParam(site, "icon", icon);

        //--- if some search queries are given, we drop the previous ones and
        //--- set these new ones

//        if (searches != null)
//            addSearches(searches);
    }

//    public Iterable<Search> getSearches() {
//        return alSearches;
//    }
//
//    public boolean isSearchEmpty() {
//        return alSearches.isEmpty();
//    }

    @Override
    public String getIcon() {
        return icon;
    }

    public DCATAPParams copy() {
        DCATAPParams copy = new DCATAPParams(dm);
        copyTo(copy);

        copy.baseUrl = baseUrl;
        copy.rdfSyntax = rdfSyntax;
        copy.icon = icon;

//        for (Search s : alSearches)
//            copy.alSearches.add(s.copy());

        return copy;
    }
//
//    private void addSearches(Element searches) {
//        alSearches.clear();
//
//        if (searches == null)
//            return;
//
//        for (Object o : searches.getChildren("search")) {
//            Element search = (Element) o;
//
//            alSearches.add(new Search(search));
//        }
//    }

    private String safeDecode(String url) throws UnsupportedEncodingException {
        url = url.replaceAll("%(?![0-9a-fA-F]{2})", "%25");
        url = url.replaceAll("\\+", "%2B");
        return URLDecoder.decode(url);
    }
}

//=============================================================================



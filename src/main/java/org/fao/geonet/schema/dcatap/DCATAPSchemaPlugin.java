/*
 * Copyright (C) 2001-2016 Food and Agriculture Organization of the
 * United Nations (FAO-UN), United Nations World Food Programme (WFP)
 * and United Nations Environment Programme (UNEP)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 *
 * Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
 * Rome - Italy. email: geonetwork@osgeo.org
 */

package org.fao.geonet.schema.dcatap;

import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.fao.geonet.kernel.schema.AssociatedResource;
import org.fao.geonet.kernel.schema.AssociatedResourcesSchemaPlugin;
import org.fao.geonet.utils.Xml;
import org.jdom.Element;
import org.jdom.Namespace;
import org.jdom.filter.ElementFilter;

import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableSet;

/**
 * 
 */
public class DCATAPSchemaPlugin
        extends org.fao.geonet.kernel.schema.SchemaPlugin
        implements AssociatedResourcesSchemaPlugin {
    public static final String IDENTIFIER = "dcat-ap";

    private static ImmutableSet<Namespace> allNamespaces;
    private static Map<String, Namespace> allTypenames;

    static {
        allNamespaces = ImmutableSet.<Namespace>builder()
                .add(DCATAPNamespaces.DC)
                .add(DCATAPNamespaces.DCT)
                .add(DCATAPNamespaces.DCAT)
                .add(DCATAPNamespaces.VCARD)
                .add(DCATAPNamespaces.FOAF)
                .build();

        allTypenames = ImmutableMap.<String, Namespace>builder()
                .put("csw:Record", Namespace.getNamespace("csw", "http://www.opengis.net/cat/csw/2.0.2"))
                .put("dcat", DCATAPNamespaces.DCAT)
                .build();
    }

    public DCATAPSchemaPlugin() {
        super(IDENTIFIER, allNamespaces);
    }


    /**
     * Always return null. Not implemented for DCAT-AP records.
     *
     * @param metadata
     * @return
     */
    public Set<AssociatedResource> getAssociatedResourcesUUIDs(Element metadata) {
        return null;
    }

    @Override
    public Set<String> getAssociatedParentUUIDs(Element metadata) {
        ElementFilter elementFilter = new ElementFilter("isPartOf", DCATAPNamespaces.DCT);
        return Xml.filterElementValues(
                metadata,
                elementFilter,
                null, null,
                null);
    }

    public Set<String> getAssociatedDatasetUUIDs(Element metadata) {
        return null;
    }

    ;

    public Set<String> getAssociatedFeatureCatalogueUUIDs(Element metadata) {
        return null;
    }

    ;

    public Set<String> getAssociatedSourceUUIDs(Element metadata) {
        ElementFilter elementFilter = new ElementFilter("relation", DCATAPNamespaces.DCT);
        Set<String> rdfAboutAttributes = Xml.filterElementValues(
                metadata,
                elementFilter,
                null, null, "resource",
                DCATAPNamespaces.RDF);
        Set<String> uuids = new HashSet<String>();
        for (String rdfAboutAttribute : rdfAboutAttributes) {
            Pattern pattern = Pattern
                    .compile("([a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}){1}");
            Matcher matcher = pattern.matcher(rdfAboutAttribute);
            if (matcher.find()) {
                uuids.add(rdfAboutAttribute.substring(matcher.start(), matcher.end()));
            }
        }
        return uuids;
    }

    @Override
    public Map<String, Namespace> getCswTypeNames() {
        return allTypenames;
    }

}

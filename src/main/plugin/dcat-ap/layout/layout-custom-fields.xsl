<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~ Copyright (C) 2001-2016 Food and Agriculture Organization of the
  ~ United Nations (FAO-UN), United Nations World Food Programme (WFP)
  ~ and United Nations Environment Programme (UNEP)
  ~
  ~ This program is free software; you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation; either version 2 of the License, or (at
  ~ your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful, but
  ~ WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  ~ General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
  ~
  ~ Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
  ~ Rome - Italy. email: geonetwork@osgeo.org
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:spdx="http://spdx.org/rdf/terms#"
		xmlns:skos="http://www.w3.org/2004/02/skos/core#"
		xmlns:adms="http://www.w3.org/ns/adms#" 
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dct="http://purl.org/dc/terms/"
    xmlns:dcat="http://www.w3.org/ns/dcat#"
		xmlns:vcard="http://www.w3.org/2006/vcard/ns#"
		xmlns:foaf="http://xmlns.com/foaf/0.1/" 
		xmlns:owl="http://www.w3.org/2002/07/owl#"
		xmlns:schema="http://schema.org/"
		xmlns:locn="http://www.w3.org/ns/locn#"
    xmlns:gml="http://www.opengis.net/gml"
		xmlns:java="java:org.fao.geonet.schema.util.XslUtil" 
		xmlns:java2="java:org.fao.geonet.schema.dcatap.util.XslUtil" 
		xmlns:gn="http://www.fao.org/geonetwork"
		xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
		xmlns:gn-fn-dcat-ap="http://geonetwork-opensource.org/xsl/functions/profiles/dcat-ap"
    xmlns:saxon="http://saxon.sf.net/"
    extension-element-prefixes="saxon"
		version="2.0"
		exclude-result-prefixes="#all">

  <xsl:include href="layout-custom-fields-concepts.xsl"/>
  <xsl:include href="layout-custom-fields-sds.xsl"/>

  <xsl:template mode="mode-dcat-ap" match="locn:geometry" priority="2000">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <xsl:variable name="north" select="'51.4960'"/>
    <xsl:variable name="south" select="'50.6746'"/>
    <xsl:variable name="east" select="'5.9200'"/>
    <xsl:variable name="west" select="'2.5579'"/>
    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="labelConfig" select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), '', $xpath)"/>

    <xsl:call-template name="render-boxed-element">
      <xsl:with-param name="label"
                      select="$labelConfig/label"/>
      <xsl:with-param name="editInfo" select="../gn:element"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="subTreeSnippet">

      <!-- xsl:variable name="identifier"
                    select="../@rdf:about"/-->
      <xsl:variable name="description"
                    select="../skos:prefLabel[1]"/>
      <xsl:variable name="readonly" select="false()"/>
      <xsl:variable name="geometry">
        <xsl:apply-templates select="." mode="gn-element-cleaner"/>
      </xsl:variable>

<!-- 
			<xsl:variable name="identifier"
                      select="../@rdf:about"/>
      <br />
			<gn-bounding-polygon polygon-xml="{string($geometry)}"
					identifier="{$identifier}"
        	read-only="{$readonly}">
      </gn-bounding-polygon>
      <xsl:if test="$description and $isFlatMode and not($metadataIsMultilingual)">
        <xsl:attribute name="data-description"
                       select="$description"/>
        <xsl:attribute name="data-description-ref"
                       select="concat('_', $description/gn:element/@ref)"/>
      </xsl:if>
 -->
	    <xsl:variable name="bbox">
	   		<xsl:if test="@rdf:datatype='http://www.opengis.net/ont/geosparql#wktLiteral'"> 
	      	<xsl:value-of select="java2:wktGeomToBbox(saxon:serialize($geometry,'default-serialize-mode'))"/>
	      </xsl:if>
	   		<xsl:if test="@rdf:datatype='http://www.opengis.net/ont/geosparql#gmlLiteral'"> 
	      	<xsl:value-of select="java:geomToBbox(saxon:serialize($geometry,'default-serialize-mode'))"/>
	      </xsl:if>
	    </xsl:variable>
	    <xsl:if test="$bbox != ''">
	      <xsl:variable name="bboxCoordinates" select="tokenize($bbox, '\|')"/>
	      <div gn-draw-bbox=""
		          data-hleft="{$bboxCoordinates[1]}"
		          data-hright="{$bboxCoordinates[3]}" 
		          data-hbottom="{$bboxCoordinates[2]}"
		          data-htop="{$bboxCoordinates[4]}"
		          data-dc-ref="_{generate-id()}"
		          data-lang="lang"
		          data-read-only="{$readonly}">
	          <xsl:if test="$identifier and $isFlatMode">
	            <xsl:attribute name="data-identifier"
	                           select="$identifier"/>
	            <xsl:attribute name="data-identifier-ref"
	                           select="concat('_', $identifier/gn:element/@ref)"/>
	          </xsl:if>
	          <xsl:if test="$description and $isFlatMode and not($metadataIsMultilingual)">
	            <xsl:attribute name="data-description"
	                           select="$description"/>
	            <xsl:attribute name="data-description-ref"
	                           select="concat('_', $description/gn:element/@ref)"/>
	          </xsl:if>
	        </div>
	      </xsl:if>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <!--xsl:template name="compute-bbox-for-polygon">

    <xsl:variable name="geometry">
      <xsl:apply-templates select="."/>
    </xsl:variable>
    <xsl:variable name="bbox">
   		<xsl:if test="@rdf:datatype='http://www.opengis.net/ont/geosparql#wktLiteral'"> 
      	<xsl:value-of select="java2:wktGeomToBbox(saxon:serialize($geometry,'default-serialize-mode'))"/>
      </xsl:if>
   		<xsl:if test="@rdf:datatype='http://www.opengis.net/ont/geosparql#gmlLiteral'"> 
      	<xsl:value-of select="java:geomToBbox(saxon:serialize($geometry,'default-serialize-mode'))"/>
      </xsl:if>
    </xsl:variable>
    <xsl:if test="$bbox != ''">
      <xsl:variable name="bboxCoordinates"
                    select="tokenize($bbox, '\|')"/>

      <gmd:geographicElement>
        <gmd:EX_GeographicBoundingBox>
          <gmd:westBoundLongitude>
            <gco:Decimal><xsl:value-of select="$bboxCoordinates[1]"/></gco:Decimal>
          </gmd:westBoundLongitude>
          <gmd:eastBoundLongitude>
            <gco:Decimal><xsl:value-of select="$bboxCoordinates[3]"/></gco:Decimal>
          </gmd:eastBoundLongitude>
          <gmd:southBoundLatitude>
            <gco:Decimal><xsl:value-of select="$bboxCoordinates[2]"/></gco:Decimal>
          </gmd:southBoundLatitude>
          <gmd:northBoundLatitude>
            <gco:Decimal><xsl:value-of select="$bboxCoordinates[4]"/></gco:Decimal>
          </gmd:northBoundLatitude>
        </gmd:EX_GeographicBoundingBox>
      </gmd:geographicElement>
    </xsl:if>
  </xsl:template-->

</xsl:stylesheet>

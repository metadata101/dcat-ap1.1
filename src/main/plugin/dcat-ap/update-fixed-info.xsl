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
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:spdx="http://spdx.org/rdf/terms#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:adms="http://www.w3.org/ns/adms#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dct="http://purl.org/dc/terms/" xmlns:dcat="http://www.w3.org/ns/dcat#" xmlns:vcard="http://www.w3.org/2006/vcard/ns#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:schema="http://schema.org/" xmlns:locn="http://www.w3.org/ns/locn#" xmlns:gn-fn-dcat-ap="http://geonetwork-opensource.org/xsl/functions/profiles/dcat-ap" exclude-result-prefixes="#all">
	<!-- Tell the XSL processor to output XML. -->
	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
	<!-- =================================================================   -->
	<xsl:include href="layout/utility-fn.xsl"/>
	<xsl:variable name="serviceUrl" select="/root/env/siteURL"/>
	<xsl:variable name="publicationBaseUrl" select="gn-fn-dcat-ap:getPublicationBaseUrl()"/>
	<xsl:template match="/root">
		<xsl:apply-templates select="//rdf:RDF"/>
	</xsl:template>
	<!-- =================================================================  -->
	<xsl:template match="@*|node()[name(.)!= 'root']">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	<!-- ================================================================= -->
	<xsl:template match="dcat:Dataset" priority="10">
		<dcat:Dataset>
			<xsl:apply-templates select="@*[not(name(.) = 'rdf:about')]"/>
			<xsl:choose>
				<xsl:when test="@rdf:about='' or (@rdf:about!='' and starts-with(@rdf:about,$publicationBaseUrl))">
					<xsl:attribute name="rdf:about" select="concat($publicationBaseUrl,'/',/root/env/uuid)"/> 
				</xsl:when>
				<xsl:otherwise> 
					<xsl:attribute name="rdf:about" select="@rdf:about"/> 
				</xsl:otherwise>
			</xsl:choose>
			<dct:identifier>
				<xsl:message select="concat('Adding dct:identifier with value ',/root/env/uuid)" />
				<xsl:value-of select="/root/env/uuid"/>
			</dct:identifier>
			<xsl:apply-templates select="node()[not(name(.) = 'dct:identifier' and ./text() = /root/env/uuid)]"/>
		</dcat:Dataset>
	</xsl:template>

	<!-- Fill empty element and update existing with resourceType -->
	<xsl:template match="foaf:Agent/dct:type|dcat:theme|dct:accrualPeriodicity|dct:language|dcat:Dataset/dct:type|dct:format|dcat:mediaType|adms:status|dct:LicenseDocument/dct:type" priority="10">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
	    <xsl:variable name="inScheme" select="gn-fn-dcat-ap:getInSchemeURIByElementName(name(.),name(..))"/>
	    <xsl:variable name="rdfType" select="gn-fn-dcat-ap:getRdfTypeByElementName(name(.),name(..))"/>
			<xsl:choose>
				<xsl:when test="count(*)=0 or count(skos:Concept/*[name(.)='skos:prefLabel'])=0">
			    <skos:Concept rdf:about="">
			    	<xsl:if test="$rdfType!=''">
			    		<rdf:type rdf:resource="{$rdfType}"/>
			    	</xsl:if>
	          <skos:prefLabel xml:lang="nl"/>
	          <skos:prefLabel xml:lang="en"/>
	          <skos:prefLabel xml:lang="fr"/>
	          <skos:prefLabel xml:lang="de"/>
						<skos:inScheme rdf:resource="{$inScheme}"/>
			    </skos:Concept>
				</xsl:when>
				<xsl:otherwise>
			    <skos:Concept rdf:about="{skos:Concept/@rdf:about}">
			    	<xsl:if test="$rdfType!=''">
			    		<rdf:type rdf:resource="{$rdfType}"/>
			    	</xsl:if>
			    	<xsl:for-each select="skos:Concept/*[name(.)='skos:prefLabel']">
	          	<xsl:copy-of select="."/>
	          </xsl:for-each>
						<skos:inScheme rdf:resource="{$inScheme}"/>
			    </skos:Concept>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>

	<!-- Fix value for attribute -->
	<xsl:template match="rdf:Statement/rdf:object" priority="10">
		<xsl:copy>
			<xsl:copy-of select="@*[not(name()='rdf:datatype')]"/>
			<xsl:attribute name="rdf:datatype">xs:dateTime</xsl:attribute>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="locn:geometry" priority="10">
		<xsl:copy>
			<xsl:message select="concat('Incomming value for locn:geometry',.)" />
	    <xsl:variable name="coverage" select="."/>
	    <xsl:variable name="n" select="substring-after($coverage,'North ')"/>
	    <xsl:if test="string-length($n)=0">
				<xsl:copy-of select="@*|node()"/>
	    </xsl:if>
	    <xsl:if test="string-length($n)>0">
				<xsl:copy-of select="@*[not(name()='rdf:datatype')]"/>
		    <xsl:variable name="north" select="substring-before($n,',')"/>
		    <xsl:variable name="s" select="substring-after($coverage,'South ')"/>
		    <xsl:variable name="south" select="substring-before($s,',')"/>
		    <xsl:variable name="e" select="substring-after($coverage,'East ')"/>
		    <xsl:variable name="east" select="substring-before($e,',')"/>
		    <xsl:variable name="w" select="substring-after($coverage,'West ')"/>
		    <xsl:variable name="west" select="if (contains($w, '. '))
		                                      then substring-before($w,'. ') else $w"/>
		    <xsl:variable name="place" select="substring-after($coverage,'. ')"/>
	     	<xsl:variable name="isValid" select="number($west) and number($east) and number($south) and number($north)"/>
	      <xsl:if test="$isValid">
						<xsl:variable name="wktLiteral" select="concat('POLYGON ((',$west,' ',$south,',',$west,' ',$north,',',$east,' ',$north,',', $east,' ', $south,',', $west,' ',$south,'))')"/>
			     	<xsl:variable name="gmlLiteral" select="concat('&lt;gml:Polygon&gt;&lt;gml:exterior&gt;&lt;gml:LinearRing&gt;&lt;gml:posList&gt;',$west,' ',$south,' ',$west,' ', $north, ' ', $east, ' ', $north, ' ', $east, ' ', $south,' ', $west, ' ', $south, '&lt;/gml:posList&gt;&lt;/gml:LinearRing&gt;&lt;/gml:exterior&gt;&lt;/gml:Polygon&gt;')"/>
						<xsl:choose>
							<xsl:when test="ends-with(@rdf:datatype,'#wktLiteral')">
								<xsl:attribute name="rdf:datatype" select="@rdf:datatype"/>
				      	<xsl:value-of select="$wktLiteral"/>
				      	<xsl:message select="concat('Updated value with ',$wktLiteral)"/>
							</xsl:when>
							<xsl:when test="ends-with(@rdf:datatype,'#gmlLiteral')">
								<xsl:attribute name="rdf:datatype" select="@rdf:datatype"/>
				      	<xsl:value-of select="$gmlLiteral"/>
				      	<xsl:message select="concat('Updated value with ',$gmlLiteral)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="rdf:datatype">http://www.opengis.net/ont/geosparql#wktLiteral</xsl:attribute>
				      	<xsl:value-of select="$wktLiteral"/>
							</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<xsl:if test="not($isValid)">
		     	<xsl:message select="concat('Updated value with Vlaanderen.  Could not parse value (',.,')')"/>
					<xsl:attribute name="rdf:datatype">http://www.opengis.net/ont/geosparql#wktLiteral</xsl:attribute>
					<xsl:value-of>POLYGON ((2.53 50.67,2.53 51.51,5.92 51.51,5.92 50.67,2.53 50.67))</xsl:value-of>
				</xsl:if>
			</xsl:if>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>

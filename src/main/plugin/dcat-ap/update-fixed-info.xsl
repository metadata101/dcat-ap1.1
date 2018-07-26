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
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:spdx="http://spdx.org/rdf/terms#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:adms="http://www.w3.org/ns/adms#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dct="http://purl.org/dc/terms/" xmlns:dcat="http://www.w3.org/ns/dcat#" xmlns:vcard="http://www.w3.org/2006/vcard/ns#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:schema="http://schema.org/" xmlns:gn-fn-dcat-ap="http://geonetwork-opensource.org/xsl/functions/profiles/dcat-ap" exclude-result-prefixes="#all">
	<!-- Tell the XSL processor to output XML. -->
	<xsl:output method="xml" indent="yes"/>
	<!-- =================================================================   -->
	<xsl:include href="layout/utility-fn.xsl"/>
	<xsl:variable name="serviceUrl" select="/root/env/siteURL"/>
	
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
		<xsl:message>Updating dataset</xsl:message>
		<dcat:Dataset>
			<xsl:apply-templates select="@*"/>
			<dct:identifier>
				<xsl:message select="concat('Adding dct:identifier with value ',/root/env/uuid)" />
				<xsl:value-of select="/root/env/uuid"/>
			</dct:identifier>
			<xsl:apply-templates select="node()[not(name(.) = 'dct:identifier' and ./text() = /root/env/uuid)]"/>
		</dcat:Dataset>
	</xsl:template>

	<!-- Fill empty element and update existing with resourceType -->
	<xsl:template match="foaf:Agent/dct:type|dcat:theme|dct:accrualPeriodicity|dct:language|dcat:Dataset/dct:type|dct:LicenseDocument/dct:type|dct:format|dcat:mediaType" priority="10">
		<xsl:copy>
			<xsl:message select="concat('Updating element with name ',name(.))" />
			<xsl:apply-templates select="@*"/>
	    <xsl:variable name="resource" select="gn-fn-dcat-ap:getResourceByElementName(name(.),name(..))"/>
	    <xsl:variable name="resourceType" select="gn-fn-dcat-ap:getResourceTypeByElementName(name(.),name(..))"/>
			<xsl:choose>
				<xsl:when test="count(*)=0 or count(skos:Concept/*[name(.)='skos:prefLabel'])=0">
			    <skos:Concept rdf:about="">
			    	<rdf:type rdf:resource="{$resourceType}"/>
	          <skos:prefLabel xml:lang="nl"/>
	          <skos:prefLabel xml:lang="en"/>
	          <skos:prefLabel xml:lang="fr"/>
	          <skos:prefLabel xml:lang="de"/>
						<skos:inScheme rdf:resource="{$resource}"/>
			    </skos:Concept>
				</xsl:when>
				<xsl:otherwise>
			    <skos:Concept rdf:about="{skos:Concept/@rdf:about}">
			    	<rdf:type rdf:resource="{$resourceType}"/>
			    	<xsl:for-each select="skos:Concept/*[name(.)='skos:prefLabel']">
	          	<xsl:copy-of select="."/>
	          </xsl:for-each>
						<skos:inScheme rdf:resource="{$resource}"/>
			    </skos:Concept>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>

	<!-- Fix value for attribute -->
	<xsl:template match="rdf:Statement/rdf:object" priority="10">
		<xsl:copy>
			<xsl:message select="'Updating rdf:object with fix value'" />
			<xsl:copy-of select="@*[not(name()='rdf:datatype')]"/>
			<xsl:attribute name="rdf:datatype">xs:dateTime</xsl:attribute>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>

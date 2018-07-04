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

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:gn-fn-dcat-ap="http://geonetwork-opensource.org/xsl/functions/profiles/dcat-ap"
	exclude-result-prefixes="#all">

  <xsl:function name="gn-fn-dcat-ap:getThesaurusTitle" as="xs:string">
	<xsl:param name="resource"/>
	<xsl:variable name="resourceBaseUrl" select="'http://publications.europa.eu/resource/authority/'"/>
	<xsl:choose>
		<xsl:when test="$resource = concat($resourceBaseUrl,'data-theme')">
			<xsl:value-of select="'Theme thesaurus'"/>
		</xsl:when>
		<xsl:when test="$resource = concat($resourceBaseUrl,'language')">
			<xsl:value-of select="'Language thesaurus'"/>
		</xsl:when>
		<xsl:when test="$resource = concat($resourceBaseUrl,'organization-type')">
			<xsl:value-of select="'Organization type thesaurus'"/>
		</xsl:when>
		<xsl:when test="$resource = concat($resourceBaseUrl,'file-type')">
			<xsl:value-of select="'File type thesaurus'"/>
		</xsl:when>
		<xsl:when test="$resource = concat($resourceBaseUrl,'licence')">
			<xsl:value-of select="'Licence thesaurus'"/>
		</xsl:when>
		<xsl:otherwise>
	  		<xsl:value-of select="'Untitled thesaurus'"/>
		</xsl:otherwise>
	</xsl:choose>
  </xsl:function>

</xsl:stylesheet>

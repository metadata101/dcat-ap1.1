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

  <xsl:variable name="resourceBaseUrl" select="'http://publications.europa.eu/resource/theme/'"/>
  <xsl:variable name="thesaurusIdentifierBaseKey" select="'geonetwork.thesaurus.external.theme.'"/>

  <xsl:function name="gn-fn-dcat-ap:getResourceByElementName" as="xs:string">
	<xsl:param name="elementName"/>
	<xsl:param name="parentElementName"/>
		<xsl:choose>
			<xsl:when test="$elementName = 'dcat:theme'">
				<xsl:value-of select="concat($resourceBaseUrl,'data-theme')"/>
			</xsl:when>
			<xsl:when test="$elementName = 'dct:language'">
				<xsl:value-of select="concat($resourceBaseUrl,'language')"/>
			</xsl:when>
			<xsl:when test="$elementName = 'dct:type' and $parentElementName = 'dcat:Dataset'">
				<xsl:value-of select="concat($resourceBaseUrl,'resource-type')"/>
			</xsl:when>
			<xsl:when test="$elementName = 'dct:type' and $parentElementName = 'foaf:Agent'">
				<xsl:value-of select="concat($resourceBaseUrl,'organization-type')"/>
			</xsl:when>
			<xsl:when test="$elementName = 'dcat:mediaType'">
				<xsl:value-of select="concat($resourceBaseUrl,'media-type')"/>
			</xsl:when>
			<xsl:when test="$elementName = 'dct:format'">
				<xsl:value-of select="concat($resourceBaseUrl,'file-type')"/>
			</xsl:when>
	  		<xsl:when test="$elementName = 'dct:license'">
				<xsl:value-of select="concat($resourceBaseUrl,'licence')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="''"/>
			</xsl:otherwise>
		</xsl:choose>
  </xsl:function>

  <xsl:function name="gn-fn-dcat-ap:getResourceTypeByElementName" as="xs:string">
	<xsl:param name="elementName"/>
	<xsl:param name="parentElementName"/>
		<xsl:choose>
			<xsl:when test="$elementName = 'dcat:theme'">
				<xsl:value-of select="''"/>
			</xsl:when>
			<xsl:when test="$elementName = 'dct:language'">
				<xsl:value-of select="'dct:LinguisticSystem'"/>
			</xsl:when>
			<xsl:when test="$elementName = 'dct:type' and $parentElementName = 'dcat:Dataset'">
				<xsl:value-of select="''"/>
			</xsl:when>
			<xsl:when test="$elementName = 'dct:type' and $parentElementName = 'foaf:Agent'">
				<xsl:value-of select="''"/>
			</xsl:when>
			<xsl:when test="$elementName = 'dct:type' and $parentElementName = 'dct:LicenseDocument'">
				<xsl:value-of select="'dct:LicenseDocument'"/>
			</xsl:when>
			<xsl:when test="$elementName = 'dcat:mediaType'">
				<xsl:value-of select="'dct:MediatypeOrExtent'"/>
			</xsl:when>
			<xsl:when test="$elementName = 'dct:format'">
				<xsl:value-of select="''"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="''"/>
			</xsl:otherwise>
		</xsl:choose>
  </xsl:function>

  <xsl:function name="gn-fn-dcat-ap:getThesaurusTitle" as="xs:string">
	<xsl:param name="resource"/>
	<xsl:choose>
		<xsl:when test="$resource = concat($resourceBaseUrl,'data-theme')">
			<xsl:value-of select="'Theme thesaurus'"/>
		</xsl:when>
		<xsl:when test="$resource = concat($resourceBaseUrl,'language')">
			<xsl:value-of select="'Language thesaurus'"/>
		</xsl:when>
		<xsl:when test="$resource = concat($resourceBaseUrl,'resource-type')">
			<xsl:value-of select="'Resource type thesaurus'"/>
		</xsl:when>
<!--
		<xsl:when test="$resource = concat($resourceBaseUrl,'media-type')">
			<xsl:value-of select="'Media type thesaurus'"/>
		</xsl:when>
-->
		<xsl:when test="$resource = concat($resourceBaseUrl,'organization-type')">
			<xsl:value-of select="'Organization type thesaurus'"/>
		</xsl:when>
		<xsl:when test="$resource = concat($resourceBaseUrl,'file-type')">
			<xsl:value-of select="'File type thesaurus'"/>
		</xsl:when>
		<xsl:otherwise>
	  		<xsl:value-of select="'Untitled thesaurus'"/>
		</xsl:otherwise>
	</xsl:choose>
  </xsl:function>

  <xsl:function name="gn-fn-dcat-ap:getThesaurusIdentifier" as="xs:string">
	<xsl:param name="resource"/>
	<xsl:value-of select="concat($thesaurusIdentifierBaseKey,substring-after($resource,$resourceBaseUrl))"/>
  </xsl:function>

  <xsl:function name="gn-fn-dcat-ap:isNotMultilingualField" as="xs:boolean">
    <xsl:param name="element" as="node()"/>
    <xsl:param name="editorConfig" as="node()"/>

    <xsl:variable name="elementName" select="name($element)"/>

    <xsl:variable name="exclusionMatchesParent" as="xs:boolean">
      <xsl:variable name="parentName"
                    select="name($element/..)"/>

      <xsl:value-of select="count($editorConfig/editor/multilingualFields/exclude/
                                  name[. = $elementName]/@parent[. = $parentName]) > 0"/>
    </xsl:variable>


    <xsl:variable name="exclusionMatchesAncestor" as="xs:boolean">
      <xsl:variable name="ancestorNames"
                    select="$element/ancestor::*/name()"/>

      <xsl:value-of select="count($editorConfig/editor/multilingualFields/exclude/
                                  name[. = $elementName]/@ancestor[. = $ancestorNames]) > 0"/>
    </xsl:variable>


    <xsl:variable name="exclusionMatchesChild" as="xs:boolean">
      <xsl:variable name="childName"
                    select="name($element/*[1])"/>

      <xsl:value-of select="count($editorConfig/editor/multilingualFields/exclude/
                                  name[. = $elementName]/@child[. = $childName]) > 0"/>
    </xsl:variable>



    <xsl:variable name="excluded"
                  as="xs:boolean"
                  select="
                    count($editorConfig/editor/multilingualFields/exclude/name[. = $elementName and not(@*)]) > 0 or
                      $exclusionMatchesAncestor = true() or
                      $exclusionMatchesParent = true() or
                      $exclusionMatchesChild = true()"/>

    <xsl:value-of select="$excluded"/>
  </xsl:function>

  <!-- Get field if templateModeOnly is true based on editor configuration.
  Search by element name or the child element name (the one
  containing the value).

  The child element take priority if defined.
  -->
  <xsl:function name="gn-fn-dcat-ap:getField" as="node()">
    <xsl:param name="configuration" as="node()"/>
    <!-- The container element -->
    <xsl:param name="name" as="xs:string"/>
    <!-- The element containing the value eg. gco:Date -->
    <xsl:param name="childName" as="xs:string?"/>
		<xsl:message select="concat('Searching for template for field with name ',$name)"/>
    <xsl:variable name="childNode"
                  select="$configuration/editor/fields/for[@name = $childName and @templateModeOnly]" />
    <xsl:variable name="node"
                  select="$configuration/editor/fields/for[@name = $name and @templateModeOnly]" />

    <xsl:choose>
			<xsl:when test="count($childNode/*)>0">
		<xsl:message select="'Found childNode'"/>
	    	<xsl:value-of select="$childNode"/>
    	</xsl:when>
			<xsl:when test="count($node/*)>0">
		<xsl:message select="'Found child'"/>
	    	<xsl:value-of select="$node"/>
    	</xsl:when>
    	<xsl:otherwise>
		<xsl:message select="'Found nothing'"/>
    		<for/>
    	</xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>

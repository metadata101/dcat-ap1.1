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


<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:adms="http://www.w3.org/ns/adms#"
	xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dct="http://purl.org/dc/terms/"
	xmlns:dcat="http://www.w3.org/ns/dcat#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:vcard="http://www.w3.org/2006/vcard/ns#" xmlns:locn="http://www.w3.org/ns/locn#"
	xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:spdx="http://spdx.org/rdf/terms#" xmlns:schema="http://schema.org/"
	xmlns:gn-fn-render="http://geonetwork-opensource.org/xsl/functions/render"
	xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
  xmlns:gn-fn-dcat-ap="http://geonetwork-opensource.org/xsl/functions/profiles/dcat-ap"
	exclude-result-prefixes="#all">

	<!-- Load the editor configuration to be able to render the different views -->
	<xsl:variable name="configuration"
		select="document('../../layout/config-editor.xml')" />

	<!-- Some utility -->
	<xsl:include href="../../layout/evaluate.xsl" />
  <xsl:include href="../../layout/utility-fn.xsl"/>

	<!-- The core formatter XSL layout based on the editor configuration -->
	<xsl:include href="sharedFormatterDir/xslt/render-layout.xsl" />

	<!-- The stylesheet 'common/functions-metadata.xsl' relies on two variables 
		'iso19139labels' and 'defaultFieldType' -->
	<xsl:variable name="iso19139labels" select="dummy" />
	<xsl:variable name="defaultFieldType" select="'text'" />
	<xsl:include href="common/functions-metadata.xsl" />

	<!-- Define the metadata to be loaded for this schema plugin -->
	<xsl:variable name="metadata" select="/root/rdf:RDF" />
	<xsl:variable name="langId" select="/root/gui/language" />  
	<xsl:variable name="nodeUrl" select="/root/gui/nodeUrl"/>

	<!-- Create a SchemaLocalizations object to look up nodeLabels with function 
		tr:node-label($schemaLocalizations, name(), name(..)). This is no longer 
		used -->
	<!-- xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations" -->
	<!-- <xsl:variable name="schemaLocalizations" select="tr:create($schema)" 
		/> -->

	<!-- The labels and their translations -->
	<xsl:variable name="schemaInfo" select="/root/schemas/*[name(.)=$schema]" />
	<xsl:variable name="labels" select="$schemaInfo/labels" />

	<!-- Specific schema rendering -->
	<xsl:template mode="getMetadataTitle" match="rdf:RDF">
		<xsl:value-of select="//dcat:Dataset/dct:title[1]" />
	</xsl:template>

	<xsl:template mode="getMetadataAbstract" match="rdf:RDF">
		<xsl:value-of select="//dcat:Dataset/dct:description" />
	</xsl:template>

	<xsl:template mode="getMetadataHeader" match="rdf:RDF">
	</xsl:template>

	<xsl:template mode="getMetadataThumbnail" match="rdf:RDF">
	</xsl:template>


	<xsl:template mode="render-view" match="field[template]"
		priority="3">
		<xsl:param name="base" select="$metadata" />

		<xsl:variable name="fieldXpath" select="@xpath" />
		<xsl:variable name="fields" select="template/values/key" />

		<!-- Get all elements that are within a dcat-ap namespace -->
		<xsl:variable name="elements">
			<xsl:call-template name="evaluate-dcat-ap">
				<xsl:with-param name="base" select="$base" />
				<xsl:with-param name="in" select="concat('/../', $fieldXpath)" />
			</xsl:call-template>
		</xsl:variable>

		<!-- Render fields for each dcat-ap element -->
		<xsl:for-each select="$elements/*">
			<xsl:variable name="element" select="."/>
			<xsl:apply-templates mode="render-field" select="$element" />
		</xsl:for-each>
	</xsl:template>



	<!-- ########################## -->
	<!-- Render fields... -->

	<xsl:template mode="render-field" match="dcat:Dataset">
		<xsl:apply-templates mode="render-field" select="@*|*" />
	</xsl:template>

	<xsl:template mode="render-field"
		match="dct:title|dct:description|dct:created|dct:issued|dct:modified|dct:identifier|foaf:name|skos:notation|schema:startDate|schema:endDate|vcard:street-address|vcard:locality|vcard:postal-code|vcard:country-name|vcard:hasEmail|vcard:hasURL|vcard:hasTelephone|vcard:fn|vcard:organization-name|skos:prefLabel">
		<dl>
			<dt style="font-weight:bold;">
				<xsl:value-of
					select="gn-fn-metadata:getLabel($schema, name(.), $labels, name(..), name(..), concat(dcat:getParentXPath(name(..)),gn-fn-metadata:getXPath(.)))/label" />
				<xsl:if test="@xml:lang">
					<xsl:value-of select="concat(' (',@xml:lang,')')" />
				</xsl:if>
			</dt>
			<dd>
				<xsl:apply-templates mode="render-value" select="." />
			</dd>
		</dl>
	</xsl:template>

	<xsl:template mode="render-field" match="@rdf:about">
		<dl>
			<dt style="font-weight:bold;">
				URI
			</dt>
			<dd>
				<xsl:apply-templates mode="render-url" select="." />
			</dd>
		</dl>
	</xsl:template>

	<xsl:template mode="render-field" match="dcat:keyword">
		<xsl:if test="not(preceding-sibling::dcat:keyword[position()=1])">
			<dl class="gn-keyword">
				<dt style="font-weight:bold;">
					<xsl:value-of
						select="gn-fn-metadata:getLabel($schema, name(.), $labels, name(..), name(..), concat(dcat:getParentXPath(name(..)),gn-fn-metadata:getXPath(.)))/label" />

				</dt>
				<dd>
				</dd>
			</dl>
		</xsl:if>
		<div
			style="background-color: #FFE615; border: 1px solid; border-color: #333; border-radius: 2px; text-align: center; padding: 6px 6px; display: inline-block;">
			<a href="{concat($nodeUrl,$langId,'/catalog.search?resultType=details&amp;sortBy=relevance&amp;from=1&amp;to=20&amp;keyword=',.)}">
				<xsl:apply-templates mode="render-value" select="." />
				<xsl:if test="@xml:lang">
					<xsl:value-of select="concat(' (',@xml:lang,')')" />
				</xsl:if>
			</a>
		</div>
	</xsl:template>

	<xsl:template mode="render-field"
		match="dcat:accessURL|dcat:downloadURL|dcat:landingPage">
		<dl>
			<dt style="font-weight:bold;">
				<xsl:value-of
					select="gn-fn-metadata:getLabel($schema, name(.), $labels, name(..), name(..), concat(dcat:getParentXPath(name(..)),gn-fn-metadata:getXPath(.),'/@rdf:resource'))/label" />
			</dt>
			<dd>
				<xsl:apply-templates mode="render-url" select="@rdf:resource" />
			</dd>
		</dl>
	</xsl:template>

	<xsl:template mode="render-field"
		match="dct:format|dcat:mediaType|dct:language|dcat:theme|dct:accrualPeriodicity|dct:type">
		<dl>
			<dt style="font-weight:bold;">
				<xsl:value-of
					select="gn-fn-metadata:getLabel($schema, name(.), $labels, name(..), name(..), concat(dcat:getParentXPath(name(..)),gn-fn-metadata:getXPath(.)))/label" />
			</dt>
			<dd>
				<xsl:for-each select="skos:Concept/skos:prefLabel">
					<a href="skos:Concept/@rdf:about">
						<xsl:apply-templates mode="render-value"
							select="." />
					</a>
					<xsl:if test="position() != last()">
						,
					</xsl:if>
				</xsl:for-each>
				<xsl:for-each select="skos:Concept/@rdf:about">
					(
					<xsl:apply-templates mode="render-url" select="." />
					)
				</xsl:for-each>
			</dd>
		</dl>
	</xsl:template>

	<!-- Bbox is displayed with an overview and the geom displayed on it and 
		the coordinates displayed around -->
	<xsl:template mode="render-field" match="dct:Location">
		<dl>
			<dt>
				<h3>
					<xsl:value-of
						select="gn-fn-metadata:getLabel($schema, name(.), $labels, name(..), name(..), concat(dcat:getParentXPath(name(..)),gn-fn-metadata:getXPath(.)))/label" />
				</h3>
			</dt>
			<dd>
		    <xsl:apply-templates mode="render-field" select="@rdf:about" />
		    <xsl:apply-templates mode="render-field" select="skos:prefLabel[1]" />
		    <xsl:message select="locn:geometry"/>
        <xsl:variable name="bbox" select="gn-fn-dcat-ap:getBboxCoordinates(node()[name(.)='locn:geometry'])"/>
        <xsl:variable name="bboxCoordinates" select="tokenize(replace($bbox,',','.'), '\|')"/>
        <xsl:if test="count($bboxCoordinates)=4">
          <xsl:copy-of
            select="gn-fn-render:bbox(
                          xs:double($bboxCoordinates[1]),
                          xs:double($bboxCoordinates[2]),
                          xs:double($bboxCoordinates[3]),
                          xs:double($bboxCoordinates[4]))" />

          <br />
          <br />
        </xsl:if>
			</dd>
		</dl>
	</xsl:template>


	<xsl:template mode="render-field"
		match="dcat:contactPoint|dct:publisher|dct:provenance|foaf:page|dct:temporal|dct:license|dct:rights|dct:accessRights|dct:conformsTo|dcat:distribution|adms:sample|vcard:hasAddress|adms:identifier">
		<dl>
			<dt>
				<h3>
					<xsl:value-of
						select="gn-fn-metadata:getLabel($schema, name(.), $labels, name(..), name(..), concat(dcat:getParentXPath(name(..)),gn-fn-metadata:getXPath(.)))/label" />
					<xsl:if test="@xml:lang">
						(
						<xsl:value-of select="." />
						)
					</xsl:if>
				</h3>
			</dt>
			<dd>
				<xsl:apply-templates mode="render-field" select="@*|*" />
			</dd>
		</dl>
	</xsl:template>

	<!-- Traverse the tree -->
	<xsl:template mode="render-field" match="*">
		<xsl:apply-templates mode="render-field" select="@*|*" />
	</xsl:template>





	<!-- ########################## -->
	<!-- Render values for text ... -->
	<xsl:template mode="render-value" match="*">
		<xsl:value-of select="." />
	</xsl:template>

	<!-- Render values for URL -->
	<xsl:template mode="render-url" match="*">
		<u>
			<a href="{.}" style="color=#06c; text-decoration: underline;">
				<xsl:value-of select="." />
				&#160;
			</a>
		</u>
	</xsl:template>

	<!-- ... Dates -->
	<xsl:template mode="render-value"
		match="*[matches(., '[0-9]{4}-[0-9]{2}-[0-9]{2}')]">
		<span data-gn-humanize-time="{.}" data-format="DD MMM YYYY">
			<xsl:value-of select="." />
		</span>
	</xsl:template>

	<xsl:template mode="render-value"
		match="*[matches(., '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}')]">
		<span data-gn-humanize-time="{.}">
			<xsl:value-of select="." />
		</span>
	</xsl:template>


	<!-- Return the XPath given an element's parent name in DCAT-AP. This is 
		quite a bit of a hack, but the full XPath is not available. -->
	<xsl:function name="dcat:getParentXPath" as="xs:string">
		<xsl:param name="parent" as="xs:string" />
		<xsl:choose>
			<xsl:when test="$parent = 'dcat:Distribution'">
				<xsl:value-of
					select="'/rdf:RDF/dcat:Catalog/dcat:dataset/dcat:Dataset/dcat:distribution'" />
			</xsl:when>
			<xsl:when test="$parent = 'dcat:distribution'">
				<xsl:value-of
					select="'/rdf:RDF/dcat:Catalog/dcat:dataset/dcat:Dataset/dcat:distribution'" />
			</xsl:when>
			<xsl:when test="$parent = 'foaf:Document'">
				<xsl:value-of
					select="'/rdf:RDF/dcat:Catalog/dcat:dataset/dcat:Dataset/dcat:distribution'" />
			</xsl:when>
			<xsl:when test="$parent = 'vcard:Organization'">
				<xsl:value-of
					select="'/rdf:RDF/dcat:Catalog/dcat:dataset/dcat:Dataset/dcat:contactPoint'" />
			</xsl:when>
			<xsl:when test="$parent = 'vcard:Address'">
				<xsl:value-of
					select="'/rdf:RDF/dcat:Catalog/dcat:dataset/dcat:Dataset/dcat:contactPoint'" />
			</xsl:when>
			<xsl:when test="$parent = 'foaf:Agent'">
				<xsl:value-of
					select="'/rdf:RDF/dcat:Catalog/dcat:dataset/dcat:Dataset/dct:publisher'" />
			</xsl:when>
			<xsl:when test="$parent = 'dct:PeriodOfTime'">
				<xsl:value-of
					select="'/rdf:RDF/dcat:Catalog/dcat:dataset/dcat:Dataset/dct:temporal'" />
			</xsl:when>
			<xsl:when test="$parent = 'adms:Identifier'">
				<xsl:value-of
					select="'/rdf:RDF/dcat:Catalog/dcat:dataset/dcat:Dataset/adms:identifier'" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'/rdf:RDF/dcat:Catalog/dcat:dataset/dcat:Dataset'" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

</xsl:stylesheet>

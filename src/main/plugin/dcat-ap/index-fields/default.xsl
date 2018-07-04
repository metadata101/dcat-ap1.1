<?xml version="1.0" encoding="UTF-8"?>
<!-- ~ Copyright (C) 2001-2016 Food and Agriculture Organization of the ~ 
	United Nations (FAO-UN), United Nations World Food Programme (WFP) ~ and 
	United Nations Environment Programme (UNEP) ~ ~ This program is free software; 
	you can redistribute it and/or modify ~ it under the terms of the GNU General 
	Public License as published by ~ the Free Software Foundation; either version 
	2 of the License, or (at ~ your option) any later version. ~ ~ This program 
	is distributed in the hope that it will be useful, but ~ WITHOUT ANY WARRANTY; 
	without even the implied warranty of ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR 
	PURPOSE. See the GNU ~ General Public License for more details. ~ ~ You should 
	have received a copy of the GNU General Public License ~ along with this 
	program; if not, write to the Free Software ~ Foundation, Inc., 51 Franklin 
	St, Fifth Floor, Boston, MA 02110-1301, USA ~ ~ Contact: Jeroen Ticheler 
	- FAO - Viale delle Terme di Caracalla 2, ~ Rome - Italy. email: geonetwork@osgeo.org -->
<xsl:stylesheet version="2.0" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dct="http://purl.org/dc/terms/" xmlns:spdx="http://spdx.org/rdf/terms#" xmlns:adms="http://www.w3.org/ns/adms#" xmlns:locn="http://www.w3.org/ns/locn#" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dcat="http://www.w3.org/ns/dcat#" xmlns:vcard="http://www.w3.org/2006/vcard/ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:util="java:org.fao.geonet.util.XslUtil" xmlns:geonet="http://www.fao.org/geonetwork">
	<!--TODO: uncomment
	<xsl:include href="../convert/functions.xsl"/>
	<xsl:include href="../../../xsl/utils-fn.xsl"/>
-->
	<!-- This file defines what parts of the metadata are indexed by Lucene 
		Searches can be conducted on indexes defined here. The Field@name attribute 
		defines the name of the search variable. If a variable has to be maintained 
		in the user session, it needs to be added to the GeoNetwork constants in 
		the Java source code. Please keep indexes consistent among metadata standards 
		if they should work accross different metadata resources -->
	<!-- ========================================================================================= -->
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!-- ========================================================================================= -->
	<xsl:template match="/">
		<xsl:apply-templates select="rdf:RDF/dcat:Catalog/dcat:dataset/dcat:Dataset"/>
	</xsl:template>
	<xsl:template match="dcat:Dataset">
			<!--TODO: uncomment<xsl:call-template name="langId-dcat-ap"/>-->
		<xsl:variable name="langCode">eng</xsl:variable>
		<Document locale="{$langCode}">
			<!-- locale information -->
			<Field name="_locale" string="{$langCode}" store="true" index="true"/>
			<Field name="_docLocale" string="{$langCode}" store="true" index="true"/>
			<!-- For multilingual docs it is good to have a title in the default locale. 
				In this type of metadata we don't have one but in the general case we do 
				so we need to add it to all -->
			<Field name="_defaultTitle" string="{string(dct:title)}" store="true" index="true"/>
			<xsl:for-each select="dct:language/skos:Concept/skos:prefLabel[@xml:lang='nl']">
				<Field name="mdLanguage" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>
			<xsl:for-each select="dct:identifier">
				<Field name="identifier" string="{string(.)}" store="false" index="true"/>
				<Field name="fileId" string="{string(.)}" store="false" index="true"/>
			</xsl:for-each>
			<Field name="type" string="dataset" store="true" index="true"/>			
			<xsl:for-each select="dct:description">
				<Field name="abstract" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>
			<xsl:for-each select="dct:issued">
				<Field name="createDate" string="{string(.)}" store="true" index="true"/>
				<Field name="createDateYear" string="{substring(string(.), 0, 5)}" store="true" index="true"/>
			</xsl:for-each>
			<xsl:for-each select="dct:modified">
				<Field name="changeDate" string="{string(.)}" store="true" index="true"/>
				<!--<Field name="createDateYear" string="{substring(., 0, 5)}" store="true" 
					index="true"/> -->
			</xsl:for-each>
			<xsl:for-each select="dct:type">
				<Field name="type" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>
			<xsl:for-each select="dct:source">
				<Field name="lineage" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>
			<xsl:for-each select="dct:relation">
				<Field name="relation" string="{string(.)}" store="false" index="true"/>
			</xsl:for-each>
			<xsl:for-each select="dct:accessRights">
				<Field name="MD_ConstraintsUseLimitation" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>
			<xsl:for-each select="dct:rights">
				<Field name="MD_LegalConstraintsUseLimitation" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>
			<xsl:for-each select="dct:spatial">
				<xsl:apply-templates select="dct:Location/locn:geometry[@rdf:datatype='http://www.opengis.net/ont/geosparql#wktLiteral']" mode="latLon"/>
				<Field name="spatial" string="{string(.)}" store="false" index="true"/>
			</xsl:for-each>
			<!-- This is needed by the CITE test script to look for strings like 'a 
				b*' strings that contain spaces -->
			<xsl:for-each select="dct:title">
				<Field name="title" string="{string(.)}" store="true" index="true"/>
				<!-- not tokenized title for sorting -->
				<Field name="_title" string="{string(.)}" store="false" index="true"/>
			</xsl:for-each>
			<!-- dcat:keyword -->
			<xsl:for-each select="dcat:keyword">
				<xsl:variable name="keyword" select="string(.)"/>
				<Field name="keyword" string="{$keyword}" store="true" index="true"/>
			</xsl:for-each>
			<Field name="thesaurusIdentifier"
                   string="data-theme"
                   store="true" index="true"/>
			<!-- dcat:theme -->
			<xsl:for-each select="dcat:theme/skos:Concept/skos:prefLabel">
				<xsl:variable name="theme" select="string(.)"/>
				<Field name="thesaurus-data-theme" string="{$theme}" store="true" index="true"/>
			</xsl:for-each>
			<!-- dcat:Distribution -->
			<xsl:for-each select="dcat:distribution/dcat:Distribution">
				<xsl:variable name="title" select="concat('titel: ',dct:title)"/>
				<xsl:variable name="description" select="concat('beschrijving',string(dct:description))"/>
				<xsl:variable name="dPosition" select="position()"/>
				<xsl:for-each select="dcat:accessURL">
					<xsl:variable name="aPosition" select="position()"/>
					<xsl:variable name="aURL" select="string(@rdf:resource)"/>
					<xsl:variable name="mimetype" select="text/csv"/>
					<!-- Index link -->
					<Field name="protocol" string="WWW:DOWNLOAD" store="true" index="true"/>
					<Field name="linkage_name_des" string="{string(concat($title, ':::', $description))}" store="true" index="true"/>
					<Field name="mimetype" string="{$mimetype}" store="true" index="true"/>
					<Field name="download" string="true" store="false" index="true"/>					
					<Field name="link" string="{concat($title, '|',$description,'|', $aURL, '|WWW:DOWNLOAD|text/csv|',$dPosition)}" store="true" index="true"/>
				</xsl:for-each>
				<xsl:for-each select="dcat:downloadURL">
					<xsl:variable name="bPosition" select="position()"/>
					<xsl:variable name="bURL" select="string(@rdf:resource)"/>
					<xsl:variable name="mimetype" select="text/csv"/>
					<!-- Index link -->
					<Field name="protocol" string="WWW:DOWNLOAD" store="true" index="true"/>
					<Field name="linkage_name_des" string="{string(concat($title, ':::', $description))}" store="true" index="true"/>
					<Field name="mimetype" string="{$mimetype}" store="true" index="true"/>
					<Field name="download" string="true" store="false" index="true"/>	
					<Field name="link" string="{concat($title, '|',$description,'|', $bURL, '|WWW:DOWNLOAD|text/csv|',$dPosition)}" store="true" index="true"/>
					<Field name="download" string="true" store="false" index="true"/>
				</xsl:for-each>
				<xsl:for-each select="dct:format/skos:Concept/skos:prefLabel">
					<Field name="format" string="{.}" store="true" index="true"/>
				</xsl:for-each>
				<!-- TODO: fix hardcoded language -->
				<xsl:for-each select="dct:license/skos:Concept/skos:prefLabel[@xml:lang='nl']">
					<Field name="MD_LegalConstraintsUseLimitation" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>
			</xsl:for-each>
			<!-- This index for "coverage" requires significant expansion to work 
				well for spatial searches. It now only works for very strictly formatted 
				content -->
			<!-- TODO parse wkt string polygon with java -->
			<!-- <xsl:for-each select="dct:spatial"> <xsl:variable name="coverage" 
				select="."/> <xsl:choose> <xsl:when test="starts-with(., 'North')"> <xsl:variable 
				name="n" select="substring-after($coverage,'North ')"/> <xsl:variable name="north" 
				select="substring-before($n, ',')"/> <xsl:variable name="s" select="substring-after($coverage,'South 
				')"/> <xsl:variable name="south" select="substring-before($s, ',')"/> <xsl:variable 
				name="e" select="substring-after($coverage,'East ')"/> <xsl:variable name="east" 
				select="substring-before($e, ',')"/> <xsl:variable name="w" select="substring-after($coverage,'West 
				')"/> <xsl:variable name="west" select="if (contains($w, '. ')) then substring-before($w, 
				'. ') else $w"/> <xsl:variable name="p" select="substring-after($coverage,'(')"/> 
				<xsl:variable name="place" select="substring-before($p,')')"/> <Field name="westBL" 
				string="{$west}" store="false" index="true"/> <Field name="eastBL" string="{$east}" 
				store="false" index="true"/> <Field name="southBL" string="{$south}" store="false" 
				index="true"/> <Field name="northBL" string="{$north}" store="false" index="true"/> 
				<Field name="geoBox" string="{concat($west, '|', $south, '|', $east, '|', 
				$north )}" store="true" index="false"/> <Field name="keyword" string="{$place}" 
				store="true" index="true"/> </xsl:when> <xsl:otherwise> <Field name="keyword" 
				string="{.}" store="true" index="true"/> </xsl:otherwise> </xsl:choose> </xsl:for-each> -->
			<xsl:for-each select="dct:isPartOf">
				<Field name="parentUuid" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>
			<xsl:for-each select="(dcat:landingPage)[normalize-space(.) != '']">
				<xsl:variable name="name" select="tokenize(., '/')[last()]"/>
				<xsl:variable name="tPosition" select="position()"/>
				<!-- Index link where last token after the last / is the link name. -->
				<Field name="link" string="{concat($name, '|description|', @rdf:resource, '|WWW:DOWNLOAD|WWW-DOWNLOAD|',$tPosition)}" store="true" index="false"/>
			</xsl:for-each>
			<xsl:for-each select="(dcat:landingPage)[normalize-space(.) != ''
                              and matches(., '.*(.gif|.png.|.jpeg|.jpg)$', 'i')]">
				<xsl:variable name="thumbnailType" select="if (position() = 1) then 'thumbnail' else 'overview'"/>
				<!-- First thumbnail is flagged as thumbnail and could be considered 
					the main one -->
				<Field name="image" string="{concat($thumbnailType, '|', ., '|')}" store="true" index="false"/>
			</xsl:for-each>
			<!-- TODO when using this we get an error about the concat first parameter 
				<Field name="any" store="false" index="true"> <xsl:attribute name="string"> 
				<xsl:value-of select="normalize-space(string(dcat:Dataset))"/> <xsl:text> 
				</xsl:text> <xsl:for-each select="//*/@*"> <xsl:value-of select="concat(., 
				' ')"/> </xsl:for-each> </xsl:attribute> </Field> -->
			<!-- locally searchable fields -->
			<!-- defaults to true -->
			<Field name="digital" string="true" store="false" index="true"/>
			<xsl:for-each select="dcat:contactPoint">
				<xsl:apply-templates mode="index-contact" select="vcard:Organization">
					<xsl:with-param name="type" select="'resource'"/>
					<xsl:with-param name="fieldPrefix" select="'responsibleParty'"/>
					<xsl:with-param name="position" select="position()"/>
				</xsl:apply-templates>
			</xsl:for-each>
			<xsl:for-each select="dct:publisher/foaf:Agent/foaf:name">
				<xsl:variable name="role" select="string($langCode)"/>
				<Field name="responsibleParty" string="{concat('Contact', '|resource|', ., '|')}" store="true" index="false"/>
			</xsl:for-each>
			<xsl:for-each select="dct:accrualPeriodicity">
				<Field name="updateFrequency" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>

		</Document>
	</xsl:template>
	<xsl:template mode="index-contact" match="vcard:Organization">
		<xsl:param name="type"/>
		<xsl:param name="fieldPrefix"/>
		<xsl:param name="position" select="'0'"/>
		<xsl:variable name="orgName" select="vcard:organization-name"/>
		<Field name="orgName" string="{string($orgName)}" store="true" index="true"/>
		<Field name="orgNameTree" string="{string($orgName)}" store="true" index="true"/>
		<xsl:variable name="role" select="'Contact'"/>
		<!--<xsl:variable name="roleTranslation"
                  select="util:getCodelistTranslation('gmd:CI_RoleCode', string($role), string($isoLangId))"/>-->
		<xsl:variable name="email" select="vcard:hasEmail"/>
		<xsl:variable name="phone" select="vcard:hasTelephone[normalize-space(.) != '']/*/text()"/>
		<xsl:variable name="individualName" select="vcard:fn/text()"/>
		<xsl:variable name="address" select="string-join(vcard:hasAddress/vcard:Address/(
                                        vcard:street-address|vcard:postal-code|vcard:locality|
                                        vcard:locality|vcard:country-name)/text(), ', ')"/>
		<Field name="{$fieldPrefix}" string="{concat('contact', '|', $type,'|',
                             $orgName, '|',
							 '', '|',
                             string-join($email, ','), '|',
                             $individualName, '|',
                             'contactpersoon', '|',
                             $address, '|',
                             string-join($phone, ','), '|',
                             'uuid', '|',
                             $position)}" store="true" index="false"/>
		<xsl:for-each select="$email">
			<Field name="{$fieldPrefix}Email" string="{string(.)}" store="true" index="true"/>
			<!--  <Field name="{$fieldPrefix}RoleAndEmail" string="{$role}|{string(.)}" store="true" index="true"/> -->
		</xsl:for-each>
	</xsl:template>
	<!-- {java:getCodelistTranslation('dcat:MD_MaintenanceFrequencyCode', string(.), 
		string($langCode))} -->
	<!-- ========================================================================================= -->
	
</xsl:stylesheet>

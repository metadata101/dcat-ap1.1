<?xml version="1.0" encoding="UTF-8" ?>

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

<xsl:stylesheet version="2.0" xmlns:foaf="http://xmlns.com/foaf/0.1/"
                 xmlns:schema="http://schema.org/"
                 xmlns:owl="http://www.w3.org/2002/07/owl#"
                 xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                 xmlns:dct="http://purl.org/dc/terms/" xmlns:spdx="http://spdx.org/rdf/terms#"
                 xmlns:adms="http://www.w3.org/ns/adms#" xmlns:locn="http://www.w3.org/ns/locn#"
                 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dcat="http://www.w3.org/ns/dcat#"
                 xmlns:vcard="http://www.w3.org/2006/vcard/ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                 xmlns:util="java:org.fao.geonet.util.XslUtil" xmlns:geonet="http://www.fao.org/geonetwork">
<xsl:include href="../convert/functions.xsl" />
<xsl:include href="../../../../xsl/utils-fn.xsl" />

	<!-- This file defines what parts of the metadata are indexed by Lucene
	     Searches can be conducted on indexes defined here.
	     The Field@name attribute defines the name of the search variable.
		 If a variable has to be maintained in the user session, it needs to be
		 added to the GeoNetwork constants in the Java source code.
		 Please keep indexes consistent among metadata standards if they should
		 work accross different metadata resources -->
	<!-- ========================================================================================= -->

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>

	<!-- ========================================================================================= -->

  <xsl:variable name="isoDocLangId">
    <xsl:call-template name="langId-dcat-ap" />
  </xsl:variable>

  <xsl:variable name="langId">
    <xsl:call-template name="langId3to2">
      <xsl:with-param name="langId-3char" select="$isoDocLangId" />
    </xsl:call-template>
  </xsl:variable>

  <xsl:template match="/">

    <Documents>
			<xsl:variable name="datasets" select="//dcat:Dataset"/>
      <xsl:for-each select="distinct-values(//dcat:Dataset//@xml:lang)">

        <xsl:variable name="isoLangId">
			    <xsl:call-template name="langId2to3">
			      <xsl:with-param name="langId-2char" select="." />
			    </xsl:call-template>
        </xsl:variable>

        <xsl:if test="not($isoLangId = $isoDocLangId)">
          <xsl:call-template name="document">
            <xsl:with-param name="datasets" select="$datasets"/>
            <xsl:with-param name="isoLangId" select="$isoLangId"/>
          </xsl:call-template>
        </xsl:if>

      </xsl:for-each>
    </Documents>

  </xsl:template>

  <!-- ========================================================================================= -->

  <xsl:template name="document">
    <xsl:param name="datasets"/>
    <xsl:param name="isoLangId"/>

    <Document locale="{$isoLangId}">
	    <Field name="_locale" string="{$isoLangId}" store="true" index="true"/>
	    <Field name="_docLocale" string="{$isoDocLangId}" store="true" index="true"/>
			<xsl:for-each select="$datasets">
		    <xsl:apply-templates select=".">
		      <xsl:with-param name="langId" select="$langId"/>
		      <xsl:with-param name="isoLangId" select="$isoLangId"/>
		    </xsl:apply-templates>
			</xsl:for-each>
    </Document>

  </xsl:template>

  <xsl:template match="dcat:Dataset">
    <xsl:param name="isoLangId"/>
    <xsl:param name="langId"/>

    <xsl:variable name="_defaultTitle">
      <xsl:call-template name="defaultTitle">
        <xsl:with-param name="isoDocLangId" select="$isoLangId" />
      </xsl:call-template>
    </xsl:variable>

    <Field name="_defaultTitle" string="{string($_defaultTitle)}"
           store="true" index="true" />

    <!-- not tokenized title for sorting, needed for multilingual sorting -->
    <xsl:if test="geonet:info/isTemplate != 's'">
      <Field name="_title" string="{string($_defaultTitle)}" store="true"
             index="true" />
    </xsl:if>

    <xsl:variable name="_defaultAbstract">
      <xsl:call-template name="defaultAbstract">
        <xsl:with-param name="isoDocLangId" select="$isoLangId" />
      </xsl:call-template>
    </xsl:variable>

    <Field name="_defaultAbstract" string="{string($_defaultAbstract)}"
           store="true" index="true" />

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- === Free text search === -->
    <Field name="any" store="false" index="true">
        <xsl:attribute name="string">
          <xsl:for-each select=".//node()[@xml:lang=$langId]">
            <xsl:value-of select="concat(normalize-space(.), ' ')"/>
          </xsl:for-each>
        </xsl:attribute>
    </Field>

    <xsl:call-template name="index-lang-tag">
      <xsl:with-param name="tag" select="dct:description"/>
      <xsl:with-param name="field" select="'abstract'"/>
      <xsl:with-param name="langId" select="$langId"/>
    </xsl:call-template>

    <xsl:call-template name="index-lang-tag">
      <xsl:with-param name="tag" select="dcat:theme"/>
      <xsl:with-param name="field" select="'dcat_theme'"/>
      <xsl:with-param name="langId" select="$langId"/>
    </xsl:call-template>

    <xsl:for-each select="dcat:distribution/dcat:Distribution">

      <xsl:variable name="mediaTypeConceptLabel">
        <xsl:call-template name="index-lang-tag-oneval">
          <xsl:with-param name="tag" select="dct:mediaType"/>
          <xsl:with-param name="langId" select="$langId"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:call-template name="index-lang-tag">
        <xsl:with-param name="tag" select="dct:format"/>
        <xsl:with-param name="field" select="'format'"/>
        <xsl:with-param name="langId" select="$langId"/>
      </xsl:call-template>

      <xsl:call-template name="index-lang-tag">
        <xsl:with-param name="tag" select="dct:license"/>
        <xsl:with-param name="field" select="'MD_LegalConstraintsUseLimitation'"/>
        <xsl:with-param name="langId" select="$langId"/>
      </xsl:call-template>

    </xsl:for-each>

  </xsl:template>

</xsl:stylesheet>

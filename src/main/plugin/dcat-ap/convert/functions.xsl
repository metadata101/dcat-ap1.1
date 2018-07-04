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
				xmlns:dct="http://purl.org/dc/terms/"
				xmlns:dcat="http://www.w3.org/ns/dcat#"
				xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
				xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:date="http://exslt.org/dates-and-times"
                xmlns:java="java:org.fao.geonet.util.XslUtil"
                xmlns:joda="java:org.fao.geonet.domain.ISODate"
                xmlns:mime="java:org.fao.geonet.util.MimeTypeFinder"              
                version="2.0"
                exclude-result-prefixes="#all">
  <!-- ========================================================================================= -->
  <!-- latlon coordinates indexed as numeric. -->

  <xsl:template match="*" mode="latLon">
  	<xsl:message>TO DO: Indexing location</xsl:message>
  </xsl:template>
  <!-- ================================================================== -->

  <xsl:template name="fixSingle">
    <xsl:param name="value"/>

    <xsl:choose>
      <xsl:when test="string-length(string($value))=1">
        <xsl:value-of select="concat('0',$value)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ================================================================== -->

  <xsl:template name="getMimeTypeFile">
    <xsl:param name="datadir"/>
    <xsl:param name="fname"/>
    <xsl:value-of select="mime:detectMimeTypeFile($datadir,$fname)"/>
  </xsl:template>

  <!-- ==================================================================== -->

  <xsl:template name="getMimeTypeUrl">
    <xsl:param name="linkage"/>
    <xsl:value-of select="mime:detectMimeTypeUrl($linkage)"/>
  </xsl:template>



  <!-- ================================================================== -->
  <!-- iso3code of default index language -->
  <xsl:variable name="defaultLang">dut</xsl:variable>

  <xsl:template name="langId-dcat-ap">
	<xsl:variable name="authorityLanguage" select="/*[name(.)='rdf:RDF']/dcat:Catalog/dcat:dataset/dcat:Dataset/dct:language[1]/skos:Concept/@rdf:about" />
    <xsl:variable name="tmp">
		<xsl:choose>
			<xsl:when test="ends-with($authorityLanguage,'NLD')">dut</xsl:when>
			<xsl:when test="ends-with($authorityLanguage,'FRA')">fre</xsl:when>
			<xsl:when test="ends-with($authorityLanguage,'ENG')">eng</xsl:when>
			<xsl:when test="ends-with($authorityLanguage,'DEU')">ger</xsl:when>
			<xsl:otherwise><xsl:value-of select="$defaultLang"/></xsl:otherwise>
		</xsl:choose>
    </xsl:variable>
    <xsl:value-of select="normalize-space(string($tmp))"></xsl:value-of>
  </xsl:template>

  <xsl:template name="defaultTitle">
    <xsl:param name="isoDocLangId"/>

    <xsl:variable name="poundLangId"
                  select="concat('#',upper-case(java:twoCharLangCode($isoDocLangId)))"/>

    <xsl:variable name="docLangTitle"
                  select="dct:title[@xml:lang=$poundLangId]"/>
    <xsl:variable name="firstTitle"
                  select="dct:title"/>
    <xsl:choose>
      <xsl:when test="string-length(string($docLangTitle)) != 0">
        <xsl:value-of select="$docLangTitle[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="string($firstTitle[1])"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="defaultAbstract">
    <xsl:param name="isoDocLangId"/>

    <xsl:variable name="poundLangId"
                  select="concat('#',upper-case(java:twoCharLangCode($isoDocLangId)))"/>

    <xsl:variable name="docLangAbstract"
                  select="dct:description[@xml:lang=$poundLangId]"/>
    <xsl:variable name="firstAbstract"
                  select="dct:description"/>
    <xsl:choose>
      <xsl:when test="string-length(string($docLangAbstract)) != 0">
        <xsl:value-of select="$docLangAbstract[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="string($firstAbstract[1])"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>

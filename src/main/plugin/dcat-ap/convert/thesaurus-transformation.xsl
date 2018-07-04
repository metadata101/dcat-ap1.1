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
				xmlns:dct="http://purl.org/dc/terms/" 
				xmlns:dcat="http://www.w3.org/ns/dcat#"
				xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
				xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:util="java:org.fao.geonet.util.XslUtil"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:gn-fn-dcat-ap="http://geonetwork-opensource.org/xsl/functions/profiles/dcat-ap"
                exclude-result-prefixes="#all">


  <!-- A set of templates use to convert thesaurus concept to ISO19139 fragments. -->


  <xsl:include href="../process/process-utility.xsl"/>


  <!-- Convert a concept to an ISO19139 keywords.
    If no keyword is provided, only thesaurus section is adaded.
    -->
  <xsl:template name="to-dcat-ap-concept">
    <xsl:param name="withAnchor" select="false()"/>
    <xsl:param name="withXlink" select="false()"/>
    <!-- Add thesaurus identifier using an Anchor which points to the download link.
        It's recommended to use it in order to have the thesaurus widget inline editor
        which use the thesaurus identifier for initialization. -->
    <xsl:param name="withThesaurusAnchor" select="true()"/>


    <!-- The lang parameter contains a list of languages
    with the main one as the first element. If only one element
    is provided, then CharacterString or Anchor are created.
    If more than one language is provided, then PT_FreeText
    with or without CharacterString can be created. -->
    <xsl:variable name="listOfLanguage" select="tokenize(/root/request/lang, ',')"/>
    <xsl:variable name="textgroupOnly"
                  as="xs:boolean"
                  select="if (/root/request/textgroupOnly and normalize-space(/root/request/textgroupOnly) != '')
                          then /root/request/textgroupOnly
                          else false()"/>


    <xsl:apply-templates mode="to-dcat-ap-concept" select=".">
      <xsl:with-param name="withAnchor" select="$withAnchor"/>
      <xsl:with-param name="withXlink" select="$withXlink"/>
      <xsl:with-param name="withThesaurusAnchor" select="$withThesaurusAnchor"/>
      <xsl:with-param name="listOfLanguage" select="$listOfLanguage"/>
      <xsl:with-param name="textgroupOnly" select="$textgroupOnly"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template mode="to-dcat-ap-concept" match="*[not(/root/request/skipdescriptivekeywords)]">
    <xsl:param name="textgroupOnly"/>
    <xsl:param name="listOfLanguage"/>
    <xsl:param name="withAnchor"/>
    <xsl:param name="withXlink"/>
    <xsl:param name="withThesaurusAnchor"/>
    <xsl:variable name="concept">
      <xsl:choose>
        <xsl:when test="$withXlink">
          <xsl:variable name="multiple"
                        select="if (contains(/root/request/id, ',')) then 'true' else 'false'"/>
          <xsl:variable name="isLocalXlink"
                        select="util:getSettingValue('system/xlinkResolver/localXlinkEnable')"/>
          <xsl:variable name="prefixUrl"
                        select="if ($isLocalXlink = 'true')
                                then  concat('local://', /root/gui/language)
                                else $serviceUrl"/>

          <xsl:attribute name="xlink:href"
                         select="concat($prefixUrl, '/xml.keyword.get?thesaurus=', thesaurus/key,
                              '&amp;amp;id=', replace(/root/request/id, '#', '%23'),
                              '&amp;amp;multiple=', $multiple,
                              if (/root/request/lang) then concat('&amp;amp;lang=', /root/request/lang) else '',
                              if ($textgroupOnly) then '&amp;amp;textgroupOnly' else '')"/>
          <xsl:attribute name="xlink:show">replace</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="to-md-concept">
            <xsl:with-param name="withAnchor" select="$withAnchor"/>
            <xsl:with-param name="withThesaurusAnchor" select="$withThesaurusAnchor"/>
            <xsl:with-param name="listOfLanguage" select="$listOfLanguage"/>
            <xsl:with-param name="textgroupOnly" select="$textgroupOnly"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
	</xsl:variable>
	<xsl:variable name="thesaurusKey"
	              select="if (thesaurus/key) then thesaurus/key else /root/request/thesaurus"/>
    <xsl:choose>
    	<xsl:when test="ends-with($thesaurusKey,'data-theme')">
		    <dcat:theme>
		    	<xsl:copy-of select="$concept"/>
		    </dcat:theme>
		</xsl:when>
    	<xsl:when test="ends-with($thesaurusKey,'language')">
		    <dct:language>
		    	<xsl:copy-of select="$concept"/>
		    </dct:language>
		</xsl:when>
    	<xsl:when test="ends-with($thesaurusKey,'organization-type')">
		    <dct:type>
		    	<xsl:copy-of select="$concept"/>
		    </dct:type>
		</xsl:when>
    	<xsl:when test="ends-with($thesaurusKey,'file-type')">
		    <dct:format>
		    	<xsl:copy-of select="$concept"/>
		    </dct:format>
		</xsl:when>
    	<xsl:when test="ends-with($thesaurusKey,'licence')">
		    <dct:license>
		    	<xsl:copy-of select="$concept"/>
		    </dct:license>
		</xsl:when>
		<xsl:otherwise>
			<xsl:message select="concat('No concept added for a field value of thesaurus ', $thesaurusKey, '. Verify thesaurus-transformation.xsl.')"/>
		</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="to-dcat-ap-concept" match="*[/root/request/skipdescriptivekeywords]">
    <xsl:param name="textgroupOnly"/>
    <xsl:param name="listOfLanguage"/>
    <xsl:param name="withAnchor"/>
    <xsl:param name="withThesaurusAnchor"/>

    <xsl:call-template name="to-md-concept">
      <xsl:with-param name="withAnchor" select="$withAnchor"/>
      <xsl:with-param name="withThesaurusAnchor" select="$withThesaurusAnchor"/>
      <xsl:with-param name="listOfLanguage" select="$listOfLanguage"/>
      <xsl:with-param name="textgroupOnly" select="$textgroupOnly"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="to-md-concept">
    <xsl:param name="textgroupOnly"/>
    <xsl:param name="listOfLanguage"/>
    <xsl:param name="withAnchor"/>
    <xsl:param name="withThesaurusAnchor"/>

	<!-- Get thesaurus ID from keyword or from request parameter if no keyword found. -->
	<xsl:variable name="currentThesaurus"
	              select="if (thesaurus/key) then thesaurus/key else /root/request/thesaurus"/>
    <xsl:variable name="resource" select="gn-fn-dcat-ap:getThesaurusResource($currentThesaurus)"/>
	<!-- Loop on all keyword from the same thesaurus -->
	<xsl:for-each select="//keyword[thesaurus/key = $currentThesaurus]">
		<skos:Concept>
			<xsl:attribute name="rdf:about"><xsl:value-of select="uri" /></xsl:attribute>
			<xsl:variable name="keyword" select="." />
			<xsl:for-each select="$listOfLanguage">
				<xsl:variable name="lang" select="." />
				<skos:prefLabel>
					<xsl:attribute name="xml:lang" select="lower-case(util:twoCharLangCode($lang))" />
					<xsl:value-of select="$keyword/values/value[@language = $lang]/text()" />
				</skos:prefLabel>
			</xsl:for-each>
			<skos:inScheme rdf:resource="{$resource}" />
		</skos:Concept>
	</xsl:for-each>
  </xsl:template>
</xsl:stylesheet>

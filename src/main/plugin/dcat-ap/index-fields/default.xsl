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
        Searches can be conducted on indexes defined here. The Field@name attribute
        defines the name of the search variable. If a variable has to be maintained
        in the user session, it needs to be added to the GeoNetwork constants in
        the Java source code. Please keep indexes consistent among metadata standards
        if they should work accross different metadata resources -->
  <!-- ========================================================================================= -->
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              indent="yes" />
  <!-- ========================================================================================= -->

  <!-- The main metadata language -->
  <xsl:variable name="isoLangId">
    <xsl:call-template name="langId-dcat-ap" />
  </xsl:variable>

  <xsl:variable name="langId">
    <xsl:call-template name="langId3to2">
      <xsl:with-param name="langId-3char" select="$isoLangId" />
    </xsl:call-template>
  </xsl:variable>

  <xsl:template match="/">
    <Document locale="{$isoLangId}">
      <xsl:apply-templates select="rdf:RDF/dcat:Catalog/dcat:dataset/dcat:Dataset" />
    </Document>
  </xsl:template>

  <xsl:template match="dcat:Dataset">
    <Field name="_locale" string="{$isoLangId}" store="true" index="true" />
    <Field name="_locale2" string="{$langId}" store="true" index="true" />

    <Field name="_docLocale" string="{$isoLangId}" store="true"
           index="true" />

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


    <xsl:apply-templates select="." mode="dataset" />

    <xsl:apply-templates select="*" mode="index" />
  </xsl:template>

  <xsl:template mode="index" match="*|@*">
    <xsl:apply-templates mode="index" select="*|@*" />
  </xsl:template>

  <xsl:template match="dcat:Dataset" mode="dataset">

    <!-- === Free text search === -->

    <Field name="any" store="false" index="true">
      <xsl:attribute name="string">
        <xsl:value-of select="normalize-space(string(.))"/>
      </xsl:attribute>
    </Field>

    <Field name="anylight" store="false" index="true">
      <xsl:attribute name="string">
        <xsl:for-each select=".//dct:title|
                              .//dct:description|
                              .//dcat:keyword|
                              .//foaf:name">
          <xsl:variable name="value">
            <xsl:call-template name="index-lang-tag-oneval">
              <xsl:with-param name="tag" select="."/>
              <xsl:with-param name="langId" select="$langId"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:if test="$value!=''">
            <xsl:value-of select="concat($value, ' ')"/>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select=".//vcard:organization-name">
          <xsl:value-of select="concat(., ' ')"/>
        </xsl:for-each>
        <xsl:for-each select=".//dct:type[name(..)='foaf:Agent']|
                              .//dcat:theme|
                              .//dct:accrualPeriodicity|
                              .//dct:language|
                              .//dct:type[name(..)='dcat:Dataset']|
                              .//dct:format|
                              .//dcat:mediaType|
                              .//adms:status|
                              .//dct:accessRights|
                              .//dct:type[name(..)='dct:LicenseDocument']">
          <xsl:if test="skos:Concept/skos:prefLabel/@xml:lang=$langId">
            <xsl:variable name="prefLabel">
              <xsl:call-template name="index-lang-tag-oneval">
                <xsl:with-param name="tag" select="."/>
                <xsl:with-param name="langId" select="$langId"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:if test="$prefLabel!=''">
              <xsl:value-of select="concat($prefLabel, ' ')"/>
            </xsl:if>
          </xsl:if>
        </xsl:for-each>
      </xsl:attribute>

    </Field>

    <xsl:for-each select="distinct-values(//dcat:dataset/dcat:Dataset/dct:title/@xml:lang)">
      <xsl:variable name="mdLanguage">
        <xsl:call-template name="langId2to3">
          <xsl:with-param name="langId-2char" select="." />
        </xsl:call-template>
      </xsl:variable>
      <xsl:if test="not($mdLanguage='')">
        <Field name="language" string="{string($mdLanguage)}" store="true" index="true"/>
        <Field name="mdLanguage" string="{string($mdLanguage)}" store="true" index="true"/>
      </xsl:if>
    </xsl:for-each>

    <Field name="type" string="dataset" store="true" index="true" />

    <!-- This is needed by the CITE test script to look for strings like 'a
            b*' strings that contain spaces -->
    <xsl:variable name="tmp_title">
      <xsl:call-template name="index-lang-tag-oneval">
        <xsl:with-param name="tag" select="dct:title"/>
        <xsl:with-param name="langId" select="$langId"/>
        <xsl:with-param name="isoLangId" select="$isoLangId"/>
      </xsl:call-template>
    </xsl:variable>
    <Field name="title" string="{string($tmp_title)}" store="true" index="true" />
    <!-- not tokenized title for sorting -->
    <Field name="_title" string="{string($tmp_title)}" store="false" index="true" />

    <xsl:variable name="tmp_abstract">
      <xsl:call-template name="index-lang-tag-oneval">
        <xsl:with-param name="tag" select="dct:description"/>
        <xsl:with-param name="langId" select="$langId"/>
        <xsl:with-param name="isoLangId" select="$isoLangId"/>
      </xsl:call-template>
    </xsl:variable>
    <Field name="abstract" string="{string($tmp_abstract)}" store="true" index="true" />
    <Field name="_abstract" string="{string($tmp_abstract)}" store="false" index="true" />

    <xsl:for-each select="dct:identifier">
      <Field name="identifier" string="{string(.)}" store="true"
             index="true" />
      <Field name="fileId" string="{string(.)}" store="false" index="true" />
    </xsl:for-each>

    <xsl:for-each select="dct:issued">
      <Field name="createDate" string="{string(.)}" store="true"
             index="true" />
      <Field name="createDateYear" string="{substring(string(.), 0, 5)}"
             store="true" index="true" />
    </xsl:for-each>

    <xsl:for-each select="dct:modified">
      <Field name="changeDate" string="{string(.)}" store="true"
             index="true" />
      <Field name="sortDate" string="{string(.)}" store="true" index="true"/>
      <Field name="_sortDate" string="{string(.)}" store="true" index="true"/>
      <!--<Field name="createDateYear" string="{substring(., 0, 5)}" store="true"
                index="true"/> -->
    </xsl:for-each>

    <xsl:for-each select="distinct-values(dct:language/skos:Concept/@rdf:about)">
      <xsl:variable name="datasetLanguage">
        <xsl:call-template name="interpretLanguage">
          <xsl:with-param name="input" select="."/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:if test="not($datasetLanguage='')">
        <Field name="datasetLang" string="{$datasetLanguage}" store="true" index="true" />
      </xsl:if>
    </xsl:for-each>

    <xsl:for-each select="dct:type">
      <Field name="type" string="{string(.)}" store="true" index="true" />
    </xsl:for-each>
    <xsl:for-each select="dct:source">
      <Field name="lineage" string="{string(.)}" store="true" index="true" />
    </xsl:for-each>
    <xsl:for-each select="dct:relation">
      <Field name="relation" string="{string(.)}" store="false"
             index="true" />
    </xsl:for-each>

    <xsl:for-each select="dct:conformsTo/dct:Standard">
      <xsl:variable name="title">
        <xsl:call-template name="index-lang-tag-oneval">
          <xsl:with-param name="tag" select="dct:title"/>
          <xsl:with-param name="langId" select="$langId"/>
          <xsl:with-param name="isoLangId" select="$isoLangId"/>
        </xsl:call-template>
      </xsl:variable>
      <Field name="standardName" string="{string($title)}"
             store="true" index="true" />
    </xsl:for-each>

    <xsl:for-each select="dcat:landingPage/@rdf:resource">
      <Field name="groupWebsite" string="{string(.)}"
             store="true" index="true" />
    </xsl:for-each>


    <xsl:for-each select="dct:rights">
      <Field name="MD_LegalConstraintsUseLimitation" string="{string(.)}"
             store="true" index="true" />
    </xsl:for-each>
    <xsl:for-each select="dct:spatial">
      <xsl:if test="count(dct:Location/locn:geometry) &gt; 0">
        <xsl:apply-templates
          select="dct:Location"
          mode="latLon" />
        <xsl:call-template name="index-lang-tag">
          <xsl:with-param name="tag" select="dct:Location/skos:prefLabel"/>
          <xsl:with-param name="field" select="'extentDesc'"/>
          <xsl:with-param name="langId" select="$langId"/>
        </xsl:call-template>
      </xsl:if>
      <Field name="geoDescCode" string="{string(dct:Location/@rdf:about)}" store="true" index="true"/>
    </xsl:for-each>


    <xsl:variable name="startDate" select="dct:temporal/dct:PeriodOfTime/schema:startDate"/>
    <xsl:variable name="endDate" select="dct:temporal/dct:PeriodOfTime/schema:endDate"/>
    <xsl:if test="$startDate">
      <Field name="tempExtentBegin"
             string="{string($startDate[1])}"
             store="true" index="true"/>
    </xsl:if>
    <xsl:if test="$endDate">
      <Field name="tempExtentEnd"
             string="{string($endDate[last()])}"
             store="true" index="true"/>
    </xsl:if>

    <xsl:call-template name="index-lang-tag">
      <xsl:with-param name="tag" select="dct:accessRights"/>
      <xsl:with-param name="field" select="'MD_ConstraintsUseLimitation'"/>
      <xsl:with-param name="langId" select="$langId"/>
    </xsl:call-template>

    <xsl:for-each select="dcat:keyword">
      <Field name="keyword" string="{.}" store="true" index="true" />
    </xsl:for-each>
    <xsl:variable name="listOfKeywords">{
      <xsl:variable name="keywordWithNoThesaurus"
                    select="dcat:keyword[@xml:lang=$langId]"/>
      <xsl:variable name="themes"
                    select="dcat:theme/skos:Concept"/>
      <xsl:if test="count($keywordWithNoThesaurus) > 0">
        'keywords': [
        <xsl:for-each select="$keywordWithNoThesaurus">
          {'value': <xsl:value-of select="concat('''', replace(., '''', '\\'''), '''')"/>,
          'link': ''}
          <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
        ]
        <xsl:if test="count($themes) > 0">,</xsl:if>
      </xsl:if>
      <xsl:if test="count($themes) > 0">
        'theme': [
        <xsl:for-each select="$themes">
          {'value': <xsl:value-of select="concat('''', replace(skos:prefLabel[@xml:lang=$langId], '''', '\\'''), '''')"/>,
          'link': ''}
          <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
        ]
      </xsl:if>
      }
    </xsl:variable>

    <Field name="keywordGroup"
           string="{normalize-space($listOfKeywords)}"
           store="true"
           index="false"/>

    <xsl:for-each select="dcat:distribution/dcat:Distribution">
      <xsl:variable name="tPosition" select="position()" />

      <xsl:variable name="title">
        <xsl:call-template name="index-lang-tag-oneval">
          <xsl:with-param name="tag" select="dct:title"/>
          <xsl:with-param name="langId" select="$langId"/>
          <xsl:with-param name="isoLangId" select="$isoLangId"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="desc">
        <xsl:call-template name="index-lang-tag-oneval">
          <xsl:with-param name="tag" select="dct:description"/>
          <xsl:with-param name="langId" select="$langId"/>
          <xsl:with-param name="isoLangId" select="$isoLangId"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="format">
        <xsl:call-template name="index-lang-tag-oneval">
          <xsl:with-param name="tag" select="dct:format"/>
          <xsl:with-param name="langId" select="$langId"/>
          <xsl:with-param name="isoLangId" select="$isoLangId"/>
        </xsl:call-template>
      </xsl:variable>
      <Field name="format" string="{string($format)}" store="true" index="true"/>

      <xsl:for-each select="dcat:downloadURL">
        <xsl:variable name="downloadURLlinkage" select="string(@rdf:resource)" />

        <Field name="link"
               string="{concat($title, '|', $desc, '|', $downloadURLlinkage,'|WWW:DOWNLOAD-1.0-http--download|WWW:DOWNLOAD-1.0-http--download|', $tPosition, '1', position())}"
               store="true" index="true"/>
      </xsl:for-each>

      <xsl:for-each select="dcat:accessURL">
        <xsl:variable name="accessURLlinkage" select="string(@rdf:resource)" />

        <Field name="link"
               string="{concat($title, '|', $desc, '|', $accessURLlinkage,'|WWW:DOWNLOAD-1.0-http--download|WWW:DOWNLOAD-1.0-http--download|', $tPosition, '2', position())}"
               store="true" index="true"/>
      </xsl:for-each>

      <xsl:for-each select="dct:license/dct:LicenseDocument">
        <xsl:variable name="tag">
          <xsl:choose>
            <xsl:when test="dct:title and dct:title!=''">
              <xsl:value-of select="dct:title"/>
            </xsl:when>
            <xsl:when test="@rdf:about and @rdf:about!=''">
              <xsl:value-of select="@rdf:about"/>
            </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="tmp_license">
          <xsl:call-template name="index-lang-tag-oneval">
            <xsl:with-param name="tag" select="$tag"/>
            <xsl:with-param name="langId" select="$langId"/>
            <xsl:with-param name="isoLangId" select="$isoLangId"/>
          </xsl:call-template>
        </xsl:variable>
        <Field name="MD_LegalConstraintsUseLimitation" string="{string($tmp_license)}" store="true" index="true"/>
      </xsl:for-each>

    </xsl:for-each>

    <xsl:for-each select="dcat:contactPoint">
      <xsl:apply-templates mode="index-contact" select="vcard:Organization">
        <xsl:with-param name="type" select="'resource'" />
        <xsl:with-param name="fieldPrefix" select="'responsibleParty'" />
        <xsl:with-param name="position" select="position()" />
      </xsl:apply-templates>
    </xsl:for-each>

    <xsl:for-each select="dct:isPartOf">
      <Field name="parentUuid" string="{string(.)}" store="true" index="true" />
    </xsl:for-each>
    <xsl:for-each select="(dcat:landingPage)[normalize-space(.) != '']">
      <xsl:variable name="name" select="tokenize(., '/')[last()]" />
      <xsl:variable name="tPosition" select="position()" />
      <!-- Index link where last token after the last / is the link name. -->
      <Field name="link"
             string="{concat($name, '|description|', @rdf:resource, '|WWW:DOWNLOAD|WWW-DOWNLOAD|',$tPosition)}"
             store="true" index="false" />
    </xsl:for-each>
    <xsl:for-each
      select="(dcat:landingPage)[normalize-space(.) != ''
                              and matches(., '.*(.gif|.png.|.jpeg|.jpg)$', 'i')]">
      <xsl:variable name="thumbnailType"
                    select="if (position() = 1) then 'thumbnail' else 'overview'"/>
      <!-- First thumbnail is flagged as thumbnail and could be considered the
                main one -->
      <Field name="image" string="{concat($thumbnailType, '|', ., '|')}"
             store="true" index="false" />
    </xsl:for-each>

    <xsl:for-each select="dct:publisher/foaf:Agent">
      <xsl:variable name="tmp_dcat_publisher">
        <xsl:call-template name="index-lang-tag-oneval">
          <xsl:with-param name="tag" select="foaf:name"/>
          <xsl:with-param name="langId" select="$langId"/>
          <xsl:with-param name="isoLangId" select="$isoLangId"/>
        </xsl:call-template>
      </xsl:variable>
      <Field name="orgName" string="{string($tmp_dcat_publisher)}" store="true" index="true" />
    </xsl:for-each>
    <!--    <xsl:for-each select="dct:accrualPeriodicity">
          <Field name="updateFrequency" string="{string(.)}" store="true"
                 index="true" />
        </xsl:for-each>-->
  </xsl:template>
  <xsl:template mode="index-contact" match="vcard:Organization">
    <xsl:param name="type" />
    <xsl:param name="fieldPrefix" />
    <xsl:param name="position" select="'0'" />
    <xsl:variable name="orgName" select="vcard:organization-name" />
    <Field name="orgName" string="{string($orgName)}" store="true"
           index="true" />
    <Field name="orgNameTree" string="{string($orgName)}" store="true"
           index="true" />
    <xsl:variable name="role" select="'Contact'" />
    <!--<xsl:variable name="roleTranslation" select="util:getCodelistTranslation('gmd:CI_RoleCode',
            string($role), string($isoLangId))"/> -->
    <xsl:variable name="email" select="vcard:hasEmail/@rdf:resource" />
    <xsl:variable name="url" select="vcard:hasURL/@rdf:resource" />
    <xsl:variable name="phone"
                  select="vcard:hasTelephone/text()" />
    <xsl:variable name="individualName" select="vcard:fn/text()" />
    <xsl:variable name="address"
                  select="string-join(vcard:hasAddress/vcard:Address/(
                                        vcard:street-address|vcard:postal-code|vcard:locality|
                                        vcard:locality|vcard:country-name)/text(), ', ')" />
    <Field name="{$fieldPrefix}"
           string="{concat('contact', '|', $type,'|',
                             $orgName, '|',
							 '', '|',
                             string-join($email, ','), '|',
                             $individualName, '|',
                             'contactpersoon', '|',
                             $address, '|',
                             string-join($phone, ','), '|',
                             'uuid', '|',
                             $position, '|', $url)}"
           store="true" index="false" />
    <xsl:for-each select="$email">
      <Field name="{$fieldPrefix}Email" string="{string(.)}" store="true"
             index="true" />
      <!-- <Field name="{$fieldPrefix}RoleAndEmail" string="{$role}|{string(.)}"
                store="true" index="true"/> -->
    </xsl:for-each>
  </xsl:template>
  <!-- {java:getCodelistTranslation('dcat:MD_MaintenanceFrequencyCode', string(.),
        string($isoLangId))} -->
  <!-- ========================================================================================= -->

</xsl:stylesheet>

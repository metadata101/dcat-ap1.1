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
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dct="http://purl.org/dc/terms/"
                xmlns:dcat="http://www.w3.org/ns/dcat#"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:vcard="http://www.w3.org/2006/vcard/ns#"
                xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"
                xmlns:gn-fn-render="http://geonetwork-opensource.org/xsl/functions/render"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                exclude-result-prefixes="#all">

  <!--  TODO: remove this comment
  @Gustaaf: de klasse SchemaLocations is blijkbaar verplaatst naar een nieuwe package.
  Er stond vroeger:
  xmlns:tr="java:org.fao.geonet.services.metadata.format.SchemaLocalizations"
  Nu is het:
  xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"  -->

  <!-- Load the editor configuration to be able
  to render the different views -->
  <xsl:variable name="configuration"
                select="document('../../layout/config-editor.xml')"/>

  <!-- Some utility -->
  <xsl:include href="../../layout/evaluate.xsl"/>

  <!-- The core formatter XSL layout based on the editor configuration -->
  <xsl:include href="sharedFormatterDir/xslt/render-layout.xsl"/>
  <!--<xsl:include href="../../../../../data/formatter/xslt/render-layout.xsl"/>-->

  <!-- Define the metadata to be loaded for this schema plugin-->
  <xsl:variable name="metadata"
                select="/root/rdf:RDF"/>
  <xsl:variable name="langId"
                select="'nl'" />



  <!-- Specific schema rendering -->
  <xsl:template mode="getMetadataTitle" match="rdf:RDF">
    <xsl:value-of select="//dcat:Dataset/dct:title"/>
  </xsl:template>

  <xsl:template mode="getMetadataAbstract"  match="rdf:RDF">
    <xsl:value-of select="//dcat:Dataset/dct:description"/>
  </xsl:template>

  <xsl:template mode="getMetadataHeader" match="dcat:Dataset">
  </xsl:template>


  <!-- Most of the elements are ... -->
  <xsl:template mode="render-field" match="*">
    <xsl:param name="fieldName" select="''" as="xs:string"/>

    <dl>
      <dt>
        <xsl:value-of select="if ($fieldName)
                                then $fieldName
                                else tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <xsl:value-of>tout:</xsl:value-of>
        <xsl:apply-templates mode="render-value" select="."/>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template mode="render-view"
                match="field[template]"
                priority="3">
    <xsl:param name="base" select="$metadata"/>

    <xsl:variable name="fieldXpath"
                  select="@xpath"/>
    <xsl:variable name="fields" select="template/values/key"/>


    <xsl:variable name="elements">
      <xsl:call-template name="evaluate-dcat-ap">
        <xsl:with-param name="base" select="$base"/>
        <xsl:with-param name="in"
                        select="concat('/../', $fieldXpath)"/>
      </xsl:call-template>
    </xsl:variable>


    <xsl:for-each select="$elements/*">
      <xsl:variable name="element" select="."/>

      <xsl:apply-templates mode="render-field" select="$element"/>

    </xsl:for-each>
  </xsl:template>

  <xsl:template mode="render-field" match="dcat:distribution">
    <xsl:param name="fieldName" select="''" as="xs:string"/>
    <xsl:for-each select="dcat:Distribution">
      <h2>
        <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'FieldId234')"/>
      </h2>

      <xsl:variable name="title">
        <xsl:apply-templates mode="render-value" select="dct:title" />
      </xsl:variable>
      <xsl:variable name="desc">
        <xsl:apply-templates mode="render-value" select="dct:description" />
      </xsl:variable>
      <xsl:variable name="mediaTypeConceptLabel">
        <xsl:apply-templates mode="render-value" select="dcat:mediaType" />
      </xsl:variable>

      <xsl:variable name="downloadURLs">
        <xsl:for-each select="dcat:downloadURL/@rdf:resource">
          <xsl:apply-templates mode="render-value" select="."/><xsl:if test="position() != last()">, </xsl:if>
        </xsl:for-each>
      </xsl:variable>

      <xsl:variable name="accessURLs">
        <xsl:for-each select="dcat:accessURL/@rdf:resource">
          <xsl:apply-templates mode="render-value" select="."/><xsl:if test="position() != last()">, </xsl:if>
        </xsl:for-each>
      </xsl:variable>

      <xsl:if test="$title">
        <dl><dt>
          <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'FieldId237')"/>
        </dt><dd>
          <xsl:value-of select="$title" />
        </dd></dl>
      </xsl:if>
      <xsl:if test="$desc">
        <dl><dt>
          <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'FieldId239')"/>
        </dt><dd>
          <xsl:value-of select="$desc" />
        </dd></dl>
      </xsl:if>
      <xsl:if test="$mediaTypeConceptLabel">
        <dl><dt>
          <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'FieldId335')"/>
        </dt><dd>
          <xsl:value-of select="$mediaTypeConceptLabel" />
        </dd></dl>
      </xsl:if>
      <xsl:if test="$downloadURLs">
        <dl><dt>
          <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'FieldId242')"/>
        </dt><dd>
          <xsl:value-of select="$downloadURLs" />
        </dd></dl>
      </xsl:if>
      <xsl:if test="$accessURLs">
        <dl><dt>
          <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'FieldId241')"/>
        </dt><dd>
          <xsl:value-of select="$accessURLs" />
        </dd></dl>
      </xsl:if>

      <!--      <xsl:for-each select="dct:format/skos:Concept/skos:prefLabel[@xml:lang=$langId]">
              <Field name="format" string="{.}" store="true" index="true"/>
            </xsl:for-each>

            <xsl:for-each
              select="dct:license/skos:Concept/skos:prefLabel[@xml:lang=$langId]">
              <Field name="MD_LegalConstraintsUseLimitation" string="{string(.)}"
                     store="true" index="true" />
            </xsl:for-each>

            <Field name="dcat_distributionTitle" string="{string($title)}"
                   store="true" index="true" />
            <Field name="dcat_distributionDesc" string="{string($desc)}"
                   store="true" index="true" />
            <Field name="dcat_distributionMediaTypeConceptLabel" string="{string($mediaTypeConceptLabel)}"
                   store="true" index="true" />

            <Field name="dcat_distribution"
                   string="{concat($tPosition, '|', $title, '|', $desc, '|', $mediaTypeConceptLabel)}"
                   store="true" index="false"/>-->
    </xsl:for-each>
  </xsl:template>

  <xsl:template mode="render-field" match="dcat:contactPoint">
    <xsl:variable name="email">
      <xsl:for-each select="vcard:Organization/vcard:hasEmail">
        <xsl:apply-templates mode="render-value"
                             select="."/><xsl:if test="position() != last()">, </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="displayName">
      <xsl:apply-templates mode="render-value"
                           select="vcard:Organization/vcard:organization-name"/>
    </xsl:variable>

    <div class="gn-contact">
      <div class="row">
        <div class="col-md-6">
          <address itemprop="author"
                   itemscope="itemscope"
                   itemtype="http://schema.org/Organization">
            <strong>
              <xsl:choose>
                <xsl:when test="$email">
                  <a href="mailto:{normalize-space($email)}">
                    <xsl:value-of select="$displayName"/>&#160;
                  </a>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$displayName"/>
                </xsl:otherwise>
              </xsl:choose>
            </strong>
            <br/>
            <xsl:for-each select="vcard:Organization">
              <xsl:for-each select="vcard:hasAddress/vcard:Address">
                <div itemprop="address"
                     itemscope="itemscope"
                     itemtype="http://schema.org/PostalAddress">
                  <xsl:for-each select="vcard:street-address">
                    <span itemprop="streetAddress">
                      <xsl:apply-templates mode="render-value" select="."/>
                    </span>
                  </xsl:for-each>
                  <xsl:for-each select="vcard:locality">
                    <span itemprop="addressLocality">
                      <xsl:apply-templates mode="render-value" select="."/>
                    </span>
                  </xsl:for-each>
                  <xsl:for-each select="vcard:postal-code">
                    <span itemprop="postalCode">
                      <xsl:apply-templates mode="render-value" select="."/>
                    </span>
                  </xsl:for-each>
                  <xsl:for-each select="vcard:country-name">
                    <span itemprop="addressCountry">
                      <xsl:apply-templates mode="render-value" select="."/>
                    </span>
                  </xsl:for-each>
                </div>
                <br/>
              </xsl:for-each>
            </xsl:for-each>
          </address>
        </div>
        <div class="col-md-6">
          <address>
            <xsl:for-each select="vcard:Organization">
              <xsl:for-each select="vcard:hasTelephone[normalize-space(.) != '']">
                <div itemprop="contactPoint"
                     itemscope="itemscope"
                     itemtype="http://schema.org/ContactPoint">

                  <xsl:variable name="phoneNumber">
                    <xsl:apply-templates mode="render-value" select="."/>
                  </xsl:variable>
                  <i class="fa fa-phone">&#160;</i>
                  <a href="tel:{$phoneNumber}">
                    <xsl:value-of select="$phoneNumber"/>&#160;
                  </a>
                </div>
              </xsl:for-each>
            </xsl:for-each>
          </address>
        </div>
      </div>
    </div>
  </xsl:template>


  <!-- Bbox is displayed with an overview and the geom displayed on it
  and the coordinates displayed around -->
  <xsl:template mode="render-field"
                match="dct:spatial">
    <xsl:value-of>No spatial</xsl:value-of>
    <!--<xsl:variable name="coverage" select="."/>

    <xsl:variable name="n" select="substring-after($coverage,'North ')"/>
    <xsl:variable name="north" select="substring-before($n,',')"/>
    <xsl:variable name="s" select="substring-after($coverage,'South ')"/>
    <xsl:variable name="south" select="substring-before($s,',')"/>
    <xsl:variable name="e" select="substring-after($coverage,'East ')"/>
    <xsl:variable name="east" select="substring-before($e,',')"/>
    <xsl:variable name="w" select="substring-after($coverage,'West ')"/>
    <xsl:variable name="west" select="if (contains($w, '. '))
                                      then substring-before($w,'. ') else $w"/>
    <xsl:variable name="place" select="substring-after($coverage,'. ')"/>

    <dl>
      <dt>
        <xsl:value-of select="if ($place != '') then $place else ''"/>
      </dt>
      <dd>
        <xsl:copy-of select="gn-fn-render:bbox(
                                xs:double($west),
                                xs:double($south),
                                xs:double($east),
                                xs:double($north))"/>
      </dd>
    </dl>-->
  </xsl:template>

  <!-- Traverse the tree -->
  <xsl:template mode="render-field" match="dcat:Dataset">
    <xsl:apply-templates mode="render-field"/>
  </xsl:template>







  <!-- ########################## -->
  <!-- Render values for text ... -->
  <xsl:template mode="render-value" match="*">
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- ... URL -->
  <xsl:template mode="render-value" match="*[starts-with(., 'http')]">
    <a href="{.}"><xsl:value-of select="."/></a>
  </xsl:template>

  <!-- ... Dates -->
  <xsl:template mode="render-value" match="*[matches(., '[0-9]{4}-[0-9]{2}-[0-9]{2}')]">
    <span data-gn-humanize-time="{.}" data-format="DD MMM YYYY">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <xsl:template mode="render-value" match="*[matches(., '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}')]">
    <span data-gn-humanize-time="{.}">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

</xsl:stylesheet>

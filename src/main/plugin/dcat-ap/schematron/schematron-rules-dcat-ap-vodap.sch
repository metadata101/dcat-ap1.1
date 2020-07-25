<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
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
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!--

Schematron validation for DCAT-AP-VL - Flemish Government.

This script was written by GIM.

Source:
- DCAT-AP v1.1: https://joinup.ec.europa.eu/release/dcat-ap-v11
- Vlaamse Open Data Handleiding: https://overheid.vlaanderen.be/open-data-handleiding (bijlage 3)

-->
	<sch:title xmlns="http://www.w3.org/2001/XMLSchema">{$loc/strings/schematron.title}</sch:title>
	<sch:ns prefix="spdx" uri="http://spdx.org/rdf/terms#"/>
	<sch:ns prefix="owl" uri="http://www.w3.org/2002/07/owl#"/>
	<sch:ns prefix="adms" uri="http://www.w3.org/ns/adms#"/>
	<sch:ns prefix="locn" uri="http://www.w3.org/ns/locn#"/>
	<sch:ns prefix="xsi" uri="http://www.w3.org/2001/XMLSchema-instance"/>
	<sch:ns prefix="foaf" uri="http://xmlns.com/foaf/0.1/"/>
	<sch:ns prefix="dct" uri="http://purl.org/dc/terms/"/>
	<sch:ns prefix="vcard" uri="http://www.w3.org/2006/vcard/ns#"/>
	<sch:ns prefix="dcat" uri="http://www.w3.org/ns/dcat#"/>
	<sch:ns prefix="schema" uri="http://schema.org/"/>
	<sch:ns prefix="rdf" uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#"/>
	<sch:ns prefix="skos" uri="http://www.w3.org/2004/02/skos/core#"/>
	<sch:ns prefix="xml" uri="http://www.w3.org/XML/1998/namespace"/>
	<sch:ns prefix="gco" uri="undefined"/>
	<sch:ns prefix="dc" uri="http://purl.org/dc/elements/1.1/"/>
	<sch:ns prefix="geonet" uri="http://www.fao.org/geonetwork"/>
	<sch:ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>
	<sch:pattern>
		<sch:title>41. dcat:contactPoint is a required property for Dataset.</sch:title>
		<sch:rule context="//dcat:Dataset">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="noContactPoint" value="not(dcat:contactPoint)"/>
			<sch:assert test="$noContactPoint = false()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" does not have a dcat:contactPoint.
			</sch:assert>
			<sch:report test="$noContactPoint = false()">The dcat:Dataset "<sch:value-of select="$id"/>" has a dcat:contactPoint "<sch:value-of select="dcat:contactPoint/*/@rdf:about/string()"/>".
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>44. dcat:distribution is a required property for Dataset.</sch:title>
		<sch:rule context="//dcat:Dataset">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="missingProperty" value="not(dcat:distribution )"/>
			<sch:assert test="$missingProperty = false()">WARNING: The dcat:Dataset "<sch:value-of select="$id"/>" does not have a dcat:distribution.
			</sch:assert>
			<sch:report test="$missingProperty = false()">The dcat:Dataset "<sch:value-of select="$id"/>" has a dcat:distribution with id  "<sch:value-of select="dcat:distribution/*/@rdf:about/string()"/>".			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>49. dct:publisher is a required property for Dataset.</sch:title>
		<sch:rule context="//dcat:Dataset">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="noPublisher" value="not(dct:publisher)"/>
			<sch:assert test="$noPublisher = false()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" does not have a dct:publisher.
			</sch:assert>
			<sch:assert test="$noPublisher = false()">The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:publisher.
			</sch:assert>
		</sch:rule>
	</sch:pattern>
  <sch:pattern>
    <sch:title>49. dct:publisher has maximum cardinality of 1 for Dataset.</sch:title>
    <sch:rule context="//dcat:Dataset">
      <sch:let name="id" value="@rdf:about/string()"/>
      <sch:let name="count" value="count(dct:publisher)"/>
      <sch:assert test="2 > $count">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has more than one dct:publisher property.
      </sch:assert>
      <sch:report test="2 > $count">The dcat:Dataset "<sch:value-of select="$id"/>" has no more than one dct:publisher property.
      </sch:report>
    </sch:rule>
  </sch:pattern>
	<sch:pattern>
		<sch:title>86. dct:license is a required property for Distribution.</sch:title>
		<sch:rule context="//dcat:Distribution">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="noLicense" value="not(dct:license)"/>
			<sch:assert test="$noLicense = false()">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" does not have a dct:license.
			</sch:assert>
			<sch:report test="$noLicense = false()">The dcat:Distribution "<sch:value-of select="$id"/>" has a dct:license.
			</sch:report>
		</sch:rule>
	</sch:pattern>
  <sch:pattern>
    <sch:title>86. dct:license has maximum cardinality of 1 for Distribution.</sch:title>
    <sch:rule context="//dcat:Distribution">
      <sch:let name="id" value="@rdf:about/string()"/>
      <sch:let name="countLicense" value="count(dct:license)"/>
      <sch:assert test="2 > $countLicense">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" has more than one dct:license property.
      </sch:assert>
      <sch:report test="2 > $countLicense">The dcat:Distribution "<sch:value-of select="$id"/>" has no more than one dct:license property.
      </sch:report>
    </sch:rule>
  </sch:pattern>
	<sch:pattern>
		<sch:title>166. dct:LicenseDocument does not exist.</sch:title>
		<sch:rule context="/">
			<sch:let name="noCatalog" value="not(//dct:LicenseDocument)"/>
			<sch:assert test="$noCatalog = false()">ERROR: The mandatory class dct:LicenseDocument does not exist.
			</sch:assert>
			<sch:report test="$noCatalog = false()">The mandatory class dct:LicenseDocument exists.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>200. Mandatory dct:title for a dcat:Distribution</sch:title>
		<sch:rule context="//dcat:Distribution">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="noTitle" value="not(dct:title)"/>
			<sch:assert test="$noTitle = false()">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" does not have a dct:title property.
			</sch:assert>
			<sch:report test="$noTitle = false()">The dcat:Distribution "<sch:value-of select="$id"/>" has a dct:title property with value  "<sch:value-of select="dct:title"/>".
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>201. dct:license is a required property for Catalog</sch:title>
		<sch:rule context="//dcat:Catalog">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="noTitle" value="not(dct:license)"/>
			<sch:assert test="$noTitle = false()">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" does not have a dct:license property.
			</sch:assert>
			<sch:report test="$noTitle = false()">The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:license property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>202. dct:license is CC0</sch:title>
		<sch:rule context="//dcat:Catalog/dct:license">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="cc0" value="./@rdf:resource = 'https://data.vlaanderen.be/id/licentie/creative-commons-zero-verklaring/v1.0' or ./dct:LicenseDocument/@rdf:about = 'https://data.vlaanderen.be/id/licentie/creative-commons-zero-verklaring/v1.0'"/>
			<sch:assert test="$cc0 = true()">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" does not have a dct:license property with value 'https://data.vlaanderen.be/id/licentie/creative-commons-zero-verklaring/v1.0'.
			</sch:assert>
			<sch:report test="$cc0 = true()">The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:license property with value 'https://data.vlaanderen.be/id/licentie/creative-commons-zero-verklaring/v1.0'.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>203. dct:accessRights must be _:public</sch:title>
		<sch:rule context="//dcat:Dataset/dct:accessRights">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="public" value="*/@rdf:about = 'http://publications.europa.eu/resource/authority/access-right/PUBLIC' or ./@rdf:resource = 'http://publications.europa.eu/resource/authority/access-right/PUBLIC'"/>
			<sch:assert test="$public = true()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" does not have a dct:accessRights property with value 'http://publications.europa.eu/resource/authority/access-right/PUBLIC'.
			</sch:assert>
			<sch:report test="$public = true()">The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:accessRights property with value 'http://publications.europa.eu/resource/authority/access-right/PUBLIC'.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>204. dct:accessRights is required</sch:title>
		<sch:rule context="//dcat:Dataset">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="noTitle" value="not(dct:accessRights)"/>
			<sch:assert test="$noTitle = false()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" does not have a dct:accessRights property.
			</sch:assert>
			<sch:report test="$noTitle = false()">The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:accessRights property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>205. dct:title should have a language tag for dcat:Distribution</sch:title>
		<sch:rule context="//dcat:Distribution/dct:title">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="noTag" value="not(./@xml:lang)"/>
			<sch:assert test="$noTag = false()">ERROR: The dcat:Distribution '<sch:value-of select="$id"/>' does not have a language tag for its dct:title '<sch:value-of select="./string()"/>'.
			</sch:assert>
			<sch:report test="$noTag = false()">The dcat:Distribution '<sch:value-of select="$id"/>' has  a language tag for its dct:title '<sch:value-of select="./string()"/>'.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>206. dct:title should have a language tag for dcat:Dataset</sch:title>
		<sch:rule context="//dcat:Dataset/dct:title">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="noTag" value="not(./@xml:lang)"/>
			<sch:assert test="$noTag = false()">ERROR: The dcat:Dataset '<sch:value-of select="$id"/>' does not have a language tag for its dct:title '<sch:value-of select="./string()"/>'.
			</sch:assert>
			<sch:report test="$noTag = false()">The dcat:Dataset '<sch:value-of select="$id"/>' has  a language tag for its dct:title '<sch:value-of select="./string()"/>'.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>207. dct:description should have a language tag for dcat:Dataset</sch:title>
		<sch:rule context="//dcat:Dataset/dct:description">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="noTag" value="not(./@xml:lang)"/>
			<sch:assert test="$noTag = false()">ERROR: The dcat:Dataset '<sch:value-of select="$id"/>' does not have a language tag for its dct:description '<sch:value-of select="./string()"/>'.
			</sch:assert>
			<sch:report test="$noTag = false()">The dcat:Dataset '<sch:value-of select="$id"/>' has  a language tag for its dct:description '<sch:value-of select="./string()"/>'.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>208. dct:description should have a language tag for dcat:Catalog</sch:title>
		<sch:rule context="//dcat:Catalog/dct:description">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="noTag" value="not(./@xml:lang)"/>
			<sch:assert test="$noTag = false()">ERROR: The dcat:Catalog '<sch:value-of select="$id"/>' does not have a language tag for its dct:description '<sch:value-of select="./string()"/>'.
			</sch:assert>
			<sch:report test="$noTag = false()">The dcat:Catalog '<sch:value-of select="$id"/>' has  a language tag for its dct:description '<sch:value-of select="./string()"/>'.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>209. dct:title should have a language tag for dcat:Catalog</sch:title>
		<sch:rule context="//dcat:Catalog/dct:title">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="noTag" value="not(./@xml:lang)"/>
			<sch:assert test="$noTag = false()">ERROR: The dcat:Catalog '<sch:value-of select="$id"/>' does not have a language tag for its dct:title '<sch:value-of select="./string()"/>'.
			</sch:assert>
			<sch:report test="$noTag = false()">The dcat:Catalog '<sch:value-of select="$id"/>' has  a language tag for its dct:title '<sch:value-of select="./string()"/>'.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>210. dct:title should have a single value per language tag for dcat:Catalog</sch:title>
		<sch:rule context="//dcat:Catalog/dct:title">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="lang" value="@xml:lang/string()"/>
			<sch:let name="count" value="count(parent::node()/dct:title[@xml:lang = $lang])"/>
			<sch:assert test="2 > $count">ERROR: The dcat:Catalog '<sch:value-of select="$id"/>' has more than one (<sch:value-of select="$count"/>) dct:title properties with language tag '<sch:value-of select="$lang"/>'.
			</sch:assert>
			<sch:report test="2 > $count">The dcat:Catalog '<sch:value-of select="$id"/>' less than one (<sch:value-of select="$count"/>) dct:title properties with language tag '<sch:value-of select="$lang"/>'.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>211. foaf:name should have a language tag for foaf:Agent</sch:title>
		<sch:rule context="//foaf:Agent/foaf:name">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="noTag" value="not(./@xml:lang)"/>
			<sch:assert test="$noTag = false()">ERROR: The foaf:Agent '<sch:value-of select="$id"/>' does not have a language tag for its foaf:name '<sch:value-of select="./string()"/>'.
			</sch:assert>
			<sch:report test="$noTag = false()">The foaf:Agent '<sch:value-of select="$id"/>' has  a language tag for its foaf:name '<sch:value-of select="./string()"/>'.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>212. foaf:name should have a single value per language tag for foaf:Agent</sch:title>
		<sch:rule context="//foaf:Agent/foaf:name">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="lang" value="@xml:lang/string()"/>
			<sch:let name="count" value="count(parent::node()/foaf:name[@xml:lang = $lang])"/>
			<sch:assert test="2 > $count">ERROR: The foaf:Agent '<sch:value-of select="$id"/>' has more than one (<sch:value-of select="$count"/>) foaf:name properties with language tag '<sch:value-of select="$lang"/>'.
			</sch:assert>
			<sch:report test="2 > $count">The foaf:Agent '<sch:value-of select="$id"/>' less than one (<sch:value-of select="$count"/>) foaf:name properties with language tag '<sch:value-of select="$lang"/>'.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>213. dct:description should have a single value per language tag for dcat:Catalog</sch:title>
		<sch:rule context="//dcat:Catalog/dct:description">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="lang" value="@xml:lang/string()"/>
			<sch:let name="count" value="count(parent::node()/dct:description[@xml:lang = $lang])"/>
			<sch:assert test="2 > $count">ERROR: The dcat:Catalog '<sch:value-of select="$id"/>' has more than one (<sch:value-of select="$count"/>) dct:description properties with language tag '<sch:value-of select="$lang"/>'.
			</sch:assert>
			<sch:report test="2 > $count">The dcat:Catalog '<sch:value-of select="$id"/>' less than one (<sch:value-of select="$count"/>) dct:description properties with language tag '<sch:value-of select="$lang"/>'.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>214. dct:title should have a single value per language tag for dcat:Dataset</sch:title>
		<sch:rule context="//dcat:Dataset/dct:title">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="lang" value="@xml:lang/string()"/>
			<sch:let name="count" value="count(parent::node()/dct:title[@xml:lang = $lang])"/>
			<sch:assert test="2 > $count">ERROR: The dcat:Dataset '<sch:value-of select="$id"/>' has more than one (<sch:value-of select="$count"/>) dct:title properties with language tag '<sch:value-of select="$lang"/>'.
			</sch:assert>
			<sch:report test="2 > $count">The dcat:Dataset '<sch:value-of select="$id"/>' less than one (<sch:value-of select="$count"/>) dct:title properties with language tag '<sch:value-of select="$lang"/>'.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>215. dct:description should have a single value per language tag for dcat:Dataset</sch:title>
		<sch:rule context="//dcat:Dataset/dct:description">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="lang" value="@xml:lang/string()"/>
			<sch:let name="count" value="count(parent::node()/dct:description[@xml:lang = $lang])"/>
			<sch:assert test="2 > $count">ERROR: The dcat:Dataset '<sch:value-of select="$id"/>' has more than one (<sch:value-of select="$count"/>) dct:description properties with language tag '<sch:value-of select="$lang"/>'.
			</sch:assert>
			<sch:report test="2 > $count">The dcat:Dataset '<sch:value-of select="$id"/>' less than one (<sch:value-of select="$count"/>) dct:description properties with language tag '<sch:value-of select="$lang"/>'.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>216. dct:title should have a single value per language tag for dcat:Distribution</sch:title>
		<sch:rule context="//dcat:Distribution/dct:title">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="lang" value="@xml:lang/string()"/>
			<sch:let name="count" value="count(parent::node()/dct:title[@xml:lang = $lang])"/>
			<sch:assert test="2 > $count">ERROR: The dcat:Distribution '<sch:value-of select="$id"/>' has more than one (<sch:value-of select="$count"/>) dct:title properties with language tag '<sch:value-of select="$lang"/>'.
			</sch:assert>
			<sch:report test="2 > $count">The dcat:Distribution '<sch:value-of select="$id"/>' less than one (<sch:value-of select="$count"/>) dct:title properties with language tag '<sch:value-of select="$lang"/>'.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>217. dct:description should have a single value per language tag for dcat:Distribution</sch:title>
		<sch:rule context="//dcat:Distribution/dct:description">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="lang" value="@xml:lang/string()"/>
			<sch:let name="count" value="count(parent::node()/dct:description[@xml:lang = $lang])"/>
			<sch:assert test="2 > $count">ERROR: The dcat:Distribution '<sch:value-of select="$id"/>' has more than one (<sch:value-of select="$count"/>) dct:description properties with language tag '<sch:value-of select="$lang"/>'.
			</sch:assert>
			<sch:report test="2 > $count">The dcat:Distribution '<sch:value-of select="$id"/>' less than one (<sch:value-of select="$count"/>) dct:description properties with language tag '<sch:value-of select="$lang"/>'.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>230. dct:title should be a non-empty string for dcat:Dataset.</sch:title>
		<sch:rule context="//dcat:Dataset/dct:title">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="emptyString" value="normalize-space(.)=''"/>
			<sch:assert test="$emptyString = false()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:title that is an empty string.
			</sch:assert>
			<sch:report test="$emptyString = false()">The dcat:Dataset '<sch:value-of select="$id"/>' has a dct:title '<sch:value-of select="./string()"/>' which is a non-empty string.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>231. dct:title should be a non-empty string for dcat:Catalog.</sch:title>
		<sch:rule context="//dcat:Catalog/dct:title">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="emptyString" value="normalize-space(.)=''"/>
			<sch:assert test="$emptyString = false()">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:title that is an empty string.
			</sch:assert>
			<sch:report test="$emptyString = false()">The dcat:Catalog '<sch:value-of select="$id"/>' has a dct:title '<sch:value-of select="./string()"/>' which is a non-empty string.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>232. dct:title should be a non-empty string for dcat:Distribution.</sch:title>
		<sch:rule context="//dcat:Distribution/dct:title">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="emptyString" value="normalize-space(.)=''"/>
			<sch:assert test="$emptyString = false()">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" has a dct:title that is an empty string.
			</sch:assert>
			<sch:report test="$emptyString = false()">The dcat:Distribution '<sch:value-of select="$id"/>' has a dct:title '<sch:value-of select="./string()"/>' which is a non-empty string.
			</sch:report>
		</sch:rule>
	</sch:pattern>
  <sch:pattern>
    <sch:title>220. dcat:accessURL has maximum cardinality of 1 for Distribution.</sch:title>
    <sch:rule context="//dcat:Distribution">
      <sch:let name="id" value="@rdf:about/string()"/>
      <sch:let name="count" value="count(dcat:accessURL)"/>
      <sch:assert test="2 > $count">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" has more than one dcat:accessURL property.
      </sch:assert>
      <sch:report test="2 > $count">The dcat:Distribution "<sch:value-of select="$id"/>" has no more than one dcat:accessURL property.
      </sch:report>
    </sch:rule>
  </sch:pattern>
	<sch:pattern>
		<sch:title>233. dct:description should be a non-empty string for Catalog.</sch:title>
		<sch:rule context="//dcat:Catalog/dct:description">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="emptyString" value="normalize-space(.)=''"/>
			<sch:assert test="$emptyString = false()">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:description that is an empty string.
			</sch:assert>
			<sch:report test="$emptyString = false()">The dcat:Catalog '<sch:value-of select="$id"/>' has a dct:description '<sch:value-of select="./string()"/>' which is a non-empty string.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>234. dct:description should be a non-empty string for Dataset.</sch:title>
		<sch:rule context="//dcat:Dataset/dct:description">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="emptyString" value="normalize-space(.)=''"/>
			<sch:assert test="$emptyString = false()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:description that is an empty string.
			</sch:assert>
			<sch:report test="$emptyString = false()">The dcat:Dataset '<sch:value-of select="$id"/>' has a dct:description '<sch:value-of select="./string()"/>' which is a non-empty string.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>411. vcard:hasEmail is a mandatory property for a contactpoint of a Dataset.</sch:title>
		<sch:rule context="//dcat:Dataset/dcat:contactPoint">
			<sch:let name="id" value="*/@rdf:about/string()"/>
			<sch:let name="noEmail" value="not(*/vcard:hasEmail)"/>
			<sch:assert test="$noEmail = false()">ERROR: The vcard:Organization with URI "<sch:value-of select="$id"/>" does not have a vcard:hasEmail property.
			</sch:assert>
			<sch:report test="$noEmail = false()">The vcard:Organization with URI "<sch:value-of select="$id"/>" has a vcard:hasEmail property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>411. vcard:hasEmail must be a non-empty string.</sch:title>
		<sch:rule context="//vcard:hasEmail">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="emptyString" value="normalize-space(@rdf:resource)='' or not(matches(@rdf:resource, '.+@.+'))"/>
			<sch:assert test="$emptyString = false()">ERROR: The contact point "<sch:value-of select="$id"/>" has a vcard:hasEmail that is an empty string or does not match the e-mail format.
			</sch:assert>
			<sch:report test="$emptyString = false()">The dcontact point '<sch:value-of select="$id"/>' has a vcard:hasEmail '<sch:value-of select="./string()"/>' which is a non-empty string and matches the e-mail string format.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
	<sch:title>411. vcard:hasEmail has maximum cardinality of 1 for a contactpoint of a Dataset.</sch:title>
		<sch:rule context="//dcat:Dataset/dcat:contactPoint">
		  <sch:let name="id" value="@rdf:about/string()"/>
		  <sch:let name="count" value="count(*/vcard:hasEmail)"/>
		  <sch:assert test="2 > $count">ERROR: The vcard:Organization with URI "<sch:value-of select="$id"/>" has more than one vcard:hasEmail property.
		  </sch:assert>
		  <sch:report test="2 > $count">The vcard:Organization with URI "<sch:value-of select="$id"/>" has no more than one vcard:hasEmail property.
		  </sch:report>
		</sch:rule>
	</sch:pattern>
  <sch:pattern>
    <sch:title>412. vcard:hasEmail is a URI with the mailto protocol.</sch:title>
		<sch:rule context="//vcard:hasEmail">
			<sch:let name="id" value="@rdf:resource/string()"/>
			<sch:let name="mailto" value="starts-with(@rdf:resource,'mailto:')"/>
			<sch:assert test="$mailto = true()">ERROR: The vcard:hasEmail "<sch:value-of select="$id"/>" property is not a URI with the mailto: protocol.
			</sch:assert>
			<sch:report test="$mailto = true()">The vcard:hasEmail "<sch:value-of select="$id"/>" property is a URI with the mailto: protocol.
			</sch:report>
		</sch:rule>
  </sch:pattern>
  <sch:pattern>
    <sch:title>413. vcard:hasEmail is a URI.</sch:title>
		<sch:rule context="//vcard:hasEmail">
			<sch:let name="id" value="@rdf:resource/string()"/>
			<sch:let name="uri" value="@rdf:resource castable as xs:anyURI"/>
			<sch:assert test="$uri = true()">ERROR: The vcard:hasEmail "<sch:value-of select="$id"/>" property is not a valid URI.
			</sch:assert>
			<sch:report test="$uri = true()">The vcard:hasEmail "<sch:value-of select="$id"/>" property is a valid URI.
			</sch:report>
		</sch:rule>
  </sch:pattern>
</sch:schema>

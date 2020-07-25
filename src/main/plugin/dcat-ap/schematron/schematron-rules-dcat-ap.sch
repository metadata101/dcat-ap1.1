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

Schematron validation for DCAT-AP

Source:
- DCAT-AP v1.1: https://joinup.ec.europa.eu/release/dcat-ap-v11
- VODAP Validator: https://github.com/tenforce/vodap-dcatap-validation

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
		<sch:title>0. foaf:name is a required property for Agent.</sch:title>
		<sch:rule context="//foaf:Agent">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="missingProperty" value="not(foaf:name)"/>
			<sch:assert test="$missingProperty = false()">ERROR: The foaf:Agent "<sch:value-of select="$id"/>" does not have a foaf:name property.
			</sch:assert>
			<sch:report test="$missingProperty = false()">The foaf:Agent "<sch:value-of select="$id"/>" has a foaf:name property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>0. foaf:name for Agent cannot be an empty string.</sch:title>
		<sch:rule context="//foaf:Agent/foaf:name">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="emptyString" value="normalize-space(.)=''"/>
			<sch:assert test="$emptyString = false()">ERROR: The foaf:Agent "<sch:value-of select="$id"/>" has a foaf:name that is an empty string.
			</sch:assert>
			<sch:report test="$emptyString = false()">The foaf:Agent '<sch:value-of select="$id"/>' has a foaf:name '<sch:value-of select="./string()"/>' which is a non-empty string.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<!--GeoNetwork adds elements like <geonet:element xmlns:geonet="http://www.fao.org/geonetwork"> to any literal.
	The new inline validation tool does not (see https://github.com/geonetwork/core-geonetwork/pull/3298) does not correctly process
	this validation rule.
	<sch:pattern>
		<sch:title>1. The foaf:name property should be a literal.</sch:title>
		<sch:rule context="//foaf:Agent/foaf:name">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="notALiteral" value="exists(./*[node-name(.) != QName('http://www.fao.org/geonetwork','element')])"/>
			<sch:assert test="$notALiteral = false()">ERROR: The foaf:Agent "<sch:value-of select="$id"/>" has a foaf:name property which value "<sch:value-of select="string-join(.[child::*]//*/name(),'|') "/>" is not a literal.
			</sch:assert>
			<sch:report test="$notALiteral = false()">The foaf:Agent "<sch:value-of select="$id"/>" has a foaf:name property which is a literal "<sch:value-of select="./string()"/>".</sch:report>
		</sch:rule>
	</sch:pattern>
	 -->
	<sch:pattern>
		<sch:title>3. dct:type should be a skos:Concept.</sch:title>
		<sch:rule context="//foaf:Agent/dct:type">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(skos:Concept | */rdf:type[resolve-QName(@rdf:resource, /*) = QName('http://www.w3.org/2004/02/skos/core#','Concept')])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dct:Agent "<sch:value-of select="$id"/>" has a dct:type property which is not a skos:Concept.
			</sch:assert>
			<sch:report test="$wrongType = false()">The dct:Agent "<sch:value-of select="$id"/>" has a dct:type property which is a skos:Concept.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>4. dcat:dataset is a required property for Catalog.</sch:title>
		<sch:rule context="//dcat:Catalog">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="missingProperty" value="not(dcat:dataset)"/>
			<sch:assert test="$missingProperty = false()">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" should have a dcat:dataset property.
			</sch:assert>
			<sch:report test="$missingProperty = false()">The dcat:Catalog "<sch:value-of select="$id"/>" has a dcat:dataset property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>5. dcat:dataset should be a dcat:Dataset.</sch:title>
		<sch:rule context="//dcat:Catalog/dcat:dataset">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="id" value="*/@rdf:about/string()"/>
			<sch:let name="noDatasetType" value="not(dcat:Dataset | */rdf:type[resolve-QName(@rdf:resource, /*) = QName('http://www.w3.org/ns/dcat#','Dataset')])"/>
			<sch:assert test="$noDatasetType = false()">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" has a member  "<sch:value-of select="$id"/>" which is not a dcat:Dataset.
			</sch:assert>
			<sch:report test="$noDatasetType = false()">The dcat:Catalog "<sch:value-of select="$id"/>" has a member  "<sch:value-of select="$id"/>" which is a dcat:Dataset.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<!-- <sch:pattern> -->
		<!-- <sch:title>6. dct:description is a required property for Catalog.</sch:title> -->
		<!-- <sch:rule context="//dcat:Catalog"> -->
			<!-- <sch:let name="id" value="@rdf:about/string()"/> -->
			<!-- <sch:let name="noDescription" value="not(dct:description)"/> -->
			<!-- <sch:assert test="$noDescription = false()">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" does not have a dct:description. -->
			<!-- </sch:assert> -->
			<!-- <sch:report test="$noDescription = false()">The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:description. -->
			<!-- </sch:report> -->
		<!-- </sch:rule> -->
	<!-- </sch:pattern> -->
	<!-- <sch:pattern> -->
		<!-- <sch:title>6. dct:description for Catalog cannot be an empty string.</sch:title> -->
		<!-- <sch:rule context="//dcat:Catalog/dct:description"> -->
			<!-- <sch:let name="id" value="parent::node()/@rdf:about/string()"/> -->
			<!-- <sch:let name="emptyString" value="normalize-space(.)=''"/> -->
			<!-- <sch:assert test="$emptyString = false()">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:description that is an empty string. -->
			<!-- </sch:assert> -->
			<!-- <sch:report test="$emptyString = false()">The dcat:Catalog '<sch:value-of select="$id"/>' has a dct:description '<sch:value-of select="./string()"/>' which is a non-empty string. -->
			<!-- </sch:report> -->
		<!-- </sch:rule> -->
	<!-- </sch:pattern> -->
	<!--GeoNetwork adds elements like <geonet:element xmlns:geonet="http://www.fao.org/geonetwork"> to any literal.
	The new inline validation tool does not (see https://github.com/geonetwork/core-geonetwork/pull/3298) does not correctly process
	this validation rule.
	<sch:pattern>
		<sch:title>7. dct:description should be a literal for Catalog.</sch:title>
		<sch:rule context="//dcat:Catalog/dct:description">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="notALiteral" value="exists(./*[node-name(.) != QName('http://www.fao.org/geonetwork','element')])"/>
			<sch:assert test="$notALiteral = false()">ERROR: In dcat:Catalog "<sch:value-of select="$id"/>" the dct:description property "<sch:value-of select="string-join(//.[child::*]//*/name(),'|') "/>," is not a literal.</sch:assert>
			<sch:report test="$notALiteral = false()">In dcat:Catalog "<sch:value-of select="$id"/>" the dct:description property "<sch:value-of select="./string()"/>," is a literal.</sch:report>
		</sch:rule>
	</sch:pattern>
	-->
	<!--
	<sch:pattern>
		<sch:title>8. dct:publisher is a required property for Catalog.</sch:title>
		<sch:rule context="//dcat:Catalog">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="noDataset" value="not(dct:publisher)"/>
			<sch:assert test="$noDataset = false()">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" should have a dct:publisher property.
			</sch:assert>
			<sch:report test="$noDataset = false()">The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:publisherproperty.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
	-->
	<!--
	<sch:pattern>
		<sch:title>9. dct:publisher has a maximum cardinality of 1 for Catalog.</sch:title>
		<sch:rule context="//dcat:Catalog">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="count" value="count(dct:publisher)"/>
			<sch:assert test="2 > $count">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" has more than one dct:publisher property.
			</sch:assert>
			<sch:report test="2 > $count">The dcat:Catalog "<sch:value-of select="$id"/>" has maximally one dct:publisher property.
			</sch:report>
		</sch:rule>
	</sch:pattern> -->
	<!-- <sch:pattern> -->
		<!-- <sch:title>11. dct:publisher should be a foaf:Agent for Catalog.</sch:title> -->
		<!-- <sch:rule context="//dcat:Catalog/dct:publisher"> -->
			<!-- <sch:let name="Catalogid" value="parent::node()/@rdf:about/string()"/> -->
			<!-- <sch:let name="id" value="*/@rdf:about/string()"/> -->
			<!-- <sch:let name="noAgent" value="not(foaf:Agent | */rdf:type[resolve-QName(@rdf:resource, /*) = QName('http://xmlns.com/foaf/0.1/','Agent')])"/> -->
			<!-- <sch:assert test="$noAgent = false()">ERROR: The dcat:Catalog "<sch:value-of select="$Catalogid"/>" has a dct:publisher  "<sch:value-of select="$id"/>" which is not a foaf:Agent. -->
			<!-- </sch:assert> -->
			<!-- <sch:report test="$noAgent = false()">The dcat:Catalog "<sch:value-of select="$Catalogid"/>" has a dct:publisher  "<sch:value-of select="$id"/>" which is a foaf:Agent. -->
			<!-- </sch:report> -->
		<!-- </sch:rule> -->
	<!-- </sch:pattern> -->
	<!-- <sch:pattern> -->
		<!-- <sch:title>12. dct:title is a required property for Catalog.</sch:title> -->
		<!-- <sch:rule context="//dcat:Catalog"> -->
			<!-- <sch:let name="id" value="@rdf:about/string()"/> -->
			<!-- <sch:let name="noTitle" value="not(dct:title)"/> -->
			<!-- <sch:assert test="$noTitle = false()">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" does not have a dct:title. -->
			<!-- </sch:assert> -->
			<!-- <sch:report test="$noTitle = false()">The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:title "<sch:value-of select="dct:title[0]/string()"/>". -->
			<!-- </sch:report> -->
		<!-- </sch:rule> -->
	<!-- </sch:pattern> -->
	<!-- <sch:pattern> -->
		<!-- <sch:title>12. dct:title should be a non-empty string.</sch:title> -->
		<!-- <sch:rule context="//dcat:Catalog/dct:title"> -->
			<!-- <sch:let name="id" value="parent::node()/@rdf:about/string()"/> -->
			<!-- <sch:let name="emptyString" value="normalize-space(.)=''"/> -->
			<!-- <sch:assert test="$emptyString = false()">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:title that is an empty string. -->
			<!-- </sch:assert> -->
			<!-- <sch:report test="$emptyString = false()">The dcat:Catalog '<sch:value-of select="$id"/>' has a dct:title '<sch:value-of select="./string()"/>' which is a non-empty string. -->
			<!-- </sch:report> -->
		<!-- </sch:rule> -->
	<!-- </sch:pattern>	 -->
	<!--GeoNetwork adds elements like <geonet:element xmlns:geonet="http://www.fao.org/geonetwork"> to any literal.
	The new inline validation tool does not (see https://github.com/geonetwork/core-geonetwork/pull/3298) does not correctly process
	this validation rule.
	<sch:pattern>
		<sch:title>13. dct:title should be a literal.</sch:title>
		<sch:rule context="//dcat:Catalog/dct:title">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="notALiteral" value="exists(./*[node-name(.) != QName('http://www.fao.org/geonetwork','element')])"/>
			<sch:assert test="$notALiteral = false()">ERROR: In dcat:Catalog "<sch:value-of select="$id"/>" the dct:title property "<sch:value-of select="string-join(//.[child::*]//*/name(),'|') "/>," is not a literal.</sch:assert>
			<sch:report test="$notALiteral = false()">In dcat:Catalog "<sch:value-of select="$id"/>" the dct:title property "<sch:value-of select="./string()"/>," is a literal.</sch:report>
		</sch:rule>
	</sch:pattern>
	-->
	<!-- <sch:pattern> -->
		<!-- <sch:title>15. foaf:homepage has a maximum cardinality of 1 for Catalog.</sch:title> -->
		<!-- <sch:rule context="//dcat:Catalog"> -->
			<!-- <sch:let name="id" value="@rdf:about/string()"/> -->
			<!-- <sch:let name="countHomepage" value="count(foaf:homepage)"/> -->
			<!-- <sch:assert test="2 > $countHomepage">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" has more than one foaf:homepage property. -->
			<!-- </sch:assert> -->
			<!-- <sch:report test="2 > $countHomepage">The dcat:Catalog "<sch:value-of select="$id"/>" has maximally one foaf:homepage property. -->
			<!-- </sch:report> -->
		<!-- </sch:rule> -->
	<!-- </sch:pattern> -->
	<!-- <sch:pattern> -->
		<!-- <sch:title>17. foaf:homepage should be a foaf:Document.</sch:title> -->
		<!-- <sch:rule context="//dcat:Catalog/foaf:homepage"> -->
			<!-- <sch:let name="Catalogid" value="parent::node()/@rdf:about/string()"/> -->
			<!-- <sch:let name="id" value="*/@rdf:about/string()"/> -->
			<!-- <sch:let name="noDocument" value="not(foaf:Document | */rdf:type[resolve-QName(@rdf:resource, /*) = QName('http://xmlns.com/foaf/0.1/','Document')])"/> -->
			<!-- <sch:assert test="$noDocument = false()">ERROR: The dcat:Catalog "<sch:value-of select="$Catalogid"/>" has a foaf:homepage  "<sch:value-of select="$id"/>" which is not a foaf:Document. -->
			<!-- </sch:assert> -->
			<!-- <sch:report test="$noDocument = false()">The dcat:Catalog "<sch:value-of select="$Catalogid"/>" has a foaf:homepage  "<sch:value-of select="$id"/>" which is a foaf:Document. -->
			<!-- </sch:report> -->
		<!-- </sch:rule> -->
	<!-- </sch:pattern> -->
	<!-- <sch:pattern> -->
		<!-- <sch:title>20. dct:language should be a dct:LinguisticSystem.</sch:title> -->
		<!-- <sch:rule context="//dcat:Catalog/dct:language"> -->
			<!-- <sch:let name="Catalogid" value="parent::node()/@rdf:about/string()"/> -->
			<!-- <sch:let name="id" value="*/@rdf:about/string()"/> -->
			<!-- <sch:let name="noLinguisticSystem" value="not(dct:LinguisticSystem | */rdf:type[@rdf:resource = 'http://purl.org/dc/terms/LinguisticSystem'])"/> -->
			<!-- <sch:assert test="$noLinguisticSystem = false()">ERROR: The dcat:Catalog "<sch:value-of select="$Catalogid"/>" has a dct:language  "<sch:value-of select="$id"/>" which is not a dct:LinguisticSystem. -->
			<!-- </sch:assert> -->
			<!-- <sch:report test="$noLinguisticSystem = false()">The dcat:Catalog "<sch:value-of select="$Catalogid"/>" has a dct:language  "<sch:value-of select="$id"/>" which is a dct:LinguisticSystem. -->
			<!-- </sch:report> -->
		<!-- </sch:rule> -->
	<!-- </sch:pattern> -->
	<!-- <sch:pattern> -->
		<!-- <sch:title>23. dct:license has a maximum cardinality of 1 for Catalog.</sch:title> -->
		<!-- <sch:rule context="//dcat:Catalog"> -->
			<!-- <sch:let name="id" value="@rdf:about/string()"/> -->
			<!-- <sch:let name="countLicense" value="count(dct:license)"/> -->
			<!-- <sch:assert test="2 > $countLicense">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" has more than one dct:license property. -->
			<!-- </sch:assert> -->
			<!-- <sch:report test="2 > $countLicense">The dcat:Catalog "<sch:value-of select="$id"/>" has no more than one dct:license property. -->
			<!-- </sch:report> -->
		<!-- </sch:rule> -->
	<!-- </sch:pattern> -->
	<!-- <sch:pattern> -->
		<!-- <sch:title>25. dct:issued should be literal typed as date or dateTime.</sch:title> -->
		<!-- <sch:rule context="//dcat:Catalog/dct:issued"> -->
			<!-- <sch:let name="id" value="parent::node()/@rdf:about/string()"/> -->
			<!-- <sch:let name="modifiedDateTime" value=". castable as xs:date or . castable as xs:dateTime"/> -->
			<!-- <sch:assert test="$modifiedDateTime = true()">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:issued property which value "<sch:value-of select="./string()"/>" is not a date or dateTime. -->
			<!-- </sch:assert> -->
			<!-- <sch:report test="$modifiedDateTime = true()">The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:issued property which value "<sch:value-of select="./string()"/>" is a date or dateTime. -->
			<!-- </sch:report> -->
		<!-- </sch:rule> -->
	<!-- </sch:pattern> -->
	<!-- <sch:pattern> -->
		<!-- <sch:title>26. dct:issued has a maximum cardinality of 1 for Catalog.</sch:title> -->
		<!-- <sch:rule context="//dcat:Catalog"> -->
			<!-- <sch:let name="id" value="@rdf:about/string()"/> -->
			<!-- <sch:let name="countIssued" value="count(dct:issued)"/> -->
			<!-- <sch:assert test="2 > $countIssued">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" has more than one dct:issued property. -->
			<!-- </sch:assert> -->
			<!-- <sch:report test="2 > $countIssued">The dcat:Catalog "<sch:value-of select="$id"/>" has no more than one dct:issued property. -->
			<!-- </sch:report> -->
		<!-- </sch:rule> -->
	<!-- </sch:pattern> -->
	<!-- <sch:pattern> -->
		<!-- <sch:title>30. dcat:record should be a dcat:CatalogRecord.</sch:title> -->
		<!-- <sch:rule context="//dcat:Catalog/dcat:record"> -->
			<!-- <sch:let name="Catalogid" value="parent::node()/@rdf:about/string()"/> -->
			<!-- <sch:let name="id" value="*/@rdf:about/string()"/> -->
			<!-- <sch:let name="noCatalogRecord" value="not(dcat:CatalogRecord | */rdf:type[resolve-QName(@rdf:resource, /*) = QName('http://www.w3.org/ns/dcat#','CatalogRecord')])"/> -->
			<!-- <sch:assert test="$noCatalogRecord = false()">ERROR: The dcat:Catalog "<sch:value-of select="$Catalogid"/>" has a dcat:record  "<sch:value-of select="$id"/>" which is not a dcat:CatalogRecord. -->
			<!-- </sch:assert> -->
			<!-- <sch:report test="$noCatalogRecord = false()">The dcat:Catalog "<sch:value-of select="$Catalogid"/>" has a dcat:record  "<sch:value-of select="$id"/>" which is a dcat:CatalogRecord. -->
			<!-- </sch:report> -->
		<!-- </sch:rule> -->
	<!-- </sch:pattern> -->
	<!-- <sch:pattern> -->
		<!-- <sch:title>32. dct:modified should be a literal typed as date or dateTime.</sch:title> -->
		<!-- <sch:rule context="//dcat:Catalog/dct:modified"> -->
			<!-- <sch:let name="id" value="parent::node()/@rdf:about/string()"/> -->
			<!-- <sch:let name="modifiedDateTime" value=". castable as xs:date or . castable as xs:dateTime"/> -->
			<!-- <sch:assert test="$modifiedDateTime = true()">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:modified property which value "<sch:value-of select="./string()"/>" is not a date or dateTime. -->
			<!-- </sch:assert> -->
			<!-- <sch:report test="$modifiedDateTime = true()">The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:modified property which value "<sch:value-of select="./string()"/>" is a date or dateTime. -->
			<!-- </sch:report> -->
		<!-- </sch:rule> -->
	<!-- </sch:pattern> -->
	<!-- <sch:pattern> -->
		<!-- <sch:title>33. dct:modified has a maximum cardinality of 1 for Catalog.</sch:title> -->
		<!-- <sch:rule context="//dcat:Catalog"> -->
			<!-- <sch:let name="id" value="@rdf:about/string()"/> -->
			<!-- <sch:let name="countModified" value="count(dct:modified)"/> -->
			<!-- <sch:assert test="2 > $countModified">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" has more than one dct:modified property. -->
			<!-- </sch:assert> -->
			<!-- <sch:report test="2 > $countModified">The dcat:Catalog "<sch:value-of select="$id"/>" has no more than one dct:modified property. -->
			<!-- </sch:report> -->
		<!-- </sch:rule> -->
	<!-- </sch:pattern>	 -->
	<!--
	<sch:pattern>
		<sch:title>34. dct:rights should be a dct:RightsStatement.</sch:title>
		<sch:rule context="//dcat:Catalog/dct:rights">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(dct:RightsStatement | */rdf:type[@rdf:resource = 'http://purl.org/dc/terms/RightsStatement'])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:rights  property "<sch:value-of select="$id"/>" which is not a dct:RightsStatement.
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:rights  property "<sch:value-of select="$id"/>" which is a dct:RightsStatement.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	-->
	<!--
	<sch:pattern>
		<sch:title>35.  dct:rights has maximum cardinality of 1 for Catalog.</sch:title>
		<sch:rule context="//dcat:Catalog">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="count" value="count(dct:rights)"/>
			<sch:assert test="2 > $count">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" has more than one dct:rights property.
			</sch:assert>
			<sch:report test="2 > $count">The dcat:Catalog "<sch:value-of select="$id"/>" has no more than one dct:rights property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	-->
	<!--
	<sch:pattern>
		<sch:title>36. dct:spatial should be a dct:Location.</sch:title>
		<sch:rule context="//dcat:Catalog/dct:spatial">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(dct:Location | */rdf:type[@rdf:resource = 'http://purl.org/dc/terms/Location'])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:spatial  property "<sch:value-of select="$id"/>" which is not a dct:Location.
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:spatial  property "<sch:value-of select="$id"/>" which is a dct:Location.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	-->
	<sch:pattern>
		<sch:title>37. dct:description is a required property for Dataset.</sch:title>
		<sch:rule context="//dcat:Dataset">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="noDescription" value="not(dct:description)"/>
			<sch:assert test="$noDescription = false()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" does not have a dct:description.
			</sch:assert>
			<sch:report test="$noDescription = false()">The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:description.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<!--38. dct:description should be a literal for Dataset.-->
	<sch:pattern>
		<sch:title>39. dct:title is a required property for Dataset.</sch:title>
		<sch:rule context="//dcat:Dataset">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="noTitle" value="not(dct:title)"/>
			<sch:assert test="$noTitle = false()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" does not have a dct:title.
			</sch:assert>
			<sch:report test="$noTitle = false()">The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:title.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<!--40. dct:title should be a literal for Dataset.-->
	<sch:pattern>
		<sch:title>43. dcat:contactPoint should be a vcard:Kind (or vcard:Organization,vcard:Individual,vcard:Location,vcard:Group).</sch:title>
		<sch:rule context="//dcat:Dataset/dcat:contactPoint">
			<sch:let name="Datasetid" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="types" value="string-join(('http://www.w3.org/2006/vcard/ns#Kind', 'http://www.w3.org/2006/vcard/ns#Organization'),'|')"/>
			<sch:let name="id" value="*/@rdf:about/string()"/>
			<sch:let name="Kind" value="exists(*[contains($types,  concat(namespace-uri-from-QName(node-name(.)),local-name-from-QName(node-name(.))))]) or exists(*/rdf:type[contains($types,  concat(namespace-uri-from-QName(resolve-QName(@rdf:resource,/*)),local-name-from-QName(resolve-QName(@rdf:resource,/*))))])"/>
			<sch:assert test="$Kind = true()">ERROR: The dcat:Dataset "<sch:value-of select="$Datasetid"/>" has a dcat:contactPoint  "<sch:value-of select="$id"/>" which is not a vcard:Kind (or vcard:Organization,vcard:Individual,vcard:Location,vcard:Group).
			</sch:assert>
			<sch:report test="$Kind = true()">The dcat:Dataset "<sch:value-of select="$Datasetid"/>" has a dcat:contactPoint  "<sch:value-of select="$id"/>" which is a vcard:Kind (or vcard:Organization,vcard:Individual,vcard:Location,vcard:Group).
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>46. dcat:distribution should be a dcat:Distribution.</sch:title>
		<sch:rule context="//dcat:Dataset/dcat:distribution">
			<sch:let name="Datasetid" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="types" value="string-join(('http://www.w3.org/ns/dcat#Distribution'),'|')"/>
			<sch:let name="id" value="*/@rdf:about/string()"/>
			<sch:let name="Distribution" value="exists(*[contains($types,  concat(namespace-uri-from-QName(node-name(.)),local-name-from-QName(node-name(.))))]) or exists(*/rdf:type[contains($types,  concat(namespace-uri-from-QName(resolve-QName(@rdf:resource,/*)),local-name-from-QName(resolve-QName(@rdf:resource,/*))))])"/>
			<sch:assert test="$Distribution = true()">ERROR: The dcat:Dataset "<sch:value-of select="$Datasetid"/>" has a dcat:distribution "<sch:value-of select="$id"/>" which is not a dcat:Distribution.
			</sch:assert>
			<sch:report test="$Distribution = true()">The dcat:Dataset "<sch:value-of select="$Datasetid"/>" has a dcat:distribution "<sch:value-of select="$id"/>" which is a dcat:Distribution.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>50. dct:publisher has maximum cardinality of 1 for Dataset.</sch:title>
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
		<sch:title>52. dct:publisher should be a foaf:Agent.</sch:title>
		<sch:rule context="//dcat:Dataset/dct:publisher">
			<sch:let name="Datasetid" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="types" value="string-join(('http://xmlns.com/foaf/0.1/Agent'),'|')"/>
			<sch:let name="id" value="*/@rdf:about/string()"/>
			<sch:let name="Agent" value="exists(*[contains($types,  concat(namespace-uri-from-QName(node-name(.)),local-name-from-QName(node-name(.))))]) or exists(*/rdf:type[contains($types,  concat(namespace-uri-from-QName(resolve-QName(@rdf:resource,/*)),local-name-from-QName(resolve-QName(@rdf:resource,/*))))])"/>
			<sch:assert test="$Agent = true()">ERROR: The dcat:Dataset "<sch:value-of select="$Datasetid"/>" has a dct:publisher "<sch:value-of select="$id"/>" which is not a foaf:Agent.
			</sch:assert>
			<sch:report test="$Agent = true()">The dcat:Dataset "<sch:value-of select="$Datasetid"/>" has a dct:publisher "<sch:value-of select="$id"/>" which is a foaf:Agent.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>56. dct:conformsTo should be a dct:Standard.</sch:title>
		<sch:rule context="//dcat:Dataset/dct:conformsTo">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(dct:Standard | */rdf:type[@rdf:resource = 'http://purl.org/dc/terms/Standard'])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:conformsTo  property "<sch:value-of select="$id"/>" which is not a dct:Standard.
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:conformsTo property "<sch:value-of select="$id"/>" which is a dct:Standard.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>58. dct:accrualPeriodicity should be a dct:Frequency.</sch:title>
		<sch:rule context="//dcat:Dataset/dct:accrualPeriodicity">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(dct:Frequency | */rdf:type[@rdf:resource = 'http://purl.org/dc/terms/Frequency'])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:accrualPeriodicity  property "<sch:value-of select="$id"/>" which is not a dct:Frequency.
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:accrualPeriodicity property "<sch:value-of select="$id"/>" which is a dct:Frequency.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>59. dct:accrualPeriodicity has maximum cardinality of 1 for Dataset.</sch:title>
		<sch:rule context="//dcat:Dataset">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="count" value="count(dct:accrualPeriodicity )"/>
			<sch:assert test="2 > $count">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has more than one dct:accrualPeriodicity  property.
			</sch:assert>
			<sch:report test="2 > $count">The dcat:Dataset "<sch:value-of select="$id"/>" has no more than one dct:accrualPeriodicity  property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<!--60. dct:identifier should be a literal.-->
	<sch:pattern>
		<sch:title>63. dcat:landingPage should be a foaf:Document.</sch:title>
		<sch:rule context="//dcat:Dataset/dcat:landingPage">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(@rdf:resource | foaf:Document | */rdf:type[resolve-QName(@rdf:resource, /*) = QName('http://xmlns.com/foaf/0.1/','Document')])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has a dcat:landingPage property "<sch:value-of select="$id"/>" which is not a foaf:Document.
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Dataset "<sch:value-of select="$id"/>" has a dcat:landingPage property "<sch:value-of select="$id"/>" which is a foaf:Document.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>65. dct:language should be a dct:LinguisticSystem.</sch:title>
		<sch:rule context="//dcat:Dataset/dct:language">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(dct:LinguisticSystem | */rdf:type[@rdf:resource = 'http://purl.org/dc/terms/LinguisticSystem'])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:language  property "<sch:value-of select="$id"/>" which is not a dct:LinguisticSystem.
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:language property "<sch:value-of select="$id"/>" which is a dct:LinguisticSystem.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>66. skos:notation is a required property for adms:Identifier.</sch:title>
		<sch:rule context="//adms:Identifier">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="propMissing" value="not(skos:notation)"/>
			<sch:assert test="$propMissing = false()">ERROR: The adms:Identifier. "<sch:value-of select="$id"/>" does not have a skos:notation property.
			</sch:assert>
			<sch:report test="$propMissing = false()">The adms:Identifier. "<sch:value-of select="$id"/>" has a skos:notation property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
		<sch:pattern>
		<sch:title>67. adms:identifier should be a adms:Identifier.</sch:title>
		<sch:rule context="//dcat:Dataset/adms:identifier">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(adms:Identifier | */rdf:type[resolve-QName(@rdf:resource, /*) = QName('http://www.w3.org/ns/adms#','Identifier')])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has a adms:identifier  property "<sch:value-of select="$id"/>" which is not a adms:Identifier.
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Dataset "<sch:value-of select="$id"/>" has a adms:identifier property "<sch:value-of select="$id"/>" which is a adms:Identifier.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>68. dct:issued should be a literal typed as date or dateTime (value).</sch:title>
		<sch:rule context="//dcat:Dataset/dct:issued">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="properDateTime" value=". castable as xs:date or . castable as xs:dateTime"/>
			<sch:assert test="$properDateTime = true()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:issued property which value "<sch:value-of select="./string()"/>" is not a proper xsd:date or xsd:dateTime.
			</sch:assert>
			<sch:report test="$properDateTime = true()">The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:issued property which value "<sch:value-of select="./string()"/>" is a date or dateTime.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>68. dct:issued should be a literal typed as date or dateTime (type).</sch:title>
		<sch:rule context="//dcat:Dataset/dct:issued">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="datatype" value="./@rdf:datatype = 'http://www.w3.org/2001/XMLSchema#date' or ./@rdf:datatype = 'http://www.w3.org/2001/XMLSchema#dateTime'"/>
			<sch:assert test="$datatype = true()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:issued property which value "<sch:value-of select="./string()"/>" is not typed (rdf:datatype) as xsd:date or xsd:dateTime.
			</sch:assert>
			<sch:report test="$datatype = true()">The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:issued property which value "<sch:value-of select="./string()"/>" is typed (rdf:datatype) as xsd:date or xsd:dateTime.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>69. dct:issued has a maximum cardinality of 1 for Dataset.</sch:title>
		<sch:rule context="//dcat:Dataset">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="count" value="count(dct:issued)"/>
			<sch:assert test="2 > $count">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has more than one dct:issued property.
			</sch:assert>
			<sch:report test="2 > $count">The dcat:Dataset "<sch:value-of select="$id"/>" has no more than one dct:issued property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>71. dct:spatial should be a dct:Location.</sch:title>
		<sch:rule context="//dcat:Dataset/dct:location">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(dct:Location | */rdf:type[@rdf:resource = 'http://purl.org/dc/terms/Location'])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:spatial  property "<sch:value-of select="$id"/>" which is not a dct:Location.
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:spatial  property "<sch:value-of select="$id"/>" which is a dct:Location.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>72. dct:temporal should be a dct:PeriodOfTime.</sch:title>
		<sch:rule context="//dcat:Dataset/dct:temporal">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(dct:PeriodOfTime | */rdf:type[@rdf:resource = 'http://purl.org/dc/terms/PeriodOfTime'])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:temporal  property "<sch:value-of select="$id"/>" which is not a dct:PeriodOfTime.
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:temporal  property "<sch:value-of select="$id"/>" which is a dct:PeriodOfTime.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>73. dct:modified should be a literal typed as date or dateTime (value).</sch:title>
		<sch:rule context="//dcat:Dataset/dct:modified">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="properDateTime" value=". castable as xs:date or . castable as xs:dateTime"/>
			<sch:assert test="$properDateTime = true()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:modified property which value "<sch:value-of select="./string()"/>" is not a proper xsd:date or xsd:dateTime.
			</sch:assert>
			<sch:report test="$properDateTime = true()">The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:modified property which value "<sch:value-of select="./string()"/>" is a date or dateTime.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>73. dct:modified should be a literal typed as date or dateTime (type).</sch:title>
		<sch:rule context="//dcat:Dataset/dct:modified">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="datatype" value="./@rdf:datatype = 'http://www.w3.org/2001/XMLSchema#date' or ./@rdf:datatype = 'http://www.w3.org/2001/XMLSchema#dateTime'"/>
			<sch:assert test="$datatype = true()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:modified property which value "<sch:value-of select="./string()"/>" is not typed (rdf:datatype) as xsd:date or xsd:dateTime.
			</sch:assert>
			<sch:report test="$datatype = true()">The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:modified property which value "<sch:value-of select="./string()"/>" is typed (rdf:datatype) as xsd:date or xsd:dateTime.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>74. dct:modified has maximum cardinality of 1 for Dataset.</sch:title>
		<sch:rule context="//dcat:Dataset">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="count" value="count(dct:modified)"/>
			<sch:assert test="2 > $count">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has more than one dct:modified property.
			</sch:assert>
			<sch:report test="2 > $count">The dcat:Dataset "<sch:value-of select="$id"/>" has no more than one dct:modified property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<!--75. owl:versionInfo should be a literal.-->
	<sch:pattern>
		<sch:title>76. owl:versionInfo has maximum cardinality of 1 for Dataset.</sch:title>
		<sch:rule context="//dcat:Dataset">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="count" value="count(owl:versionInfo)"/>
			<sch:assert test="2 > $count">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has more than one owl:versionInfo property.
			</sch:assert>
			<sch:report test="2 > $count">The dcat:Dataset "<sch:value-of select="$id"/>" has no more than one owl:versionInfo property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
  <sch:pattern>
	<!--77. adms:versionNotes should be literal.-->
    <sch:title>79. dcat:accessURL is a mandatory property for a distribution.</sch:title>
    <sch:rule context="//dcat:Distribution">
      <sch:let name="id" value="dct:title[1]/string()"/>
      <sch:let name="noURL" value="not(dcat:accessURL)"/>
      <sch:assert test="$noURL = false()">ERROR: The dcat:Distribution with title "<sch:value-of select="$id"/>" does not have a dcat:accessURL property.
      </sch:assert>
      <sch:report test="$noURL = false()">The dcat:Distribution with title "<sch:value-of select="$id"/>" has a dcat:accessURL property.
      </sch:report>
    </sch:rule>
  </sch:pattern>
  <sch:pattern>
    <sch:title>79. dcat:accessURL must be a non-empty string.</sch:title>
    <sch:rule context="//dcat:Distribution/dcat:accessURL">
      <sch:let name="id" value="parent::node()/dct:title[1]/string()"/>
      <sch:let name="emptyString" value="normalize-space(@rdf:resource) = ''"/>
      <sch:assert test="$emptyString = false()">ERROR: The dcat:Distribution with title "<sch:value-of select="$id"/>" has a dcat:accessURL that is an empty string.
      </sch:assert>
      <sch:report test="$emptyString = false()">The dcat:Distribution with title '<sch:value-of select="$id"/>' has a dcat:accessURL '<sch:value-of select="./string()"/>' which is a non-empty string.
      </sch:report>
    </sch:rule>
  </sch:pattern>
  <sch:pattern>
    <sch:title>80. dcat:accessURL must be a resource.</sch:title>
    <sch:rule context="//dcat:Distribution/dcat:accessURL">
      <sch:let name="id" value="parent::node()/dct:title[1]/string()"/>
      <sch:let name="isAResource" value="./@rdf:resource and not(./string() = '')"/>
      <sch:assert test="$isAResource = false()">ERROR: The dcat:Distribution with title "<sch:value-of select="$id"/>" has a dcat:accessURL that is not a resource (URI).
      </sch:assert>
      <sch:report test="$isAResource = false()">The dcat:Distribution with title '<sch:value-of select="$id"/>' has a dcat:accessURL '<sch:value-of select="./string()"/>' that is a resource (URI).
      </sch:report>
    </sch:rule>
  </sch:pattern>
	<!--82. dct:description should be a literal.-->
	<sch:pattern>
		<sch:title>84. dct:format should be a dct:MediaTypeOrExtent.</sch:title>
		<sch:rule context="//dcat:Distribution/dct:format">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(dct:MediaTypeOrExtent | */rdf:type[@rdf:resource = 'http://purl.org/dc/terms/MediaTypeOrExtent'])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" has a dct:format  property "<sch:value-of select="$id"/>" which is not a dct:MediaTypeOrExtent.
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Distribution "<sch:value-of select="$id"/>" has a dct:format  property "<sch:value-of select="$id"/>" which is a dct:MediaTypeOrExtent.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>85. dct:format has a maximum cardinality of 1 for Distribution.</sch:title>
		<sch:rule context="//dcat:Distribution">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="count" value="count(dct:format)"/>
			<sch:assert test="2 > $count">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" has more than one dct:format property.
			</sch:assert>
			<sch:report test="2 > $count">The dcat:Distribution "<sch:value-of select="$id"/>" has no more than one dct:format property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>87. dct:license should be a dct:LicenseDocument.</sch:title>
		<sch:rule context="//dcat:Distribution/dct:license">
			<sch:let name="Distributionid" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="types" value="string-join(('http://purl.org/dc/terms/LicenseDocument'),'|')"/>
			<sch:let name="id" value="*/@rdf:about/string()"/>
			<sch:let name="LicenseDocument" value="exists(*[contains($types,  concat(namespace-uri-from-QName(node-name(.)),local-name-from-QName(node-name(.))))]) or exists(*/rdf:type[contains($types,  concat(namespace-uri-from-QName(resolve-QName(@rdf:resource,/*)),local-name-from-QName(resolve-QName(@rdf:resource,/*))))])"/>
			<sch:assert test="$LicenseDocument = true()">ERROR: The dcat:Distribution "<sch:value-of select="$Distributionid"/>" has a dct:license "<sch:value-of select="$id"/>" which is not a dct:LicenseDocument.
			</sch:assert>
			<sch:report test="$LicenseDocument = true()">The dcat:Distribution "<sch:value-of select="$Distributionid"/>" has a dct:license "<sch:value-of select="$id"/>" which is a dct:LicenseDocument.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>88. dct:license has maximum cardinality of 1 for Distribution.</sch:title>
		<sch:rule context="//dcat:Distribution">
			<sch:let name="id" value="parent::node()/dct:title[1]/string()"/>
			<sch:let name="count" value="count(dct:license)"/>
			<sch:assert test="2 > $count">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" has more than one dct:license property.
			</sch:assert>
			<sch:report test="2 > $count">The dcat:Distribution "<sch:value-of select="$id"/>" has no more than one dct:license property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>89. dcat:byteSize should be a literal typed as decimal (value).</sch:title>
		<sch:rule context="//dcat:Distribution/dcat:byteSize">
			<sch:let name="id" value="parent::node()/dct:title[1]/string()"/>
			<sch:let name="datatype" value=". castable as xs:decimal"/>
			<sch:assert test="$datatype = true()">ERROR: The dcat:Distribution has a dcat:byteSize property value that is not a valid xsd:decimal.
			</sch:assert>
			<sch:report test="$datatype = true()">The dcat:Distribution "<sch:value-of select="$id"/>" has a dcat:byteSize property value that is a valid xsd:decimal.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>89. dcat:byteSize should be a literal typed as decimal (datatype).</sch:title>
		<sch:rule context="//dcat:Distribution/dcat:byteSize">
			<sch:let name="id" value="parent::node()/dct:title[1]/string()"/>
			<sch:let name="datatype" value="./@rdf:datatype = xs:decimal"/>
			<sch:assert test="$datatype = false()">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" has a dcat:byteSize property that is not typed as an xsd:decimal.
			</sch:assert>
			<sch:report test="$datatype = false()">The dcat:Distribution "<sch:value-of select="$id"/>" has a dcat:byteSize property that is typed as an xsd:decimal.
			</sch:report>
		</sch:rule>
	</sch:pattern>
  <sch:pattern>
    <sch:title>90. dcat:downloadURL should be a resource.</sch:title>
    <sch:rule context="//dcat:Distribution/dcat:downloadURL">
      <sch:let name="id" value="parent::node()/dct:title[1]/string()"/>
      <sch:let name="isAResource" value="./@rdf:resource and not(./string() = '')"/>
      <sch:assert test="$isAResource = false()">ERROR: The dcat:Distribution with title "<sch:value-of select="$id"/>" has a dcat:downloadURL that is not a resource (URI).
      </sch:assert>
      <sch:report test="$isAResource = false()">The dcat:Distribution with title '<sch:value-of select="$id"/>' has a dcat:downloadURL '<sch:value-of select="./string()"/>' that is a resource (URI).
      </sch:report>
    </sch:rule>
  </sch:pattern>
	<sch:pattern>
		<sch:title>91. dcat:mediaType should be a dct:MediaTypeOrExtent.</sch:title>
		<sch:rule context="//dcat:Distribution/dcat:mediaType">
			<sch:let name="id" value="parent::node()/dct:title[1]/string()"/>
			<sch:let name="wrongType" value="not(dct:MediaTypeOrExtent | */rdf:type[@rdf:resource = 'http://purl.org/dc/terms/MediaTypeOrExtent'])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" has a dcat:mediaType property "<sch:value-of select="$id"/>" which is not a dct:MediaTypeOrExtent.
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Distribution "<sch:value-of select="$id"/>" has a dcat:mediaType  property "<sch:value-of select="$id"/>" which is a dct:MediaTypeOrExtent.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>92. dct:issued should be a literal typed as date or dateTime (value).</sch:title>
		<sch:rule context="//dcat:Distribution/dct:issued">
			<sch:let name="id" value="parent::node()/dct:title[1]/string()"/>
			<sch:let name="properDateTime" value=". castable as xs:date or . castable as xs:dateTime"/>
			<sch:assert test="$properDateTime = true()">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" has a dct:issued property which value "<sch:value-of select="./string()"/>" is not a proper xsd:date or xsd:dateTime.
			</sch:assert>
			<sch:report test="$properDateTime = true()">The dcat:Distribution "<sch:value-of select="$id"/>" has a dct:issued property which value "<sch:value-of select="./string()"/>" is a date or dateTime.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>92. dct:issued should be a literal typed as date or dateTime (type).</sch:title>
		<sch:rule context="//dcat:Distribution/dct:issued">
			<sch:let name="id" value="parent::node()/dct:title[1]/string()"/>
			<sch:let name="datatype" value="./@rdf:datatype = 'http://www.w3.org/2001/XMLSchema#date' or ./@rdf:datatype = 'http://www.w3.org/2001/XMLSchema#dateTime'"/>
			<sch:assert test="$datatype = true()">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" has a dct:issued property which value "<sch:value-of select="./string()"/>" is not typed (rdf:datatype) as xsd:date or xsd:dateTime.
			</sch:assert>
			<sch:report test="$datatype = true()">The dcat:Distribution "<sch:value-of select="$id"/>" has a dct:issued property which value "<sch:value-of select="./string()"/>" is typed (rdf:datatype) as xsd:date or xsd:dateTime.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>93. dct:rights should be a dct:RightsStatement.</sch:title>
		<sch:rule context="//dcat:Distribution/dct:rights">
			<sch:let name="id" value="parent::node()/dct:title[1]/string()"/>
			<sch:let name="wrongType" value="not(dct:RightsStatement | */rdf:type[@rdf:resource = 'http://purl.org/dc/terms/RightsStatement'])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" has a dct:rights  property "<sch:value-of select="$id"/>" which is not a dct:RightsStatement.
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Distribution "<sch:value-of select="$id"/>" has a dct:rights  property "<sch:value-of select="$id"/>" which is a dct:RightsStatement.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<!--95. dct:title should be a literal.-->
	<sch:pattern>
		<sch:title>96. dct:modified should be a literal typed as date or dateTime (value).</sch:title>
		<sch:rule context="//dcat:Distribution/dct:modified">
			<sch:let name="id" value="parent::node()/dct:title[1]/string()"/>
			<sch:let name="properDateTime" value=". castable as xs:date or . castable as xs:dateTime"/>
			<sch:assert test="$properDateTime = true()">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" has a dct:modified property which value "<sch:value-of select="./string()"/>" is not a proper xsd:date or xsd:dateTime.
			</sch:assert>
			<sch:report test="$properDateTime = true()">The dcat:Distribution "<sch:value-of select="$id"/>" has a dct:modified property which value "<sch:value-of select="./string()"/>" is a date or dateTime.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>96. dct:modified should be a literal typed as date or dateTime (type).</sch:title>
		<sch:rule context="//dcat:Distribution/dct:modified">
			<sch:let name="id" value="parent::node()/dct:title[1]/string()"/>
			<sch:let name="datatype" value="./@rdf:datatype = 'http://www.w3.org/2001/XMLSchema#date' or ./@rdf:datatype = 'http://www.w3.org/2001/XMLSchema#dateTime'"/>
			<sch:assert test="$datatype = true()">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" has a dct:modified property which value "<sch:value-of select="./string()"/>" is not typed (rdf:datatype) as xsd:date or xsd:dateTime.
			</sch:assert>
			<sch:report test="$datatype = true()">The dcat:Distribution "<sch:value-of select="$id"/>" has a dct:modified property which value "<sch:value-of select="./string()"/>" is typed (rdf:datatype) as xsd:date or xsd:dateTime.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>98. dct:type has maximum cardinality of 1 for Agent.</sch:title>
		<sch:rule context="//foaf:Agent">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="count" value="count(dct:type)"/>
			<sch:assert test="2 > $count">ERROR: The foaf:Agent "<sch:value-of select="$id"/>" has more than one dct:type property.
			</sch:assert>
			<sch:report test="2 > $count">The foaf:Agent "<sch:value-of select="$id"/>" has no more than one dct:type property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>99. dct:isPartOf has maximum cardinality of 1 for Catalog.</sch:title>
		<sch:rule context="//dcat:Catalog">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="count" value="count(dct:isPartOf)"/>
			<sch:assert test="2 > $count">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" has more than one dct:isPartOf property.
			</sch:assert>
			<sch:report test="2 > $count">The dcat:Catalog "<sch:value-of select="$id"/>" has no more than one dct:isPartOf property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>100. dct:accessRights has maximum cardinality of 1 for Dataset.</sch:title>
		<sch:rule context="//dcat:Dataset">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="count" value="count(dct:accessRights)"/>
			<sch:assert test="2 > $count">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has more than one dct:accessRights property.
			</sch:assert>
			<sch:report test="2 > $count">The dcat:Dataset "<sch:value-of select="$id"/>" has no more than one dct:accessRights property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>103. dct:type has maximum cardinality of 1 for Dataset.</sch:title>
		<sch:rule context="//dcat:Dataset">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="count" value="count(dct:type)"/>
			<sch:assert test="2 > $count">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has more than one dct:type property.
			</sch:assert>
			<sch:report test="2 > $count">The dcat:Dataset "<sch:value-of select="$id"/>" has no more than one dct:type property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>104. dct:type should be a skos:Concept.</sch:title>
		<sch:rule context="//dcat:Dataset/dct:type">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(skos:Concept | */rdf:type[resolve-QName(@rdf:resource, /*) = QName('http://www.w3.org/2004/02/skos/core#','Concept')])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has a type  "<sch:value-of select="$id"/>" which is not a skos:Concept.
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Dataset "<sch:value-of select="$id"/>" has a type  "<sch:value-of select="$id"/>" which is a skos:Concept.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>105. spdx:checksum has a maximum cardinality of 1 for Distribution.</sch:title>
		<sch:rule context="//dcat:Distribution">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="count" value="count(spdx:checksum)"/>
			<sch:assert test="2 > $count">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" has more than one spdx:checksum property.
			</sch:assert>
			<sch:report test="2 > $count">The dcat:Distribution "<sch:value-of select="$id"/>" has no more than one spdx:checksum property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>106. spdx:checksum should be a spdx:Checksum.</sch:title>
		<sch:rule context="//dcat:Distribution/spdx:checksum">
			<sch:let name="id" value="parent::node()/dct:title[1]/string()"/>
			<sch:let name="wrongType" value="not(spdx:Checksum| */rdf:type[resolve-QName(@rdf:resource, /*) = QName('http://spdx.org/rdf/terms#','spdx:Checksum')])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Distribution"<sch:value-of select="$id"/>" has a spdx:checksum property which is not a spdx:Checksum.
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Distribution "<sch:value-of select="$id"/>" has a spdx:checksum property which is a spdx:Checksum.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>107. dct:issued has a maximum cardinality of 1 for Distribution.</sch:title>
		<sch:rule context="//dcat:Distribution">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="count" value="count(dct:issued)"/>
			<sch:assert test="2 > $count">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" has more than one dct:issued property.
			</sch:assert>
			<sch:report test="2 > $count">The dcat:Distribution "<sch:value-of select="$id"/>" has no more than one dct:issued property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>108. dct:rights has a maximum cardinality of 1 for Distribution.</sch:title>
		<sch:rule context="//dcat:Distribution">
			<sch:let name="id" value="dct:title[1]/string()"/>
			<sch:let name="count" value="count(dct:rights)"/>
			<sch:assert test="2 > $count">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" has more than one dct:rights property.
			</sch:assert>
			<sch:report test="2 > $count">The dcat:Distribution "<sch:value-of select="$id"/>" has no more than one dct:rights property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>109. adms:status has maximum cardinality of 1 for Distribution.</sch:title>
		<sch:rule context="//dcat:Distribution">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="count" value="count(adms:status)"/>
			<sch:assert test="2 > $count">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" has more than one adms:status property.
			</sch:assert>
			<sch:report test="2 > $count">The dcat:Distribution "<sch:value-of select="$id"/>" has no more than one adms:status property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>110. adms:status should be a skos:Concept.</sch:title>
		<sch:rule context="//dcat:Distribution/adms:status">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(skos:Concept | */rdf:type[resolve-QName(@rdf:resource, /*) = QName('http://www.w3.org/2004/02/skos/core#','Concept')])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" has a adms:status property which is not a skos:Concept.
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Distribution "<sch:value-of select="$id"/>" has a adms:status property which is a skos:Concept.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>111. dct:modified has a maximum cardinality of 1 for Distribution.</sch:title>
		<sch:rule context="//dcat:Distribution">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="count" value="count(dct:modified)"/>
			<sch:assert test="2 > $count">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" has more than one dct:modified property.
			</sch:assert>
			<sch:report test="2 > $count">The dcat:Distribution "<sch:value-of select="$id"/>" has no more than one dct:modified property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>112. dcat:Catalog does not exist.</sch:title>
		<sch:rule context="/">
			<sch:let name="noCatalog" value="not(//dcat:Catalog)"/>
			<sch:assert test="$noCatalog = false()">ERROR: The mandatory class dcat:Catalog does not exist.
			</sch:assert>
			<sch:report test="$noCatalog = false()">The mandatory class dcat:Catalog exists.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>113. foaf:Agent does not exist.</sch:title>
		<sch:rule context="/">
			<sch:let name="noAgent" value="not(//foaf:Agent)"/>
			<sch:assert test="$noAgent = false()">ERROR: The mandatory class foaf:Agent does not exist.
			</sch:assert>
			<sch:report test="$noAgent = false()">The mandatory class foaf:Agent does exist.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>114. The mandatory class dcat:Dataset does not exist.</sch:title>
		<sch:rule context="/">
			<sch:let name="noDataset" value="not(//dcat:Dataset)"/>
			<sch:assert test="$noDataset = false()">ERROR: The mandatory class dcat:Dataset does not exist.</sch:assert>
			<sch:report test="$noDataset = false()">The mandatory class dcat:Dataset does exist.</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>115. dcat:theme should be a skos:Concept.</sch:title>
		<sch:rule context="//dcat:Dataset/dcat:theme">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(skos:Concept | */rdf:type[resolve-QName(@rdf:resource, /*) = QName('http://www.w3.org/2004/02/skos/core#','Concept')])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has a dcat:theme property which is not a skos:Concept.
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Dataset "<sch:value-of select="$id"/>" has a dcat:theme property which is a skos:Concept.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>118. dct:type has a maximum cardinality of 1 for dct:LicenseDocument.</sch:title>
		<sch:rule context="//dct:LicenseDocument">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="count" value="count(dct:type)"/>
			<sch:assert test="2 > $count">ERROR: The dct:LicenseDocument "<sch:value-of select="$id"/>" has more than one dct:type property.
			</sch:assert>
			<sch:report test="2 > $count">The dct:LicenseDocument "<sch:value-of select="$id"/>" has no more than one dct:type property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
<!-- 119.  foaf:primaryTopic is a required property for Catalog Record-->
<!-- 120.  dct:modified is a required property for Catalog Record-->
<!-- 121.  foaf:primaryTopic has a maximum cardinality of 1 for Catalog Record-->
	<sch:pattern>
		<sch:title>122. dct:modified has a maximum cardinality of 1 for dcat:CatalogRecord</sch:title>
		<sch:rule context="//dcat:CatalogRecord">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="countModified" value="count(dct:modified)"/>
			<sch:assert test="2 > $countModified">ERROR: The dcat:CatalogRecord resource with URI <sch:value-of select="$id"/> has more than one dct:modified property.
			</sch:assert>
			<sch:report test="2 > $countModified">The dcat:CatalogRecord resource with URI <sch:value-of select="$id"/> has no more than one dct:modified property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
<!-- 123.  dct:conformsTo has a maximum cardinality of 1 for Catalog Record-->
<!-- 124.  dct:conformsTo should be a resource-->
<!-- 125.  adms:status has a maximum cardinality of 1 for Catalog Record-->
<!-- 126.  adms:status should be a skos:Concept-->
<!-- 127.  dct:issued has a maximum cardinality of 1 for dcat:Catalog Record-->
<!-- 128.  dct:source should be a dcat:CatalogRecord-->
<!-- 129.  dct:source has a maximum cardinality of 1 for Catalog Record-->
<!-- 131.  dct:language should be a dct:LinguisticSystem-->
	<sch:pattern>
		<sch:title>132. spdx:algorithm is a required property for Checksum.</sch:title>
		<sch:rule context="//spdx:Checksum">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="noName" value="not(spdx:algorithm)"/>
			<sch:assert test="$noName = false()">ERROR: The spdx:Checksum "<sch:value-of select="$id"/>" does not have a spdx:algorithm property.
			</sch:assert>
			<sch:report test="$noName = false()">The spdx:Checksum "<sch:value-of select="$id"/>" has a spdx:algorithm property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>133. spdx:checksumValue is a required property for Checksum.</sch:title>
		<sch:rule context="//spdx:Checksum">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="noName" value="not(spdx:checksumValue)"/>
			<sch:assert test="$noName = false()">ERROR: The spdx:Checksum "<sch:value-of select="$id"/>" does not have a spdx:checksumValue property.
			</sch:assert>
			<sch:report test="$noName = false()">The spdx:Checksum "<sch:value-of select="$id"/>" has a spdx:checksumValue property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>134. spdx:algorithm has a maximum cardinality of 1 for spdx:Checksum.</sch:title>
		<sch:rule context="//spdx:Checksum">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="count" value="count(spdx:algorithm)"/>
			<sch:assert test="2 > $count">ERROR: The spdx:Checksum "<sch:value-of select="$id"/>" has more than one spdx:algorithm property.
			</sch:assert>
			<sch:report test="2 > $count">The spdx:Checksum "<sch:value-of select="$id"/>" has no more than one spdx:algorithm property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>135. spdx:checksumValue has a maximum cardinality of 1 for spdx:Checksum.</sch:title>
		<sch:rule context="//spdx:Checksum">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="count" value="count(spdx:checksumValue)"/>
			<sch:assert test="2 > $count">ERROR: The spdx:Checksum "<sch:value-of select="$id"/>" has more than one spdx:checksumValue property.
			</sch:assert>
			<sch:report test="2 > $count">The spdx:Checksum "<sch:value-of select="$id"/>" has no more than one spdx:checksumValue property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>136. schema:startDate has a maximum cardinality of 1 for dct:PeriodOfTime.</sch:title>
		<sch:rule context="//dct:PeriodOfTime">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="count" value="count(schema:startDate)"/>
			<sch:assert test="2 > $count">ERROR: The dct:PeriodOfTime "<sch:value-of select="$id"/>" has more than one schema:startDate property.
			</sch:assert>
			<sch:report test="2 > $count">The dct:PeriodOfTime "<sch:value-of select="$id"/>" has no more than one schema:startDate property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>137. schema:endDate has a maximum cardinality of 1 for dct:PeriodOfTime.</sch:title>
		<sch:rule context="//dct:PeriodOfTime">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="count" value="count(schema:startDate)"/>
			<sch:assert test="2 > $count">ERROR: The dct:PeriodOfTime "<sch:value-of select="$id"/>" has more than one schema:endDate property.
			</sch:assert>
			<sch:report test="2 > $count">The dct:PeriodOfTime "<sch:value-of select="$id"/>" has no more than one schema:endDate property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>138. dct:license should be a dct:LicenseDocument.</sch:title>
		<sch:rule context="//dcat:Catalog/dct:license">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(dct:LicenseDocument | */rdf:type[@rdf:resource = 'http://purl.org/dc/terms/LicenseDocument'])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:license property which is not a dct:LicenseDocument.
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:license property which is a dct:LicenseDocument.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>139. dcat:themeTaxonomy should be a skos:ConceptScheme.</sch:title>
		<sch:rule context="//dcat:Catalog/dcat:themeTaxonomy">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(skos:ConceptScheme | */rdf:type[resolve-QName(@rdf:resource, /*) = QName('http://www.w3.org/2004/02/skos/core#','ConceptScheme')])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" has a dcat:themeTaxonomy property which is not a skos:ConceptScheme.
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Catalog "<sch:value-of select="$id"/>" has a dcat:themeTaxonomy property which is a skos:ConceptScheme.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>140. dct:hasPart should be a dcat:Catalog.</sch:title>
		<sch:rule context="//dcat:Catalog/dct:hasPart">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(dcat:Catalog | */rdf:type[resolve-QName(@rdf:resource, /*) = QName('http://www.w3.org/ns/dcat#','Catalog')])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:hasPart property which is not a dcat:Catalog.
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:hasPart property which is a dcat:Catalog.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>141. dct:isPartOf should be a dcat:Catalog.</sch:title>
		<sch:rule context="//dcat:Catalog/dct:isPartOf">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(dcat:Catalog | */rdf:type[resolve-QName(@rdf:resource, /*) = QName('http://www.w3.org/ns/dcat#','Catalog')])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:isPartOf property which is not a dcat:Catalog.
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:isPartOf property which is a dcat:Catalog.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>150. dct:accessRights should be a dct:RightsStatement.</sch:title>
		<sch:rule context="//dcat:Dataset/dct:accessRights">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(dct:RightsStatement | */rdf:type[@rdf:resource = 'http://purl.org/dc/terms/RightsStatement'])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:accessRights property which is not a dct:RightsStatement
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:accessRights property which is a dct:RightsStatement.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>151. foaf:page should be a foaf:Document.</sch:title>
		<sch:rule context="//dcat:Dataset/foaf:page">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(foaf:Document | */rdf:type[resolve-QName(@rdf:resource, /*) = QName('http://xmlns.com/foaf/0.1/','Document')])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has a foaf:page property which is not a foaf:Document
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Dataset "<sch:value-of select="$id"/>" has a foaf:page property which is a foaf:Document.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>152. dct:hasVersion should be a dcat:Dataset.</sch:title>
		<sch:rule context="//dcat:Dataset/dct:hasVersion">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(dcat:Dataset | */rdf:type[resolve-QName(@rdf:resource, /*) = QName('http://www.w3.org/ns/dcat#','Dataset')])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:hasVersion property which is not a dcat:Dataset
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:hasVersion property which is a dcat:Dataset.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>153. dct:isVersionOf should be a dcat:Dataset.</sch:title>
		<sch:rule context="//dcat:Dataset/dct:isVersionOf">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(dcat:Dataset | */rdf:type[resolve-QName(@rdf:resource, /*) = QName('http://www.w3.org/ns/dcat#','Dataset')])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:isVersionOf property which is not a dcat:Dataset
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:isVersionOf property which is a dcat:Dataset.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>154. dct:provenance should be a dct:ProvenanceStatement.</sch:title>
		<sch:rule context="//dcat:Dataset/dct:provenance">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(dct:ProvenanceStatement | */rdf:type[@rdf:resource = 'http://purl.org/dc/terms/ProvenanceStatement'])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:provenance property which is not a dct:ProvenanceStatement
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:provenance property which is a dct:ProvenanceStatement.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>155. dct:relation should be a resource.</sch:title>
		<sch:rule context="//dcat:Dataset/dct:relation">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="resource" value="(* and not(*/@rdf:about)) or (@rdf:resource and @rdf:resource castable as xs:anyURI) or (*/@rdf:about and */@rdf:about castable as xs:anyURI)"/>
			<sch:assert test="$resource = true()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:relation property that is not a resource.
			</sch:assert>
			<sch:report test="$resource = true()">The dcat:Dataset "<sch:value-of select="$id"/>" has  a dct:relation property that is a resource.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>156. adms:sample should be a dcat:Distribution.</sch:title>
		<sch:rule context="//dcat:Dataset/adms:sample">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(dcat:Distribution | */rdf:type[resolve-QName(@rdf:resource, /*) = QName('http://www.w3.org/ns/dcat#','Distribution')])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:isVersionOf property which is not a dcat:Distribution
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:isVersionOf property which is a dcat:Distribution.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>157. dct:source should be a dcat:Dataset.</sch:title>
		<sch:rule context="//dcat:Dataset/dct:source">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(dcat:Dataset | */rdf:type[resolve-QName(@rdf:resource, /*) = QName('http://www.w3.org/ns/dcat#','Dataset')])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:source property which is not a dcat:Dataset
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Dataset "<sch:value-of select="$id"/>" has a dct:source property which is a dcat:Dataset.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>158. dcat:byteSize has a maximum cardinality of 1 for Distribution.</sch:title>
		<sch:rule context="//dcat:Distribution">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="count" value="count(dcat:byteSize)"/>
			<sch:assert test="2 > $count">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" has more than one dcat:byteSize property.
			</sch:assert>
			<sch:report test="2 > $count">The dcat:Distribution "<sch:value-of select="$id"/>" has no more than one dcat:byteSize property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>159. foaf:page should be a foaf:Document.</sch:title>
		<sch:rule context="//dcat:Distribution/foaf:page">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(foaf:Document | */rdf:type[resolve-QName(@rdf:resource, /*) = QName('http://xmlns.com/foaf/0.1/','Document')])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Distribution"<sch:value-of select="$id"/>" has a foaf:page property which is not a foaf:Document
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Distribution "<sch:value-of select="$id"/>" has a foaf:page property which is a foaf:Document.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>160. dct:language should be a dct:LinguisticSystem.</sch:title>
		<sch:rule context="//dcat:Distribution/dct:language">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(dct:LinguisticSystem | */rdf:type[@rdf:resource = 'http://purl.org/dc/terms/LinguisticSystem'])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" has a dct:language  property that is not a dct:LinguisticSystem.
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Distribution "<sch:value-of select="$id"/>" has a dct:language property that is a dct:LinguisticSystem.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>161. dct:conformsTo should be a dct:Standard.</sch:title>
		<sch:rule context="//dcat:Distribution/dct:conformsTo">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(dct:Standard | */rdf:type[@rdf:resource = 'http://purl.org/dc/terms/Standard'])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" has a dct:conformsTo  property that is not a dct:Standard.
			</sch:assert>
			<sch:report test="$wrongType = false()">The dcat:Distribution "<sch:value-of select="$id"/>" has a dct:conformsTo property that is a dct:Standard.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>162. dcat:mediaType has a maximum cardinality of 1 for Distribution.</sch:title>
		<sch:rule context="//dcat:Distribution">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="count" value="count(dcat:mediaType)"/>
			<sch:assert test="2 > $count">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" has more than one dcat:mediaType property.
			</sch:assert>
			<sch:report test="2 > $count">The dcat:Distribution "<sch:value-of select="$id"/>" has no more than one dcat:mediaType property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>163. The recommended class dcat:Distribution does not exist.</sch:title>
		<sch:rule context="/">
			<sch:let name="noDistribution" value="not(//dcat:Distribution)"/>
			<sch:assert test="$noDistribution = false()">ERROR: The recommended class dcat:Distribution does not exist.
			</sch:assert>
			<sch:report test="$noDistribution = false()">The recommended class dcat:Distribution does exist.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>164. spdx:checksumValue should be literal typed as hexBinary (value).</sch:title>
		<sch:rule context="//spdx:Checksum/spdx:checksumValue">
			<sch:let name="id" value="parent::node()/dct:title[1]/string()"/>
			<sch:let name="datatype" value=". castable as xs:hexBinary"/>
			<sch:assert test="$datatype = true()">ERROR: The spdx:Checksum "<sch:value-of select="$id"/>" has a dcat:checksumValue property value that is not a valid xsd:hexBinary.
			</sch:assert>
			<sch:report test="$datatype = true()">The spdx:Checksum "<sch:value-of select="$id"/>" has a dcat:byteSize property value that is a valid xsd:hexBinary.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>164. spdx:checksumValue should be literal typed as hexBinary (datatype).</sch:title>
		<sch:rule context="//spdx:Checksum/spdx:checksumValue">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="datatype" value="./@rdf:datatype = xs:hexBinary"/>
			<sch:assert test="$datatype = false()">ERROR: The spdx:Checksum "<sch:value-of select="$id"/>" has a dcat:checksumValue property that is not typed as an xsd:hexBinary.
			</sch:assert>
			<sch:report test="$datatype = false()">The spdx:Checksum "<sch:value-of select="$id"/>" has a dcat:byteSize property that is typed as an xsd:hexBinary.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>165. dct:type should be a skos:Concept.</sch:title>
		<sch:rule context="//dct:LicenseDocument/dct:type">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="wrongType" value="not(skos:Concept | */rdf:type[resolve-QName(@rdf:resource, /*) = QName('http://www.w3.org/2004/02/skos/core#','Concept')])"/>
			<sch:assert test="$wrongType = false()">ERROR: The dct:LicenseDocument "<sch:value-of select="$id"/>" has a dct:type property which is not a skos:Concept.
			</sch:assert>
			<sch:report test="$wrongType = false()">The dct:LicenseDocument "<sch:value-of select="$id"/>" has a dct:type property which is a skos:Concept.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>169. skos:prefLabel is a required property for skos:Concept.</sch:title>
		<sch:rule context="//skos:Concept[not(name(..) = ('dct:type','dcat:theme','dct:format'))]">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="value" value="skos:prefLabel[@xml:lang='nl']"/>
			<sch:let name="missingProperty" value="not($value!='')"/>
			<sch:assert test="$missingProperty = false()">ERROR: The <sch:value-of select="name(../..)"/>/<sch:value-of select="name(..)"/> does not have a skos:prefLabel value.
			</sch:assert>
			<sch:report test="$missingProperty = false()">The <sch:value-of select="name(../..)"/>/<sch:value-of select="name(..)"/> does have a skos:prefLabel with value <sch:value-of select="$value"/>.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>169. skos:prefLabel is a required property for skos:Concept.</sch:title>
		<sch:rule context="//skos:Concept">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="missingProperty" value="not(skos:prefLabel)"/>
			<sch:assert test="$missingProperty = false()">ERROR: The skos:Concept "<sch:value-of select="$id"/>" does not have a skos:prefLabel property.
			</sch:assert>
			<sch:report test="$missingProperty = false()">The skos:Concept "<sch:value-of select="$id"/>" has a skos:prefLabel property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>171. dct:title is a required property for Category scheme.</sch:title>
		<sch:rule context="//skos:ConceptScheme">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="missingProperty" value="not(dct:title)"/>
			<sch:assert test="$missingProperty = false()">ERROR: The skos:ConceptScheme "<sch:value-of select="$id"/>" should have a dct:title property.
			</sch:assert>
			<sch:report test="$missingProperty = false()">The skos:ConceptScheme "<sch:value-of select="$id"/>" has a dct:title property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<!--172. dct:title should be a literal.-->
	<!--173. skos:prefLabel should be a literal.-->
  <sch:pattern>
    <sch:title>174. schema:startDate should be a literal typed as date or dateTime (value)</sch:title>
    <sch:rule context="//dct:PeriodOfTime/schema:startDate">
      <sch:let name="id" value="parent::node()/@rdf:about/string()"/>
      <sch:let name="startDateTime" value="string() != '' and (. castable as xs:date or . castable as xs:dateTime)"/>
      <sch:assert test="$startDateTime = true()">
        ERROR: The dct:PeriodOfTime "<sch:value-of select="$id"/>" has a schema:startDate property which value "<sch:value-of select="./string()"/>" is not a date or dateTime.
      </sch:assert>
      <sch:report test="$startDateTime = true()">
        The dct:PeriodOfTime "<sch:value-of select="$id"/>" has a schema:startDate property which value "<sch:value-of select="./string()"/>" is a date or dateTime.
      </sch:report>
    </sch:rule>
  </sch:pattern>
  <sch:pattern>
	<sch:title>174. schema:startDate should be a literal typed as date or dateTime (type).</sch:title>
	<sch:rule context="//dct:PeriodOfTime/schema:startDate">
		<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
		<sch:let name="datatype" value="./@rdf:datatype = 'http://www.w3.org/2001/XMLSchema#date' or ./@rdf:datatype = 'http://www.w3.org/2001/XMLSchema#dateTime'"/>
		<sch:assert test="$datatype = true()">ERROR: The dct:PeriodOfTime "<sch:value-of select="$id"/>" has a schema:startDate property which value "<sch:value-of select="./string()"/>" is not typed (rdf:datatype) as xsd:date or xsd:dateTime.
		</sch:assert>
		<sch:report test="$datatype = true()">The dct:PeriodOfTime "<sch:value-of select="$id"/>" has a schema:startDate property which value "<sch:value-of select="./string()"/>" is typed (rdf:datatype) as xsd:date or xsd:dateTime.
		</sch:report>
	</sch:rule>
  </sch:pattern>
  <sch:pattern>
    <sch:title>175. schema:endDate should be a literal typed as date or dateTime (value)</sch:title>
    <sch:rule context="//dct:PeriodOfTime/schema:endDate">
      <sch:let name="id" value="parent::node()/@rdf:about/string()"/>
      <sch:let name="endDateTime" value="string() != '' and (. castable as xs:date or . castable as xs:dateTime)"/>
      <sch:assert test="$endDateTime = true()">
        ERROR: The dct:PeriodOfTime "<sch:value-of select="$id"/>" has a schema:endDate property which value "<sch:value-of select="./string()"/>" is not a date or dateTime.
      </sch:assert>
      <sch:report test="$endDateTime = true()">
        The dct:PeriodOfTime "<sch:value-of select="$id"/>" has a schema:endDate property which value "<sch:value-of select="./string()"/>" is a date or dateTime.
      </sch:report>
    </sch:rule>
  </sch:pattern>
  <sch:pattern>
	<sch:title>175. schema:endDate should be a literal typed as date or dateTime (type).</sch:title>
	<sch:rule context="//dct:PeriodOfTime/schema:endDate">
		<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
		<sch:let name="datatype" value="./@rdf:datatype = 'http://www.w3.org/2001/XMLSchema#date' or ./@rdf:datatype = 'http://www.w3.org/2001/XMLSchema#dateTime'"/>
		<sch:assert test="$datatype = true()">ERROR: The dct:PeriodOfTime "<sch:value-of select="$id"/>" has a schema:endDate property which value "<sch:value-of select="./string()"/>" is not typed (rdf:datatype) as xsd:date or xsd:dateTime.
		</sch:assert>
		<sch:report test="$datatype = true()">The dct:PeriodOfTime "<sch:value-of select="$id"/>" has a schema:endDate property which value "<sch:value-of select="./string()"/>" is typed (rdf:datatype) as xsd:date or xsd:dateTime.
		</sch:report>
	</sch:rule>
  </sch:pattern>
	<sch:pattern>
		<sch:title>176. skos:notation has maximum cardinality of 1 for adms:Identifier.</sch:title>
		<sch:rule context="//adms:Identifier">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="count" value="count(skos:notation)"/>
			<sch:assert test="2 > $count">ERROR: The adms:Identifier "<sch:value-of select="$id"/>" has more than one skos:notation property.
			</sch:assert>
			<sch:report test="2 > $count">The adms:Identifier "<sch:value-of select="$id"/>" has no more than one skos:notation property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>500. dcat:catalog property is a rdf:resource.</sch:title>
		<sch:rule context="//dcat:catalog">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="resource" value="(* and not(*/@rdf:about)) or (@rdf:resource and @rdf:resource castable as xs:anyURI) or (*/@rdf:about and */@rdf:about castable as xs:anyURI)"/>
			<sch:assert test="$resource = true()">A dcat:catalog property has a value that is not a resource.
			</sch:assert>
			<sch:report test="$resource = true()">A dcat:catalog property has a value that is a resource.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>501. dcat:dataset property is a rdf:resource.</sch:title>
		<sch:rule context="//dcat:dataset">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="resource" value="(* and not(*/@rdf:about)) or (@rdf:resource and @rdf:resource castable as xs:anyURI) or (*/@rdf:about and */@rdf:about castable as xs:anyURI)"/>
			<sch:assert test="$resource = true()">A dcat:dataset property has a value that is not a resource.
			</sch:assert>
			<sch:report test="$resource = true()">A dcat:dataset property has a value that is a resource.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>502. dcat:distribution property is a rdf:resource.</sch:title>
		<sch:rule context="//dcat:distribution">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="resource" value="(* and not(*/@rdf:about)) or (@rdf:resource and @rdf:resource castable as xs:anyURI) or (*/@rdf:about and */@rdf:about castable as xs:anyURI)"/>
			<sch:assert test="$resource = true()">A dcat:distribution property has a value that is not a resource.
			</sch:assert>
			<sch:report test="$resource = true()">A dcat:distribution property has a value that is a resource.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>503. dct:publisher property is a rdf:resource.</sch:title>
		<sch:rule context="//dct:publisher">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="resource" value="(* and not(*/@rdf:about)) or (@rdf:resource and @rdf:resource castable as xs:anyURI) or (*/@rdf:about and */@rdf:about castable as xs:anyURI)"/>
			<sch:assert test="$resource = true()">A dct:publisher property has a value that is not a resource.
			</sch:assert>
			<sch:report test="$resource = true()">A dct:publisher property has a value that is a resource.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>504. dcat:record property is a rdf:resource.</sch:title>
		<sch:rule context="//dcat:record">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="resource" value="(* and not(*/@rdf:about)) or (@rdf:resource and @rdf:resource castable as xs:anyURI) or (*/@rdf:about and */@rdf:about castable as xs:anyURI)"/>
			<sch:assert test="$resource = true()">A dcat:record property has a value that is not a resource.
			</sch:assert>
			<sch:report test="$resource = true()">A dcat:record property has a value that is a resource.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>504. dcat:record property is a rdf:resource.</sch:title>
		<sch:rule context="//dcat:record">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="resource" value="(* and not(*/@rdf:about)) or (@rdf:resource and @rdf:resource castable as xs:anyURI) or (*/@rdf:about and */@rdf:about castable as xs:anyURI)"/>
			<sch:assert test="$resource = true()">A dcat:record property has a value that is not a resource.
			</sch:assert>
			<sch:report test="$resource = true()">A dcat:record property has a value that is a resource.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>505. dct:license property is a rdf:resource.</sch:title>
		<sch:rule context="//dct:license">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="resource" value="(* and not(*/@rdf:about)) or (@rdf:resource and @rdf:resource castable as xs:anyURI) or (*/@rdf:about and */@rdf:about castable as xs:anyURI)"/>
			<sch:assert test="$resource = true()">A dct:license property has a value that is not a resource.
			</sch:assert>
			<sch:report test="$resource = true()">A dct:license property has a value that is a resource.
			</sch:report>
		</sch:rule>
	</sch:pattern>
</sch:schema>

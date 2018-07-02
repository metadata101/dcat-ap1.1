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

This script was written by GIM. 

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
			<sch:let name="noName" value="not(foaf:name)"/>
			<sch:assert test="$noName = false()">The foaf:Agent "<sch:value-of select="$id"/>" does not have a foaf:name property.
			</sch:assert>
			<sch:report test="$noName = false()">The foaf:Agent "<sch:value-of select="$id"/>" has a foaf:name property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>1. The foaf:name property should be a literal.</sch:title>
		<sch:rule context="//foaf:Agent/foaf:name">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="noNameLiteral" value="exists(.[child::*[node-name(.) != QName('http://www.fao.org/geonetwork','element')]])"/>
			<sch:assert test="$noNameLiteral = false()">ERROR: The foaf:Agent "<sch:value-of select="$id"/>" has a foaf:name property which value "<sch:value-of select="string-join(.[child::*]//*/name(),'|') "/>" is not a literal.
			</sch:assert>
			<sch:report test="$noNameLiteral = false()">The foaf:Agent "<sch:value-of select="$id"/>" has a foaf:name property which is a literal "<sch:value-of select="."/>".</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>4. dcat:dataset is a required property for Catalog.</sch:title>
		<sch:rule context="//dcat:Catalog">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="noDataset" value="not(dcat:dataset)"/>
			<sch:assert test="$noDataset = false()">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" should have a dcat:dataset property.
			</sch:assert>
			<sch:report test="$noDataset = false()">The dcat:Catalog "<sch:value-of select="$id"/>" has a dcat:dataset property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>5. dcat:dataset should be a dcat:Dataset.</sch:title>
		<sch:rule context="//dcat:Catalog/dcat:dataset">
			<sch:let name="Catalogid" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="id" value="*/@rdf:about/string()"/>
			<sch:let name="noDatasetType" value="not(dcat:Dataset | */dct:type[resolve-QName(@rdf:resource, /*) = QName('http://www.w3.org/ns/dcat#','Dataset')])"/>
			<sch:assert test="$noDatasetType = false()">ERROR: The dcat:Catalog "<sch:value-of select="$Catalogid"/>" has a member  "<sch:value-of select="$id"/>" which is not a dcat:Dataset.
			</sch:assert>
			<sch:report test="$noDatasetType = false()">The dcat:Catalog "<sch:value-of select="$Catalogid"/>" has a member  "<sch:value-of select="$id"/>" which is a dcat:Dataset.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>6. dct:description is a required property for Catalog.</sch:title>
		<sch:rule context="//dcat:Catalog">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="noDescription" value="not(dct:description)"/>
			<sch:assert test="$noDescription = false()">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" does not have a dct:description.
			</sch:assert>
			<sch:report test="$noDescription = false()">The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:description.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>7. dct:description should be a literal.</sch:title>
		<sch:rule context="//dcat:Catalog/dct:description">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="noDescriptionLiteral" value="exists(.[child::*[node-name(.) != QName('http://www.fao.org/geonetwork','element')]])"/>
			<sch:assert test="$noDescriptionLiteral = false()">ERROR: In dcat:Catalog "<sch:value-of select="$id"/>" the dct:description property "<sch:value-of select="string-join(//.[child::*]//*/name(),'|') "/>," is not a literal.</sch:assert>
			<sch:report test="$noDescriptionLiteral = false()">In dcat:Catalog "<sch:value-of select="$id"/>" the dct:description property "<sch:value-of select="."/>," is a literal.</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>11. dct:publisher should be a foaf:Agent.</sch:title>
		<sch:rule context="//dcat:Catalog/dct:publisher">
			<sch:let name="Catalogid" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="id" value="*/@rdf:about/string()"/>
			<sch:let name="noAgent" value="not(foaf:Agent | */rdf:type[resolve-QName(@rdf:resource, /*) = QName('http://xmlns.com/foaf/0.1/','Agent')])"/>
			<sch:assert test="$noAgent = false()">ERROR: The dcat:Catalog "<sch:value-of select="$Catalogid"/>" has a dct:publisher  "<sch:value-of select="$id"/>" which is not a foaf:Agent.
			</sch:assert>
			<sch:report test="$noAgent = false()">The dcat:Catalog "<sch:value-of select="$Catalogid"/>" has a dct:publisher  "<sch:value-of select="$id"/>" which is a foaf:Agent.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>12. dct:title is a required property for Catalog.</sch:title>
		<sch:rule context="//dcat:Catalog">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="noTitle" value="not(dct:title)"/>
			<sch:assert test="$noTitle = false()">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" does not have a dct:title.
			</sch:assert>
			<sch:report test="$noTitle = false()">The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:title "<sch:value-of select="dct:title[0]/text()"/>".
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>13. dct:title should be a literal.</sch:title>
		<sch:rule context="//dcat:Catalog/dct:title">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="noTitleLiteral" value="exists(.[child::*[node-name(.) != QName('http://www.fao.org/geonetwork','element')]])"/>
			<sch:assert test="$noTitleLiteral = false()">ERROR: In dcat:Catalog "<sch:value-of select="$id"/>" the dct:title property "<sch:value-of select="string-join(//.[child::*]//*/name(),'|') "/>," is not a literal.</sch:assert>
			<sch:report test="$noTitleLiteral = false()">In dcat:Catalog "<sch:value-of select="$id"/>" the dct:title property "<sch:value-of select="."/>," is a literal.</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>15. foaf:homepage has a maximum cardinality of 1 for Catalog.</sch:title>
		<sch:rule context="//dcat:Catalog">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="countHomepage" value="count(foaf:homepage)"/>
			<sch:assert test="2 > $countHomepage">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" has more than one foaf:homepage property.
			</sch:assert>
			<sch:report test="2 > $countHomepage">The dcat:Catalog "<sch:value-of select="$id"/>" has maximally one foaf:homepage property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>17. foaf:homepage should be a foaf:Document.</sch:title>
		<sch:rule context="//dcat:Catalog/foaf:homepage">
			<sch:let name="Catalogid" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="id" value="*/@rdf:about/string()"/>
			<sch:let name="noDocument" value="not(foaf:Document | */rdf:type[resolve-QName(@rdf:resource, /*) = QName('http://xmlns.com/foaf/0.1/','Document')])"/>
			<sch:assert test="$noDocument = false()">ERROR: The dcat:Catalog "<sch:value-of select="$Catalogid"/>" has a foaf:homepage  "<sch:value-of select="$id"/>" which is not a foaf:Document.
			</sch:assert>
			<sch:report test="$noDocument = false()">The dcat:Catalog "<sch:value-of select="$Catalogid"/>" has a foaf:homepage  "<sch:value-of select="$id"/>" which is a foaf:Document.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>20. dct:language should be a dct:LinguisticSystem.</sch:title>
		<sch:rule context="//dcat:Catalog/dct:language">
			<sch:let name="Catalogid" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="id" value="*/@rdf:about/string()"/>
			<sch:let name="noLinguisticSystem" value="not(dct:LinguisticSystem | */rdf:type[resolve-QName(@rdf:resource, /*) = QName('http://purl.org/dc/terms/','LinguisticSystem')])"/>
			<sch:assert test="$noLinguisticSystem = false()">ERROR: The dcat:Catalog "<sch:value-of select="$Catalogid"/>" has a dct:language  "<sch:value-of select="$id"/>" which is not a dct:LinguisticSystem.
			</sch:assert>
			<sch:report test="$noLinguisticSystem = false()">The dcat:Catalog "<sch:value-of select="$Catalogid"/>" has a dct:language  "<sch:value-of select="$id"/>" which is a dct:LinguisticSystem.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>23. dct:license has a maximum cardinality of 1 for Catalog.</sch:title>
		<sch:rule context="//dcat:Catalog">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="countLicense" value="count(dct:license)"/>
			<sch:assert test="2 > $countLicense">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" has more than one dct:license property.
			</sch:assert>
			<sch:report test="2 > $countLicense">The dcat:Catalog "<sch:value-of select="$id"/>" has no more than one dct:license property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>26. dct:issued has a maximum cardinality of 1 for Catalog.</sch:title>
		<sch:rule context="//dcat:Catalog">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="countIssued" value="count(dct:issued)"/>
			<sch:assert test="2 > $countIssued">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" has more than one dct:issued property.
			</sch:assert>
			<sch:report test="2 > $countIssued">The dcat:Catalog "<sch:value-of select="$id"/>" has no more than one dct:issued property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>30. dcat:record should be a dcat:CatalogRecord.</sch:title>
		<sch:rule context="//dcat:Catalog/dcat:record">
			<sch:let name="Catalogid" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="id" value="*/@rdf:about/string()"/>
			<sch:let name="noCatalogRecord" value="not(dcat:CatalogRecord | */rdf:type[resolve-QName(@rdf:resource, /*) = QName('http://www.w3.org/ns/dcat#','CatalogRecord')])"/>
			<sch:assert test="$noCatalogRecord = false()">ERROR: The dcat:Catalog "<sch:value-of select="$Catalogid"/>" has a dcat:record  "<sch:value-of select="$id"/>" which is not a dcat:CatalogRecord.
			</sch:assert>
			<sch:report test="$noCatalogRecord = false()">The dcat:Catalog "<sch:value-of select="$Catalogid"/>" has a dcat:record  "<sch:value-of select="$id"/>" which is a dcat:CatalogRecord.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>32. dct:modified should be a literal typed as date or dateTime.</sch:title>
		<sch:rule context="//dcat:Catalog/dct:modified">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="modifiedDateTime" value=". castable as xs:date or . castable as xs:dateTime"/>
			<sch:assert test="$modifiedDateTime = true()">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:modified property which value "<sch:value-of select="./string()"/>" is not a date or dateTime.
			</sch:assert>
			<sch:report test="$modifiedDateTime = true()">The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:modified property which value "<sch:value-of select="./string()"/>" is a date or dateTime.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>33. dct:modified has a maximum cardinality of 1 for Catalog.</sch:title>
		<sch:rule context="//dcat:Catalog">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="countModified" value="count(dct:modified)"/>
			<sch:assert test="2 > $countModified">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" has more than one dct:modified property.
			</sch:assert>
			<sch:report test="2 > $countModified">The dcat:Catalog "<sch:value-of select="$id"/>" has no more than one dct:modified property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
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
	<sch:pattern>
		<sch:title>38. dct:description should be a literal.</sch:title>
		<sch:rule context="//dcat:Dataset/dct:description">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="noDescriptionLiteral" value="exists(.[child::*[node-name(.) != QName('http://www.fao.org/geonetwork','element')]])"/>
			<sch:assert test="$noDescriptionLiteral = false()">ERROR: In dcat:Dataset "<sch:value-of select="$id"/>" the dct:description property "<sch:value-of select="string-join(//.[child::*]//*/name(),'|') "/>," is not a literal.</sch:assert>
			<sch:report test="$noDescriptionLiteral = false()">In dcat:Dataset "<sch:value-of select="$id"/>" the dct:description property "<sch:value-of select="."/>," is a literal.</sch:report>
		</sch:rule>
	</sch:pattern>
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
	<sch:pattern>
		<sch:title>40. dct:title should be a literal.</sch:title>
		<sch:rule context="//dcat:Dataset/dct:title">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="noTitleLiteral" value="exists(.[child::*[node-name(.) != QName('http://www.fao.org/geonetwork','element')]])"/>
			<sch:assert test="$noTitleLiteral = false()">ERROR: In dcat:Dataset "<sch:value-of select="$id"/>" the dct:title property "<sch:value-of select="string-join(//dct:title[child::*]//*/name(),'|') "/>," is not a literal.</sch:assert>
			<sch:report test="$noTitleLiteral = false()">In dcat:Dataset "<sch:value-of select="$id"/>" the dct:title property "<sch:value-of select="."/>," is a literal.</sch:report>
		</sch:rule>
	</sch:pattern>
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
			<sch:let name="countPublisher" value="count(dct:publisher)"/>
			<sch:assert test="2 > $countPublisher">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" has more than one dct:publisher property.
			</sch:assert>
			<sch:report test="2 > $countPublisher">The dcat:Dataset "<sch:value-of select="$id"/>" has no more than one dct:publisher property.
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
		<sch:title>82. dct:description should be a literal.</sch:title>
		<sch:rule context="//dcat:Distribution/dct:description">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="descriptionLiteral" value="exists(.[child::*[node-name(.) != QName('http://www.fao.org/geonetwork','element')]])"/>
			<sch:assert test="$descriptionLiteral = false()">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" has a dct:description property which value "<sch:value-of select="string-join(.[child::*]//*/name(),'|') "/>" is not a literal.
			</sch:assert>
			<sch:report test="$descriptionLiteral = false()">The dcat:Distribution "<sch:value-of select="$id"/>" has a dct:description property which value "<sch:value-of select="string-join(.[child::*]//*/name(),'|') "/>" is a literal.
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
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="countPublisher" value="count(dct:license)"/>
			<sch:assert test="2 > $countPublisher">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" has more than one dct:license property.
			</sch:assert>
			<sch:report test="2 > $countPublisher">The dcat:Distribution "<sch:value-of select="$id"/>" has no more than one dct:license property.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>95. dct:title should be a literal.</sch:title>
		<sch:rule context="//dcat:Distribution/dct:title">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="titleLiteral" value="exists(.[child::*[node-name(.) != QName('http://www.fao.org/geonetwork','element')]])"/>
			<sch:assert test="$titleLiteral = false()">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" has a dct:title property which value "<sch:value-of select="string-join(.[child::*]//*/name(),'|') "/>" is not a literal.
			</sch:assert>
			<sch:report test="$titleLiteral = false()">The dcat:Distribution "<sch:value-of select="$id"/>" has a dct:title property which value "<sch:value-of select="string-join(.[child::*]//*/name(),'|') "/>" is a literal.
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
	<!-- Rule_ID:118  (seems wrong in DCATv1.1 !) -->
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
	<sch:pattern>
		<sch:title>138. dct:license should be a dct:LicenseDocument.</sch:title>
		<sch:rule context="//dcat:Catalog/dct:license">
			<sch:let name="Catalogid" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="types" value="string-join(('http://purl.org/dc/terms/LicenseDocument'),'|')"/>
			<sch:let name="id" value="*/@rdf:about/string()"/>
			<sch:let name="LicenseDocument" value="exists(*[contains($types,  concat(namespace-uri-from-QName(node-name(.)),local-name-from-QName(node-name(.))))]) or exists(*/rdf:type[contains($types,  concat(namespace-uri-from-QName(resolve-QName(@rdf:resource,/*)),local-name-from-QName(resolve-QName(@rdf:resource,/*))))])"/>
			<sch:assert test="$LicenseDocument = true()">ERROR: The dcat:Catalog "<sch:value-of select="$Catalogid"/>" has a dct:license "<sch:value-of select="$id"/>" which is not a dct:LicenseDocument.
			</sch:assert>
			<sch:report test="$LicenseDocument = true()">The dcat:Catalog "<sch:value-of select="$Catalogid"/>" has a dct:license "<sch:value-of select="$id"/>" which is a dct:LicenseDocument.
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
</sch:schema>

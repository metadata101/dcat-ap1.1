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

Schematron validation for DCAT - Flemish Government.

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
		<sch:title>8. dct:publisher is a required property for Catalog.</sch:title>
		<sch:rule context="//dcat:Catalog">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="noPublisher" value="not(dct:publisher)"/>
			<sch:assert test="$noPublisher = false()">ERROR: The dcat:Catalog "<sch:value-of select="$id"/>" does not have a dct:publisher.
			</sch:assert>
			<sch:report test="$noPublisher = false()">The dcat:Catalog "<sch:value-of select="$id"/>" has a dct:publisher with id "<sch:value-of select="dct:publisher/*/@rdf:about/string()"/>".
			</sch:report>
		</sch:rule>
	</sch:pattern>
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
		<sch:title>45. dcat:distribution is a required property for Dataset.</sch:title>
		<sch:rule context="//dcat:Dataset">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="noDistribution" value="not(dcat:distribution )"/>
			<sch:assert test="$noDistribution = false()">ERROR: The dcat:Dataset "<sch:value-of select="$id"/>" does not have a dcat:distribution.
			</sch:assert>
			<sch:report test="$noDistribution = false()">The dcat:Dataset "<sch:value-of select="$id"/>" has a dcat:distribution with id  "<sch:value-of select="dcat:distribution/*/@rdf:about/string()"/>".
			</sch:report>
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
		<sch:title>81. dct:description is a required property for Distribution.</sch:title>
		<sch:rule context="//dcat:Distribution">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="noDescription" value="not(dct:description)"/>
			<sch:assert test="$noDescription = false()">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" does not have a dct:description.
			</sch:assert>
			<sch:report test="$noDescription = false()">The dcat:Distribution "<sch:value-of select="$id"/>" has a dct:description "<sch:value-of select="dct:description"/>"
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>81. dct:description should be a non-empty string for dcat:Distribution.</sch:title>
		<sch:rule context="//dcat:Distribution/dct:description">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="emptyString" value="normalize-space(.)=''"/>
			<sch:assert test="$emptyString = false()">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" has a dct:description that is an empty string.
			</sch:assert>
			<sch:report test="$emptyString = false()">The dcat:Distribution '<sch:value-of select="$id"/>' has a dct:description '<sch:value-of select="./string()"/>' which is a non-empty string.
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
	<!-- ISSUE: this seems to be the same as 49. -->
	<sch:pattern>
		<sch:title>163. Mandatory dcat:Distribution for a dcat:Dataset</sch:title>
		<sch:rule context="//dcat:Dataset">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="noDistribution" value="not(//dcat:Distribution)"/>
			<sch:assert test="$noDistribution = false()">ERROR: No dcat:Distribution resource exists for dcat:Dataset with URI <sch:value-of select="$id"/>.
			</sch:assert>
			<sch:report test="$noDistribution = false()">A dcat:Distribution resource exists for dcat:Dataset with URI <sch:value-of select="$id"/>.
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<!-- Rule_ID:118  (seems wrong in DCATv1.1 !) -->
		<sch:title>170. dct:type is a required property for Licence Document.</sch:title>
		<sch:rule context="//dct:LicenseDocument">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="noLicenseType" value="not(dct:type)"/>
			<sch:assert test="$noLicenseType = false()">ERROR: The licence <sch:value-of select="$id"/> has no dct:type property. 
			</sch:assert>
			<sch:report test="$noLicenseType = false()">The licence <sch:value-of select="$id"/> has a dct:type property. 
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>200. Mandatory dct:title for a dcat:Distribution</sch:title>
		<sch:rule context="//dcat:Distribution">
			<sch:let name="id" value="@rdf:about/string()"/>
			<sch:let name="noTitle" value="not(dct:title) or dct:title/string() = ''"/>
			<sch:assert test="$noTitle = false()">ERROR: The dcat:Distribution "<sch:value-of select="$id"/>" does not have a dct:title property.
			</sch:assert>
			<sch:report test="$noTitle = false()">The dcat:Distribution "<sch:value-of select="$id"/>" has a dct:title property with value  "<sch:value-of select="dct:title"/>".
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<sch:pattern>
		<sch:title>200. dct:title should be a non-empty string for dcat:Distribution.</sch:title>
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
		<sch:rule context="//vcard:hasEmail/@rdf:resource">
			<sch:let name="id" value="parent::node()/@rdf:about/string()"/>
			<sch:let name="emptyString" value="normalize-space(.)=''"/>
			<sch:assert test="$emptyString = false()">ERROR: The contact point "<sch:value-of select="$id"/>" has a vcard:hasEmail that is an empty string.
			</sch:assert>
			<sch:report test="$emptyString = false()">The dcontact point '<sch:value-of select="$id"/>' has a vcard:hasEmail '<sch:value-of select="./string()"/>' which is a non-empty string.
			</sch:report>
		</sch:rule>
	</sch:pattern>	
</sch:schema>

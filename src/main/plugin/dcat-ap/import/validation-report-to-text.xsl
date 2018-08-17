<?xml version="1.0" encoding="UTF-8"?>
<!-- 
Copyright (C) 2001-2007 Food and Agriculture Organization of the
United Nations (FAO-UN), United Nations World Food Programme (WFP)
and United Nations Environment Programme (UNEP)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA

Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
Rome - Italy. email: geonetwork@osgeo.org
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<!-- Tell the XSL processor to output XML. -->
	<xsl:output method="text" omit-xml-declaration="yes" indent="no" encoding="UTF-8"/>
	<xsl:template match="/">
		<xsl:value-of select="concat('','&#xA;')"/>
		<xsl:apply-templates select="reports"/>
	</xsl:template>	
	<xsl:template match="report[label]">
		<xsl:value-of select="concat('  ',label/text(),': ',error/text(),' errors. &#xA;')"/>
		<xsl:apply-templates select="patterns"/>
	</xsl:template>
	<xsl:template match="report[not(exists(label))]">
		<xsl:value-of select="concat('  ','DCAT-AP XML Schema Validation: ',error/text(),' errors. &#xA;')"/>
		<xsl:apply-templates select="patterns"/>
	</xsl:template>
	<xsl:template match="pattern[rules/rule/@type='error']">
		<xsl:value-of select="concat('      ', title, ' &#xA;')"/>
		<xsl:apply-templates select="rules"/>
	</xsl:template>
	<xsl:template match="rule[@group='xsd']">
		<xsl:value-of select="concat('          ERROR: at XPath ', details, ' &#xA;')"/>
	</xsl:template>
	<xsl:template match="rule[@type='error' and not(@group='xsd')]">
		<xsl:value-of select="concat('          ', msg, ' &#xA;')"/>
	</xsl:template>
	<xsl:template match="*|@*">
		<xsl:apply-templates select="*|@*"/>
	</xsl:template>	
</xsl:stylesheet>

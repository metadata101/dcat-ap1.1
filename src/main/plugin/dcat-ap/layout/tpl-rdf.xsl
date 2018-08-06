<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:geonet="http://www.fao.org/geonetwork" xmlns:saxon="http://saxon.sf.net/" 
		xmlns:spdx="http://spdx.org/rdf/terms#"
		xmlns:skos="http://www.w3.org/2004/02/skos/core#"
		xmlns:adms="http://www.w3.org/ns/adms#" 
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        xmlns:dc="http://purl.org/dc/elements/1.1/"
        xmlns:dct="http://purl.org/dc/terms/"
        xmlns:dcat="http://www.w3.org/ns/dcat#"
		xmlns:vcard="http://www.w3.org/2006/vcard/ns#"
		xmlns:foaf="http://xmlns.com/foaf/0.1/" 
		xmlns:owl="http://www.w3.org/2002/07/owl#"
		xmlns:schema="http://schema.org/"
		xmlns:locn="http://www.w3.org/ns/locn#"
		xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
		xmlns:void="http://www.w3.org/TR/void/"
		xmlns:ogc="http://www.opengis.net/rdf#"
		extension-element-prefixes="saxon"
		exclude-result-prefixes="#all">
	<!-- 
    Create reference block to metadata record and dataset to be added in dcat:Catalog usually.
  -->
	<!-- FIME : $url comes from a global variable. -->
	<xsl:template match="rdf:RDF" mode="record-reference">
		<dcat:dataset rdf:resource="{$url}/resource/{dcat:Catalog/dcat:dataset/dcat:Dataset/dct:identifier[1]}"/>
		<!--  <dcat:record rdf:resource="{$url}/metadata/{dcat:Catalog/dcat:dataset/dcat:Dataset/dct:identifier[1]}"/>  --> 
	</xsl:template>
	<!-- 
    Create metadata block with root element dcat:Dataset.
  -->
	<xsl:template match="rdf:RDF" mode="to-dcat">
		<xsl:copy-of select="dcat:Catalog/dcat:dataset/dcat:Dataset"/> 
	</xsl:template>
	<xsl:template match="rdf:RDF" mode="references"/>
	<xsl:template mode="rdf:RDF" match="gui|request|metadata"/>
</xsl:stylesheet>

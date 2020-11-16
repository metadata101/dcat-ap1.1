<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dct="http://purl.org/dc/terms/"
                xmlns:dcat="http://www.w3.org/ns/dcat#"
                exclude-result-prefixes="#all">
  <xsl:template match="/">
    <title>
      <xsl:value-of select="rdf:RDF/dcat:Catalog/dcat:dataset/dcat:Dataset/dct:title[1]"/>
    </title>
  </xsl:template>

</xsl:stylesheet>

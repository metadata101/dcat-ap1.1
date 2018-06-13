<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
                version="2.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="#all">

  <xsl:template name="render-transparent-boxed-element">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="value"/>
    <xsl:param name="errors" required="no"/>
    <xsl:param name="editInfo" required="no"/>
    <!-- The content to put into the box -->
    <xsl:param name="subTreeSnippet" required="yes" as="node()"/>
    <!-- cls may define custom CSS class in order to activate
    custom widgets on client side -->
    <xsl:param name="cls" required="no"/>
    <!-- XPath is added as data attribute for client side references
    to get help or inline editing ? -->
    <xsl:param name="xpath" required="no"/>
    <xsl:param name="attributesSnippet" required="no">
      <null/>
    </xsl:param>
    <xsl:param name="isDisabled" select="ancestor::node()[@xlink:href]"/>


    <xsl:variable name="hasXlink" select="@xlink:href"/>

    <div id="{concat('gn-el-', if ($editInfo) then $editInfo/@ref else generate-id())}"
              data-gn-field-highlight=""
              class="{if ($hasXlink) then 'gn-has-xlink' else ''} gn-{substring-after(name(), ':')}">
        <!--
         The toggle title is in conflict with the element title
         required for the element tooltip
         and bootstrap set the title attribute an higher priority.
         TODO: Could be improved ?
         title="{{{{'toggleSection' | translate}}}}"
        -->
        <xsl:if test="$xpath and $withXPath">
          <xsl:attribute name="data-gn-xpath" select="$xpath"/>
        </xsl:if>

        <xsl:if test="$editInfo and not($isDisabled)">
          <xsl:call-template name="render-boxed-element-control">
            <xsl:with-param name="editInfo" select="$editInfo"/>
          </xsl:call-template>
        </xsl:if>

        <xsl:if test="$editInfo">
          <xsl:call-template name="render-form-field-control-move">
            <xsl:with-param name="elementEditInfo" select="$editInfo"/>
            <xsl:with-param name="domeElementToMoveRef" select="$editInfo/@ref"/>
          </xsl:call-template>
        </xsl:if>

      <xsl:if test="count($attributesSnippet/*) > 0">
        <div class="well well-sm gn-attr {if ($isDisplayingAttributes) then '' else 'hidden'}">
          <xsl:copy-of select="$attributesSnippet"/>
        </div>
      </xsl:if>

      <xsl:if test="normalize-space($errors) != ''">
        <xsl:for-each select="$errors/errors/error">
          <div class="alert alert-danger">
            <xsl:value-of select="."/>
          </div>
        </xsl:for-each>
      </xsl:if>

      <xsl:if test="$subTreeSnippet">
        <xsl:copy-of select="$subTreeSnippet"/>
      </xsl:if>
    </div>
  </xsl:template>
</xsl:stylesheet>

<?xml version="1.0"?>
<!-- Copyright (C) 2023 Geoffrey T. Dairiki -->
<xsl:transform version="1.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:svg="http://www.w3.org/2000/svg"
               xmlns:xlink="http://www.w3.org/1999/xlink"
               xmlns:exsl="http://exslt.org/common"
               xmlns:func="http://exslt.org/functions"
               xmlns:regexp="http://exslt.org/regular-expressions"
               xmlns:set="http://exslt.org/sets"
               xmlns:bh="http://dairiki.org/barnhunt/inkscape-extensions"
               extension-element-prefixes="exsl func regexp set">

  <xsl:output method="xml"
              indent="yes" />

  <xsl:variable name="root" select="/*"/>

  <xsl:variable name="pat-ref-re" select="'(.*: *url\(#)([^)]+)(\).*)'"/>

  <xsl:key name="defs" match="svg:defs/*[@id]" use="@id"/>

  <!-- extract target ids of url()-style references from, eg. @style attribute -->
  <func:function name="bh:extract-ref">
    <xsl:param name="attr-val" select="."/>
    <func:result select="regexp:match($attr-val, $pat-ref-re)[3]"/>
  </func:function>

  <!-- update url() reference in @style attribute to point to new-ref -->
  <func:function name="bh:update-ref">
    <xsl:param name="new-ref"/>
    <xsl:param name="attr-val" select="."/>
    <func:result>
      <xsl:value-of select="regexp:match($attr-val, $pat-ref-re)[2]"/>
      <xsl:value-of select="$new-ref"/>
      <xsl:value-of select="regexp:match($attr-val, $pat-ref-re)[4]"/>
    </func:result>
  </func:function>

  <xsl:template match="@* | node()">
    <xsl:param name="defs" select="/.."/>
    <xsl:copy>
      <xsl:apply-templates select="@* | node()">
        <xsl:with-param name="defs" select="$defs"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!-- copy referenced patterns into the symbol -->
  <xsl:template match="svg:symbol[.//@style[bh:extract-ref(.)]]">
    <xsl:variable name="find-refs">
      <xsl:apply-templates select="*" mode="gather-refs"/>
    </xsl:variable>
    <!-- clone defs referenced by this symbol -->
    <xsl:variable name="clone-defs">
      <xsl:for-each select="set:distinct(exsl:node-set($find-refs)/*)">
        <xsl:variable name="ref" select="."/>
        <xsl:for-each select="$root">
          <xsl:copy-of select="key('defs', $ref)"/>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="defs" select="exsl:node-set($clone-defs)"/>

    <xsl:copy>
      <xsl:apply-templates select="@* | node()">
        <xsl:with-param name="defs" select="$defs"/>
      </xsl:apply-templates>

      <xsl:for-each select="$defs/*">
        <xsl:copy>
          <xsl:attribute name="id">
            <xsl:value-of select="generate-id(.)"/>
          </xsl:attribute>
          <xsl:apply-templates select="@* | node()" mode="copy-def"/>
        </xsl:copy>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <!-- mangle pattern references to point to copies -->
  <xsl:template match="@style[./ancestor::svg:symbol][bh:extract-ref(.)]">
    <xsl:param name="defs" select="/.."/>
    <xsl:variable name="def" select="($defs/*[@id = bh:extract-ref(current())])"/>
    <xsl:if test="not($def)">
      <xsl:copy/>
    </xsl:if>
    <xsl:if test="$def">
      <xsl:attribute name="{name()}">
        <xsl:value-of select="bh:update-ref(generate-id($def))"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <!-- strip out patterns -->
  <xsl:template match="svg:pattern[parent::svg:defs]"/>

  <!-- Strip out most id attributes -->
  <xsl:template match="@id" />
  <xsl:template match="svg:defs/*/@id | @id[//@xlink:href = concat('#', .)]">
    <xsl:copy />
  </xsl:template>

  <!-- ================================================================
      mode: gather-defs
  ================================================================ -->
  <xsl:template match="*" mode="gather-refs">
    <xsl:apply-templates select="* | @*" mode="gather-refs"/>
  </xsl:template>

  <xsl:template match="@*" mode="gather-refs"/>
  <xsl:template match="@style" mode="gather-refs">
    <xsl:if test="key('defs', bh:extract-ref())">
      <xsl:copy-of select="bh:extract-ref()"/>
    </xsl:if>
  </xsl:template>

  <!-- ================================================================
      mode: copy-def
  ================================================================ -->
  <xsl:template match="@* | node()" mode="copy-def">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="copy-def"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@collect | @id" mode="copy-def"/>

</xsl:transform>

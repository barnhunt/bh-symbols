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
               xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
               xmlns:bh="http://dairiki.org/barnhunt/inkscape-extensions"
               extension-element-prefixes="exsl func regexp set">

  <xsl:output method="xml"
              indent="yes" />

  <xsl:variable name="newline"><xsl:text>
  </xsl:text></xsl:variable>

  <xsl:variable name="root" select="/*"/>
  <xsl:key name="defs" match="/*/svg:defs/*[@id]" use="@id"/>

  <!-- get def by id -->
  <func:function name="bh:get-def">
    <xsl:param name="id" select="."/>
    <xsl:for-each select="$root"><!-- reset current node to main document -->
      <func:result select="key('defs', $id)"/>
    </xsl:for-each>
  </func:function>

  <xsl:variable name="pat-ref-re" select="'(.*\burl\(#)([^)]+)(\).*)'"/>

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

  <!-- ================================================================
      mode: top-level
  ================================================================ -->

  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- strip out non-symbol defs  -->
  <xsl:template match="/*/svg:defs/*"/>

  <!-- Strip out id attributes -->
  <xsl:template match="@id" />

  <xsl:template match="/*/svg:defs/svg:symbol[@id]">
    <xsl:variable name="id-prefix" select="concat(@id, ':')"/>

    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="copy-symbol">
        <xsl:with-param name="id-prefix" select="$id-prefix"/>
      </xsl:apply-templates>

      <!-- copy referenced patterns and symbols into the symbol -->
      <xsl:variable name="refs">
        <xsl:apply-templates select="*" mode="gather-refs"/>
      </xsl:variable>
      <xsl:variable name="distinct-refs" select="set:distinct(exsl:node-set($refs)/*)"/>
      <xsl:if test="$distinct-refs">
        <svg:defs>
          <xsl:apply-templates select="$distinct-refs" mode="copy-def">
            <xsl:with-param name="id-prefix" select="$id-prefix"/>
          </xsl:apply-templates>
        </svg:defs>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================
      mode: gather-refs
  ================================================================ -->
  <xsl:template match="*" mode="gather-refs">
    <xsl:apply-templates select="* | @*" mode="gather-refs"/>
  </xsl:template>

  <xsl:template match="@*" mode="gather-refs"/>

  <xsl:template match="/*/svg:defs/*/@id" mode="gather-refs">
    <match><xsl:value-of select="."/></match>
  </xsl:template>
  
  <xsl:template match="@style|@clip-path" mode="gather-refs">
    <xsl:apply-templates select="bh:get-def(bh:extract-ref())" mode="gather-refs"/>
  </xsl:template>
  
  <xsl:template match="@xlink:href[starts-with(., '#')]" mode="gather-refs">
    <xsl:apply-templates select="bh:get-def(substring(., 2))" mode="gather-refs"/>
  </xsl:template>

  <!-- ================================================================
      mode: copy-symbol
      ================================================================ -->

  <xsl:template match="@* | node()" mode="copy-symbol">
    <xsl:param name="id-prefix"/>
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="copy-symbol">
        <xsl:with-param name="id-prefix" select="$id-prefix"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!-- Strip out most id attributes -->
  <xsl:template match="@id" mode="copy-symbol"/>

  <!-- mangle internal target ids -->
  <xsl:template match="@id[//@xlink:href = concat('#', .)]" mode="copy-symbol">
    <xsl:param name="id-prefix"/>
    <xsl:attribute name="{name()}">
      <xsl:value-of select="concat($id-prefix, .)"/>
    </xsl:attribute>
  </xsl:template>

  <!-- preserve top-level symbol ids -->
  <xsl:template match="/*/svg:defs/*/@id" mode="copy-symbol">
    <xsl:copy />
  </xsl:template>

  <!-- mangle pattern references -->
  <xsl:template match="@style[bh:get-def(bh:extract-ref(.))]
                       |@clip-path[bh:get-def(bh:extract-ref(.))]"
                mode="copy-symbol">
    <xsl:param name="id-prefix"/>
    <xsl:attribute name="{name()}">
      <xsl:value-of select="bh:update-ref(concat($id-prefix, bh:extract-ref()))"/>
    </xsl:attribute>
  </xsl:template>

  <!-- mangle <use> references  -->
  <xsl:template match="@xlink:href[starts-with(., '#')]" mode="copy-symbol">
    <xsl:param name="id-prefix"/>
    <xsl:attribute name="{name()}">
      <xsl:value-of select="concat('#', $id-prefix, substring(., 2))"/>
    </xsl:attribute>
  </xsl:template>

  <!-- ================================================================
      mode: copy-def
  ================================================================ -->
  <xsl:template match="@* | node()" mode="copy-def">
    <xsl:param name="id-prefix"/>
    <xsl:apply-templates select="." mode="copy-symbol">
      <xsl:with-param name="id-prefix" select="$id-prefix"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- dereference the <match> nodes in $distinct-refs -->
  <xsl:template match="/match" mode="copy-def">
    <xsl:param name="id-prefix"/>
    <xsl:apply-templates select="bh:get-def(.)" mode="copy-def">
      <xsl:with-param name="id-prefix" select="$id-prefix"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="/*/svg:defs/*" mode="copy-def">
    <xsl:param name="id-prefix"/>

    <xsl:value-of select="$newline"/>
    <xsl:copy>
      <xsl:apply-templates select="@* | *" mode="copy-def">
        <xsl:with-param name="id-prefix" select="$id-prefix"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/*/svg:defs/svg:symbol" mode="copy-def">
    <xsl:param name="id-prefix"/>

    <xsl:value-of select="$newline"/>
    <svg:g>
      <xsl:apply-templates select="@* | *" mode="copy-def">
        <xsl:with-param name="id-prefix" select="$id-prefix"/>
      </xsl:apply-templates>
    </svg:g>
  </xsl:template>

  <xsl:template match="/*/svg:defs/*/@id" mode="copy-def">
    <xsl:param name="id-prefix"/>
    <xsl:attribute name="{name()}">
      <xsl:value-of select="concat($id-prefix, .)"/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="/*/svg:defs/*/svg:title
                       | /*/svg:defs/*/@inkscape:collect
                       | /*/svg:defs/*/@bh:count-as"
                mode="copy-def"/>

</xsl:transform>

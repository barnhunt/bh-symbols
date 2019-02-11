<?xml version="1.0"?>
<xsl:transform version="1.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:svg="http://www.w3.org/2000/svg"
               xmlns:xlink="http://www.w3.org/1999/xlink"
               xmlns:dyn="http://exslt.org/dynamic"
               xmlns:str="http://exslt.org/strings"
               xmlns:bale="http://dairiki.org/barnhunt/bale-scaling"
               extension-element-prefixes="dyn str">

  <xsl:param name="bale-length">36</xsl:param>
  <xsl:param name="bale-width">18</xsl:param>
  <xsl:param name="bale-height">15</xsl:param>
  <xsl:param name="bale-strings">2</xsl:param>

  <xsl:output method="xml"
              indent="yes" />

  <xsl:variable name="bale-dims"
                select="concat($bale-length, 'x', $bale-width, 'x', $bale-height)"/>

  <xsl:template name="fixup-number-of-strings">
    <xsl:param name="text" select="."/>
    <xsl:choose>
      <xsl:when test="$bale-strings = 2">
        <xsl:value-of select="str:replace($text, 'NN-string', 'Two-string')"/>
      </xsl:when>
      <xsl:when test="$bale-strings = 3">
        <xsl:value-of select="str:replace($text, 'NN-string', 'Three-string')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="fixup-text">
    <xsl:param name="text" select="."/>
    <xsl:call-template name="fixup-number-of-strings">
      <xsl:with-param name="text" select="str:replace(., 'LLxWWxHH', $bale-dims)"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="expand-params">
    <xsl:if test="@bale:height">
      <xsl:attribute name="height">
        <xsl:value-of select="dyn:evaluate(@bale:height)"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@bale:width">
      <xsl:attribute name="width">
        <xsl:value-of select="dyn:evaluate(@bale:width)"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@bale:d">
      <xsl:attribute name="d">
        <xsl:value-of select="dyn:evaluate(@bale:d)"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@bale:transform">
      <xsl:attribute name="transform">
        <xsl:value-of select="dyn:evaluate(@bale:transform)"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*" name="expand-elem">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:call-template name="expand-params"/>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[@bale:condition]">
    <xsl:if test="dyn:evaluate(@bale:condition)">
      <xsl:call-template name="expand-elem"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@*">
    <xsl:copy />
  </xsl:template>

  <!-- Strip out @bale:* attributes -->
  <xsl:template match="@*[namespace-uri() = 'http://dairiki.org/barnhunt/bale-scaling']" />

  <!-- Strip out the xmlns:bale namespace declaration -->
  <xsl:template match="/*">
    <xsl:element name="{name(.)}" namespace="{namespace-uri(.)}">
      <!-- <xsl:copy-of select="namespace::*[name(.) != 'bale']"/> -->
      <xsl:copy-of select="namespace::*[. != 'http://dairiki.org/barnhunt/bale-scaling']"/>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@id" />

  <xsl:template match="svg:defs/*/@id
                       | @id[//@xlink:href = concat('#', .)]
                       | @xlink:href">
    <xsl:attribute name="{name()}">
      <xsl:call-template name="fixup-text"/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:call-template name="fixup-text"/>
  </xsl:template>

</xsl:transform>

<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dcterms="http://purl.org/dc/terms/">
  <xsl:output method="html"/>
  <xsl:variable name="about" select="/rdf:RDF/rdf:Description[1]/@rdf:about"/>
  <xsl:variable name="title" select="/rdf:RDF/rdf:Description[1]/dcterms:title"/>
  <xsl:variable name="modified" select="/rdf:RDF/rdf:Description[1]/dcterms:modified"/>
  <xsl:variable name="publisher" select="/rdf:RDF/rdf:Description[1]/dcterms:publisher/@rdf:resource"/>
  <xsl:variable name="seeAlso" select="/rdf:RDF/rdf:Description[1]/rdfs:seeAlso/@rdf:resource"/>

  <xsl:variable name="rdfs-class">http://www.w3.org/2000/01/rdf-schema#Class</xsl:variable>
  <xsl:variable name="rdf-property">http://www.w3.org/1999/02/22-rdf-syntax-ns#Property</xsl:variable>

  <xsl:template match="/">
    <html>
      <head>
        <title><xsl:value-of select="$title"/></title>
        <style>
          h1 { font-size: x-large; }
          h2 { font-size: large; }
          h3 { font-size: medium; }
        </style>
      </head>
      <body>
        <h1><xsl:value-of select="$title"/></h1>
        <p>Namespace URI: <xsl:value-of select="$about"/><br/>
           Modified: <xsl:value-of select="$modified"/><br/>
           Published by: <a href="{$publisher}"><xsl:value-of select="$publisher"/></a>
           <xsl:if test="$seeAlso != ''">
             <br/>See Also: <a href="{$seeAlso}"><xsl:value-of select="$seeAlso"/></a>
           </xsl:if>
        </p>

        <!-- table of contents -->
        <xsl:for-each select="/rdf:RDF/rdf:Description[rdf:type/@rdf:resource=$rdfs-class]">
          <xsl:sort select="@rdf:about"/>
          <xsl:if test="position() = 1"><h2>Classes</h2></xsl:if>
          <xsl:call-template name="toc-entry"/>
        </xsl:for-each>
        <xsl:for-each select="/rdf:RDF/rdf:Description[rdf:type/@rdf:resource=$rdf-property]">
          <xsl:sort select="@rdf:about"/>
          <xsl:if test="position() = 1"><h2>Properties</h2></xsl:if>
          <xsl:call-template name="toc-entry"/>
        </xsl:for-each>

        <!-- class list -->
        <xsl:for-each select="/rdf:RDF/rdf:Description[rdf:type/@rdf:resource=$rdfs-class]">
          <xsl:sort select="@rdf:about"/>
          <xsl:if test="position() = 1"><h2>Classes</h2></xsl:if>
          <xsl:call-template name="main-entry"/>
        </xsl:for-each>

        <!-- properties list -->
        <xsl:for-each select="/rdf:RDF/rdf:Description[rdf:type/@rdf:resource=$rdf-property]">
          <xsl:sort select="@rdf:about"/>
          <xsl:if test="position() = 1"><h2>Properties</h2></xsl:if>
          <xsl:call-template name="main-entry"/>
        </xsl:for-each>
      </body>
    </html>
  </xsl:template>
  <xsl:template name="display-uri">
    <xsl:param name="label"/>
    <xsl:param name="uri"/>
    <xsl:variable name="name">
      <xsl:choose>
        <xsl:when test="/*/namespace::*[starts-with($uri,.)]">
          <xsl:for-each select="/*/namespace::*">
            <xsl:if test="starts-with($uri,.)">
              <xsl:value-of select="name()"/>:<xsl:value-of select="substring-after($uri,.)"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="$uri"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$uri != ''">
      <li><xsl:value-of select="$label"/><xsl:text>: </xsl:text>
        <a href="$uri"><xsl:value-of select="$name"/></a>
      </li>
    </xsl:if>
  </xsl:template>
  <xsl:template name="toc-entry">
    <xsl:variable name="id">
      <xsl:value-of select="substring-after(@rdf:about,$about)"/>
    </xsl:variable>
    <xsl:if test="$id != ''">
      <a href="#{$id}"><xsl:value-of select="$id"/></a>
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>
  <xsl:template name="main-entry">
    <xsl:variable name="id">
      <xsl:value-of select="substring-after(@rdf:about,$about)"/>
    </xsl:variable>
    <xsl:if test="$id != ''">
      <h3 id="{$id}"><xsl:value-of select="$id"/></h3>
      <ul>
        <li>Label: <xsl:value-of select="rdfs:label"/></li>
        <xsl:if test="rdfs:comment != ''">
          <li>Comment: <xsl:value-of select="rdfs:comment"/></li>
        </xsl:if>
        <xsl:call-template name="display-uri">
          <xsl:with-param name="label">Type</xsl:with-param>
          <xsl:with-param name="uri" select="rdf:type/@rdf:resource"/>
        </xsl:call-template>
        <xsl:choose>
          <xsl:when test="rdf:type/@rdf:resource = $rdfs-class">
            <xsl:call-template name="display-uri">
              <xsl:with-param name="label">Subclass of</xsl:with-param>
              <xsl:with-param name="uri" select="rdfs:subClassOf/@rdf:resource"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="rdf:type/@rdf:resource = $rdf-property">
            <xsl:call-template name="display-uri">
              <xsl:with-param name="label">Subproperty of</xsl:with-param>
              <xsl:with-param name="uri" select="rdfs:subPropertyOf/@rdf:resource"/>
            </xsl:call-template>
            <xsl:call-template name="display-uri">
              <xsl:with-param name="label">Domain</xsl:with-param>
              <xsl:with-param name="uri" select="rdfs:domain/@rdf:resource"/>
            </xsl:call-template>
            <xsl:call-template name="display-uri">
              <xsl:with-param name="label">Range</xsl:with-param>
              <xsl:with-param name="uri" select="rdfs:range/@rdf:resource"/>
            </xsl:call-template>
          </xsl:when>
        </xsl:choose>
      </ul>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>

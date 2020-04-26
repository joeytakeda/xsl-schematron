<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    exclude-result-prefixes="#all"
    xpath-default-namespace="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:rng="http://relaxng.org/ns/structure/1.0"
    xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
    xmlns:xso="dummy"
    xmlns:jt="https://github.com/joeytakeda/xsl-schematron"
    version="3.0">
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:namespace-alias stylesheet-prefix="xso" result-prefix="xsl"/>
    
    <xsl:variable name="mode-to-template" as="map(xs:string, xs:string*)">
        <xsl:map>
            <xsl:for-each-group select="//template[matches(@mode,'^M\d+')][@priority=1000]" group-by="@mode">
                <xsl:map-entry key="xs:string(current-grouping-key())">
                    <xsl:sequence select="for $match in current-group() return $match/@match/xs:string(.)"/>
                </xsl:map-entry>
            </xsl:for-each-group>
        </xsl:map>
    </xsl:variable>

    <xsl:template match="apply-templates[starts-with(@mode,'M')][ancestor::template[@match='/']]">
        <xsl:variable name="matches" select="$mode-to-template(xs:string(@mode))"/>
        <xsl:variable name="matchEval" select="string-join(for $match in tokenize($matches,'\|') return '//' || normalize-space($match),'|') => replace('///','/')"/>
        <xsl:if test="not(empty($matches))">
            <xso:apply-templates select="{$matchEval}" mode="{@mode}"/>
        </xsl:if> 
    </xsl:template>
    
    <xsl:template match="apply-templates[@select='*'][ancestor::template[1][@priority='1000']]"/>
   
</xsl:stylesheet>

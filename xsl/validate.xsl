<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    exclude-result-prefixes="#all"
    xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:rng="http://relaxng.org/ns/structure/1.0"
    xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
    xmlns:jt="https://github.com/joeytakeda/xsl-schematron"
    version="3.0">
    
    <xsl:param name="rng" as="xs:string?"/>
    <xsl:param name="sch" as="xs:string?"/>
    <xsl:param name="xsl" as="xs:string?"/>
    <xsl:param name="file" as="xs:string?"/>
    <xsl:param name="dir" as="xs:string?"/>
    <xsl:param name="out" as="xs:string?"/>
    <xsl:param name="failOnError" select="'no'" static="yes" as="xs:string?"/>
    <xsl:param name="verbose" as="xs:string?"/>
    <xsl:param name="pattern">*.xml</xsl:param>
    <xsl:param name="recurse">yes</xsl:param>
    
    
    <xsl:output method="text"/>
    
    <xsl:variable name="resolvedFile" select="resolve-uri($file)"/>
    
    <xsl:variable name="extract.rng">schematron/ExtractSchFromRNG-2.xsl</xsl:variable>
    <xsl:variable name="iso.dsdl.include">schematron/iso_dsdl_include.xsl</xsl:variable>
    <xsl:variable name="iso.abstract.expand">schematron/iso_abstract_expand.xsl</xsl:variable>
    <xsl:variable name="iso.svrl">schematron/iso_svrl_for_xslt2.xsl</xsl:variable>
    
    <xsl:variable name="useVerbose" select="if ($verbose=('True','true','yes','y','verbose','0')) then true() else false()"/>
    
    <xsl:variable name="docs" select="if (not(jt:noVal($dir))) then collection($dir || '?select=' || $pattern || ';recurse=' || $recurse || ';on-error=ignore') else doc($file)" as="document-node()*"/>
    
    <xsl:variable name="schemaXsl">
        <xsl:call-template name="makeSchemaXsl"/>
    </xsl:variable>
 
    <xsl:template match="/">
        <xsl:call-template name="echoParams"/>
        <xsl:call-template name="checkParams"/>
        <xsl:call-template name="validate"/>
    </xsl:template>
    
    
    <xsl:template name="validate">

        <xsl:variable name="errors" as="map(xs:anyURI, element()+)">
            <xsl:call-template name="makeErrorsMap"/>
        </xsl:variable>
        
        <xsl:variable name="size" select="map:size($errors)"/>
        
        <xsl:choose>
            <xsl:when test="$size gt 0">
                <xsl:for-each select="map:keys($errors)">
                    <xsl:message><xsl:text>&#xA;</xsl:text></xsl:message>
                    <xsl:variable name="key" select="."/>
                    <xsl:variable name="entry" select="$errors($key)"/>
                    <xsl:message><xsl:value-of select="$key"/>:</xsl:message>
                    <xsl:for-each select="$entry">
                        <xsl:message><xsl:text>&#x9;</xsl:text><xsl:text>* </xsl:text><xsl:value-of select="normalize-space(svrl:text)"/></xsl:message>
                    </xsl:for-each>
                    <xsl:message><xsl:text>&#xA;</xsl:text></xsl:message>
                </xsl:for-each>
                <xsl:message _terminate="{$failOnError}">Validation failed. Messages are provided above.</xsl:message>
                <xsl:message>*************************************************************************</xsl:message>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message><xsl:text>&#xA;</xsl:text></xsl:message>
                <xsl:message><xsl:value-of select="count($docs)"/> document<xsl:if test="count($docs) gt 1">s</xsl:if> have been successfully validated.</xsl:message>
            </xsl:otherwise>
        </xsl:choose>  
    </xsl:template>
    
    
    <xsl:template name="makeErrorsMap">
        <xsl:map>
            <xsl:for-each select="$docs">
                <xsl:variable name="currDoc" select="."/>
                <xsl:variable name="uri" select="document-uri($currDoc)"/>
                <xsl:message>Validating <xsl:value-of select="$uri"/></xsl:message>
                <xsl:variable name="result" select="transform(map{'stylesheet-node': $schemaXsl, 'source-node': $currDoc})?output"/>
                <xsl:variable name="failed-asserts" select="$result//svrl:failed-assert" as="element(svrl:failed-assert)*"/>
                <xsl:variable name="successful-reports" select="$result//svrl:successful-report" as="element(svrl:successful-report)*"/>
                <xsl:variable name="errors" select="($failed-asserts,$successful-reports)" as="element()*"/>
                <xsl:if test="not(empty($errors))">
                    <xsl:map-entry key="$uri" select="$errors"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:map>
    </xsl:template>
    
    
    <xsl:template name="makeSchemaXsl">
        <xsl:if test="$useVerbose">
            <xsl:message>Making schema XSLT...</xsl:message>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="not(jt:noVal($xsl)) and doc-available($xsl)">
                <xsl:if test="$useVerbose">
                    <xsl:message>XSLT supplied; using that.</xsl:message>
                </xsl:if>
                <xsl:copy-of select="doc($xsl)"/>
            </xsl:when>
            <xsl:when test="not(jt:noVal($sch)) and doc-available($sch)">
                <xsl:if test="$useVerbose">
                    <xsl:message>Found schematron. Converting to XSL.</xsl:message>
                </xsl:if>
                <xsl:copy-of select="jt:schematronToXsl(doc($sch))"/>
            </xsl:when>
            <xsl:when test="not(jt:noVal($rng)) and doc-available($rng)">
                <xsl:if test="$useVerbose">
                    <xsl:message>Found RNG with embedded Schematron.</xsl:message>
                </xsl:if>
                <xsl:if test="$useVerbose">
                    <xsl:message>Extracting embedded schematron from RNG using <xsl:value-of select="resolve-uri($extract.rng)"/></xsl:message>
                </xsl:if>
                <xsl:copy-of select="jt:transform($extract.rng, doc($rng))?output => jt:schematronToXsl()"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="jt:schematronToXsl">
        <xsl:param name="sch"/>
        <xsl:variable name="first">
            <xsl:if test="$useVerbose">
                <xsl:message>Expanding <xsl:value-of select="document-uri($sch)"/> includes using <xsl:value-of select="resolve-uri($iso.dsdl.include)"/></xsl:message>
            </xsl:if>
            <xsl:copy-of select="jt:transform($iso.dsdl.include,$sch)?output"/>
        </xsl:variable>
        <xsl:variable name="second">
            <xsl:if test="$useVerbose">
                <xsl:message>Expanding using <xsl:value-of select="resolve-uri($iso.abstract.expand)"/></xsl:message>
            </xsl:if>
            <xsl:copy-of select="jt:transform($iso.abstract.expand, $first)?output"/>
        </xsl:variable>
        <xsl:variable name="third">
            <xsl:if test="$useVerbose">
                <xsl:message>Expanding using <xsl:value-of select="resolve-uri($iso.svrl)"/></xsl:message>
            </xsl:if>
            <xsl:copy-of select="jt:transform($iso.svrl, $second)?output"/>
        </xsl:variable> 
        <xsl:copy-of select="$third"/>
    </xsl:function>
    
    
    <xsl:function name="jt:transform">
        <xsl:param name="stylesheet-location" as="xs:string"/>
        <xsl:param name="source-node" as="node()"/>
        <xsl:copy-of select="transform(map{'stylesheet-location': $stylesheet-location, 'source-node': $source-node})"/>
    </xsl:function>
    

    


  
    <xsl:template name="echoParams">
        <xsl:if test="$useVerbose"><xsl:message>$rng: <xsl:value-of select="$rng"/></xsl:message></xsl:if>
        <xsl:if test="$useVerbose"><xsl:message>$sch: <xsl:value-of select="$sch"/></xsl:message></xsl:if>
        <xsl:if test="$useVerbose"><xsl:message>$xsl: <xsl:value-of select="$xsl"/></xsl:message></xsl:if>
        <xsl:if test="$useVerbose"><xsl:message>$file: <xsl:value-of select="$file"/></xsl:message></xsl:if>
        <xsl:if test="$useVerbose"><xsl:message>$dir: <xsl:value-of select="$dir"/></xsl:message></xsl:if>
        <xsl:if test="$useVerbose"><xsl:message>$out: <xsl:value-of select="$out"/></xsl:message></xsl:if>
        <xsl:if test="$useVerbose"><xsl:message>$verbose: <xsl:value-of select="$verbose"/></xsl:message></xsl:if>
        <xsl:if test="$useVerbose"><xsl:message>$resolvedFile: <xsl:value-of select="$resolvedFile"/></xsl:message></xsl:if>
    </xsl:template>
    
    <xsl:template name="checkParams">
        <xsl:choose>
            <xsl:when test="not(jt:noVal($rng)) and not(jt:noVal($sch)) and not(jt:noVal($xsl))">
                <xsl:message terminate="yes">ERROR: One of rng, sch, and xsl should be supplied. Choose one.</xsl:message>
            </xsl:when>
            <xsl:when test="jt:noVal($rng) and jt:noVal($sch) and jt:noVal($xsl)">
                <xsl:message terminate="yes">ERROR: No schema specified.</xsl:message>
            </xsl:when>
            <xsl:when test="not(jt:noVal($file)) and not(jt:noVal($dir))">
                <xsl:message terminate="yes">ERROR: Both file and dir supplied. Choose one.</xsl:message>
            </xsl:when>
            <xsl:when test="jt:noVal($file) and jt:noVal($dir)">
                <xsl:message terminate="yes">ERROR: No file or directory specified.</xsl:message>
            </xsl:when>
            <xsl:when test="empty($docs)">
                <xsl:message terminate="yes">ERROR: No documents specified. Check your paths.</xsl:message>
            </xsl:when>
        </xsl:choose>
        
        
    </xsl:template>
    
    <xsl:function name="jt:noVal" as="xs:boolean">
        <xsl:param name="string" as="xs:string?"/>
        <xsl:value-of select="string-length(normalize-space($string)) = 0"/>
    </xsl:function>
    
    
    
</xsl:stylesheet>
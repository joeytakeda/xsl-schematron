<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    exclude-result-prefixes="#all"
    xmlns:hcmc="glo"
    version="3.0">
    
    
    <xsl:param name="schemaXsl" select="'../rng/london_all.xsl'"/>
    <xsl:param name="collectionPath" select="'../../'"/>
    <xsl:variable name="collection" select="collection($collectionPath || '?select=*.xml;recurse=yes')"/>
       
    <xsl:variable name="errors" as="xs:string*">
        <xsl:for-each select="$collection">
            <xsl:variable name="curr" select="."/>
            <xsl:message>Processing <xsl:value-of select="document-uri($curr)"/></xsl:message>
            <xsl:sequence select="
                let $t := transform(map{'stylesheet-location': $schemaXsl, 'source-node': .})?output
                return 
                    if ($t[//*:failed-assert]) 
                    then $t//*:failed-assert/*:text/concat(document-uri($curr),': ',.) => normalize-space()
                    else ()"/>
        </xsl:for-each>
    </xsl:variable>

    
    <xsl:template name="go">
        <xsl:if test="not(empty($errors))">
            <xsl:message terminate="yes">
                Validation with <xsl:value-of select="resolve-uri($schemaXsl)"/> failed. Results are provided below:
                
                <xsl:for-each select="$errors">
                    <xsl:value-of select="."/>
                </xsl:for-each>
            </xsl:message>
        </xsl:if>
    </xsl:template>
    
    
    
</xsl:stylesheet>
<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt3"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
    <ns prefix="sch" uri="http://purl.oclc.org/dsdl/schematron"/>
    <ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
    <ns prefix="xs" uri="http://www.w3.org/2001/XMLSchema"/>
    <ns prefix="hcmc" uri="http://hcmc.uvic.ca/ns"/>
    <ns prefix="xsl" uri="http://www.w3.org/1999/XSL/Transform"/>
    <ns prefix="rng" uri="http://relaxng.org/ns/structure/1.0"/>
    <ns prefix="teix" uri="http://www.tei-c.org/ns/Examples"/>
    
    
    <pattern>
        <rule context="tei:persName">
            <assert test="not(@type)">
                ERROR: No type value allowed on <value-of select="hcmc:name(.)"/>.
            </assert>
        </rule>
    </pattern>

    
    <pattern>
        <rule context="tei:persName">
            <assert test="let $map := map{'a': 'b'} return 
                if ($map('e')) then true() else false()">
                ERROR: TEST.
            </assert>
            
        </rule>
    </pattern>
    
    <xsl:function name="hcmc:name">
        <xsl:param name="element"/>
        <xsl:value-of select="'el: ' || local-name($element)"/>
    </xsl:function>
    
</schema>
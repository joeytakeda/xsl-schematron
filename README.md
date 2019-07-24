# xsl-schematron

## An XSLT 3.0 Validator for Schematron

This repository provides the code for an XSLT 3.0 validator for use with Schematron or embedded Schematron within an RelaxNG schema. It is still in development; documentation will follow soon.

## How to Use

Using your favourite XSLT 3.0 processor (like Saxon 9.8HE), you can run the XSLT like you would any other:

```
saxon -xsl:validate.xsl -s:validate.xsl
```

You must provide, as a paramater to the stylesheet, **one of**:

* file: The source file to validate
* dir: A directory containing files to validate

**and one of**:

* rng: The RelaxNG schema with embedded schematron
* sch: The schematron file
* xsl: An XSLT filed derived using Rick Jeliffe's stylesheets for SCH --> XSLT --> SVRL.


## How it Works

This transformation relies heavily on the XSLT `transform()` function: https://www.saxonica.com/html/documentation/functions/fn/transform.html

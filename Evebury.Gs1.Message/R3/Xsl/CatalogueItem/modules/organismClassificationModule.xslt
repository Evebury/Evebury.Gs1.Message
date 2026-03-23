<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:organism_classification:xsd:3' and local-name()='organismClassificationModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="organismClassification" mode="organismClassificationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="organismClassification" mode="organismClassificationModule">
		<xsl:param name="targetMarket"/>
		<!--Rule 1865: If species is used, then genus SHALL be used.-->
		<xsl:if test="string(species) != '' and string(genus) = ''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1865" />
			</xsl:apply-templates>
		</xsl:if>

		
	</xsl:template>

</xsl:stylesheet>
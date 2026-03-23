<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:copyright_information:xsd:3' and local-name()='copyrightInformationModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="copyrightInformation" mode="copyrightInformationModule"/>

	</xsl:template>

	<xsl:template match="copyrightInformation" mode="copyrightInformationModule">

		<xsl:apply-templates select="partyIdentification" mode="gln"/>
	</xsl:template>

</xsl:stylesheet>
<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:medical_device_trade_item:xsd:3' and local-name()='medicalDeviceTradeItemModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="medicalDeviceInformation" mode="medicalDeviceTradeItemModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="medicalDeviceInformation" mode="medicalDeviceTradeItemModule">
		<xsl:param name="targetMarket"/>

		<!--Rule 1852: If initialSterilisationPriorToUseCode and/or manufacturerSpecifiedAcceptableResterilisationCode is used then initialSterilisationPriorToUseCode and/or manufacturerSpecifiedAcceptableResterilisationCode SHALL NOT equal "NOT_STERILISED".-->
		<xsl:if test="tradeItemSterilityInformation[manufacturerSpecifiedAcceptableResterilisationCode = 'NOT_STERILISED'] or tradeItemSterilityInformation[initialSterilisationPriorToUseCode = 'NOT_STERILISED']">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1852" />
			</xsl:apply-templates>
		</xsl:if>

		<!--Rule 2075: If initialManufacturerSterilisationCode and/or manufacturerSpecifiedAcceptableResterilisationCode is used then initialManufacturerSterilisationCode and/or manufacturerSpecifiedAcceptableResterilisationCode SHALL NOT equal 'NO_STERILISATION_REQUIRED'.-->
		<xsl:if test="tradeItemSterilityInformation[manufacturerSpecifiedAcceptableResterilisationCode = 'NO_STERILISATION_REQUIRED'] or tradeItemSterilityInformation[initialSterilisationPriorToUseCode = 'NO_STERILISATION_REQUIRED']">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="2075" />
			</xsl:apply-templates>
		</xsl:if>

	</xsl:template>

</xsl:stylesheet>
<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:alcohol_information:xsd:3' and local-name()='alcoholInformationModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="alcoholInformation" mode="alcoholInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="alcoholInformation" mode="alcoholInformationModule">
		<xsl:param name="targetMarket"/>
		<!--Rule 428: If percentageOfAlcoholByVolume is not empty then value must be greater than or equal to 0 and less than or equal to 100.00.-->
		<xsl:if test="number(percentageOfAlcoholByVolume) = percentageOfAlcoholByVolume">
			<xsl:if test="percentageOfAlcoholByVolume &lt; 0 or percentageOfAlcoholByVolume &gt; 100">
				<xsl:apply-templates select="percentageOfAlcoholByVolume" mode="error">
					<xsl:with-param name="id" select="428"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<!--Rule 1800: If targetMarketCountryCode equals '752' (Sweden) and alcoholicBeverageSugarContent is used then associated alcoholicBeverageSugarContent/@measurementUnitCode SHALL equal 'GL' (gram per litre).-->
		<xsl:if test="string(alcoholicBeverageSugarContent) != '' and $targetMarket = '752'">
			<xsl:if test="alcoholicBeverageSugarContent/@measurementUnitCode != 'GL'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1800" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		
		<xsl:if test="$targetMarket = '756'">

			<!--Rule 1951: If targetMarketCountryCode equals <Geographic> and percentageOfAlcoholByVolumeMeasurementPrecisionCode is used then percentageOfAlcoholByVolume SHALL be used.-->
			<xsl:if test="string(percentageOfAlcoholByVolumeMeasurementPrecisionCode) != '' and string(percentageOfAlcoholByVolume) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1951" />
				</xsl:apply-templates>
			</xsl:if>

			<!--Rule 2024: If targetMarketCountryCode equals <Geographic> and percentageOfAlcoholByVolumeMeasurementPrecisionCode is used then percentageOfAlcoholByVolumeMeasurementPrecisionCode SHALL equal 'LESS_THAN'.-->
			<xsl:if test="string(percentageOfAlcoholByVolumeMeasurementPrecisionCode) != '' and string(percentageOfAlcoholByVolumeMeasurementPrecisionCode) != 'LESS_THAN'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="2024" />
				</xsl:apply-templates>
			</xsl:if>
			
		</xsl:if>

	</xsl:template>

</xsl:stylesheet>
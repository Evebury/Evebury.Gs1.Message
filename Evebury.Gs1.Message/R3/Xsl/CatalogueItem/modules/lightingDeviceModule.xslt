<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:lighting_device:xsd:3' and local-name()='lightingDeviceModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="lightBulbInformation" mode="lightingDeviceModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="lightOutput" mode="lightingDeviceModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="lightBulbInformation" mode="lightingDeviceModule">
		<xsl:param name="targetMarket"/>
		<!--Rule 1810: If colourTemperature is used then associated @measurementUnitCode SHALL equal 'KEL' (Kelvin).-->
		<xsl:if test="string(colourTemperature) != '' and string(colourTemperature/@temperatureMeasurementUnitCode) != 'KEL'">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1810" />
			</xsl:apply-templates>
		</xsl:if>
		
		
	</xsl:template>

	<xsl:template match="lightOutput" mode="lightingDeviceModule">
		<xsl:param name="targetMarket"/>
		<!--Rule 1811: If targetMarketCountryCode equals '752' (Sweden) and lightOutput is used then the associated @measurementUnitCode SHALL equal 'B60' (Lumens per square metre) or 'LUX' (Lux).-->
		<xsl:if test="$targetMarket = '752'">
			<xsl:if test="@measurementUnitCode != 'B60' and @measurementUnitCode != 'LUX'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1811" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

	</xsl:template>

</xsl:stylesheet>
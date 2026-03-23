<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:trade_item_temperature_information:xsd:3' and local-name()='tradeItemTemperatureInformationModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="tradeItemTemperatureInformation" mode="tradeItemTemperatureInformationModule">
			<xsl:with-param name="targetMarket"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="tradeItemTemperatureInformation" mode="tradeItemTemperatureInformationModule">
		<xsl:param name="targetMarket"/>
		<!--Rule 362: If a minimum and corresponding maximum are not empty then the minimum SHALL be less than or equal to the corresponding maximum.-->
		<xsl:if test="gs1:InvalidRange(minimumTemperature,maximumTemperature)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="362"/>
			</xsl:apply-templates>
		</xsl:if>
		<xsl:if test="gs1:InvalidRange(minimumToleranceTemperature,maximumToleranceTemperature)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="362"/>
			</xsl:apply-templates>
		</xsl:if>

		<!--Rule 477: If targetMarketCountryCode equals <Geographic> and (maximumTemperature, minimumTemperature, flashPoint/flashPointTemperature or hazardousInformationHeader/flashPointTemperature are used) then at least one iteration of the associated measurementUnitCode SHALL equal 'CEL'.-->
		<xsl:if test="contains('752, 203, 250, 208, 246, 040, 703, 756', $targetMarket)">
			<xsl:if test="minimumTemperature">
				<xsl:choose>
					<xsl:when test="minimumTemperature[@temperatureMeasurementUnitCode = 'CEL']"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="477"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="maximumTemperature">
				<xsl:choose>
					<xsl:when test="maximumTemperature[@temperatureMeasurementUnitCode = 'CEL']"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="477"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:if>

		<!--Rule 1058: If any attribute of the TradeItemTemperatureInformation class other than temperatureTypeQualifierCode is not empty then temperatureTypeQualifierCode must not be empty.-->
		<xsl:if test="string(temperatureQualifierCode) = ''">
			<xsl:if test="*[text() != '' and name() != 'temperatureQualifierCode']">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1058" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>


		<xsl:if test="$targetMarket = '208' or $targetMarket = '826'">
			<xsl:if test="temperatureQualifierCode = 'STORAGE_HANDLING'">
				<!--Rule 1652: If targetMarketCountryCode equals (208 (Denmark) or 826 (UK)) and contextIdentification does not equal 'DP007' or 'DP008' and temperatureQualifierCode equals 'STORAGE_HANDLING', then maximumTemperature SHALL be used.-->
				<xsl:if test="maximumTemperature  =''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1652" />
					</xsl:apply-templates>
				</xsl:if>
				<!--Rule 1653: If targetMarketCountryCode equals (208 (Denmark) or 826 (UK)) and contextIdentfication does not equal 'DP007' or 'DP008' and temperatureQualifierCode equals 'STORAGE_HANDLING', then minimumTemperature SHALL be used.-->
				<xsl:if test="minimumTemperature  =''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1653" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<!--Rule 1837: If temperatureQualifierCode is used, then at least one other attribute in the TradeItemTemperatureInformation class SHALL be used.-->
		<xsl:if test="string(temperatureQualifierCode) != ''">
			<xsl:if test="count(*[name() != 'temperatureQualifierCode']) = 0">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1837" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
		
	</xsl:template>

</xsl:stylesheet>
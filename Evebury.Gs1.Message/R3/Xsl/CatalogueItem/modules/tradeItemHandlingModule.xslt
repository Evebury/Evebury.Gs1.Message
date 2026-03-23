<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:trade_item_handling:xsd:3' and local-name()='tradeItemHandlingModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="tradeItemHandlingInformation" mode="tradeItemHandlingModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
			<xsl:with-param name="tradeItem" select="$tradeItem"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="tradeItemHandlingInformation" mode="tradeItemHandlingModule">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>
		<xsl:apply-templates select="tradeItemStacking" mode="tradeItemHandlingModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>

		<!--Rule 1659: If contextIdentification does not equal 'DP007' or 'DP008' and multiple iterations of handlingInstructionsCodeReference are used, then no two iterations SHALL be equal.-->
		<xsl:variable name="parent" select="."/>
		<xsl:for-each select="handlingInstructionsCodeReference">
			<xsl:variable name="value" select="."/>
			<xsl:if test="count($parent[handlingInstructionsCodeReference = $value]) &gt; 1">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1659" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>

		<!--Rule 1703: IF targetMarketCountryCode equals '752' (Sweden) and HandlingInstructionsCodeReference equals ‘OTC’ (Temperature Control), then temperatureQualifierCode SHALL be used and equal  ('STORAGE_HANDLING' or 'TRANSPORTATION') AND maximumTemperature and minimumTemperature SHALL be used per temperatureQualifierCode.-->
		<xsl:if test="$targetMarket = '752' and HandlingInstructionsCodeReference = 'OTC'">
			<xsl:variable name="module" select="$tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_temperature_information:xsd:3' and local-name()='tradeItemTemperatureInformationModule']/tradeItemTemperatureInformation"/>
			<xsl:if test="string($module[temperatureQualifierCode = 'STORAGE_HANDLING']/minimumTemperature) ='' or string($module[temperatureQualifierCode = 'STORAGE_HANDLING']/maximumTemperature) =''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1703" />
				</xsl:apply-templates>
			</xsl:if>
			<xsl:if test="string($module[temperatureQualifierCode = 'TRANSPORTATION']/minimumTemperature) ='' or string($module[temperatureQualifierCode = 'TRANSPORTATION']/maximumTemperature) =''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1703" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<xsl:if test="$targetMarket ='756' or $targetMarket ='040'">
			<!--Rule 1990: If targetMarketCountryCode equals <Geographic> then handlingInstructionsCodeReference codes '11' and '12' SHALL NOT be used for the same trade item.-->
			<xsl:if test="handlingInstructionsCodeReference = '11' and handlingInstructionsCodeReference = '12'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1990" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
		
	</xsl:template>

	<xsl:template match="tradeItemStacking" mode="tradeItemHandlingModule">
		<xsl:param name="targetMarket"/>

		<!--Rule 479: If targetMarketCountryCode equals <Geographic> then stackingFactor SHALL be less than 100.-->
		<xsl:if test="contains('056, 442, 528', $targetMarket)">
			<xsl:if test="string(stackingFactor) != '' and stackingFactor &gt; 100">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="479"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<!--Rule 1324: If stackingFactor is not empty, it must equal or be greater than '1'-->
		<xsl:if test="string(stackingFactor) != '' and stackingFactor &lt; 1">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1324"/>
			</xsl:apply-templates>
		</xsl:if>

		<!--Rule 1745: If targetMarketCountryCode equals <Geographic> then for each iteration of TradeItemStacking class if (stackingFactorTypeCode is used or stackingFactor is used) then stackingFactorTypeCode SHALL be used and stackingFactor SHALL be used.-->
		<xsl:if test="contains('040, 056, 246, 442, 528, 756', $targetMarket)">
			<xsl:if test="string(stackingFactor) != '' or string(stackingFactorTypeCode) != ''">
				<xsl:if test="string(stackingFactor) = '' or string(stackingFactorTypeCode) = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1745" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
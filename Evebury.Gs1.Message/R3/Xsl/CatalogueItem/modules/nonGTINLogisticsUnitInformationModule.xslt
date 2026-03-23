<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:nongtin_logistics_unit_information:xsd:3' and local-name()='nonGTINLogisticsUnitInformationModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="nonGTINLogisticsUnitInformation" mode="nonGTINLogisticsUnitInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
			<xsl:with-param name="tradeItem" select="$tradeItem"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="nonGTINLogisticsUnitInformation" mode="nonGTINLogisticsUnitInformationModule">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>
		<!--Rule 480: If targetMarketCountryCode equals <Geographic> then logisticsUnitStackingFactor SHALL be less than 100.-->
		<xsl:if test="contains('056, 442, 528', $targetMarket)">
			<xsl:if test="string(logisticsUnitStackingFactor) != '' and logisticsUnitStackingFactor &gt; 100">
				<xsl:apply-templates select="logisticsUnitStackingFactor" mode="error">
					<xsl:with-param name="id" select="480"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
		<!--Rule 1651: If targetMarketCountryCode equals <Geographic> and tradeItemUnitDescriptorCode equals 'PALLET', then no attributes in class nonGTINLogisticsUnitInformation SHALL be used.-->
		<xsl:if test="contains('276, 528, 208, 203, 246, 056, 442, 250, 040, 380', $targetMarket)">
			<xsl:if test="$tradeItem/tradeItemUnitDescriptorCode  = 'PALLET'">
				<xsl:if test="string(grossWeight) != '' or string(height) != '' or string(depth) != '' or string(width) != '' or string(logisticsUnitStackingFactor) != ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1651" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<!--Rule 1792: If specialItemCode does not equal 'DYNAMIC_ASSORTMENT' and (quantityOfTradeItemsPerPallet and NonGTINLogisticsUnitInformation/grossWeight and tradeItemMeasurements/tradeItemWeight/grossWeight are used), then NonGTINLogisticsUnitInformation/grossWeight SHALL be greater than 96 % of quantityOfTradeItemsPerPallet multiplied by tradeItemMeasurements/tradeItemWeight/grossWeight.-->
		<xsl:if test="grossWeight != ''">
			<xsl:if test="string($tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:marketing_information:xsd:3' and local-name()='marketingInformationModule']/marketingInformation/specialItemCode) != 'DYNAMIC_ASSORTMENT'">
				<xsl:variable name="grossWeightValue" select="$tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_measurements:xsd:3' and local-name()='tradeItemMeasurementsModule']/tradeItemMeasurements/tradeItemWeight/grossWeight"/>
				<xsl:variable name="quantity" select="$tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_hierarchy:xsd:3' and local-name()='tradeItemHierarchyModule']/tradeItemHierarchy/quantityOfTradeItemsPerPallet"/>
				
				<xsl:if test="$grossWeightValue and $quantity">
					<xsl:variable name="weight">
						<xsl:apply-templates select="grossWeight" mode="measurementUnit"/>
					</xsl:variable>
					<xsl:variable name="grossWeight">
						<xsl:apply-templates select="$grossWeightValue" mode="measurementUnit"/>
					</xsl:variable>
					<xsl:if test="$weight &lt; 0.96 * $quantity * $grossWeight">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1792" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<!--Rule 1927: If targetMarketCountryCode equals <Geographic> and  nonGTINLogisticsUnitInformation/depth is used and nonGTINLogisticsUnitInformation/width is used then nonGTINLogisticsUnitInformation/depth must be greater than or equal to nonGTINLogisticsUnitInformation/width.-->
		<xsl:if test="$targetMarket  = '380'">
			<xsl:if test="string(depth) != '' and string(width) != ''">
				<xsl:if test="width &gt; depth">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1927" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>

	</xsl:template>

</xsl:stylesheet>
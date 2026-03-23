<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:trade_item_data_carrier_and_identification:xsd:3' and local-name()='tradeItemDataCarrierAndIdentificationModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>


		<xsl:apply-templates select="dataCarrier" mode="tradeItemDataCarrierAndIdentificationModule">
			<xsl:with-param name="tradeItem" select="$tradeItem"/>
		</xsl:apply-templates>

		<xsl:for-each select="gS1TradeItemIdentificationKey">
			<xsl:choose>
				<xsl:when test="gs1TradeItemIdentificationKeyCode  = 'GTIN_13'">
					<xsl:if test="gs1:InvalidGTIN(gs1TradeItemIdentificationKeyValue,13)">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1294" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:when test="gs1TradeItemIdentificationKeyCode  = 'GTIN_8'">
					<xsl:if test="gs1:InvalidGTIN(gs1TradeItemIdentificationKeyValue,8)">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1295" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:when test="gs1TradeItemIdentificationKeyCode  = 'GTIN_14'">
					<xsl:if test="gs1:InvalidGTIN(gs1TradeItemIdentificationKeyValue,14)">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1296" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:when test="gs1TradeItemIdentificationKeyCode  = 'GTIN_12'">
					<xsl:if test="gs1:InvalidGTIN(gs1TradeItemIdentificationKeyValue,12)">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1297" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<!--Rule 1748: If gs1TradeItemIdentificationKeyCode is equal to 'ZERO_SUPPRESSED_GTIN', then the first digit of gs1TradeItemIdentificationKeyValue SHALL equal '0'.-->
				<xsl:when test="gs1TradeItemIdentificationKeyCode  = 'ZERO_SUPPRESSED_GTIN'">
					<xsl:if test="string(gs1TradeItemIdentificationKeyValue) = '' or substring(gs1TradeItemIdentificationKeyValue,1,1) != '0'">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1748" />
						</xsl:apply-templates>
					</xsl:if>
					<xsl:if test="gs1:InvalidGTIN(gs1TradeItemIdentificationKeyValue,8)">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1749" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>

		<!--Rule 1834: If (gs1TradeItemIdentificationKeyValue is used or gs1TradeItemIdentificationKeyCode is used) then gs1TradeItemIdentificationKeyValue SHALL be used and gs1TradeItemIdentificationKeyCode SHALL be used.-->
		<xsl:if test="(string(gs1TradeItemIdentificationKeyValue) != '' or string(gs1TradeItemIdentificationKeyCode) != '') and (string(gs1TradeItemIdentificationKeyValue) = '' or string(gs1TradeItemIdentificationKeyCode) = '')">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1834" />
			</xsl:apply-templates>
		</xsl:if>

	</xsl:template>

	<xsl:template match="dataCarrier" mode="tradeItemDataCarrierAndIdentificationModule">
		<xsl:param name="tradeItem"/>

		<!--Rule 523: If dataCarrierTypeCode equals ('EAN_13', 'UPC_A' or 'UPC_E') then first digit of gtin shall equal '0'.-->
		<xsl:if test="dataCarrierTypeCode = 'EAN_13' or dataCarrierTypeCode = 'UPC_A' or dataCarrierTypeCode = 'UPC_E'">
			<xsl:apply-templates select="$tradeItem/gtin" mode="r523"/>
			<xsl:apply-templates select="$tradeItem/nextLowerLevelTradeItemInformation/childTradeItem/gtin" mode="r523"/>
			<xsl:apply-templates select="$tradeItem/referencedTradeItem/gtin" mode="r523"/>
			<xsl:apply-templates select="$tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:promotional_item_information:xsd:3' and local-name()='promotionalItemInformationModule']/promotionalItemInformation/nonPromotionalTradeItem/gtin" mode="r523"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="gtin" mode="r523">
		<xsl:choose>
			<xsl:when test="starts-with(., '0')"/>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="523" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
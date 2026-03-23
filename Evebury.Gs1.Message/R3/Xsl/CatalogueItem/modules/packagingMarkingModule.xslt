<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:packaging_marking:xsd:3' and local-name()='packagingMarkingModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="packagingMarking" mode="packagingMarkingModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
			<xsl:with-param name="tradeItem" select="$tradeItem"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="packagingMarking" mode="packagingMarkingModule">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>
		<xsl:apply-templates select="consumerWarningInformation" mode="packagingMarkingModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>
		<!--Rule 1231: There must be at most one iteration of tradeItemDateOnPackagingFormatName  -->
		<xsl:for-each select="packagingDate">
			<xsl:variable name="date" select="."/>
			<xsl:for-each select="tradeItemDateOnPackagingFormatName">
				<xsl:variable name="value" select="."/>
				<xsl:if test="count($date[tradeItemDateOnPackagingFormatName = $value]) &gt; 1">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1231" />
					</xsl:apply-templates>
				</xsl:if>			
			</xsl:for-each>
		</xsl:for-each>

		<!--Rule 1660: If multiple iterations of packagingMarkedLabelAccreditationCode are used, then no two iterations SHALL be equal.-->
		<xsl:variable name="parent" select="."/>
		<xsl:for-each select="packagingMarkedLabelAccreditationCode">
			<xsl:variable name="value" select="."/>
			<xsl:if test="count($parent[packagingMarkedLabelAccreditationCode = $value]) &gt; 1">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1660" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>

		<!--Rule 1772: If targetMarketCountryCode equals <Geographic> and gpcCategoryCode is in GPC Segment '92000000' then isPackagingMarkedReturnable SHALL NOT equal 'true'.-->
		<xsl:if test="isPackagingMarkedReturnable = 'true' and contains('056, 442, 528', $targetMarket)">
			<xsl:variable name="brick" select="$tradeItem/gDSNTradeItemClassification/gpcCategoryCode"/>
			<xsl:if test="gs1:IsInSegment($brick, '92000000')">
				<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1772" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		
		<xsl:if test="$targetMarket= '756'">
			<!--Rule 1976: If targetMarketCountryCode equals <Geographic> and isTradeItemABaseUnit equals 'true' and isPriceOnPack equals 'true' then suggestedRetailPrice/tradeItemPrice SHALL be used.-->
			<xsl:if test="isPriceOnPack  = 'true' and $tradeItem/isTradeItemABaseUnit = 'true'">
				<xsl:if test="string($tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:sales_information:xsd:3' and local-name()='salesInformationModule']/tradeItemPriceInformation/suggestedRetailPrice/tradeItemPrice) = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1976" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>

			<!--Rule 2002: If targetMarketCountryCode equals <Geographic> and tradeItemDateOnPackagingTypeCode is used and tradeItemDateOnPackagingTypeCode is not in ('NO_DATE_MARKED', 'DISPLAY_UNTIL_DATE', 'FREEZING_DATE', 'PACKAGING_DATE', 'PRODUCTION_DATE') then minimumTradeItemLifespanFromTimeOfArrival SHALL be used or minimumTradeItemLifespanFromTimeOfProduction SHALL be used.-->
			<xsl:variable name="code" select="packagingDate/tradeItemDateOnPackagingTypeCode"/>
			<xsl:choose>
				<xsl:when test="string($code) = ''"/>
				<xsl:when test="$code = 'NO_DATE_MARKED'"/>
				<xsl:when test="$code = 'DISPLAY_UNTIL_DATE'"/>
				<xsl:when test="$code = 'FREEZING_DATE'"/>
				<xsl:when test="$code = 'PACKAGING_DATE'"/>
				<xsl:when test="$code = 'PRODUCTION_DATE'"/>
				<xsl:otherwise>
					<xsl:variable name="mod" select="$tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_lifespan:xsd:3' and local-name()='tradeItemLifespanModule']/tradeItemLifespan"/>
					<xsl:if test="string($mod/minimumTradeItemLifespanFromTimeOfArrival) = '' or string($mod/minimumTradeItemLifespanFromTimeOfProduction) = ''">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="2002" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>

		</xsl:if>
		
	</xsl:template>

	<xsl:template match="consumerWarningInformation" mode="packagingMarkingModule">
		<xsl:param name="targetMarket"/>
		<!--Rule 1541: If targetMarketCountryCode equals ('249' (France) or '250' (France) and consumerWarningDescription is used, then consumerWarningTypeCode shall be used.-->
		<xsl:if test="$targetMarket = '249' or $targetMarket = '250'">
			<xsl:if test="string(consumerWarningDescription) != '' and string(consumerWarningTypeCode) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1541" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
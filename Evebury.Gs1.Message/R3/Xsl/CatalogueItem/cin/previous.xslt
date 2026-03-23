<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl"
	>
	<xsl:output method="xml" indent="yes"/>
	<xsl:template match="/">
		<tradeItems>
			<xsl:call-template name="tradeItems">
				<xsl:with-param name="tradeItems" select="//tradeItem"/>
			</xsl:call-template>
		</tradeItems>
	</xsl:template>

	<xsl:template match="tradeItem">
		<tradeItem informationProvider="{informationProviderOfTradeItem/gln}" market="{targetMarket/targetMarketCountryCode}" gtin="{gtin}">
			<xsl:apply-templates select="preliminaryItemStatusCode" mode="node"/>
			<xsl:apply-templates select="tradeItemSynchronisationDates"/>
			<xsl:apply-templates select="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:delivery_purchasing_information:xsd:3' and local-name()='deliveryPurchasingInformationModule']/deliveryPurchasingInformation"/>
			<xsl:apply-templates select="tradeItemInformation/extension/*[namespace-uri() = 'urn:gs1:gdsn:trade_item_measurements:xsd:3' and local-name() = 'tradeItemMeasurementsModule']/tradeItemMeasurements"/>
			<xsl:apply-templates select="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:sales_information:xsd:3' and local-name()='salesInformationModule']/salesInformation"/>
			<xsl:apply-templates select="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_description:xsd:3' and local-name()='tradeItemDescriptionModule']/tradeItemDescriptionInformation"/>
			<xsl:apply-templates select="nextLowerLevelTradeItemInformation"/>
			<xsl:apply-templates select="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:allergen_information:xsd:3' and local-name()='allergenInformationModule']/allergenInformationModule"/>
		</tradeItem>
	</xsl:template>

	<xsl:template match="allergenInformationModule">
		<allergenInformationModule>
			<xsl:for-each select="allergenRelatedInformation/allergen">
				<allergen code="{allergenTypeCode}" level="{levelOfContainmentCode}"/>
			</xsl:for-each>
		</allergenInformationModule>
	</xsl:template>

	<xsl:template match="nextLowerLevelTradeItemInformation">
		<nextLowerLevelTradeItemInformation>
			<xsl:apply-templates select="totalQuantityOfNextLowerLevelTradeItem" mode="node"/>
			<xsl:for-each select="childTradeItem">
				<childTradeItem gtin="{gtin}"/>
			</xsl:for-each>
		</nextLowerLevelTradeItemInformation>
	</xsl:template>

	<xsl:template match="deliveryPurchasingInformation">
		<deliveryPurchasingInformation>
			<xsl:apply-templates select="endAvailabilityDateTime" mode="node"/>
		</deliveryPurchasingInformation>
	</xsl:template>

	<xsl:template match="tradeItemSynchronisationDates">
		<tradeItemSynchronisationDates>
			<xsl:apply-templates select="lastChangeDateTime" mode="node"/>
			<xsl:apply-templates select="discontinuedDateTime" mode="node"/>
			<xsl:apply-templates select="udidFirstPublicationDateTime" mode="node"/>
		</tradeItemSynchronisationDates>
	</xsl:template>

	<xsl:template match="tradeItemDescriptionInformation">
		<tradeItemDescriptionInformation>
			<xsl:apply-templates select="brandNameInformation/brandName" mode="node"/>
		</tradeItemDescriptionInformation>
	</xsl:template>

	<xsl:template match="tradeItemMeasurements">
		<tradeItemMeasurements>
			<xsl:apply-templates select="height" mode="node"/>
			<xsl:apply-templates select="width" mode="node"/>
			<xsl:apply-templates select="depth" mode="node"/>
			<xsl:apply-templates select="netContent" mode="node"/>
			<xsl:apply-templates select="tradeItemWeight/grossWeight" mode="node"/>
		</tradeItemMeasurements>
	</xsl:template>

	<xsl:template match="salesInformation">
		<salesInformation>
			<xsl:apply-templates select="priceComparisonMeasurement" mode="node"/>
		</salesInformation>
	</xsl:template>

	<xsl:template match="*" mode="node">
		<xsl:if test=". != ''">
			<xsl:element name="{local-name()}">
				<xsl:copy-of select="@*"/>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template name="tradeItems">
		<xsl:param name="tradeItems"/>
		<xsl:param name="index" select="1"/>
		<xsl:param name="count" select="count(msxsl:node-set($tradeItems))"/>
		<xsl:param name="keys"/>
		<xsl:if test="$index &lt;= $count">
			<xsl:variable name="tradeItem" select="msxsl:node-set($tradeItems)[$index]"/>
			<xsl:variable name="informationProvider" select="$tradeItem/informationProviderOfTradeItem/gln"/>
			<xsl:variable name="market" select="$tradeItem/targetMarket/targetMarketCountryCode"/>
			<!-- targetMarketSubdivisionCode ??-->
			<xsl:variable name="gtin" select="$tradeItem/gtin"/>

			<xsl:variable name="new" select="not(msxsl:node-set($keys)[@ip = $informationProvider and @ma = $market and @gtin = $gtin])"/>
			<xsl:if test="$new">
				<xsl:apply-templates select="$tradeItem"/>
			</xsl:if>
			<xsl:call-template name="tradeItems">
				<xsl:with-param name="tradeItems" select="$tradeItems"/>
				<xsl:with-param name="index" select="$index + 1"/>
				<xsl:with-param name="count" select="$count"/>
				<xsl:with-param name="keys">
					<xsl:copy-of select="$keys"/>
					<xsl:if test="$new">
						<key ip="{$informationProvider}" ma="{$market}" gtin="{$gtin}"/>
					</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>


</xsl:stylesheet>
<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:marketing_information:xsd:3' and local-name()='marketingInformationModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="marketingInformation" mode="marketingInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="marketingInformation" mode="marketingInformationModule">
		<xsl:param name="targetMarket"/>

		<xsl:apply-templates select="targetConsumer/targetConsumerUsage" mode="marketingInformationModule"/>
		<xsl:apply-templates select="season" mode="marketingInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>
		
		<!--Rule 341: If a start dateTime and its corresponding end dateTime are not empty then the start date SHALL be less than or equal to corresponding end date. -->
		<xsl:for-each select="marketingCampaign">
			<xsl:if test="gs1:InvalidDateTimeSpan(campaignStartDateTime, campaignEndDateTime)">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="341"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
		<!--Rule 1406: If targetMarketCountryCode is equal to ('840' (United States) and MarketingInformationModule/MarketingInformation/couponFamilyCode is not empty it shall be exactly 3 characters.-->
		<xsl:if test="$targetMarket = '840'">
			<xsl:if test="string(couponFamilyCode) != '' and string-length(couponFamilyCode) != 3">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1406" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<!--Rule 1806: If targetMarketCountryCode equals '752' (Sweden) and shortTradeItemMarketingMessage is used then tradeItemMarketingMessage SHALL be used.-->
		<xsl:if test="$targetMarket = '752'">
			<xsl:if test="string(shortTradeItemMarketingMessage) != '' and string(tradeItemMarketingMessage) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1806" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<!--Rule 1907: If targetMarketCountryCode equals <Geographic> and shortTradeItemMarketingMessage is used, then at least one iteration of shortTradeItemMarketingMessage/@languageCode SHALL be equal to 'fi' (Finnish) and 'sv' (Swedish).-->
		<xsl:if test="$targetMarket = '246'">
			<xsl:if test="shortTradeItemMarketingMessage">
				<xsl:choose>
					<xsl:when test="string(shortTradeItemMarketingMessage[@languageCode = 'fi']) != '' and string(shortTradeItemMarketingMessage[@languageCode = 'sv']) != ''"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1907" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:if>

	</xsl:template>


	<xsl:template match="season" mode="marketingInformationModule">
		<xsl:param name="targetMarket"/>
		<xsl:if test="gs1:InvalidDateTimeSpan(seasonalAvailabilityStartDateTime, seasonalAvailabilityEndDateTime)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="341"/>
			</xsl:apply-templates>
		</xsl:if>

		<!--Rule 1847: If targetMarketCountryCode equals '246' (Finland) and (seasonalAvailabilityEndDateTime or seasonalAvailabilityStartDateTime is used), then seasonalAvailabilityEndDateTime and seasonalAvailabilityStartDateTime SHALL be used.-->
		<xsl:if test="$targetMarket = '246'">
			<xsl:if test="(string(seasonalAvailabilityEndDateTime) != '' or string(seasonalAvailabilityStartDateTime) != '') and (string(seasonalAvailabilityEndDateTime) = '' or string(seasonalAvailabilityStartDateTime) = '')">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1847" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
		
	</xsl:template>
	
	<xsl:template match="targetConsumerUsage" mode="marketingInformationModule">
		<!--Rule 1803: If  targetConsumerUsageTypeCode is used THEN at least one of targetConsumerMinimumUsage or targetConsumerMaximumUsage SHALL be used.-->
		<xsl:if test="string(targetConsumerUsageTypeCode) != '' and string(targetConsumerMinimumUsage) = '' and string(targetConsumerMaximumUsage) =''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1803" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
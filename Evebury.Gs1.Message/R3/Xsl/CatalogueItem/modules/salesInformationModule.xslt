<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:sales_information:xsd:3' and local-name()='salesInformationModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="tradeItemPriceInformation" mode="salesInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="salesInformation" mode="salesInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
			<xsl:with-param name="tradeItem" select="$tradeItem"/>
		</xsl:apply-templates>

		<!--Rule 1102: If targetMarketCountryCode equals ('249' (France) or '250' (France)) and gpcCategoryCode equals '10000424' and isTradeItemAConsumerUnit equals 'TRUE' then at least one iteration of priceComparisonContentTypeCode shall equal 'PER_KILOGRAM' or 'PER_LITRE'-->
		<xsl:if test="$targetMarket = '249' or $targetMarket = '250'">
			<xsl:if test="$tradeItem/isTradeItemAConsumerUnit = 'true'">
				<xsl:variable name="brick" select="$tradeItem/gDSNTradeItemClassification/gpcCategoryCode"/>
				<xsl:if test="$brick = '10000424' and salesInformation">
					<xsl:choose>
						<xsl:when test="salesInformation[priceComparisonContentTypeCode = 'PER_KILOGRAM']"/>
						<xsl:when test="salesInformation[priceComparisonContentTypeCode = 'PER_LITRE']"/>
						<xsl:otherwise>
							<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="1102" />
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</xsl:if>
		</xsl:if>

	</xsl:template>

	<xsl:template match="tradeItemPriceInformation" mode="salesInformationModule">
		<xsl:param name="targetMarket"/>
		<!--Rule 341: If a start dateTime and its corresponding end dateTime are not empty then the start date SHALL be less than or equal to corresponding end date. -->
		<xsl:for-each select="additionalTradeItemPrice">
			<xsl:if test="gs1:InvalidDateTimeSpan(priceEffectiveStartDate, priceEffectiveEndDate)">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="341"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="cataloguePrice">
			<xsl:if test="gs1:InvalidDateTimeSpan(priceEffectiveStartDate, priceEffectiveEndDate)">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="341"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="suggestedRetailPrice">
			<xsl:if test="gs1:InvalidDateTimeSpan(priceEffectiveStartDate, priceEffectiveEndDate)">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="341"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>

		<!--Rule 520: If  targetMarketCountryCode equals '752' (Sweden) and priceBasisQuantity is used then related measurementUnitCode shall equal 'KGM', 'GRM', 'MTR','MLT', 'MMT', 'LTR', 'MTK', 'MTQ' or 'H87'.-->
		<xsl:if test="$targetMarket = '752'">
			<xsl:apply-templates select="additionalTradeItemPrice/priceBasisQuantity" mode="r520"/>
			<xsl:apply-templates select="cataloguePrice/priceBasisQuantity" mode="r520"/>
			<xsl:apply-templates select="suggestedRetailPrice/priceBasisQuantity" mode="r520"/>
		</xsl:if>

		<!--Rule 1082: If cataloguePrice/tradeItemPrice is used then tradeItemPriceTypeCode shall be empty.-->
		<xsl:for-each select="cataloguePrice">
			<xsl:if test="string(tradeItemPrice) != '' and string(tradeItemPriceTypeCode) != ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1082" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>

		<!--Rule 1083: If TradeItemPriceInformation/suggestedRetailPrice/tradeItemPrice is used then tradeItemPriceTypeCode shall be empty.-->
		<xsl:for-each select="suggestedRetailPrice/cataloguePrice">
			<xsl:if test="string(tradeItemPrice) != '' and string(tradeItemPriceTypeCode) != ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1083" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>

		
		<xsl:if test="$targetMarket  = '756'">

			<!--Rule 1965: If targetMarketCountryCode equals <Geographic> and cataloguePrice/tradeItemPrice is used then cataloguePrice/priceBasisQuantity SHALL be used and cataloguePrice/priceEffectiveStartDate SHALL be used.-->
			<xsl:for-each select="cataloguePrice">
				<xsl:if test="string(tradeItemPrice) != '' and (string(priceBasisQuantity) = '' or string(priceEffectiveStartDate) = '')">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1965" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:for-each>
			<!--Rule 1977: If targetMarketCountryCode equals <Geographic> and suggestedRetailPrice/tradeItemPrice is used then suggestedRetailPrice/priceEffectiveStartDate SHALL be used.-->
			<xsl:for-each select="suggestedRetailPrice">
				<xsl:if test="string(tradeItemPrice) != '' and string(priceEffectiveStartDate) = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1977" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
		

	</xsl:template>

	<xsl:template match="salesInformation" mode="salesInformationModule">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:if test="$targetMarket = '249' or $targetMarket = '250'">

			<!--Rule 1104: If targetMarketCountryCode equals '250' (France) and isTradeItemAConsumerUnit equals 'true' and if priceComparisonContentTypeCode equals 'PER_PIECE' then priceComparisonMeasurement shall be an Integer-->
			<xsl:if test="$tradeItem/isTradeItemAConsumerUnit = 'true'">
				<xsl:if test="priceComparisonContentTypeCode = 'PER_PIECE'">
					<xsl:if test="contains(priceComparisonMeasurement, '.')">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1104" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:if>
			</xsl:if>

			<!--Rule 1105: If targetMarketCountryCode equals  ('250' (France) or '246' (Finland)) and priceComparisonMeasurement is used, then priceComparisonMeasurement SHALL be greater than 0.-->
			<xsl:if test="string(priceComparisonMeasurement) != '' and priceComparisonMeasurement &lt;= 0">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1105" />
				</xsl:apply-templates>
			</xsl:if>

			<xsl:choose>
				<xsl:when test="priceComparisonContentTypeCode = 'PER_LITRE'">
					<!--Rule 1110: If targetMarketCountryCode equals ('249' (France) or '250' (France)) and gpcCategoryCode is not equal to ('10000050' or '10000262') 
and priceComparisonContentTypeCode equals 'PER_LITRE' then the associated measurementUnitCode of priceComparisonMeasurement and of one iteration of netContent shall be from the Unit Of Measure Classification 'VOLUME'-->
					<xsl:variable name="brick" select="$tradeItem/gDSNTradeItemClassification/gpcCategoryCode"/>
					<xsl:choose>
						<xsl:when test="$brick = '10000050'"/>
						<xsl:when test="$brick = '10000262'"/>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="string(priceComparisonMeasurement) = ''">
									<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
									<xsl:apply-templates select="." mode="error">
										<xsl:with-param name="id" select="1110" />
									</xsl:apply-templates>
								</xsl:when>
								<xsl:otherwise>
									<xsl:variable name="type">
										<xsl:apply-templates select="priceComparisonMeasurement" mode="measurementUnitType"/>
									</xsl:variable>
									<xsl:variable name="module" select="$tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_measurements:xsd:3' and local-name()='tradeItemMeasurementsModule']/tradeItemMeasurements"/>
									<xsl:variable name="netContent">
										<xsl:choose>
											<xsl:when test="$module/netContent">
												<xsl:for-each select="$module/netContent">
													<xsl:apply-templates select="." mode="measurementUnitType"/>
												</xsl:for-each>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="'Volume'"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<xsl:if test="$type != 'Volume' or $netContent = ''">
										<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
										<xsl:apply-templates select="." mode="error">
											<xsl:with-param name="id" select="1110" />
										</xsl:apply-templates>
									</xsl:if>
								</xsl:otherwise>
							</xsl:choose>

						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="priceComparisonContentTypeCode = 'PER_KILOGRAM'">
					<!--Rule 1116: If targetMarketCountryCode equals ('249' (France) or '250' (France)) and priceComparisonContentTypeCode equals 'PER_KILOGRAM' and netWeight is populated, then priceComparisonMeasurement and netWeight shall be equivalent.-->
					<xsl:choose>
						<xsl:when test="string(priceComparisonMeasurement) = ''">
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="1116" />
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="value">
								<xsl:apply-templates select="priceComparisonMeasurement" mode="measurementUnit"/>
							</xsl:variable>
							<xsl:variable name="module" select="$tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_measurements:xsd:3' and local-name()='tradeItemMeasurementsModule']/tradeItemMeasurements/tradeItemWeight"/>
							<xsl:variable name="weight">
								<xsl:choose>
									<xsl:when test="string($module/netWeight) = ''">
										<xsl:value-of select="-1"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="$module/netWeight" mode="measurementUnit"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:if test="$value != $weight">
								<xsl:apply-templates select="." mode="error">
									<xsl:with-param name="id" select="1116" />
								</xsl:apply-templates>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:when>
				<xsl:when test="priceComparisonContentTypeCode = 'DRAINED_WEIGHT'">
					<!--Rule 1117: If targetMarketCountryCode equals ('249' (France) or '250' (France)) and priceComparisonContentTypeCode equals 'DRAINED_WEIGHT' and drainedWeight is populated, then priceComparisonMeasurement and drainedWeight shall be equivalent.-->
					<xsl:choose>
						<xsl:when test="string(priceComparisonMeasurement) = ''">
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="1117" />
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="value">
								<xsl:apply-templates select="priceComparisonMeasurement" mode="measurementUnit"/>
							</xsl:variable>
							<xsl:variable name="module" select="$tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_measurements:xsd:3' and local-name()='tradeItemMeasurementsModule']/tradeItemMeasurements/tradeItemWeight"/>
							<xsl:variable name="weight">
								<xsl:choose>
									<xsl:when test="string($module/drainedWeight) = ''">
										<xsl:value-of select="-1"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="$module/drainedWeight" mode="measurementUnit"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:if test="$value != $weight">
								<xsl:apply-templates select="." mode="error">
									<xsl:with-param name="id" select="1117" />
								</xsl:apply-templates>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:when>
			</xsl:choose>

		</xsl:if>

		<!--Rule 1162: If targetMarketCountryCode equals '250' (France) or '752' (Sweden) and isTradeItemAConsumerUnit equals 'true' and isTradeItemNonphysical does not equal 'true' then both priceComparisonContentTypeCode and priceComparisonMeasurement SHALL be used.-->
		<xsl:if test="$targetMarket = '752' or $targetMarket = '250'">
			<xsl:if test="$tradeItem/isTradeItemAConsumerUnit = 'true' and string($tradeItem/isTradeItemNonphysical) != 'true'">
				<xsl:if test="string(priceComparisonContentTypeCode) = '' or string(priceComparisonMeasurement) =''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1162" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<!--Rule 1315: If priceComparisonContentTypeCode is used, then priceComparisonMeasurement shall be used.-->
		<xsl:if test="string(priceComparisonContentTypeCode) != '' and string(priceComparisonMeasurement) = ''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1315" />
			</xsl:apply-templates>
		</xsl:if>

		<!--Rule 1563: if  salesConditionTargetMarketCountry/countryCode is used, then targetMarketConsumerSalesConditionCode shall be used.-->
		<xsl:for-each select="targetMarketSalesConditions">
			<xsl:if test="salesConditionTargetMarketCountry">
				<xsl:choose>
					<xsl:when test="targetMarketConsumerSalesConditionCode"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1563" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:for-each>

		<!--Rule 1691: If targetMarketCountryCode equals 752 (Sweden) and  (priceComparisonContentTypeCode OR priceComparisonMeasurement is used), then priceComparisonContentTypeCode AND priceComparisonMeasurement SHALL be used.-->
		<xsl:if test="$targetMarket = '752'">
			<xsl:if test="string(priceComparisonContentTypeCode) != '' or string(priceComparisonMeasurement) != ''">
				<xsl:if test="string(priceComparisonContentTypeCode) = '' or string(priceComparisonMeasurement) = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1691" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>


		<xsl:if test="$targetMarket = '246'">

			<!--Rule 1848: If targetMarketCountryCode equals '246' (Finland) and priceComparisonMeasurement is used then at least one iteration of the related priceComparisonMeasurement/@measurementUnitCode SHALL equal 'KGM',  'LTR'  or 'H87’.-->
			<xsl:if test="string(priceComparisonMeasurement) != ''">
				<xsl:choose>
					<xsl:when test="priceComparisonMeasurement[@measurementUnitCode  = 'KGM' or @measurementUnitCode  = 'LTR' or @measurementUnitCode  = 'H87']"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1848" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>

			<!--Rule 1849: If targetMarketCountryCode equals <Geographic> and gpcCategoryCode is in GPC Segment '50000000' (Food/Beverage) and isTradeItemAConsumerUnit equals 'true' then priceComparisonMeasurement SHALL be used.-->
			<xsl:if test="string(priceComparisonMeasurement) = '' and $tradeItem/isTradeItemAConsumerUnit = 'true'">
				<xsl:variable name="brick" select="$tradeItem/gDSNTradeItemClassification/gpcCategoryCode"/>
				<xsl:if test="gs1:IsInSegment($brick, '50000000')">
					<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1849" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>

		</xsl:if>


		<xsl:if test="$targetMarket = '756'">
			<xsl:for-each select=".//priceBasisQuantity">

				<!--Rule 1944: If targetMarketCountryCode equals <Geographic> and priceBasisQuantity is used then priceBasisQuantity/@measurementUnitCode SHALL equal ('H87', 'KGM', 'LTR' or 'MTR').-->
				<xsl:choose>
					<xsl:when test="@measurementUnitCode  = 'H87'"/>
					<xsl:when test="@measurementUnitCode  = 'KGM'"/>
					<xsl:when test="@measurementUnitCode  = 'LTR'"/>
					<xsl:when test="@measurementUnitCode  = 'MTR'"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1944" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>

				<!--Rule 1945: If targetMarketCountryCode equals <Geographic> and priceBasisQuantity is used then priceBasisQuantity SHALL equal 1, 10, 100 or 1000.-->
				<xsl:choose>
					<xsl:when test=". = '1'"/>
					<xsl:when test=". = '10'"/>
					<xsl:when test=". = '100'"/>
					<xsl:when test=". = '1000'"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1945" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:for-each>

			<!--Rule 1953: If targetMarketCountryCode equals <Geographic> and isTradeItemABaseUnit equals 'true' and brandDistributionTradeItemTypeCode equals 'CUSTOM_LABEL' then brandDistributionTradeItemTypeCode SHALL equal 'CUSTOM_LABEL' on all levels of the trade item hierarchy.-->
			<xsl:if test="brandDistributionTradeItemTypeCode = 'CUSTOM_LABEL'">
				<xsl:variable name="child" select="tradeItem/../catalogueItemChildItemLink/tradeItem/extension/*[namespace-uri()='urn:gs1:gdsn:sales_information:xsd:3' and local-name()='salesInformationModule']/salesInformation"/>
				<xsl:if test="$child and $child[brandDistributionTradeItemTypeCode != 'CUSTOM_LABEL']">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1953" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<xsl:if test="$targetMarket = '756' or $targetMarket = '040'">
			<!--Rule 1956: If targetMarketCountryCode equals <Geographic> and isTradeItemABaseUnit equals 'true' and brandDistributionTradeItemTypeCode equals 'PRIVATE_LABEL' then brandDistributionTradeItemTypeCode SHALL equal 'PRIVATE_LABEL' on all levels of the trade item hierarchy.-->
			<xsl:if test="brandDistributionTradeItemTypeCode = 'PRIVATE_LABEL'">
				<xsl:variable name="child" select="tradeItem/../catalogueItemChildItemLink/tradeItem/extension/*[namespace-uri()='urn:gs1:gdsn:sales_information:xsd:3' and local-name()='salesInformationModule']/salesInformation"/>
				<xsl:if test="$child and $child[brandDistributionTradeItemTypeCode != 'PRIVATE_LABEL']">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1956" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>

			<!--Rule 2019: If targetMarketCountryCode equals <Geographic> and isBasePriceDeclarationRelevant is used then isBasePriceDeclarationRelevant SHALL equal ('TRUE' or 'FALSE').-->
			<xsl:if test="string(isBasePriceDeclarationRelevant) != '' and string(isBasePriceDeclarationRelevant) != 'TRUE' and string(isBasePriceDeclarationRelevant) != 'FALSE'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="2019" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

	

	</xsl:template>

	<xsl:template match="priceBasisQuantity" mode="r520">
		<xsl:choose>
			<xsl:when test="@measurementUnitCode = 'KGM'"/>
			<xsl:when test="@measurementUnitCode = 'GRM'"/>
			<xsl:when test="@measurementUnitCode = 'MTR'"/>
			<xsl:when test="@measurementUnitCode = 'MLT'"/>
			<xsl:when test="@measurementUnitCode = 'MMT'"/>
			<xsl:when test="@measurementUnitCode = 'LTR'"/>
			<xsl:when test="@measurementUnitCode = 'MTK'"/>
			<xsl:when test="@measurementUnitCode = 'MTQ'"/>
			<xsl:when test="@measurementUnitCode = 'H87'"/>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="520" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
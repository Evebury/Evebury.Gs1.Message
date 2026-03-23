<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:food_and_beverage_preparation_serving:xsd:3' and local-name()='foodAndBeveragePreparationServingModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="preparationServing" mode="foodAndBeveragePreparationServingModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="servingQuantityInformation" mode="foodAndBeveragePreparationServingModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
			<xsl:with-param name="tradeItem" select="$tradeItem"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="servingQuantityInformation" mode="foodAndBeveragePreparationServingModule">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>
		
		<!--Rule 1663: If targetMarketCountryCode equals (528 (Netherlands), 276 (Germany), 250 (France), 056 (Belgium), 442 (Luxembourg), 208 (Denmark), 203 (Czech Republic), 246 (Finland), 826 (UK), 380 (Italy) or 040 (Austria)) and numberOfServingsPerPackage is used, then it SHALL be greater than zero.-->
		<xsl:if test="contains('056, 442, 528, 276, 208, 203, 250, 246, 040, 380', $targetMarket) and string(numberOfServingsPerPackage) != ''">
			<xsl:if test="numberOfServingsPerPackage &lt;= 0">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1663" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<!--Rule 1777: If gpcCategoryCode is a brick from the segment '50000000' and numberOfSmallestUnitsPerPackage is used, then numberOfSmallestUnitsPerPackage SHALL be greater than 0.-->
		<xsl:variable name="brick" select="$tradeItem/gDSNTradeItemClassification/gpcCategoryCode"/>
		<xsl:if test="gs1:IsInSegment($brick, '50000000') and string(numberOfSmallestUnitsPerPackage) != '' and numberOfSmallestUnitsPerPackage &lt;= 0">
			<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1777" />
			</xsl:apply-templates>
		</xsl:if>

	
		<xsl:if test="$targetMarket = '756'">

			<!--Rule 1954: If targetMarketCountryCode equals <Geographic> and numberOfServingsPerPackageMeasurementPrecisionCode is used then numberOfServingsPerPackageMeasurementPrecisionCode SHALL equal 'APPROXIMATELY'.-->
			<xsl:if test="string(numberOfServingsPerPackageMeasurementPrecisionCode) != '' and numberOfServingsPerPackageMeasurementPrecisionCode != 'APPROXIMATELY'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1954" />
				</xsl:apply-templates>
			</xsl:if>

			<!--Rule 1979: If targetMarketCountryCode equals <Geographic> and numberOfServingsPerPackageMeasurementPrecisionCode is used then numberOfServingsPerPackage SHALL be used.-->
			<xsl:if test="string(numberOfServingsPerPackageMeasurementPrecisionCode) != '' and string(numberOfServingsPerPackage) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1979" />
				</xsl:apply-templates>
			</xsl:if>
			
		</xsl:if>

		<xsl:if test="$targetMarket = '756' or $targetMarket = '040'">
			<!--Rule 1980: If targetMarketCountryCode equals <Geographic> and numberOfServingsPerPackage is used then numberOfServingsRangeDescription SHALL NOT be used.-->
			<xsl:if test="string(numberOfServingsPerPackage) != '' and string(numberOfServingsRangeDescription) != ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1980" />
				</xsl:apply-templates>
			</xsl:if>
			
		</xsl:if>
		
	</xsl:template>

	<xsl:template match="preparationServing" mode="foodAndBeveragePreparationServingModule">
		<xsl:param name="targetMarket"/>
		<!--Rule 362: If a minimum and corresponding maximum are not empty then the minimum SHALL be less than or equal to the corresponding maximum.-->
		<xsl:if test="gs1:InvalidRange(minimumOptimumConsumptionTemperature,maximumOptimumConsumptionTemperature)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="362"/>
			</xsl:apply-templates>
		</xsl:if>

		<!--Rule 1090: If targetMarketCountryCode does not equal <Geographic> and ProductYieldInformation/productYield is used then PreparationServing/preparationTypeCode SHALL be used.-->
		<xsl:if test="$targetMarket = '246'">
			<xsl:if test="productYieldInformation[string(productYield) != ''] and string(preparationTypeCode) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1090" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

	
		<xsl:for-each select="productYieldInformation">
			<!--Rule 1091: If ProductYieldInformation/productYield is not empty then ProductYieldInformation/productYieldTypeCode must not be empty.-->
			<xsl:if test="string(productYield) != '' and string(productYieldTypeCode) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1091" />
				</xsl:apply-templates>
			</xsl:if>
			<!--Rule 1410: If productYieldTypeCode  is used then productYield shall be used.-->
			<xsl:if test="string(productYield) = '' and string(productYieldTypeCode) != ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1410" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>

		<!--Rule 1866: If targetMarketCountryCode equals <Geographic> and preparationInstructions is used then preparationTypeCode SHALL be used.-->
		<xsl:if test="string(preparationTypeCode) ='' and string(preparationInstructions) != '' and contains('752, 756, 040', $targetMarket)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1866" />
			</xsl:apply-templates>
		</xsl:if>

	
		<xsl:if test="$targetMarket = '246'">
			<!--Rule 1904: If targetMarketCountryCode equals <Geographic> and preparationInstructions is used, then one iteration of preparationInstructions/@languageCode SHALL be equal to 'fi' (Finnish) and 'sv' (Swedish).-->
			<xsl:if test="preparationInstructions">
				<xsl:choose>
					<xsl:when test="string(preparationInstructions[@languageCode = 'fi']) != '' and string(preparationInstructions[@languageCode = 'sv']) != ''"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1904" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<!--Rule 1905: If targetMarketCountryCode equals <Geographic> and servingSuggestion is used, then one iteration of servingSuggestion/@languageCode SHALL be equal to 'fi' (Finnish) and 'sv' (Swedish).-->
			<xsl:if test="servingSuggestion">
				<xsl:choose>
					<xsl:when test="string(servingSuggestion[@languageCode = 'fi']) != '' and string(servingSuggestion[@languageCode = 'sv']) != ''"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1905" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:if>

		<xsl:if test="$targetMarket = '756' or $targetMarket = '040'">
			<!--Rule 2033: If targetMarketCountryCode equals <Geographic> and preparationTypeCode is used and preparationTypeCode is not equal to ('READY_TO_DRINK' or 'READY_TO_EAT') then preparationInstructions SHALL be used.-->
			<xsl:if test="string(preparationTypeCode) != 'READY_TO_DRINK' and string(preparationTypeCode) != 'READY_TO_EAT' and string(preparationInstructions) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="2033" />
				</xsl:apply-templates>
			</xsl:if>
			<!--Rule 2034: If targetMarketCountryCode equals <Geographic> and preparationTypeCode is used then preparationTypeCode SHALL NOT equal ('PREPARED' or 'UNPREPARED').-->
			<xsl:if test="preparationTypeCode = 'PREPARED' or preparationTypeCode = 'UNPREPARED'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="2034" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<xsl:if test="$targetMarket = '756'">
			<!--Rule 2035: If targetMarketCountryCode equals <Geographic> and productYieldVariationPercentage is used then productYield SHALL be used.-->
			<xsl:if test="string(productYieldVariationPercentage) != '' and string(productYield) =''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="2035" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

	</xsl:template>

</xsl:stylesheet>
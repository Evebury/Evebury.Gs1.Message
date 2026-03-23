<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:place_of_item_activity:xsd:3' and local-name()='placeOfItemActivityModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="importClassification" mode="placeOfItemActivityModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
			<xsl:with-param name="tradeItem" select="$tradeItem"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="placeOfProductActivity" mode="placeOfItemActivityModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
			<xsl:with-param name="tradeItem" select="$tradeItem"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="importClassification" mode="placeOfItemActivityModule">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<!--Rule 583: If importClassificationTypeCode is not empty then importClassificationValue must not be empty.-->
		<xsl:if test="string(importClassificationTypeCode) != '' and string(importClassificationValue) = ''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="583" />
			</xsl:apply-templates>
		</xsl:if>
		<!--Rule 584: If importClassificationValue  is not empty then  importClassificationTypeCode must not be empty.-->
		<xsl:if test="string(importClassificationValue) != '' and string(importClassificationTypeCode) = ''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="584" />
			</xsl:apply-templates>
		</xsl:if>

		<!--Rule 1693: If targetMarketCountryCode equals <Geographic> and importClassificationTypeCode equals 'INTRASTAT' then corresponding importClassificationValue SHALL have exactly 8 digits.-->
		<xsl:if test="importClassificationTypeCode  = 'INTRASTAT'">
			<xsl:if test="contains('056, 528, 442, 756, 380, 752', $targetMarket)">
				<xsl:if test="importClassificationValue != number(importClassificationValue) or string-length(importClassificationValue) != 8">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1693" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<!--Rule 1821: If targetMarketCountryCode equals '250' (France) and importClassificationTypeCode equals 'CUSTOMS_TARIFF_NUMBER', then the corresponding importClassificationValue SHALL have a value between 8 and 13 numeric characters in length.-->
		<xsl:if test="$targetMarket = '250'">
			<xsl:if test="importClassificationTypeCode  = 'CUSTOMS_TARIFF_NUMBER'">
				<xsl:variable name="length" select="string-length(importClassificationValue)"/>
				<xsl:if test="importClassificationValue != number(importClassificationValue) or $length &lt; 8 or $length &gt; 13">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1821" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<xsl:if test="$targetMarket = '756' or $targetMarket = '040'">
			<!--Rule 1978: If targetMarketCountryCode equals <Geographic> and statisticalReportingMeasurement is used then importClassificationValue SHALL be used.-->

			<xsl:if test="string(statisticalReportingMeasurement) != '' and string(importClassificationValue) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1978" />
				</xsl:apply-templates>
			</xsl:if>

			<!--Rule 2028: If targetMarketCountryCode equals <Geographic> and statisticalReportingMeasurement is used then statisticalReportingMeasurement/@measurementUnitCode SHALL equal 'H87'.-->
			<xsl:if test="string(statisticalReportingMeasurement) != '' and statisticalReportingMeasurement/@measurementUnitCode != 'H87'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="2028" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>



		<xsl:if test="$targetMarket = '756'">
			<!--Rule 2025: If targetMarketCountryCode equals <Geographic> and importClassificationTypeCode equals 'CUSTOMS_TARIFF_NUMBER' then importClassificationValue SHALL have exactly 11 digits.-->
			<xsl:if test="importClassificationTypeCode = 'CUSTOMS_TARIFF_NUMBER' and string-length(importClassificationValue) != 11 and number(importClassificationValue) != importClassificationValue">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="2025" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<xsl:if test="contains('756, 203, 380, 705', $targetMarket)">
			<!--Rule 2027: If targetMarketCountryCode equals <Geographic> and importClassificationTypeCode equals 'TARIF_INTEGRE_DE_LA_COMMUNAUTE' then corresponding importClassificationValue SHALL have exactly 10 digits.-->
			<xsl:if test="importClassificationTypeCode = 'TARIF_INTEGRE_DE_LA_COMMUNAUTE' and string-length(importClassificationValue) != 10 and number(importClassificationValue) != importClassificationValue">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="2027" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<xsl:if test="contains('056, 203, 250, 380, 442, 528, 703, 752', $targetMarket)">


			<xsl:if test="importClassificationTypeCode = 'INTRASTAT' or importClassificationTypeCode = 'TARIF_INTEGRE_DE_LA_COMMUNAUTE' or importClassificationTypeCode = 'CUSTOMS_TARIFF_NUMBER'">

				<!--Rule 102077: If targetMarketCountryCode equals <Geographic> and importClassificationTypeCode equals ('INTRASTAT', 'TARIF_INTEGRE_DE_LA_COMMUNAUTE' or 'CUSTOMS_TARIFF_NUMBER') and importClassificationValue starts with ('010221', '010229', '0901', '1201', '120710', '120810', '1507', '1511', '1801', '1802', '1803', '1804', '1805', '1806', '2304' or '230660') then at least one iteration of regulationTypeCode SHALL equal 'DEFORESTATION_REGULATION' and isTradeItemRegulationCompliant SHALL equal 'TRUE' in the same iteration.-->
				<xsl:if test="starts-with(importClassificationValue, '010221') or starts-with(importClassificationValue, '010229') or starts-with(importClassificationValue, '0901') or starts-with(importClassificationValue, '1201') or starts-with(importClassificationValue, '120710') or starts-with(importClassificationValue, '120810') or starts-with(importClassificationValue, '1507') or starts-with(importClassificationValue, '1511') or starts-with(importClassificationValue, '1801') or starts-with(importClassificationValue, '1802') or starts-with(importClassificationValue, '1803') or starts-with(importClassificationValue, '1804') or starts-with(importClassificationValue, '1805') or starts-with(importClassificationValue, '1806') or starts-with(importClassificationValue, '2304') or starts-with(importClassificationValue, '230660')">
					<xsl:variable name="mod" select="$tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:regulated_trade_item:xsd:3' and local-name()='regulatedTradeItemModule']/regulatoryInformation"/>
					<xsl:choose>
						<xsl:when test="$mod">
							<xsl:choose>
								<xsl:when test="$mod[regulationTypeCode = 'DEFORESTATION_REGULATION' and isTradeItemRegulationCompliant = 'TRUE']"/>
								<xsl:otherwise>
									<xsl:apply-templates select="." mode="error">
										<xsl:with-param name="id" select="102077" />
									</xsl:apply-templates>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="102077" />
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<!--Rule 102078: If targetMarketCountryCode equals <Geographic> and importClassificationTypeCode equals ('INTRASTAT', 'TARIF_INTEGRE_DE_LA_COMMUNAUTE' or 'CUSTOMS_TARIFF_NUMBER') and importClassificationValue starts with ('0201', '0202', '020610', '020622', '020629', '151321', '151329', '160250', '290545', '291570', '291590', '382311', '382312', '382319', '382370', '4001', '4005', '4006', '4007', '4008', '4010', '4011', '4012', '4013', '4015', '4016', '4017', '4101', '4104', '4107', '4401', '4402', '4403', '4404', '4405', '4406', '4407', '4408', '4409', '4410', '4411', '4412', '4413', '4414', '4415', '4416', '4417', '4418', '4419', '4420', '4421', '47', '48', '49', '9401', '940330', '940340', '940350', '940360', '940391' or '940610') then at least one iteration of regulationTypeCode SHALL equal 'DEFORESTATION_REGULATION' and isTradeItemRegulationCompliant SHALL equal 'TRUE' or 'NOT_APPLICABLE' in the same iteration.​-->
				<xsl:if test="string(importClassificationValue) != ''">
					<xsl:if test="starts-with(importClassificationValue, '0201') or starts-with(importClassificationValue, '0202') or starts-with(importClassificationValue, '020610') or starts-with(importClassificationValue, '020622') or starts-with(importClassificationValue, '020629') or starts-with(importClassificationValue, '151321') or starts-with(importClassificationValue, '151329') or starts-with(importClassificationValue, '160250') or starts-with(importClassificationValue, '290545') or starts-with(importClassificationValue, '291570') or starts-with(importClassificationValue, '291590') or starts-with(importClassificationValue, '382311') or starts-with(importClassificationValue, '382312') or starts-with(importClassificationValue, '382319') or starts-with(importClassificationValue, '382370') or starts-with(importClassificationValue, '4001') or starts-with(importClassificationValue, '4005') or starts-with(importClassificationValue, '4006') or starts-with(importClassificationValue, '4007') or starts-with(importClassificationValue, '4008') or starts-with(importClassificationValue, '4010') or starts-with(importClassificationValue, '4011') or starts-with(importClassificationValue, '4012') or starts-with(importClassificationValue, '4013') or starts-with(importClassificationValue, '4015') or starts-with(importClassificationValue, '4016') or starts-with(importClassificationValue, '4017') or starts-with(importClassificationValue, '4101') or starts-with(importClassificationValue, '4104') or starts-with(importClassificationValue, '4107') or starts-with(importClassificationValue, '4401') or starts-with(importClassificationValue, '4402') or starts-with(importClassificationValue, '4403') or starts-with(importClassificationValue, '4404') or starts-with(importClassificationValue, '4405') or starts-with(importClassificationValue, '4406') or starts-with(importClassificationValue, '4407') or starts-with(importClassificationValue, '4408') or starts-with(importClassificationValue, '4409') or starts-with(importClassificationValue, '4410') or starts-with(importClassificationValue, '4411') or starts-with(importClassificationValue, '4412') or starts-with(importClassificationValue, '4413') or starts-with(importClassificationValue, '4414') or starts-with(importClassificationValue, '4415') or starts-with(importClassificationValue, '4416') or starts-with(importClassificationValue, '4417') or starts-with(importClassificationValue, '4418') or starts-with(importClassificationValue, '4419') or starts-with(importClassificationValue, '4420') or starts-with(importClassificationValue, '4421') or starts-with(importClassificationValue, '47') or starts-with(importClassificationValue, '48') or starts-with(importClassificationValue, '49') or starts-with(importClassificationValue, '9401') or starts-with(importClassificationValue, '940330') or starts-with(importClassificationValue, '940340') or starts-with(importClassificationValue, '940350') or starts-with(importClassificationValue, '940360') or starts-with(importClassificationValue, '940391') or starts-with(importClassificationValue, '940610')">
						<xsl:variable name="mod" select="$tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:regulated_trade_item:xsd:3' and local-name()='regulatedTradeItemModule']/regulatoryInformation"/>
						<xsl:choose>
							<xsl:when test="$mod">
								<xsl:choose>
									<xsl:when test="$mod[regulationTypeCode = 'DEFORESTATION_REGULATION' and (isTradeItemRegulationCompliant = 'TRUE' or isTradeItemRegulationCompliant = 'NOT_APPLICABLE')]"/>
									<xsl:otherwise>
										<xsl:apply-templates select="." mode="error">
											<xsl:with-param name="id" select="102078" />
										</xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="." mode="error">
									<xsl:with-param name="id" select="102078" />
								</xsl:apply-templates>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
				</xsl:if>
			</xsl:if>

		</xsl:if>


	</xsl:template>

	<xsl:template match="placeOfProductActivity" mode="placeOfItemActivityModule">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>
		<xsl:apply-templates select="productActivityDetails" mode="placeOfItemActivityModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
			<xsl:with-param name="tradeItem" select="$tradeItem"/>
		</xsl:apply-templates>
		<!--Rule 1656: If the class CountryOfOrigin or MaterialCountryOfOrigin is repeated, then no two iterations of countryCode in  this class SHALL be equal.-->
		<xsl:variable name="parent" select="."/>
		<xsl:for-each select="countryOfOrigin/countryCode">
			<xsl:variable name="value" select="."/>
			<xsl:if test="count($parent/countryOfOrigin[countryCode = $value]) &gt; 1">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1656" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>

	</xsl:template>

	<xsl:template match="productActivityDetails" mode="placeOfItemActivityModule">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<!--Rule 1702: If <Geographic> and If catchAreaCode is used and PlaceOfItemActivityModule/../productActivityTypeCode equals 'CATCH_ZONE', then catchAreaCode shall equal PlaceOfItemActivityModule/../productActivityRegionZoneCodeReference/enumerationValueInformation/enumerationValue-->
		<xsl:if test="productActivityTypeCode  = 'CATCH_ZONE'">
			<xsl:if test="contains('008, 051, 031, 040, 112, 056, 070, 100, 191, 196, 203, 208, 233, 246, 250, 276, 268, 300, 348, 352, 372, 376, 380, 398, 417, 428, 440, 442, 807, 498, 499, 528, 578, 616, 620, 642, 643, 688, 703, 705, 756, 792, 795, 826, 804, 860', $targetMarket)">
				<xsl:variable name="module" select="$tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:dairy_fish_meat_poultry:xsd:3' and local-name()='dairyFishMeatPoultryItemModule']/dairyFishMeatPoultryInformation/fishReportingInformation"/>
				<xsl:for-each select="productActivityRegionZoneCodeReference/enumerationValueInformation/enumerationValue">
					<xsl:variable name="value" select="."/>
					<xsl:choose>
						<xsl:when test="$module/fishCatchInformation[catchAreaCode = $value]"/>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="1702" />
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:if>
		</xsl:if>

		<!--Rule 1719: If targetMarketCountryCode equals <Geographic> and placeOfItemActivityModule/../productActivityTypeCode equals 'CATCH_ZONE' then placeOfItemActivityModule/../productActivityRegionZoneCodeReference/enumerationValueInformation/enumerationValue SHALL NOT be in ('27', '37').-->
		<xsl:if test="productActivityTypeCode  = 'CATCH_ZONE'">
			<xsl:if test="$targetMarket = '276'">
				<xsl:if test="productActivityRegionZoneCodeReference/enumerationValueInformation[enumerationValue = '27' or enumerationValue = '37']">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1719" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<xsl:if test="$targetMarket = '756'">
			<!--Rule 2018: If targetMarketCountryCode equals <Geographic> and countryOfActivity/countryCode is used and corresponding productActivityTypeCode equals 'LAST_PROCESSING' then countryOfActivity/countryCode SHALL NOT equal ('097' or 'NON_EU').-->
			<xsl:if test="productActivityTypeCode = 'LAST_PROCESSING'">
				<xsl:if test="countryOfActivity[countryCode = '097'] or countryOfActivity[countryCode = 'NON_EU']">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="2018" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>

		</xsl:if>

	</xsl:template>

</xsl:stylesheet>
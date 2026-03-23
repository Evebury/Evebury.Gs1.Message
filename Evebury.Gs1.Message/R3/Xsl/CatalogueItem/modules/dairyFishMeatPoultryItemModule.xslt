<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:dairy_fish_meat_poultry:xsd:3' and local-name()='dairyFishMeatPoultryItemModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="dairyFishMeatPoultryInformation" mode="dairyFishMeatPoultryItemModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="dairyFishMeatPoultryInformation" mode="dairyFishMeatPoultryItemModule">
		<xsl:param name="targetMarket"/>

		<xsl:apply-templates select="cheeseInformation" mode="dairyFishMeatPoultryItemModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="fishReportingInformation" mode="dairyFishMeatPoultryItemModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>

		<!--Rule 1939: If targetMarketCountryCode equals <Geographic> and fatPercentageInDryMatter is used then fatInMilkContent SHALL NOT be used.-->
		<xsl:if test="$targetMarket = '756'">
			<xsl:if test="cheeseInformation[string(fatPercentageInDryMatter) != '']">
				<xsl:if test="fatInMilkContent != ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1939" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>
		
	</xsl:template>

	<xsl:template match="fishReportingInformation" mode="dairyFishMeatPoultryItemModule">
		<xsl:param name="targetMarket"/>
		<xsl:apply-templates select="fishCatchInformation" mode="dairyFishMeatPoultryItemModule"/>
		
		<xsl:variable name="isEU" select="contains('008, 051, 031, 112, 056, 070, 100, 191, 196, 203, 208, 233, 246, 250, 268, 300, 348, 352, 372, 376, 380, 398, 417, 428, 440, 442, 807, 498, 499, 528, 578, 616, 620, 642, 643, 688, 703, 705, 724, 752, 792, 795, 826, 804, 860', $targetMarket)"/>
		<!--Rule 1585: If targetMarketCountryCode equals EU and catchMethodCode is used then at least one iteration of catchMethodCode SHALL equal ('01', '02', '03', '04', '05', '07', '08' or '09').-->
		<xsl:if test="$isEU">
			<xsl:for-each select="fishCatchInformation/catchMethodCode">
				<xsl:choose>
					<xsl:when test=". = '01'"/>
					<xsl:when test=". = '02'"/>
					<xsl:when test=". = '03'"/>
					<xsl:when test=". = '04'"/>
					<xsl:when test=". = '05'"/>
					<xsl:when test=". = '07'"/>
					<xsl:when test=". = '08'"/>
					<xsl:when test=". = '09'"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1585" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:if>

		<!--Rule 1696: If targetMarket/countryCode in ('276' Germany or '040' Austria) and catchAreaCode is used then catchAreaCode SHALL NOT be in ('27', '37').-->
		<xsl:if test="$targetMarket = '270' or $targetMarket = '040'">
			<xsl:if test="fishCatchInformation[catchMethodCode = '27'] or fishCatchInformation[catchMethodCode = '37']">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1696" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
		
	</xsl:template>

	<xsl:template match="fishCatchInformation" mode="dairyFishMeatPoultryItemModule">
		<!--Rule 1840: If productionMethodForFishAndSeafoodCode equals 'MARINE_FISHERY' then catchCountryCode SHALL NOT be used.-->
		<xsl:if test="productionMethodForFishAndSeafoodCode = 'MARINE_FISHERY' and string(catchCountryCode) != ''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1840" />
			</xsl:apply-templates>
		</xsl:if>

		<!--Rule 1841: If catchCountryCode and catchAreaCode are used then catchAreaCode SHALL equal (’01’, ‘02’, ’03’, ’04’, ’05’, ’06’, ’07, or ’08’).-->
		<xsl:if test="string(catchAreaCode) != '' and string(catchCountryCode) != ''">
			<xsl:choose>
				<xsl:when test="contains('01, 02, 03, 04, 05, 06, 07, 08', catchAreaCode)"/>
				<xsl:otherwise>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1841" />
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

		<!--Rule 1842: If productionMethodForFishAndSeafoodCode equals ‘INLAND_FISHERY' and catchAreaCode is used then catchAreaCode SHALL equal (’01’, ‘02’, ’03’, ’04’, ’05’, ’06’, ’07, or ’08’).-->
		<xsl:if test="productionMethodForFishAndSeafoodCode = 'INLAND_FISHERY'">
			<xsl:choose>
				<xsl:when test="contains('01, 02, 03, 04, 05, 06, 07, 08', catchAreaCode)"/>
				<xsl:otherwise>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1842" />
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="cheeseInformation" mode="dairyFishMeatPoultryItemModule">
		<xsl:param name="targetMarket"/>
		<!--Rule 1034: If fatPercentageInDryMatter is not empty then value must be greater than or equal to 0 and less than or equal to 100.00.-->
		<xsl:if test="string(fatPercentageInDryMatter) != '' and (fatPercentageInDryMatter &lt; 0 or fatPercentageInDryMatter &gt; 100)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1034" />
			</xsl:apply-templates>
		</xsl:if>

		
		<xsl:if test="$targetMarket = '756' or $targetMarket = '040'">

			<!--Rule 1948: If targetMarketCountryCode equals <Geographic> and fatPercentageInDryMatterMeasurementPrecisionCode is used then fatPercentageInDryMatter SHALL be used.-->
			<xsl:if test="string(fatPercentageInDryMatterMeasurementPrecisionCode) != '' and string(fatPercentageInDryMatter) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1948" />
				</xsl:apply-templates>
			</xsl:if>

			<!--Rule 2013: If targetMarketCountryCode equals <Geographic> and fatPercentageInDryMatterMeasurementPrecisionCode is used then fatPercentageInDryMatterMeasurementPrecisionCode SHALL equal 'GREATER_THAN_OR_EQUAL'.-->
			<xsl:if test="string(fatPercentageInDryMatterMeasurementPrecisionCode) != '' and string(fatPercentageInDryMatterMeasurementPrecisionCode) != 'GREATER_THAN_OR_EQUAL'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="2013" />
				</xsl:apply-templates>
			</xsl:if>

			<!--Rule 2029: If targetMarketCountryCode equals <Geographic> and ripeningTimePeriod is used then ripeningTimePeriod/@measurementUnitCode SHALL equal ('ANN', 'DAY', 'HUR', 'MIN', 'MON', 'SEC' or 'WEE').-->
			<xsl:if test="string(ripeningTimePeriod) != ''">
				<xsl:choose>
					<xsl:when test="contains('ANN, DAY, HUR, MIN, MON, SEC, WEE', ripeningTimePeriod/@measurementUnitCode)"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="2029" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
				
			</xsl:if>
		</xsl:if>
		
	</xsl:template>

</xsl:stylesheet>
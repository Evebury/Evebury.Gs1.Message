<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:battery_information:xsd:3' and local-name()='batteryInformationModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="batteryDetail" mode="batteryInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>

		<!--Rule 1741: If targetMarketCountryCode equals <Geographic> and areBatteriesRequired equals 'true' then areBatteriesIncluded SHALL be used.-->
		<xsl:if test="contains('040, 056, 208, 246, 250, 276, 442, 528, 756', $targetMarket)" >
			<xsl:if test="areBatteriesRequired  = 'true' and string(areBatteriesIncluded) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1741" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

	</xsl:template>

	<xsl:template match="batteryDetail" mode="batteryInformationModule">
		<xsl:param name="targetMarket"/>
		<xsl:apply-templates select="batteryMaterials" mode="batteryInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>
		<!--Rule 1781: If quantityOfBatteriesBuiltIn is used, then quantityOfBatteriesBuiltIn SHALL be greater than 0.-->
		<xsl:if test="string(quantityOfBatteriesBuiltIn) != '' and quantityOfBatteriesBuiltIn &lt;= 0">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1781" />
			</xsl:apply-templates>
		</xsl:if>
		<!--Rule 1782: If quantityOfBatteriesIncluded is used then quantityOfBatteriesIncluded SHALL be greater than 0.-->
		<xsl:if test="string(quantityOfBatteriesIncluded) != '' and quantityOfBatteriesIncluded &lt;= 0">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1782" />
			</xsl:apply-templates>
		</xsl:if>
		<!--Rule 1783: If quantityOfBatteriesRequired is used, then quantityOfBatteriesRequired SHALL be greater than 0.-->
		<xsl:if test="string(quantityOfBatteriesRequired) != '' and quantityOfBatteriesRequired &lt;= 0">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1783" />
			</xsl:apply-templates>
		</xsl:if>
		<!--Rule 1784: If batteryWeight is used, then batteryWeight SHALL be greater than 0.-->
		<xsl:if test="string(batteryWeight) != '' and batteryWeight &lt;= 0">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1784" />
			</xsl:apply-templates>
		</xsl:if>
		<!--Rule 1785: If targetMarketCountryCode not ('203' (Czech Republic), '208' (Denmark), '250' (France), ‘840’ (US), ‘104‘ (Myanmar) or ‘430’ (Liberia)) and batteryWeight is used, then batteryWeight/@measurementUnitCode SHALL equal ('KGM’, 'GRM’ or ‘MGM’).-->
		<xsl:choose>
			<xsl:when test="contains('203, 208, 250, 840, 104, 430', $targetMarket)"/>
			<xsl:otherwise>
				<xsl:if test="string(batteryWeight) != '' and string(batteryWeight/@measurementUnitCode) != 'KGM' and string(batteryWeight/@measurementUnitCode) != 'GRM' and string(batteryWeight/@measurementUnitCode) != 'MGM'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1785" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:if test="$targetMarket = '756'">
			<!--Rule 2023: If targetMarketCountryCode equals <Geographic> and areBatteriesBuiltIn is used then areBatteriesBuiltIn SHALL equal ('TRUE' or 'FALSE').-->
			<xsl:if test="string(areBatteriesBuiltIn) != '' and areBatteriesBuiltIn != 'FALSE' and areBatteriesBuiltIn != 'TRUE'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="2023" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

	</xsl:template>

	<xsl:template match="batteryMaterials" mode="batteryInformationModule">
		<xsl:param name="targetMarket"/>
		<xsl:apply-templates select="tradeItemMaterialComposition" mode="batteryInformationModule"/>
		<!--Rule 1553: (if TradeItemMaterial/materialAgencyCode is used then TradeItemMaterial/TradeItemMaterialComposition/materialCode shall be used) and (if TradeItemMaterial/TradeItemMaterialComposition/materialCode is used then TradeItemMaterial/materialAgencyCode shall be used).-->
		<xsl:if test="(string(materialAgencyCode) != '' and string(materialCode) = '') or (string(materialAgencyCode) = '' and string(materialCode) != '')">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1553" />
			</xsl:apply-templates>
		</xsl:if>
		<!--Rule 1554: If TradeItemMaterial/materialAgencyCode and TradeItemMaterial/TradeItemMaterialComposition/materialCode are used and targetMarketCountryCode does NOT equal (056 (Belgium), 442 (Luxembourg), 528 (Netherlands)) then TradeItemMaterial/TradeItemMaterialComposition/materialPercentage shall be used.-->
		<xsl:choose>
			<xsl:when test="$targetMarket = '056' or $targetMarket = '442' or $targetMarket = '528'"/>
			<xsl:otherwise>
				<xsl:if test="string(materialAgencyCode) != '' and string(tradeItemMaterialComposition/materialCode) !=''">
					<xsl:if test="string(tradeItemMaterialComposition/materialPercentage) = ''">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1554" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tradeItemMaterialComposition" mode="batteryInformationModule">
		<!--Rule 1656: If the class CountryOfOrigin or MaterialCountryOfOrigin is repeated, then no two iterations of countryCode in  this class SHALL be equal.-->
		<xsl:variable name="parent" select="."/>
		<xsl:for-each select="materialCountryOfOrigin/countryCode">
			<xsl:variable name="value" select="."/>
			<xsl:if test="count($parent/materialCountryOfOrigin[countryCode = $value]) &gt; 1">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1656" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
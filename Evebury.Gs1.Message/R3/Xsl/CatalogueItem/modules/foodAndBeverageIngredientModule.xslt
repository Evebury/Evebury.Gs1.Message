<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:food_and_beverage_ingredient:xsd:3' and local-name()='foodAndBeverageIngredientModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="foodAndBeverageIngredient" mode="foodAndBeverageIngredientModule" >
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>

		<!--Rule 1900: If targetMarketCountryCode equals <Geographic> and ingredientStatement is used, then at least one iteration of ingredientStatement/@languageCcode SHALL equal to 'fi' (Finnish) and 'sv' (Swedish).-->
		<xsl:if test="$targetMarket = '246'">
			<xsl:if test="ingredientStatement">
				<xsl:choose>
					<xsl:when test="string(ingredientStatement[@languageCode = 'fi']) != '' and string(ingredientStatement[@languageCode = 'sv']) != ''"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1900" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:if>

		<xsl:if test="$targetMarket = '756' or $targetMarket = '040'">
			<!--Rule 2012: If targetMarketCountryCode equals <Geographic> and additiveInformation/levelOfContainmentCode is used then additiveInformation/levelOfContainmentCode SHALL equal 'CONTAINS'.-->
			<xsl:for-each select="additiveInformation">
				<xsl:if test="string(levelOfContainmentCode) != '' and levelOfContainmentCode != 'CONTAINS'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="2012" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>

	</xsl:template>

	<xsl:template match="foodAndBeverageIngredient" mode="foodAndBeverageIngredientModule">
		<xsl:param name="targetMarket"/>
		<xsl:apply-templates select="ingredientPlaceOfActivity" mode="foodAndBeverageIngredientModule"/>

		<xsl:apply-templates select="ingredientParty" mode="gln"/>
		<xsl:apply-templates select="ingredientParty" mode="languageSpecificPartyName"/>

		<!--Rule 1177:If targetMarketCountryCode does not equal <Geographic> and there is more than one iteration of ingredientSequence, then ingredientSequence and ingredientName must not be empty.-->
		<xsl:if test="$targetMarket != '562'">
			<xsl:if test="string(ingredientSequence) = '' or string(ingredientName) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1177" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<!--Rule 1275: If targetMarketCountryCode does not equal <Geographic> and any attribute of the FoodAndBeverageIngredient class is used, then either ingredientName or grapeVarietycode, or both shall be used.-->
		<xsl:choose>
			<xsl:when test="contains('056, 203, 442, 528', $targetMarket)"/>
			<xsl:otherwise>
				<xsl:if test="string(ingredientName) = '' and  string(grapeVarietycode) = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1275" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>

		<!--Rule 1281: The format of ingredientSequence shall be 'dd.dd.dd…'. Where 'd' shall be a digit, always ending in a 'dd' and never having a value of '00'.-->
		<xsl:if test="gs1:InvalidSequence(ingredientSequence)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1281" />
			</xsl:apply-templates>
		</xsl:if>

		<xsl:variable name="isEU" select="contains('008, 051, 031, 112, 056, 070, 100, 191, 196, 203, 208, 233, 246, 250, 268, 300, 348, 352, 372, 376, 380, 398, 417, 428, 440, 442, 807, 498, 499, 528, 578, 616, 620, 642, 643, 688, 703, 705, 724, 752, 792, 795, 826, 804, 860', $targetMarket)"/>

		<xsl:if test="$isEU">
			<!--Rule 1874: If targetMarketCountryCode equals <Geographic> then organicTradeItemCode SHALL NOT equal '1'.-->
			<xsl:if test="ingredientOrganicInformation/organicClaim[organicTradeItemCode = '1']">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1874" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

	</xsl:template>

	<xsl:template match="ingredientPlaceOfActivity" mode="foodAndBeverageIngredientModule">
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

</xsl:stylesheet>
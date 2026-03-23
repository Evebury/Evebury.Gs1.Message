<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:nonfood_ingredient:xsd:3' and local-name()='nonfoodIngredientModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="nonfoodIngredient" mode="nonfoodIngredientModule"/>

		<!--Rule 1906: If targetMarketCountryCode equals <Geographic> and nonFoodIngredientStatement is used, then at least one iteration of nonFoodIngredientStatement/@languageCode SHALL be equal to 'fi' (Finnish) and 'sv' (Swedish).-->
		<xsl:if test="$targetMarket = '246'">
			<xsl:if test="nonFoodIngredientStatement">
				<xsl:choose>
					<xsl:when test="string(nonFoodIngredientStatement[@languageCode = 'fi']) != '' and string(nonFoodIngredientStatement[@languageCode = 'sv']) != ''"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1906" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:if>

	</xsl:template>

	<xsl:template match="nonfoodIngredient" mode="nonfoodIngredientModule">
		<!--Rule 1305: If isIngredientGeneric is not empty, then ingredientStength must not be empty.-->
		<xsl:if test="string(isIngredientGeneric) != '' and ingredientStrength[string(ingredientStrength) = '']">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1305" />
			</xsl:apply-templates>
		</xsl:if>
		
	</xsl:template>

</xsl:stylesheet>
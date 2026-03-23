<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:allergen_information:xsd:3' and local-name()='allergenInformationModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="allergenRelatedInformation" mode="allergenInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="allergenRelatedInformation" mode="allergenInformationModule">
		<xsl:param name="targetMarket"/>
		<xsl:apply-templates select="allergen" mode="allergenInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>

		<!--Rule 1658: If multiple iterations of allergenTypeCode are used, then no two iterations SHALL be equal within the same class allergenRelatedInformation.-->
		<xsl:variable name="parent" select="."/>
		<xsl:for-each select="allergen/allergenTypeCode">
			<xsl:variable name="value" select="."/>
			<xsl:if test="count($parent/allergen[allergenTypeCode = $value]) &gt; 1">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1658" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>


	</xsl:template>

	<xsl:template match="allergen" mode="allergenInformationModule">
		<xsl:param name="targetMarket"/>

		<!--Rule 1755: If targetMarketCountryCode equals ('056' (Belgium), '442' (Luxembourg), '528' (Netherlands)) and levelOfContainmentCode is used, then levelOfContainmentCode SHALL equal one of the following values: 'CONTAINS', 'FREE_FROM' or 'MAY_CONTAIN'.-->
		<xsl:if test="contains('056, 442, 528', $targetMarket)">
			<xsl:choose>
				<xsl:when test="levelOfContainmentCode  = 'CONTAINS'"/>
				<xsl:when test="levelOfContainmentCode  = 'FREE_FROM'"/>
				<xsl:when test="levelOfContainmentCode  = 'MAY_CONTAIN'"/>
				<xsl:otherwise>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1755" />
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		
		
		<xsl:if test="$targetMarket = '756' or $targetMarket = '040'">
			<!--Rule 2017: If targetMarketCountryCode equals <Geographic> and allergen/levelOfContainmentCode is used then allergen/levelOfContainmentCode SHALL equal ('CONTAINS' or 'MAY_CONTAIN').-->
			<xsl:if test="string(levelOfContainmentCode) != '' and string(levelOfContainmentCode) != 'CONTAINS' and string(levelOfContainmentCode) != 'MAY_CONTAIN'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="2017" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
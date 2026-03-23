<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:material:xsd:3' and local-name()='materialModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="material" mode="materialModule"/>

	</xsl:template>

	<xsl:template match="material" mode="materialModule">
		<xsl:apply-templates select="materialComposition" mode="materialModule"/>
		<!--Rule 1308: If Material/materialAgencyCode is used then Material/MaterialComposition/materialCode SHALL be used.-->
		<xsl:if test="string(materialAgencyCode) != ''">
			<xsl:if test="materialComposition[string(materialCode) = '']">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1308" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<!--Rule 1309: if Material/materialAgencyCode and Material/MaterialComposition/materialCode are used then Material/MaterialComposition/materialPercentage shall be used.-->
		<xsl:if test="string(materialAgencyCode) != '' and materialComposition[string(materialCode) != '']">
			<xsl:if test="materialComposition[string(materialPercentage) = '']">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1308" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
		
	</xsl:template>

	<xsl:template match="materialComposition" mode="materialModule">
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
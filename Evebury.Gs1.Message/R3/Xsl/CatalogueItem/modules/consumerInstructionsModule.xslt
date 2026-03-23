<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:consumer_instructions:xsd:3' and local-name()='consumerInstructionsModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="consumerInstructions" mode="consumerInstructionsModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="consumerInstructions" mode="consumerInstructionsModule">
		<xsl:param name="targetMarket"/>

		<xsl:if test="$targetMarket = '246'">
			<!--Rule 1902: If targetMarketCountryCode equals <Geographic> and consumerStorageInstructions is used, then at least one iteration of consumerStorageInstructions/@languageCode SHALL equal to 'fi' (Finnish) and 'sv' (Swedish).-->
			<xsl:if test="consumerStorageInstructions">
				<xsl:choose>
					<xsl:when test="string(consumerStorageInstructions[@languageCode = 'fi']) != '' and string(consumerStorageInstructions[@languageCode = 'sv']) != ''"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1902" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<!--Rule 1903: If targetMarketCountryCode equals <Geographic> and consumerUsageInstructions is used, then at least one iteration of consumerUsageInstructions/@languageCode SHALL be equal to 'fi' (Finnish) and 'sv' (Swedish).-->
			<xsl:if test="consumerUsageInstructions">
				<xsl:choose>
					<xsl:when test="string(consumerUsageInstructions[@languageCode = 'fi']) != '' and string(consumerUsageInstructions[@languageCode = 'sv']) != ''"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1903" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:if>

	</xsl:template>

</xsl:stylesheet>
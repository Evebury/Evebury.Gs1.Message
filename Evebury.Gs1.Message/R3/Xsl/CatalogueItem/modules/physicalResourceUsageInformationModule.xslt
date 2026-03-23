<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:physical_resource_usage:xsd:3' and local-name()='physicalResourceUsageInformationModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="physicalResourceUsageInformation" mode="physicalResourceUsageInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="physicalResourceUsageInformation" mode="physicalResourceUsageInformationModule">
		<xsl:param name="targetMarket"/>

		<xsl:if test="$targetMarket = '756'">

			<!--Rule 1988: If targetMarketCountryCode equals <Geographic> and physicalResourceTypeCode equals 'ELECTRICITY' and physicalResourceUsageRatingScaleCodeReference is used and physicalResourceUsageRatingScaleCodeReference/@codeListName equals 'EU_EnergyEfficiencyScale' then physicalResourceUsageClassificationCodeReference SHALL be used in the same iteration.-->
			<xsl:if test="physicalResourceTypeCode = 'ELECTRICITY' and physicalResourceUsageRatingScaleCodeReference[@codeListName = 'EU_EnergyEfficiencyScale']">
				<xsl:if test="string(physicalResourceUsageClassificationCodeReference) =''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1988" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>

	</xsl:template>

</xsl:stylesheet>
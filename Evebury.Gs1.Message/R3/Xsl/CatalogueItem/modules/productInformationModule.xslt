<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:product_information:xsd:3' and local-name()='productInformationModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="productInformationDetail" mode="productInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="productInformationDetail" mode="productInformationModule">
		<xsl:param name="targetMarket"/>
		<xsl:apply-templates select="claimDetail" mode="productInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="tobaccoCannabisInformation" mode="productInformationModule"/>

		<!--Rule 1870: minimumTerpeneContent and maximumTerpeneContent, if one value is used the other should be used as well-->
		<xsl:for-each select="terpeneInformation">
			<xsl:if test="(string(minimumTerpeneContent) != '' or string(maximumTerpeneContent) !='') and (string(minimumTerpeneContent) = '' or string(maximumTerpeneContent) ='')">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1869" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="claimDetail" mode="productInformationModule">
		<xsl:param name="targetMarket"/>
		<!--Rule 1236: If claimElementCode is used then claimTypeCode SHALL be used.-->
		<xsl:if test="string(claimElementCode) != '' and string(claimTypeCode) = ''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1236" />
			</xsl:apply-templates>
		</xsl:if>
	
		<xsl:if test="$targetMarket = '756'">

			<!--Rule 1947: If targetMarketCountryCode equals <Geographic> and claimMarkedOnPackage is used then claimTypeCode SHALL be used.-->
			<xsl:if test="string(claimMarkedOnPackage) != '' and string(claimTypeCode)  = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1947" />
				</xsl:apply-templates>
			</xsl:if>

			<!--Rule 2022: If targetMarketCountryCode equals <Geographic> and claimMarkedOnPackage is used then claimMarkedOnPackage SHALL equal ('TRUE' or 'FALSE').-->
			<xsl:if test="string(claimMarkedOnPackage) != '' and string(claimMarkedOnPackage) != 'FALSE' and string(claimMarkedOnPackage) != 'TRUE'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="2022" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tobaccoCannabisInformation" mode="productInformationModule">
		<!--Rule 1869: cannabinoidMinimumRangeValue and cannabinoidMaximumRangeValue, if one value is used the other should be used as well-->
		<xsl:for-each select="cannabinoidContentInformation">
			<xsl:if test="(string(cannabinoidMinimumRangeValue) != '' or string(cannabinoidMaximumRangeValue) !='') and (string(cannabinoidMinimumRangeValue) = '' or string(cannabinoidMaximumRangeValue) ='')">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1869" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>



</xsl:stylesheet>
<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:trade_item_size:xsd:3' and local-name()='tradeItemSizeModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="nonPackagedSizeDimension" mode="tradeItemSizeModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="nonPackagedSizeDimension" mode="tradeItemSizeModule">
		<xsl:param name="targetMarket"/>
		<!--Rule 1062: If class NonPackagedSizeDimension is used then either descriptiveSizeDimension, sizeDimension or sizeCode shall be used.-->
		<xsl:choose>
			<xsl:when test="string(descriptiveSizeDimension) != '' or string(sizeDimension) != '' or string(sizeTypeCode) != ''"/>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1062" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>

		<!--Rule 1809: If targetMarketCountryCode equals '752' (Sweden) and sizeTypeCode or sizeDimension is used then sizeTypeCode and sizeDimension SHALL be used.-->
		<xsl:if test="$targetMarket = '752'">
			<xsl:if test="(string(sizeTypeCode) != '' or string(sizeDimension) != '') and (string(sizeTypeCode) = '' or string(sizeDimension) = '')">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1809" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<xsl:if test="$targetMarket ='756'">
			<!--Rule 1991: If targetMarketCountryCode equals <Geographic> and (sizeCode is used or sizeSystemCode is used) then sizeCode SHALL be used and sizeSystemCode SHALL be used.-->
			<xsl:if test="(string(sizeTypeCode) != '' or string(sizeSystemCode) != '') and (string(sizeTypeCode) = '' or string(sizeSystemCode) = '')">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1991" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
		
	</xsl:template>

</xsl:stylesheet>
<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:audio_visual_media_content_information:xsd:3' and local-name()='audioVisualMediaContentInformationModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>


		<xsl:apply-templates select="audioVisualMediaContentInformation" mode="audioVisualMediaContentInformationModule"/>

	</xsl:template>

	<xsl:template match="audioVisualMediaContentInformation" mode="audioVisualMediaContentInformationModule">
		<!--Rule 1189: There must be at most one iteration of distributionMediaTypeCode -->
		<xsl:variable name="info" select="."/>
		<xsl:for-each select="distributionMediaTypeCode">
			<xsl:variable name="value" select="."/>
			<xsl:if test="count($info[distributionMediaTypeCode = $value]) &gt; 1">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1189" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
		
	</xsl:template>

</xsl:stylesheet>
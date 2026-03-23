<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:audio_visual_media_product_description_information:xsd:3' and local-name()='audioVisualMediaProductDescriptionInformationModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>


		<!--<xsl:apply-templates select="todo" mode="audioVisualMediaProductDescriptionInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>			
		</xsl:apply-templates>-->

	</xsl:template>

	<!--<xsl:template match="todo" mode="audioVisualMediaProductDescriptionInformationModule">

	</xsl:template>-->

</xsl:stylesheet>
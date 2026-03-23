<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:food_and_beverage_properties_information:xsd:3' and local-name()='foodAndBeveragePropertiesInformationModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="microbiologicalInformation" mode="foodAndBeveragePropertiesInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="microbiologicalInformation" mode="foodAndBeveragePropertiesInformationModule">
		<xsl:param name="targetMarket"/>
		<!--Rule 1694: If any attributes in class microbiologicalInformation is provided, then the attribute microbiologicalOrganismCode must be provided.-->
		<xsl:if test="*[name() != 'microbiologicalOrganismCode']">
			<xsl:if test="string(microbiologicalOrganismCode)  =''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1694" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<!--Rule 1981: If targetMarketCountryCode equals <Geographic> and microbiologicalOrganismCode is used then microbiologicalOrganismMaximumValue SHALL be used.-->
		<xsl:if test="$targetMarket  = '756'">
			<xsl:if test="string(microbiologicalOrganismCode) != '' and string(microbiologicalOrganismMaximumValue) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1981" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
		
		
	</xsl:template>

</xsl:stylesheet>
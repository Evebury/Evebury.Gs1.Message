<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:variable_trade_item_information:xsd:3' and local-name()='variableTradeItemInformationModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="variableTradeItemInformation" mode="variableTradeItemInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
			<xsl:with-param name="tradeItem" select="$tradeItem"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="variableTradeItemInformation" mode="variableTradeItemInformationModule">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>
		<!--Rule 362: If a minimum and corresponding maximum are not empty then the minimum SHALL be less than or equal to the corresponding maximum.-->
		<xsl:if test="gs1:InvalidRange(variableWeightRangeMinimum,variableWeightRangeMaximum)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="362"/>
			</xsl:apply-templates>
		</xsl:if>

		<!--Rule 1893: If targetMarketCountryCode equals <Geographic> and isTradeItemAnInvoiceUnit equals 'true' and isTradeItemAVariableUnit equals 'true', then sellingUnitOfMeasure SHALL be used.-->
		<xsl:if test="$targetMarket = '250' and isTradeItemAVariableUnit = 'true'">
			<xsl:if test="string($tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:sales_information:xsd:3' and local-name()='salesInformationModule']/salesInformation/sellingUnitOfMeasure) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1893" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

	
		<xsl:if test="$targetMarket = '756'">

			<!--Rule 1974: If targetMarketCountryCode equals <Geographic> and (variableWeightRangeMinimum is used or variableWeightRangeMaximum is used) then variableWeightRangeMinimum SHALL be used and variableWeightRangeMaximum SHALL be used.-->
			<xsl:if test="(string(variableWeightRangeMinimum) != '' or string(variableWeightRangeMaximum) != '') and (string(variableWeightRangeMinimum) = '' or string(variableWeightRangeMaximum) = '')">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1974" />
				</xsl:apply-templates>
			</xsl:if>

			<!--Rule 1975: If targetMarketCountryCode equals <Geographic> and (variableWeightAllowableDeviationPercentage is used or variableWeightRangeMinimum is used or variableWeightRangeMaximum is used) then isTradeItemAVariableUnit SHALL equal 'true'.-->
			<xsl:if test="(string(variableWeightRangeMinimum) != '' or string(variableWeightRangeMaximum) != '') and string(isTradeItemAVariableUnit) != 'true'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1975" />
				</xsl:apply-templates>
			</xsl:if>
			
		</xsl:if>
		
	</xsl:template>

</xsl:stylesheet>
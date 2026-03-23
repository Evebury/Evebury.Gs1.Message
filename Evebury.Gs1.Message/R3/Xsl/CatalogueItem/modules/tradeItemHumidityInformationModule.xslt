<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:trade_item_humidity_information:xsd:3' and local-name()='tradeItemHumidityInformationModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="tradeItemHumidityInformation" mode="tradeItemHumidityInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="tradeItemHumidityInformation" mode="tradeItemHumidityInformationModule">
		<xsl:param name="targetMarket"/>
		<!--Rule 362: If a minimum and corresponding maximum are not empty then the minimum SHALL be less than or equal to the corresponding maximum.-->
		<xsl:if test="gs1:InvalidRange(minimumHumidityPercentage,maximumHumidityPercentage)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="362"/>
			</xsl:apply-templates>
		</xsl:if>

		<!--Rule 491: If maximumHumidityPercentage and minimumHumidityPercentage are used then value shall be greater than, or equal to '0' and less than or equal to '100'.-->
		<xsl:if test="string(minimumHumidityPercentage) != '' and (minimumHumidityPercentage &lt; 0 or minimumHumidityPercentage &gt; 100)">
			<xsl:apply-templates select="minimumHumidityPercentage" mode="error">
				<xsl:with-param name="id" select="362"/>
			</xsl:apply-templates>
		</xsl:if>
		<xsl:if test="string(maximumHumidityPercentage) != '' and (maximumHumidityPercentage &lt; 0 or maximumHumidityPercentage &gt; 100)">
			<xsl:apply-templates select="maximumHumidityPercentage" mode="error">
				<xsl:with-param name="id" select="362"/>
			</xsl:apply-templates>
		</xsl:if>

		<!--Rule 1076: If maximumHumidityPercentage and/or minimumHumidityPercentage are not empty then humidityQualifierCode must not be empty.-->
		<xsl:if test="string(humidityQualifierCode) = ''">
			<xsl:if test="string(minimumHumidityPercentage) != '' or string(maximumHumidityPercentage) != ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1076" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<!--Rule 1838: If humidityQualifierCode is used, then at least one other attribute in the TradeItemHumidityInformation class SHALL be used.-->
		<xsl:if test="string(humidityQualifierCode) != ''">
			<xsl:if test="count(*[name() != 'humidityQualifierCode']) = 0">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1838" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
		
	</xsl:template>

</xsl:stylesheet>
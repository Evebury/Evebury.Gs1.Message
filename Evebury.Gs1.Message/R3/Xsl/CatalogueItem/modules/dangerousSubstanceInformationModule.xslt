<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:dangerous_substance_information:xsd:3' and local-name()='dangerousSubstanceInformationModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="dangerousSubstanceInformation/dangerousSubstanceProperties" mode="dangerousSubstanceInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="dangerousSubstanceProperties" mode="dangerousSubstanceInformationModule">
		<xsl:param name="targetMarket"/>
		<!--Rule 362: If a minimum and corresponding maximum are not empty then the minimum SHALL be less than or equal to the corresponding maximum.-->
		<xsl:if test="gs1:InvalidRange(flammableSubstanceMinimumPercent,flammableSubstanceMaximumPercent)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="362"/>
			</xsl:apply-templates>
		</xsl:if>


		<!--Rule 1911: If there is more than one iteration of dangerousHazardousLabel, then dangerousHazardousLabelSequenceNumber SHALL be used.-->
		<xsl:if test="count(dangerousHazardousLabel) &gt; 1">
			<xsl:if test="dangerousHazardousLabel[string(dangerousHazardousLabelSequenceNumber)  = '']">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1911" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<xsl:if test="$targetMarket = '756' or $targetMarket = '040'">
			<!--Rule 2005: If targetMarketCountryCode equals <Geographic> and dangerousSubstanceWasteCode/enumerationValueInformation/enumerationValue is used then corresponding dangerousSubstanceWasteCode/externalAgencyName SHALL equal 'EU'. -->
			<xsl:if test="dangerousSubstanceWasteCode[enumerationValueInformation/enumerationValue]">
				<xsl:if test="dangerousSubstanceWasteCode[enumerationValueInformation/enumerationValue]/dangerousSubstanceWasteCode != 'EU'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="2005" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
			<!--Rule 2009: If targetMarketCountryCode equals <Geographic> and (dangerousSubstanceName is used or flammableSubstanceMinimumPercent is used or flammableSubstanceMaximumPercent is used) then dangerousSubstanceName SHALL be used and flammableSubstanceMinimumPercent SHALL be used and flammableSubstanceMaximumPercent SHALL be used.-->
			<xsl:if test="(string(dangerousSubstanceName) != '' or string(flammableSubstanceMinimumPercent) != '' or string(flammableSubstanceMaximumPercent) != '') and (string(dangerousSubstanceName) = '' or string(flammableSubstanceMinimumPercent) = '' or string(flammableSubstanceMaximumPercent) = '')">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="2009" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<xsl:if test="$targetMarket = '756'">
			<!--Rule 2016: If targetMarketCountryCode equals <Geographic> and dangerousSubstanceGasDensity is used then dangerousSubstanceGasDensity/@measurementUnitCode SHALL equal ('23' or 'GL').-->
			<xsl:if test="string(dangerousSubstanceGasDensity) != '' and dangerousSubstanceGasDensity/@measurementUnitCode !='23' and dangerousSubstanceGasDensity/@measurementUnitCode !='GL'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="2016" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

	</xsl:template>

</xsl:stylesheet>
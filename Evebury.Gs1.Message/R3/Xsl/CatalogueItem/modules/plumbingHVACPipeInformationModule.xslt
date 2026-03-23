<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:plumbing_hvac_pipe_information:xsd:3' and local-name()='plumbingHVACPipeInformationModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="plumbingHVACPipeInformation/tradeItemWorkingPressure" mode="plumbingHVACPipeInformationModule"/>

	</xsl:template>

	<xsl:template match="tradeItemWorkingPressure" mode="plumbingHVACPipeInformationModule">
		<!--Rule 362: If a minimum and corresponding maximum are not empty then the minimum SHALL be less than or equal to the corresponding maximum.-->
		<xsl:if test="gs1:InvalidRange(workingPressureRatingMinimum,workingPressureRatingMaximum)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="362"/>
			</xsl:apply-templates>
		</xsl:if>
	
	</xsl:template>

</xsl:stylesheet>
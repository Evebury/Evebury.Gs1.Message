<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:animal_feeding:xsd:3' and local-name()='animalFeedingModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="animalFeeding" mode="animalFeedingModule"/>

		<!--Rule 1640: If feedType is repeated for one trade item, then maximum one iteration of the same feedType shall exist for the same Trade Item-->
		<xsl:variable name="feed" select="."/>
		<xsl:for-each select="feedType">
			<xsl:variable name="value" select="."/>
			<xsl:if test="count($feed[feedType = $value]) &gt; 1">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1640" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
		

	</xsl:template>

	<xsl:template match="animalFeeding" mode="animalFeedingModule">
		<!--Rule 362: If a minimum and corresponding maximum are not empty then the minimum SHALL be less than or equal to the corresponding maximum.-->
		<xsl:if test="gs1:InvalidRange(minimumWeightOfAnimalBeingFed,maximumWeightOfAnimalBeingFed)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="362"/>
			</xsl:apply-templates>
		</xsl:if>

		<xsl:for-each select="animalFeedingDetail">

			<xsl:if test="gs1:InvalidRange(minimumFeedingAmount,maximumFeedingAmount)">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="362"/>
				</xsl:apply-templates>
			</xsl:if>

			<xsl:for-each select="animalNutrientDetail">
				<xsl:if test="gs1:InvalidRange(animalNutrientMinimumPercentage,animalNutrientMaximumPercentage)">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="362"/>
					</xsl:apply-templates>
				</xsl:if>
			</xsl:for-each>

		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
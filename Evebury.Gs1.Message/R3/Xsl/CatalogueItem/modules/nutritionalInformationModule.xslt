<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:nutritional_information:xsd:3' and local-name()='nutritionalInformationModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="nutrientHeader" mode="nutritionalInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
			<xsl:with-param name="tradeItem" select="$tradeItem"/>
		</xsl:apply-templates>

		<!--Rule 1753: If targetMarketCountryCode equals <Geographic> and preparationStateCode is used then at least one iteration of preparationStateCode SHALL equal to 'PREPARED' or 'UNPREPARED'.-->
		<xsl:if test="contains('008, 051, 040, 031, 112, 056, 070, 100, 191, 196, 203, 233, 246, 250, 268, 276, 300, 348, 352, 372, 376, 380, 398, 417, 428, 440, 442, 807, 498, 499, 528, 578, 616, 620, 642, 643, 688, 703, 705, 752, 792, 795, 804, 826, 860', $targetMarket)">
			<xsl:choose>
				<xsl:when test="nutrientHeader[preparationStateCode = 'PREPARED' or preparationStateCode = 'UNPREPARED']"/>
				<xsl:otherwise>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1753" />
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

		<!--Rule 1780: If targetMarketCountryCode equals '528' (Netherlands) and if preparationStateCode is used and isTradeItemAConsumerUnit equals 'true', then regulatedProductName (with languageCode 'nl') SHALL be used.-->
		<xsl:if test="$targetMarket = '528' and $tradeItem/isTradeItemAConsumerUnit = 'true' and nutrientHeader[string(preparationStateCode) != '']">
			<xsl:choose>
				<xsl:when test="$tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_description:xsd:3' and local-name()='tradeItemDescriptionModule']/tradeItemDescriptionInformation/regulatedProductName[@languageCode  = 'nl']"/>
				<xsl:otherwise>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1780" />
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

	</xsl:template>

	<xsl:template match="nutrientHeader" mode="nutritionalInformationModule">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>
		<xsl:apply-templates select="nutrientDetail" mode="nutritionalInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>
		<!--Rule 1440: If targetMarketCountryCode equals <Geographic> and preparationStateCode is used then at least 1 iteration of nutrientTypeCode SHALL be used.-->
		<xsl:if test="contains('752, 246, 756', $targetMarket)">
			<xsl:if test="string(preparationStateCode) != ''">
				<xsl:if test="count(nutrientDetail[string(nutrientTypeCode) != '']) = 0">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1440" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>


		<xsl:if test="contains('056, 442, 528, 276, 208, 203, 826, 040, 756, 246, 380, 250', $targetMarket)">
			<xsl:variable name="starch" select="nutrientDetail[nutrientTypeCode = 'STARCH']"/>
			<xsl:variable name="choavl" select="nutrientDetail[nutrientTypeCode = 'CHOAVL']"/>
			<xsl:variable name="polyl" select="nutrientDetail[nutrientTypeCode = 'POLYL']"/>
			<xsl:variable name="fasat" select="nutrientDetail[nutrientTypeCode = 'FASAT']"/>
			<xsl:variable name="fat" select="nutrientDetail[nutrientTypeCode = 'FAT']"/>
			<xsl:variable name="famcis" select="nutrientDetail[nutrientTypeCode = 'FAMSCIS']"/>
			<xsl:variable name="fapucis" select="nutrientDetail[nutrientTypeCode = 'FAPUCIS']"/>
			<xsl:variable name="sugarmin" select="nutrientDetail[nutrientTypeCode = 'SUGAR-']"/>

			<!--Rule 1641: If targetMarketCountryCode equals <Geographic> for the same nutrientBasisQuantity or servingSize and one instance of nutrientTypeCode equals 'STARCH' and quantityContained is used and another instance of nutrientTypeCode equals 'CHOAVL' and quantityContained is used then quantityContained for nutrientTypeCode 'STARCH' SHALL be less than or equal to quantityContained for nutrientTypeCode 'CHOAVL'.-->
			<xsl:if test="$starch and string($starch/quantityContained) != ''">
				<xsl:if test="$choavl and string($choavl/quantityContained) != ''">
					<xsl:variable name="v1">
						<xsl:apply-templates select="$starch/quantityContained" mode="measurementUnit"/>
					</xsl:variable>
					<xsl:variable name="v2">
						<xsl:apply-templates select="$choavl/quantityContained" mode="measurementUnit"/>
					</xsl:variable>
					<xsl:if test="$v1 &gt; $v2">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1641" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:if>
			</xsl:if>
			<!--Rule 1642: If targetMarketCountryCode equals <Geographic> for the same nutrientBasisQuantity or servingSize and one instance of nutrientTypeCode equals 'POLYL' and quantityContained is used and another instance of nutrientTypeCode equals 'CHOAVL' and quantityContained is used then quantityContained for nutrientTypeCode 'POLYL' SHALL be less than or equal to quantityContained for nutrientTypeCode 'CHOAVL'..-->
			<xsl:if test="$polyl and string($polyl/quantityContained) != ''">
				<xsl:if test="$choavl and string($choavl/quantityContained) != ''">
					<xsl:variable name="v1">
						<xsl:apply-templates select="$polyl/quantityContained" mode="measurementUnit"/>
					</xsl:variable>
					<xsl:variable name="v2">
						<xsl:apply-templates select="$choavl/quantityContained" mode="measurementUnit"/>
					</xsl:variable>
					<xsl:if test="$v1 &gt; $v2">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1641" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:if>
			</xsl:if>
			<!--Rule 1643: If targetMarketCountryCode equals <Geographic> for the same nutrientBasisQuantity or servingSize and one instance of nutrientTypeCode equals 'FASAT' and quantityContained is used and another instance of nutrientTypeCode equals 'FAT' and quantityContained is used then quantityContained for nutrientTypeCode 'FASAT' SHALL be less than or equal to quantityContained for nutrientTypeCode 'FAT'.-->
			<xsl:if test="$fasat and string($fasat/quantityContained) != ''">
				<xsl:if test="$fat and string($fat/quantityContained) != ''">
					<xsl:variable name="v1">
						<xsl:apply-templates select="$fasat/quantityContained" mode="measurementUnit"/>
					</xsl:variable>
					<xsl:variable name="v2">
						<xsl:apply-templates select="$fat/quantityContained" mode="measurementUnit"/>
					</xsl:variable>
					<xsl:if test="$v1 &gt; $v2">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1641" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:if>
			</xsl:if>
			<!--Rule 1644: If targetMarketCountryCode equals <Geographic> for the same nutrientBasisQuantity or servingSize and one instance of nutrientTypeCode equals 'FAMSCIS' and quantityContained is used and another instance of nutrientTypeCode equals 'FAT' and quantityContained is used then quantityContained for nutrientTypeCode 'FAMSCIS' SHALL be less than or equal to quantityContained for nutrientTypeCode 'FAT'.-->
			<xsl:if test="$famcis and string($famcis/quantityContained) != ''">
				<xsl:if test="$fat and string($fat/quantityContained) != ''">
					<xsl:variable name="v1">
						<xsl:apply-templates select="$famcis/quantityContained" mode="measurementUnit"/>
					</xsl:variable>
					<xsl:variable name="v2">
						<xsl:apply-templates select="$fat/quantityContained" mode="measurementUnit"/>
					</xsl:variable>
					<xsl:if test="$v1 &gt; $v2">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1641" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:if>
			</xsl:if>
			<!--Rule 1645: If targetMarketCountryCode equals <Geographic> for the same nutrientBasisQuantity or servingSize and one instance of nutrientTypeCode equals 'FAPUCIS' and quantityContained is used and another instance of nutrientTypeCode equals 'FAT' and quantityContained is used then quantityContained for nutrientTypeCode 'FAPUCIS' SHALL be less than or equal to quantityContained for nutrientTypeCode 'FAT'.-->
			<xsl:if test="$fapucis and string($fapucis/quantityContained) != ''">
				<xsl:if test="$fat and string($fat/quantityContained) != ''">
					<xsl:variable name="v1">
						<xsl:apply-templates select="$fapucis/quantityContained" mode="measurementUnit"/>
					</xsl:variable>
					<xsl:variable name="v2">
						<xsl:apply-templates select="$fat/quantityContained" mode="measurementUnit"/>
					</xsl:variable>
					<xsl:if test="$v1 &gt; $v2">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1641" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:if>
			</xsl:if>

			<!--Rule 1665: If targetMarketCountryCode equals <Geographic> for the same nutrientBasisQuantity or servingSize and one instance of nutrientTypeCode equals 'SUGAR-' and quantityContained is used and another instance of nutrientTypeCode equals 'CHOAVL' and quantityContained is used then quantityContained for nutrientTypeCode 'SUGAR-' SHALL be less than or equal to quantityContained for nutrientTypeCode 'CHOAVL'.-->
			<xsl:if test="$sugarmin and string($sugarmin/quantityContained) != ''">
				<xsl:if test="$choavl and string($choavl/quantityContained) != ''">
					<xsl:variable name="v1">
						<xsl:apply-templates select="$sugarmin/quantityContained" mode="measurementUnit"/>
					</xsl:variable>
					<xsl:variable name="v2">
						<xsl:apply-templates select="$choavl/quantityContained" mode="measurementUnit"/>
					</xsl:variable>
					<xsl:if test="$v1 &gt; $v2">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1665" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:if>
			</xsl:if>
		</xsl:if>


		<!--Rule 1654: If targetMarketCountryCode equals <Geographic> and nutrientTypeCode equals ('ENER-', 'FAT', 'FASAT', 'CHOAVL', 'SUGAR-', 'PRO-' or 'SALTEQ') and dailyValueIntakePercent is used then dailyValueIntakeReference SHALL be used in the parent NutrientHeader class.-->
		<xsl:if test="contains('040, 056, 203, 276, 380, 442, 528, 752, 756, 826', $targetMarket)">
			<xsl:variable name="used">
				<xsl:choose>
					<xsl:when test="string(nutrientDetail[nutrientTypeCode = 'ENER-']/dailyValueIntakePercent) != ''">
						<xsl:value-of select="1"/>
					</xsl:when>
					<xsl:when test="string(nutrientDetail[nutrientTypeCode = 'FAT']/dailyValueIntakePercent) != ''">
						<xsl:value-of select="1"/>
					</xsl:when>
					<xsl:when test="string(nutrientDetail[nutrientTypeCode = 'FASAT']/dailyValueIntakePercent) != ''">
						<xsl:value-of select="1"/>
					</xsl:when>
					<xsl:when test="string(nutrientDetail[nutrientTypeCode = 'CHOAVL']/dailyValueIntakePercent) != ''">
						<xsl:value-of select="1"/>
					</xsl:when>
					<xsl:when test="string(nutrientDetail[nutrientTypeCode = 'SUGAR-']/dailyValueIntakePercent) != ''">
						<xsl:value-of select="1"/>
					</xsl:when>
					<xsl:when test="string(nutrientDetail[nutrientTypeCode = 'PRO-']/dailyValueIntakePercent) != ''">
						<xsl:value-of select="1"/>
					</xsl:when>
					<xsl:when test="string(nutrientDetail[nutrientTypeCode = 'SALTEQ']/dailyValueIntakePercent) != ''">
						<xsl:value-of select="1"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="$used = 1 and string(dailyValueIntakeReference) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1654" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<xsl:variable name="parent" select="."/>

		<!--Rule 1717: If targetMarketCountryCode equals <Geographic> and NutrientDetail sub-class is used then all nutrientTypeCode values SHALL be unique within the same NutrientHeader class.-->
		<xsl:if test="contains('208, 250, 752, 756, 040', $targetMarket)">
			<xsl:for-each select="nutrientDetail/nutrientTypeCode">
				<xsl:variable name="value" select="."/>
				<xsl:if test="count($parent/nutrientDetail[nutrientTypeCode = $value]) &gt; 1">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1717" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>

		<!--Rule 1761: If targetMarketCountryCode equals <Geographic> and one instance of preparationStateCode equals 'PREPARED' and at least one nutrientTypeCode is used, then there SHALL be at least one instance of preparationInstructions with languageCode equal to 'nl'.-->
		<xsl:if test="preparationStateCode = 'PREPARED'">
			<xsl:if test="$targetMarket = '528'">
				<xsl:choose>
					<xsl:when test="$tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:food_and_beverage_preparation_serving:xsd:3' and local-name()='foodAndBeveragePreparationServingModule']/preparationServing/preparationInstructions[@languageCode = 'nl']"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1761" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:if>

	
		<xsl:if test="contains('008, 051, 031, 112, 056, 070, 040, 100, 191, 196, 203, 208, 233, 246, 250, 276, 268, 300, 348, 352, 372, 376, 380, 398, 417, 428, 440, 442, 807, 498, 499, 528, 578, 616, 620, 642, 643, 688, 703, 705, 752, 756, 792, 795, 826, 804, 860', $targetMarket)">
			<!--Rule 1765: If targetMarketCountryCode equals <geographic> and one instance of nutrientTypeCode is equal to 'FASAT', then there SHALL be also one instance of nutrientTypeCode with the value 'FAT' within the same nutrientHeader.-->
			<xsl:if test="nutrientDetail[nutrientTypeCode = 'FASAT']">
				<xsl:choose>
					<xsl:when test="nutrientDetail[nutrientTypeCode = 'FAT']"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1765" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<!--Rule 1766: If targetMarketCountryCode equals geographic and one instance of nutrientTypeCode equals 'FAMSCIS', then there SHALL be also one instance of nutrientTypeCode with the value 'FAT' within the same nutrientHeader.-->
			<xsl:if test="nutrientDetail[nutrientTypeCode = 'FAMSCIS']">
				<xsl:choose>
					<xsl:when test="nutrientDetail[nutrientTypeCode = 'FAT']"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1766" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<!--Rule 1767: If targetMarketCountryCode equals geographic and one instance of nutrientTypeCode equals 'FAPUCIS', then there SHALL be also one instance of nutrientTypeCode with the value 'FAT' within the same nutrientHeader.-->
			<xsl:if test="nutrientDetail[nutrientTypeCode = 'FAPUCIS']">
				<xsl:choose>
					<xsl:when test="nutrientDetail[nutrientTypeCode = 'FAT']"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1767" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<!--Rule 1768: If targetMarketCountryCode equals geographic and one instance of nutrientTypeCode equals 'STARCH', then there SHALL be also one instance of nutrientTypeCode with the value 'CHOAVL' within the same nutrientHeader.-->
			<xsl:if test="nutrientDetail[nutrientTypeCode = 'STARCH']">
				<xsl:choose>
					<xsl:when test="nutrientDetail[nutrientTypeCode = 'CHOAVL']"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1768" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<!--Rule 1769: If targetMarketCountryCode equals geographic and one instance of nutrientTypeCode equals 'POLYL', then there SHALL be also one instance of nutrientTypeCode with the value 'CHOAVL' within the same nutrientHeader.-->
			<xsl:if test="nutrientDetail[nutrientTypeCode = 'POLYL']">
				<xsl:choose>
					<xsl:when test="nutrientDetail[nutrientTypeCode = 'CHOAVL']"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1769" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>

			<!--Rule 1770: If targetMarketCountryCode equals geographic and (nutrientBasisQuantity equals '100' GRM, '100' MLT, '1000' MLT or '1' LTR) and one instance of nutrientTypeCode equals 'SUGAR-', then there SHALL be also one instance of nutrientTypeCode with the value 'CHOAVL' within the same nutrientHeader.-->
			<xsl:if test="(nutrientBasisQuantity = 100 and nutrientBasisQuantity/@measurementUnitCode = 'GRM') or (nutrientBasisQuantity = 100 and nutrientBasisQuantity/@measurementUnitCode = 'MLT') or (nutrientBasisQuantity = 1000 and nutrientBasisQuantity/@measurementUnitCode = 'MLT') or (nutrientBasisQuantity = 1 and nutrientBasisQuantity/@measurementUnitCode = 'LTR')">
				<xsl:if test="nutrientDetail[nutrientTypeCode = 'SUGAR-']">
					<xsl:choose>
						<xsl:when test="nutrientDetail[nutrientTypeCode = 'CHOAVL']"/>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="1770" />
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</xsl:if>

			<!--Rule 1779: If targetMarketCountryCode equals geographic and (nutrientBasisQuantity equals 100 and nutrientBasisQuantity /@measuremenrUnitCode equals 'GRM') and (nutrientTypeCode equals 'FAT' and quantityContained/UoM is used with 'GRM') and (nutrientTypeCode is used with 'PRO-' and quantityContained/@measuremenrUnitCode equals 'GRM') and (nutrientTypeCode equals 'CHOAVL' and quantityContained/@measuremenrUnitCode equals 'GRM'), then the sum of the corresponding quantityContained values SHALL be less than 102 gram per nutrientHeader.-->
			<xsl:if test="nutrientBasisQuantity = 100 and nutrientBasisQuantity/@measurementUnitCode = 'GRM'">
				<xsl:variable name="fat" select="nutrientDetail[nutrientTypeCode = 'FAT' and quantityContained/@measurementUnitCode = 'GRM']"/>
				<xsl:variable name="pro" select="nutrientDetail[nutrientTypeCode = 'PRO-' and quantityContained/@measurementUnitCode = 'GRM']"/>
				<xsl:variable name="choavl" select="nutrientDetail[nutrientTypeCode = 'CHOAVL' and quantityContained/@measurementUnitCode = 'GRM']"/>
				<xsl:if test="$fat and $pro and $choavl">
					<xsl:if test="$fat/quantityContained + $pro/quantityContained + $choavl/quantityContained &gt; 102">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1779" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:if>

			</xsl:if>
		</xsl:if>

		<!--Rule 1771: If targetMarketCountryCode equals '528' (the Netherlands) and if isTradeItemAConsumerUnit equals 'true’ and (nutrientTypeCode is used with 'NA' and quantityContained is greater than or equal to 0.1 GRM and if measurementPrecisionCode is NOT equal to 'LESS_THAN') and if (nutrientTypeCode is used with 'SALTEQ' and if measurementPrecisionCode is NOT equal to 'LESS_THAN' and quantityContained is greater than or equal to 0.1 GRM), then quantityContained of nutrientTypeCode 'NA' multiplied by 2.5, SHALL be less than 1.1 times and greater than 0.9 times quantityContained of nutrientTypeCode 'SALTEQ’.-->
		<xsl:if test="$targetMarket = '528' and $tradeItem/isTradeItemAConsumerUnit = 'true'">
			<xsl:variable name="na" select="nutrientDetail[nutrientTypeCode = 'NA']"/>
			<xsl:variable name="salteq" select="nutrientDetail[nutrientTypeCode = 'SALTEQ']"/>
			<xsl:if test="$na and $salteq">
				<xsl:if test="$na[quantityContained &gt; 0.1 and measurementPrecisionCode != 'LESS_THAN'] and $salteq[quantityContained &gt; 0.1 and measurementPrecisionCode != 'LESS_THAN']">
					<xsl:variable name="naValue" select="$na/quantityContained * 2.5"/>
					<xsl:variable name="salteqValue" select="$salteq/quantityContained"/>
					<xsl:if test="$naValue &gt; 1.1 * $salteqValue or $naValue &lt; 0.9 * $salteqValue">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1771" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<!--Rule 1787: If NutrientDetail class is used, then all combinations of nutrientTypeCode and measurementPrecisionCode values SHALL be unique within the same NutrientHeader class.-->
		<xsl:for-each select="nutrientDetail">
			<xsl:variable name="code" select="nutrientTypeCode"/>
			<xsl:variable name="unit" select="measurementPrecisionCode"/>
			<xsl:if test="count($parent/nutrientDetail[nutrientTypeCode = $code and measurementPrecisionCode = $unit]) &gt; 1">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1787" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>

		<!--Rule 1812: If targetMarketCountryCode equals '752' (Sweden) and nutrientTypeCode is used then nutrientBasisQuantity and nutrientBasisQuantityTypeCode SHALL be used within the same NutrientHeader class.-->
		<xsl:if test="$targetMarket = '752'">
			<xsl:if test="nutrientDetail/nutrientTypeCode">
				<xsl:if test="string(nutrientBasisQuantity) = '' or string(nutrientBasisQuantityTypeCode) = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1812" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<xsl:if test="$targetMarket = '756' or $targetMarket = '040'">
			<!--Rule 2026: If targetMarketCountryCode equals <Geographic> and nutrientTypeCode is used then nutrientBasisQuantity SHALL be used in the parent NutrientHeader class.-->
			<xsl:if test="nutrientDetail/nutrientTypeCode">
				<xsl:if test="string(nutrientBasisQuantity) = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="2026" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>

			<!--Rule 2032: If targetMarketCountryCode equals <Geographic> and nutrientBasisQuantity is used then (nutrientBasisQuantity and nutrientBasisQuantity/@measurementUnitCode) SHALL equal (100 'GRM', 100 'MLT', 1 'LTR' or 1 'PTN').-->
			<xsl:choose>
				<xsl:when test="string(nutrientBasisQuantity) = ''"/>
				<xsl:when test="nutrientBasisQuantity = '100' and nutrientBasisQuantity/@measurementUnitCode ='GRM'"/>
				<xsl:when test="nutrientBasisQuantity = '100' and nutrientBasisQuantity/@measurementUnitCode ='MLT'"/>
				<xsl:when test="nutrientBasisQuantity = '1' and nutrientBasisQuantity/@measurementUnitCode ='LTR'"/>
				<xsl:when test="nutrientBasisQuantity = '1' and nutrientBasisQuantity/@measurementUnitCode ='PTN'"/>
				<xsl:otherwise>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="2032" />
					</xsl:apply-templates>
				</xsl:otherwise>

			</xsl:choose>

			<!--Rule 2036: If targetMarketCountryCode equals <Geographic> and preparationStateCode is used then preparationStateCode SHALL equal ('PREPARED' or 'UNPREPARED').-->
			<xsl:if test="string(preparationStateCode) != '' and preparationStateCode != 'PREPARED' and preparationStateCode != 'UNPREPARED'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="2036" />
				</xsl:apply-templates>
			</xsl:if>
			
		</xsl:if>		
		
	</xsl:template>

	<xsl:template match="nutrientDetail" mode="nutritionalInformationModule">
		<xsl:param name="targetMarket"/>
		<!--Rule 1445: If nutrientTypeCode is used and measurementPrecisionCode does not equal ('ABSENCE', 'NOT_DETECTED', 'NOT_SIGNIFICANT_SOURCE_OF', 'TRACE', 'UNDETECTABLE') then at least quantityContained or dailyValueIntakePercent SHALL be used.-->
		<xsl:if test="string(nutrientTypeCode) != ''">
			<xsl:choose>
				<xsl:when test="measurementPrecisionCode = 'ABSENCE'"/>
				<xsl:when test="measurementPrecisionCode = 'NOT_DETECTED'"/>
				<xsl:when test="measurementPrecisionCode = 'NOT_SIGNIFICANT_SOURCE_OF'"/>
				<xsl:when test="measurementPrecisionCode = 'TRACE'"/>
				<xsl:when test="measurementPrecisionCode = 'UNDETECTABLE'"/>
				<xsl:otherwise>
					<xsl:if test="string(quantityContained) = '' and string(dailyValueIntakePercent) = ''">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1445" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

		<!--Rule 1739: If targetMarketCountryCode equals <Geographic> and (nutrientTypeCode, quantityContained, or measurementPrecisionCode) is used then (nutrientTypeCode, quantityContained and measurementPrecisionCode) SHALL be used.-->
		<xsl:if test="contains('040, 056, 203, 246, 250, 380, 442, 528, 703, 705, 752', $targetMarket)">
			<xsl:if test="string(nutrientTypeCode) != '' or string(quantityContained) != '' or string(measurementPrecisionCode) != ''">
				<xsl:if test="string(nutrientTypeCode) = '' or string(quantityContained) = '' or string(measurementPrecisionCode) = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1739" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>


		<xsl:if test="contains('008, 051, 031, 040, 112, 056, 070, 100, 191, 196, 203, 233, 246, 250, 268, 300, 348, 352, 372, 376, 380, 398, 417, 428, 440, 442, 807, 498, 499, 528, 578, 616, 620, 642, 643, 688, 703, 705, 752, 756, 792, 795, 826, 804, 860', $targetMarket)">
			<!--Rule 1754: If targetMarketCountryCode equals <Geographic> and nutrientDetail/measurementPrecisionCode is used, then nutrientDetail/measurementPrecisionCode SHALL equal 'APPROXIMATELY' or 'LESS_THAN'.-->
			<xsl:if test="string(measurementPrecisionCode) != '' and measurementPrecisionCode != 'APPROXIMATELY' and measurementPrecisionCode != 'LESS_THAN'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1754" />
				</xsl:apply-templates>
			</xsl:if>
			<!--Rule 1757: If targetMarketCountryCode equals <Geographic> and nutrientTypeCode is used with one of the values: 'FAT', 'FASAT', 'FAMSCIS', 'FAPUCIS', 'CHOAVL', 'PRO-', 'FIBTG', 'SUGAR-', 'SALTEQ', 'POLYL' or 'STARCH', then the value of quantityContained/@unitOfMeasurement SHALL equal 'GRM'.-->
			<xsl:variable name="c" select="nutrientTypeCode"/>
			<xsl:if test="$c = 'FAT' or $c= 'FASAT' or $c= 'FAMSCIS' or $c= 'FAPUCIS' or $c= 'CHOAVL' or $c= 'PRO-' or $c= 'FIBTG' or $c= 'SUGAR-' or $c= 'SALTEQ' or $c= 'POLYL' or $c= 'STARCH'">
				<xsl:choose>
					<xsl:when test="quantityContained[@unitOfMeasurement  = 'GRM']"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1757" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>

			<!--Rule 1763: If targetMarketCountryCode equals <geographic> and nutrientTypeCode is used, then quantityContained SHALL be used.-->
			<xsl:if test="string(nutrientTypeCode) != '' and string(quantityContained) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1763" />
				</xsl:apply-templates>
			</xsl:if>

			<!--Rule 1764: If targetMarketCountryCode equals <geographic> and (nutrientBasisQuantity equals 100 GRM, 100 MLT, 1000 MLT or 1 LTR) and dailyValueIntakePercent is used and (nutrientTypeCode is used with one of the values: 'FAT', 'FASAT', 'ENER-', 'CHOAVL', 'PRO-', 'SUGAR-' or 'SALTEQ'), then dailyValueIntakeReference SHALL be used.-->
			<xsl:variable name="base" select="../nutrientBasisQuantity"/>
			<xsl:if test="($base = 100 and $base/@measurementUnitCode = 'GRM') or ($base = 100 and $base/@measurementUnitCode = 'MLT') or ($base = 1000 and $base/@measurementUnitCode = 'MLT') or ($base = 1 and $base/@measurementUnitCode = 'LTR')">
				<xsl:choose>
					<xsl:when test="nutrientTypeCode  = 'FAT' and string(dailyValueIntakeReference) = ''">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1764" />
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="nutrientTypeCode  = 'FASAT' and string(dailyValueIntakeReference) = ''">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1764" />
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="nutrientTypeCode  = 'ENER-' and string(dailyValueIntakeReference) = ''">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1764" />
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="nutrientTypeCode  = 'CHOAVL' and string(dailyValueIntakeReference) = ''">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1764" />
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="nutrientTypeCode  = 'PRO-' and string(dailyValueIntakeReference) = ''">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1764" />
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="nutrientTypeCode  = 'SUGAR-' and string(dailyValueIntakeReference) = ''">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1764" />
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="nutrientTypeCode  = 'SALTEQ' and string(dailyValueIntakeReference) = ''">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1764" />
						</xsl:apply-templates>
					</xsl:when>
				</xsl:choose>
			</xsl:if>

			<!--Rule 1778: If targetMarketCountryCode equals geographic and nutrientTypeCode is used, then nutrientTypeCode SHALL NOT equal to 'ENERA', 'NACL', 'SUGAR', 'CHO-' and 'FIB-'.-->
			<xsl:if test="nutrientTypeCode  = 'ENERA' or nutrientTypeCode  = 'NACL' or nutrientTypeCode  = 'SUGAR' or nutrientTypeCode  = 'CHO-' or nutrientTypeCode  = 'FIB-'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1778" />
				</xsl:apply-templates>
			</xsl:if>


			
			
		</xsl:if>

		<!--Rule 1758: If dailyValueIntakePercent is used, then the value of dailyValueIntakePercent SHALL equal greater than or equal to 0 (zero).-->
		<xsl:if test="string(dailyValueIntakePercent) != '' and dailyValueIntakePercent &lt; 0">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1758" />
			</xsl:apply-templates>
		</xsl:if>
		
		
		
		
	</xsl:template>

</xsl:stylesheet>
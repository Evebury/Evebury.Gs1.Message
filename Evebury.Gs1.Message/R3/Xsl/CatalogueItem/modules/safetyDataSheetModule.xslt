<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:safety_data_sheet:xsd:3' and local-name()='safetyDataSheetModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="safetyDataSheetInformation" mode="safetyDataSheetModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="safetyDataSheetInformation" mode="safetyDataSheetModule">
		<xsl:param name="targetMarket"/>
		<!--Rule 362: If a minimum and corresponding maximum are not empty then the minimum SHALL be less than or equal to the corresponding maximum.-->
		<xsl:for-each select="chemicalInformation/chemicalIngredient">
			<xsl:if test="gs1:InvalidRange(chemicalIngredientConcentrationLowerValue,chemicalIngredientConcentrationUpperValue)">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="362"/>
				</xsl:apply-templates>
			</xsl:if>
			<xsl:if test="gs1:InvalidRange(lowerExplosiveLimit,upperExplosiveLimit)">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="362"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="specificGravityInformation">
			<xsl:if test="gs1:InvalidRange(specificGravityLowerValue,specificGravityUpperValue)">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="362"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>

		<xsl:apply-templates select="physicalChemicalPropertyInformation" mode="safetyDataSheetModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="referencedFileInformation" mode="safetyDataSheetModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="gHSDetail" mode="safetyDataSheetModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>

		<xsl:if test="$targetMarket = '756'">
			<!--Rule 2006: If targetMarketCountryCode equals <Geographic> and (chemicalIngredientIdentification is used or chemicalIngredientScheme is used) then chemicalIngredientIdentification SHALL be used and chemicalIngredientScheme SHALL equal 'UFI'.-->
			<xsl:if test="string(chemicalInformation/chemicalIngredientScheme) != '' or chemicalInformation/chemicalIngredient[string(chemicalIngredientIdentification) != '']">
				<xsl:if test="chemicalInformation/chemicalIngredientScheme != 'UFI' or chemicalInformation/chemicalIngredient[string(chemicalIngredientIdentification) = '']">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="2006" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>

		</xsl:if>

	</xsl:template>

	<xsl:template match="referencedFileInformation" mode="safetyDataSheetModule">
		<xsl:param name="targetMarket"/>
		<!--Rule 341: If a start dateTime and its corresponding end dateTime are not empty then the start date SHALL be less than or equal to corresponding end date. -->
		<xsl:if test="gs1:InvalidDateTimeSpan(fileEffectiveStartDateTime, fileEffectiveEndDateTime)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="341"/>
			</xsl:apply-templates>
		</xsl:if>
		<!--Rule 569: If targetMarketCountryCode does not equal ('756' (Switzerland), '276' (Germany), '040' (Austria), '528' (Netherlands), '056' (Belgium), '442' (Luxembourg), 203 (Czech Republic), or '250' (France)) and uniformResourceIdentifier is used and referencedFileTypeCode equals 'PRODUCT_IMAGE' then fileFormatName SHALL be used.-->
		<xsl:if test="not(contains('756, 276, 040, 528, 056, 442, 203, 250', $targetMarket))">
			<xsl:if test="string(uniformResourceIdentifier) != '' and referencedFileTypeCode = 'PRODUCT_IMAGE'">
				<xsl:choose>
					<xsl:when test="string(fileFormatName) != ''"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="569" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:if>
		<!--Rule 570: If uniformResourceIdentifier is used and referencedFileTypeCode equals  'PRODUCT_IMAGE' and targetMarketCountryCode does not equal  756 (Switzerland), 276 (Germany), 040 (Austria), 528 (Netherlands) then fileName shall be used.-->
		<xsl:if test="not(contains('756, 276, 040, 528', $targetMarket))">
			<xsl:if test="string(uniformResourceIdentifier) != '' and referencedFileTypeCode = 'PRODUCT_IMAGE'">
				<xsl:choose>
					<xsl:when test="string(fileName) != ''"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="570" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:if>
		<!--Rule 1611: If targetMarketCountryCode equals ‘250’ (France)) and uniformResourceIdentifier is used, and referencedFileTypeCode equals (‘VIDEO’ or ‘360_DEGREE_IMAGE’ or ‘MOBILE_DEVICE_IMAGE’ or ‘OUT_OF_PACKAGE_IMAGE’ or ‘PRODUCT_IMAGE’ or ‘PRODUCT_LABEL_IMAGE’ or ‘TRADE_ITEM_IMAGE_WITH_DIMENSIONS’)  then fileEffectiveStartDateTime shall  be used.-->
		<xsl:if test="$targetMarket ='250' and string(uniformResourceIdentifier) != ''">
			<xsl:if test="referencedFileTypeCode = 'VIDEO' or referencedFileTypeCode = '360_DEGREE_IMAGE' or referencedFileTypeCode = 'MOBILE_DEVICE_IMAGE' or referencedFileTypeCode = 'OUT_OF_PACKAGE_IMAGE' or referencedFileTypeCode = 'PRODUCT_IMAGE'or referencedFileTypeCode = 'PRODUCT_LABEL_IMAGE' or referencedFileTypeCode = 'TRADE_ITEM_IMAGE_WITH_DIMENSIONS'">
				<xsl:if test="string(fileEffectiveStartDateTime) = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1611" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="physicalChemicalPropertyInformation" mode="safetyDataSheetModule">
		<xsl:param name="targetMarket"/>
		<!--Rule 362: If a minimum and corresponding maximum are not empty then the minimum SHALL be less than or equal to the corresponding maximum.-->
		<xsl:if test="gs1:InvalidRange(lowerExplosiveLimit,upperExplosiveLimit)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="362"/>
			</xsl:apply-templates>
		</xsl:if>
		<xsl:for-each select="flashPoint">
			<xsl:if test="gs1:InvalidRange(flashPointTemperatureLowerValue,flashPointTemperatureUpperValue)">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="362"/>
				</xsl:apply-templates>
			</xsl:if>
			<!--Rule 1548: If flashPointDescriptor is used, then at least (flashPointtemperature, or flashPointTemperatureLowerValue or flashPointTemperatureUpperValue) shall be used.-->
			<xsl:if test="string(flashPointDescriptor) != ''">
				<xsl:if test="string(flashPointTemperature) = '' and string(flashPointTemperatureLowerValue) = '' and string(flashPointTemperatureUpperValue) = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1548" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>

		</xsl:for-each>
		<xsl:for-each select="pHInformation">
			<xsl:if test="gs1:InvalidRange(minimumPH,maximumPH)">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="362"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>

		<!--Rule 477: If targetMarketCountryCode equals <Geographic> and (maximumTemperature, minimumTemperature, flashPoint/flashPointTemperature or hazardousInformationHeader/flashPointTemperature are used) then at least one iteration of the associated measurementUnitCode SHALL equal 'CEL'.-->
		<xsl:if test="contains('752, 203, 250, 208, 246, 040, 703, 756', $targetMarket)">
			<xsl:if test="flashPoint/flashPointTemperature">
				<xsl:choose>
					<xsl:when test="flashPoint/flashPointTemperature[@temperatureMeasurementUnitCode = 'CEL']"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="477"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:if>

	</xsl:template>

	<xsl:template match="gHSDetail" mode="safetyDataSheetModule">
		<xsl:param name="targetMarket"/>
		<!--Rule 1961: If targetMarketCountryCode equals <Geographic> and hazardStatementsCode equals 'EUH208' then hazardStatementsDescription SHALL be used.-->
		<xsl:if test="contains('203, 756, 040, 703', $targetMarket)">
			<xsl:for-each select="hazardStatement">
			<xsl:if test="hazardStatementsCode  = 'EUH208' and string(hazardStatementsDescription) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1961" />
				</xsl:apply-templates>
			</xsl:if>
			</xsl:for-each>
		</xsl:if>


		<xsl:if test="$targetMarket = '756' or $targetMarket = '040'">

			<!--Rule 1962: If targetMarketCountryCode equals <Geographic> and precautionaryStatementsCode equals ('P221', 'P230', 'P231', 'P231+P232', 'P241', 'P250', 'P264', 'P264+P265', 'P301', 'P301+P310', 'P301+P310+P330+P331', 'P301+P312', 'P302', 'P302+P352', 'P303', 'P303+P361+P353+P310', 'P304', 'P304+P310', 'P304+P312', 'P304+P340+P312', 'P305', 'P305+P351+P338+P310', 'P306', 'P307+P311', 'P308', 'P308+P311', 'P310', 'P311', 'P312', 'P320', 'P321', 'P332', 'P333', 'P337', 'P342', 'P342+P311', 'P352', 'P370', 'P370+P378', 'P370+P380+P375+[P378]', 'P371', 'P378', 'P401', 'P406', 'P411', 'P411+P235', 'P413', 'P422', 'P501' or 'P503') then precautionaryStatementsDescription SHALL be used.-->
			<xsl:for-each select="precautionaryStatement">
				<xsl:if test="contains('P221, P230, P231, P231+P232, P241, P250, P264, P264+P265, P301, P301+P310, P301+P310+P330+P331, P301+P312, P302, P302+P352, P303, P303+P361+P353+P310, P304, P304+P310, P304+P312, P304+P340+P312, P305, P305+P351+P338+P310, P306, P307+P311, P308, P308+P311, P310, P311, P312, P320, P321, P332, P333, P337, P342, P342+P311, P352, P370, P370+P378, P370+P380+P375+[P378], P371, P378, P401, P406, P411, P411+P235, P413, P422, P501, P503', precautionaryStatementsCode) and string(precautionaryStatementsDescription) = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1962" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:for-each>

			<!--Rule 2007: If targetMarketCountryCode equals <Geographic> and hazardStatementsDescription is used then hazardStatementsCode SHALL be used.-->
			<xsl:if test="string(hazardStatementsDescription) != '' and string(hazardStatementsCode) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="2007" />
				</xsl:apply-templates>
			</xsl:if>

			<!--Rule 2008: If targetMarketCountryCode equals <Geographic> and precautionaryStatementsDescription is used then precautionaryStatementsCode SHALL be used.-->
			<xsl:if test="string(precautionaryStatementsDescription) != '' and string(precautionaryStatementsCode) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="2008" />
				</xsl:apply-templates>
			</xsl:if>
			
		</xsl:if>
		
	</xsl:template>

</xsl:stylesheet>
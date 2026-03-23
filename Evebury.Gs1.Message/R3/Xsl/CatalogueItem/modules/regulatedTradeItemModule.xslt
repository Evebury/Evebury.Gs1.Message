<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:regulated_trade_item:xsd:3' and local-name()='regulatedTradeItemModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="regulatoryInformation" mode="regulatedTradeItemModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
			<xsl:with-param name="tradeItem" select="$tradeItem"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="regulatoryInformation" mode="regulatedTradeItemModule">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>
		<xsl:apply-templates select="permitIdentification" mode="regulatedTradeItemModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
			<xsl:with-param name="tradeItem" select="$tradeItem"/>
		</xsl:apply-templates>
		<!--Rule 1353: If targetMarketCountrycode equals '752' (Sweden) and regulationTypeCode equals 'TRACEABILITY_REGULATION', then regulatoryAct AND regulatoryAgency shall be used.-->
		<xsl:if test="$targetMarket = '752'">
			<xsl:if test="regulationTypeCode = 'TRACEABILITY_REGULATION'">
				<xsl:if test="string(regulatoryAct)  = '' or string(regulatoryAgency) = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1353" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<!--Rule 1704: If targetMarketCountryCode equals '250' (France) and regulationTypeCode equals 'BIOCIDE_REGULATION', then regulationLevelCodeReference SHALL be populated.-->
		<xsl:if test="$targetMarket = '250'">
			<xsl:if test="regulationTypeCode = 'BIOCIDE_REGULATION'">
				<xsl:if test="string(regulationLevelCodeReference)  = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1704" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>
		
		<xsl:if test="$targetMarket = '756'">

			<!--Rule 1943: If targetMarketCountryCode equals <Geographic> and regulationTypeCode equals 'EXPLOSIVES_PRECURSORS_REGISTRATION' and isTradeItemRegulationCompliant equals 'TRUE' then regulationLevelCodeReference and regulatoryActComplianceLevelCode SHALL be used.-->
			<xsl:if test="regulationTypeCode = 'EXPLOSIVES_PRECURSORS_REGISTRATION' and isTradeItemRegulationCompliant = 'TRUE'">
				<xsl:if test="string(regulatoryActComplianceLevelCode) = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1943" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>

			<!--Rule 2011: If targetMarketCountryCode equals <Geographic> and (regulationLevelCodeReference is used or regulatoryActComplianceLevelCode is used) then regulationTypeCode SHALL equal 'EXPLOSIVES_PRECURSORS_REGISTRATION' and isTradeItemRegulationCompliant SHALL equal 'TRUE'.-->
			<xsl:if test="string(regulationLevelCodeReference) != '' or string(regulatoryActComplianceLevelCode) != ''">
				<xsl:if test="string(regulationTypeCode) != 'EXPLOSIVES_PRECURSORS_REGISTRATION' or string(isTradeItemRegulationCompliant) != 'TRUE'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="2011" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
			
			
		</xsl:if>

		<xsl:if test="$targetMarket = '756' or $targetMarket = '040'">
			<!--Rule 2003: If targetMarketCountryCode equals <Geographic> and isTradeItemABaseUnit equals 'true' and regulatoryAct equals 'GHS' and corresponding regulatoryPermitIdentification equals 'TRUE' then gHSSymbolDescriptionCode SHALL be used and hazardStatementsCode SHALL be used and precautionaryStatementsCode SHALL be used.-->
			<xsl:if test="$tradeItem/isTradeItemABaseUnit = 'true' and regulatoryAct = 'GHS'">
				<xsl:if test="isTradeItemRegulationCompliant = 'TRUE'">
					<xsl:for-each select="$tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:safety_data_sheet:xsd:3' and local-name()='safetyDataSheetModule']/safetyDataSheetInformation/gHSDetail">
						<xsl:if test="string(precautionaryStatement/precautionaryStatementsCode) = '' or string(hazardStatement/hazardStatementsCode) = '' or string(gHSSymbolDescriptionCode) = ''">
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="2003" />
							</xsl:apply-templates>
						</xsl:if>
					</xsl:for-each>
				</xsl:if>
			</xsl:if>

			<!--Rule 2020: If targetMarketCountryCode equals <Geographic> and regulatoryAgency equals 'UN' and regulatoryAct equals 'GHS' then the corresponding regulatoryPermitIdentification SHALL equal ('TRUE' or 'FALSE').-->
			<xsl:if test="regulatoryAgency = 'UN' or regulatoryAct = 'GHS'">
				<xsl:if test="string(isTradeItemRegulationCompliant) != 'FALSE' and string(isTradeItemRegulationCompliant) != 'TRUE'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="2020" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
			
			
		</xsl:if>

	</xsl:template>

	<xsl:template match="permitIdentification" mode="regulatedTradeItemModule">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>
		<!--Rule 341: If a start dateTime and its corresponding end dateTime are not empty then the start date SHALL be less than or equal to corresponding end date. -->
		<xsl:if test="gs1:InvalidDateTimeSpan(permitStartDateTime, permitEndDateTime)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="341"/>
			</xsl:apply-templates>
		</xsl:if>

		<!--Rule 1300: If TargetMarket equals '124' (Canada) and regulatoryPermitIdentification is used, then doesSaleOfTradeItemRequireGovernmentalReporting shall be used.-->
		<xsl:if test="$targetMarket  = '124'">
			<xsl:if test="string(regulatoryPermitIdentification) != ''">
				<xsl:if test="string($tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:healthcare_item_information:xsd:3' and local-name()='healthcareItemInformationModule']/healthcareItemInformation/doesSaleOfTradeItemRequireGovernmentalReporting) = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1300" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>
	</xsl:template>



</xsl:stylesheet>
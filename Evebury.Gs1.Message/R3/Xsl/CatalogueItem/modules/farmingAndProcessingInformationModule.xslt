<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:farming_and_processing_information:xsd:3' and local-name()='farmingAndProcessingInformationModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>


		<xsl:apply-templates select="tradeItemFarmingAndProcessing" mode="farmingAndProcessingInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
			<xsl:with-param name="tradeItem" select="$tradeItem"/>
		</xsl:apply-templates>



	</xsl:template>

	<xsl:template match="tradeItemFarmingAndProcessing" mode="farmingAndProcessingInformationModule">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<!--Rule 586: If targetMarketCountryCode is equal to '840' (US) and growingMethodCode  is equal to 'ORGANIC' then organicClaimAgencyCode and organicTradeItemCode must not  be empty.-->
		<xsl:if test="$targetMarket = '840'">
			<xsl:if test="growingMethodCode = 'ORGANIC'">
				<xsl:for-each select="tradeItemOrganicInformation/organicClaim">
					<xsl:if test="string(organicClaimAgencyCode) = '' or string(organicTradeItemCode) = ''">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="586" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
		</xsl:if>



		<xsl:variable name="isEU" select="contains('008, 051, 031, 112, 056, 070, 100, 191, 196, 203, 208, 233, 246, 250, 268, 300, 348, 352, 372, 376, 380, 398, 417, 428, 440, 442, 807, 498, 499, 528, 578, 616, 620, 642, 643, 688, 703, 705, 724, 752, 792, 795, 826, 804, 860', $targetMarket)"/>


		<xsl:if test="$isEU">


			<!--Rule 1569: If targetMarketCountryCode equals EU
and GDSNTradeItemClassification/gpcCategoryCode belongs to any of the GPC families ('50100000', '50250000', '50260000', '50270000', '50290000', '50310000', '50320000', '50350000', '50360000', '50370000' or '50380000') and tradeItemFarmingAndProcessing/growingMethodCode equals 'ORGANIC' then tradeItemOrganicInformation/organicClaim/organicClaimAgencyCode SHALL be used.-->
			<xsl:if test="growingMethodCode = 'ORGANIC'">
				<xsl:variable name="brick" select="$tradeItem/gDSNTradeItemClassification/gpcCategoryCode"/>
				<xsl:if test="gs1:IsInFamily($brick, '50100000, 50250000, 50260000, 50270000, 50290000, 50310000, 50320000, 50350000, 50360000, 50370000, 50380000')">
					<xsl:if test="string(tradeItemOrganicInformation/organicClaim/organicClaimAgencyCode) = ''">
						<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1569" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:if>
			</xsl:if>

			<!--Rule 1570: If targetMarketCountryCode equals EU and GDSNTradeItemClassification/gpcCategoryCode belongs to any of the GPC families ('50100000', '50250000', '50260000', '50270000', '50290000', '50310000', '50320000', '50350000', '50360000', '50370000' or '50380000') and tradeItemFarmingAndProcessing/growingMethodCode is used, then tradeItemFarmingAndProcessing/growingMethodCode SHALL equal ('CONVENTIONAL', 'FIELD_GROWN', 'GREENHOUSE', 'HYDROPONIC', 'INTEGRATED_PEST_MANAGEMENT', 'ORGANIC', 'SHADE_GROWN', or 'WILD').-->

			<xsl:variable name="brick" select="$tradeItem/gDSNTradeItemClassification/gpcCategoryCode"/>
			<xsl:if test="gs1:IsInFamily($brick, '50100000, 50250000, 50260000, 50270000, 50290000, 50310000, 50320000, 50350000, 50360000, 50370000, 50380000')">
				<xsl:for-each select="growingMethodCode">
					<xsl:choose>
						<xsl:when test=". = 'CONVENTIONAL'"/>
						<xsl:when test=". = 'FIELD_GROWN'"/>
						<xsl:when test=". = 'GREENHOUSE'"/>
						<xsl:when test=". = 'HYDROPONIC'"/>
						<xsl:when test=". = 'INTEGRATED_PEST_MANAGEMENT'"/>
						<xsl:when test=". = 'ORGANIC'"/>
						<xsl:when test=". = 'SHADE_GROWN'"/>
						<xsl:when test=". = 'WILD'"/>
						<xsl:otherwise>
							<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="1570" />
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>

				<!--Rule 1617: If targetMarketCountryCode equals EU, and GPC Brick belongs to the GPC families ('50100000', '50250000', '50260000', '50270000', '50290000', '50310000', '50320000', '50350000', '50360000', '50370000' or '50380000') and growingMethodCode  equals 'ORGANIC' then farmingAndProcessingInformationModule/tradeItemOrganicInformation/organicClaim/organicTradeItemCode SHALL be used.-->
				<xsl:if test="string(tradeItemOrganicInformation/organicClaim/organicTradeItemCode) = ''">
					<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1617" />
					</xsl:apply-templates>
				</xsl:if>

			</xsl:if>



			<!--Rule 1874: If targetMarketCountryCode equals <Geographic> then organicTradeItemCode SHALL NOT equal '1'.-->
			<xsl:if test="tradeItemOrganicInformation/organicClaim[organicTradeItemCode = '1']">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1874" />
				</xsl:apply-templates>
			</xsl:if>

		</xsl:if>

		
		<xsl:if test="$targetMarket = '756' or $targetMarket = '040'">

			<!--Rule 1955: If targetMarketCountryCode equals <Geographic> and geneticallyModifiedDeclarationCode is used then it SHALL equal ('CONTAINS', 'FREE_FROM' or 'MAY_CONTAIN').-->
			<xsl:if test="string(geneticallyModifiedDeclarationCode) != ''">
				<xsl:choose>
					<xsl:when test="geneticallyModifiedDeclarationCode = 'CONTAINS'"/>
					<xsl:when test="geneticallyModifiedDeclarationCode = 'FREE_FROM'"/>
					<xsl:when test="geneticallyModifiedDeclarationCode = 'MAY_CONTAIN'"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1955" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>

			<!--Rule 2037: If targetMarketCountryCode equals <Geographic> and organicTradeItemCode is used and organicTradeItemCode is equal to ('2' or '6') then organicCertificationIdentification SHALL be used.-->
			<xsl:if test="tradeItemOrganicInformation/organicClaim[organicTradeItemCode = '2']">
				<xsl:if test="string(tradeItemOrganicInformation/organicClaim[organicTradeItemCode = '2']/organicCertification/organicCertificationIdentification) = ''">
					<xsl:apply-templates select="tradeItemOrganicInformation/organicClaim[organicTradeItemCode = '2']" mode="error">
						<xsl:with-param name="id" select="2037" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
			<xsl:if test="tradeItemOrganicInformation/organicClaim[organicTradeItemCode = '6']">
				<xsl:if test="string(tradeItemOrganicInformation/organicClaim[organicTradeItemCode = '6']/organicCertification/organicCertificationIdentification) = ''">
					<xsl:apply-templates select="tradeItemOrganicInformation/organicClaim[organicTradeItemCode = '6']" mode="error">
						<xsl:with-param name="id" select="2037" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>

			<!--Rule 2038: If targetMarketCountryCode equals <Geographic> and organicCertificationIdentification is used then organicTradeItemCode SHALL equal ('2' or '6').-->
			<xsl:for-each select="tradeItemOrganicInformation/organicClaim">
				<xsl:if test="string(organicCertification/organicCertificationIdentification) != ''">
					<xsl:if test="string(organicTradeItemCode) != '2' and string(organicTradeItemCode) != '6'">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="2038" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>

	</xsl:template>



</xsl:stylesheet>
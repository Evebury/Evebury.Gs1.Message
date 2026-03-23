<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:packaging_information:xsd:3' and local-name()='packagingInformationModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="packaging" mode="packagingInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
			<xsl:with-param name="tradeItem" select="$tradeItem"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="packaging" mode="packagingInformationModule">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="packagingOwnerIdentification" mode="gln"/>
		
		<!--Rule 506: If targetMarketCountryCode equals <Geographic> and packagingMaterialCompositionQuantity is used then in at least one iteration of packagingMaterialCompositionQuantity the related packagingMaterialCompositionQuantity/@measurementUnitCode SHALL equal 'KGM' or 'GRM'.-->
		<xsl:if test="contains('056, 203, 246, 442, 528, 752', $targetMarket)">
			<xsl:if test="packagingMaterial/packagingMaterialCompositionQuantity[text() != '']">
				<xsl:choose>
					<xsl:when test="packagingMaterial/packagingMaterialCompositionQuantity[text() != '' and @measurementUnitCode = 'KGM']"/>
					<xsl:when test="packagingMaterialCompositionQuantity[text() != '' and @measurementUnitCode = 'GRM']"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="506" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:if>

		<!--Rule 507: If packagingMaterialCompositionQuantity and packagingWeight are not empty then the sum of all instances of  packagingMaterialCompositionQuantity for the trade item must be less than or equal to packagingWeight.-->
		<xsl:if test="string(packagingWeight) != '' and packagingMaterial/packagingMaterialCompositionQuantity[text() != '']">
			<xsl:variable name="packagingWeight">
				<xsl:apply-templates select="packagingWeight" mode="measurementUnit"/>
			</xsl:variable>
			<xsl:variable name="itemWeight">
				<xsl:call-template name="r507">
					<xsl:with-param name="items" select="packagingMaterial/packagingMaterialCompositionQuantity"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:if test="$itemWeight &gt; $packagingWeight">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="507" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<!--Rule 540: If parent item platformTypeCode is equal to '11', and the child platformTypeCode is equal to '10' then quantityOfNextLowerLevelTradeItem of the parent item must not be greater than 2.-->
		<xsl:if test="platformTypeCode = '11'">
			<xsl:variable name="quantity" select="sum(nextLowerLevelTradeItemInformation/childTradeItem/quantityOfNextLowerLevelTradeItem)"/>
			<xsl:for-each select="$tradeItem/../catalogueItemChildItemLink/catalogueItem/tradeItem">
				<xsl:if test="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:packaging_information:xsd:3' and local-name()='packagingInformationModule']/packaging/platformTypeCode = '10'">
					<xsl:if test="$quantity &gt; 2">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="540" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>


		<xsl:if test="$targetMarket = '249' or $targetMarket = '250'">
			<xsl:if test="$tradeItem/tradeItemUnitDescriptorCode = 'PALLET'">
				<xsl:variable name="module" select="$tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_measurements:xsd:3' and local-name()='tradeItemMeasurementsModule']/tradeItemMeasurements"/>
				<xsl:choose>
					<xsl:when test="platformTypeCode = '10'">
						<!--Rule 1107: If targetMarketCountryCode equals ('249' (France) or '250' (France))  and tradeItemUnitDescriptorCode equals 'PALLET' and platformTypeCode equals '10', then depth shall be between and including  ('800 MMT' or '31.50 IN')  and ('1600 MMT' or '63 IN') and width shall be between and including (' '600 MMT' or '23.62 IN') and ('1200 MMT' or '47.24 IN').-->
						<xsl:call-template name="packagingInformationModule_france_pallet">
							<xsl:with-param name="module" select="$module"/>
							<xsl:with-param name="error" select="1107"/>
							<xsl:with-param name="minDepth" select="800"/>
							<xsl:with-param name="maxDepth" select="1600"/>
							<xsl:with-param name="minWidth" select="600"/>
							<xsl:with-param name="maxWidth" select="1200"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="platformTypeCode = '49'">
						<!--Rule 1124: If targetMarketCountryCode equals ('249' (France) or '250' (France)) and tradeItemUnitDescriptorCode equals 'PALLET' and platformTypeCode equals  '49', then TradeItemMeasurements/depth shall be between and including ('610 MMT' or '24.02 IN') and ('1220 MMT' or '48.04 IN') and TradeItemMeasurements/width shall be between and including ('508 MMT' or '20 IN') and ('1016 MMT' or '40 IN').-->
						<xsl:call-template name="packagingInformationModule_france_pallet">
							<xsl:with-param name="module" select="$module"/>
							<xsl:with-param name="error" select="1124"/>
							<xsl:with-param name="minDepth" select="610"/>
							<xsl:with-param name="maxDepth" select="1220"/>
							<xsl:with-param name="minWidth" select="508"/>
							<xsl:with-param name="maxWidth" select="1016"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="platformTypeCode = '48'">
						<!--Rule 1125: If targetMarketCountryCode equals ('249' (France) or '250' (France)) and tradeItemUnitDescriptorCode equals 'PALLET' and platformTypeCode equals  '48', then TradeItemMeasurements/depth shall be between and including ('610 MMT' or '24.02 IN') and ('1220 MMT' or '48.04 IN') and TradeItemMeasurements/width shall be between and including ('1016 MMT' or '40 IN') and ('2032 MMT' or '80 IN').-->
						<xsl:call-template name="packagingInformationModule_france_pallet">
							<xsl:with-param name="module" select="$module"/>
							<xsl:with-param name="error" select="1125"/>
							<xsl:with-param name="minDepth" select="610"/>
							<xsl:with-param name="maxDepth" select="1220"/>
							<xsl:with-param name="minWidth" select="1016"/>
							<xsl:with-param name="maxWidth" select="2032"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="platformTypeCode = '47'">
						<!--Rule 1126: If targetMarketCountryCode equals ('249' (France) or '250' (France)) and  tradeItemUnitDescriptorCode equals 'PALLET' and platformTypeCode equals  '47', then TradeItemMeasurements/depth shall be between and including ('400 MMT' or '15.75 IN') and ('800 MMT' or '31.5 IN'), and TradeItemMeasurements/width shall be between and including ( '800 MMT' or '31.50 IN) and ('1600 MMT' or '63 IN').-->
						<xsl:call-template name="packagingInformationModule_france_pallet">
							<xsl:with-param name="module" select="$module"/>
							<xsl:with-param name="error" select="1126"/>
							<xsl:with-param name="minDepth" select="400"/>
							<xsl:with-param name="maxDepth" select="800"/>
							<xsl:with-param name="minWidth" select="800"/>
							<xsl:with-param name="maxWidth" select="1600"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="platformTypeCode = '43'">
						<!--Rule 1127: If targetMarketCountryCode equals ('249' (France) or '250' (France)) and  tradeItemUnitDescriptorCode equals 'PALLET' and platformTypeCode equals  '43', then TradeItemMeasurements/depth shall be between and including ('1140 MMT' or '43.31 IN') and  ('2280 MMT' or '86.62 IN') and TradeItemMeasurements/width shall be between and including ('1140 MMT' or '43.31 IN') and ('2280 MMT' or '86.62 IN').-->
						<xsl:call-template name="packagingInformationModule_france_pallet">
							<xsl:with-param name="module" select="$module"/>
							<xsl:with-param name="error" select="1127"/>
							<xsl:with-param name="minDepth" select="1140"/>
							<xsl:with-param name="maxDepth" select="2280"/>
							<xsl:with-param name="minWidth" select="1140"/>
							<xsl:with-param name="maxWidth" select="2280"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="platformTypeCode = '42'">
						<!--Rule 1128: If targetMarketCountryCode equals ('249' (France) or '250' (France)) and tradeItemUnitDescriptorCode equals 'PALLET' and platformTypeCode equals  '42', then TradeItemMeasurements/depth shall bebetween and including ('1100 MMT' or '43.31 IN') and ('2200 MMT' or '86.62 IN') and TradeItemMeasurements/width shall be between and including ('1100 MMT' or '43.31 IN') and ('2200 MMT' or '86.62 IN').-->
						<xsl:call-template name="packagingInformationModule_france_pallet">
							<xsl:with-param name="module" select="$module"/>
							<xsl:with-param name="error" select="1128"/>
							<xsl:with-param name="minDepth" select="1100"/>
							<xsl:with-param name="maxDepth" select="2200"/>
							<xsl:with-param name="minWidth" select="1100"/>
							<xsl:with-param name="maxWidth" select="2200"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="platformTypeCode = '41'">
						<!--Rule 1129: If targetMarketCountryCode equals ('249' (France) or '250' (France)) and  tradeItemUnitDescriptorCode equals 'PALLET' and platformTypeCode equals  '41', then TradeItemMeasurements/depth shall be between and including ('1067 MMT' or '42.01 IN') and ('2134 MMT' or '84.02 IN') and TradeItemMeasurements/width shall be between and including ('1067 MMT' or '42.01 IN') and ('2134 MMT' or '84.02 IN').-->
						<xsl:call-template name="packagingInformationModule_france_pallet">
							<xsl:with-param name="module" select="$module"/>
							<xsl:with-param name="error" select="1129"/>
							<xsl:with-param name="minDepth" select="1067"/>
							<xsl:with-param name="maxDepth" select="2134"/>
							<xsl:with-param name="minWidth" select="1067"/>
							<xsl:with-param name="maxWidth" select="2134"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="platformTypeCode = '40'">
						<!--Rule 1130: If targetMarketCountryCode equals ('249' (France) or '250' (France)) and tradeItemUnitDescriptorCode equals 'PALLET' and platformTypeCode equals  '40', then TradeItemMeasurements/depth shall be between and including ('1016 MMT' or '40 IN') and ('2032 MMT' or '80 IN') and TradeItemMeasurements/width shall be between and including ('1219 MMT' or '47.99 IN') and ('2438 MMT' or '95.98 IN').-->
						<xsl:call-template name="packagingInformationModule_france_pallet">
							<xsl:with-param name="module" select="$module"/>
							<xsl:with-param name="error" select="1130"/>
							<xsl:with-param name="minDepth" select="1016"/>
							<xsl:with-param name="maxDepth" select="2032"/>
							<xsl:with-param name="minWidth" select="1219"/>
							<xsl:with-param name="maxWidth" select="2438"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="platformTypeCode = '35'">
						<!--Rule 1133: If targetMarketCountryCode equals ('249' (France) or '250' (France)) and tradeItemUnitDescriptorCode equals 'PALLET' and platformTypeCode equals  '35', then TradeItemMeasurements/depth shall be between and including ('1200 MMT' or '47.24 IN') and ('2400 MMT' or '94.5 IN'), and TradeItemMeasurements/width shall be between and including ('1000 MMT' or '39.37 IN') and ('2000 MMT' or '78.74 IN').-->
						<xsl:call-template name="packagingInformationModule_france_pallet">
							<xsl:with-param name="module" select="$module"/>
							<xsl:with-param name="error" select="1133"/>
							<xsl:with-param name="minDepth" select="1200"/>
							<xsl:with-param name="maxDepth" select="2400"/>
							<xsl:with-param name="minWidth" select="1000"/>
							<xsl:with-param name="maxWidth" select="2000"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="platformTypeCode = '31'">
						<!--Rule 1135: If targetMarketCountryCode equals ('249' (France) or '250' (France)) and tradeItemUnitDescriptorCode equals 'PALLET' and platformTypeCode equals  '31', then TradeItemMeasurements/depth shall be between and including  ('1000 MMT' or '39.37 IN') and ('2000 MMT' or '78.74 IN') and TradeItemMeasurements/width shall be between and including ('600 MMT' or '23.62 IN') and ('1200 MMT' or '47.34 IN').-->
						<xsl:call-template name="packagingInformationModule_france_pallet">
							<xsl:with-param name="module" select="$module"/>
							<xsl:with-param name="error" select="1135"/>
							<xsl:with-param name="minDepth" select="1000"/>
							<xsl:with-param name="maxDepth" select="2000"/>
							<xsl:with-param name="minWidth" select="600"/>
							<xsl:with-param name="maxWidth" select="1200"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="platformTypeCode = '31'">
						<!--Rule 1137: If targetMarketCountryCode equals ('249' (France) or '250' (France)) and tradeItemUnitDescriptorCode equals 'PALLET' and platformTypeCode equals  '25', then TradeItemMeasurements/depth shall be between and including ('1165 MMT' or '45.87 IN') and ('2330 MMT' or '91.74 IN'), and TradeItemMeasurements/width shall be between and including ('1165 MMT' or '45.87 IN') and ('2330 MMT' or '91.74 IN').-->
						<xsl:call-template name="packagingInformationModule_france_pallet">
							<xsl:with-param name="module" select="$module"/>
							<xsl:with-param name="error" select="1137"/>
							<xsl:with-param name="minDepth" select="1165"/>
							<xsl:with-param name="maxDepth" select="2330"/>
							<xsl:with-param name="minWidth" select="1165"/>
							<xsl:with-param name="maxWidth" select="2330"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="platformTypeCode = '14'">
						<!--Rule 1138: If targetMarketCountryCode equals ('249' (France) or '250' (France)) and tradeItemUnitDescriptorCode equals 'PALLET' and platformTypeCode equals  '14', then TradeItemMeasurements/depth shall be between and including ('400 MMT' or '15.75 IN') and ('800 MMT' or '31.5 IN'), and TradeItemMeasurements/width shall be between and including ('300 MMT' or '11.81 IN') and ('600 MMT' or '23.62 IN').-->
						<xsl:call-template name="packagingInformationModule_france_pallet">
							<xsl:with-param name="module" select="$module"/>
							<xsl:with-param name="error" select="1138"/>
							<xsl:with-param name="minDepth" select="400"/>
							<xsl:with-param name="maxDepth" select="800"/>
							<xsl:with-param name="minWidth" select="300"/>
							<xsl:with-param name="maxWidth" select="600"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="platformTypeCode = '13'">
						<!--Rule 1139: If targetMarketCountryCode equals ('249' (France) or '250' (France)) and  tradeItemUnitDescriptorCode equals 'PALLET' and platformTypeCode equals  '13', then TradeItemMeasurements/depth shall be between and including ('600 MMT' or '23.62 IN') and ('1200 MMT' or '47.24 IN'), and TradeItemMeasurements/width shall be between and including ('400 MMT' or '15.75 IN') and ('800 MMT' or '31.5 IN').-->
						<xsl:call-template name="packagingInformationModule_france_pallet">
							<xsl:with-param name="module" select="$module"/>
							<xsl:with-param name="error" select="1139"/>
							<xsl:with-param name="minDepth" select="600"/>
							<xsl:with-param name="maxDepth" select="1200"/>
							<xsl:with-param name="minWidth" select="400"/>
							<xsl:with-param name="maxWidth" select="800"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="platformTypeCode = '12'">
						<!--Rule 1140: If targetMarketCountryCode equals ('249' (France) or '250' (France)) and tradeItemUnitDescriptorCode equals 'PALLET' and platformTypeCode equals  '12', then TradeItemMeasurements/depth shall be between and including ('1200 MMT' or '47.24 IN') and ('2400 MMT' or '94.48 IN'), and TradeItemMeasurements/width shall be between and including ('1000 MMT' or '39.37 IN') and ('2000 MMT' or '78.74 IN').-->
						<xsl:call-template name="packagingInformationModule_france_pallet">
							<xsl:with-param name="module" select="$module"/>
							<xsl:with-param name="error" select="1140"/>
							<xsl:with-param name="minDepth" select="1200"/>
							<xsl:with-param name="maxDepth" select="2400"/>
							<xsl:with-param name="minWidth" select="1000"/>
							<xsl:with-param name="maxWidth" select="2000"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="platformTypeCode = '11'">
						<!--Rule 1141: If targetMarketCountryCode equals ('249' (France) or '250' (France)) and  tradeItemUnitDescriptorCode equals 'PALLET' and platformTypeCode equals  '11', then TradeItemMeasurements/depth shall be between and including ('1200 MMT' or '47.24 IN') and ('2400 MMT' or '94.48 IN'), and TradeItemMeasurements/width shall be between and including ('800 MMT' or '31.50 IN') and ('1600 MMT' or '63 IN').-->
						<xsl:call-template name="packagingInformationModule_france_pallet">
							<xsl:with-param name="module" select="$module"/>
							<xsl:with-param name="error" select="11401"/>
							<xsl:with-param name="minDepth" select="1200"/>
							<xsl:with-param name="maxDepth" select="2400"/>
							<xsl:with-param name="minWidth" select="800"/>
							<xsl:with-param name="maxWidth" select="1600"/>
						</xsl:call-template>
					</xsl:when>
				</xsl:choose>


			</xsl:if>
		</xsl:if>


		<!--Rule 1166: If (PackagingDimension/packagingDepth or PackagingDimension/packagingWidth are used) and (platformTypeCode is not used or equal to '98' or packagingTypeCode does not equal to 'PX'('Pallet')) then PackagingDimension/packagingHeight SHALL be used.-->
		<xsl:if test="string(packagingDimension/packagingDepth) != '' or string(packagingDimension/packagingWidth) != ''">
			<xsl:if test="string(platformTypeCode) = '' or platformTypeCode = '98' or packagingTypeCode != 'PX'">
				<xsl:if test="string(packagingDimension/packagingHeight) = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1166" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<xsl:variable name="packaging" select="."/>

		<!--Rule 1209: There must be at most one iteration of packagingRefundObligationName -->
		<xsl:for-each select="packagingRefundObligationName">
			<xsl:variable name="value" select="."/>
			<xsl:if test="count($packaging[packagingRefundObligationName = $value]) &gt; 1">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1209" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>


		<!--Rule 1210: There must be at most one iteration of packagingRefuseObligationName -->
		<xsl:for-each select="packagingRefuseObligationName">
			<xsl:variable name="value" select="."/>
			<xsl:if test="count($packaging[packagingRefuseObligationName = $value]) &gt; 1">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1210" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>

		<!--Rule 1211: If PackagingInformationModule/Packaging/packagingTermsAndConditionsCode is used, then it shall not exceed one iteration.-->
		<xsl:for-each select="packagingTermsAndConditionsCode">
			<xsl:variable name="value" select="."/>
			<xsl:if test="count($packaging[packagingTermsAndConditionsCode = $value]) &gt; 1">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1211" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>

		<!--Rule 1293: If Packaging class or sub-classes are not empty then packagingTypeCode or platformTypeCode SHALL be used-->
		<xsl:if test="string(packagingTypeCode)  = '' and string(platformTypeCode) = ''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1293" />
			</xsl:apply-templates>
		</xsl:if>

		<!--Rule 1310: If packagingFunctioncode is equal to "TAMPER_EVIDENT" then"packagingTypeCode must not be empty.-->
		<xsl:if test="packagingFunctionCode  = 'TAMPER_EVIDENT'">
			<xsl:if test="string(packagingTypeCode) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1310" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<!--Rule 1312: If platformTermsAndConditionsCode is used then platformTypeCode SHALL be used and SHALL NOT equal to '98'.-->
		<xsl:if test="string(platformTermsAndConditionsCode)  != ''">
			<xsl:if test="string(platformTypeCode) = '' or platformTypeCode  = '98'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1312" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
		<xsl:apply-templates select="packagingMaterial" mode="packagingInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="packageDeposit" mode="packagingInformationModule"/>
		<xsl:apply-templates select="returnableAsset" mode="packagingInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>
		<!--Rule 1742: If targetMarketCountryCode equals <Geographic> and Packaging class or sub-classes are used then packagingTypeCode SHALL be used in each iteration of the Packaging class.-->
		<xsl:if test="string(packagingTypeCode)  = ''">
			<xsl:if test="contains('056, 208, 246, 250, 442, 528', $targetMarket)">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1742" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<!--Rule 1773: If targetMarketCountryCode equals '528' (Netherlands) and the value of gpcCategoryCode equals one of the bricks in GPC families ('50250000', '50260000' or '50350000') and packagingTypeCode is not equal to 'X11' or 'NE', then isPackagingMarkedReturnable SHALL be used.-->
		<xsl:if test="$targetMarket  = '528' and string(isPackagingMarkedReturnable) = ''">
			<xsl:choose>
				<xsl:when test="packagingTypeCode = 'X11'"/>
				<xsl:when test="packagingTypeCode = 'NE'"/>
				<xsl:otherwise>
					<xsl:variable name="brick" select="$tradeItem/gDSNTradeItemClassification/gpcCategoryCode"/>
					<xsl:if test="gs1:IsInFamily($brick, '50250000, 50260000, 50350000')">
						<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1773" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

		<!--Rule 1776: If packagingTypeCode equals 'NE', then drainedWeight SHALL NOT be used.-->
		<xsl:if test="packagingTypeCode = 'NE'">
			<xsl:if test="string($tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_measurements:xsd:3' and local-name()='tradeItemMeasurementsModule']/tradeItemMeasurements/tradeItemWeight/drainedWeight) != ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1776" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<!--Rule 1823: If targetMarketCountryCode equals '250' (France) and isTradeItemADespatchUnit equals 'true' and (isTradeItemPackedIrregularly equals 'FALSE' or is not used) and platformTypeCode is used, then quantityOfCompleteLayersContainedInATradeItem SHALL be greater than 0.-->
		<xsl:if test="string(platformTypeCode) != '' and $targetMarket='250' and $tradeItem/isTradeItemADespatchUnit = 'true'">
			<xsl:if test="$tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_hierarchy:xsd:3' and local-name()='tradeItemHierarchyModule']/tradeItemHierarchy/isTradeItemPackedIrregularly != 'true'">
				<xsl:if test="string($tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_hierarchy:xsd:3' and local-name()='tradeItemHierarchyModule']/tradeItemHierarchy/quantityOfCompleteLayersContainedInATradeItem) = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1823" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<!--Rule 1868: packagingClaimTypeCode and packagingClaimElementCode should be both used if one is used.-->
		<xsl:for-each select="packagingClaims">
			<xsl:if test="(string(packagingClaimElementCode) != '' or string(packagingClaimTypeCode) !='') and (string(packagingClaimElementCode) = '' or string(packagingClaimTypeCode) ='')">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1868" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>

		<xsl:if test="$targetMarket = '756' and $targetMarket = '040'">

			<!--Rule 1984: If targetMarketCountryCode equals <Geographic> and tradeItemUnitDescriptorCode does not equal ('PALLET' or 'MIXED_MODULE') and isTradeItemADespatchUnit equals 'true' and (platformTypeCode is used and does not equal '98') then platformTermsAndConditionsCode SHALL be used in every iteration where platformTypeCode is used and quantityOfTradeItemsPerPallet SHALL be used and quantityOfLayersPerPallet SHALL be used and logisticsUnitStackingFactor SHALL be used and nonGTINLogisticsUnitInformation/grossWeight SHALL be used and nonGTINLogisticsUnitInformation/height SHALL be used and nonGTINLogisticsUnitInformation/depth SHALL be used and nonGTINLogisticsUnitInformation/width SHALL be used.-->
			<xsl:if test="string(platformTypeCode) != '' and platformTypeCode != '98'">
				<xsl:if test="$tradeItem/isTradeItemADespatchUnit = 'true' and $tradeItem/tradeItemUnitDescriptorCode != 'PALLET' and $tradeItem/tradeItemUnitDescriptorCode != 'MIXED_MODULE'">
					<xsl:variable name="mod1" select="$tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_hierarchy:xsd:3' and local-name()='tradeItemHierarchyModule']/tradeItemHierarchy"/>
					<xsl:variable name="mod2" select="tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:nongtin_logistics_unit_information:xsd:3' and local-name()='nonGTINLogisticsUnitInformationModule']/nonGTINLogisticsUnitInformation"/>
					<xsl:if test="string(platformTermsAndConditionsCode) = '' or string($mod1/quantityOfTradeItemsPerPallet) = '' or string($mod1/quantityOfLayersPerPallet) = '' or string($mod2/logisticsUnitStackingFactor) = '' or string($mod2/grossWeight) = '' or string($mod2/height) = '' or string($mod2/depth) = '' or string($mod2/width) = ''">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1984" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:if>
			</xsl:if>

			<!--Rule 1985: If targetMarketCountryCode equals <Geographic> and platformTypeCode is used then isTradeItemADespatchUnit SHALL equal 'true'.-->
			<xsl:if test="string(platformTypeCode) != '' and string($tradeItem/isTradeItemADespatchUnit) != 'true'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1985" />
				</xsl:apply-templates>
			</xsl:if>
			
		</xsl:if>
	</xsl:template>

	<xsl:template name="packagingInformationModule_france_pallet">
		<xsl:param name="module"/>
		<xsl:param name="minDepth"/>
		<xsl:param name="maxDepth"/>
		<xsl:param name="minWidth"/>
		<xsl:param name="maxWidth"/>
		<xsl:param name="error"/>
		<xsl:choose>
			<xsl:when test="string($module/depth) = '' or string($module/width) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="$error" />
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="depth">
					<xsl:apply-templates select="$module/depth" mode="measurementUnit"/>
				</xsl:variable>
				<xsl:variable name="width">
					<xsl:apply-templates select="$module/width" mode="measurementUnit"/>
				</xsl:variable>
				<xsl:if test="$depth &lt; $minDepth or $depth &gt; $maxDepth or $width &lt; $minWidth or $width &gt; $maxWidth">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="$error" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="packagingMaterial" mode="packagingInformationModule">
		<xsl:param name="targetMarket"/>
		<xsl:apply-templates select=".//packagingRawMaterialInformation" mode="packagingInformationModule"/>
		
		<!--Rule 466: If packagingMaterialCompositionQuantity is not empty then value must be greater than 0.-->
		<xsl:if test="string(packagingMaterialCompositionQuantity) != '' and packagingMaterialCompositionQuantity &lt;= 0">
			<xsl:apply-templates select="packagingMaterialCompositionQuantity" mode="error">
				<xsl:with-param name="id" select="466"/>
			</xsl:apply-templates>
		</xsl:if>

		<!--Rule 1025: If targetMarketCountryCode equals <Geographic> and packagingMaterial/packagingMaterialTypeCode is used then packagingMaterial/packagingMaterialCompositionQuantity SHALL be used.-->
		<xsl:if test="contains('752, 203, 246, 703', $targetMarket)">
			<xsl:if test="string(packagingMaterialTypeCode) != '' and string(packagingMaterialCompositionQuantity) =''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1025" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<!--Rule 1057: If packagingMaterial/packagingMaterialTypeCode does not equal ('COMPOSITE', 'METAL_COMPOSITE', 'LAMINATED_CARTON', 'PAPER_PAPERBOARD' or 'OTHER') then CompositeMaterialDetail class SHALL NOT be used..-->
		<xsl:choose>
			<xsl:when test="packagingMaterialTypeCode = 'COMPOSITE'"/>
			<xsl:when test="packagingMaterialTypeCode = 'METAL_COMPOSITE'"/>
			<xsl:when test="packagingMaterialTypeCode = 'LAMINATED_CARTON'"/>
			<xsl:when test="packagingMaterialTypeCode = 'PAPER_PAPERBOARD'"/>
			<xsl:when test="packagingMaterialTypeCode = 'OTHER'"/>
			<xsl:otherwise>
				<xsl:if test="string(compositeMaterialDetail) != ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1057" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		<!--Rule 1714: If packagingLabellingCoveragePercentage is used then the value SHALL be greater than or equal to 0 and less than or equal to 100-->
		<xsl:if test="string(packagingLabellingCoveragePercentage) != ''">
			<xsl:if test="packagingLabellingCoveragePercentage &lt; 0 or packagingLabellingCoveragePercentage &gt; 100">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1714" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<xsl:if test="$targetMarket = '756' and $targetMarket = '040'">
			<!--Rule 2015: If targetMarketCountryCode equals <Geographic> and packagingMaterialCompositionQuantity is used then packagingMaterialCompositionQuantity/@measurementUnitCode SHALL equal ('CMK', 'DMK', 'GRM', 'KGM', 'MGM', 'MMK', 'MTK' or 'TNE').-->
			<xsl:if test="string(packagingMaterialCompositionQuantity) != ''">
				<xsl:choose>
					<xsl:when test="contains('CMK, DMK, GRM, KGM, MGM,MMK,MTK, TNE', packagingMaterialCompositionQuantity/@measurementUnitCode)"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="2015" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>

			<!--Rule 2039: If targetMarketCountryCode equals <Geographic> and packagingMaterial/packagingRawMaterialInformation/packagingRawMaterialContentPercentage is used and packagingMaterial/packagingRawMaterialInformation/packagingRawMaterialCode equals 'RECYCLED' then packagingMaterial/packagingMaterialCompositionQuantity SHALL be used.-->
			<xsl:if test="string(packagingMaterialCompositionQuantity) = ''">
			<xsl:for-each select="packagingRawMaterialInformation">
				<xsl:if test="string(packagingRawMaterialContentPercentage) != '' and packagingRawMaterialCode = 'RECYCLED'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="2039" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:for-each>
			</xsl:if>
			
		</xsl:if>

		
	</xsl:template>

	<xsl:template match="packagingRawMaterialInformation" mode="packagingInformationModule">
		
		<xsl:if test="string(packagingRawMaterialContentPercentage) != ''">

			<!--Rule 1713: If packagingRawMaterialContentPercentage is used then the value SHALL be greater than or equal to 0 and less than or equal to 100-->
			<xsl:if test="packagingRawMaterialContentPercentage &lt; 0 or packagingRawMaterialContentPercentage &gt; 100">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1713" />
				</xsl:apply-templates>
			</xsl:if>

			<!--Rule 1808: If packagingRawMaterialContentPercentage is used then packagingRawMaterialCode SHALL be used. -->
			<xsl:if test="string(packagingRawMaterialCode)  = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1808" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

	
		
		
	</xsl:template>

	<xsl:template match="packageDeposit" mode="packagingInformationModule">
		<!--Rule 632: If depositValueEffectiveDateTime is not empty then returnablePackageDepositIdentification or returnablePackageDepositAmount must not be empty.-->
		<xsl:if test="depositValueEffectiveDateTime != ''">
			<xsl:if test="returnablePackageDepositAmount = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="632" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="returnableAsset" mode="packagingInformationModule">
		<xsl:param name="targetMarket"/>

		<xsl:apply-templates select="returnableAssetOwnerId" mode="gln"/>
		
		<!--Rule 634: If targetMarketCountryCode is equal to  ('040' (Austria) or '276' (Germany)) and isReturnableAssetEmpty = 'true' then returnableAssetCapacityContent shall not be empty.-->
		<xsl:if test="$targetMarket = '040' or $targetMarket = '276'">
			<xsl:if test="isReturnableAssetEmpty = 'true'">
				<xsl:if test="returnableAssetCapacityContent  = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="634" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>
		<!--Rule 1409: If returnableAssetsContainedQuantity is used, it shall only have a measurementUnitCode of Unit Of Measure Classification 'Count'.-->
		<xsl:for-each select="returnableAssetsContainedQuantity">
			<xsl:variable name="type">
				<xsl:apply-templates select="." mode="measurementUnitType"/>			 
			</xsl:variable>
			<xsl:if test="$type != 'Piece'">
				<xsl:apply-templates select="gs1:AddEventData('unit', @measurementUnitCode)"/>
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1409" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
		<!--Rule 1446: If (returnablePackageDepositRegion/targetMarketCountryCode or returnableAssetsContainedQuantity) is used then returnablePackageDepositIdentification shall be used.-->
		<xsl:if test="returnableAssetsContainedQuantity != '' or returnableAssetPackageDeposit/returnablePackageDepositRegion/targetMarketCountryCode !=''">
			<xsl:if test="returnableAssetPackageDeposit/returnablePackageDepositIdentification = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1446" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<!--Rule 1024: GRAI must have a valid check digit.-->
		<xsl:if test="grai != '' and gs1:InvalidGTIN(grai, string-length(grai))">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1024" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template name="r507">
		<xsl:param name="items"/>
		<xsl:param name="index" select="1"/>
		<xsl:param name="count" select="count(msxsl:node-set($items))"/>
		<xsl:param name="weight" select="0"/>
		<xsl:choose>
			<xsl:when test="$index &lt;= $count">
				<xsl:variable name="value" select="msxsl:node-set($items)[$index]"/>
				<xsl:variable name="itemWeight">
					<xsl:choose>
						<xsl:when test="$value = number($value)">
							<xsl:variable name="weightValue">
								<xsl:apply-templates select="$value" mode="measurementUnit"/>
							</xsl:variable>
							<xsl:value-of select="$weightValue"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="0"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:call-template name="r507">
					<xsl:with-param name="items" select="$items"/>
					<xsl:with-param name="index" select="$index + 1"/>
					<xsl:with-param name="count" select="$count"/>
					<xsl:with-param name="weight" select="$weight + $itemWeight"/>
				</xsl:call-template>

			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$weight"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
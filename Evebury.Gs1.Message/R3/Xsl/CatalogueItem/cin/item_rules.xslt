<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:include href="component_rules.xslt"/>

	<xsl:template match="tradeItem" mode="item_rules">
		<xsl:param name="targetMarket"/>
		<xsl:param name="isEU"/>

		<xsl:apply-templates select="." mode="gtin"/>
		<xsl:apply-templates select="referencedTradeItem" mode="gtin"/>
		<xsl:apply-templates select="nextLowerLevelTradeItemInformation/childTradeItem" mode="gtin"/>

		<xsl:apply-templates select="brandOwner" mode="gln"/>
		<xsl:apply-templates select="informationProviderOfTradeItem" mode="gln"/>
		<xsl:apply-templates select="manufacturerOfTradeItem" mode="gln"/>
		<xsl:apply-templates select="partyInRole" mode="gln"/>
		<xsl:apply-templates select="tradeItemContactInformation" mode="gln"/>

		<xsl:apply-templates select="brandOwner" mode="languageSpecificPartyName"/>
		<xsl:apply-templates select="informationProviderOfTradeItem" mode="languageSpecificPartyName"/>
		<xsl:apply-templates select="manufacturerOfTradeItem" mode="languageSpecificPartyName"/>
		<xsl:apply-templates select="partyInRole" mode="languageSpecificPartyName"/>

		<xsl:variable name="brick" select="string(gDSNTradeItemClassification/gpcCategoryCode)" />
		<xsl:variable name="specialItemCode" select="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:marketing_information:xsd:3' and local-name()='marketingInformationModule']/marketingInformation/specialItemCode)"/>

		<xsl:apply-templates select="tradeItemInformation/extension/*" mode="module">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
			<xsl:with-param name="isEU" select="$isEU"/>
			<xsl:with-param name="tradeItem" select="."/>
			<xsl:with-param name="brick" select="$brick"/>
			<xsl:with-param name="specialItemCode" select="$specialItemCode"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="tradeItemInformation/tradeItemComponents" mode="components">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
			<xsl:with-param name="isEU" select="$isEU"/>
			<xsl:with-param name="tradeItem" select="."/>
			<xsl:with-param name="brick" select="$brick"/>
			<xsl:with-param name="specialItemCode" select="$specialItemCode"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="." mode="item_market_rules">
			<xsl:with-param name="isEU" select="$isEU"/>
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
			<xsl:with-param name="brick" select="$brick"/>
			<xsl:with-param name="specialItemCode" select="$specialItemCode"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="." mode="r382"/>
		<xsl:apply-templates select="." mode="r383"/>
		<xsl:apply-templates select="." mode="r398">
			<xsl:with-param name="brick" select="$brick"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="." mode="r454"/>
		<xsl:apply-templates select="." mode="r472"/>
		<xsl:apply-templates select="." mode="r474"/>
		<xsl:apply-templates select="." mode="r475">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="." mode="r504"/>
		<xsl:apply-templates select="." mode="r510"/>
		<xsl:apply-templates select="." mode="r572"/>
		<xsl:apply-templates select="." mode="r594">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="." mode="r617"/>
		<xsl:apply-templates select="." mode="r635"/>
		<xsl:apply-templates select="." mode="r636"/>
		<xsl:apply-templates select="." mode="r1000"/>
		<xsl:apply-templates select="." mode="r1001"/>
		<xsl:apply-templates select="." mode="r1004"/>
		<xsl:apply-templates select="." mode="r1008">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="." mode="r1010"/>
		<xsl:apply-templates select="." mode="r1012"/>
		<xsl:apply-templates select="." mode="r1018"/>
		<xsl:apply-templates select="." mode="r1038"/>
		<xsl:apply-templates select="." mode="r1039"/>
		<xsl:apply-templates select="." mode="r1045"/>
		<xsl:apply-templates select="." mode="r1049"/>
		<xsl:apply-templates select="." mode="r1061"/>
		<xsl:apply-templates select="." mode="r1078"/>
		<xsl:apply-templates select="." mode="r1079"/>
		<xsl:apply-templates select="." mode="r1080"/>
		<xsl:apply-templates select="." mode="r1089"/>
		<xsl:apply-templates select="." mode="r1167"/>
		<xsl:apply-templates select="." mode="r1168"/>
		<xsl:apply-templates select="." mode="r1176"/>
		<xsl:apply-templates select="." mode="r1283"/>
		<xsl:apply-templates select="." mode="r1288">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="." mode="r1291"/>
		<xsl:apply-templates select="." mode="r1299">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="." mode="r1338"/>
		<xsl:apply-templates select="." mode="r1459"/>
		<xsl:apply-templates select="." mode="r1697">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="." mode="r1722"/>
		<xsl:apply-templates select="." mode="r1793"/>
		<xsl:apply-templates select="." mode="r1835"/>
		<xsl:apply-templates select="." mode="r1862"/>
		<xsl:apply-templates select="." mode="r1896"/>

		<xsl:choose>
			<xsl:when test="tradeItemUnitDescriptorCode = 'BASE_UNIT_OR_EACH'">
				<xsl:apply-templates select="." mode="r96"/>
			</xsl:when>
			<xsl:when test="tradeItemUnitDescriptorCode = 'TRANSPORT_LOAD'">
				<xsl:apply-templates select="." mode="r554"/>
			</xsl:when>
			<xsl:when test="tradeItemUnitDescriptorCode = 'PALLET'">
				<xsl:apply-templates select="." mode="r555"/>
				<xsl:apply-templates select="." mode="r557"/>
			</xsl:when>
			<xsl:when test="tradeItemUnitDescriptorCode = 'CASE'">
				<xsl:apply-templates select="." mode="r558"/>
				<xsl:apply-templates select="." mode="r559"/>
			</xsl:when>
			<xsl:when test="tradeItemUnitDescriptorCode = 'PACK_OR_INNERPACK'">
				<xsl:apply-templates select="." mode="r560"/>
				<xsl:apply-templates select="." mode="r561"/>
			</xsl:when>
			<xsl:when test="tradeItemUnitDescriptorCode = 'MIXED_MODULE'">
				<xsl:apply-templates select="." mode="r1277"/>
				<xsl:apply-templates select="." mode="r1278"/>
			</xsl:when>
			<xsl:when test="tradeItemUnitDescriptorCode = 'DISPLAY_SHIPPER'">
				<xsl:apply-templates select="." mode="r1279"/>
				<xsl:apply-templates select="." mode="r1280"/>
			</xsl:when>
		</xsl:choose>




		<xsl:if test="$specialItemCode != 'DYNAMIC_ASSORTMENT'">

			<xsl:apply-templates select="." mode="r202"/>

		</xsl:if>

		<xsl:if test="isTradeItemADespatchUnit = 'true'">

			<xsl:apply-templates select="." mode="r204"/>

		</xsl:if>

	</xsl:template>

	<xsl:template match="tradeItem" mode="item_market_rules">
		<xsl:param name="targetMarket"/>
		<xsl:param name="isEU"/>
		<xsl:param name="brick"/>
		<xsl:param name="specialItemCode"/>

		<!-- EU -->
		<xsl:if test="$isEU">
			<xsl:apply-templates select="." mode="r1613"/>
			<xsl:apply-templates select="." mode="r1855"/>
			<xsl:if test="isTradeItemABaseUnit = 'true'">

				<xsl:apply-templates select="." mode="r325">
					<xsl:with-param name="brick" select="$brick"/>
				</xsl:apply-templates>

			</xsl:if>

		</xsl:if>


		<!-- Belgium 056, Luxembourg 442, Netherlands 528  = (Benelux) -->
		<xsl:if test="$targetMarket = '056' or $targetMarket = '442' or $targetMarket = '528'">
			<xsl:apply-templates select="." mode="r469"/>

			<xsl:if test="isTradeItemAConsumerUnit = 'true'">

				<xsl:apply-templates select="." mode="r575">
					<xsl:with-param name="brick" select="$brick"/>
				</xsl:apply-templates>

				<xsl:apply-templates select="." mode="r1662">
					<xsl:with-param name="brick" select="$brick"/>
				</xsl:apply-templates>

				<xsl:apply-templates select="." mode="r1692"/>

			</xsl:if>

		</xsl:if>

		<!-- Australia 036, Czechia 203, Denmark 208, Finland 246, France 250, Hungary 348, Iceland 352, Italy 380, New Zealand 554, Slovakia 703, Sweden 752, United States of America 840, Canada 124 -->
		<xsl:if test="contains('036, 203, 208, 246, 250, 348, 352, 380, 554, 703, 752, 840, 124', $targetMarket)">

			<xsl:if test="isTradeItemAConsumerUnit = 'true'">

				<xsl:apply-templates select="." mode="r524"/>

			</xsl:if>

		</xsl:if>

		<xsl:choose>
			<!-- Italy 380 -->
			<xsl:when test="targetMarket = '380'">
				<xsl:apply-templates select="." mode="r590"/>
				<xsl:if test="isTradeItemAConsumerUnit = 'true'">

					<xsl:apply-templates select="." mode="r1662">
						<xsl:with-param name="brick" select="$brick"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="." mode="r1922"/>

				</xsl:if>

			</xsl:when>
			<!-- Slovakia 703 -->
			<xsl:when test="targetMarket = '703'">
				<xsl:apply-templates select="." mode="r1917"/>
				<xsl:if test="isTradeItemAConsumerUnit = 'true'">

					<xsl:apply-templates select="." mode="r1744">
						<xsl:with-param name="brick" select="$brick"/>
					</xsl:apply-templates>

				</xsl:if>

				<xsl:if test="isTradeItemABaseUnit = 'true'">
					<xsl:if test="isTradeItemAConsumerUnit = 'false'">
						<xsl:apply-templates select="." mode="r1918"/>
					</xsl:if>
				</xsl:if>

			</xsl:when>
			<!-- Czechia 203 -->
			<xsl:when test="targetMarket = '203'">
				<xsl:apply-templates select="." mode="r1895"/>
				<xsl:apply-templates select="." mode="r1917"/>

				<xsl:if test="isTradeItemAConsumerUnit = 'true'">

					<xsl:apply-templates select="." mode="r1662">
						<xsl:with-param name="brick" select="$brick"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="." mode="r1744">
						<xsl:with-param name="brick" select="$brick"/>
					</xsl:apply-templates>

				</xsl:if>
				<xsl:if test="isTradeItemABaseUnit = 'true'">
					<xsl:if test="isTradeItemAConsumerUnit = 'false'">
						<xsl:apply-templates select="." mode="r1918"/>
					</xsl:if>
				</xsl:if>

			</xsl:when>
			<!-- Ireland 372 -->
			<xsl:when test="targetMarket = '372'">
				<xsl:if test="isTradeItemABaseUnit = 'true'">
					<xsl:apply-templates select="." mode="r631">
						<xsl:with-param name="brick" select="$brick"/>
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<!-- United States of America 840 -->
			<xsl:when test="targetMarket = '840'">
				<xsl:if test="isTradeItemAConsumerUnit = 'true'">
					<xsl:apply-templates select="." mode="r642"/>
				</xsl:if>
			</xsl:when>
			<!-- Finland 246 -->
			<xsl:when test="targetMarket = '246'">
				<xsl:apply-templates select="." mode="r590"/>
				<xsl:choose>
					<xsl:when test="tradeItemUnitDescriptorCode = 'BASE_UNIT_OR_EACH'">
						<xsl:apply-templates select="." mode="r1850"/>

					</xsl:when>
				</xsl:choose>

				<xsl:if test="isTradeItemAConsumerUnit = 'true'">

					<xsl:apply-templates select="." mode="r575">
						<xsl:with-param name="brick" select="$brick"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="." mode="r1744">
						<xsl:with-param name="brick" select="$brick"/>
					</xsl:apply-templates>

				</xsl:if>

			</xsl:when>
			<!-- Sweden 752 -->
			<xsl:when test="targetMarket = '752'">
				<xsl:apply-templates select="." mode="r517">
					<xsl:with-param name="brick" select="$brick"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="." mode="r1419"/>

				<xsl:if test="isTradeItemAConsumerUnit = 'true'">

					<xsl:apply-templates select="." mode="r531"/>
					<xsl:apply-templates select="." mode="r1804">
						<xsl:with-param name="brick" select="$brick"/>
					</xsl:apply-templates>

				</xsl:if>

				<xsl:if test="isTradeItemADespatchUnit = 'true'">

					<xsl:apply-templates select="." mode="r565"/>

				</xsl:if>
			</xsl:when>
			<!-- Australia 036 -->
			<xsl:when test="targetMarket = '036'">
				<xsl:apply-templates select="." mode="r528"/>
			</xsl:when>
			<!-- Netherlands 528 -->
			<xsl:when test="targetMarket = '528'">
				<xsl:apply-templates select="." mode="r533">
					<xsl:with-param name="brick" select="$brick"/>
				</xsl:apply-templates>
			</xsl:when>
			<!-- France 250 -->
			<xsl:when test="targetMarket = '250'">
				<xsl:apply-templates select="." mode="r590"/>
				<xsl:apply-templates select="." mode="r603"/>
				<xsl:apply-templates select="." mode="r1161"/>
				<xsl:apply-templates select="." mode="r1695"/>
				<xsl:apply-templates select="." mode="r1858">
					<xsl:with-param name="brick" select="$brick"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="." mode="r1867"/>
				<xsl:apply-templates select="." mode="r1901"/>
				<xsl:apply-templates select="." mode="r1963"/>
				<xsl:apply-templates select="." mode="r2069"/>

				<xsl:choose>
					<xsl:when test="tradeItemUnitDescriptorCode = 'BASE_UNIT_OR_EACH'">
						<xsl:apply-templates select="." mode="r598"/>

						<xsl:if test="isTradeItemABaseUnit  = 'true'">

							<xsl:apply-templates select="." mode="r1684">
								<xsl:with-param name="brick" select="$brick"/>
							</xsl:apply-templates>

						</xsl:if>

					</xsl:when>
					<xsl:when test="tradeItemUnitDescriptorCode = 'PACK_OR_INNER_PACK'">

						<xsl:if test="isTradeItemAConsumerUnit  = 'true'">

							<xsl:apply-templates select="." mode="r1875"/>
							<xsl:apply-templates select="." mode="r1883"/>

						</xsl:if>

					</xsl:when>
					<xsl:when test="tradeItemUnitDescriptorCode = 'DISPLAY_SHIPPER'">

						<xsl:apply-templates select="." mode="r1877"/>

					</xsl:when>
					<xsl:when test="tradeItemUnitDescriptorCode = 'MIXED_MODULE'">

						<xsl:apply-templates select="." mode="r1877"/>

					</xsl:when>
				</xsl:choose>

				<xsl:if test="isTradeItemAConsumerUnit  = 'true'">

					<xsl:apply-templates select="." mode="r618">
						<xsl:with-param name="brick" select="$brick"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="." mode="r1160"/>
					<xsl:apply-templates select="." mode="r1892">
						<xsl:with-param name="brick" select="$brick"/>
					</xsl:apply-templates>

				</xsl:if>

				<xsl:if test="isTradeItemABaseUnit  = 'true'">

					<xsl:apply-templates select="." mode="r1639">
						<xsl:with-param name="brick" select="$brick"/>
					</xsl:apply-templates>

				</xsl:if>

				<xsl:if test="isTradeItemAVariableUnit = 'false'">
					<xsl:apply-templates select="." mode="r1857"/>

				</xsl:if>

				<xsl:if test="isTradeItemADespatchUnit = 'true'">
					<xsl:apply-templates select="." mode="r1861"/>

				</xsl:if>
			</xsl:when>
			<!-- Switzerland 756 -->
			<xsl:when test="targetMarket = '756'">
				<xsl:apply-templates select="." mode="r1937"/>
				<xsl:apply-templates select="." mode="r1963"/>
				<xsl:apply-templates select="." mode="r1971"/>
				<xsl:apply-templates select="." mode="r2004">
					<xsl:with-param name="brick" select="$brick"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="." mode="r102010">
					<xsl:with-param name="brick" select="$brick"/>
				</xsl:apply-templates>
			</xsl:when>
			<!-- Austria 040 -->
			<xsl:when test="targetMarket = '040'">
				<xsl:apply-templates select="." mode="r1971"/>
				<xsl:apply-templates select="." mode="r2004">
					<xsl:with-param name="brick" select="$brick"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>




	</xsl:template>


	<xsl:template match="*" mode="r96">
		<!--Rule 96: If tradeItemUnitDescriptor is equal to 'BASE_UNIT_OR_EACH' then ChildTradeItem/gtin must be empty.-->
		<xsl:if test="nextLowerLevelTradeItemInformation/childTradeItem[string(gtin) != '']">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="96"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r202">
		<!--Rule 202: If specialItemCode does not equal 'DYNAMIC_ASSORTMENT' then the sum of all quantityofNextLowerLevelTradeItem shall equal totalQuantityOfNextLowerLevelTradeItem.-->
		<xsl:if test="nextLowerLevelTradeItemInformation/totalQuantityOfNextLowerLevelTradeItem != sum(nextLowerLevelTradeItemInformation/childTradeItem/quantityOfNextLowerLevelTradeItem)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="202"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r204">
		<!--Rule 204: If isTradeItemADespatchUnit equals 'true' then tradeItemWeight/grossWeight SHALL be greater than 0.-->
		<xsl:variable name="grossWeightValue" select="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_measurements:xsd:3' and local-name()='tradeItemMeasurementsModule']/tradeItemMeasurements/tradeItemWeight/grossWeight" />
		<xsl:variable name="grossWeight">
			<xsl:choose>
				<xsl:when test="$grossWeightValue != number($grossWeightValue)">
					<xsl:value-of select="0"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$grossWeightValue"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$grossWeight &lt;= 0">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="204"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r325">
		<xsl:param name="brick"/>
		<!--Rule 325: If targetMarketCountryCode equals <Geographic> and (gpcCategoryCode is in GPC Class '50202200' and gpcCategoryCode does not equal ('10000142', '10000143', '10008029', '10008030', '10008031', '10008032', '10008033', ' 10008034', '10008035', '10008042') and isTradeItemABaseUnit equals 'true' then percentageOfAlcoholByVolume SHALL be used.-->
		<xsl:if test="gs1:IsInClass($brick, '50202200')">
			<xsl:choose>
				<xsl:when test="contains('10000142, 10000143, 10008029, 10008030, 10008031, 10008032, 10008033, 10008034, 10008035, 10008042', $brick)"></xsl:when>
				<xsl:otherwise>
					<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:alcohol_information:xsd:3' and local-name()='alcoholInformationModule']/alcoholInformation/percentageOfAlcoholByVolume) = ''">
						<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="325"/>
						</xsl:apply-templates>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r382">
		<!--Rule 328: If ChildTradeItem/gtin is empty then attribute isTradeItemABaseUnit must be equal to 'true'.-->
		<xsl:if test="string(isTradeItemABaseUnit) != 'true' and not(nextLowerLevelTradeItemInformation/childTradeItem/gtin)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="382"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r383">
		<!--Rule 383: If ChildTradeItem/gtin is not empty then attribute isTradeItemABaseUnit must be equal to 'false'.-->
		<xsl:if test="string(isTradeItemABaseUnit) != 'false' and nextLowerLevelTradeItemInformation/childTradeItem[string(gtin) != '']">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="383"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r398">
		<xsl:param name="brick"/>
		<!--Rule 398: If gpcCategorycode is used, then its value shall be in the list of official GPC bricks as published by GS1 and currently adopted in production by GDSN.-->
		<xsl:if test="$brick != '' and gs1:InvalidBrick($brick)">
			<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="398" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r454">
		<!--Rule 454: ChildTradeItem/gtin must not equal TradeItem/gtin-->
		<xsl:variable name="gtin" select="string(gtin)" />
		<xsl:if test="nextLowerLevelTradeItemInformation/childTradeItem[gtin = $gtin]">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="454"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r469">
		<!--Rule 469: If targetMarketCountryCode equals <Geographic> then tradeItem/gtin SHALL NOT start with '002', '004' or '02'.-->
		<xsl:if test="starts-with(gtin, '002') or starts-with(gtin, '004') or starts-with(gtin, '02')">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="469"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r472">
		<!--Rule 472: If childTradeItem/gtin is used, then the corresponding tradeItem/gtin SHALL exist in the same CIN document. -->
		<xsl:variable name="tradeItem" select="."/>
		<xsl:for-each select="nextLowerLevelTradeItemInformation/childTradeItem[string(gtin) != '']">
			<xsl:variable name="gtin" select="string(gtin)"/>
			<xsl:choose>
				<xsl:when test="$tradeItem/../catalogueItemChildItemLink/catalogueItem/tradeItem/gtin = $gtin"/>
				<xsl:otherwise>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="472"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="*" mode="r474">
		<!--Rule 474: If dataCarrierTypeCode is equal to 'EAN_8' then the first six digits of the TradeItem/GTIN shall equal '000000'.-->
		<xsl:if test="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_data_carrier_and_identification:xsd:3' and local-name()='tradeItemDataCarrierAndIdentificationModule']/dataCarrier/dataCarrierTypeCode ='EAN_8'">
			<xsl:if test="not(starts-with(gtin, '000000'))">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="474"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r475">
		<xsl:param name="targetMarket"/>
		<!--Rule 475: targetMarketCountryCode and (targetMarketSubdivisionCode if not empty) must be consistent across item hierarchy.  Example: If parent item targetmarketCountryCode is equal to '840' then child item cannot have a targetMarketCountryCode equal to '340'.-->
		<xsl:if test="../catalogueItemChildItemLink/catalogueItem/tradeItem/targetMarket[targetMarketCountryCode != $targetMarket]">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="475"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r504">
		<!--Rule 504: There shall be at most 25 iterations of Class GDSNTradeItemClassificationAttribute per Class GDSNTradeItemClassification.-->
		<xsl:if test="count(gDSNTradeItemClassification/gDSNTradeItemClassificationAttribute) &gt; 25">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="504"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r510">

		<xsl:if test="string(isTradeItemNonphysical) != 'true'">

			<xsl:variable name="mod" select="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_measurements:xsd:3' and local-name()='tradeItemMeasurementsModule']/tradeItemMeasurements"/>

			<!--Rule 510: If isTradeItemNonPhysical equals 'false' or is not used then tradeItemMeasurements/depth SHALL be greater than 0.-->
			<xsl:if test="count($mod[depth &gt; 0]) != 1">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="510" />
				</xsl:apply-templates>
			</xsl:if>

			<!--Rule 511: If isTradeItemNonPhysical equals 'false' or is not used then tradeItemMeasurements/height SHALL be greater than 0.-->
			<xsl:if test="count($mod[height &gt; 0]) != 1">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="511" />
				</xsl:apply-templates>
			</xsl:if>

			<!--Rule 512: If isTradeItemNonPhysical equals 'false' or is not used then tradeItemMeasurements/width SHALL be greater than 0.-->
			<xsl:if test="count($mod[width &gt; 0]) != 1">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="512" />
				</xsl:apply-templates>
			</xsl:if>

			<!--Rule 549: If isTradeItemNonphysical equals 'false' or is not used then tradeItemWeight/grossWeight SHALL be greater than 0.-->
			<xsl:if test="count($mod[tradeItemWeight/grossWeight &gt; 0]) != 1">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="549" />
				</xsl:apply-templates>
			</xsl:if>

		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r517">
		<xsl:param name="brick" />
		<!--Rule 517: If targetMarketCountryCode not equal to '752' (Sweden) and (Audio Visual Media Product Description Module or Publication Title Rating Module or Audio Visual Media Content Information Module) are used and gpcCategoryCode is equal to '10001137' then audioVisualMediaProductTitle, genreTypeCodeReference, titleRatingCodeReference/Code, titleRatingCodeReference/codeListAgencyCode and gameFormatCode shall be used.-->
		<xsl:if test="$brick = '10001137'">
			<xsl:variable name="mod1" select="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:audio_visual_media_product_description_information:xsd:3' and local-name()='audioVisualMediaProductDescriptionInformationModule']"/>
			<xsl:variable name="mod2" select="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:audio_visual_media_content_information:xsd:3' and local-name()='audioVisualMediaContentInformationModule']"/>
			<xsl:variable name="mod3" select="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:publication_title_rating:xsd:3' and local-name()='publicationTitleRatingModule']"/>
			<xsl:if test="$mod1 or $mod2 or $mod3">

				<xsl:variable name="audioVisualMediaProductTitle" select="$mod1/audioVisualMediaProductDescription/audioVisualMediaProductTitle[text() != '']"/>
				<xsl:variable name="genreTypeCodeReference" select="$mod1/audioVisualMediaProductDescription/genreTypeCodeReference[text() != '']"/>
				<xsl:variable name="gameFormatCode" select="$mod2/audioVisualMediaContentInformation/gameFormatCode[text() != '']"/>
				<xsl:variable name="titleRatingCodeReference" select="$mod3/publicationTitleRating/titleRatingCodeReference[text() != '' and @codeListAgencyCode != '']"/>
				<xsl:choose>
					<xsl:when test="$audioVisualMediaProductTitle and $genreTypeCodeReference and $gameFormatCode and $titleRatingCodeReference"/>
					<xsl:otherwise>
						<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="517" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r524">
		<!--Rule 524: If targetMarketCountryCode equals <Geographic> and isTradeItemAConsumerUnit equals 'true' then netContent SHALL be used..-->
		<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_measurements:xsd:3' and local-name()='tradeItemMeasurementsModule']/tradeItemMeasurements/netContent) = ''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="524" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r528">
		<!--Rule 528: If targetMarketCountryCode is equal to '036' (Australia) and dutyFeeTaxTypeCode is equal to 'WET' then percentageOfAlcoholByVolume must not be empty.-->
		<xsl:if test="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:duty_fee_tax_information:xsd:3' and local-name()='dutyFeeTaxInformationModule']/dutyFeeTaxInformation/dutyFeeTaxTypeCode = 'WET'">
			<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:alcohol_information:xsd:3' and local-name()='alcoholInformationModule']/alcoholInformation/percentageOfAlcoholByVolume) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="528" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r531">
		<!--Rule 531: If targetMarketCountryCode equals ('752' (Sweden)) and isTradeItemAConsumerUnit is equal to 'true' then functionalName must not contain a value from brandName or descriptiveSizeDimension.-->
		<xsl:variable name="mod" select="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_description:xsd:3' and local-name()='tradeItemDescriptionModule']/tradeItemDescriptionInformation"/>
		<xsl:variable name="functionalName" select="string($mod/functionalName)"/>
		<xsl:if test="$functionalName != ''">
			<xsl:variable name="brand" select="string($mod/brandNameInformation/brandName)"/>
			<xsl:variable name="size" select="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_size:xsd:3' and local-name()='tradeItemSizeModule']/nonPackagedSizeDimension/descriptiveSizeDimension)"/>
			<xsl:choose>
				<xsl:when test="$brand != '' and contains($functionalName, $brand)">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="531" />
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="$size != '' and contains($functionalName, $size)">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="531" />
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r533">
		<xsl:param name="brick"/>
		<!--Rule 533: If targetMarketCountryCode equals '528' (Netherlands) and gpcCategoryCode does not equal class then dutyFeeTaxCategoryCode shall be used.-->
		<xsl:choose>
			<xsl:when test ="contains('10000458,10000570,10000686,10000915,10000456,10000457,10000681,10000912,10000922,10000448,10000449,10000450,10000451,10000684,10000908,10000909,10000910,10000474,10000488,10000489,10000685,10000907,10000459,10000682,10000690,10000487,10000525,10000526,10000527,10000528,10000529,10000637,10000638,10000639,10000687,10000688,10000689,10000911,10000500,10000504,10000683,10000846,10000847,10000848,10000849,10000850,10000851,10000852,10000923,10000853,10000854,10000855,10000856,10000857,10000858,10000859,10000860,10000861,10000862,10000914,10000863,10000864,10000865,10000866,10000867,10000868,10000869,10000870,10000871,10000872,10000873,10000874,10000919,10000875,10000876,10000877,10000878,10000879,10000880,10000881,10000882,10000883,10000884,10000916,10000920,10000885,10000886,10000887,10000888,10000889,10000890,10000891,10000892,10000893,10000903,10000904,10000905,10000906,10000894,10000895,10000896,10000897,10000898,10000899,10000900,10000901,10000902,10000921,10002423,10000460,10000461,10000462,10000674,10000838,10000463,10000464,10000675,10000455,10000843,10000452,10000453,10000454,10000648,10000844,10000647,10000673,10005844,10006412,10005845,10000514', $brick)"/>
			<xsl:otherwise>
				<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:duty_fee_tax_information:xsd:3' and local-name()='dutyFeeTaxInformationModule']/dutyFeeTaxInformation/dutyFeeTax/dutyFeeTaxCategoryCode) = ''">
					<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="533" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="r554">
		<!--Rule 554: If tradeItemUnitDescriptorCode is equal to 'TRANSPORT_LOAD'  and parent item exists then parent item tradeItemUnitDescriptorCode must equal 'TRANSPORT_LOAD'.-->
		<xsl:variable name="parent" select="../../../tradeItem"/>
		<xsl:if test="$parent">
			<xsl:choose>
				<xsl:when test="string($parent/tradeItemUnitDescriptorCode) != 'TRANSPORT_LOAD'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="554" />
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r555">
		<!--Rule 555: If tradeItemUnitDescriptorCode is equal to 'PALLET' and parent item exists then parent item tradeItemUnitDescriptorCode must equal 'TRANSPORT_LOAD' or 'PALLET'.-->
		<xsl:variable name="parent" select="../../../tradeItem"/>
		<xsl:if test="$parent">
			<xsl:choose>
				<xsl:when test="$parent/tradeItemUnitDescriptorCode = 'TRANSPORT_LOAD'"/>
				<xsl:when test="$parent/tradeItemUnitDescriptorCode = 'PALLET'"/>
				<xsl:otherwise>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="555" />
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r557">
		<!--Rule 557: If tradeItemUnitDescriptorCode is equal to 'PALLET' then child item tradeItemUnitDescriptorCode must not equal 'TRANSPORT_LOAD' .-->
		<xsl:for-each select="catalogueItemChildItemLink/catalogueItem/tradeItem">
			<xsl:choose>
				<xsl:when test="tradeItemUnitDescriptorCode = 'TRANSPORT_LOAD'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="557" />
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="*" mode="r558">
		<!--Rule 558: If tradeItemUnitDescriptorCode is equal to 'CASE' then parent item tradeItemUnitDescriptorCode must not equal 'BASE_UNIT_OR_EACH' or 'PACK_OR_INNERPACK'.-->
		<xsl:variable name="parent" select="../../../tradeItem"/>
		<xsl:if test="$parent">
			<xsl:choose>
				<xsl:when test="$parent/tradeItemUnitDescriptorCode = 'BASE_UNIT_OR_EACH'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="558" />
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="$parent/tradeItemUnitDescriptorCode = 'PACK_OR_INNERPACK'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="558" />
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r559">
		<!--Rule 559: If tradeItemUnitDescriptorCode is equal to 'CASE' then child item tradeItemUnitDescriptorCode must not equal 'TRANSPORT_LOAD', 'MIXED_MODULE' or ' PALLET'.-->
		<xsl:for-each select="catalogueItemChildItemLink/catalogueItem/tradeItem">
			<xsl:choose>
				<xsl:when test="tradeItemUnitDescriptorCode = 'TRANSPORT_LOAD'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="559" />
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="tradeItemUnitDescriptorCode = 'MIXED_MODULE'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="559" />
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="tradeItemUnitDescriptorCode = 'PALLET'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="559" />
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="*" mode="r560">
		<!--Rule 560: If tradeItemUnitDescriptorCode is equal to 'PACK_OR_INNERPACK' then parent item tradeItemUnitDescriptorCode must not equal 'BASE_UNIT_OR_EACH'.-->
		<xsl:variable name="parent" select="../../../tradeItem"/>
		<xsl:if test="$parent">
			<xsl:choose>
				<xsl:when test="$parent/tradeItemUnitDescriptorCode = 'BASE_UNIT_OR_EACH'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="560" />
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r561">
		<!--Rule 561: If tradeItemUnitDescriptorCode is equal to 'PACK_OR_INNERPACK' then child item tradeItemUnitDescriptorCode must not equal 'TRANSPORT_LOAD', 'PALLET', 'MIXED_MODULE', 'DISPLAY_SHIPPER' or 'CASE'.-->
		<xsl:for-each select="catalogueItemChildItemLink/catalogueItem/tradeItem">
			<xsl:choose>
				<xsl:when test="tradeItemUnitDescriptorCode = 'TRANSPORT_LOAD'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="561" />
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="tradeItemUnitDescriptorCode = 'MIXED_MODULE'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="561" />
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="tradeItemUnitDescriptorCode = 'PALLET'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="561" />
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="tradeItemUnitDescriptorCode = 'DISPLAY_SHIPPER'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="561" />
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="tradeItemUnitDescriptorCode = 'CASE'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="561" />
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="*" mode="r565">
		<!--Rule 565: If targetMarketCountryCode is equal to '752' (Sweden) and isTradeItemADespatchUnit is equal to 'true' then stackingFactor must not be empty.-->
		<xsl:choose>
			<xsl:when test="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_handling:xsd:3' and local-name()='tradeItemHandlingModule']/tradeItemHandlingInformation/tradeItemStacking/stackingFactor[text() != '']"/>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="565" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="r572">
		<!--Rule 572: lastChangeDateTime must not be greater than current date.-->
		<xsl:if test="gs1:InvalidDateTimeSpan(tradeItemSynchronisationDates/lastChangeDateTime, gs1:TimeStamp())">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="572"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r575">
		<xsl:param name="brick" />
		<!--Rule 575: If targetMarketCountryCode equals <Geographic> and isTradeItemAConsumerUnit equals 'true' and gpcCategoryCode is not in GPC Segment '51000000' then tradeItem/gtin SHALL not begin with values '1' to '9'.-->
		<xsl:if test="not(gs1:IsInSegment($brick, '51000000'))">
			<xsl:choose>
				<xsl:when test="string(gtin) = ''"/>
				<xsl:when test="starts-with(gtin, '0')"/>
				<xsl:otherwise>
					<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="575" />
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r590">
		<xsl:param name="targetMarket" />
		<!--Rule 590: If targetMarketCountryCode equals ('250' (France), '246' (Finland) or '380' (Italy)) then tradeItemDescription shall be used. -->
		<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_description:xsd:3' and local-name()='tradeItemDescriptionModule']/tradeItemDescriptionInformation/tradeItemDescription) = ''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="590" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r594">
		<xsl:param name="targetMarket" />
		<!--Rule 594: If targetMarketCountryCode does not equal ('036' (Australia) or '554' (New Zealand) or 752 (Sweden)) and tradeItemUnitDescriptor is equal to 'PALLET' or 'MIXED_MODULE' then platformTypeCode  shall not be empty-->
		<xsl:if test="$targetMarket != '036' and $targetMarket != '554' and $targetMarket != '752'">
			<xsl:if test="tradeItemUnitDescriptorCode = 'PALLET' or tradeItemUnitDescriptorCode ='MIXED_MODULE'">
				<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:packaging_information:xsd:3' and local-name()='packagingInformationModule']/packaging/platformTypeCode) = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="594" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r598">
		<!--Rule 598: If targetMarketCountryCode equals '250' (France) and tradeItemUnitDescriptorCode equals 'BASE_UNIT_OR_EACH' then placeOfProductActivity/countryOfOrigin shall not be empty.-->
		<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:place_of_item_activity:xsd:3' and local-name()='placeOfItemActivityModule']/placeOfProductActivity/countryOfOrigin/countryCode) = ''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="598" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r603">
		<xsl:param name="targetMarket" />
		<!--Rule 603: If targetMarketCountryCode equals '250' (France) then dutyFeeTaxAgencyCode, if used, shall equal  '65'.-->
		<xsl:variable name="code" select="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:duty_fee_tax_information:xsd:3' and local-name()='dutyFeeTaxInformationModule']/dutyFeeTaxInformation/dutyFeeTaxAgencyCode)"/>
		<xsl:if test="$code != '' and $code != '65'">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="603" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r617">
		<!--Rule 617: If childTradeItem/tradeItemIdentification is used then quantityOfNextLowerLevelTradeItem shall be greater than '0'.-->
		<xsl:for-each select="nextLowerLevelTradeItemInformation/childTradeItem">
			<xsl:if test="string(gtin) != ''">
				<xsl:if test="string(quantityOfNextLowerLevelTradeItem) = '' or quantityOfNextLowerLevelTradeItem &lt; 0">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="617" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="*" mode="r618">
		<xsl:param name="brick" />
		<!--Rule 618: If targetMarketCountryCode equals '250' (France)) and (gpcCategoryCode is in Class '50202200' and does not equal '10000142') and isTradeItemAConsumerUnit equals 'true' then at least one iteration of dutyFeeTaxTypeCode shall equal ('3001000002541', '3001000002244', '3001000002312' or '3001000002329').-->
		<xsl:if test="$brick != '10000142'">
			<xsl:if test="gs1:IsInClass($brick, '50202200')">
				<xsl:choose>
					<xsl:when test="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:duty_fee_tax_information:xsd:3' and local-name()='dutyFeeTaxInformationModule']/dutyFeeTaxInformation[dutyFeeTaxTypeCode = '3001000002541' or dutyFeeTaxTypeCode = '3001000002244' or dutyFeeTaxTypeCode = '3001000002312' or dutyFeeTaxTypeCode = '3001000002329'] "/>
					<xsl:otherwise>
						<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="618" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r631">
		<xsl:param name="brick" />
		<!--Rule 631: If targetMarketCountryCode equals '372' (Ireland) and if isTradeItemABaseUnit equals 'true' and ((gpcCategoryCode is in Class ('50202200' or '50211500') and does not equal ('10000142', '10000143', '10000303' or '10000584')) then at least one iteration of AdditionalTradeItemClassification shall have a value with additionalTradeItemClassificationSystemCode equal to '57'(REV).-->
		<xsl:choose>
			<xsl:when test="$brick = '10000142'"/>
			<xsl:when test="$brick = '10000143'"/>
			<xsl:when test="$brick = '10000303'"/>
			<xsl:when test="$brick = '10000584'"/>
			<xsl:otherwise>
				<xsl:if test="gs1:IsInClass($brick, '50202200') or gs1:IsInClass($brick, '50211500')">
					<xsl:choose>
						<xsl:when test="gDSNTradeItemClassification/additionalTradeItemClassification[additionalTradeItemClassificationSystemCode = '57']"/>
						<xsl:otherwise>
							<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="631" />
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="r635">
		<!--Rule 635: discontinuedDateTime shall not be older than effectiveDateTime minus six months.-->
		<xsl:if test="string(tradeItemSynchronisationDates/discontinuedDateTime) != '' and string(tradeItemSynchronisationDates/effectiveDateTime) != ''">
			<xsl:variable name="date" select="gs1:AddMonths(tradeItemSynchronisationDates/effectiveDateTime, -6)"/>
			<xsl:if test="gs1:InvalidDateTimeSpan($date, tradeItemSynchronisationDates/discontinuedDateTime)">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="635" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r636">
		<xsl:if test="referencedTradeItem">
			<xsl:variable name="gtin" select="string(gtin)"/>
			<xsl:if test="$gtin != ''">
				<xsl:for-each select="referencedTradeItem[gtin = $gtin]">
					<xsl:choose>
						<xsl:when test="referencedTradeItemTypeCode = 'REPLACED_BY'">
							<!--Rule 636: Replaced By Trade Item (referencedTradeItemTypeCode equals 'REPLACED_BY')  shall not equal TradeItem/ tradeItemIdentification.-->
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="636" />
							</xsl:apply-templates>
						</xsl:when>
						<xsl:when test="referencedTradeItemTypeCode = 'SUBSTITUTED_BY'">
							<!--Rule 637: Substituted By Trade Item (referencedTradeItemTypeCode equals 'SUBSTITUTED_BY') shall not equal TradeItem/tradeItemIdentification.-->
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="637" />
							</xsl:apply-templates>
						</xsl:when>
						<xsl:when test="referencedTradeItemTypeCode = 'EQUIVALENT'">
							<!--Rule 638: equivalentTradeItem (referencedTradeItemTypeCode equals 'EQUIVALENT') shall not equal TradeItem/tradeItemIdentification.-->
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="638" />
							</xsl:apply-templates>
						</xsl:when>
						<xsl:when test="referencedTradeItemTypeCode = 'DEPENDENT_PROPRIETARY'">
							<!--Rule 639: Dependent Proprietary Trade Item (referencedTradeItemTypeCode equals 'DEPENDENT_PROPRIETARY') shall not equal TradeItem/tradeItemIdentification.-->
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="639" />
							</xsl:apply-templates>
						</xsl:when>
						<xsl:when test="referencedTradeItemTypeCode = 'ITEM_VARIANT_MASTER'">
							<!--Rule 640: Item Variant Master (referencedTradeItemTypeCode equals 'ITEM_VARIANT_MASTER') shall not equal TradeItem/tradeItemIdentification.-->
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="640" />
							</xsl:apply-templates>
						</xsl:when>
						<xsl:when test="referencedTradeItemTypeCode = 'REPLACED'">
							<!--Rule 641: Replaced Trade Item Identification (referencedTradeItemTypeCode equals 'REPLACED') shall not equal TradeItem/tradeItemIdentification.-->
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="641" />
							</xsl:apply-templates>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r642">
		<!--Rule 642: If isTradeItemAConsumerUnit is equal to 'true' and targetMarketCountryCode is equal to '840'(United States) then dataCarrierTypeCode must not be empty..-->
		<xsl:if test="isTradeItemAConsumerUnit = 'true'">
			<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_data_carrier_and_identification:xsd:3' and local-name()='tradeItemDataCarrierAndIdentificationModule']/dataCarrier/dataCarrierTypeCode) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="642" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1000">
		<!--Rule 1000: There shall be one instance of TradeItem/informationProviderOfTradeItem/gln.-->
		<xsl:if test="count(informationProviderOfTradeItem/gln) != 1">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1000" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1001">
		<!--Rule 1001: TradeItem/informationProviderOfTradeItem/partyName shall be used.-->
		<xsl:if test="string(informationProviderOfTradeItem/partyName) = ''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1001" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1004">
		<!--Rule 1004: startAvailabilityDateTime must not be empty.-->
		<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:delivery_purchasing_information:xsd:3' and local-name()='deliveryPurchasingInformationModule']/deliveryPurchasingInformation/startAvailabilityDateTime) = ''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1004" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1008">
		<xsl:param name="targetMarket" />
		<!--Rule 1008: If targetMarketCountryCode does NOT equal <Geographic> then isTradeItemAConsumerUnit SHALL be used.-->
		<xsl:choose>
			<xsl:when test="contains('040, 056, 203, 208, 246, 276, 372, 442, 528, 703, 752, 756, 826', $targetMarket)"/>
			<xsl:otherwise>
				<xsl:if test="string(isTradeItemAConsumerUnit) = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1008" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="r1010">
		<!--Rule 1010: isTradeItemADespatchUnit must not be empty.-->
		<xsl:if test="string(isTradeItemADespatchUnit) = ''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1010" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1012">
		<!--Rule 1012: isTradeItemAnOrderableUnit must not be empty.-->
		<xsl:if test="string(isTradeItemAnOrderableUnit) = ''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1012" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1018">
		<!--Rule 1018: targetMarket for a child item cannot be more specific than for the parent. Example: If parent item targetmarketCountryCode is equal to '840' then child item cannot have a targetMarketSubdivisonCode.-->
		<xsl:if test="targetMarket/targetMarketCountryCode">
			<xsl:for-each select="catalogueItemChildItemLink/catalogueItem/tradeItem">
				<xsl:if test="targetMarket/targetMarketSubdivisionCode">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1018" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1038">
		<!--Rule 1038: discontinuedDateTime and cancelledDateTime shall not be used simultaneously .-->
		<xsl:if test="string(tradeItemSynchronisationDates/cancelledDateTime) != '' and string(tradeItemSynchronisationDates/discontinuedDateTime) != ''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1038" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1045">
		<!--Rule 1045: There must be at most one iteration per languageCode.-->
		<xsl:choose>
			<xsl:when test="@languageCode">
				<xsl:variable name="name" select="name()"/>
				<xsl:variable name="languageCode" select="@languageCode"/>
				<xsl:if test="count(../*[name() = $name and @languageCode = $languageCode]) &gt; 1">
					<xsl:apply-templates select="gs1:AddEventData('language', $languageCode)"/>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1045" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*" mode="r1045"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="r1049">
		<!--Rule 1049: There must be at most one iteration per Unit Of Measurement.-->
		<xsl:choose>
			<xsl:when test="@measurementUnitCode">
				<xsl:variable name="name" select="name()"/>
				<xsl:variable name="measurementUnitCode" select="@measurementUnitCode"/>
				<xsl:if test="count(../*[name() = $name and @measurementUnitCode = $measurementUnitCode]) &gt; 1">
					<xsl:apply-templates select="gs1:AddEventData('unit', $measurementUnitCode)"/>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1049" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:when test="@temperatureMeasurementUnitCode">
				<xsl:variable name="name" select="name()"/>
				<xsl:variable name="measurementUnitCode" select="@temperatureMeasurementUnitCode"/>
				<xsl:if test="count(../*[name() = $name and @temperatureMeasurementUnitCode = $measurementUnitCode]) &gt; 1">
					<xsl:apply-templates select="gs1:AddEventData('unit', $measurementUnitCode)"/>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1049" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:when test="@currencyCode">
				<xsl:variable name="name" select="name()"/>
				<xsl:variable name="measurementUnitCode" select="@currencyCode"/>
				<xsl:if test="count(../*[name() = $name and @currencyCode = $measurementUnitCode]) &gt; 1">
					<xsl:apply-templates select="gs1:AddEventData('unit', $measurementUnitCode)"/>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1049" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:when test="@timeMeasurementUnitCode">
				<xsl:variable name="name" select="name()"/>
				<xsl:variable name="measurementUnitCode" select="@timeMeasurementUnitCode"/>
				<xsl:if test="count(../*[name() = $name and @timeMeasurementUnitCode = $measurementUnitCode]) &gt; 1">
					<xsl:apply-templates select="gs1:AddEventData('unit', $measurementUnitCode)"/>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1049" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:when test="@transactionalMeasurementUnitCode">
				<xsl:variable name="name" select="name()"/>
				<xsl:variable name="measurementUnitCode" select="@transactionalMeasurementUnitCode"/>
				<xsl:if test="count(../*[name() = $name and @transactionalMeasurementUnitCode = $measurementUnitCode]) &gt; 1">
					<xsl:apply-templates select="gs1:AddEventData('unit', $measurementUnitCode)"/>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1049" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:when test="@bitternessOfBeerMeasurementUnitCode">
				<xsl:variable name="name" select="name()"/>
				<xsl:variable name="measurementUnitCode" select="@bitternessOfBeerMeasurementUnitCode"/>
				<xsl:if test="count(../*[name() = $name and @bitternessOfBeerMeasurementUnitCode = $measurementUnitCode]) &gt; 1">
					<xsl:apply-templates select="gs1:AddEventData('unit', $measurementUnitCode)"/>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1049" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*" mode="r1049"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="r1039">
		<!--Rule 1039: If additionalTradeItemIdentificationTypeCode  is equal to 'GTIN_13' then associated additionalTradeItemIdentification value must have 13 digits and must have a valid check digit.-->
		<xsl:for-each select="additionalTradeItemIdentification">
			<xsl:choose>
				<xsl:when test="@additionalTradeItemIdentificationTypeCode = 'GTIN_13'">
					<xsl:if test="gs1:InvalidGTIN(.,13)">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1039" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:when test="@additionalTradeItemIdentificationTypeCode = 'GTIN_8'">
					<xsl:if test="gs1:InvalidGTIN(.,8)">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1040" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:when test="@additionalTradeItemIdentificationTypeCode = 'GTIN_14'">
					<xsl:if test="gs1:InvalidGTIN(.,14)">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1041" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:when test="@additionalTradeItemIdentificationTypeCode = 'GTIN_12'">
					<xsl:if test="gs1:InvalidGTIN(.,12)">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1042" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
		<xsl:for-each select="referencedTradeItem/additionalTradeItemIdentification">
			<xsl:choose>
				<xsl:when test="@additionalTradeItemIdentificationTypeCode = 'GTIN_13'">
					<xsl:if test="gs1:InvalidGTIN(.,13)">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1039" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:when test="@additionalTradeItemIdentificationTypeCode = 'GTIN_8'">
					<xsl:if test="gs1:InvalidGTIN(.,8)">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1040" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:when test="@additionalTradeItemIdentificationTypeCode = 'GTIN_14'">
					<xsl:if test="gs1:InvalidGTIN(.,14)">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1041" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:when test="@additionalTradeItemIdentificationTypeCode = 'GTIN_12'">
					<xsl:if test="gs1:InvalidGTIN(.,12)">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1042" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
		<xsl:for-each select="nextLowerLevelTradeItemInformation/childTradeItem/additionalTradeItemIdentification">
			<xsl:choose>
				<xsl:when test="@additionalTradeItemIdentificationTypeCode = 'GTIN_13'">
					<xsl:if test="gs1:InvalidGTIN(.,13)">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1039" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:when test="@additionalTradeItemIdentificationTypeCode = 'GTIN_8'">
					<xsl:if test="gs1:InvalidGTIN(.,8)">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1040" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:when test="@additionalTradeItemIdentificationTypeCode = 'GTIN_14'">
					<xsl:if test="gs1:InvalidGTIN(.,14)">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1041" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:when test="@additionalTradeItemIdentificationTypeCode = 'GTIN_12'">
					<xsl:if test="gs1:InvalidGTIN(.,12)">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1042" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="*" mode="r1061">
		<!--Rule 1061: The maximumlength of datatype StringAttributeValuePair is 5000 characters.-->
		<xsl:choose>
			<xsl:when test="avpList">
				<xsl:for-each select="stringAVP">
					<xsl:if test="string-length(.) &gt; 5000">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1061" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*" mode="r1061"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="r1078">
		<!--Rule 1078: If TradeItem/brandOwner/gln is not empty then brandOwner/PartyRoleCode shall be empty.-->
		<xsl:if test="string(brandOwner/gln) != ''">
			<xsl:if test="brandOwner[string(partyRoleCode) != '']">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1078" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1079">
		<!--Rule 1079: If TradeItem/informationProviderOfTradeItem/gln is used then TradeItem/informationProviderOfTradeItem/partyRoleCode shall be empty.-->
		<xsl:if test="string(informationProviderOfTradeItem/gln) != ''">
			<xsl:if test="informationProviderOfTradeItem[string(partyRoleCode) != '']">
				<xsl:apply-templates select="informationProviderOfTradeItem" mode="error">
					<xsl:with-param name="id" select="1079" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1080">
		<!--Rule 1080: If TradeItem/manufacturerOfTradeItem/gln and/or TradeItem/manufacturerOfTradeItem/partyName is used then manufacturerOfTradeItem/partyRoleCode shall be empty.-->
		<xsl:if test="string(manufacturerOfTradeItem/gln) != '' or string(manufacturerOfTradeItem/partyName) != ''">
			<xsl:if test="manufacturerOfTradeItem[string(partyRoleCode) != '']">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1080" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1089">
		<!--Rule 1089: If any attribute in class catalogueItem/tradeItem/PartyInRole is used then catalogueItem/tradeItem/PartyInRole/partyRoleCode SHALL be used.-->
		<xsl:for-each select="partyInRole">
			<xsl:if test="string(partyRoleCode) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1089" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="*" mode="r1160">
		<!--Rule 1160: If targetMarketCountryCode equals ('250' (France)) and isTradeItemAConsumerUnit equals 'TRUE' then descriptionShort shall be used.-->
		<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_description:xsd:3' and local-name()='tradeItemDescriptionModule']/tradeItemDescriptionInformation/descriptionShort) = ''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1160" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1161">
		<!--Rule 1161: If targetMarketCountryCode equals ('249' (France) or '250' (France)) then tradeItemDescriptionInformation/tradeItemDescription shall be used.-->
		<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_description:xsd:3' and local-name()='tradeItemDescriptionModule']/tradeItemDescriptionInformation/tradeItemDescription) = ''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1161" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1167">
		<!--Rule 1167: If isTradeItemNonPhysical is not equal to 'true' then tradeItemUnitDescriptor must not be empty.-->
		<xsl:if test="string(isTradeItemNonphysical) != 'true' and string(tradeItemUnitDescriptorCode) = ''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1167" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1168">
		<!--Rule 1168: There must be at most 1 iteration of referencedTradeItem/GTIN where  referencedTradeItemTypeCode equals 'ITEM_VARIANT_MASTER'-->
		<xsl:if test="count(referencedTradeItem[referencedTradeItemTypeCode = 'ITEM_VARIANT_MASTER']) &gt; 1">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1168" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1176">
		<!--Rule 1176: There must be at most 1 iteration of referencedTradeItem/GTIN where  referencedTradeItemTypeCode equals 'PREFERRED'-->
		<xsl:if test="count(referencedTradeItem[referencedTradeItemTypeCode = 'PREFERRED']) &gt; 1">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1176" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1277">
		<!--Rule 1277: If tradeItemUnitDescriptorCode is equal to 'MIXED_MODULE' and parent item exists then parent item tradeItemUnitDescriptorCode must equal 'TRANSPORT_LOAD', 'PALLET', or 'MIXED_MODULE'.-->
		<xsl:variable name="parent" select="../../../tradeItem"/>
		<xsl:if test="$parent">
			<xsl:choose>
				<xsl:when test="$parent/tradeItemUnitDescriptorCode = 'TRANSPORT_LOAD'"/>
				<xsl:when test="$parent/tradeItemUnitDescriptorCode = 'PALLET'"/>
				<xsl:when test="$parent/tradeItemUnitDescriptorCode = 'MIXED_MODULE'"/>
				<xsl:otherwise>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1277" />
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1278">
		<!--Rule 1278: If tradeItemUnitDescriptorCode is equal to 'MIXED_MODULE' then child item tradeItemUnitDescriptorCode must not equal 'TRANSPORT_LOAD' .-->
		<xsl:for-each select="catalogueItemChildItemLink/catalogueItem/tradeItem">
			<xsl:choose>
				<xsl:when test="tradeItemUnitDescriptorCode = 'TRANSPORT_LOAD'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1278" />
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="*" mode="r1279">
		<!--Rule 1279: If tradeItemUnitDescriptorCode equals 'DISPLAY_SHIPPER' then parent item tradeItemUnitDescriptorCode shall not equal 'BASE_UNIT_OR_EACH' or 'PACK_OR_INNER_PACK'.-->
		<xsl:variable name="parent" select="../../../tradeItem"/>
		<xsl:if test="$parent">
			<xsl:choose>
				<xsl:when test="$parent/tradeItemUnitDescriptorCode = 'BASE_UNIT_OR_EACH'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1279" />
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="$parent/tradeItemUnitDescriptorCode = 'PACK_OR_INNER_PACK'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1279" />
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1280">
		<!--Rule 1280: If tradeItemUnitDescriptorCode is equal to 'DISPLAY_SHIPPER' then child item tradeItemUnitDescriptorCode must not equal 'TRANSPORT_LOAD', 'MIXED_MODULE' or ' PALLET'.-->
		<xsl:for-each select="catalogueItemChildItemLink/catalogueItem/tradeItem">
			<xsl:choose>
				<xsl:when test="tradeItemUnitDescriptorCode = 'TRANSPORT_LOAD' or tradeItemUnitDescriptorCode = 'MIXED_MODULE' or tradeItemUnitDescriptorCode = 'PALLET'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1280" />
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="*" mode="r1283">
		<!--Rule 1283: effectiveDateTime must not be empty-->
		<xsl:if test="string(tradeItemSynchronisationDates/effectiveDateTime) = ''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1283" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1288">
		<xsl:param name="targetMarket" />
		<!--Rule 1288: If targetMarketCountryCode does not equal (036 (Australia), 554 (New Zealand)) and If preliminaryItemStatusCode is equal to 'PRELIMINARY' or 'FINAL' then firstShipDateTime must not be empty. -->
		<xsl:if test="$targetMarket != '036' and $targetMarket != '554'">
			<xsl:if test="preliminaryItemStatusCode = 'PRELIMINARY' or preliminaryItemStatusCode = 'FINAL'">
				<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:delivery_purchasing_information:xsd:3' and local-name()='deliveryPurchasingInformationModule']/deliveryPurchasingInformation/firstShipDateTime) = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1288" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1291">
		<!--Rule 1291: If preliminaryItemStatusCode is equal to 'PRELIMINARY' then parent trade item preliminaryItemStatusCode must not equal 'FINAL'.-->
		<xsl:if test="preliminaryItemStatusCode = 'PRELIMINARY'">
			<xsl:variable name="parent" select="../../../tradeItem"/>
			<xsl:if test="$parent/preliminaryItemStatusCode = 'FINAL'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1291" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1299">
		<xsl:param name="targetMarket" />
		<!--Rule 1299: If targetMarketCountryCode does not equal <Geographic> and any attribute in class brandOwner is used then brandOwner/gln SHALL be used.-->
		<xsl:choose>
			<xsl:when test="contains('036, 040, 276', $targetMarket)"/>
			<xsl:otherwise>
				<xsl:if test="brandOwner/*[name() != 'gln']">
					<xsl:if test="string(brandOwner/gln) = ''">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1299" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="r1338">
		<!--Rule 1338: If gpcAttributeTypeCode is used then gpcAttributeValueCode shall be used.-->
		<xsl:for-each select="gDSNTradeItemClassification/gDSNTradeItemClassificationAttribute">
			<xsl:if test="string(gpcAttributeTypeCode) != '' and string(gpcAttributeValueCode) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1338" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="*" mode="r1419">
		<!--Rule 1419: There must be one iteration for language 'Swedish'.-->
		<xsl:choose>
			<xsl:when test="@languageCode">
				<xsl:variable name="name" select="name()"/>
				<xsl:if test="count(../*[name() = $name and @languageCode = 'sv']) &lt; 1">
					<xsl:apply-templates select="gs1:AddEventData('language', 'sv')"/>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1419" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*" mode="r1419"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="r1459">
		<xsl:for-each select="gDSNTradeItemClassification/additionalTradeItemClassification">
			<!--Rule 1459: if additionalTradeItemClassificationSystemCode is used then there shall be a corresponding additionalTradeItemClassificationCodeValue used-->
			<xsl:if test="string(additionalTradeItemClassificationSystemCode) != '' and string(additionalTradeItemClassificationValue/additionalTradeItemClassificationCodeValue) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1459" />
				</xsl:apply-templates>
			</xsl:if>
			<!--Rule 1460: if additionalTradeItemClassificationCodeValue is used then there shall be a corresponding additionalTradeItemClassificationSystemCode used-->
			<xsl:if test="string(additionalTradeItemClassificationSystemCode) = '' and string(additionalTradeItemClassificationValue/additionalTradeItemClassificationCodeValue) != ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1460" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="*" mode="r1613">
		<!--Rule 1613: If additionalTradeItemClassificationSystemCode equals '76' then additionalTradeItemClassificationCodeValue shall equal ('EU_CLASS_I',  'EU_CLASS_IIA', 'EU_CLASS_IIB', 'EU_CLASS_III', 'EU_CLASS_A', 'EU_CLASS_B', 'EU_CLASS_C', or 'EU_CLASS_D').-->
		<xsl:variable name="class" select="gDSNTradeItemClassification/additionalTradeItemClassification[additionalTradeItemClassificationSystemCode = '76']"/>
		<xsl:if test="$class">
			<xsl:choose>
				<xsl:when test="$class/additionalTradeItemClassificationValue/additionalTradeItemClassificationCodeValue = 'EU_CLASS_I'"/>
				<xsl:when test="$class/additionalTradeItemClassificationValue/additionalTradeItemClassificationCodeValue = 'EU_CLASS_IIA'"/>
				<xsl:when test="$class/additionalTradeItemClassificationValue/additionalTradeItemClassificationCodeValue = 'EU_CLASS_IIB'"/>
				<xsl:when test="$class/additionalTradeItemClassificationValue/additionalTradeItemClassificationCodeValue = 'EU_CLASS_III'"/>
				<xsl:when test="$class/additionalTradeItemClassificationValue/additionalTradeItemClassificationCodeValue = 'EU_CLASS_A'"/>
				<xsl:when test="$class/additionalTradeItemClassificationValue/additionalTradeItemClassificationCodeValue = 'EU_CLASS_B'"/>
				<xsl:when test="$class/additionalTradeItemClassificationValue/additionalTradeItemClassificationCodeValue = 'EU_CLASS_C'"/>
				<xsl:when test="$class/additionalTradeItemClassificationValue/additionalTradeItemClassificationCodeValue = 'EU_CLASS_D'"/>
				<xsl:otherwise>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1613" />
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1639">
		<xsl:param name="brick" />
		<!--Rule 1639: If targetMarketCountryCode equals '250' (France) and  isTradeItemABaseUnit equals 'true' and (gpcCategoryCode equals ('10000273' [- Wine – Fortified] or '10000275' [- Wine – Sparkling] or  '10000276' [- Wine – Still]) then isTradeItemAQualityVintageAlcoholProduct shall be used.-->
		<xsl:if test="$brick = '10000276'">
			<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:alcohol_information:xsd:3' and local-name()='alcoholInformationModule']/alcoholInformation/isTradeItemAQualityVintageAlcoholProduct) = ''">
				<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1639" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1662">
		<xsl:param name="brick" />
		<!--Rule 1662: If targetMarketCountryCode equals <Geographic> and gpcCategoryCode equals '10000159' and isTradeItemAConsumerUnit = 'true', then degreeOfOriginalWort SHALL be used.-->
		<xsl:if test="$brick = '10000159'">
			<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:alcohol_information:xsd:3' and local-name()='alcoholInformationModule']/alcoholInformation/degreeOfOriginalWort) = ''">
				<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1662" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1684">
		<xsl:param name="brick" />

		<xsl:if test="gs1:IsInFamily($brick, '67010000, 63010000')">

			<!--Rule 1684: If targetMarketCountryCode equals ‘250’ (France) and gpcCategoryCode is in GPC Family ('67010000' (Clothing) or ‘63010000’ (Footwear)) and tradeItemUnitDescriptorCode equals ‘BASE_UNIT_OR_EACH’ and isTradeItemAConsumerUnit equals ‘true’ then at least one iteration of additionalTradeItemIdentification/@additionalTradeItemIdentificationTypeCode SHALL have the value ‘SUPPLIER_ASSIGNED’ -->
			<xsl:if test="count(additionalTradeItemIdentification[@additionalTradeItemIdentificationTypeCode ='SUPPLIER_ASSIGNED']) = 0">
				<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1684" />
				</xsl:apply-templates>
			</xsl:if>

			<!--Rule 1686: If targetMarketCountryCode equals ‘250’ (France) and gpcCategoryCode is in GPC Family ('67010000' (Clothing) or ‘63010000’ (Footwear)) and isTradeItemAConsumerUnit equals ‘true’ then additionalTradeItemDescription shall not be empty.-->
			<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_description:xsd:3' and local-name()='tradeItemDescriptionModule']/tradeItemDescriptionInformation/additionalTradeItemDescription) = ''">
				<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1686" />
				</xsl:apply-templates>
			</xsl:if>

			<!--Rule 1688: If targetMarketCountryCode equals ‘250’ (France) and gpcCategoryCode is in GPC Family ('67010000' (Clothing) or ‘63010000’ (Footwear)) and tradeItemUnitDescriptorCode equals ‘BASE_UNIT_OR_EACH’ and isTradeItemAConsumerUnit equals ‘true’ then one iteration of colourCode shall be provided.-->
			<xsl:if test="count(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_description:xsd:3' and local-name()='tradeItemDescriptionModule']/tradeItemDescriptionInformation/colour/colourCode) = 0">
				<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1688" />
				</xsl:apply-templates>
			</xsl:if>

			<!--Rule 1689: If targetMarketCountryCode equals ‘250’ (France) and gpcCategoryCode is in GPC Family ('67010000' (Clothing) or ‘63010000’ (Footwear)) and tradeItemUnitDescriptorCode equals ‘BASE_UNIT_OR_EACH’ and isTradeItemAConsumerUnit equals ‘true’ then colourFamilyCode shall be populated.-->
			<xsl:if test="count(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_description:xsd:3' and local-name()='tradeItemDescriptionModule']/tradeItemDescriptionInformation/colour/colourFamilyCode) = 0">
				<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1689" />
				</xsl:apply-templates>
			</xsl:if>

			<!--Rule 1690: If targetMarketCountryCode equals ‘250’ (France) and gpcCategoryCode is in GPC Family ('67010000' (Clothing) or ‘63010000’ (Footwear)) and tradeItemUnitDescriptorCode equals ‘BASE_UNIT_OR_EACH’ and isTradeItemAConsumerUnit equals ‘true’ then targetConsumerGender shall be provided .-->
			<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:marketing_information:xsd:3' and local-name()='marketingInformationModule']/marketingInformation/targetConsumer/targetConsumerGender) = ''">
				<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1690" />
				</xsl:apply-templates>
			</xsl:if>

		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1692">
		<!--Rule 1692: If (targetMarketCountryCode equals '056' (Belgium) or '528' (the Netherlands) or '442' (Luxembourg) ) and isTradeItemAConsumerUnit equals 'true', then one instance of importClassificationTypeCode SHALL be equal to 'INTRASTAT'.-->
		<xsl:if test="count(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:place_of_item_activity:xsd:3' and local-name()='placeOfItemActivityModule']/importClassification[importClassificationTypeCode = 'INTRASTAT'])  = 0">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1692" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1695">
		<!--Rule 1695: If targetMarketCountryCode equals ('250' (France)) then codes ('NON_EU' or 'D_A') cannot be used for any countryCode attribute.-->
		<xsl:if test=".//@countryCode = 'NON_EU' or .//@countryCode = 'D_A'">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1695" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1697">
		<xsl:param name="targetMarket" />
		<!--Rule 1697: Code value 'NON_EU' (Non European Union) shall not be used -->
		<xsl:if test="$targetMarket = 'NON_EU'">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1697" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1722">
		<!--Rule 1722: If additionalTradeItemClassificationSystemCode equals '85' then additionalTradeItemClassificationCodeValue SHALL equal (‘EU_CLASS_I’, ‘EU_CLASS_IIA’, ‘EU_CLASS_IIB’, ‘EU_CLASS_III’, ‘IVDD_ANNEX_II_LIST_A’, ‘IVDD_ANNEX_II_LIST_B’, ‘IVDD_DEVICES_SELF_TESTING’, ‘IVDD_GENERAL’, or 'AIMDD')-->
		<xsl:variable name="class" select="gDSNTradeItemClassification/additionalTradeItemClassification[additionalTradeItemClassificationSystemCode = '85']"/>
		<xsl:if test="$class">
			<xsl:for-each select="$class/additionalTradeItemClassificationValue/additionalTradeItemClassificationCodeValue">
				<xsl:choose>
					<xsl:when test="contains('EU_CLASS_I, EU_CLASS_IIA, EU_CLASS_IIB, EU_CLASS_III, IVDD_ANNEX_II_LIST_A, IVDD_ANNEX_II_LIST_B, IVDD_DEVICES_SELF_TESTING, IVDD_GENERAL, AIMDD', .)"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1722" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1744">
		<xsl:param name="brick" />
		<!--Rule 1744: If targetMarketCountryCode equals <Geographic> and (gpcCategoryCode is in GPC Segment '50000000' (Food/Beverage) or gpcCategoryCode equals ('10000467' (Vitamins/Minerals), '10000468' (Nutritional Supplements) or '10000651' (Vitamins/Minerals/Nutritional Supplements Variety Packs))) and isTradeItemAConsumerUnit equals 'true' and (preliminaryItemStatusCode equals 'FINAL' or is not used) then regulatedProductName SHALL be used.-->
		<xsl:if test="string(preliminaryItemStatusCode) = '' or preliminaryItemStatusCode = 'FINAL'">
			<xsl:if test="gs1:IsInSegment($brick, '50000000') or $brick = '10000467' or $brick = '10000468' or $brick = '10000651'">
				<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_description:xsd:3' and local-name()='tradeItemDescriptionModule']/tradeItemDescriptionInformation/regulatedProductName) = ''">
					<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1744" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1793">
		<xsl:variable name="class" select="gDSNTradeItemClassification"/>
		<xsl:for-each select="$class/additionalTradeItemClassification">
			<xsl:choose>
				<!--Rule 1793: If one instance of additionalTradeItemClassificationSystemCode equals '76' then all other instances of additionalTradeItemClassificationSystemCode SHALL NOT equal '76’.-->
				<xsl:when test="additionalTradeItemClassificationSystemCode  = '76'">
					<xsl:if test="count($class/additionalTradeItemClassification[additionalTradeItemClassificationSystemCode  = '76']) &gt; 1">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1793" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<!--Rule 1794: If one instance of additionalTradeItemClassificationSystemCode equals '85' then all other instances of additionalTradeItemClassificationSystemCode SHALL NOT equal '85’.-->
				<xsl:when test="additionalTradeItemClassificationSystemCode  = '85'">
					<xsl:if test="count($class/additionalTradeItemClassification[additionalTradeItemClassificationSystemCode  = '85']) &gt; 1">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1794" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="*" mode="r1804">
		<xsl:param name="brick" />
		<!--Rule 1804: If targetMarketCountryCode equals <Geographic> and gpcCategoryCode is in GPC Family '12010000' (Tobacco/Cannabis/Smoking Accessories) and gpcCategoryCode is not in GPC Brick ('10000303' (Smoking Accessories) or '10006730' (Electronic Cigarette Accessories)) and isTradeItemAConsumerUnit equals 'true' then consumerSalesConditionCode SHALL be used.-->
		<xsl:if test="gs1:IsInFamily($brick, '12010000') and $brick != '10000303' and $brick != '10006730'">
			<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:sales_information:xsd:3' and local-name()='salesInformationModule']/salesInformation/consumerSalesConditionCode) = ''">
				<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1804" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1835">
		<!--Rule 1835: If referencedTradeItemTypeCode equals 'EQUIVALENT', then each iteration with referencedTradeItem/gtin SHALL be unique.-->
		<!--Rule 1836: If referencedTradeItemTypeCode equals 'DEPENDENT_PROPRIETARY', then each iteration with referencedTradeItem/gtin SHALL be unique.-->
		<xsl:variable name="parent" select="."/>
		<xsl:for-each select="referencedTradeItem">
			<xsl:choose>
				<xsl:when test="referencedTradeItemTypeCode = 'EQUIVALENT'">
					<xsl:variable name="gtin" select="gtin"/>
					<xsl:if test="count($parent/referencedTradeItem[referencedTradeItemTypeCode = 'EQUIVALENT' and gtin = $gtin]) &gt; 1">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1835" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:when test="referencedTradeItemTypeCode = 'DEPENDENT_PROPRIETARY'">
					<xsl:variable name="gtin" select="gtin"/>
					<xsl:if test="count($parent/referencedTradeItem[referencedTradeItemTypeCode = 'DEPENDENT_PROPRIETARY' and gtin = $gtin]) &gt; 1">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1836" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="*" mode="r1850">
		<xsl:param name="targetMarket" />
		<!--Rule 1850: If targetMarketCountryCode equals <Geographic> and tradeItemUnitDescriptorCode equals 'BASE_UNIT_OR_EACH', then tradeItemTradeChannelCode SHALL be used.-->
		<xsl:if test="string(tradeItemTradeChannelCode)  = ''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1850" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1855">
		<!--Rule 1855: If targetMarketCountryCode equals <Geographic> then isTradeItemAConsumerUnit SHALL be used.-->
		<xsl:if test="string(isTradeItemAConsumerUnit) = ''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1855" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1857">
		<!--Rule 1857: If targetMarketCountryCode equals <Geographic> and isTradeItemAVariableUnit equals 'false' then additionalTradeItemIdentification/@additionalTradeItemIdentificationTypeCode SHALL NOT equal 'PLU'.-->
		<xsl:if test="additionalTradeItemIdentification[@additionalTradeItemIdentificationTypeCode = 'PLU']">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1857" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1858">
		<xsl:param name="brick" />

		<!--Rule 1858: If targetMarketCountryCode equals <Geographic> and TradeItem/PartyInRole/partyRoleCode equals ('PURCHASE_ORDER_RECEIVER' or 'SHIP_FROM'), then TradeItem/PartyInRole/gln and TradeItem/PartyInRole/partyName SHALL be used.-->
		<xsl:if test="PartyInRole[partyRoleCode = 'PURCHASE_ORDER_RECEIVER'] and (PartyInRole[partyRoleCode = 'PURCHASE_ORDER_RECEIVER']/gln = '' or PartyInRole[partyRoleCode = 'PURCHASE_ORDER_RECEIVER']/name = '')">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1858" />
			</xsl:apply-templates>
		</xsl:if>
		<xsl:if test="PartyInRole[partyRoleCode = 'SHIP_FROM'] and (string(PartyInRole[partyRoleCode = 'SHIP_FROM']/gln) = '' or string(PartyInRole[partyRoleCode = 'SHIP_FROM']/name) = '')">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1858" />
			</xsl:apply-templates>
		</xsl:if>


		<xsl:variable name="plu" select="additionalTradeItemIdentification[@additionalTradeItemIdentificationTypeCode = 'PLU']"/>
		<xsl:choose>
			<xsl:when test="$plu">

				<!--Rule 2062: If targetMarketCountryCode equals <Geographic> and additionalTradeItemIdentification/@additionalTradeItemIdentificationTypeCode equals 'PLU' then associated additionalTradeItemIdentification value SHALL start with one of the following prefixes ('02' , '22' , '24' , '26' , '28' , '21' , '23' , '25' , '27 or '29').-->
				<xsl:choose>
					<xsl:when test="starts-with($plu, '02')"/>
					<xsl:when test="starts-with($plu, '22')"/>
					<xsl:when test="starts-with($plu, '24')"/>
					<xsl:when test="starts-with($plu, '26')"/>
					<xsl:when test="starts-with($plu, '28')"/>
					<xsl:when test="starts-with($plu, '21')"/>
					<xsl:when test="starts-with($plu, '23')"/>
					<xsl:when test="starts-with($plu, '25')"/>
					<xsl:when test="starts-with($plu, '27')"/>
					<xsl:when test="starts-with($plu, '29')"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="2062" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>

				<!--Rule 2063: If targetMarketCountryCode equals <Geographic> and additionalTradeItemIdentification/@additionalTradeItemIdentificationTypeCode equals 'PLU' then isTradeItemAVariableUnit SHALL equal 'true'.-->
				<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:variable_trade_item_information:xsd:3' and local-name()='variableTradeItemInformationModule']/variableTradeItemInformation/isTradeItemAVariableUnit) != 'true'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="2063" />
					</xsl:apply-templates>
				</xsl:if>

				<!--Rule 2065: If targetMarketCountryCode equals <Geographic> and additionalTradeItemIdentification/@additionalTradeItemIdentificationTypeCode equals 'PLU' then associated additionalTradeItemIdentification value must have exactly 7 digits.-->
				<xsl:if test="number($plu) != $plu or string-length($plu) != 7">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="2065" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<!--Rule 2064: If targetMarketCountryCode equals <Geographic> and isTradeItemAVariableUnit equals 'true' then at least one iteration of additionalTradeItemIdentification/@additionalTradeItemIdentificationTypeCode SHALL equal 'PLU'.-->
				<xsl:if test="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:variable_trade_item_information:xsd:3' and local-name()='variableTradeItemInformationModule']/variableTradeItemInformation/isTradeItemAVariableUnit = 'true'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="2064" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>

		<!--Rule 2067: If targetMarketCountryCode equals <Geographic> and hasDisplayReadyPackaging equals 'TRUE' then isTradeItemAConsumerUnit SHALL equal 'false'.-->
		<xsl:if test="string(isTradeItemAConsumerUnit) != 'false' and displayUnitInformation/hasDisplayReadyPackaging = 'TRUE'">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="2067" />
			</xsl:apply-templates>
		</xsl:if>


		<xsl:if test="isTradeItemABaseUnit = 'true'">

			<!--Rule 2070: If targetMarketCountryCode equals <Geographic> and (gpcCategoryCode is in GPC Class '50202200' and gpcCategoryCode does not equal ('10000142', '10000143', '10008042') and isTradeItemABaseUnit equals 'true' then percentageOfAlcoholByVolume SHALL be used.-->
			<xsl:if test="gs1:IsInClass($brick, '50202200') and $brick != '10000142'  and $brick != '10000143' and $brick != '10008042'">
				<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:alcohol_information:xsd:3' and local-name()='alcoholInformationModule']/alcoholInformation/percentageOfAlcoholByVolume) = ''">
					<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="2070" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>

			<!--Rule 2072: If targetMarketCountryCode equals <Geographic> and isTradeItemADespatchUnit equals 'true' and tradeItem/gtin begins with '9' then isTradeItemAVariableUnit SHALL equals 'true' on the lowest level of the hierarchy (isTradeItemABaseUnit equals 'true').-->
			<xsl:if test="substring(gtin,1,1) = '9'">
				<xsl:if test="string(isTradeItemAVariableUnit) != 'true'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="2072" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<!--Rule 102068: If targetMarketCountryCode equals <Geographic> and hasDisplayReadyPackaging equals 'TRUE' then isTradeItemADespatchUnit SHALL equal 'true'.-->
		<xsl:if test="displayUnitInformation/hasDisplayReadyPackaging = 'TRUE'">
			<xsl:if test="string(isTradeItemADespatchUnit) != 'true'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="102068" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

	</xsl:template>

	<xsl:template match="*" mode="r1861">
		<!--Rule 1861: If targetMarketCountryCode equals <Geographic> and isTradeItemADespatchUnit equals 'true', then packagingTypeCode SHALL be used.-->
		<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:packaging_information:xsd:3' and local-name()='packagingInformationModule']/packaging/packagingTypeCode) = ''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1861" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1862">
		<!--Rule 1862: If referencedTradeItemTypeCode equals 'SUBSTITUTED', then tradeItem/gtin SHALL not equal referencedTradeItem/gtin.-->
		<xsl:variable name="gtin" select="string(gtin)"/>
		<xsl:for-each select="referencedTradeItem[referencedTradeItemTypeCode = 'SUBSTITUTED']">
			<xsl:if test="gtin = $gtin">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1862" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="*" mode="r1867">
		<!--Rule 1867: (Warning) If targetMarketCountryCode equals <Geographic> and additionalTradeItemIdentification/@additionalTradeItemIdentificationTypeCode equals 'SUPPLIER_ASSIGNED', then additionalTradeItemIdentification SHALL be less than or equal to 35 characters.-->
		<xsl:for-each select="additionalTradeItemIdentification[@additionalTradeItemIdentificationTypeCode = 'SUPPLIER_ASSIGNED']">
			<xsl:if test="string-length(additionalTradeItemIdentification) &gt; 35">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1867" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="*" mode="r1875">
		<!--Rule 1875: If targetMarketCountryCode equals <Geographic> and tradeItemUnitDescriptorCode equals 'PACK_OR_INNER_PACK' and isTradeItemAConsumerUnit equals 'true', then totalQuantityOfNextLowerLevelTradeItem SHALL be greater than 1.-->
		<xsl:if test="string(nextLowerLevelTradeItemInformation/totalQuantityOfNextLowerLevelTradeItem) != '' and nextLowerLevelTradeItemInformation/totalQuantityOfNextLowerLevelTradeItem &lt; 1">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1875" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1877">
		<!--Rule 1877: If targetMarketCountryCode equals <Geographic> and tradeItemUnitDescriptorCode equals ('DISPLAY_SHIPPER' or 'MIXED_MODULE') and quantityOfChildren is greater than 1, then tradeItem/gtin SHALL start with '0'.-->
		<xsl:if test="nextLowerLevelTradeItemInformation/quantityOfChildren &gt; 1">
			<xsl:if test="substring(gtin,1,1) != '0'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1877" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<!--Rule 1890: If targetMarketCountryCode equals <Geographic> and tradeItemUnitDescriptorCode equals 'PALLET' or 'MIXED_MODULE', then quantityOfTradeItemsContainedInACompleteLayer SHALL be greater than 0.-->
		<xsl:variable name="quantityOfTradeItems" select="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_hierarchy:xsd:3' and local-name()='tradeItemHierarchyModule']/tradeItemHierarchy/quantityOfTradeItemsContainedInACompleteLayer"/>
		<xsl:if test="string($quantityOfTradeItems) = '' or $quantityOfTradeItems &lt;= 0">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1890" />
			</xsl:apply-templates>
		</xsl:if>

		<!--Rule 1891: If targetMarketCountryCode equals <Geographic> and tradeItemUnitDescriptorCode equals 'PALLET' or 'MIXED_MODULE', then platformTermsAndConditionsCode SHALL be used.-->
		<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:packaging_information:xsd:3' and local-name()='packagingInformationModule']/packaging/platformTermsAndConditionsCode) = ''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1891" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1883">
		<!--Rule 1883: If targetMarketCountryCode equals <Geographic> and tradeItemUnitDescriptorCode equals 'PACK_OR_INNER_PACK' and isTradeItemAConsumerUnit equals 'true', then totalQuantityOfNextLowerLevelTradeItem SHALL be greater than 1.-->
		<xsl:if test="string(nextLowerLevelTradeItemInformation/totalQuantityOfNextLowerLevelTradeItem) = '' or nextLowerLevelTradeItemInformation/totalQuantityOfNextLowerLevelTradeItem &lt;= 1">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1883" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1892">
		<xsl:param name="brick" />
		<!--Rule 1892: If targetMarketCountryCode equals <Geographic> and gpcCategoryCode is in GPC Segment '50000000' and isTradeItemAConsumerUnit equals 'true', then netWeight SHALL be used.-->
		<xsl:if test="gs1:IsInSegment($brick, '50000000')">
			<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_measurements:xsd:3' and local-name()='tradeItemMeasurementsModule']/tradeItemMeasurements/tradeItemWeight/netWeight) = ''">
				<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1892" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1895">
		<!--Rule 1895: If targetMarketCountryCode equals <Geographic> and referencedTradeItem/gtin is used, then referencedTradeItem/gtin SHALL be unique across all iterations where referencedTradeItemTypeCode equals ('DEPENDENT_PROPRIETARY', 'EQUIVALENT', 'PRIMARY_ALTERNATIVE', 'REPLACED', 'REPLACED_BY', 'SUBSTITUTED' or 'SUBSTITUTED_BY').-->
		<xsl:variable name="parent" select="."/>
		<xsl:for-each select="referencedTradeItem">
			<xsl:variable name="gtin" select="string(gtin)"/>
			<xsl:if test="$gtin != '' and count($parent/referencedTradeItem[gtin=$gtin]) &gt; 1">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1895" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="*" mode="r1896">
		<!--Rule 1896: If referencedTradeItem/gtin is used, then referencedTradeItem/gtin SHALL be unique across all iterations where referencedTradeItemTypeCode equals ('REPLACED' or 'REPLACED_BY').-->
		<!--Rule 1897: If referencedTradeItem/gtin is used, then referencedTradeItem/gtin SHALL be unique across all iterations where referencedTradeItemTypeCode equals ('SUBSTITUTED' or 'SUBSTITUTED_BY').-->
		<xsl:variable name="parent" select="."/>
		<xsl:for-each select="referencedTradeItem">
			<xsl:variable name="gtin" select="string(gtin)"/>
			<xsl:if test="$gtin != ''">
				<xsl:choose>
					<xsl:when test="referencedTradeItemTypeCode = 'REPLACED'">
						<xsl:if test="count($parent/referencedTradeItem[referencedTradeItemTypeCode = 'REPLACED' and gtin=$gtin]) &gt; 1">
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="1896" />
							</xsl:apply-templates>
						</xsl:if>
					</xsl:when>
					<xsl:when test="referencedTradeItemTypeCode = 'REPLACED_BY'">
						<xsl:if test="count($parent/referencedTradeItem[referencedTradeItemTypeCode = 'REPLACED_BY' and gtin=$gtin]) &gt; 1">
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="1896" />
							</xsl:apply-templates>
						</xsl:if>
					</xsl:when>
					<xsl:when test="referencedTradeItemTypeCode = 'SUBSTITUTED'">
						<xsl:if test="count($parent/referencedTradeItem[referencedTradeItemTypeCode = 'SUBSTITUTED' and gtin=$gtin]) &gt; 1">
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="1897" />
							</xsl:apply-templates>
						</xsl:if>
					</xsl:when>
					<xsl:when test="referencedTradeItemTypeCode = 'SUBSTITUTED_BY'">
						<xsl:if test="count($parent/referencedTradeItem[referencedTradeItemTypeCode = 'SUBSTITUTED_BY' and gtin=$gtin]) &gt; 1">
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="1897" />
							</xsl:apply-templates>
						</xsl:if>
					</xsl:when>
				</xsl:choose>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="*" mode="r1901">
		<!--Rule 1901: If targetMarketCountryCode equals <Geographic>, then descriptionShort SHALL be used.-->
		<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_description:xsd:3' and local-name()='tradeItemDescriptionModule']/tradeItemDescriptionInformation/descriptionShort) = ''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1901" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1917">
		<!--Rule 1917: If targetMarketCountryCode equals <Geographic> and tradeItemUnitDescriptorCode does not equal ('PALLET ' or 'MIXED_MODULE') then packagingTypeCode SHALL be used.-->
		<xsl:if test="string(tradeItemUnitDescriptorCode) != 'PALLET' and string(tradeItemUnitDescriptorCode) != 'MIXED_MODULE'">
			<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:packaging_information:xsd:3' and local-name()='packagingInformationModule']/packaging/packagingTypeCode) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1917" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1918">
		<!--Rule 1918: If targetMarketCountryCode equals <Geographic> and isTradeItemABaseUnit equals 'true' and isTradeItemAConsumerUnit equals 'false' then netContent SHALL be used.-->
		<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_measurements:xsd:3' and local-name()='tradeItemMeasurementsModule']/tradeItemMeasurements/netContent) = ''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1918" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r1922">

		<!--Rule 1922: If targetMarketCountryCode equals <Geographic> and isTradeItemAConsumerUnit equals 'true' then dutyFeeTaxTypeCode SHALL be used.-->
		<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:duty_fee_tax_information:xsd:3' and local-name()='dutyFeeTaxInformationModule']/dutyFeeTaxInformation/dutyFeeTaxTypeCode) = ''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1922" />
			</xsl:apply-templates>
		</xsl:if>

		<!--Rule 102071: If targetMarketCountryCode equals <Geographic> and isTradeItemAConsumerUnit equals 'true' then one iteration of importClassificationTypeCode SHALL equal to ('INTRASTAT' or 'TARIF_INTEGRE_DE_LA_COMMUNAUTE').-->
		<xsl:choose>
			<xsl:when test="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:place_of_item_activity:xsd:3' and local-name()='placeOfItemActivityModule']/importClassification[importClassificationTypeCode = 'INTRASTAT']"/>
			<xsl:when test="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:place_of_item_activity:xsd:3' and local-name()='placeOfItemActivityModule']/importClassification[importClassificationTypeCode = 'TARIF_INTEGRE_DE_LA_COMMUNAUTE']"/>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="102071" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="r1937">
		<!--Rule 1937: There must be one iteration for language 'German, French and Italian'.-->
		<xsl:choose>
			<xsl:when test="@languageCode">
				<xsl:variable name="name" select="name()"/>
				<xsl:if test="count(../*[name() = $name and @languageCode = 'de']) &lt; 1 or count(../*[name() = $name and @languageCode = 'fr']) &lt; 1 or count(../*[name() = $name and @languageCode = 'it']) &lt; 1">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1937" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*" mode="r1937"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="r1963">

		<!--Rule 1963: If targetMarketCountryCode equals <Geographic> and gpcCategoryCode equals '10000159' (Beer) and isTradeItemABaseUnit equals 'true' then degreeOfOriginalWort SHALL be used.-->
		<xsl:if test="isTradeItemABaseUnit = 'true'">
			<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:alcohol_information:xsd:3' and local-name()='alcoholInformationModule']/alcoholInformation/degreeOfOriginalWort) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1963" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<!--Rule 1964: If targetMarketCountryCode equals <Geographic> and (brandOwner/gln is used or brandOwner/partyName is used) then brandOwner/gln SHALL be used and brandOwner/partyName SHALL be used.-->
		<xsl:if test="(string(brandOwner/gln) != '' or string(brandOwner/partyName) != '') and (string(brandOwner/gln) = '' or string(brandOwner/partyName) = '')">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1964" />
			</xsl:apply-templates>
		</xsl:if>

	</xsl:template>

	<xsl:template match="*" mode="r1971">

		<xsl:if test="tradeItemUnitDescriptorCode = 'PALLET' or tradeItemUnitDescriptorCode = 'MIXED_MODULE'">

			<!--Rule 1971: If targetMarketCountryCode equals <Geographic> and tradeItemUnitDescriptorCode equals ('PALLET' or 'MIXED_MODULE') then isTradeItemADespatchUnit SHALL equal 'true'.-->
			<xsl:if test="string(isTradeItemADespatchUnit) != 'true'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1971" />
				</xsl:apply-templates>
			</xsl:if>

			<!--Rule 1982: If targetMarketCountryCode equals <Geographic> and tradeItemUnitDescriptorCode equals ('PALLET' or 'MIXED_MODULE') then one iteration of TradeItemStacking class SHALL have stackingFactorTypeCode equal to 'STORAGE_UNSPECIFIED'.-->
			<xsl:choose>
				<xsl:when test="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_handling:xsd:3' and local-name()='tradeItemHandlingModule']/tradeItemHandlingInformation/tradeItemStacking[stackingFactor = 'STORAGE_UNSPECIFIED']"/>
				<xsl:otherwise>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1982" />
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>

			<!--Rule 1983: If targetMarketCountryCode equals <Geographic> and tradeItemUnitDescriptorCode equals ('PALLET' or 'MIXED_MODULE') then quantityOfCompleteLayersContainedInATradeItem SHALL be used.-->
			<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_hierarchy:xsd:3' and local-name()='tradeItemHierarchyModule']/tradeItemHierarchy/quantityOfCompleteLayersContainedInATradeItem) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1983" />
				</xsl:apply-templates>
			</xsl:if>


		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r2004">
		<xsl:param name="brick" />

		<!--Rule 2004: If targetMarketCountryCode equals <Geographic> and (gHSSymbolDescriptionCode is used or gHSSignalWordsCode is used or dangerousSubstanceWasteCode/enumerationValueInformation/enumerationValue is used or dangerousSubstancePhaseOfMatterCode is used or dangerousSubstanceGasDensity is used or dangerousSubstancesWaterSolubilityCode is used or chemicalIngredientIdentification is used) then one iteration of regulatoryAct SHALL equal 'GHS' and corresponding regulatoryPermitIdentification SHALL equal 'TRUE'.-->
		<xsl:variable name="safety">
			<xsl:variable name="mod" select="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:safety_data_sheet:xsd:3' and local-name()='safetyDataSheetModule']/safetyDataSheetInformation"/>
			<xsl:choose>
				<xsl:when test="$mod[string(gHSDetail/gHSSymbolDescriptionCode) != ''] or $mod[string(gHSDetail/gHSSignalWordsCode) != '']">
					<xsl:value-of select="1"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="dangerous">
			<xsl:variable name="mod" select="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:dangerous_substance_information:xsd:3' and local-name()='dangerousSubstanceInformationModule']/dangerousSubstanceInformation/dangerousSubstanceProperties"/>
			<xsl:choose>
				<xsl:when test="$mod[string(dangerousSubstancePhaseOfMatterCode) != ''] or $mod[string(dangerousSubstanceGasDensity) != ''] or $mod[string(dangerousSubstancesWaterSolubilityCode) != ''] or $mod[angerousSubstanceWasteCode/enumerationValueInformation/enumerationValue]">
					<xsl:value-of select="1"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="ingredient">
			<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:safety_data_sheet:xsd:3' and local-name()='safetyDataSheetModule']/safetyDataSheetInformation/chemicalInformation/chemicalIngredient/chemicalIngredientIdentification) != ''">
				<xsl:value-of select="1"/>
			</xsl:if>
		</xsl:variable>
		<xsl:if test="$safety = 1 or $dangerous = 1 or $ingredient =  1">
			<xsl:variable name="regu" select="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:regulated_trade_item:xsd:3' and local-name()='regulatedTradeItemModule']/regulatoryInformation[regulatoryAct = 'GHS']"/>
			<xsl:choose>
				<xsl:when test="$regu and $regu[isTradeItemRegulationCompliant = 'TRUE']"/>
				<xsl:otherwise>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="2004" />
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

		<!--Rule 101970: If targetMarketCountryCode equals <Geographic> and gpcCategoryCode equals ('10005882', '10005886', '10005887', '10005888', '10005889', '10005900', '10005903', '10005911', '10005912', '10005918', '10005921', '10005922', '10005937', '10006079', '10006085', '10006097', '10006100', '10006161', '10006162', '10006163', '10006164', '10006165', '10006166', '10006190', '10006191', '10006192', '10006195', '10006267') then gradeCodeReference SHALL equal ('EXTRA', 'I', 'II' or 'NONE') and gradeCodeReference/@codeListName SHALL equal 'fruitsVegetablesGradeCodes'.-->
		<xsl:if test="contains('10005882, 10005886, 10005887, 10005888, 10005889, 10005900, 10005903, 10005911, 10005912, 10005918, 10005921, 10005922, 10005937, 10006079, 10006085, 10006097, 10006100, 10006161, 10006162, 10006163, 10006164, 10006165, 10006166, 10006190, 10006191, 10006192, 10006195, 10006267', $brick)">
			<xsl:variable name="mod" select="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:marketing_information:xsd:3' and local-name()='marketingInformationModule']/marketingInformation"/>
			<xsl:choose>
				<xsl:when test="$mod/gradeCodeReference = 'EXTRA' and $mod/gradeCodeReference/@codeListName = 'fruitsVegetablesGradeCodes'"/>
				<xsl:when test="$mod/gradeCodeReference = 'I' and $mod/gradeCodeReference/@codeListName = 'fruitsVegetablesGradeCodes'"/>
				<xsl:when test="$mod/gradeCodeReference = 'II' and $mod/gradeCodeReference/@codeListName = 'fruitsVegetablesGradeCodes'"/>
				<xsl:when test="$mod/gradeCodeReference = 'NONE' and $mod/gradeCodeReference/@codeListName = 'fruitsVegetablesGradeCodes'"/>
				<xsl:otherwise>
					<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="101970" />
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>

		</xsl:if>

		<!--Rule 101986: If targetMarketCountryCode equals <Geographic> and tradeItemUnitDescriptorCode equals ('PALLET' or 'MIXED_MODULE') and child item tradeItemUnitDescriptorCode does not equal ('PALLET' or 'MIXED_MODULE') then child item platformTypeCode SHALL NOT be used.-->
		<xsl:if test="tradeItemUnitDescriptorCode = 'PALLET' or tradeItemUnitDescriptorCode = 'MIXED_MODULE'">
			<xsl:for-each select="../catalogueItemChildItemLink/catalogueItem/tradeItem">
				<xsl:if test="string(tradeItemUnitDescriptorCode) != 'PALLET' and string(tradeItemUnitDescriptorCode) != 'MIXED_MODULE'">
					<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:packaging_information:xsd:3' and local-name()='packagingInformationModule']/packaging/platformTypeCode) != ''">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="101986" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r2069">
		<!--Rule 2069: There must be one iteration for language 'French'.-->
		<xsl:choose>
			<xsl:when test="@languageCode">
				<xsl:variable name="name" select="name()"/>
				<xsl:if test="count(../*[name() = $name and @languageCode = 'fr']) &lt; 1">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="2069" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*" mode="r2069"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="r102010">
		<xsl:param name="brick" />
		<!--Rule 102010: If targetMarketCountryCode equals <Geographic> and gpcCategoryCode is equal to ('10001678', '10001676', '10001680', '10000775', '10000669', '10000533', '10000534', '10000360', '10000778', '10000333', '10000361', '10000345', '10000346', '10000348', '10000834', '10000536', '10000383', '10003874', '10002501', '10005657', '10002462', '10005687', '10005198', '10000531', '10000746', '10000441', '10000423', '10000440', '10006234', '10000443', '10000426', '10000696', '10000697', '10000427', '10000703', '10005266', '10002423', '10003234', '10003221', '10004110', '10005168', '10005192', '10006378', '10005232', '10001685', '10001684', '10008397' or '10005233') then one iteration of regulationTypeCode SHALL equal 'EXPLOSIVES_PRECURSORS_REGISTRATION' and corresponding isTradeItemRegulationCompliant SHALL equal ('TRUE' or 'NOT_APPLICABLE').-->

		<xsl:if test="contains('10001678, 10001676, 10001680, 10000775, 10000669, 10000533, 10000534, 10000360, 10000778, 10000333, 10000361, 10000345, 10000346, 10000348, 10000834, 10000536, 10000383, 10003874, 10002501, 10005657, 10002462, 10005687, 10005198, 10000531, 10000746, 10000441, 10000423, 10000440, 10006234, 10000443, 10000426, 10000696, 10000697, 10000427, 10000703, 10005266, 10002423, 10003234, 10003221, 10004110, 10005168, 10005192, 10006378, 10005232, 10001685, 10001684, 10008397, 10005233', $brick)">
			<xsl:variable name="mod" select="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:regulated_trade_item:xsd:3' and local-name()='regulatedTradeItemModule']/regulatoryInformation"/>
			<xsl:choose>
				<xsl:when test="$mod[regulationTypeCode = 'EXPLOSIVES_PRECURSORS_REGISTRATION']">
					<xsl:choose>
						<xsl:when test="$mod[regulationTypeCode = 'EXPLOSIVES_PRECURSORS_REGISTRATION' and (isTradeItemRegulationCompliant  = 'TRUE' or isTradeItemRegulationCompliant  = 'NOT_APPLICABLE')]"/>
						<xsl:otherwise>
							<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="102010" />
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="102010" />
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
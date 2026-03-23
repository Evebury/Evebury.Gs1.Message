<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:trade_item_hierarchy:xsd:3' and local-name()='tradeItemHierarchyModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="tradeItemHierarchy" mode="tradeItemHierarchyModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
			<xsl:with-param name="tradeItem" select="$tradeItem"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="tradeItemHierarchy" mode="tradeItemHierarchyModule">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:if test="isTradeItemPackedIrregularly = 'FALSE'">

			<xsl:variable name="total" select="$tradeItem/nextLowerLevelTradeItemInformation/totalQuantityOfNextLowerLevelTradeItem"/>

			<!--Rule 446: If isTradeItemPackedIrregularly equals ‘FALSE’ and tradeItemCompositionWidth, tradeItemCompositionDepth and quantityOfCompleteLayersContainedInATradeItem are all supplied and tradeItemCompositionWidth/measurementUnitCode and tradeItemCompositionDepth/measurementUnitCode equal ‘EA’ then the product of the three attributes should equal the totalQuantityOfNextLowerLevelTradeItem.-->
			<xsl:variable name="measurements" select="$tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_measurements:xsd:3' and local-name()='tradeItemMeasurementsModule']/tradeItemMeasurements"/>
			<xsl:if test="$measurements">
				<xsl:variable name="depth" select="$measurements/tradeItemCompositionDepth"/>
				<xsl:variable name="width" select="$measurements/tradeItemCompositionWidth"/>
				<xsl:if test="$depth * $width * quantityOfCompleteLayersContainedInATradeItem != $total">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="446"/>
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>

			<!--Rule 473: If isTradeItemPackedIrregularly is equal to 'FALSE' and quantityOfCompleteLayersContainedInATradeItem is used and quantityOfTradeItemsContainedInACompleteLayer is used then totalQuantityOfNextLowerLevelTradeItem must equal quantityOfCompleteLayersContainedInATradeItem multiplied by value in quantityOfTradeItemsContainedInACompleteLayer.-->
			<xsl:if test="quantityOfCompleteLayersContainedInATradeItem * quantityOfTradeItemsContainedInACompleteLayer != $total">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="473"/>
				</xsl:apply-templates>
			</xsl:if>

		</xsl:if>

		<!--Rule 481: If targetMarketCountryCode equals <Geographic> and quantityOfLayersPerPallet is used then quantityOfLayersPerPallet SHALL be less than 999.-->
		<xsl:if test="contains('056, 442, 528', $targetMarket)">
			<xsl:if test="quantityOfLayersPerPallet != '' and quantityOfLayersPerPallet &gt;= 999">
				<xsl:apply-templates select="quantityOfLayersPerPallet" mode="error">
					<xsl:with-param name="id" select="481"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<!--Rule 519: If  targetMarketCountryCode is equal to '752' (Sweden) and layerHeight is not empty then value must equal child item width, depth or height.-->
		<xsl:if test="$targetMarket = '752'">
			<xsl:if test="string(layerHeight) != ''">
				<xsl:variable name="value">
					<xsl:apply-templates select="layerHeight" mode="measurementUnit"/>
				</xsl:variable>
				<xsl:variable name="height">
					<xsl:apply-templates select="$tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_measurements:xsd:3' and local-name()='tradeItemMeasurementsModule']/tradeItemMeasurements/height" mode="measurementUnit"/>
				</xsl:variable>
				<xsl:if test="$value != $height">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="519" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<!--Rule 530: If targetMarketCountryCode equals <Geographic> and quantityOfTradeItemsPerPalletLayer is used then quantityOfLayersPerPallet SHALL be used..-->
		<xsl:if test="string(quantityOfTradeItemsPerPalletLayer) != ''">
			<xsl:if test="contains('036, 348, 528, 056, 442, 380, 554', $targetMarket)">
				<xsl:if test="string(quantityOfLayersPerPallet) = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="530" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<!--Rule 576: If  isNonGTINLogisticsUnitPackedIrregularly is equal to 'false' then quantityOfTradeItemsPerPallet shall equal quantityOfLayersPerPallet multiplied by quantityOfTradeItemsPerPalletLayer.-->
		<xsl:if test="isNonGTINLogisticsUnitPackedIrregularly = 'false'">
			<xsl:if test="quantityOfLayersPerPallet * quantityOfTradeItemsPerPalletLayer != quantityOfTradeItemsPerPallet">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="576" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
		<!--Rule 585: If targetMarketCountryCode equals ('036' (Australia),'348' (Hungary),'554' (New Zealand),'528' (Netherlands),'056' (Belgium) or'442' (Luxembourg)) and quantityOfLayersPerPallet is greater than zero then quantityOfTradeItemsPerPalletLayer shall be greater than zero.-->
		<xsl:if test="contains('036, 554, 348, 528, 056, 442', $targetMarket)">
			<xsl:if test="string(quantityOfLayersPerPallet) != '' and quantityOfLayersPerPallet &gt; 0">
				<xsl:if test="string(quantityOfTradeItemsPerPalletLayer) = '' or quantityOfTradeItemsPerPalletLayer &lt;= 0">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="585" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<!--Rule 1646: If targetMarketCountryCode equals <Geographic> and tradeItemUnitDescriptorCode does not equal ('PALLET' or 'MIXED_MODULE') then quantityOfCompleteLayersContainedInATradeItem SHALL NOT be used.-->
		<xsl:if test="contains('056, 442, 528, 276, 208, 203, 246, 826, 380, 250, 040, 756', $targetMarket)">
			<xsl:if test="string($tradeItem/tradeItemUnitDescriptorCode) != 'PALLET' and string($tradeItem/tradeItemUnitDescriptorCode) != 'MIXED_MODULE'">
				<xsl:if test="string(quantityOfCompleteLayersContainedInATradeItem) != ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1646" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<!--Rule 1647: If targetMarketCountryCode equals <Geographic> and tradeItemUnitDescriptorCode does not equal ('PALLET' or 'MIXED_MODULE') then quantityOfTradeItemsContainedInACompleteLayer SHALL NOT be used.-->
		<xsl:if test="contains('056, 442, 528, 208, 203, 380, 756', $targetMarket)">
			<xsl:if test="string($tradeItem/tradeItemUnitDescriptorCode) != 'PALLET' and string($tradeItem/tradeItemUnitDescriptorCode) != 'MIXED_MODULE'">
				<xsl:if test="string(quantityOfTradeItemsContainedInACompleteLayer) != ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1647" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<!--Rule 1648: If targetMarketCountryCode equals (056 (Belgium), 442 (Luxembourg), 528 (Netherlands), 208 (Denmark), 203 (Czech Republic), 246 (Finland) or 380 (Italy)) and tradeItemUnitDescriptorCode equals 'PALLET', then quantityOfTradeItemsPerPalletLayer SHALL NOT be used. -->
		<xsl:if test="contains('056, 442, 528, 208, 203, 246, 380', $targetMarket)">
			<xsl:if test="$tradeItem/tradeItemUnitDescriptorCode = 'PALLET'">
				<xsl:if test="string(quantityOfTradeItemsPerPalletLayer) != ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1648" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		
		<xsl:if test="contains('056, 442, 276, 528, 208, 203, 246, 380, 250, 040', $targetMarket)">
			<!--Rule 1649: If targetMarketCountryCode equals (056 (Belgium), 442 (Luxembourg), 276 (Germany), 528 (Netherlands), 208 (Denmark), 203 (Czech Republic), 246 (Finland), 380 (Italy), 250 (France) or 040 (Austria)) and tradeItemUnitDescriptorCode equals 'PALLET', then quantityOfTradeItemsPerPallet SHALL NOT be used.-->
			<xsl:if test="$tradeItem/tradeItemUnitDescriptorCode = 'PALLET'">
				<xsl:if test="string(quantityOfTradeItemsPerPallet) != ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1649" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
			<!--Rule 1650: If targetMarketCountryCode equals (056 (Belgium), 442 (Luxembourg), 276 (Germany), 528 (Netherlands), 208 (Denmark), 203 (Czech Republic), 246 (Finland), 380 (Italy), 250 (France) or 040 (Austria)) and tradeItemUnitDescriptorCode equals 'PALLET', then quantityOfLayersPerPallet SHALL NOT be used.-->
			<xsl:if test="$tradeItem/tradeItemUnitDescriptorCode = 'PALLET'">
				<xsl:if test="string(quantityOfLayersPerPallet) != ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1650" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>


		<!--Rule 1740: If targetMarketCountryCode equals <Geographic> and tradeItemUnitDescriptorCode equals 'PALLET' and (isTradeItemPackedIrregularly equals 'FALSE' or is not used) then quantityOfCompleteLayersContainedInATradeItem SHALL be greater than 0 (zero).-->
		<xsl:if test="contains('056, 203, 246, 380, 442, 528', $targetMarket)">
			<xsl:if test="$tradeItem/tradeItemUnitDescriptorCode = 'PALLET' and (isTradeItemPackedIrregularly = 'FALSE' or string(isTradeItemPackedIrregularly) = '')">
				<xsl:if test="string(quantityOfCompleteLayersContainedInATradeItem) = '' or quantityOfCompleteLayersContainedInATradeItem &lt;= 0">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1740" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<!--Rule 1743: If targetMarketCountryCode equals <Geographic> and (quantityOfTradeItemsPerPallet is used or quantityOfLayersPerPallet is used or quantityOfTradeItemsPerPalletLayer is used) then at least one iteration of platformTypeCode SHALL be used.-->
		<xsl:if test="string(quantityOfTradeItemsPerPallet) != '' or string(quantityOfTradeItemsPerPalletLayer) != '' or string(quantityOfLayersPerPallet) != ''">
			<xsl:if test="contains('056, 246, 442, 528', $targetMarket)">
				<xsl:if test="count($tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:packaging_information:xsd:3' and local-name()='packagingInformationModule']/packaging[platformTypeCode != '']) = 0">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1743" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<!--Rule 1921: If targetMarketCountryCode equals <Geographic> and (isTradeItemPackedIrregularly equals 'FALSE' or is not used) and quantityOfCompleteLayersContainedInATradeItem is used and quantityOfTradeItemsContainedInACompleteLayer is used then totalQuantityOfNextLowerLevelTradeItem SHALL equal quantityOfCompleteLayersContainedInATradeItem multiplied by quantityOfTradeItemsContainedInACompleteLayer.-->
		<xsl:if test="contains('380, 124, 840', $targetMarket)">
			<xsl:if test="(isTradeItemPackedIrregularly = 'FALSE' or string(isTradeItemPackedIrregularly) = '') and string(quantityOfCompleteLayersContainedInATradeItem) != '' and string(quantityOfTradeItemsContainedInACompleteLayer) != ''">
				<xsl:variable name="quantity" select="$tradeItem/nextLowerLevelTradeItemInformation/totalQuantityOfNextLowerLevelTradeItem"/>
				<xsl:if test="string($quantity) = '' or ($quantity != quantityOfCompleteLayersContainedInATradeItem * quantityOfTradeItemsContainedInACompleteLayer)">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1921" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<xsl:if test="isNonGTINLogisticsUnitPackedIrregularly = 'FALSE' or string(isNonGTINLogisticsUnitPackedIrregularly) = ''">

			<!--Rule 1928: If targetMarketCountryCode equals <Geographic> and (isNonGTINLogisticsUnitPackedIrregularly equals 'FALSE' or is not used) and quantityOfLayersPerPallet is used and quantityOfTradeItemsPerPalletLayer is used then quantityOfTradeItemsPerPallet SHALL equal quantityOfLayersPerPallet multiplied by quantityOfTradeItemsPerPalletLayer.-->
			<xsl:if test="contains('380, 124, 840', $targetMarket)">
				<xsl:if test="string(quantityOfLayersPerPallet) != '' and string(quantityOfTradeItemsPerPalletLayer) != ''">
					<xsl:if test="quantityOfTradeItemsPerPallet != quantityOfLayersPerPallet * quantityOfTradeItemsPerPalletLayer">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1928" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:if>
			</xsl:if>
			
			<xsl:if test="$targetMarket  = '380'">

				<!--Rule 1925: If targetMarketCountryCode equals <Geographic> and (isNonGTINLogisticsUnitPackedIrregularly equals 'FALSE' or is not used) and quantityOfLayersPerPallet is used then quantityOfTradeItemsPerPalletLayer SHALL be used.-->
				<xsl:if test="string(quantityOfLayersPerPallet) != '' and string(quantityOfTradeItemsPerPalletLayer) = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1925" />
					</xsl:apply-templates>
				</xsl:if>

				<!--Rule 101924: If targetMarketCountryCode equals <Geographic> and (isNonGTINLogisticsUnitPackedIrregularly equals 'FALSE' or is not used) and (nonGTINLogisticsUnitInformation/depth is used or nonGTINLogisticsUnitInformation/width is used or nonGTINLogisticsUnitInformation/height is used or nonGTINLogisticsUnitInformation/grossWeight is used or quantityOfLayersPerPallet is used or quantityOfTradeItemsPerPalletLayer is used or quantityOfTradeItemsPerPallet is used) then nonGTINLogisticsUnitInformation/depth and nonGTINLogisticsUnitInformation/width and nonGTINLogisticsUnitInformation/height and nonGTINLogisticsUnitInformation/grossWeight and quantityOfLayersPerPallet and quantityOfTradeItemsPerPalletLayer and quantityOfTradeItemsPerPallet SHALL be used.-->
				<xsl:if test="(string(quantityOfLayersPerPallet) != '' or string(quantityOfTradeItemsPerPalletLayer) != '' or string(quantityOfTradeItemsPerPalletLayer) != '') and (string(quantityOfLayersPerPallet) = '' or string(quantityOfTradeItemsPerPalletLayer) = '' or string(quantityOfTradeItemsPerPalletLayer) = '')">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="101924" />
					</xsl:apply-templates>
				</xsl:if>
				<xsl:variable name="nongtin" select="$tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:nongtin_logistics_unit_information:xsd:3' and local-name()='nonGTINLogisticsUnitInformationModule']/nonGTINLogisticsUnitInformation"/>
				<xsl:if test="$nongtin and (string($nongtin/depth) != '' or string($nongtin/width) !='' or string($nongtin/height) != '' or string($nongtin/grossWeigth) != '') and (string($nongtin/depth) = '' or string($nongtin/width) ='' or string($nongtin/height) = '' or string($nongtin/grossWeigth) = '')">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="101924" />
					</xsl:apply-templates>
				</xsl:if>
			
				
				
			</xsl:if>
		</xsl:if>

		<xsl:if test="isTradeItemPackedIrregularly = 'FALSE' or string(isTradeItemPackedIrregularly) = ''">

			<xsl:if test="$targetMarket  = '380'">
				
				<!--Rule 1926: If targetMarketCountryCode equals <Geographic> and tradeItemUnitDescriptorCode equals 'PALLET' and (isTradeItemPackedIrregularly equals 'FALSE' or is not used) then quantityOfTradeItemsContainedInACompleteLayer SHALL be greater than 0 (zero).-->
				<xsl:if test="$tradeItem/tradeItemUnitDescriptorCode  = 'PALLET'">
					<xsl:if test="string(quantityOfTradeItemsContainedInACompleteLayer) = '' or quantityOfTradeItemsContainedInACompleteLayer &lt;= 0">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1926" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:if>
				
				
			</xsl:if>

		</xsl:if>


		<xsl:if test="$targetMarket = '756'">
			<!--Rule 1968: If targetMarketCountryCode equals <Geographic> and quantityOfTradeItemsContainedInACompleteLayer is used then tradeItemUnitDescriptorCode SHALL equal ('PALLET' or 'MIXED_MODULE').-->
			<xsl:if test="string(quantityOfTradeItemsContainedInACompleteLayer) != ''">
				<xsl:if test="string($tradeItem/tradeItemUnitDescriptorCode) != 'PALLET' and string($tradeItem/tradeItemUnitDescriptorCode) != 'MIXED_MODULE'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1968" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
			<!--Rule 1969: If targetMarketCountryCode equals <Geographic> and quantityOfTradeItemsPerPalletLayer is used then tradeItemUnitDescriptorCode SHALL NOT equal ('PALLET' or 'MIXED_MODULE') and isTradeItemADespatchUnit SHALL equal 'true'.-->
			<xsl:if test="string(quantityOfTradeItemsPerPalletLayer) != ''">
				<xsl:if test="$tradeItem/tradeItemUnitDescriptorCode = 'PALLET' or $tradeItem/tradeItemUnitDescriptorCode = 'MIXED_MODULE' or string($tradeItem/isTradeItemADespatchUnit) != 'true'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1969" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>
		

	</xsl:template>

</xsl:stylesheet>
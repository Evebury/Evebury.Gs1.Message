<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:trade_item_measurements:xsd:3' and local-name()='tradeItemMeasurementsModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>
		<xsl:param name="component"/>
		<xsl:apply-templates select="tradeItemMeasurements" mode="tradeItemMeasurementsModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
			<xsl:with-param name="tradeItem" select="$tradeItem"/>
			<xsl:with-param name="component" select="$component"/>
		</xsl:apply-templates>


	</xsl:template>

	<xsl:template match="tradeItemMeasurements" mode="tradeItemMeasurementsModule">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>
		<xsl:param name="component"/>
		<xsl:variable name="netWeightValue" select="tradeItemWeight/netWeight"/>
		<xsl:variable name="grossWeightValue" select="tradeItemWeight/grossWeight"/>

		<!--Rule 98: If specialItemCode does not equal 'DYNAMIC_ASSORTMENT' and parent trade item netWeight and child trade item netWeight are used then parent netWeight shall  be greater than or equal to the sum of (netweight multiplied by quantityOfNextLowerLevelTradeItem) of each child item.-->
		<xsl:if test="string($tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:marketing_information:xsd:3' and local-name()='marketingInformationModule']/marketingInformation/specialItemCode) != 'DYNAMIC_ASSORTMENT'">
			<xsl:choose>
				<xsl:when test="$component">
					<!-- Todo? check tradeitem net weight and all component netweights?-->
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="$netWeightValue = number($netWeightValue)">

						<xsl:variable name="netWeight">
							<xsl:apply-templates select="$netWeightValue" mode="measurementUnit"/>
						</xsl:variable>

						<xsl:variable name="childNetWeight">
							<xsl:call-template name="r98">
								<xsl:with-param name="items" select="$tradeItem/../catalogueItemChildItemLink" />
							</xsl:call-template>
						</xsl:variable>

						<xsl:if test="$childNetWeight &gt; $netWeight">
							<xsl:apply-templates select="$netWeightValue" mode="error">
								<xsl:with-param name="id" select="98"/>
							</xsl:apply-templates>
						</xsl:if>

					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
	
		</xsl:if>


		<!--Rule 201: If grossWeight is not empty and netWeight is not empty then grossWeight must be greater than or equal to netWeight.-->
		<xsl:if test="$grossWeightValue = number($grossWeightValue) and $netWeightValue = number($netWeightValue)">

			<xsl:variable name="grossWeight">
				<xsl:apply-templates select="$grossWeightValue" mode="measurementUnit"/>
			</xsl:variable>

			<xsl:variable name="netWeight">
				<xsl:apply-templates select="$netWeightValue" mode="measurementUnit"/>
			</xsl:variable>

			<xsl:if test="$netWeight &gt; $grossWeight">
				<xsl:apply-templates select="$grossWeightValue" mode="error">
					<xsl:with-param name="id" select="201"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<!--Rule 362: If a minimum and corresponding maximum are not empty then the minimum SHALL be less than or equal to the corresponding maximum.-->
		<xsl:if test="gs1:InvalidRange(individualUnitMinimumSize,individualUnitMaximumSize)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="362"/>
			</xsl:apply-templates>
		</xsl:if>

		<!--Rule 478: If nestingIncrement is not empty then value must be greater than 0.-->
		<xsl:for-each select="tradeItemNesting/nestingIncrement">
			<xsl:if test=". != '' and . &lt;= 0">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="478"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>

		<!--Rule 515: If  grossWeight is not empty then value shall be greater than or equal to 0.-->
		<xsl:if test="string($grossWeightValue) != '' and $grossWeightValue &lt; 0">
			<xsl:apply-templates select="$grossWeightValue" mode="error">
				<xsl:with-param name="id" select="515" />
			</xsl:apply-templates>
		</xsl:if>

		<!--Rule 516: If netWeight is not empty then value must be greater than 0.-->
		<xsl:if test="string(netWeightValue) != '' and netWeightValue &lt; 0">
			<xsl:apply-templates select="netWeightValue" mode="error">
				<xsl:with-param name="id" select="516" />
			</xsl:apply-templates>
		</xsl:if>

		<!--Rule 539: If grossWeight is used and netContent/measurementUnitCode is a weight then grossWeight shall be greater than or equal to netContent.-->
		<xsl:if test="string($grossWeightValue) != ''">
			<xsl:if test="string(netContent) != ''">
				<xsl:variable name="type">
					<xsl:apply-templates select="netContent" mode="measurementUnitType"/>
				</xsl:variable>
				<xsl:if test="$type = 'Weight'">
					<xsl:variable name="grossWeight">
						<xsl:apply-templates select="$grossWeightValue" mode="measurementUnit"/>
					</xsl:variable>
					<xsl:variable name="netContentWeight">
						<xsl:apply-templates select="netContent" mode="measurementUnit"/>
					</xsl:variable>
					<xsl:if test="$netContentWeight &gt; $grossWeight">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="539" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<!--Rule 543: If individualUnitMinimumSize and/or individualUnitMaximumSize are not empty then isTradeItemABaseUnit must equal 'true'.-->
		<!--Rule 544: If isTradeItemABaseUnit is equal to 'false' then individualUnitMinimumSize and individualUnitMaximumSize must be empty.-->
		<xsl:if test="string(individualUnitMaximumSize) != '' and string(individualUnitMinimumSize) != ''">
			<xsl:if test="string($tradeItem/isTradeItemABaseUnit) != 'true'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="544" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<!--Rule 613: If freeQuantityOfProduct and netContent are both used, then freeQuantityOfProduct shall be less than or equal to netContent, when expressed in the same measurementUnitCode.-->
		<xsl:if test="string(netContent) != ''">
			<xsl:variable name="freeQuantityOfProduct" select="$tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:promotional_item_information:xsd:3' and local-name()='promotionalItemInformationModule']/promotionalItemInformation/freeQuantityOfProduct"/>
			<xsl:if test="string($freeQuantityOfProduct) != ''">
				<xsl:variable name="netContentType">
					<xsl:apply-templates select="netContent" mode="measurementUnitType"/>
				</xsl:variable>
				<xsl:variable name="freeQuantityOfProductType">
					<xsl:apply-templates select="$freeQuantityOfProduct" mode="measurementUnitType"/>
				</xsl:variable>
				<xsl:if test="$netContentType = $freeQuantityOfProductType">
					<xsl:variable name="netContentValue">
						<xsl:apply-templates select="netContent" mode="measurementUnit"/>
					</xsl:variable>
					<xsl:variable name="freeQuantityOfProductValue">
						<xsl:apply-templates select="netContent" mode="measurementUnit"/>
					</xsl:variable>
					<xsl:if test="$freeQuantityOfProductValue &gt; $netContentValue">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="613" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<!--Rule 616: if drainedWeight and netWeight are not empty then drainedWeight must be less than or equal to netWeight.-->
		<xsl:if test="string(tradeItemWeight/drainedWeight) != '' and string($netWeightValue) != ''">
			<xsl:variable name="netWeight">
				<xsl:apply-templates select="$netWeightValue" mode="measurementUnit"/>
			</xsl:variable>
			<xsl:variable name="drainedWeight">
				<xsl:apply-templates select="tradeItemWeight/drainedWeight" mode="measurementUnit"/>
			</xsl:variable>
			<xsl:if test="$drainedWeight &gt; $netWeight">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="616" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<!--Rule 1017: if drainedWeight and grossWeight are not empty then drainedWeight must be less than or equal to grossWeight.-->
		<xsl:if test="string(tradeItemWeight/drainedWeight) != '' and string($grossWeightValue) != ''">
			<xsl:variable name="grossWeight">
				<xsl:apply-templates select="$grossWeightValue" mode="measurementUnit"/>
			</xsl:variable>
			<xsl:variable name="drainedWeight">
				<xsl:apply-templates select="tradeItemWeight/drainedWeight" mode="measurementUnit"/>
			</xsl:variable>
			<xsl:if test="$drainedWeight &gt; $grossWeight">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1017" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<!--Rule 1108: If (netWeight or drainedWeight or grossWeight ) is not empty, then the associated measurementUnitCode shall be from the Unit Of Measure Classification 'MASS'-->
		<xsl:if test="string($netWeightValue) != ''">
			<xsl:variable name="type">
				<xsl:apply-templates select="$netWeightValue" mode="measurementUnitType"/>
			</xsl:variable>
			<xsl:if test="$type != 'Weight'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1108" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
		<xsl:if test="string($grossWeightValue) != ''">
			<xsl:variable name="type">
				<xsl:apply-templates select="$grossWeightValue" mode="measurementUnitType"/>
			</xsl:variable>
			<xsl:if test="$type != 'Weight'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1108" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
		<xsl:if test="string(tradeItemWeight/drainedWeight) != ''">
			<xsl:variable name="type">
				<xsl:apply-templates select="tradeItemWeight/drainedWeight" mode="measurementUnitType"/>
			</xsl:variable>
			<xsl:if test="$type != 'Weight'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1108" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<!--Rule 1109: If (tradeItemMeasurements/height or tradeItemMeasurements/depth or tradeItemMeasurements/width ) is used, then the associated measurementUnitCode shall be from the Unit Of Measure Classification 'DIMENSIONS'-->
		<xsl:if test="string(depth) != ''">
			<xsl:variable name="type">
				<xsl:apply-templates select="depth" mode="measurementUnitType"/>
			</xsl:variable>
			<xsl:if test="$type != 'Length'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1109" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
		<xsl:if test="string(width) != ''">
			<xsl:variable name="type">
				<xsl:apply-templates select="width" mode="measurementUnitType"/>
			</xsl:variable>
			<xsl:if test="$type != 'Length'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1109" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<!--Rule 1112: If targetMarketCountryCode equals '250' (France) and tradeItemUnitDescriptorCode equals'PALLET', then TradeItemMeasurements/height shall be less than or equal to '3 MTR'.-->
		<xsl:if test="$targetMarket = '250'">
			<xsl:if test="$tradeItem/tradeItemUnitDescriptorCode  = 'PALLET' and string(height) != ''">
				<xsl:variable name="height">
					<xsl:apply-templates select="height" mode="measurementUnit"/>
				</xsl:variable>
				<xsl:if test="$height &gt; 300">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1112" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<xsl:if test="$targetMarket = '249' or $targetMarket = '250'">
			<!--Rule 1113: If targetMarketCountryCode equals ('249' (France) or '250' (France)) and (TradeItemMeasurements/height or TradeItemMeasurements/width or TradeItemMeasurements/depth) is not empty and the associated measurementUnitCode equals 'MTR', then its associated value shall not have more than 3 decimal positions.-->
			<xsl:apply-templates select="." mode="tradeItemMeasurementsModule_decimals">
				<xsl:with-param name="decimals" select="3"/>
				<xsl:with-param name="unit" select="'MTR'"/>
				<xsl:with-param name="error" select="1113"/>
			</xsl:apply-templates>
			<!--Rule 1114: If targetMarketCountryCode equals ('249' (France) or '250' (France)) and (TradeItemMeasurements/height or TradeItemMeasurements/width or TradeItemMeasurements/depth) is not empty and the associated measurementUnitCode equals ''CMT', then its associated value shall not have more than 1 decimal position.-->
			<xsl:apply-templates select="." mode="tradeItemMeasurementsModule_decimals">
				<xsl:with-param name="decimals" select="1"/>
				<xsl:with-param name="unit" select="'CMT'"/>
				<xsl:with-param name="error" select="1114"/>
			</xsl:apply-templates>
			<!--Rule 1115: If targetMarketCountryCode equals ('249' (France) or '250' (France)) and (TradeItemMeasurements/height or TradeItemMeasurements/width or TradeItemMeasurements/depth) is not empty and the associated measurementUnitCode equals ''MMT'', then its associated value shall not have a decimal position.-->
			<xsl:apply-templates select="." mode="tradeItemMeasurementsModule_decimals">
				<xsl:with-param name="decimals" select="0"/>
				<xsl:with-param name="unit" select="'MMT'"/>
				<xsl:with-param name="error" select="1115"/>
			</xsl:apply-templates>
		</xsl:if>

		<!--Rule 1601: If targetMarketCountryCode equals <Geographic> and gpcCategoryCode does not equal gpc and isTradeItemAConsumerUnit equals 'true' then netContent SHALL be used.-->
		<xsl:if test="$targetMarket = '056' or $targetMarket = '442' or $targetMarket = '528'">
			<xsl:if test="$tradeItem/isTradeItemAConsumerUnit = 'true'">
				<xsl:variable name="brick" select="$tradeItem/gDSNTradeItemClassification/gpcCategoryCode"/>
				<xsl:choose>
					<xsl:when test="contains('10000458, 10000570, 10000686, 10000915, 10000456, 10000457, 10000681, 10000912, 10000922, 10000448, 10000449, 10000450, 10000451, 10000684, 10000908, 10000909, 10000910, 10000474, 10000488, 10000489, 10000685, 10000907, 10000459, 10000682, 10000690, 10000487, 10000525, 10000526, 10000527, 10000528, 10000529, 10000637, 10000638, 10000639, 10000687, 10000688, 10000689, 10000911, 10000500, 10000504, 10000683, 10000846, 10000847, 10000848, 10000849, 10000850, 10000851, 10000852, 10000923, 10000853, 10000854, 10000855, 10000856, 10000857, 10000858, 10000859, 10000860, 10000861, 10000862, 10000914, 10000863, 10000864, 10000865, 10000866, 10000867, 10000868, 10000869, 10000870, 10000871, 10000872, 10000873, 10000874, 10000919, 10000875, 10000876, 10000877, 10000878, 10000879, 10000880, 10000881, 10000882, 10000883, 10000884, 10000916, 10000920, 10000885, 10000886, 10000887, 10000888, 10000889, 10000890, 10000891, 10000892, 10000893, 10000903, 10000904, 10000905, 10000906, 10000894, 10000895, 10000896, 10000897, 10000898, 10000899, 10000900, 10000901, 10000902, 10000921, 10002423, 10000460, 10000461, 10000462, 10000674, 10000838, 10000463, 10000464, 10000675, 10000455, 10000843, 10000452, 10000453, 10000454, 10000648, 10000844, 10000647, 10000673, 10005844, 10006412, 10005845, 10000514', $brick)"/>
					<xsl:otherwise>
						<xsl:if test="string(netContent) = ''">
							<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="1601" />
							</xsl:apply-templates>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:if>

		<!--Rule 1637: If  targetMarketCountrycode equals '826' (United Kingdom) and displayTypeCode equals 'SDR' (Shelf Display Ready Packaging), then frontFaceTypeCode shall be used.-->
		<xsl:if test="$targetMarket = '826'">
			<xsl:if test="$tradeItem/displayUnitInformation/displayTypeCode = 'SDR'">
				<xsl:if test="string(frontFaceTypeCode) = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1637" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<!--Rule 1655: If targetMarketCountryCode equals (056 (Belgium), 442 (Luxembourg), 528 (Netherlands), 250 (France), 208 (Denmark), 203 (Czech Republic), 246 (Finland), 826 (UK), or 380 (Italy)) and isTradeItemNonphysical, does not equal 'true' or is not populated and isTradeItemAConsumerUnit equals 'false' and TradeItemMeasurements/depth is used and TradeItemMeasurements/width is used, then TradeItemMeasurements/depth SHALL be greater than or equal to TradeItemMeasurements/width. -->
		<xsl:if test="contains('056, 442, 528, 208, 203, 250, 246, 380, 826', $targetMarket)">
			<xsl:if test="string($tradeItem/isTradeItemNonphysical) != 'true' and $tradeItem/isTradeItemAConsumerUnit = 'false'">
				<xsl:if test="string(depth) != '' and string(width) != ''">
					<xsl:variable name="v1">
						<xsl:apply-templates select="depth" mode="measurementUnit"/>
					</xsl:variable>
					<xsl:variable name="v2">
						<xsl:apply-templates select="width" mode="measurementUnit"/>
					</xsl:variable>
					<xsl:if test="$v2 &gt; $v1">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1655" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<!--Rule 1657: If multiple iterations of pegHoleNumber are used, then no two iterations SHALL be equal.-->
		<xsl:if test="pegMeasurements">
			<xsl:variable name="parent" select="."/>
			<xsl:for-each select="pegMeasurements/pegHoleNumber">
				<xsl:variable name="value" select="."/>
				<xsl:if test="count($parent/pegMeasurements[pegHoleNumber = $value]) &gt; 1">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1657" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>

		<!--Rule 1756: If targetMarketCountryCode equals Geographic and drainedWeight is used, then the drainedWeight unit of measurement SHALL equal one of the following values: 'KGM' or 'GRM'.-->
		<xsl:if test="tradeItemWeight/drainedWeight != ''">
			<xsl:if test="contains('008, 051, 031, 112, 056, 070, 040, 100, 191, 196, 203, 208, 233, 246, 250, 276, 268, 300, 348, 352, 372, 376, 380, 398, 417, 428, 440, 442, 807, 498, 499, 528, 578, 616, 620, 642, 643, 688, 703, 705, 752, 756, 792, 795, 826, 804, 860', $targetMarket)">
				<xsl:choose>
					<xsl:when test="tradeItemWeight/drainedWeight[@measurementUnitCode = 'KGM' or @measurementUnitCode ='GRM']"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1756" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:if>

		<!--Rule 1775: If drainedWeight is used, then drainedWeight SHALL be greater than 0.-->
		<xsl:if test="string(tradeItemWeight/drainedWeight) != '' and tradeItemWeight/drainedWeight &lt;= 0">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1775" />
			</xsl:apply-templates>
		</xsl:if>


		<xsl:if test="$targetMarket  = '756'">
			<xsl:for-each select="tradeItemNesting">

				<!--Rule 1949: If targetMarketCountryCode equals <Geographic> and nestingIncrement is used then at least one of nestingTypeCode or nestingDirectionCode SHALL be used.-->
				<xsl:if test="string(nestingIncrement) != '' and string(nestingTypeCode) ='' and string(nestingDirectionCode) =''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1949" />
					</xsl:apply-templates>
				</xsl:if>

				<!--Rule 1950: If targetMarketCountryCode equals <Geographic> and (nestingTypeCode or nestingDirectionCode is used) then nestingIncrement SHALL be used.-->
				<xsl:if test="string(nestingIncrement) = '' and (string(nestingTypeCode) !='' or string(nestingDirectionCode) !='')">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1950" />
					</xsl:apply-templates>
				</xsl:if>
				
			</xsl:for-each>

			<!--Rule 1957: If targetMarketCountryCode equals <Geographic> and quantityOfChildren is greater than 1 and netContent is used then netContent/@measurementUnitCode SHALL equal 'H87' (Piece).-->
			<xsl:if test="$tradeItem/nextLowerLevelTradeItemInformation/quantityOfChildren &gt; 1">
				<xsl:if test="string(netContent) != '' and netContent/@measurementUnitCode != 'H87'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1957" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>

			<!--Rule 1958: If targetMarketCountryCode equals <Geographic> and quantityOfChildren is greater than 1 and netContent is used then netContent SHALL equal totalQuantityOfNextLowerLevelTradeItem.-->
			<xsl:if test="$tradeItem/nextLowerLevelTradeItemInformation/quantityOfChildren &gt; 1">
				<xsl:if test="string(netContent) != '' and netContent != $tradeItem/nextLowerLevelTradeItemInformation/quantityOfChildren">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1958" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>

			<!--Rule 1967: If targetMarketCountryCode equals <Geographic> and pegHoleNumber is used then pegHoleTypeCode SHALL be used.-->
			<xsl:for-each select="pegMeasurements">
				<xsl:if test="string(pegHoleNumber) != '' and string(pegHoleTypeCode) = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1967" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:for-each>
			
		</xsl:if>
		
		
	</xsl:template>


	<xsl:template match="tradeItemMeasurements" mode="tradeItemMeasurementsModule_decimals">
		<xsl:param name="unit"/>
		<xsl:param name="decimals"/>
		<xsl:param name="error"/>
		<xsl:if test="string(height[@measurementUnitCode = $unit]) != ''">
			<xsl:if test="contains(height[@measurementUnitCode = $unit], '.')">
				<xsl:if test="string-length(substring-after(height[@measurementUnitCode = $unit], '.')) &gt; $decimals">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="$error" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>
		<xsl:if test="string(width[@measurementUnitCode = $unit]) != ''">
			<xsl:if test="contains(width[@measurementUnitCode = $unit], '.')">
				<xsl:if test="string-length(substring-after(width[@measurementUnitCode = $unit], '.')) &gt; $decimals">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="$error" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>
		<xsl:if test="string(depth[@measurementUnitCode = $unit]) != ''">
			<xsl:if test="contains(depth[@measurementUnitCode = $unit], '.')">
				<xsl:if test="string-length(substring-after(depth[@measurementUnitCode = $unit], '.')) &gt; $decimals">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="$error" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>

	</xsl:template>

	<xsl:template name="r98">
		<xsl:param name="items"/>
		<xsl:param name="index" select="1"/>
		<xsl:param name="count" select="count(msxsl:node-set($items))"/>
		<xsl:param name="weight" select="0"/>
		<xsl:choose>
			<xsl:when test="$index &lt;= $count">
				<xsl:variable name="item" select="msxsl:node-set($items)[$index]"/>

				<xsl:variable name="value" select="$item/catalogueItem/tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_measurements:xsd:3' and local-name()='tradeItemMeasurementsModule']/tradeItemMeasurements/tradeItemWeight/netWeight"/>

				<xsl:variable name="netWeight">
					<xsl:choose>
						<xsl:when test="$value = number($value)">
							<xsl:variable name="quantity">
								<xsl:choose>
									<xsl:when test="$item/quantity = number($item/quantity)">
										<xsl:value-of select="$item/quantity"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="1"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:variable name="weightValue">
								<xsl:apply-templates select="$value" mode="measurementUnit"/>
							</xsl:variable>
							<xsl:value-of select="$quantity * $weightValue"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="0"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:call-template name="r98">
					<xsl:with-param name="items" select="$items"/>
					<xsl:with-param name="index" select="$index + 1"/>
					<xsl:with-param name="count" select="$count"/>
					<xsl:with-param name="weight" select="$weight + $netWeight"/>
				</xsl:call-template>

			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$weight"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
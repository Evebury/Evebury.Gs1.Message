<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1 cin"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	xmlns:cin="urn:gs1:gdsn:catalogue_item_notification:xsd:3"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:variable name="version" select="'3.1'"/>
	<xsl:param name="current"/>

	<xsl:include href="modules/alcoholInformationModule.xslt"/>
	<xsl:include href="modules/allergenInformationModule.xslt"/>
	<xsl:include href="modules/animalFeedingModule.xslt"/>
	<xsl:include href="modules/audienceOrPlayerInformationModule.xslt"/>
	<xsl:include href="modules/audioVisualMediaContentInformationModule.xslt"/>
	<xsl:include href="modules/audioVisualMediaProductDescriptionInformationModule.xslt"/>
	<xsl:include href="modules/batteryInformationModule.xslt"/>
	<xsl:include href="modules/certificationInformationModule.xslt"/>
	<xsl:include href="modules/childNutritionInformationModule.xslt"/>
	<xsl:include href="modules/consumerInstructionsModule.xslt"/>
	<xsl:include href="modules/copyrightInformationModule.xslt"/>
	<xsl:include href="modules/dairyFishMeatPoultryItemModule.xslt"/>
	<xsl:include href="modules/dangerousSubstanceInformationModule.xslt"/>
	<xsl:include href="modules/deliveryPurchasingInformationModule.xslt"/>
	<xsl:include href="modules/dietInformationModule.xslt"/>
	<xsl:include href="modules/dutyFeeTaxInformationModule.xslt"/>
	<xsl:include href="modules/farmingAndProcessingInformationModule.xslt"/>
	<xsl:include href="modules/foodAndBeverageIngredientModule.xslt"/>
	<xsl:include href="modules/foodAndBeveragePreparationServingModule.xslt"/>
	<xsl:include href="modules/foodAndBeveragePropertiesInformationModule.xslt"/>
	<xsl:include href="modules/healthRelatedInformationModule.xslt"/>
	<xsl:include href="modules/lightingDeviceModule.xslt"/>
	<xsl:include href="modules/marketingInformationModule.xslt"/>
	<xsl:include href="modules/materialModule.xslt"/>
	<xsl:include href="modules/medicalDeviceTradeItemModule.xslt"/>
	<xsl:include href="modules/nonfoodIngredientModule.xslt"/>
	<xsl:include href="modules/nonGTINLogisticsUnitInformationModule.xslt"/>
	<xsl:include href="modules/nutritionalInformationModule.xslt"/>
	<xsl:include href="modules/oNIXPublicationFileInformationModule.xslt"/>
	<xsl:include href="modules/organismClassificationModule.xslt"/>
	<xsl:include href="modules/packagingInformationModule.xslt"/>
	<xsl:include href="modules/packagingMarkingModule.xslt"/>
	<xsl:include href="modules/physicalResourceUsageInformationModule.xslt"/>
	<xsl:include href="modules/placeOfItemActivityModule.xslt"/>
	<xsl:include href="modules/plumbingHVACPipeInformationModule.xslt"/>
	<xsl:include href="modules/productFormulationStatementModule.xslt"/>
	<xsl:include href="modules/productInformationModule.xslt"/>
	<xsl:include href="modules/promotionalItemInformationModule.xslt"/>
	<xsl:include href="modules/referencedFileDetailInformationModule.xslt"/>
	<xsl:include href="modules/regulatedTradeItemModule.xslt"/>
	<xsl:include href="modules/safetyDataSheetModule.xslt"/>
	<xsl:include href="modules/salesInformationModule.xslt"/>
	<xsl:include href="modules/tradeItemDataCarrierAndIdentificationModule.xslt"/>
	<xsl:include href="modules/tradeItemDescriptionModule.xslt"/>
	<xsl:include href="modules/tradeItemHandlingModule.xslt"/>
	<xsl:include href="modules/tradeItemHierarchyModule.xslt"/>
	<xsl:include href="modules/tradeItemHumidityInformationModule.xslt"/>
	<xsl:include href="modules/tradeItemLicensingModule.xslt"/>
	<xsl:include href="modules/tradeItemLifespanModule.xslt"/>
	<xsl:include href="modules/tradeItemMeasurementsModule.xslt"/>
	<xsl:include href="modules/tradeItemSizeModule.xslt"/>
	<xsl:include href="modules/tradeItemTemperatureInformationModule.xslt"/>
	<xsl:include href="modules/transportationHazardousClassificationModule.xslt"/>
	<xsl:include href="modules/variableTradeItemInformationModule.xslt"/>
	<xsl:include href="modules/warrantyInformationModule.xslt"/>

	<!-- region auxiliary -->
	<xsl:include href="cin/hierarchy_rules.xslt"/>
	<xsl:include href="cin/item_rules.xslt"/>
	<xsl:include href="cin/measurementUnit.xslt"/>


	<xsl:variable name="quote">
		<xsl:text>'</xsl:text>
	</xsl:variable>

	<xsl:variable name="EVENT_DATA_INFORMATION_PROVIDER" select="'information_provider'"/>
	<xsl:variable name="EVENT_DATA_MARKET" select="'market'"/>
	<xsl:variable name="EVENT_DATA_TRADE_PARTNER" select="'trade_partner'"/>
	<xsl:variable name="EVENT_DATA_GTIN" select="'gtin'"/>
	<xsl:variable name="EVENT_DATA_DESCRIPTOR" select="'descriptor'"/>
	<xsl:variable name="EVENT_DATA_BRICK" select="'brick'"/>
	<xsl:variable name="EVENT_DATA_XPATH" select="'xpath'"/>
	<xsl:variable name="EVENT_DATA_LANGUAGE" select="'language'"/>
	<xsl:variable name="EVENT_DATA_MEASUREMENT_UNIT" select="'unit'"/>

	<xsl:template match="*" mode="error">
		<xsl:param name="id"/>
		<xsl:apply-templates select="." mode="xpath"/>
		<xsl:apply-templates select="gs1:AddErrorEvent($id)" />
	</xsl:template>

	<xsl:template match="*" mode="xpath">
		<xsl:param name="xpath" select="''"/>
		<xsl:variable name="name" select="local-name()"/>
		<xsl:choose>
			<xsl:when test="$name != 'catalogueItemNotificationMessage'">
				<xsl:variable name="path">
					<xsl:choose>
						<xsl:when test="$name = 'transaction'">
							<xsl:value-of select="concat($name, '[transactionIdentification/entityIdentification =', $quote, transactionIdentification/entityIdentification , $quote, ']')"/>
						</xsl:when>
						<xsl:when test="$name = 'catalogueItem'">
							<xsl:choose>
								<xsl:when test="tradeItem/gtin != ''">
									<xsl:value-of select="concat($name, '[tradeItem/gtin = ', $quote, tradeItem/gtin, $quote, ']')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="name()"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="$name = 'nonPromotionalTradeItem'">
							<xsl:value-of select="concat($name, '[gtin = ', $quote, gtin, $quote, ']')"/>
						</xsl:when>
						<xsl:when test="$name = 'referencedTradeItem'">
							<xsl:value-of select="concat($name, '[gtin = ', $quote, gtin, $quote, ']')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="name()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:apply-templates select=".." mode="xpath">
					<xsl:with-param name="xpath">
						<xsl:choose>
							<xsl:when test="$xpath = ''">
								<xsl:value-of select="$path"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat($path,'/',$xpath)"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="gs1:AddEventData($EVENT_DATA_XPATH, concat('/', name(), '/', $xpath))"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--endregion auxiliary -->

	<xsl:template match="/">
		<xsl:apply-templates select="gs1:BeginResponse($version)"/>
		<xsl:apply-templates select="cin:catalogueItemNotificationMessage"/>
		<xsl:copy-of select="gs1:EndResponse()"/>
	</xsl:template>

	<xsl:template match="cin:catalogueItemNotificationMessage">
		<xsl:variable name="count" select="count(transaction)"/>
		<xsl:choose>
			<xsl:when test="$count &gt; 1000">
				<!--There must be at most 1000 transactions per message.-->
				<xsl:apply-templates select="transaction" mode="transaction"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="transaction"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="transaction">
		<xsl:apply-templates select="gs1:BeginTransaction(transactionIdentification/entityIdentification)"/>
		<xsl:apply-templates select="documentCommand"/>
		<xsl:apply-templates select="gs1:EndTransaction()"/>
	</xsl:template>

	<xsl:template match="documentCommand">
		<xsl:if test="count(cin:catalogueItemNotification) &gt; 100">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="495" />
			</xsl:apply-templates>
		</xsl:if>
		<xsl:apply-templates select="cin:catalogueItemNotification">
			<xsl:with-param name="command" select="documentCommandHeader/@type"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="cin:catalogueItemNotification">
		<xsl:param name="command"/>
		<xsl:apply-templates select="catalogueItem" mode="hierarchical">
			<xsl:with-param name="command" select="$command"/>
			<xsl:with-param name="previous">
				<xsl:if test="msxsl:node-set($current)/*">
					<xsl:value-of select="1"/>
				</xsl:if>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="catalogueItem" mode="hierarchical">
		<xsl:param name="sequence" select="1"/>
		<xsl:param name="command"/>
		<xsl:param name="previous"/>

		<xsl:variable name="informationProvider" select="tradeItem/informationProviderOfTradeItem/gln"/>
		<xsl:variable name="targetMarket" select="tradeItem/targetMarket/targetMarketCountryCode"/>
		<xsl:variable name="isEU" select="contains('008, 051, 031, 040, 112, 056, 070, 100, 191, 196, 203, 208, 233, 246, 250, 276, 268, 300, 348, 352, 372, 376, 380, 398, 417, 428, 440, 442, 807, 498, 499, 528, 578, 616, 620, 642, 643, 688, 703, 705, 756, 792, 795, 826, 804, 860', $targetMarket)"/>

		<xsl:apply-templates select="gs1:BeginSequence()"/>
		<xsl:apply-templates select="gs1:AddSequenceEventDataWithLabel($EVENT_DATA_INFORMATION_PROVIDER, $informationProvider, tradeItem/informationProviderOfTradeItem/partyName)"/>
		<xsl:apply-templates select="gs1:AddSequenceEventData($EVENT_DATA_MARKET, $targetMarket)"/>
		<xsl:for-each select="tradeItem/partyInRole[partyRoleCode = 'PARTY_RECEIVING_PRIVATE_DATA']">
			<xsl:apply-templates select="gs1:AddSequenceEventDataWithLabel($EVENT_DATA_TRADE_PARTNER, gln, partyName)"/>
		</xsl:for-each>
		<xsl:apply-templates select="gs1:AddSequenceEventData($EVENT_DATA_GTIN, tradeItem/gtin)"/>
		<xsl:apply-templates select="gs1:AddSequenceEventData($EVENT_DATA_DESCRIPTOR, tradeItem/tradeItemUnitDescriptorCode)"/>

		<xsl:if test="$sequence = 1">
			<xsl:apply-templates select="." mode="hierarchy_rules">
				<xsl:with-param name="targetMarket" select="$targetMarket"/>
				<xsl:with-param name="isEU" select="$isEU"/>
				<xsl:with-param name="informationProvider" select="$informationProvider"/>
				<xsl:with-param name="command" select="$command"/>
			</xsl:apply-templates>
		</xsl:if>

		<xsl:if test="$previous =  1">
			<xsl:apply-templates select="tradeItem" mode="compare">
				<xsl:with-param name="targetMarket" select="$targetMarket"/>
				<xsl:with-param name="isEU" select="$isEU"/>
				<xsl:with-param name="informationProvider" select="$informationProvider"/>
				<xsl:with-param name="command" select="$command"/>
			</xsl:apply-templates>
		</xsl:if>

		<xsl:apply-templates select="tradeItem" mode="item_rules">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
			<xsl:with-param name="isEU" select="$isEU"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="gs1:EndSequence()"/>

		<xsl:apply-templates select="catalogueItemChildItemLink/catalogueItem" mode="hierarchical">
			<xsl:with-param name="sequence" select="$sequence + 1"/>
			<xsl:with-param name="command" select="$command"/>
			<xsl:with-param name="previous" select="$previous"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="module">
		<!-- ignore all undefined modules -->
	</xsl:template>


	<!-- region validation rules -->
	<xsl:template match="*" mode="compare">
		<xsl:param name="targetMarket"/>
		<xsl:param name="informationProvider"/>
		<xsl:param name="command"/>
		<xsl:variable name="gtin" select="gtin"/>
		<xsl:variable name="tradeItem" select="msxsl:node-set($current)/*/tradeItem[@informationProvider = $informationProvider and @market = $targetMarket and @gtin=$gtin]"/>

		<xsl:if test="$tradeItem">
			<!--Rule 483: On first population endAvailabilityDateTime shall be later than or equal to today.-->
			<xsl:variable name="date" select="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:delivery_purchasing_information:xsd:3' and local-name()='deliveryPurchasingInformationModule']/deliveryPurchasingInformation/endAvailabilityDateTime"/>
			<xsl:if test="string($tradeItem/deliveryPurchasingInformation/endAvailabilityDateTime) = ''">
				<xsl:if test="gs1:InvalidDateTimeSpan(gs1:Today(), $date)">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="483" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
			<!-- Rule 488: lastChangeDateTime SHALL be later than or equal to the previously sent value.-->
			<xsl:if test="gs1:InvalidDateTimeSpan($tradeItem/tradeItemSynchronisationDates/lastChangeDateTime, tradeItemSynchronisationDates/lastChangeDateTime)">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="488" />
				</xsl:apply-templates>
			</xsl:if>

			<xsl:if test="string(preliminaryItemStatusCode) != 'PRELIMINARY' and $command = 'CHANGE_BY_REFRESH'">
				<xsl:variable name="module" select="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_measurements:xsd:3' and local-name()='tradeItemMeasurementsModule']/tradeItemMeasurements"/>

				<xsl:variable name="netContent">
					<xsl:apply-templates select="$module/netContent" mode="measurementUnit"/>
				</xsl:variable>

				<xsl:variable name="cNetContent">
					<xsl:apply-templates select="$tradeItem/tradeItemMeasurements/netContent" mode="measurementUnit"/>
				</xsl:variable>

				<!--Rule 449: If preliminaryItemStatusCode does not equal 'PRELIMINARY' then if the Document Command is equal to  'CHANGE_BY_REFRESH' then netContent must not be updated.-->
				<xsl:if test="$netContent != $cNetContent">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="449"/>
					</xsl:apply-templates>
				</xsl:if>

				<!--Rule 451: If preliminaryItemStatusCode does not equal 'PRELIMINARY' and the Document Command equals  'CHANGE_BY_REFRESH' then BrandNameInformation/brandName shall not be updated.-->
				<xsl:if test="string(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:trade_item_description:xsd:3' and local-name()='tradeItemDescriptionModule']/tradeItemDescriptionInformation/brandNameInformation/brandName) != string($tradeItem/tradeItemDescriptionInformation/brandName)">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="451"/>
					</xsl:apply-templates>
				</xsl:if>

				<!--Rule 452: If preliminaryItemStatusCode does not equal 'PRELIMINARY' then if the Document Command is equal to 'CHANGE_BY_REFRESH' then totalQuantityOfNextLowerLevelTradeItem must not be updated.-->

				<xsl:if test="string(nextLowerLevelTradeItemInformation/totalQuantityOfNextLowerLevelTradeItem) != string($tradeItem/nextLowerLevelTradeItemInformation/totalQuantityOfNextLowerLevelTradeItem)">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="452"/>
					</xsl:apply-templates>
				</xsl:if>

				<!--Rule 453: If the Document Command is equal to 'CHANGE_BY_REFRESH then ChildTradeItem/gtin shall not be updated.-->
				<xsl:variable name="xpath" select="."/>
				<xsl:for-each select="nextLowerLevelTradeItemInformation/childTradeItem">
					<xsl:variable name="key" select="gtin"/>
					<xsl:choose>
						<xsl:when test="$tradeItem/nextLowerLevelTradeItemInformation/childTradeItem[@gtin = $key]"/>
						<xsl:otherwise>
							<xsl:apply-templates select="$xpath" mode="error">
								<xsl:with-param name="id" select="453"/>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
				<xsl:for-each select="$tradeItem/nextLowerLevelTradeItemInformation/childTradeItem">
					<xsl:variable name="key" select="@gtin"/>
					<xsl:choose>
						<xsl:when test="$xpath/nextLowerLevelTradeItemInformation/childTradeItem[gtin = $key]"/>
						<xsl:otherwise>
							<xsl:apply-templates select="$xpath" mode="error">
								<xsl:with-param name="id" select="453"/>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>

				<xsl:variable name="price">
					<xsl:apply-templates select="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:sales_information:xsd:3' and local-name()='salesInformationModule']/salesInformation/priceComparisonMeasurement" mode="measurementUnit"/>
				</xsl:variable>
				<xsl:variable name="cPrice">
					<xsl:apply-templates select="$tradeItem/salesInformation/priceComparisonMeasurement" mode="measurementUnit"/>
				</xsl:variable>
				<!--Rule 450: If preliminaryItemStatusCode does not equal 'PRELIMINARY' then if the Document Command is equal to 'CHANGE_BY_REFRESH' then priceComparisonMeasurement must not be updated.-->
				<xsl:if test="$price != $cPrice">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="450"/>
					</xsl:apply-templates>
				</xsl:if>

				<xsl:variable name="height">
					<xsl:apply-templates select="$module/height" mode="measurementUnit"/>
				</xsl:variable>
				<xsl:variable name="cHeight">
					<xsl:apply-templates select="$tradeItem/tradeItemMeasurements/height" mode="measurementUnit"/>
				</xsl:variable>
				<xsl:variable name="width">
					<xsl:apply-templates select="$module/width" mode="measurementUnit"/>
				</xsl:variable>
				<xsl:variable name="cWidth">
					<xsl:apply-templates select="$tradeItem/tradeItemMeasurements/width" mode="measurementUnit"/>
				</xsl:variable>
				<xsl:variable name="depth">
					<xsl:apply-templates select="$module/depth" mode="measurementUnit"/>
				</xsl:variable>
				<xsl:variable name="cDepth">
					<xsl:apply-templates select="$tradeItem/tradeItemMeasurements/depth" mode="measurementUnit"/>
				</xsl:variable>
				<xsl:variable name="grossWeight">
					<xsl:apply-templates select="$module/tradeItemWeight/grossWeight" mode="measurementUnit"/>
				</xsl:variable>
				<xsl:variable name="cGrossWeight">
					<xsl:apply-templates select="$tradeItem/tradeItemMeasurements/grossWeight" mode="measurementUnit"/>
				</xsl:variable>

				<!-- Rule 500: If preliminaryItemStatusCode does not equal 'PRELIMINARY' and if the Document Command is equal to 'CHANGE_BY_REFRESH' then TradeItemMeasurements/height shall not be 20 percent greater than current version height.-->
				<xsl:if test="$height != '' and $cHeight != '' and  $height &gt; $cHeight * 1.2">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="500" />
					</xsl:apply-templates>
				</xsl:if>

				<!-- Rule 501: If preliminaryItemStatusCode does not equal 'PRELIMINARY' and if the Document Command is equal to 'CHANGE_BY_REFRESH' then TradeItemMeasurements/width shall not be 20 percent greater than current version width.-->
				<xsl:if test="$width != '' and $cWidth != '' and  $width &gt; $cWidth * 1.2">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="501" />
					</xsl:apply-templates>
				</xsl:if>

				<!--Rule 502: If preliminaryItemStatusCode does not equal 'PRELIMINARY' and if the Document Command is equal to 'CHANGE_BY_REFRESH' then TradeItemMeasurements/depth shall not be 20 percent greater than current version depth.-->
				<xsl:if test="$depth != '' and $cDepth != '' and  $depth &gt; $cDepth * 1.2">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="502" />
					</xsl:apply-templates>
				</xsl:if>

				<!--Rule 503: If preliminaryItemStatusCode does not equal 'PRELIMINARY' and if the Document Command is equal to 'CHANGE_BY_REFRESH' then TradeItemMeasurements/grossWeight shall not be 20 percent greater than current version grossWeight. -->
				<xsl:if test="$grossWeight != '' and $cGrossWeight != '' and  $grossWeight &gt; $cGrossWeight * 1.2">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="503" />
					</xsl:apply-templates>
				</xsl:if>

				<!--Rule 1085: If preliminaryItemStatusCode does not equal 'PRELIMINARY' and if the Document Command is equal to 'CHANGE_BY_REFRESH' then TradeItemMeasurements/height shall not be less than 80 percent of the current version height.-->
				<xsl:if test="$height != '' and $cHeight != '' and  $height &lt; $cHeight * 0.8">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1085" />
					</xsl:apply-templates>
				</xsl:if>

				<!--Rule 1086: If preliminaryItemStatusCode does not equal 'PRELIMINARY'  and if the Document Command is equal to 'CHANGE_BY_REFRESH' then TradeItemMeasurements/width must not be less than 80 percent of the current version width.-->
				<xsl:if test="$width != '' and $cWidth != '' and  $width &lt; $cWidth * 0.8">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1086" />
					</xsl:apply-templates>
				</xsl:if>

				<!--Rule 1087: If preliminaryItemStatusCode does not equal 'PRELIMINARY' and if the Document Command is equal to 'CHANGE_BY_REFRESH' then  TradeItemMeasurements/depth shall not be less than 80 percent of the current version depth.-->
				<xsl:if test="$depth != '' and $cDepth != '' and  $depth &lt; $cDepth * 0.8">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1087" />
					</xsl:apply-templates>
				</xsl:if>
				<!--Rule 1088: If preliminaryItemStatusCode does not equal 'PRELIMINARY' and if the Document Command is equal to 'CHANGE_BY_REFRESH' then TradeItemMeasurements/grossWeight shall not be less than 80 percent of the current version grossWeight.-->
				<xsl:if test="$grossWeight != '' and $cGrossWeight != '' and  $grossWeight &lt; $cGrossWeight * 0.8">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1088" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>

			<!--Rule 1122: udidFirstPublicationDateTime when first populated or changed shall be today's date or in the future.-->
			<xsl:if test="gs1:InvalidDateTimeSpan(gs1:Today(), tradeItemSynchronisationDates/udidFirstPublicationDateTime)">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1122" />
				</xsl:apply-templates>
			</xsl:if>

			<!--Rule 1123: udidFirstPublicationDateTime shall not be changed once the current populated date has been reached.-->
			<xsl:if test="gs1:InvalidDateTimeSpan(gs1:Today(), $tradeItem/tradeItemSynchronisationDates/udidFirstPublicationDateTime)">
				<xsl:if test="tradeItemSynchronisationDates/udidFirstPublicationDateTime != $tradeItem/tradeItemSynchronisationDates/udidFirstPublicationDateTime">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1123" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>


			<!--Rule 1290: If targetMarketCountryCode does not equal (036 (Australia), 554 (New Zealand)) and if preliminaryItemStatusCode changes from  'PRELIMINARY' to 'FINAL' and Document Command is equal to CHANGE_BY_REFRESH, then the lastChangeDateTime must be less than or equal to the firstShipDateTime.-->
			<xsl:if test="$targetMarket != '036' and $targetMarket != '554'">
				<xsl:if test="$tradeItem/preliminaryItemStatusCode = 'PRELIMINARY' and preliminaryItemStatusCode = 'FINAL'">
					<xsl:if test="$command = 'CHANGE_BY_REFRESH'">
						<xsl:if test="gs1:InvalidDateTimeSpan(tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:delivery_purchasing_information:xsd:3' and local-name()='deliveryPurchasingInformationModule']/deliveryPurchasingInformation/firstShipDateTime, tradeItemSynchronisationDates/lastChangeDateTime)">
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="1290" />
							</xsl:apply-templates>
						</xsl:if>
					</xsl:if>
				</xsl:if>
			</xsl:if>

			<xsl:if test="$command != 'CORRECT'">
				<xsl:if test="tradeItemSynchronisationDates/discontinuedDateTime != $tradeItem/tradeItemSynchronisationDates/discontinuedDateTime">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="485"/>
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>

			<!--Rule 1807: If targetMarketCountryCode equals '752' (Sweden) and (preliminaryItemStatusCode is not used or equals 'FINAL’) and allergen/levelOfContainmentCode equals 'CONTAINS' or 'MAY_CONTAIN' and Document Command equals 'CHANGE_BY_REFRESH' then corresponding values for allergenTypeCode SHALL NOT be added or removed.-->
			<xsl:if test="$targetMarket = '752' and (string(preliminaryItemStatusCode) = '' or preliminaryItemStatusCode = 'FINAL') and $command != 'CHANGE_BY_REFRESH'">
				<xsl:variable name="root" select="."/>
				<xsl:variable name="mod" select="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:allergen_information:xsd:3' and local-name()='allergenInformationModule']/allergenRelatedInformation"/>
				<xsl:for-each select="$tradeItem/allergenInformationModule/allergen">
					<xsl:variable name="code" select="@code"/>
					<xsl:variable name="level" select="@level"/>
					<xsl:if test="$level = 'CONTAINS' or $level = 'MAY_CONTAIN'">
						<xsl:variable name="allergen" select="$mod/allergen[allergenTypeCode = $code and levelOfContainmentCode = $level]"/>
						<xsl:choose>
							<xsl:when test="$allergen"/>
							<xsl:otherwise>
								<xsl:apply-templates select="$root" mode="error">
									<xsl:with-param name="id" select="1807" />
								</xsl:apply-templates>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
				</xsl:for-each>
				<xsl:for-each select="$mod/allergen">
					<xsl:variable name="code" select="allergenTypeCode"/>
					<xsl:variable name="level" select="levelOfContainmentCode"/>
					<xsl:if test="$level = 'CONTAINS' or $level = 'MAY_CONTAIN'">
						<xsl:variable name="allergen" select="$tradeItem/allergen[@code = $code and @level = $level]"/>
						<xsl:choose>
							<xsl:when test="$allergen"/>
							<xsl:otherwise>
								<xsl:apply-templates select="$root" mode="error">
									<xsl:with-param name="id" select="1807" />
								</xsl:apply-templates>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="transaction" mode="transaction">
		<!--Rule 493: There must be at most 1000 transactions per message.-->
		<xsl:apply-templates select="gs1:BeginTransaction(transactionIdentification/entityIdentification)"/>
		<xsl:apply-templates select="gs1:AddErrorEvent('493')" />
		<xsl:apply-templates select="gs1:EndTransaction()"/>
	</xsl:template>

	<xsl:template match="*" mode="gtin">
		<!--Rule 471: If data type is equal to  gtin then attribute value must be a  valid GTIN-8, GTIN-12, GTIN-13 or GTIN-14 number.-->
		<xsl:variable name="gtin">
			<xsl:choose>
				<xsl:when test="gtin">
					<xsl:value-of select="gtin"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="length" select="string-length($gtin)"/>
		<xsl:choose>
			<xsl:when test="$length = 0"/>
			<xsl:when test="$length = 14">
				<xsl:if test="gs1:InvalidGTIN($gtin, 14)">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="471" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$length = 13">
				<xsl:if test="gs1:InvalidGTIN($gtin, 13)">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="471" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$length = 12">
				<xsl:if test="gs1:InvalidGTIN($gtin, 12)">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="471" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$length = 8">
				<xsl:if test="gs1:InvalidGTIN($gtin, 8)">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="471" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="471" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="gln">
		<!--Rule 448: If attribute datatype equals gln then it must be a 13 digit number and have a valid check digit.-->
		<xsl:variable name="gln">
			<xsl:choose>
				<xsl:when test="gln">
					<xsl:value-of select="gln"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$gln = ''"/>
			<xsl:otherwise>
				<xsl:if test="gs1:InvalidGLN($gln)">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="448" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="languageSpecificPartyName">
		<!--Rule 1723: There shall be at most one value of languageSpecificPartyName for each language.-->
		<xsl:variable name="parent" select="."/>
		<xsl:for-each select="languageSpecificPartyName">
			<xsl:variable name="value" select="@languageCode"/>
			<xsl:if test="count($parent/languageSpecificPartyName[@languageCode = $value]) &gt; 1">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1723" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- endregion validation rules -->

</xsl:stylesheet>
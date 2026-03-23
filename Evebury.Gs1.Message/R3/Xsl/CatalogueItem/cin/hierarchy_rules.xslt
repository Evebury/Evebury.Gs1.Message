<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="catalogueItem" mode="hierarchy_rules">
		<xsl:param name="command"/>
		<xsl:param name="targetMarket"/>
		<xsl:param name="informationProvider"/>
		<xsl:param name="isEU"/>

		<xsl:apply-templates select="dataRecipient" mode="gln"/>
		<xsl:apply-templates select="sourceDataPool" mode="gln"/>

		<!--Rule 203: dataRecipient must not be empty.-->
		<xsl:if test="string(dataRecipient) = ''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="203"/>
			</xsl:apply-templates>
		</xsl:if>


		<xsl:variable name="tradeItems" select=".//tradeItem"/>

		<!--Rule 300: EntityIdentification/PartyIdentification/gln shall equal dataSource, contentOwner and informationProvider and shall be the same for all levels of trade item hierarchy.-->
		<xsl:if test="$tradeItems/informationProviderOfTradeItem[string(gln) != $informationProvider]">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="300" />
			</xsl:apply-templates>
		</xsl:if>

		<!--Rule 312: If isReturnableAssetEmpty does not equal “true” or is not used for any item in a Catalogue Item Notification Message then isTradeItemAnOrderableUnit must be equal to 'true' for at least one item in a Catalogue Item Notification Message.-->
		<xsl:choose>
			<xsl:when test="$tradeItems/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:packaging_information:xsd:3' and local-name()='packagingInformationModule']/packaging/returnableAsset[isReturnableAssetEmpty = 'true']"/>
			<xsl:otherwise>
				<xsl:if test="count($tradeItems[isTradeItemAnOrderableUnit = 'true']) = 0">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="312"/>
					</xsl:apply-templates>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>

		<!--Rule 1458: Catalogue Item Notification message shall not be sent using  transaction/documentCommand/documentCommandHeader/@type equal to 'DELETE'.-->
		<xsl:if test="$command = 'DELETE'">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1458" />
			</xsl:apply-templates>
		</xsl:if>

		<!--Rule 1789: If isTradeItemUDIDILevel=‘true’, then isTradeItemUDIDILevel SHALL equal ‘false’ or not used for all other tradeItem/gtin within the same hierarchy.-->
		<xsl:if test="count($tradeItems[isTradeItemUDIDILevel = 'true']) &gt; 1">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1789" />
			</xsl:apply-templates>
		</xsl:if>

		<!--Rule 1790: If isTradeItemUnitOfUse =‘true’, then isTradeItemUnitOfUse SHALL equal ‘false’ or not used for all other tradeItem/gtin within the same hierarchy.-->
		<xsl:if test="count($tradeItems[isTradeItemUnitOfUse = 'true']) &gt; 1">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1790" />
			</xsl:apply-templates>
		</xsl:if>


		<!-- EU -->
		<xsl:if test="$isEU">

			<xsl:choose>
				<xsl:when test="$tradeItems/nextLowerLevelTradeItemInformation[string(quantityOfChildren) != '' and quantityOfChildren != 1]"/>
				<xsl:otherwise>
					<!--Rule 1759: If targetMarketCountryCode  equals <Geographic> and quantityOfChildren equals '1' on every level of the item hierarchy (except for the level where isTradeItemABaseUnit equals 'true’) and percentageOfAlcoholByVolume is used, then percentageOfAlcoholByVolume SHALL equal the same value in all levels of the item hierarchy where percentageOfAlcoholByVolume is used.-->
					<xsl:variable name="percentageOfAlcoholByVolume" select="$tradeItems/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:alcohol_information:xsd:3' and local-name()='alcoholInformationModule']/alcoholInformation[string(percentageOfAlcoholByVolume) != ''][1]/percentageOfAlcoholByVolume"/>
					<xsl:if test="string($percentageOfAlcoholByVolume) != ''">
						<xsl:if test="$tradeItems/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:alcohol_information:xsd:3' and local-name()='alcoholInformationModule']/alcoholInformation[string(percentageOfAlcoholByVolume) != $percentageOfAlcoholByVolume]">
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="1759" />
							</xsl:apply-templates>
						</xsl:if>
					</xsl:if>
					<!--Rule 1760: If targetMarketCountryCode equals <geographic> and quantityOfChildren equals 1 on each level of the item hierarchy (except for the level where isTradeItemABaseUnit equals 'true’) and degreeOfOriginalWort is used, then degreeOfOriginalWort SHALL equal the same value in all levels of the item hierarchy where degreeOfOriginalWort is used.-->
					<xsl:variable name="degreeOfOriginalWort" select="$tradeItems/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:alcohol_information:xsd:3' and local-name()='alcoholInformationModule']/alcoholInformation[string(degreeOfOriginalWort) != ''][1]/degreeOfOriginalWort"/>
					<xsl:if test="string($degreeOfOriginalWort) != ''">
						<xsl:if test="$tradeItems/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:alcohol_information:xsd:3' and local-name()='alcoholInformationModule']/alcoholInformation[string(degreeOfOriginalWort) != $degreeOfOriginalWort]">
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="1760" />
							</xsl:apply-templates>
						</xsl:if>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>

		</xsl:if>

		<!-- Sweden (752) -->
		<xsl:if test="$targetMarket = '752'">

			<!--Rule 521: If targetMarketCountryCode is equal to '752' (Sweden) and isTradeItemOrderable is equal to 'true'  and additionalTradeItemIdentificationTypeCode  is equal to ('SUPPLIER_ASSIGNED' or 'DISTRIBUTOR_ASSIGNED') then associated additionalTradeItemIdentification must be unique within hierarchy.-->
			<xsl:for-each select="$tradeItems[isTradeItemAnOrderableUnit = 'true']">
				<xsl:for-each select="additionalTradeItemIdentification">
					<xsl:if test="@additionalTradeItemIdentificationTypeCode = 'SUPPLIER_ASSIGNED' or @additionalTradeItemIdentificationTypeCode = 'DISTRIBUTOR_ASSIGNED'">
						<xsl:variable name="code" select="."
						/>
						<xsl:if test="count($tradeItems[additionalTradeItemIdentification = $code]) &gt; 1">
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="521" />
							</xsl:apply-templates>
						</xsl:if>
					</xsl:if>
				</xsl:for-each>
			</xsl:for-each>

			<!--Rule 1830: If targetMarketCountryCode equals '752' (Sweden) and (quantityOfChildren equals '1' or is not used) on all levels of the trade item hierarchy,  then dutyFeeTaxRate, where used, SHALL equal the same value.-->
			<xsl:choose>
				<xsl:when test="$tradeItems/nextLowerLevelTradeItemInformation[string(quantityOfChildren) != '' and quantityOfChildren != 1]"/>
				<xsl:otherwise>
					<xsl:variable name="dutyFeeTaxRate" select="$tradeItems/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:duty_fee_tax_information:xsd:3' and local-name()='dutyFeeTaxInformationModule']/dutyFeeTaxInformation/dutyFeeTax[string(dutyFeeTaxRate) != ''][1]/dutyFeeTaxRate"/>
					<xsl:if test="string($dutyFeeTaxRate) != ''">
						<xsl:if test="$tradeItems/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:duty_fee_tax_information:xsd:3' and local-name()='dutyFeeTaxInformationModule']/dutyFeeTaxInformation/dutyFeeTax[string(dutyFeeTaxRate) != '' and dutyFeeTaxRate != $dutyFeeTaxRate]">
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="1830" />
							</xsl:apply-templates>
						</xsl:if>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>

		</xsl:if>

		<!-- France (250) -->
		<xsl:if test="$targetMarket = '250'">

			<!--Rule 1092: If targetMarketCountryCode equals <Geographic> and (isTradeItemNonphysical equals 'false' or is not used) and (isTradeItemAService equals 'false' or is not used) and (one iteration of tradeItemTradeChannelCode equals to ('CASH_AND_CARRY', 'CONSIGNMENT', 'CONVENIENCE', 'DRUG_STORE', 'FOOD_SERVICE', 'GROCERY',  'ONLINE' or 'UNSPECIFIED') or tradeItemTradeChannelCode is not used) then isTradeItemADespatchUnit SHALL equal 'true' for at least one trade item in the item hierarchy.-->
			<xsl:for-each select="$tradeItems">
				<xsl:if test="string(isTradeItemNonphysical) != 'true' and string(isTradeItemAService) !='true'">
					<xsl:if test="string(tradeItemTradeChannelCode) = '' or tradeItemTradeChannelCode= 'CASH_AND_CARRY' or tradeItemTradeChannelCode= 'CONSIGNMENT' or tradeItemTradeChannelCode= 'CONVENIENCE' or tradeItemTradeChannelCode= 'DRUG_STORE' or tradeItemTradeChannelCode= 'FOOD_SERVICE' or tradeItemTradeChannelCode= 'GROCERY' or tradeItemTradeChannelCode= 'ONLINE' or tradeItemTradeChannelCode= 'UNSPECIFIED'">
						<xsl:if test="count($tradeItems[isTradeItemADespatchUnit = 'true'])  = 0">
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="1092" />
							</xsl:apply-templates>
						</xsl:if>
					</xsl:if>
				</xsl:if>
			</xsl:for-each>

			<!--Rule 2066: If targetMarketCountryCode equals <Geographic> and .../@currencycode is used then at least one iteration of .../@currencycode SHALL equal 'EUR'.-->
			<xsl:apply-templates select="." mode="r2066"/>


		</xsl:if>


		<!-- Australia (036), New Zealand (554),  France (250), Sweden (752) -->
		<xsl:if test="$targetMarket = '036' or $targetMarket = '554' or $targetMarket = '250' or $targetMarket = '752'">

			<!--Rule 1720: If targetMarketCountryCode equals <Geographic> then isTradeItemAnInvoiceUnit SHALL equal 'true' for at least one trade item in the hierarchy.-->
			<xsl:if test="count($tradeItems[isTradeItemAnInvoiceUnit = 'true']) = 0">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1720" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>


		<!-- Switzerland (756) -->
		<xsl:if test="$targetMarket = '756'">

			<xsl:variable name="zcg" select="$tradeItems[isTradeItemABaseUnit = 'true' and tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:transportation_hazardous_classification:xsd:3' and local-name()='transportationHazardousClassificationModule']/transportationClassification/regulatedTransportationMode/hazardousInformationHeader/dangerousGoodsRegulationCode = 'ZCG']"/>

			<!--Rule 2000: If targetMarketCountryCode equals <Geographic> and dangerousGoodsLimitedQuantitiesCode is used then dangerousGoodsRegulationCode SHALL equal 'ZCG' on at least one trade item in the hierarchy where isTradeItemABaseUnit equals 'true'.-->
			<xsl:if test="$tradeItems/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:transportation_hazardous_classification:xsd:3' and local-name()='transportationHazardousClassificationModule']/transportationClassification/regulatedTransportationMode/hazardousInformationHeader[string(dangerousGoodsLimitedQuantitiesCode) != '']">
				<xsl:choose>
					<xsl:when test="$zcg"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="2000" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>

			<!--Rule 2001: If targetMarketCountryCode equals <Geographic> and isTradeItemABaseUnit equals 'true' and dangerousGoodsRegulationCode equals 'ZCG' then dangerousGoodsLimitedQuantitiesCode SHALL be used and dangerousGoodsLimitedQuantitiesCode SHALL be used on all its parent levels of the trade item hierarchy.-->
			<xsl:if test="$zcg">
				<xsl:apply-templates select="$zcg" mode="r2001"/>
			</xsl:if>

		</xsl:if>

	</xsl:template>

	<xsl:template match="*" mode="r2001">
		<!--Rule 2001: If targetMarketCountryCode equals <Geographic> and isTradeItemABaseUnit equals 'true' and dangerousGoodsRegulationCode equals 'ZCG' then dangerousGoodsLimitedQuantitiesCode SHALL be used and dangerousGoodsLimitedQuantitiesCode SHALL be used on all its parent levels of the trade item hierarchy.-->
		<xsl:if test="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:transportation_hazardous_classification:xsd:3' and local-name()='transportationHazardousClassificationModule']/transportationClassification/regulatedTransportationMode/hazardousInformationHeader[string(dangerousGoodsLimitedQuantitiesCode) = '']">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="2001" />
			</xsl:apply-templates>
		</xsl:if>
		<xsl:variable name="parent" select="../../../tradeItem"/>
		<xsl:if test="$parent">
			<xsl:apply-templates select="$parent" mode="r2001"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r2066">
		<!--Rule 2066: If targetMarketCountryCode equals <Geographic> and .../@currencycode is used then at least one iteration of .../@currencycode SHALL equal 'EUR'.-->
		<xsl:choose>
			<xsl:when test="@currencyCode">
				<xsl:variable name="name" select="name()"/>
				<xsl:if test="count(../*[name() = $name and @currencyCode = 'EUR']) = 0">
					<xsl:apply-templates select="gs1:AddEventData('unit', 'EUR')"/>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="2066" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*" mode="r2066"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


</xsl:stylesheet>
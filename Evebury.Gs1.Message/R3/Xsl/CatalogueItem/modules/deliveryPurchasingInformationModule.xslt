<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:delivery_purchasing_information:xsd:3' and local-name()='deliveryPurchasingInformationModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="deliveryPurchasingInformation" mode="deliveryPurchasingInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
			<xsl:with-param name="tradeItem" select="$tradeItem"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="deliveryPurchasingInformation" mode="deliveryPurchasingInformationModule">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="incotermInformation" mode="deliveryPurchasingInformationModule"/>

		<!--Rule 341: If a start dateTime and its corresponding end dateTime are not empty then the start date SHALL be less than or equal to corresponding end date. -->
		<xsl:if test="gs1:InvalidDateTimeSpan(consumerFirstAvailabilityDateTime, consumerEndAvailabilityDateTime)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="341"/>
			</xsl:apply-templates>
		</xsl:if>
		<xsl:if test="gs1:InvalidDateTimeSpan(firstOrderDateTime, lastOrderDateTime)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="341"/>
			</xsl:apply-templates>
		</xsl:if>
		<xsl:if test="gs1:InvalidDateTimeSpan(startAvailabilityDateTime, endAvailabilityDateTime)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="341"/>
			</xsl:apply-templates>
		</xsl:if>
		<xsl:if test="gs1:InvalidDateTimeSpan(startDateMaximumBuyingQuantity, endMaximumBuyingQuantityDateTime)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="341"/>
			</xsl:apply-templates>
		</xsl:if>
		<xsl:if test="gs1:InvalidDateTimeSpan(startDateMinimumBuyingQuantity, endMinimumBuyingQuantityDateTime)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="341"/>
			</xsl:apply-templates>
		</xsl:if>
		<xsl:if test="gs1:InvalidDateTimeSpan(firstShipDateTime, lastShipDateTime)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="341"/>
			</xsl:apply-templates>
		</xsl:if>
		<xsl:for-each select="orderableReturnableInformation">
			<xsl:if test="gs1:InvalidDateTimeSpan(firstReturnableDateTime, lastReturnableDateTime)">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="341"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>

		<!--Rule 362: If a minimum and corresponding maximum are not empty then the minimum SHALL be less than or equal to the corresponding maximum.-->
		<xsl:if test="gs1:InvalidRange(agreedMinimumBuyingQuantity,agreedMaximumBuyingQuantity)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="362"/>
			</xsl:apply-templates>
		</xsl:if>
		<xsl:if test="gs1:InvalidRange(orderQuantityMinimum,orderQuantityMaximum)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="362"/>
			</xsl:apply-templates>
		</xsl:if>

		<!--Rule 526: If orderingLeadTime is not empty, then value must be greater than 0.-->
		<xsl:for-each select="distributionDetails/orderingLeadTime">
			<xsl:if test="string(.) != '' and . &lt; 0">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="526" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>

		<!--Rule 1289: If targetMarketCountryCode does not equal (036 (Australia), 554 (New Zealand)) and If  firstShipDateTime is less than or equal to current date then preliminaryItemStatusCode must not equal 'PRELIMINARY' -->
		<xsl:if test="$targetMarket != '036' and $targetMarket != '554'">
			<xsl:if test="gs1:InvalidDateTimeSpan(gs1:Today(), firstShipDateTime)">
				<xsl:if test="$tradeItem/preliminaryItemStatusCode = 'PRELIMINARY'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1289" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>


		<xsl:if test="$targetMarket = '250'">

			<!--Rule 1856: If targetMarketCountryCode equals <Geographic> and (endAvailabilityDateTime and ChildItem..endAvailabilityDateTime) are used, then ChildItem..endAvailabilityDateTime SHALL be equal to or after endAvailabilityDateTime.-->
			<xsl:if test="string(endAvailabilityDateTime) != ''">
				<xsl:variable name="endAvailabilityDateTime" select="endAvailabilityDateTime"/>
				<xsl:for-each select="$tradeItem/../catalogueItemChildItemLink/catalogueItem/tradeItem">
					<xsl:variable name="date" select="tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:delivery_purchasing_information:xsd:3' and local-name()='deliveryPurchasingInformationModule']/deliveryPurchasingInformation/endAvailabilityDateTime"/>
					<xsl:if test="string($date) != ''">
						<xsl:if test="gs1:InvalidDateTimeSpan($endAvailabilityDateTime, $date)">
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="1856" />
							</xsl:apply-templates>
						</xsl:if>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>

			<!--Rule 1894: If targetMarketCountryCode equals <Geographic> and (startAvailabilityDateTime and ChildItem..startAvailabilityDateTime) are used, then ChildItem..startAvailabilityDateTime SHALL be before or equal to startAvailabilityDateTime.-->
			<xsl:if test="string(startAvailabilityDateTime) != ''">
				<xsl:variable name="startAvailabilityDateTime" select="startAvailabilityDateTime"/>
				<xsl:for-each select="$tradeItem/../catalogueItemChildItemLink/catalogueItem/tradeItem">
					<xsl:variable name="date" select="./tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:delivery_purchasing_information:xsd:3' and local-name()='deliveryPurchasingInformationModule']/deliveryPurchasingInformation/startAvailabilityDateTime"/>
					<xsl:if test="string($date) != ''">
						<xsl:if test="gs1:InvalidDateTimeSpan($date, $startAvailabilityDateTime)">
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="1894" />
							</xsl:apply-templates>
						</xsl:if>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
			
			
		</xsl:if>

		<!--Rule 1919: If orderingLeadTime is used then orderingLeadTime/@measurementUnitCode SHALL equal 'DAY'.-->
		<xsl:for-each select="distributionDetails">
			<xsl:if test="string(orderingLeadTime) != '' and string(orderingLeadTime/@measurementUnitCode) != 'DAY'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1919" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>

		<xsl:if test="$targetMarket = '756'">
			<!--Rule 1966: If targetMarketCountryCode equals <Geographic> and orderQuantityMinimum is used then isTradeItemAnOrderableUnit SHALL equal 'true'.-->
			<xsl:if test="string(orderQuantityMinimum) != '' and string($tradeItem/isTradeItemAnOrderableUnit) != 'true'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1966" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
		

	</xsl:template>

	<xsl:template match="incotermInformation" mode="deliveryPurchasingInformationModule">
		<!--Rule 392: If incotermCodeLocation is not empty then incotermCode must not be empty.-->
		<xsl:if test="string(incotermCodeLocation) != '' and string(incotermCode) =''">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="392" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
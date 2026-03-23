<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:duty_fee_tax_information:xsd:3' and local-name()='dutyFeeTaxInformationModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="dutyFeeTaxInformation" mode="dutyFeeTaxInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
			<xsl:with-param name="tradeItem" select="$tradeItem"/>
		</xsl:apply-templates>

		<!--Rule 1093: If targetMarketCountryCode equals ('249' (France) or '250' (France)) and for the same dutyFeeTaxTypeCode, then the range of dutyFeeTaxEffectiveStartDateTime if used and dutyFeeTaxEffectiveEndDateTime if used, SHALL NOT overlap date range with another instance of the same dutyFeeTaxTypeCode.-->
		<xsl:if test="$targetMarket = '249' or $targetMarket = '250'">
			<xsl:call-template name="r1093">
				<xsl:with-param name="items" select="dutyFeeTaxInformation"/>
			</xsl:call-template>
		</xsl:if>


		<xsl:if test="$targetMarket = '250'">
			<xsl:variable name="parent" select="."/>
			<xsl:for-each select="dutyFeeTaxInformation">
				<xsl:variable name="value" select="dutyFeeTaxTypeCode"/>
				<xsl:if test="count($parent/dutyFeeTaxInformation[dutyFeeTaxTypeCode = $value]) &gt; 1">
					<!--Rule 1819: If targetMarketCountryCode equals ('250' (France)) and more than one instance of dutyFeeTaxInformation class has the same dutyFeeTaxTypeCode, then dutyFeeTaxEffectiveStartDateTime SHALL be used in all instances of the same dutyFeeTaxTypeCode.-->
					<xsl:for-each select="$parent/dutyFeeTaxInformation[dutyFeeTaxTypeCode = $value]">
						<xsl:if test="string(dutyFeeTaxEffectiveStartDateTime) = ''">
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="1819" />
							</xsl:apply-templates>
						</xsl:if>
					</xsl:for-each>

					<!--Rule 1820: If targetMarketCountryCode equals ('250' (France)) and more than one instance of dutyFeeTaxInformation class has the same dutyFeeTaxTypeCode, then there SHALL be only 1 instance for the same dutyFeeTaxTypeCode that may have dutyFeeTaxEffectiveEndDateTime not used and in all other instances dutyFeeTaxEffectiveEndDateTime SHALL be used.-->
					<xsl:if test="count($parent/dutyFeeTaxInformation[dutyFeeTaxTypeCode = $value and string(dutyFeeTaxEffectiveEndDateTime)  = '']) &gt; 1">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1820" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:if>
			</xsl:for-each>

		</xsl:if>

	</xsl:template>

	<xsl:template match="dutyFeeTaxInformation" mode="dutyFeeTaxInformationModule">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="dutyFeeTax" mode="dutyFeeTaxInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
			<xsl:with-param name="tradeItem" select="$tradeItem"/>
		</xsl:apply-templates>

		<!--Rule 341: If a start dateTime and its corresponding end dateTime are not empty then the start date SHALL be less than or equal to corresponding end date. -->
		<xsl:if test="gs1:InvalidDateTimeSpan(dutyFeeTaxEffectiveStartDateTime, dutyFeeTaxEffectiveEndDateTime)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="341"/>
			</xsl:apply-templates>
		</xsl:if>
		<!--Rule 571: If targetMarketCountryCode is equal to '752' (Sweden) and dutyFeeTaxAgencyCode is not empty then dutyFeeTaxAgencyCode must equal '9SE'.-->
		<xsl:if test="$targetMarket = '752'">
			<xsl:if test="string(dutyFeeTaxAgencyCode) != '' and dutyFeeTaxAgencyCode != '9SE'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="571" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<!--Rule 1111: If targetMarketCountryCode equals ('249' (France) or '250' (France)) and dutyFeeTaxTypeCode equals '3001000002282' then dutyFeeTaxRate shall be empty and dutyFeeTaxAmount shall be used.-->
		<xsl:if test="$targetMarket = '249' or $targetMarket = '250'">
			<xsl:if test="dutyFeeTaxTypeCode = '3001000002282' and (string(dutyFeeTaxRate) !='' or dutyFeeTax[dutyFeeTaxAmount = ''])">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1111" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>


		<xsl:if test="$targetMarket = '250'">
			<!--Rule 1876: If targetMarketCountryCode equals <Geographic> and isTradeItemAConsumerUnit equals 'true' and dutyFeeTaxTypeCode equals '3001000002312', then percentageOfAlcoholByVolume SHALL be greater than 0.-->
			<xsl:if test="dutyFeeTaxTypeCode = '3001000002312' and $tradeItem/isTradeItemAConsumerUnit = 'true'">
				<xsl:variable name="alcohol" select="$tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:alcohol_information:xsd:3' and local-name()='alcoholInformationModule']/alcoholInformation/percentageOfAlcoholByVolume"/>
				<xsl:if test="string($alcohol) = '' or $alcohol &lt; 1">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1876" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>

			<!--Rule 1881: If targetMarketCountryCode equals <Geographic> and isTradeItemAConsumerUnit equals 'true', then at least one iteration of dutyFeeTaxTypeCode SHALL equal ('S' , '1G' , '2G' , '3G' , 'H' or 'E').-->
			<xsl:if test="$tradeItem/isTradeItemAConsumerUnit = 'true'">
				<xsl:choose>
					<xsl:when test="dutyFeeTax[dutyFeeTaxCategoryCode = 'S']"/>
					<xsl:when test="dutyFeeTax[dutyFeeTaxCategoryCode = '1G']"/>
					<xsl:when test="dutyFeeTax[dutyFeeTaxCategoryCode = '2G']"/>
					<xsl:when test="dutyFeeTax[dutyFeeTaxCategoryCode = '3G']"/>
					<xsl:when test="dutyFeeTax[dutyFeeTaxCategoryCode = 'H']"/>
					<xsl:when test="dutyFeeTax[dutyFeeTaxCategoryCode = 'E']"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1881" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>

			<!--Rule 1884: If targetMarketCountryCode equals <Geographic> and isTradeItemAConsumerUnit equals 'true' and dutyFeeTaxTypeCode equals '3001000002312', then percentageOfAlcoholByVolume SHALL be greater than 0.-->
			<xsl:if test="dutyFeeTaxTypeCode = '3001000002312' and $tradeItem/isTradeItemAConsumerUnit = 'true'">
				<xsl:variable name="alcohol" select="$tradeItem/tradeItemInformation/extension/*[namespace-uri()='urn:gs1:gdsn:alcohol_information:xsd:3' and local-name()='alcoholInformationModule']/alcoholInformation/percentageOfAlcoholByVolume"/>
				<xsl:if  test="string($alcohol) = '' or $alcohol &lt;= 0">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1884" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
			
		</xsl:if>

	
		<xsl:if test="$targetMarket = '380'">
			<xsl:if test="dutyFeeTaxTypeCode  = 'VAT' or dutyFeeTaxTypeCode = 'IVA'">

				<!--Rule 1920: If targetMarketCountryCode equals <Geographic> and isTradeItemAConsumerUnit equals 'true' and dutyFeeTaxTypeCode equals ('VAT' or 'IVA') then dutyFeeTaxRate SHALL be used.-->
				<xsl:if test="$tradeItem/isTradeItemAConsumerUnit =  'true'">
					<xsl:if test="dutyFeeTax[string(dutyFeeTaxRate) = '']">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1920" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:if>

				<!--Rule 101923: If targetMarketCountryCode equals <Geographic> and dutyFeeTaxTypeCode equals ('VAT' or 'IVA') and dutyFeeTaxRate equals 0 (zero) then dutyFeeTaxCategoryCode SHALL equal 'ZERO' or 'EXEMPT'.-->
				<xsl:if test="dutyFeeTax/dutyFeeTaxRate = 0 and dutyFeeTax/dutyFeeTaxCategoryCode != 'ZERO' and dutyFeeTax/dutyFeeTaxCategoryCode != 'EXEMPT'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="101923" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>


	</xsl:template>

	<xsl:template match="dutyFeeTax" mode="dutyFeeTaxInformationModule">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<!--Rule 1860: If targetMarketCountryCode equals <Geographic> and isTradeItemAConsumerUnit equals 'true' and dutyFeeTaxCategoryCode does not equal 'EXEMPT' and dutyFeeTaxAmount is used, then dutyFeeTaxAmount SHALL be greater than 0.-->
		<xsl:if test="$targetMarket = '250'">
			<xsl:if test="dutyFeeTaxCategoryCode != 'EXEMPT' and $tradeItem/isTradeItemAConsumerUnit = 'true'">
				<xsl:if test="string(dutyFeeTaxAmount) != '' and dutyFeeTaxAmount &lt;= 0">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1860" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>
	</xsl:template>


	<xsl:template name="r1093">
		<xsl:param name="items"/>
		<xsl:param name="index" select="1"/>
		<xsl:param name="count" select="count(msxsl:node-set($items))"/>
		<xsl:param name="codes"/>
		<xsl:if test="$index &lt;= $count">
			<xsl:variable name="item" select="msxsl:node-set($items)[$index]"/>
			<xsl:variable name="dutyCode" select="$item/dutyFeeTaxTypeCode"/>
			<xsl:variable name="code">
				<xsl:choose>
					<xsl:when test="msxsl:node-set($codes)/*[@Code = $dutyCode]">
						<xsl:value-of select="0"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="1"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:if test="$code = 1">
				<xsl:variable name="ranges">
					<xsl:for-each select="msxsl:node-set($items[dutyFeeTaxTypeCode = $dutyCode])">
						<DateTimeRange Start="{dutyFeeTaxEffectiveStartDateTime}" End="{dutyFeeTaxEffectiveEndDateTime}"/>
					</xsl:for-each>
				</xsl:variable>
				<xsl:if test="gs1:OverlappingDateTimeRange($ranges)">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1093" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>

			<xsl:call-template name="r1093">
				<xsl:with-param name="items" select="$items"/>
				<xsl:with-param name="index" select="$index + 1"/>
				<xsl:with-param name="count" select="$count"/>
				<xsl:with-param name="codes">
					<xsl:copy-of select="$codes"/>
					<xsl:if test="$code = 1">
						<Code Code="{$dutyCode}"/>
					</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
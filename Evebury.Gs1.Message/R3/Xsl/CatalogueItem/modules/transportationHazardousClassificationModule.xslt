<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:transportation_hazardous_classification:xsd:3' and local-name()='transportationHazardousClassificationModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="transportationClassification/regulatedTransportationMode/hazardousInformationHeader" mode="transportationHazardousClassificationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
			<xsl:with-param name="tradeItem" select="$tradeItem"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="transportationClassification" mode="transportationHazardousClassificationModule"/>

	</xsl:template>

	<xsl:template match="transportationClassification" mode="transportationHazardousClassificationModule">

		<xsl:variable name="class" select="."/>

		<!--Rule 1233: There must be at most one iteration of transportationModeRegulatoryAgency-->
		<xsl:for-each select="transportationModeRegulatoryAgency">
			<xsl:variable name="value" select="."/>
			<xsl:if test="count($class[transportationModeRegulatoryAgency = $value]) &gt; 1">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1233" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>

	</xsl:template>

	<xsl:template match="hazardousInformationHeader" mode="transportationHazardousClassificationModule">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="hazardousInformationDetail" mode="transportationHazardousClassificationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>

		<xsl:if test="dangerousGoodsRegulationCode  = 'ADR'">

			<!--Rule 339: If dangerousGoodsRegulationCode is equal to 'ADR' and dangerousGoodsPackingGroup is not empty then dangerousGoodsPackingGroup must equal  ('NA','I', 'II' or 'III').-->
			<xsl:for-each select="hazardousInformationDetail/dangerousGoodsPackingGroup">
				<xsl:choose>
					<xsl:when test=". = ''"/>
					<xsl:when test=". = 'NA'"/>
					<xsl:when test=". = 'I'"/>
					<xsl:when test=". = 'II'"/>
					<xsl:when test=". = 'III'"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="339"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>

			<!--Rule 437: If dangerousGoodsRegulationCode is equal to 'ADR' and classOfDangerousGoods is not empty then classOfDangerousGoods must equal ('1', '2', '3', '4.1', '4.2', '4.3', '5.1', '5.2', '6.1', '6.2', '7', '8'or '9').-->
			<xsl:for-each select="hazardousInformationDetail/classOfDangerousGoods">
				<xsl:choose>
					<xsl:when test=". = ''"/>
					<xsl:when test=". = '1'"/>
					<xsl:when test=". = '2'"/>
					<xsl:when test=". = '3'"/>
					<xsl:when test=". = '4.1'"/>
					<xsl:when test=". = '4.2'"/>
					<xsl:when test=". = '4.3'"/>
					<xsl:when test=". = '5.1'"/>
					<xsl:when test=". = '5.2'"/>
					<xsl:when test=". = '6.1'"/>
					<xsl:when test=". = '6.2'"/>
					<xsl:when test=". = '7'"/>
					<xsl:when test=". = '8'"/>
					<xsl:when test=". = '9'"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="437"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:if>

		<!--Rule 477: If targetMarketCountryCode equals <Geographic> and (maximumTemperature, minimumTemperature, flashPoint/flashPointTemperature or hazardousInformationHeader/flashPointTemperature are used) then at least one iteration of the associated measurementUnitCode SHALL equal 'CEL'.-->
		<xsl:if test="contains('752, 203, 250, 208, 246, 040, 703, 756', $targetMarket)">
			<xsl:if test="flashPointTemperature">
				<xsl:choose>
					<xsl:when test="flashPointTemperature[@temperatureMeasurementUnitCode = 'CEL']"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="477"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:if>

		<!--Rule 1802: If targetMarketCountryCode equals ('208' (Denmark) or 752' (Sweden)) then aDRDangerousGoodsLimitedQuantitiesCode SHALL NOT be used.-->
		<xsl:if test="$targetMarket= '208' or $targetMarket = '752'">
			<xsl:if test="string(aDRDangerousGoodsLimitedQuantitiesCode) != ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1802" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>


		<xsl:if test="$targetMarket ='756' or $targetMarket ='040'">
			<!--Rule 1994: If targetMarketCountryCode equals <Geographic> and isTradeItemABaseUnit equals 'true' and (dangerousGoodsRegulationAgency is used or dangerousGoodsRegulationCode is used) then dangerousGoodsRegulationCode SHALL be used and dangerousGoodsRegulationAgency SHALL equal 'ADR'.-->
			<xsl:if test="$tradeItem/isTradeItemABaseUnit = 'true'">
				<xsl:if test="(dangerousGoodsRegulationAgency != '' or  dangerousGoodsRegulationCode !='') and (dangerousGoodsRegulationAgency = '' or  dangerousGoodsRegulationCode ='')">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1994" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
			<!--Rule 1995: If targetMarketCountryCode equals <Geographic> and dangerousGoodsRegulationCode is used then dangerousGoodsRegulationCode SHALL equal ('ZCG' or 'ZNA').-->
			<xsl:if test="dangerousGoodsRegulationCode and dangerousGoodsRegulationCode != 'ZCG' and dangerousGoodsRegulationCode != 'ZNA'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1995" />
				</xsl:apply-templates>
			</xsl:if>
			<!--Rule 1996: If targetMarketCountryCode equals <Geographic> and isTradeItemABaseUnit equals 'true' and dangerousGoodsRegulationCode equals 'ZCG' then classOfDangerousGoods SHALL be used and dangerousGoodsClassificationCode SHALL be used and unitedNationsDangerousGoodsNumber SHALL be used and dangerousGoodsHazardousCode SHALL be used and dangerousGoodsPackingGroup SHALL be used and dangerousGoodsTechnicalName SHALL be used.-->
			<xsl:if test="dangerousGoodsRegulationCode = 'ZCG' and $tradeItem/isTradeItemABaseUnit = 'true'">
				<xsl:for-each select="hazardousInformationDetail">
					<xsl:if test="classOfDangerousGoods = '' or dangerousGoodsClassificationCode = '' or unitedNationsDangerousGoodsNumber ='' or dangerousGoodsHazardousCode ='' or dangerousGoodsPackingGroup = '' or dangerousGoodsTechnicalName = ''">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1996" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
			
			<!--Rule 1997: If targetMarketCountryCode equals <Geographic> and (classOfDangerousGoods is used or dangerousGoodsClassificationCode is used or unitedNationsDangerousGoodsNumber is used or dangerousGoodsHazardousCode is used or dangerousGoodsPackingGroup is used or dangerousGoodsTechnicalName is used or netMassOfExplosives is used or dangerousGoodsSpecialProvisions is used or aDRTunnelRestrictionCode is used or hazardousMaterialAdditionalInformation is used) then isTradeItemABaseUnit SHALL equal 'true' and dangerousGoodsRegulationCode SHALL equal 'ZCG'.-->
			<xsl:if test="hazardousInformationDetail/*[text() != '']">
				<xsl:if test="dangerousGoodsRegulationCode != 'ZCG' or $tradeItem/isTradeItemABaseUnit != 'true'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1997" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
			
		</xsl:if>
		
		
	</xsl:template>

	<xsl:template match="hazardousInformationDetail" mode="transportationHazardousClassificationModule">
		<xsl:param name="targetMarket"/>

		<!--Rule 1851: If targetMarketCountryCode equals '246' (Finland) and netMassOfExplosives is used, then at least one iteration of netMassOfExplosives/@measurementUnitCode SHALL equal 'KGM'-->
		<xsl:if test="$targetMarket = '246'">
			<xsl:if test="netMassOfExplosives != ''">
				<xsl:choose>
					<xsl:when test="netMassOfExplosives[@measurementUnitCode = 'KGM']"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1851" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:if>

		<xsl:if test="contains('756, 203, 040, 703', $targetMarket)">
			<!--Rule 1998: If targetMarketCountryCode equals <Geographic> and classOfDangerousGoods equals '1' then netMassOfExplosives SHALL be used.-->
			<xsl:if test="classOfDangerousGoods = '1' and netMassOfExplosives = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1998" />
				</xsl:apply-templates>
			</xsl:if>
			<!--Rule 1999: If targetMarketCountryCode equals <Geographic> and netMassOfExplosives is used then classOfDangerousGoods SHALL equal '1'.-->
			<xsl:if test="classOfDangerousGoods != '1' and netMassOfExplosives != ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1999" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
		
		
	</xsl:template>



</xsl:stylesheet>
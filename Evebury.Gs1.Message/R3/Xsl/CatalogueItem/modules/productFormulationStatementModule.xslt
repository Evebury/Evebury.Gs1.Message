<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:product_formulation_statement:xsd:3' and local-name()='productFormulationStatementModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="productFormulationStatement" mode="productFormulationStatementModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="productFormulationStatement" mode="productFormulationStatementModule">
		<xsl:param name="targetMarket"/>
		<xsl:apply-templates select="productFormulationStatementDocument" mode="productFormulationStatementModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="creditableIngredient" mode="productFormulationStatementModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>

		<xsl:if test="$targetMarket = '840'">

			<!--Rule 1343: If targetMarketCountryCode equals '840' (United States) and productFormulationStatementRegulatoryBodyCode is used, then totalPortionWeightAsPurchased shall be used. -->
			<xsl:if test="string(productFormulationStatementRegulatoryBodyCode) != '' and string(productFormulationStatement/totalPortionWeightAsPurchased)  = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1343" />
				</xsl:apply-templates>
			</xsl:if>

			<!--Rule 1344: If targetMarketCountryCode equals '840' (united States) and productFormulationStatementRegulatoryBodyCode is used, then creditableIngredientTypeCode and totalCreditableIngredientTypeAmount shall be used at least once. -->
			<xsl:if test="productFormulationStatementRegulatoryBodyCode">
				<xsl:if test="count(creditableIngredient/creditableIngredientTypeCode) &lt; 1">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1344" />
					</xsl:apply-templates>
				</xsl:if>
				<xsl:if test="count(creditableIngredient/totalCreditableIngredientTypeAmount) &lt; 1">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1344" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>


		</xsl:if>

	</xsl:template>

	<xsl:template match="creditableIngredient" mode="productFormulationStatementModule">
		<xsl:param name="targetMarket"/>
		<xsl:if test="$targetMarket = '840'">
			<!--Rule 1345: If targetMarketCountryCode equals '840' (united States) and creditableIngredientTypeCode is used, then creditableIngredientDescription shall be used.-->
			<xsl:if test="string(creditableIngredientTypeCode) != '' and string(creditableIngredientDetails/creditableIngredientDescription)  = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1345" />
				</xsl:apply-templates>
			</xsl:if>


			<xsl:for-each select="creditableIngredientDetails">
				<!--Rule 1346: If targetMarketCountryCode equals '840' (United States) and creditableIngredientDescription is used, then creditableAmount shall be used.-->
				<xsl:if test="string(creditableIngredientDescription) != '' and string(creditableAmount) = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1346" />
					</xsl:apply-templates>
				</xsl:if>
				<!--Rule 1347: If targetMarketCountryCode equals '840' (United States) and  vegetableSubgroupCode is used, then totalVegetableSubgroupAmount shall be used.-->
				<xsl:for-each select="creditableVegetable">
					<xsl:if test="string(vegetableSubgroupCode) != '' and string(totalVegetableSubgroupAmount) = ''">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1347" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:for-each>
				
				<xsl:for-each select="creditableGrainsInformation">
					<!--Rule 1348: If targetMarketCountryCode equals '840' (United States) and doesTradeItemContainNoncreditableGrains is used, then doesTradeItemMeetWholeGrainRichCriteria, and creditableGrainGroupCode shall be used.-->
					<xsl:if test="string(doesTradeItemContainNoncreditableGrains) != '' and (string(doesTradeItemMeetWholeGrainRichCriteria) = '' or string(creditableGrain/creditableGrainGroupCode) = '')">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1348" />
						</xsl:apply-templates>
					</xsl:if>
					<!--Rule 1349: If targetMarketCountryCode equals '840' (United States) and doesTradeItemMeetWholeGrainRichCriteria is used, then doesTradeItemContainNoncreditableGrains, and creditableGrainGroupCode shall be used.-->
					<xsl:if test="string(doesTradeItemMeetWholeGrainRichCriteria) != '' and (string(doesTradeItemContainNoncreditableGrains) = '' or string(creditableGrain/creditableGrainGroupCode) = '')">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1349" />
						</xsl:apply-templates>
					</xsl:if>
					<!--Rule 1350: If targetMarketCountryCode equals '840' (United States) and  creditableGrainGroupCode is used, then doesTradeItemContainNoncreditableGrains, and doesTradeItemMeetWholeGrainRichCriteria shall be used.-->
					<xsl:if test="string(creditableGrain/creditableGrainGroupCode) != '' and (string(doesTradeItemContainNoncreditableGrains) = '' or string(doesTradeItemMeetWholeGrainRichCriteria) = '')">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1350" />
						</xsl:apply-templates>
					</xsl:if>
					<!--Rule 1351: If targetMarketCountryCode equals '840' (United States) and  doesTradeItemContainNoncreditableGrains is TRUE, then nonCreditableGrainAmount shall be used.-->
					<xsl:if test="doesTradeItemContainNoncreditableGrains = 'true' and string(noncreditableGrain/noncreditableGrainAmount) = ''">
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="1351" />
						</xsl:apply-templates>
					</xsl:if>
					
					
				</xsl:for-each>

			</xsl:for-each>
				
		</xsl:if>
	</xsl:template>

	<xsl:template match="productFormulationStatementDocument" mode="productFormulationStatementModule">
		<xsl:param name="targetMarket"/>
		<!--Rule 341: If a start dateTime and its corresponding end dateTime are not empty then the start date SHALL be less than or equal to corresponding end date. -->
		<xsl:if test="gs1:InvalidDateTimeSpan(fileEffectiveStartDateTime, fileEffectiveEndDateTime)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="341"/>
			</xsl:apply-templates>
		</xsl:if>
		<!--Rule 569: If targetMarketCountryCode does not equal ('756' (Switzerland), '276' (Germany), '040' (Austria), '528' (Netherlands), '056' (Belgium), '442' (Luxembourg), 203 (Czech Republic), or '250' (France)) and uniformResourceIdentifier is used and referencedFileTypeCode equals 'PRODUCT_IMAGE' then fileFormatName SHALL be used.-->
		<xsl:if test="not(contains('756, 276, 040, 528, 056, 442, 203, 250', $targetMarket))">
			<xsl:if test="uniformResourceIdentifier != '' and referencedFileTypeCode = 'PRODUCT_IMAGE'">
				<xsl:choose>
					<xsl:when test="fileFormatName != ''"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="569" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:if>
		<!--Rule 570: If uniformResourceIdentifier is used and referencedFileTypeCode equals  'PRODUCT_IMAGE' and targetMarketCountryCode does not equal  756 (Switzerland), 276 (Germany), 040 (Austria), 528 (Netherlands) then fileName shall be used.-->
		<xsl:if test="not(contains('756, 276, 040, 528', $targetMarket))">
			<xsl:if test="uniformResourceIdentifier != '' and referencedFileTypeCode = 'PRODUCT_IMAGE'">
				<xsl:choose>
					<xsl:when test="fileName != ''"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="570" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:if>
		<!--Rule 1611: If targetMarketCountryCode equals ‘250’ (France)) and uniformResourceIdentifier is used, and referencedFileTypeCode equals (‘VIDEO’ or ‘360_DEGREE_IMAGE’ or ‘MOBILE_DEVICE_IMAGE’ or ‘OUT_OF_PACKAGE_IMAGE’ or ‘PRODUCT_IMAGE’ or ‘PRODUCT_LABEL_IMAGE’ or ‘TRADE_ITEM_IMAGE_WITH_DIMENSIONS’)  then fileEffectiveStartDateTime shall  be used.-->
		<xsl:if test="$targetMarket ='250' and uniformResourceIdentifier != ''">
			<xsl:if test="referencedFileTypeCode = 'VIDEO' or referencedFileTypeCode = '360_DEGREE_IMAGE' or referencedFileTypeCode = 'MOBILE_DEVICE_IMAGE' or referencedFileTypeCode = 'OUT_OF_PACKAGE_IMAGE' or referencedFileTypeCode = 'PRODUCT_IMAGE'or referencedFileTypeCode = 'PRODUCT_LABEL_IMAGE' or referencedFileTypeCode = 'TRADE_ITEM_IMAGE_WITH_DIMENSIONS'">
				<xsl:if test="fileEffectiveStartDateTime = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1611" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>
	</xsl:template>



</xsl:stylesheet>
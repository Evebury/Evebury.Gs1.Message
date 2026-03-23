<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:referenced_file_detail_information:xsd:3' and local-name()='referencedFileDetailInformationModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="referencedFileHeader" mode="referencedFileDetailInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="referencedFileHeader" mode="referencedFileDetailInformationModule">
		<xsl:param name="targetMarket"/>
		<!--Rule 341: If a start dateTime and its corresponding end dateTime are not empty then the start date SHALL be less than or equal to corresponding end date. -->
		<xsl:if test="gs1:InvalidDateTimeSpan(fileEffectiveStartDateTime, fileEffectiveEndDateTime)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="341"/>
			</xsl:apply-templates>
		</xsl:if>
		<!--Rule 569: If targetMarketCountryCode does not equal ('756' (Switzerland), '276' (Germany), '040' (Austria), '528' (Netherlands), '056' (Belgium), '442' (Luxembourg), 203 (Czech Republic), or '250' (France)) and uniformResourceIdentifier is used and referencedFileTypeCode equals 'PRODUCT_IMAGE' then fileFormatName SHALL be used.-->
		<xsl:if test="not(contains('756, 276, 040, 528, 056, 442, 203, 250', $targetMarket))">
			<xsl:if test="string(uniformResourceIdentifier) != '' and referencedFileTypeCode = 'PRODUCT_IMAGE'">
				<xsl:choose>
					<xsl:when test="string(fileFormatName) != ''"/>
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
			<xsl:if test="string(uniformResourceIdentifier) != '' and referencedFileTypeCode = 'PRODUCT_IMAGE'">
				<xsl:choose>
					<xsl:when test="string(fileName) != ''"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="570" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:if>
		<!--Rule 1611: If targetMarketCountryCode equals ‘250’ (France)) and uniformResourceIdentifier is used, and referencedFileTypeCode equals (‘VIDEO’ or ‘360_DEGREE_IMAGE’ or ‘MOBILE_DEVICE_IMAGE’ or ‘OUT_OF_PACKAGE_IMAGE’ or ‘PRODUCT_IMAGE’ or ‘PRODUCT_LABEL_IMAGE’ or ‘TRADE_ITEM_IMAGE_WITH_DIMENSIONS’)  then fileEffectiveStartDateTime shall  be used.-->
		<xsl:if test="$targetMarket ='250' and string(uniformResourceIdentifier) != ''">
			<xsl:if test="referencedFileTypeCode = 'VIDEO' or referencedFileTypeCode = '360_DEGREE_IMAGE' or referencedFileTypeCode = 'MOBILE_DEVICE_IMAGE' or referencedFileTypeCode = 'OUT_OF_PACKAGE_IMAGE' or referencedFileTypeCode = 'PRODUCT_IMAGE'or referencedFileTypeCode = 'PRODUCT_LABEL_IMAGE' or referencedFileTypeCode = 'TRADE_ITEM_IMAGE_WITH_DIMENSIONS'">
				<xsl:if test="string(fileEffectiveStartDateTime) = ''">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1611" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
		</xsl:if>

		<xsl:if test="$targetMarket ='756' or $targetMarket ='040'">
			<!--Rule 1989: If targetMarketCountryCode equals <Geographic> and referencedFileTypeCode is used then uniformResourceIdentifier SHALL be used.-->
			<xsl:if test="string(referencedFileTypeCode) != '' and string(uniformResourceIdentifier) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1989" />
				</xsl:apply-templates>
			</xsl:if>
			<!--Rule 2014: If targetMarketCountryCode equals <Geographic> and fileSize is used then fileSize/@measurementUnitCode SHALL equal ('2P', '4L', 'AD', 'E34' or 'E35').-->
			<xsl:for-each select="referencedFileDetail/fileSize">
				<xsl:choose>
					<xsl:when test=". = ''"/>
					<xsl:when test=". = '2P'"/>
					<xsl:when test=". = '4L'"/>
					<xsl:when test=". = 'AD'"/>
					<xsl:when test=". = 'E34'"/>
					<xsl:when test=". = 'E35'"/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="2014" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
			
			<!--Rule 101973: If targetMarketCountryCode equals <Geographic> and referencedFileTypeCode equals 'PRODUCT_IMAGE' then uniformResourceIdentifier SHALL begin with ('http://' or 'https://').-->
			<xsl:if test="referencedFileTypeCode = 'PRODUCT_IMAGE'">
				<xsl:choose>
					<xsl:when test="starts-with(uniformResourceIdentifier , 'http://') or starts-with(uniformResourceIdentifier , 'https://') "/>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="error">
							<xsl:with-param name="id" select="101973" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:if>

		<xsl:if test="$targetMarket ='756'">
			<!--Rule 101972: If targetMarketCountryCode equals <Geographic> and referencedFileTypeCode equals ('SAFETY_DATA_SHEET', 'DOP_SHEET' or 'DECLARATION_OF_CONFORMITY') then fileLanguageCode SHALL be used.-->
			<xsl:if test="contains('SAFETY_DATA_SHEET, DOP_SHEET, DECLARATION_OF_CONFORMITY', referencedFileTypeCode) and string(fileLanguageCode) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="101972" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
	</xsl:template>



</xsl:stylesheet>
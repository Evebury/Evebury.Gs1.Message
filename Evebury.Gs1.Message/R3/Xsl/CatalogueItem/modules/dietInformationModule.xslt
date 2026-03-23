<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*[namespace-uri()='urn:gs1:gdsn:diet_information:xsd:3' and local-name()='dietInformationModule']" mode="module">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>

		<xsl:apply-templates select="dietInformation/dietTypeInformation" mode="dietInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="dietTypeInformation" mode="dietInformationModule">
		<xsl:param name="targetMarket"/>
		<xsl:apply-templates select="dietCertification" mode="dietInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>
		<!--Rule 1705: If dietTypeCode equals ’PESCATARIAN’ and dietTypeSubcode is used, then dietTypeSubcode SHALL be a value in (‘PESCA’, ‘LACTO_OVO_PESCA’, 'LACTO_PESCA’).-->
		<xsl:if test="dietTypeCode  = 'PESCATARIAN'">
			<xsl:choose>
				<xsl:when test="string(dietTypeSubcode) =  ''"/>
				<xsl:when test="dietTypeSubcode =  'PESCA'"/>
				<xsl:when test="dietTypeSubcode =  'LACTO_OVO_PESCA'"/>
				<xsl:when test="dietTypeSubcode =  'LACTO_PESCA'"/>
				<xsl:otherwise>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1705"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		
		<xsl:if test="dietTypeCode  = 'VEGETARIAN'">
			<xsl:choose>
				<xsl:when test="$targetMarket = '840'">
					<!--Rule 1707: If targetMarketcountrycode = ('840' (US)) and dietTypeCode equals ’VEGETARIAN’ and dietTypeSubcode is used, then dietTypeSubcode SHALL be a value in (‘OVO’, ‘LACTO ‘, ‘LACTO_OVO’, ‘PESCA’, ‘LACTO_OVO_PESCA’ or 'LACTO_PESCA’).-->
					<xsl:choose>
						<xsl:when test="string(dietTypeSubcode) =  ''"/>
						<xsl:when test="dietTypeSubcode =  'OVO'"/>
						<xsl:when test="dietTypeSubcode =  'LACTO'"/>
						<xsl:when test="dietTypeSubcode =  'LACTO_OVO'"/>
						<xsl:when test="dietTypeSubcode =  'PESCA'"/>
						<xsl:when test="dietTypeSubcode =  'LACTO_OVO_PESCA'"/>
						<xsl:when test="dietTypeSubcode =  'LACTO_PESCA'"/>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="1707"/>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<!--Rule 1706: If dietTypeCode equals ’VEGETARIAN’ and dietTypeSubcode is used and targetMarketCountryCode is not '840' (US), then dietTypeSubcode SHALL be a value in (‘OVO’, ‘LACTO ‘, ‘LACTO_OVO’).-->
					<xsl:choose>
						<xsl:when test="string(dietTypeSubcode) =  ''"/>
						<xsl:when test="dietTypeSubcode =  'OVO'"/>
						<xsl:when test="dietTypeSubcode =  'LACTO'"/>
						<xsl:when test="dietTypeSubcode =  'LACTO_OVO'"/>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="error">
								<xsl:with-param name="id" select="1706"/>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		
		</xsl:if>

		<!--Rule 1708: If dietTypeCode equals ’KOSHER’ and dietTypeSubcode is used, then dietTypeSubcode SHALL be a value in (‘MEAT’, ’FISH’, ‘DAIRY’, ‘PAREVE’, 'KOSHER_FOR_PASSOVER', ‘MEAT_FOR_PASSOVER’, ‘FISH_FOR_PASSOVER’, ‘DAIRY_FOR_PASSOVER’, ‘PAREVE_FOR_PASSOVER’, ‘DE’, ‘MEVUSHAL’, ‘KOSHER_FOR_PASSOVER_MEVUSHAL’).-->
		<xsl:if test="dietTypeCode  = 'KOSHER'">
			<xsl:choose>
				<xsl:when test="string(dietTypeSubcode) =  ''"/>
				<xsl:when test="dietTypeSubcode =  'MEAT'"/>
				<xsl:when test="dietTypeSubcode =  'FISH'"/>
				<xsl:when test="dietTypeSubcode =  'DAIRY'"/>
				<xsl:when test="dietTypeSubcode =  'PAREVE'"/>
				<xsl:when test="dietTypeSubcode =  'KOSHER_FOR_PASSOVER'"/>
				<xsl:when test="dietTypeSubcode =  'MEAT_FOR_PASSOVER'"/>
				<xsl:when test="dietTypeSubcode =  'FISH_FOR_PASSOVER'"/>
				<xsl:when test="dietTypeSubcode =  'DAIRY_FOR_PASSOVER'"/>
				<xsl:when test="dietTypeSubcode =  'PAREVE_FOR_PASSOVER'"/>
				<xsl:when test="dietTypeSubcode =  'DE'"/>
				<xsl:when test="dietTypeSubcode =  'MEVUSHAL'"/>
				<xsl:when test="dietTypeSubcode =  'KOSHER_FOR_PASSOVER_MEVUSHAL'"/>
				<xsl:otherwise>
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1708"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

	
		<xsl:if test="$targetMarket = '756'">

			<!--Rule 1946: If targetMarketCountryCode equals <Geographic> and dietTypeSubcode equals ('LACTO', 'LACTO_OVO' or 'OVO') then dietTypeCode SHALL equal 'VEGETARIAN'.-->
			<xsl:if test="dietTypeSubcode = 'LACTO' or dietTypeSubcode = 'LACTO_OVO' or dietTypeSubcode = 'OVO'">
				<xsl:if test="string(dietTypeCode) != 'VEGETARIAN'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1946" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>

			<!--Rule 2021: If targetMarketCountryCode equals <Geographic> and isDietTypeMarkedOnPackage is used then isDietTypeMarkedOnPackage SHALL equal ('TRUE' or 'FALSE').-->
			<xsl:if test="string(isDietTypeMarkedOnPackage) != '' and string(isDietTypeMarkedOnPackage) != 'FALSE' and string(isDietTypeMarkedOnPackage) != 'TRUE'">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="2021" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
		
	</xsl:template>

	<xsl:template match="dietCertification" mode="dietInformationModule">
		<xsl:param name="targetMarket"/>
		<xsl:apply-templates select="certificationOrganisationIdentifier" mode="gln"/>
		<xsl:apply-templates select="certification" mode="dietInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="certification" mode="dietInformationModule">
		<xsl:param name="targetMarket"/>
		<!--Rule 341: If a start dateTime and its corresponding end dateTime are not empty then the start date SHALL be less than or equal to corresponding end date. -->
		<xsl:if test="gs1:InvalidDateTimeSpan(certificationEffectiveStartDateTime, certificationEffectiveEndDateTime)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="341"/>
			</xsl:apply-templates>
		</xsl:if>
		<xsl:apply-templates select="referencedFileInformation" mode="dietInformationModule">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="referencedFileInformation" mode="dietInformationModule">
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
	</xsl:template>



</xsl:stylesheet>
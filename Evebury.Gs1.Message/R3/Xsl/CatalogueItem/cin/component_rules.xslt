<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="tradeItemComponents" mode="components">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>
		<xsl:param name="specialItemCode"/>


		<xsl:apply-templates select="componentInformation" mode="components">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
			<xsl:with-param name="tradeItem" select="$tradeItem"/>
			<xsl:with-param name="specialItemCode" select="$specialItemCode"/>
		</xsl:apply-templates>

		<xsl:variable name="root" select="."/>

		<!--Rule 1607: All iterations of componentNumber shall be unique within this tradeItem-->
		<xsl:for-each select="componentInformation/componentNumber">
			<xsl:variable name="value" select="."/>
			<xsl:if test="count($root/componentInformation[componentNumber = $value]) &gt; 1">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1607" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>

		<!--Rule 1610: If componentInformation is used, then componentIdentification shall be unique for each component.-->
		<xsl:for-each select="componentInformation/componentIdentification">
			<xsl:variable name="value" select="."/>
			<xsl:if test="count($root/componentInformation[componentIdentification = $value]) &gt; 1">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1610" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>


		<xsl:if test="$specialItemCode != 'DYNAMIC_ASSORTMENT'">
			<!--Rule 1604: If any attribute in class tradeItemComponents or class componentInformation is used, and specialItemcode does not equal 'DYNAMIC_ASSORTMENT' then numberOfPiecesInSet and totalNumberOfComponents shall be used.-->
			<xsl:if test="string(numberOfPiecesInSet)  = '' or string(totalNumberOfComponents) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1604" />
				</xsl:apply-templates>
			</xsl:if>
		
			<!--Rule 1606: If any attribute in tradeItemComponents or componentInformation is used, and specialItemCode does not equal 'DYNAMIC_ASSORTMENT', then totalNumberOfComponents shall be greater than '0'.-->
			<xsl:if test="string(totalNumberOfComponents) = '' or totalNumberOfComponents &lt;= 0">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1606" />
				</xsl:apply-templates>
			</xsl:if>

		</xsl:if>

		<!--Rule 1608: numberOfPiecesInSet shall equal the sum of componentQuantity of each child component.-->
		<xsl:if test="number(numberOfPiecesInSet) != sum(componentInformation/componentQuantity)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1608" />
			</xsl:apply-templates>
		</xsl:if>

		<!--Rule 1609: If componentInformation is used, then totalNumberOfComponents shall equal the number of iterations of class componentInformation.-->
		<xsl:if test="number(totalNumberOfComponents) != count(componentInformation)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1609" />
			</xsl:apply-templates>
		</xsl:if>


	</xsl:template>

	<xsl:template match="componentInformation" mode="components">
		<xsl:param name="targetMarket"/>
		<xsl:param name="tradeItem"/>
		<xsl:param name="specialItemCode"/>

		<xsl:if test="$specialItemCode != 'DYNAMIC_ASSORTMENT'">
			<!--Rule 1605: If any attribute in class componentInformation is used, and specialItemcode does not equal 'DYNAMIC_ASSORTMENT' then componentDescription and componentQuantity shall be used.-->
			<xsl:if test="string(componentDescription) = '' or string(componentQuantity) = ''">
				<xsl:apply-templates select="." mode="error">
					<xsl:with-param name="id" select="1605" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>

		<!--Rule 398: If gpcCategorycode is used, then its value shall be in the list of official GPC bricks as published by GS1 and currently adopted in production by GDSN.-->
		<xsl:variable name="brick" select="string(gpcCategoryCode)" />
		<xsl:if test="$brick != '' and gs1:InvalidBrick($brick)">
			<xsl:apply-templates select="gs1:AddEventData('brick', $brick)"/>
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="398" />
			</xsl:apply-templates>
		</xsl:if>

		<!--Rule 1550: There shall be at most 25 iterations of Class GDSNTradeItemClassificationAttribute per iteration of ComponentInformation/gpcCategoryCode.-->
		<xsl:if test="count(gDSNTradeItemClassificationAttribute) &gt; 25">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="1550" />
			</xsl:apply-templates>
		</xsl:if>

		<xsl:apply-templates select="extension/*" mode="module">
			<xsl:with-param name="targetMarket" select="$targetMarket"/>
			<xsl:with-param name="tradeItem" select="$tradeItem"/>
			<xsl:with-param name="component" select=".."/>
		</xsl:apply-templates>


		<xsl:choose>
			<xsl:when test="@identificationSchemeAgencyCode = 'GTIN_14'">
				<!--Rule 1669: If  compontentIdentification/identificationSchemeAgencyCode equals 'GTIN_14'  then  componentIdentification shall be exactly 14 digits long and have a valid check digit.-->
				<xsl:if test="gs1:InvalidGTIN(., 14)">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1669" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:when test="@identificationSchemeAgencyCode = 'GTIN_13'">
				<!--Rule 1671: If  compontentIdentification/identificationSchemeAgencyCode equals 'GTIN_13'  then  componentIdentification shall be exactly 13 digits long and have a valid check digit.-->
				<xsl:if test="gs1:InvalidGTIN(., 13)">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1671" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:when test="@identificationSchemeAgencyCode = 'GTIN_12'">
				<!--Rule 1673: If  compontentIdentification/identificationSchemeAgencyCode equals 'GTIN_12'  then  componentIdentification shall be exactly 12 digits long and have a valid check digit.-->
				<xsl:if test="gs1:InvalidGTIN(., 12)">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1673" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:when test="@identificationSchemeAgencyCode = 'GTIN_18'">
				<!--Rule 1675: If  compontentIdentification/identificationSchemeAgencyCode equals 'GTIN_8'  then  componentIdentification shall be exactly 8 digits long and have a valid check digit.-->
				<xsl:if test="gs1:InvalidGTIN(., 8)">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="1675" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
		</xsl:choose>

	</xsl:template>

</xsl:stylesheet>
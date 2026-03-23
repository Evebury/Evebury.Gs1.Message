<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1 ciw"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	xmlns:ciw="urn:gs1:gdsn:catalogue_item_hierarchical_withdrawal:xsd:3"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:variable name="version" select="'3.1'"/>

	<!-- region auxiliary -->

	<xsl:variable name="quote">
		<xsl:text>'</xsl:text>
	</xsl:variable>

	<xsl:variable name="EVENT_DATA_INFORMATION_PROVIDER" select="'information_provider'"/>
	<xsl:variable name="EVENT_DATA_XPATH" select="'xpath'"/>
	<xsl:variable name="EVENT_DATA_MARKET" select="'market'"/>
	<xsl:variable name="EVENT_DATA_TRADE_PARTNER" select="'trade_partner'"/>

	<xsl:template match="*" mode="error">
		<xsl:param name="id"/>
		<xsl:apply-templates select="." mode="xpath"/>
		<xsl:apply-templates select="gs1:AddErrorEvent($id)" />
	</xsl:template>

	<xsl:template match="*" mode="xpath">
		<xsl:param name="xpath" select="''"/>
		<xsl:variable name="name" select="local-name()"/>
		<xsl:choose>
			<xsl:when test="$name != 'catalogueItemHierarchicalWithdrawalMessage'">
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
								<xsl:value-of select="concat($EVENT_DATA_XPATH,'/',$xpath)"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="gs1:AddEventData('xpath', concat('/', name(), '/', $xpath))"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--endregion auxiliary -->

	<xsl:template match="/">
		<xsl:apply-templates select="gs1:BeginResponse($version)"/>
		<xsl:apply-templates select="ciw:catalogueItemHierarchicalWithdrawalMessage/transaction"/>
		<xsl:copy-of select="gs1:EndResponse()"/>
	</xsl:template>

	<xsl:template match="transaction">
		<xsl:apply-templates select="gs1:BeginTransaction(transactionIdentification/entityIdentification)"/>
		<xsl:apply-templates select="documentCommand" mode="r495"/>
		<xsl:apply-templates select="documentCommand/ciw:catalogueItemHierarchicalWithdrawal" mode="rules">
			<xsl:with-param name="command" select="documentCommand/documentCommandHeader/@type"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="gs1:EndTransaction()"/>
	</xsl:template>

	<!-- region rules -->
	<xsl:template match="*" mode="r447">
		<!--Rule 447: If attribute datatype is equal to gtin then it must have a valid check digit.-->
		<xsl:variable name="length" select="string-length(gtin)"/>
		<xsl:choose>
			<xsl:when test="$length = 14">
				<xsl:if test="gs1:InvalidGTIN(gtin, 14)">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="471" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$length = 13">
				<xsl:if test="gs1:InvalidGTIN(gtin, 13)">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="471" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$length = 12">
				<xsl:if test="gs1:InvalidGTIN(gtin, 12)">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="471" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$length = 8">
				<xsl:if test="gs1:InvalidGTIN(gtin, 8)">
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

	<xsl:template match="*" mode="r448">
		<!--Rule 448: If attribute datatype equals gln then it must be a 13 digit number and have a valid check digit.-->
		<xsl:if test="gs1:InvalidGTIN(catalogueItemHierarchicalWithdrawalIdentification/contentOwner/gln, 13)">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="448" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="r495">
		<!--Rule 495: There must be at most 100 Documents per transaction.-->
		<xsl:if test="count(ciw:catalogueItemPublication) &gt; 100">
			<xsl:apply-templates select="." mode="error">
				<xsl:with-param name="id" select="495" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="gtin">
		<!--Rule 471: If data type is equal to  gtin then attribute value must be a  valid GTIN-8, GTIN-12, GTIN-13 or GTIN-14 number.-->
		<xsl:variable name="length" select="string-length(gtin)"/>
		<xsl:choose>
			<xsl:when test="$length = 0"/>
			<xsl:when test="$length = 14">
				<xsl:if test="gs1:InvalidGTIN(gtin, 14)">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="471" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$length = 13">
				<xsl:if test="gs1:InvalidGTIN(gtin, 13)">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="471" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$length = 12">
				<xsl:if test="gs1:InvalidGTIN(gtin, 12)">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="id" select="471" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$length = 8">
				<xsl:if test="gs1:InvalidGTIN(gtin, 8)">
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

	<!-- end region rules -->

	<xsl:template match="*" mode="rules">
		<xsl:apply-templates select="gs1:BeginSequence()"/>
		<xsl:apply-templates select="gs1:AddSequenceEventData($EVENT_DATA_INFORMATION_PROVIDER, catalogueItemReference/dataSource)"/>
		<xsl:apply-templates select="gs1:AddSequenceEventData($EVENT_DATA_TRADE_PARTNER, catalogueItemReference/dataRecipient/gln)"/>
		<xsl:apply-templates select="gs1:AddSequenceEventData($EVENT_DATA_MARKET, catalogueItemReference/targetMarketCountryCode)"/>
		<xsl:apply-templates select="catalogueItemReference" mode="r447"/>

		<xsl:apply-templates select="gs1:EndSequence()"/>
	</xsl:template>

</xsl:stylesheet>
<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl">
	<xsl:output method="xml" indent="yes"/>


	<xsl:param name="type" select="'CatalogueItemNotification'"/>

	<xsl:variable name="quote">
		<xsl:text>'</xsl:text>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:element name="xsl:stylesheet">
			<!--<xsl:for-each select="Rules/Rule[@Name = $type]">
				<xsl:sort select="@Id" data-type="number"/>
				<xsl:apply-templates select="."/>
			</xsl:for-each>-->
			<xsl:apply-templates select="/Rules/Rule[@Name != $type][XPath[contains(@Path, 'catalogueItemHierarchicalWithdrawalMessage')]]"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Rule">
		<xsl:element name="xsl:template">
			<xsl:attribute name="match">
				<xsl:text>*</xsl:text>
			</xsl:attribute>
			<xsl:attribute name="mode">
				<xsl:text>r</xsl:text>
				<xsl:value-of select="@Id"/>
			</xsl:attribute>
			<xsl:if test="Market">
				<xsl:element name="xsl:param">
					<xsl:attribute name="name">
						<xsl:text>targetMarket</xsl:text>
					</xsl:attribute>
				</xsl:element>
			</xsl:if>
			<xsl:comment>
				<xsl:text>Rule </xsl:text>
				<xsl:value-of select="@Id"/>
				<xsl:text>: </xsl:text>
				<xsl:value-of select="@Rule"/>
			</xsl:comment>
			<xsl:apply-templates select="XPath" mode="variable"/>
			<xsl:if test="Market">
				<xsl:element name="xsl:variable">
					<xsl:attribute name="name">
						<xsl:text>isTargetMarket</xsl:text>
					</xsl:attribute>
					<xsl:attribute name="select">
						<xsl:text>contains('</xsl:text>
						<xsl:for-each select="Market">
							<xsl:value-of select="@Code"/>
							<xsl:if test="position() != last()">
								<xsl:text>, </xsl:text>
							</xsl:if>
						</xsl:for-each>
						<xsl:text>', $targetMarket)</xsl:text>
					</xsl:attribute>
				</xsl:element>
			</xsl:if>
			<xsl:element name="xsl:if">
				<xsl:attribute name="test">
					<xsl:text>$xpath = 'TODO'</xsl:text>
				</xsl:attribute>
				<xsl:element name="xsl:apply-templates">
					<xsl:attribute name="select">
						<xsl:text>.</xsl:text>
					</xsl:attribute>
					<xsl:attribute name="mode">
						<xsl:text>error</xsl:text>
					</xsl:attribute>
					<xsl:element name="xsl:with-param">
						<xsl:attribute name="name">
							<xsl:text>id</xsl:text>
						</xsl:attribute>
						<xsl:attribute name="select">
							<xsl:value-of select="@Id"/>
						</xsl:attribute>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="XPath" mode="variable">
		<xsl:variable name="index">
			<xsl:choose>
				<xsl:when test="position() = 1"></xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="position() - 1"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="xsl:variable">
			<xsl:attribute name="name">
				<xsl:value-of select="concat('xpath', $index)"/>
			</xsl:attribute>
			<xsl:attribute name="select">
				<xsl:value-of select="@Path"/>
			</xsl:attribute>
		</xsl:element>
	</xsl:template>


</xsl:stylesheet>
<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl">
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="/">
		<schema>
			<xsl:apply-templates select="schema/segment"/>
		</schema>
	</xsl:template>

	<xsl:template match="segment">
		<segment code="{@code}">
			<xsl:apply-templates select="family"/>
		</segment>
	</xsl:template>
	
	<xsl:template match="family">
		<family code="{@code}">
			<xsl:apply-templates select="class"/>
		</family>
	</xsl:template>
	
	<xsl:template match="class">
		<class code="{@code}">
			<xsl:apply-templates select="brick"/>
		</class>
	</xsl:template>

	<xsl:template match="brick">
		<brick code="{@code}"/>
	</xsl:template>

</xsl:stylesheet>
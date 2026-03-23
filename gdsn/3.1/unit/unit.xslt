<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl">
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="/">
		<Units>
			<xsl:apply-templates select="root/element[classId = '-1012663220']"/>
		</Units>
	</xsl:template>

	<xsl:template match="element">
		<Unit Name="{name}" Code="{codeValue}" Definition="{definition}"/>
	</xsl:template>
	

</xsl:stylesheet>
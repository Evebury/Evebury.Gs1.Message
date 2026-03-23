<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="/">
		<xs:schema
    targetNamespace="urn:iso:code"
    elementFormDefault="qualified"
    xmlns="urn:iso:code"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
>
			<xs:simpleType name="CountryCode">
				<xs:restriction base="xs:token">
					<xsl:apply-templates select="root/element"/>
				</xs:restriction>
			</xs:simpleType>
		</xs:schema>
	</xsl:template>

	<xsl:template match="element">
		<xs:enumeration value="{normalize-space(code)}">
			<xs:annotation>
				<xs:documentation>
					<xsl:value-of select="concat(normalize-space(name), ' (', alpha3, ')')"/>
				</xs:documentation>
			</xs:annotation>
		</xs:enumeration>
	</xsl:template>
	


</xsl:stylesheet>
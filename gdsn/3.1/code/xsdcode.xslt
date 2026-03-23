<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xsl:output method="xml" indent="yes"/>


	<xsl:template match="/">
		<xs:schema
    targetNamespace="urn:gs1:gdsn:code"
    elementFormDefault="qualified"
    xmlns="urn:gs1:gdsn:code"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
>
			<xsl:apply-templates select="Codes/Code"/>
		</xs:schema>
	</xsl:template>

	<xsl:template match="Code">
		<xs:complexType name="{@Type}_GS1CodeType">
			<xs:simpleContent>
				<xs:extension base="{@Type}">
					<xs:attribute name="codeListVersion">
						<xs:simpleType>
							<xs:restriction base="xs:string">
								<xs:maxLength value="35"/>
								<xs:minLength value="1"/>
							</xs:restriction>
						</xs:simpleType>
					</xs:attribute>
				</xs:extension>
			</xs:simpleContent>
		</xs:complexType>
		<xs:simpleType name="{@Type}">
			<xs:restriction base="xs:token">
				<xsl:apply-templates select="Value"/>
			</xs:restriction>
		</xs:simpleType>
	</xsl:template>

	<xsl:template match="Value">
		<xs:enumeration value="{@Value}"/>
	</xsl:template>

</xsl:stylesheet>
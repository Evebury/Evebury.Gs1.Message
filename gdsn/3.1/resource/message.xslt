<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl data" xmlns:data="urn:xdf:dataset">
	<xsl:output method="xml" indent="yes"/>


	<xsl:template match="/">
		<root>
			<!-- 
    Microsoft ResX Schema 
    
    Version 2.0
    
    The primary goals of this format is to allow a simple XML format 
    that is mostly human readable. The generation and parsing of the 
    various data types are done through the TypeConverter classes 
    associated with the data types.
    
    Example:
    
    ... ado.net/XML headers & schema ...
    <resheader name="resmimetype">text/microsoft-resx</resheader>
    <resheader name="version">2.0</resheader>
    <resheader name="reader">System.Resources.ResXResourceReader, System.Windows.Forms, ...</resheader>
    <resheader name="writer">System.Resources.ResXResourceWriter, System.Windows.Forms, ...</resheader>
    <data name="Name1"><value>this is my long string</value><comment>this is a comment</comment></data>
    <data name="Color1" type="System.Drawing.Color, System.Drawing">Blue</data>
    <data name="Bitmap1" mimetype="application/x-microsoft.net.object.binary.base64">
        <value>[base64 mime encoded serialized .NET Framework object]</value>
    </data>
    <data name="Icon1" type="System.Drawing.Icon, System.Drawing" mimetype="application/x-microsoft.net.object.bytearray.base64">
        <value>[base64 mime encoded string representing a byte array form of the .NET Framework object]</value>
        <comment>This is a comment</comment>
    </data>
                
    There are any number of "resheader" rows that contain simple 
    name/value pairs.
    
    Each data row contains a name, and value. The row also contains a 
    type or mimetype. Type corresponds to a .NET class that support 
    text/value conversion through the TypeConverter architecture. 
    Classes that don't support this are serialized and stored with the 
    mimetype set.
    
    The mimetype is used for serialized objects, and tells the 
    ResXResourceReader how to depersist the object. This is currently not 
    extensible. For a given mimetype the value must be set accordingly:
    
    Note - application/x-microsoft.net.object.binary.base64 is the format 
    that the ResXResourceWriter will generate, however the reader can 
    read any of the formats listed below.
    
    mimetype: application/x-microsoft.net.object.binary.base64
    value   : The object must be serialized with 
            : System.Runtime.Serialization.Formatters.Binary.BinaryFormatter
            : and then encoded with base64 encoding.
    
    mimetype: application/x-microsoft.net.object.soap.base64
    value   : The object must be serialized with 
            : System.Runtime.Serialization.Formatters.Soap.SoapFormatter
            : and then encoded with base64 encoding.

    mimetype: application/x-microsoft.net.object.bytearray.base64
    value   : The object must be serialized into a byte array 
            : using a System.ComponentModel.TypeConverter
            : and then encoded with base64 encoding.
    -->
			<xsd:schema id="root" xmlns="" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">
				<xsd:import namespace="http://www.w3.org/XML/1998/namespace" />
				<xsd:element name="root" msdata:IsDataSet="true">
					<xsd:complexType>
						<xsd:choice maxOccurs="unbounded">
							<xsd:element name="metadata">
								<xsd:complexType>
									<xsd:sequence>
										<xsd:element name="value" type="xsd:string" minOccurs="0" />
									</xsd:sequence>
									<xsd:attribute name="name" use="required" type="xsd:string" />
									<xsd:attribute name="type" type="xsd:string" />
									<xsd:attribute name="mimetype" type="xsd:string" />
									<xsd:attribute ref="xml:space" />
								</xsd:complexType>
							</xsd:element>
							<xsd:element name="assembly">
								<xsd:complexType>
									<xsd:attribute name="alias" type="xsd:string" />
									<xsd:attribute name="name" type="xsd:string" />
								</xsd:complexType>
							</xsd:element>
							<xsd:element name="data">
								<xsd:complexType>
									<xsd:sequence>
										<xsd:element name="value" type="xsd:string" minOccurs="0" msdata:Ordinal="1" />
										<xsd:element name="comment" type="xsd:string" minOccurs="0" msdata:Ordinal="2" />
									</xsd:sequence>
									<xsd:attribute name="name" type="xsd:string" use="required" msdata:Ordinal="1" />
									<xsd:attribute name="type" type="xsd:string" msdata:Ordinal="3" />
									<xsd:attribute name="mimetype" type="xsd:string" msdata:Ordinal="4" />
									<xsd:attribute ref="xml:space" />
								</xsd:complexType>
							</xsd:element>
							<xsd:element name="resheader">
								<xsd:complexType>
									<xsd:sequence>
										<xsd:element name="value" type="xsd:string" minOccurs="0" msdata:Ordinal="1" />
									</xsd:sequence>
									<xsd:attribute name="name" type="xsd:string" use="required" />
								</xsd:complexType>
							</xsd:element>
						</xsd:choice>
					</xsd:complexType>
				</xsd:element>
			</xsd:schema>
			<resheader name="resmimetype">
				<value>text/microsoft-resx</value>
			</resheader>
			<resheader name="version">
				<value>2.0</value>
			</resheader>
			<resheader name="reader">
				<value>System.Resources.ResXResourceReader, System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089</value>
			</resheader>
			<resheader name="writer">
				<value>System.Resources.ResXResourceWriter, System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089</value>
			</resheader>
			<xsl:apply-templates select="root/element[messageName = 'CatalogueItemNotification']"/>
		</root>
	</xsl:template>


	<xsl:template match="element">
		<xsl:variable name="code" select="msxsl:node-set($codes)/Codes"/>
		<xsl:variable name="id" select="id"/>
		<xsl:choose>
			<xsl:when test="$code/Ignore/Code[@Id = $id]"/>
			<xsl:otherwise>
				<xsl:variable name="message">
					<xsl:choose>
						<xsl:when test="$code/Messages/Message[@Id = $id]">
							<xsl:value-of select="$code/Messages/Message[@Id = $id]/@Message"/>
						</xsl:when>
						<xsl:when test="contains(errorMessageDescription, '&#xD;')">
							<xsl:value-of select="substring-before(errorMessageDescription, '&#xD;')"/>
						</xsl:when>
						<xsl:when test="contains(errorMessageDescription, '&#xA;')">
							<xsl:value-of select="substring-before(errorMessageDescription, '&#xA;')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="errorMessageDescription"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<data name="{$id}" xml:space="preserve">
			<value><xsl:value-of select="$message"/></value>
		</data>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:variable name="codes">
		<Codes>
			<Messages>
				<Message Id="1045" Message="There must be at most one iteration per language."/>
				<Message Id="1049" Message="There must be at most one iteration per unit."/>
			</Messages>
			<Ignore>
				<Code Id="1046"/>
				<Code Id="1047"/>
				<Code Id="1048"/>
				<Code Id="1050"/>
				<Code Id="1055"/>
				<Code Id="1056"/>
				<Code Id="1068"/>
				<Code Id="1069"/>
				<Code Id="1070"/>
				<Code Id="1071"/>
				<Code Id="1072"/>
				<Code Id="1073"/>
				<Code Id="1074"/>
				<Code Id="1075"/>
				<Code Id="1178"/>
				<Code Id="1179"/>
				<Code Id="1180"/>
				<Code Id="1181"/>
				<Code Id="1182"/>
				<Code Id="1184"/>
				<Code Id="1185"/>
				<Code Id="1186"/>
				<Code Id="1190"/>
				<Code Id="1191"/>
				<Code Id="1192"/>
				<Code Id="1193"/>
				<Code Id="1194"/>
				<Code Id="1198"/>
				<Code Id="1199"/>
				<Code Id="1200"/>
				<Code Id="1206"/>
				<Code Id="1208"/>
				<Code Id="1213"/>
				<Code Id="1214"/>
				<Code Id="1215"/>
				<Code Id="1216"/>
				<Code Id="1219"/>
				<Code Id="1220"/>
				<Code Id="1223"/>
				<Code Id="1224"/>
				<Code Id="1225"/>
				<Code Id="1226"/>
				<Code Id="1228"/>
				<Code Id="1229"/>
				<Code Id="1230"/>
				<Code Id="1237"/>
				<Code Id="1238"/>
				<Code Id="1239"/>
				<Code Id="1240"/>
				<Code Id="1241"/>
				<Code Id="1242"/>
				<Code Id="1243"/>
				<Code Id="1244"/>
				<Code Id="1245"/>
				<Code Id="1246"/>
				<Code Id="1247"/>
				<Code Id="1249"/>
				<Code Id="1250"/>
				<Code Id="1251"/>
				<Code Id="1253"/>
				<Code Id="1254"/>
				<Code Id="1255"/>
				<Code Id="1256"/>
				<Code Id="1257"/>
				<Code Id="1258"/>
				<Code Id="1259"/>
				<Code Id="1260"/>
				<Code Id="1261"/>
				<Code Id="1262"/>
				<Code Id="1263"/>
				<Code Id="1265"/>
				<Code Id="1267"/>
				<Code Id="1269"/>
				<Code Id="1270"/>
				<Code Id="1272"/>
				<Code Id="1273"/>
				<Code Id="1274"/>
				<Code Id="1334"/>
				<Code Id="1381"/>
				<Code Id="1382"/>
				<Code Id="1383"/>
				<Code Id="1384"/>
				<Code Id="1385"/>
				<Code Id="1386"/>
				<Code Id="1387"/>
				<Code Id="1388"/>
				<Code Id="1389"/>
				<Code Id="1390"/>
				<Code Id="1391"/>
				<Code Id="1394"/>
				<Code Id="1405"/>
				<Code Id="1461"/>
				<Code Id="1462"/>
				<Code Id="1463"/>
				<Code Id="1464"/>
				<Code Id="1465"/>
				<Code Id="1466"/>
				<Code Id="1467"/>
				<Code Id="1468"/>
				<Code Id="1469"/>
				<Code Id="1471"/>
				<Code Id="1474"/>
				<Code Id="1476"/>
				<Code Id="1477"/>
				<Code Id="1478"/>
				<Code Id="1479"/>
				<Code Id="1483"/>
				<Code Id="1484"/>
				<Code Id="1485"/>
				<Code Id="1486"/>
				<Code Id="1487"/>
				<Code Id="1488"/>
				<Code Id="1489"/>
				<Code Id="1490"/>
				<Code Id="1491"/>
				<Code Id="1492"/>
				<Code Id="1493"/>
				<Code Id="1494"/>
				<Code Id="1495"/>
				<Code Id="1496"/>
				<Code Id="1498"/>
				<Code Id="1499"/>
				<Code Id="1500"/>
				<Code Id="1502"/>
				<Code Id="1504"/>
				<Code Id="1506"/>
				<Code Id="1507"/>
				<Code Id="1508"/>
				<Code Id="1509"/>
				<Code Id="1510"/>
				<Code Id="1511"/>
				<Code Id="1513"/>
				<Code Id="1514"/>
				<Code Id="1515"/>
				<Code Id="1516"/>
				<Code Id="1517"/>
				<Code Id="1520"/>
				<Code Id="1521"/>
				<Code Id="1522"/>
				<Code Id="1523"/>
				<Code Id="1525"/>
				<Code Id="1546"/>
				<Code Id="1547"/>
				<Code Id="1555"/>
				<Code Id="1556"/>
				<Code Id="1560"/>
				<Code Id="1561"/>
				<Code Id="1587"/>
				<Code Id="1590"/>
				<Code Id="1619"/>
				<Code Id="1623"/>
				<Code Id="1624"/>
				<Code Id="1625"/>
				<Code Id="1626"/>
				<Code Id="1627"/>
				<Code Id="1628"/>
				<Code Id="1630"/>
				<Code Id="1633"/>
				<Code Id="1634"/>
				<Code Id="1635"/>
				<Code Id="1636"/>
				<Code Id="1666"/>
				<Code Id="1668"/>
				<Code Id="1679"/>
				<Code Id="1680"/>
				<Code Id="1701"/>
				<Code Id="1711"/>
				<Code Id="1712"/>
				<Code Id="1730"/>
				<Code Id="1732"/>
				<Code Id="1733"/>
				<Code Id="1736"/>
				<Code Id="1737"/>
				<Code Id="1826"/>
				<Code Id="1828"/>
				<Code Id="1829"/>
				<Code Id="1843"/>
				<Code Id="1853"/>
				<Code Id="1872"/>
				<Code Id="1873"/>
				<Code Id="2042"/>
				<Code Id="2073"/>
				<Code Id="2074"/>
				<Code Id="2076"/>
				<Code Id="1051"/>
				<Code Id="1052"/>
				<Code Id="1053"/>
				<Code Id="1054"/>
				<Code Id="1187"/>
				<Code Id="1188"/>
				<Code Id="1196"/>
				<Code Id="1197"/>
				<Code Id="1202"/>
				<Code Id="1203"/>
				<Code Id="1204"/>
				<Code Id="1205"/>
				<Code Id="1207"/>
				<Code Id="1212"/>
				<Code Id="1218"/>
				<Code Id="1221"/>
				<Code Id="1222"/>
				<Code Id="1234"/>
				<Code Id="1235"/>
				<Code Id="1266"/>
				<Code Id="1336"/>
				<Code Id="1337"/>
				<Code Id="1392"/>
				<Code Id="1393"/>
				<Code Id="1395"/>
				<Code Id="1396"/>
				<Code Id="1397"/>
				<Code Id="1400"/>
				<Code Id="1401"/>
				<Code Id="1402"/>
				<Code Id="1472"/>
				<Code Id="1473"/>
				<Code Id="1503"/>
				<Code Id="1512"/>
				<Code Id="1518"/>
				<Code Id="1519"/>
				<Code Id="1526"/>
				<Code Id="1527"/>
				<Code Id="1528"/>
				<Code Id="1529"/>
				<Code Id="1530"/>
				<Code Id="1531"/>
				<Code Id="1532"/>
				<Code Id="1533"/>
				<Code Id="1534"/>
				<Code Id="1535"/>
				<Code Id="1536"/>
				<Code Id="1537"/>
				<Code Id="1539"/>
				<Code Id="1540"/>
				<Code Id="1542"/>
				<Code Id="1543"/>
				<Code Id="1549"/>
				<Code Id="1559"/>
				<Code Id="1572"/>
				<Code Id="1573"/>
				<Code Id="1586"/>
				<Code Id="1588"/>
				<Code Id="1621"/>
				<Code Id="1632"/>
				<Code Id="1681"/>
				<Code Id="1682"/>
				<Code Id="1700"/>
				<Code Id="1709"/>
				<Code Id="1710"/>
				<Code Id="1725"/>
				<Code Id="1728"/>
				<Code Id="1729"/>
				<Code Id="1731"/>
				<Code Id="1738"/>
				<Code Id="1750"/>
				<Code Id="1751"/>
				<Code Id="1786"/>
				<Code Id="1795"/>
				<Code Id="1796"/>
				<Code Id="1797"/>
				<Code Id="1798"/>
				<Code Id="1827"/>
				<Code Id="1831"/>
				<Code Id="1844"/>
				<Code Id="1846"/>
				<Code Id="1871"/>
				<Code Id="2040"/>
				<Code Id="2041"/>
				<Code Id="2045"/>
				<Code Id="455"/>
				<Code Id="1195"/>
				<Code Id="1201"/>
				<Code Id="1248"/>
				<Code Id="1264"/>
				<Code Id="1271"/>
				<Code Id="1284"/>
				<Code Id="1285"/>
				<Code Id="1286"/>
				<Code Id="1287"/>
				<Code Id="1335"/>
				<Code Id="1403"/>
				<Code Id="1404"/>
				<Code Id="1501"/>
				<Code Id="1544"/>
				<Code Id="1545"/>
				<Code Id="1551"/>
				<Code Id="1552"/>
				<Code Id="1571"/>
				<Code Id="1589"/>
				<Code Id="1631"/>
				<Code Id="1667"/>
				<Code Id="1726"/>
				<Code Id="1727"/>
				<Code Id="1734"/>
				<Code Id="1912"/>
				<Code Id="1913"/>
				<Code Id="2046"/>
			</Ignore>
		</Codes>
	</xsl:variable>
</xsl:stylesheet>


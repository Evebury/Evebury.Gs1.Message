<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1 sh"
	xmlns:gs1="urn:xsl:extension:gdsn:gs1:response" xmlns:sh="http://www.unece.org/cefact/namespaces/StandardBusinessDocumentHeader"  xmlns="urn:evebury:gdsn:gs1:response:1"
	>
	<xsl:output method="xml" indent="yes"/>
	<xsl:template match="/">
		<Response>
			<xsl:attribute name="Id">
				<xsl:variable name="id">
					<xsl:value-of select="/*/gS1Response/originatingMessageIdentifier/entityIdentification"/>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$id != ''">
						<xsl:value-of select="$id"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="gs1:RandomId()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="TimeStamp">
				<xsl:variable name="timeStamp">
					<xsl:value-of select="/*/sh:StandardBusinessDocumentHeader/sh:DocumentIdentification/sh:CreationDateAndTime"/>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$timeStamp != ''">
						<xsl:value-of select="$timeStamp"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="gs1:TimeStamp()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="Status">
				<xsl:choose>
					<xsl:when test="/*/gS1Response/gS1Exception">
						<xsl:text>ERROR</xsl:text>
					</xsl:when>
					<xsl:when test="/*/gS1Response/transactionResponse[responseStatusCode = 'REJECTED']">
						<xsl:text>ERROR</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>OK</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="/*/gS1Response/gS1Exception/messageException">
					<Transactions>
						<Transaction Id="{gs1:RandomId()}" Status="REJECTED">
							<Events>
								<xsl:for-each select="/*/gS1Response/gS1Exception/messageException/gS1Error">
									<Event Id="{errorCode}" Message="{errorDescription}" Level="ERROR"/>
								</xsl:for-each>
							</Events>
						</Transaction>
					</Transactions>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="/*/gS1Response"/>
				</xsl:otherwise>
			</xsl:choose>
		</Response>
	</xsl:template>

	<xsl:template match="gS1Response">
		<xsl:if test="transactionResponse">
			<Transactions>
				<xsl:apply-templates select="transactionResponse"/>
			</Transactions>
		</xsl:if>
	</xsl:template>

	<xsl:template match="transactionResponse">
		<xsl:variable name="id" select="transactionIdentifier/entityIdentification"/>
		<Transaction Id="{$id}" Status="{responseStatusCode}">
			<xsl:variable name="events" select="/*/gS1Response/gS1Exception/transactionException[entityIdentification/entityIdentification = $id]/gS1Error"/>
			<xsl:if test="$events">
				<Events>
					<xsl:for-each select="$events">
						<Event Id="{errorCode}" Message="{errorDescription}" Level="ERROR"/>
					</xsl:for-each>
				</Events>
			</xsl:if>
		</Transaction>
	</xsl:template>

</xsl:stylesheet>
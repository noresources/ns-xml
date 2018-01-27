<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" version="1.0">
	<xsl:import href="../../../ns/xsl/strings.xsl" />

	<xsl:output method="text" encoding="utf-8" />

	<xsl:template match="/">
		<xsl:apply-templates select="./text" />
	</xsl:template>

	<xsl:template match="//text()">
		<xsl:call-template name="str.base64ToHex">
			<xsl:with-param name="text" select="." />
		</xsl:call-template>
		<xsl:value-of select="$str.unix.endl" />
	</xsl:template>
</xsl:stylesheet>

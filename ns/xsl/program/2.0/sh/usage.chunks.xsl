<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 - 2021 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Usage chunks for usage -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	<xsl:import href="../usage.chunks.xsl" />

	<xsl:param name="prg.sh.usage.indentChar">
		<xsl:text>  </xsl:text>
	</xsl:param>

	<!-- override default param prg.usage.indentChar -->
	<xsl:variable name="prg.usage.indentChar" select="$prg.sh.usage.indentChar" />
	<xsl:template match="prg:details/text()">
		<xsl:value-of select="normalize-space(.)" />
	</xsl:template>

	<xsl:template match="prg:block">
		<xsl:value-of select="$str.endl" />
		<xsl:call-template name="str.prependLine">
			<xsl:with-param name="prependedText" select="$prg.usage.indentChar" />
			<xsl:with-param name="text">
				<xsl:call-template name="prg.usage.descriptionDisplay" />
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- Name of the usage() function -->
	<xsl:variable name="prg.sh.usage.usageFunctionName">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:text>usage</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
</xsl:stylesheet>

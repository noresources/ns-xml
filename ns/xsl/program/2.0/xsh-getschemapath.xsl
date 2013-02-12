<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:bash="http://xsd.nore.fr/bash" xmlns:xsh="http://xsd.nore.fr/xsh">

	<xsl:output method="text" encoding="utf-8" />

	<xsl:template match="/">
		<xsl:value-of select="name(.)" />
		<xsl:choose>
			<xsl:when test="xsh:program">
				<xsl:text>xsh/1.0/xsh.xsd</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>bash.xsd</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>

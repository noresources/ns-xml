<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2018 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Generate option parsing code for shell programs -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	<xsl:import href="parser.chunks.xsl" />
	<xsl:import href="parser.functions.xsl" />
	
	<xsl:output method="text" indent="no" encoding="utf-8" />
	
	<!-- Default behavior for 'standalone' program interface definition file -->
	<xsl:template match="/">
		<xsl:call-template name="prg.sh.parser.main">
			<xsl:with-param name="programNode" select="/prg:program" />
		</xsl:call-template>
	</xsl:template>
</xsl:stylesheet>
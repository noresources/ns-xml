<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Base templates for XUL UI elements -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" xmlns:xul="http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul">

	<xsl:import href="base.xsl" />
	
	<xsl:variable name="prg.xul.availableSubcommands" select="/prg:program/prg:subcommands/prg:subcommand[not(prg:ui/@mode = 'disabled')]" />

	<xsl:template name="prg.xul.subCommandLabel">
		<xsl:param name="subcommandNode" select="." />
		<xsl:choose>
			<xsl:when test="$subcommandNode/prg:ui/prg:label">
				<xsl:value-of select="$subcommandNode/prg:ui/prg:label" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="prg:name" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>

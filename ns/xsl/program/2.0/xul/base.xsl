<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Basic includes and parameter relative to XUL application generation -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">

	<xsl:import href="../base.xsl" />

	<!-- platform name ("linux" or "osx") -->
	<xsl:param name="prg.xul.platform" />

	<xsl:param name="prg.xul.appName">
		<xsl:value-of select="/prg:program/prg:name" />
	</xsl:param>
	
	<xsl:param name="prg.xul.js.mainWindowInstanceName">
		<xsl:value-of select="$prg.xul.appName" /><xsl:text>MainWindow</xsl:text>
	</xsl:param>
	
	<xsl:param name="prg.xul.js.applicationInstanceName">
		<xsl:value-of select="$prg.xul.appName" /><xsl:text>Application</xsl:text>
	</xsl:param>

	<!-- Id for anonymous value command line parameters -->
	<xsl:template name="prg.xul.valueId">
		<xsl:param name="valueNode" select="." />
		<xsl:param name="index" />

		<xsl:variable name="grandParent" select="$valueNode/../.." />

		<xsl:text>VALUE_</xsl:text>
		<xsl:if test="$grandParent/self::prg:subcommand">
			<xsl:value-of select="$grandParent/prg:name" />
			<xsl:text>_</xsl:text>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="$valueNode/self::prg:value">
				<xsl:value-of select="$index"></xsl:value-of>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>OTHER</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2013 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!--  -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	<xsl:output method="text" encoding="utf-8" />

	<!-- Add php markers -->
	<xsl:param name="prg.php.phpmarkers" select="true()" />

	<!-- Set current namespace -->
	<xsl:param name="prg.php.programinfo.namespace" select="''" />

	<!-- PHP Parser base class namespace -->
	<xsl:param name="prg.php.parser.namespace" select="''" />

	<!-- Local item index -->
	<xsl:template name="prg.php.itemLocalIndex">
		<xsl:param name="itemNode" select="." />
		<xsl:param name="rootNode" select="$itemNode/.." />
		<xsl:for-each select="$rootNode/*">
			<xsl:if test="$itemNode = .">
				<xsl:value-of select="position() - 1" />
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- Canonical class name of the Parser base classes -->
	<xsl:template name="prg.php.base.classname">
		<xsl:param name="classname" />

		<xsl:text>\</xsl:text>
		<xsl:if test="string-length($prg.php.parser.namespace) &gt; 1 and ($prg.php.parser.namespace != '\')">
			<xsl:value-of select="$prg.php.parser.namespace" />
			<xsl:text>\</xsl:text>
		</xsl:if>
		<xsl:value-of select="$classname" />
	</xsl:template>
	
</xsl:stylesheet>

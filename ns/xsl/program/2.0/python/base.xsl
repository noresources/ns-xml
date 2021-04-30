<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2018 - 2021 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Parameters, variables and basic templates of the Python parser -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	<xsl:output method="text" encoding="utf-8" />

	<!-- Name of Python parser module -->
	<xsl:param name="prg.python.parser.modulename" select="'Parser'" />

	<!-- generateBase, generateInfo, generateEmbedded or generateMerge -->
	<xsl:param name="prg.python.generationMode" />

	<xsl:variable name="prg.python.codingHint">
		<xsl:text># -*- coding: utf-8 -*-</xsl:text>
		<xsl:value-of select="$str.endl" />
	</xsl:variable>

	<xsl:variable name="prg.python.copyright">
		<xsl:text>""" Copyright © 2018 - 2021 by Renaud Guillard """</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:text>""" Distributed under the terms of the MIT License, see LICENSE """</xsl:text>
		<xsl:value-of select="$str.endl" />
	</xsl:variable>

	<!-- Local item index -->
	<xsl:template name="prg.python.itemLocalIndex">
		<xsl:param name="itemNode" select="." />
		<xsl:param name="rootNode" select="$itemNode/.." />
		<xsl:for-each select="$rootNode/*">
			<xsl:if test="$itemNode = .">
				<xsl:value-of select="position() - 1" />
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- Canonical class name of the Parser base classes -->
	<xsl:template name="prg.python.base.classname">
		<xsl:param name="classname" />

		<xsl:variable name="sameFile" select="($prg.python.generationMode = 'generateEmbedded') or ($prg.python.generationMode = 'generateMerge')" />

		<xsl:if test="not ($sameFile) and string-length($prg.python.parser.modulename) &gt; 0">
			<xsl:value-of select="$prg.python.parser.modulename" />
			<xsl:text>.</xsl:text>
		</xsl:if>
		<xsl:value-of select="$classname" />
	</xsl:template>

</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2018 - 2020 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Generate program parser source code -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	<xsl:import href="parser.generic-source.xsl" />
	<xsl:import href="parser.info.xsl" />
	<xsl:import href="parser.results.xsl" />
	<xsl:import href="parser.functions.xsl" />
	<xsl:output method="text" encoding="utf-8" />
	<xsl:template match="/prg:program">
		<!-- Embed generic source (if asked) -->
		<xsl:if test="string-length($prg.c.parser.nsxmlHeaderPath) = 0">
			<xsl:value-of select="$prg.c.parser.genericSource" />
			<xsl:value-of select="$str.endl" />
		</xsl:if>
		<xsl:call-template name="c.comment">
			<xsl:with-param name="content">
				<xsl:text>Parser and utility functions dedicated to </xsl:text>
				<xsl:value-of select="./prg:name" />
			</xsl:with-param>
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />
		<!-- Or include our header (prg.c.parser.header.filePath) -->
		<xsl:if test="string-length($prg.c.parser.nsxmlHeaderPath) &gt; 0">
			<xsl:text># include "</xsl:text>
			<xsl:value-of select="$prg.c.parser.header.filePath" />
			<xsl:text>"</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>
		<xsl:text>#if defined(__cplusplus)</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:text>#include &lt;cstring&gt;</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:text>extern "C" {</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:text>#else</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:text>#include &lt;string.h&gt;</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:text>#endif</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:call-template name="prg.c.parser.programInfoInitFunctionDefinition">
			<xsl:with-param name="programNode" select="." />
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />
		<xsl:call-template name="prg.c.parser.programInfoNewFunctionDefinition">
			<xsl:with-param name="programNode" select="." />
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />
		<xsl:call-template name="prg.c.parser.programInfoCleanupFunctionDefinition">
			<xsl:with-param name="programNode" select="." />
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />
		<xsl:call-template name="prg.c.parser.programInfoFreeFunctionDefinition">
			<xsl:with-param name="programNode" select="." />
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />
		<xsl:call-template name="prg.c.parser.programResultFreeFunctionDefinition">
			<xsl:with-param name="programNode" select="." />
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />
		<!-- Result message helper functions -->
		<xsl:call-template name="prg.c.parser.programResultErrorCountFunctionDefinition" />
		<xsl:value-of select="$str.endl" />
		<xsl:call-template name="prg.c.parser.programResultGetMessageFunctionDefinition">
			<xsl:with-param name="type" select="'warning'" />
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />
		<xsl:call-template name="prg.c.parser.programResultGetMessageFunctionDefinition">
			<xsl:with-param name="type" select="'error'" />
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />
		<xsl:call-template name="prg.c.parser.programResultGetMessageFunctionDefinition">
			<xsl:with-param name="type" select="'fatal_error'" />
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />
		<xsl:call-template name="prg.c.parser.programResultDisplayErrorsFunctionDefinition" />
		<xsl:value-of select="$str.endl" />
		<xsl:call-template name="prg.c.parser.usageFunctionDefinition" />
		<xsl:value-of select="$str.endl" />
		<xsl:call-template name="prg.c.parser.parseFunctionDefinition" />
		<xsl:value-of select="$str.endl" />
		<xsl:text>#if defined(__cplusplus)</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:text>} /*extern "C" */</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:text>#endif</xsl:text>
		<xsl:value-of select="$str.endl" />
	</xsl:template>

</xsl:stylesheet>

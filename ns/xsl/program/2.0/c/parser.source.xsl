<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Generate program parser source code -->
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" version="1.0">
	<import href="parser.generic-source.xsl"/>
	<import href="parser.info.xsl"/>
	<import href="parser.results.xsl"/>
	<import href="parser.functions.xsl"/>
	<output method="text" encoding="utf-8"/>
	<template match="/prg:program">
		<!-- Embed generic source (if asked) -->
		<if test="string-length($prg.c.parser.nsxmlHeaderPath) = 0">
			<value-of select="$prg.c.parser.genericSource"/>
			<call-template name="endl"/>
		</if>
		<call-template name="c.comment">
			<with-param name="content">
				<text>Parser and utility functions dedicated to </text>
				<value-of select="./prg:name"/>
			</with-param>
		</call-template>
		<call-template name="endl"/>
		<!-- Or include our header (prg.c.parser.header.filePath) -->
		<if test="string-length($prg.c.parser.nsxmlHeaderPath) &gt; 0">
			<text># include "</text>
			<value-of select="$prg.c.parser.header.filePath"/>
			<text>"</text>
			<call-template name="endl"/>
		</if>
		<text>#if defined(__cplusplus)</text>
		<call-template name="endl"/>
		<text>#include &lt;cstring&gt;</text>
		<call-template name="endl"/>
		<text>extern "C" {</text>
		<call-template name="endl"/>
		<text>#else</text>
		<call-template name="endl"/>
		<text>#include &lt;string.h&gt;</text>
		<call-template name="endl"/>
		<text>#endif</text>
		<call-template name="endl"/>
		<call-template name="prg.c.parser.programInfoInitFunctionDefinition">
			<with-param name="programNode" select="."/>
		</call-template>
		<call-template name="endl"/>
		<call-template name="prg.c.parser.programInfoNewFunctionDefinition">
			<with-param name="programNode" select="."/>
		</call-template>
		<call-template name="endl"/>
		<call-template name="prg.c.parser.programInfoCleanupFunctionDefinition">
			<with-param name="programNode" select="."/>
		</call-template>
		<call-template name="endl"/>
		<call-template name="prg.c.parser.programInfoFreeFunctionDefinition">
			<with-param name="programNode" select="."/>
		</call-template>
		<call-template name="endl"/>
		<call-template name="prg.c.parser.programResultFreeFunctionDefinition">
			<with-param name="programNode" select="."/>
		</call-template>
		<call-template name="endl"/>
		<!-- Result message helper functions -->
		<call-template name="prg.c.parser.programResultErrorCountFunctionDefinition"/>
		<call-template name="endl"/>
		<call-template name="prg.c.parser.programResultGetMessageFunctionDefinition">
			<with-param name="type" select="'warning'"/>
		</call-template>
		<call-template name="endl"/>
		<call-template name="prg.c.parser.programResultGetMessageFunctionDefinition">
			<with-param name="type" select="'error'"/>
		</call-template>
		<call-template name="endl"/>
		<call-template name="prg.c.parser.programResultGetMessageFunctionDefinition">
			<with-param name="type" select="'fatal_error'"/>
		</call-template>
		<call-template name="endl"/>
		<call-template name="prg.c.parser.programResultDisplayErrorsFunctionDefinition"/>
		<call-template name="endl"/>
		<call-template name="prg.c.parser.usageFunctionDefinition"/>
		<call-template name="endl"/>
		<call-template name="prg.c.parser.parseFunctionDefinition"/>
		<call-template name="endl"/>
		<text>#if defined(__cplusplus)</text>
		<call-template name="endl"/>
		<text>} /*extern "C" */</text>
		<call-template name="endl"/>
		<text>#endif</text>
		<call-template name="endl"/>
	</template>

</stylesheet>

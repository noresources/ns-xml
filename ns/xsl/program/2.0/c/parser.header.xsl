<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the BSD License, see LICENSE -->

<!-- Generate program parser header -->
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" version="1.0">
	<import href="parser.generic-header.xsl"/>
	<import href="parser.info.xsl"/>
	<import href="parser.results.xsl"/>
	<import href="parser.functions.xsl"/>
	<output method="text" encoding="utf-8"/>
	<param name="prg.c.parser.header.filePath" select="'cmdline.h'"/>
	<variable name="prg.c.parser.header.preprocessorFileDefine">
		<text>__</text>
		<call-template name="c.validIdentifierName">
			<with-param name="name" select="translate(normalize-space($prg.c.parser.prefix),'-','_')"/>
		</call-template>
		<text>_</text>
		<call-template name="c.validIdentifierName">
			<with-param name="name" select="translate(normalize-space($prg.c.parser.header.filePath),'.-/','_')"/>
		</call-template>
		<text>__</text>
	</variable>
	<output method="text" encoding="utf-8"/>
	<template match="/prg:program">
		<!-- Embed generic header if asked -->
		<if test="string-length($prg.c.parser.nsxmlHeaderPath) = 0">
			<value-of select="$prg.c.parser.genericHeader"/>
			<call-template name="endl"/>
		</if>
		<call-template name="c.preprocessor.ifndef">
			<with-param name="condition" select="$prg.c.parser.header.preprocessorFileDefine"/>
			<with-param name="then">
				<text>#define </text>
				<value-of select="$prg.c.parser.header.preprocessorFileDefine"/>
				<call-template name="endl"/>
				<if test="string-length($prg.c.parser.nsxmlHeaderPath) &gt; 0">
					<!-- include nsxml header (expect the same naming style) -->
					<text># include "</text>
					<value-of select="$prg.c.parser.nsxmlHeaderPath"/>
					<text>"</text>
					<call-template name="endl"/>
				</if>
				<text>#if defined(__cplusplus)</text>
				<call-template name="endl"/>
				<text>extern "C" {</text>
				<call-template name="endl"/>
				<text>#endif</text>
				<call-template name="endl"/>
				<!-- Declare info functions and structs -->
				<call-template name="prg.c.parser.programInfoTypedefs"/>
				<call-template name="endl"/>
				<call-template name="prg.c.parser.programInfoInitFunctionDeclaration">
					<with-param name="programNode" select="."/>
				</call-template>
				<call-template name="endl"/>
				<call-template name="prg.c.parser.programInfoNewFunctionDeclaration">
					<with-param name="programNode" select="."/>
				</call-template>
				<call-template name="endl"/>
				<call-template name="prg.c.parser.programInfoCleanupFunctionDeclaration">
					<with-param name="programNode" select="."/>
				</call-template>
				<call-template name="endl"/>
				<call-template name="prg.c.parser.programInfoFreeFunctionDeclaration">
					<with-param name="programNode" select="."/>
				</call-template>
				<call-template name="endl"/>
				<!-- Declare subcommand results -->
				<!-- 
				<if test="./prg:subcommands">
					<for-each select="./prg:subcommands/prg:subcommand[prg:options]">
						<call-template name="prg.c.parser.subcommandResultDefinition" />
					</for-each>
					<call-template name="endl" />
				</if>
				 -->
				<call-template name="prg.c.parser.programResultDefinition"/>
				<call-template name="endl"/>
				<call-template name="prg.c.parser.programResultFreeFunctionDeclaration">
					<with-param name="programNode" select="."/>
				</call-template>
				<call-template name="endl"/>
				<call-template name="prg.c.parser.programResultErrorCountFunctionDeclaration"/>
				<call-template name="endl"/>
				<!-- Result message helper functions -->
				<call-template name="prg.c.parser.programResultGetMessageFunctionDeclaration">
					<with-param name="type" select="'warning'"/>
				</call-template>
				<call-template name="endl"/>
				<call-template name="prg.c.parser.programResultGetMessageFunctionDeclaration">
					<with-param name="type" select="'error'"/>
				</call-template>
				<call-template name="endl"/>
				<call-template name="prg.c.parser.programResultGetMessageFunctionDeclaration">
					<with-param name="type" select="'fatal_error'"/>
				</call-template>
				<call-template name="endl"/>
				<call-template name="prg.c.parser.programResultDisplayErrorsFunctionDeclaration"/>
				<call-template name="endl"/>
				<call-template name="prg.c.parser.usageFunctionDeclaration"/>
				<call-template name="endl"/>
				<call-template name="prg.c.parser.parseFunctionDeclaration"/>
				<call-template name="endl"/>
				<text>#if defined(__cplusplus)</text>
				<call-template name="endl"/>
				<text>} /*extern "C" */</text>
				<call-template name="endl"/>
				<text>#endif</text>
				<call-template name="endl"/>
			</with-param>
		</call-template>
		<text> </text>
		<call-template name="c.inlineComment">
			<with-param name="content" select="$prg.c.parser.header.preprocessorFileDefine"/>
		</call-template>
		<call-template name="endl"/>
	</template>

</stylesheet>

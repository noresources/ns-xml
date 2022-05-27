<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2018 - 2021 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Generate program parser header -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	<xsl:import href="parser.generic-header.xsl" />
	<xsl:import href="parser.info.xsl" />
	<xsl:import href="parser.results.xsl" />
	<xsl:import href="parser.functions.xsl" />
	<xsl:output method="text" encoding="utf-8" />
	<xsl:param name="prg.c.parser.header.filePath" select="'cmdline.h'" />
	<xsl:variable name="prg.c.parser.header.preprocessorFileDefine">
		<xsl:call-template name="c.validIdentifierName">
			<xsl:with-param name="name" select="translate(normalize-space($prg.c.parser.prefix),'-','_')" />
		</xsl:call-template>
		<xsl:text>_</xsl:text>
		<xsl:call-template name="c.validIdentifierName">
			<xsl:with-param name="name" select="translate(normalize-space($prg.c.parser.header.filePath),'.-/','_')" />
		</xsl:call-template>
		<xsl:text>__</xsl:text>
	</xsl:variable>
	<xsl:output method="text" encoding="utf-8" />
	<xsl:template match="/prg:program">
		<!-- Embed generic header if asked -->
		<xsl:if test="string-length($prg.c.parser.nsxmlHeaderPath) = 0">
			<xsl:value-of select="$prg.c.parser.genericHeader" />
			<xsl:value-of select="$str.endl" />
		</xsl:if>
		<xsl:call-template name="c.preprocessor.ifndef">
			<xsl:with-param name="condition" select="$prg.c.parser.header.preprocessorFileDefine" />
			<xsl:with-param name="then">
				<xsl:text>#define </xsl:text>
				<xsl:value-of select="$prg.c.parser.header.preprocessorFileDefine" />
				<xsl:value-of select="$str.endl" />
				<xsl:if test="string-length($prg.c.parser.nsxmlHeaderPath) &gt; 0">
					<!-- include nsxml header (expect the same naming style) -->
					<xsl:text># include "</xsl:text>
					<xsl:value-of select="$prg.c.parser.nsxmlHeaderPath" />
					<xsl:text>"</xsl:text>
					<xsl:value-of select="$str.endl" />
				</xsl:if>
				<xsl:text>#if defined(__cplusplus)</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:text>extern "C" {</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:text>#endif</xsl:text>
				<xsl:value-of select="$str.endl" />
				<!-- Declare info functions and structs -->
				<xsl:call-template name="prg.c.parser.programInfoTypedefs" />
				<xsl:value-of select="$str.endl" />
				<xsl:call-template name="prg.c.parser.programInfoInitFunctionDeclaration">
					<xsl:with-param name="programNode" select="." />
				</xsl:call-template>
				<xsl:value-of select="$str.endl" />
				<xsl:call-template name="prg.c.parser.programInfoNewFunctionDeclaration">
					<xsl:with-param name="programNode" select="." />
				</xsl:call-template>
				<xsl:value-of select="$str.endl" />
				<xsl:call-template name="prg.c.parser.programInfoCleanupFunctionDeclaration">
					<xsl:with-param name="programNode" select="." />
				</xsl:call-template>
				<xsl:value-of select="$str.endl" />
				<xsl:call-template name="prg.c.parser.programInfoFreeFunctionDeclaration">
					<xsl:with-param name="programNode" select="." />
				</xsl:call-template>
				<xsl:value-of select="$str.endl" />
				<!-- Declare subcommand results -->
				<!-- 
				<if test="./prg:subcommands">
					<for-each select="./prg:subcommands/prg:subcommand[prg:options]">
						<call-template name="prg.c.parser.subcommandResultDefinition" />
					</for-each>
					<value-of select="$str.endl" />
				</if>
				 -->
				<xsl:call-template name="prg.c.parser.programResultDefinition" />
				<xsl:value-of select="$str.endl" />
				<xsl:call-template name="prg.c.parser.programResultFreeFunctionDeclaration">
					<xsl:with-param name="programNode" select="." />
				</xsl:call-template>
				<xsl:value-of select="$str.endl" />
				<xsl:call-template name="prg.c.parser.programResultErrorCountFunctionDeclaration" />
				<xsl:value-of select="$str.endl" />
				<!-- Result message helper functions -->
				<xsl:call-template name="prg.c.parser.programResultGetMessageFunctionDeclaration">
					<xsl:with-param name="type" select="'warning'" />
				</xsl:call-template>
				<xsl:value-of select="$str.endl" />
				<xsl:call-template name="prg.c.parser.programResultGetMessageFunctionDeclaration">
					<xsl:with-param name="type" select="'error'" />
				</xsl:call-template>
				<xsl:value-of select="$str.endl" />
				<xsl:call-template name="prg.c.parser.programResultGetMessageFunctionDeclaration">
					<xsl:with-param name="type" select="'fatal_error'" />
				</xsl:call-template>
				<xsl:value-of select="$str.endl" />
				<xsl:call-template name="prg.c.parser.programResultDisplayErrorsFunctionDeclaration" />
				<xsl:value-of select="$str.endl" />
				<xsl:call-template name="prg.c.parser.usageFunctionDeclaration" />
				<xsl:value-of select="$str.endl" />
				<xsl:call-template name="prg.c.parser.parseFunctionDeclaration" />
				<xsl:value-of select="$str.endl" />
				<xsl:text>#if defined(__cplusplus)</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:text>} /*extern "C" */</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:text>#endif</xsl:text>
				<xsl:value-of select="$str.endl" />
			</xsl:with-param>
		</xsl:call-template>
		<xsl:text> </xsl:text>
		<xsl:call-template name="c.inlineComment">
			<xsl:with-param name="content" select="$prg.c.parser.header.preprocessorFileDefine" />
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />
	</xsl:template>

</xsl:stylesheet>

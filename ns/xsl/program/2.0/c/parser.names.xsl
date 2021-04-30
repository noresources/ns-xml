<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2018 - 2021 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- List of variable, structs and function names generated from program schema info -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	<xsl:import href="parser.base.xsl" />
	<xsl:variable name="prg.c.parser.functionName.program_info_init">
		<xsl:call-template name="prg.c.parser.functionName">
			<xsl:with-param name="name" select="concat($prg.c.parser.prefix, '_info_init')" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.functionName.program_info_new">
		<xsl:call-template name="prg.c.parser.functionName">
			<xsl:with-param name="name" select="concat($prg.c.parser.prefix, '_info_new')" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.functionName.program_info_cleanup">
		<xsl:call-template name="prg.c.parser.functionName">
			<xsl:with-param name="name" select="concat($prg.c.parser.prefix, '_info_cleanup')" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.functionName.program_info_free">
		<xsl:call-template name="prg.c.parser.functionName">
			<xsl:with-param name="name" select="concat($prg.c.parser.prefix, '_info_free')" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.structName.program_result">
		<xsl:call-template name="prg.c.parser.structName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.c.parser.prefix" />
				<xsl:text>_result</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.functionName.program_result_free">
		<xsl:call-template name="prg.c.parser.functionName">
			<xsl:with-param name="name" select="concat($prg.c.parser.prefix, '_result_free')" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.functionName.program_result_error_count">
		<xsl:call-template name="prg.c.parser.functionName">
			<xsl:with-param name="name" select="concat($prg.c.parser.prefix, '_result_error_count')" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.functionName.program_result_display_errors">
		<xsl:call-template name="prg.c.parser.functionName">
			<xsl:with-param name="name" select="concat($prg.c.parser.prefix, '_result_display_errors')" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.structName.program_info">
		<xsl:call-template name="prg.c.parser.structName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.c.parser.prefix" />
				<xsl:text>_info</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.functionName.program_parse">
		<xsl:call-template name="prg.c.parser.functionName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.c.parser.prefix" />
				<xsl:text>_parse</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.functionName.program_usage">
		<xsl:call-template name="prg.c.parser.functionName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.c.parser.prefix" />
				<xsl:text>_usage</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
</xsl:stylesheet>

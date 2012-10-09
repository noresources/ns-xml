<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2012 by Renaud Guillard (dev@niao.fr) -->
<!-- Distributed under the terms of the BSD License, see LICENSE -->
<!-- List of variable, structs and function names generated from program schema info -->
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" version="1.0">
	<import href="parser.base.xsl"/>
	<variable name="prg.c.parser.functionName.program_info_init">
		<call-template name="prg.c.parser.functionName">
			<with-param name="name" select="concat($prg.c.parser.prefix, '_info_init')"/>
		</call-template>
	</variable>
	<variable name="prg.c.parser.functionName.program_info_new">
		<call-template name="prg.c.parser.functionName">
			<with-param name="name" select="concat($prg.c.parser.prefix, '_info_new')"/>
		</call-template>
	</variable>
	<variable name="prg.c.parser.functionName.program_info_cleanup">
		<call-template name="prg.c.parser.functionName">
			<with-param name="name" select="concat($prg.c.parser.prefix, '_info_cleanup')"/>
		</call-template>
	</variable>
	<variable name="prg.c.parser.functionName.program_info_free">
		<call-template name="prg.c.parser.functionName">
			<with-param name="name" select="concat($prg.c.parser.prefix, '_info_free')"/>
		</call-template>
	</variable>
	<variable name="prg.c.parser.structName.program_result">
		<call-template name="prg.c.parser.structName">
			<with-param name="name">
				<value-of select="$prg.c.parser.prefix"/>
				<text>_result</text>
			</with-param>
		</call-template>
	</variable>
	<variable name="prg.c.parser.functionName.program_result_free">
		<call-template name="prg.c.parser.functionName">
			<with-param name="name" select="concat($prg.c.parser.prefix, '_result_free')"/>
		</call-template>
	</variable>
	<variable name="prg.c.parser.functionName.program_result_error_count">
		<call-template name="prg.c.parser.functionName">
			<with-param name="name" select="concat($prg.c.parser.prefix, '_result_error_count')"/>
		</call-template>
	</variable>
	<variable name="prg.c.parser.functionName.program_result_display_errors">
		<call-template name="prg.c.parser.functionName">
			<with-param name="name" select="concat($prg.c.parser.prefix, '_result_display_errors')"/>
		</call-template>
	</variable>
	<variable name="prg.c.parser.structName.program_info">
		<call-template name="prg.c.parser.structName">
			<with-param name="name">
				<value-of select="$prg.c.parser.prefix"/>
				<text>_info</text>
			</with-param>
		</call-template>
	</variable>
	<variable name="prg.c.parser.functionName.program_parse">
		<call-template name="prg.c.parser.functionName">
			<with-param name="name">
				<value-of select="$prg.c.parser.prefix"/>
				<text>_parse</text>
			</with-param>
		</call-template>
	</variable>
	<variable name="prg.c.parser.functionName.program_usage">
		<call-template name="prg.c.parser.functionName">
			<with-param name="name">
				<value-of select="$prg.c.parser.prefix"/>
				<text>_usage</text>
			</with-param>
		</call-template>
	</variable>
</stylesheet>

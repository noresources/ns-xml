<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2013 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the BSD License, see LICENSE -->
<!-- List of variable, structs and function names which can be modified by the user -->
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform"
	xmlns:prg="http://xsd.nore.fr/program" version="1.0">
	<import href="parser.base.xsl" />
	
	<variable name="prg.c.parser.functionName.nsxml_util_strncpy">
		<call-template name="prg.c.parser.functionName">
			<with-param name="name" select="'nsxml_util_strncpy'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.functionName.nsxml_util_strcpy">
		<call-template name="prg.c.parser.functionName">
			<with-param name="name" select="'nsxml_util_strcpy'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.functionName.nsxml_util_asnprintf">
		<call-template name="prg.c.parser.functionName">
			<with-param name="name" select="'nsxml_util_asnprintf'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.functionName.nsxml_util_string_starts_with">
		<call-template name="prg.c.parser.functionName">
			<with-param name="name" select="'nsxml_util_string_starts_with'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.functionName.nsxml_util_path_access_check">
		<call-template name="prg.c.parser.functionName">
			<with-param name="name" select="'nsxml_util_path_access_check'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.functionName.nsxml_util_text_wrap_options_init">
		<call-template name="prg.c.parser.functionName">
			<with-param name="name" select="'nsxml_util_text_wrap_options_init'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.functionName.nsxml_util_text_wrap_fprintf">
		<call-template name="prg.c.parser.functionName">
			<with-param name="name" select="'nsxml_util_text_wrap_fprintf'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.structName.nsxml_util_text_wrap_options">
		<call-template name="prg.c.parser.structName">
			<with-param name="name" select="'nsxml_util_text_wrap_options'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.structName.nsxml_message">
		<call-template name="prg.c.parser.structName">
			<with-param name="name" select="'nsxml_message'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.structName.nsxml_value">
		<call-template name="prg.c.parser.structName">
			<with-param name="name" select="'nsxml_value'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.variableName.nsxml_util_text_wrap_indent_none">
		<call-template name="prg.c.parser.variableName">
			<with-param name="name" select="'nsxml_util_text_wrap_indent_none'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.variableName.nsxml_util_text_wrap_indent_first">
		<call-template name="prg.c.parser.variableName">
			<with-param name="name" select="'nsxml_util_text_wrap_indent_first'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.variableName.nsxml_util_text_wrap_indent_others">
		<call-template name="prg.c.parser.variableName">
			<with-param name="name" select="'nsxml_util_text_wrap_indent_others'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.variableName.nsxml_util_text_wrap_eol_cr">
		<call-template name="prg.c.parser.variableName">
			<with-param name="name" select="'nsxml_util_text_wrap_eol_cr'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.variableName.nsxml_util_text_wrap_eol_lf">
		<call-template name="prg.c.parser.variableName">
			<with-param name="name" select="'nsxml_util_text_wrap_eol_lf'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.variableName.nsxml_util_text_wrap_eol_crlf">
		<call-template name="prg.c.parser.variableName">
			<with-param name="name" select="'nsxml_util_text_wrap_eol_crlf'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.variableName.nsxml_message_type_debug">
		<call-template name="prg.c.parser.variableName">
			<with-param name="name" select="'nsxml_message_type_debug'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.variableName.nsxml_message_type_warning">
		<call-template name="prg.c.parser.variableName">
			<with-param name="name" select="'nsxml_message_type_warning'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.variableName.nsxml_message_type_error">
		<call-template name="prg.c.parser.variableName">
			<with-param name="name" select="'nsxml_message_type_error'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.variableName.nsxml_message_type_fatal_error">
		<call-template name="prg.c.parser.variableName">
			<with-param name="name" select="'nsxml_message_type_fatal_error'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.variableName.nsxml_message_type_count">
		<call-template name="prg.c.parser.variableName">
			<with-param name="name" select="'nsxml_message_type_count'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.variableName.nsxml_value_type_unset">
		<call-template name="prg.c.parser.variableName">
			<with-param name="name" select="'nsxml_value_type_unset'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.variableName.nsxml_value_type_null">
		<call-template name="prg.c.parser.variableName">
			<with-param name="name" select="'nsxml_value_type_null'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.variableName.nsxml_value_type_int">
		<call-template name="prg.c.parser.variableName">
			<with-param name="name" select="'nsxml_value_type_int'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.variableName.nsxml_value_type_float">
		<call-template name="prg.c.parser.variableName">
			<with-param name="name" select="'nsxml_value_type_float'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.variableName.nsxml_value_type_string">
		<call-template name="prg.c.parser.variableName">
			<with-param name="name" select="'nsxml_value_type_string'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.variableName.nsxml_usage_format_short">
		<call-template name="prg.c.parser.variableName">
			<with-param name="name" select="'nsxml_usage_format_short'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.variableName.nsxml_usage_format_abstract">
		<call-template name="prg.c.parser.variableName">
			<with-param name="name" select="'nsxml_usage_format_abstract'" />
		</call-template>
	</variable>
	<variable name="prg.c.parser.variableName.nsxml_usage_format_details">
		<call-template name="prg.c.parser.variableName">
			<with-param name="name" select="'nsxml_usage_format_details'" />
		</call-template>
	</variable>
</stylesheet>

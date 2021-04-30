<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2012-2021 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->
<!-- List of variable, structs and function names which can be modified by the user -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:prg="http://xsd.nore.fr/program" version="1.0">
	<xsl:import href="parser.base.xsl" />
	
	<xsl:variable name="prg.c.parser.functionName.nsxml_util_append">
		<xsl:call-template name="prg.c.parser.functionName">
			<xsl:with-param name="name" select="'nsxml_util_append'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.functionName.nsxml_util_strncpy">
		<xsl:call-template name="prg.c.parser.functionName">
			<xsl:with-param name="name" select="'nsxml_util_strncpy'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.functionName.nsxml_util_strcpy">
		<xsl:call-template name="prg.c.parser.functionName">
			<xsl:with-param name="name" select="'nsxml_util_strcpy'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.functionName.nsxml_util_strdup">
		<xsl:call-template name="prg.c.parser.functionName">
			<xsl:with-param name="name" select="'nsxml_util_strdup'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.functionName.nsxml_util_strcat">
		<xsl:call-template name="prg.c.parser.functionName">
			<xsl:with-param name="name" select="'nsxml_util_strcat'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.functionName.nsxml_util_asnprintf">
		<xsl:call-template name="prg.c.parser.functionName">
			<xsl:with-param name="name" select="'nsxml_util_asnprintf'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.functionName.nsxml_util_string_starts_with">
		<xsl:call-template name="prg.c.parser.functionName">
			<xsl:with-param name="name" select="'nsxml_util_string_starts_with'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.functionName.nsxml_util_path_access_check">
		<xsl:call-template name="prg.c.parser.functionName">
			<xsl:with-param name="name" select="'nsxml_util_path_access_check'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.functionName.nsxml_util_text_wrap_options_init">
		<xsl:call-template name="prg.c.parser.functionName">
			<xsl:with-param name="name" select="'nsxml_util_text_wrap_options_init'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.functionName.nsxml_util_text_wrap_fprint">
		<xsl:call-template name="prg.c.parser.functionName">
			<xsl:with-param name="name" select="'nsxml_util_text_wrap_fprint'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.structName.nsxml_util_text_wrap_options">
		<xsl:call-template name="prg.c.parser.structName">
			<xsl:with-param name="name" select="'nsxml_util_text_wrap_options'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.structName.nsxml_message">
		<xsl:call-template name="prg.c.parser.structName">
			<xsl:with-param name="name" select="'nsxml_message'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.structName.nsxml_value">
		<xsl:call-template name="prg.c.parser.structName">
			<xsl:with-param name="name" select="'nsxml_value'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_util_text_wrap_indent_none">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_util_text_wrap_indent_none'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_util_text_wrap_indent_first">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_util_text_wrap_indent_first'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_util_text_wrap_indent_others">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_util_text_wrap_indent_others'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_util_text_wrap_eol_cr">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_util_text_wrap_eol_cr'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_util_text_wrap_eol_lf">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_util_text_wrap_eol_lf'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_util_text_wrap_eol_crlf">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_util_text_wrap_eol_crlf'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_message_type_debug">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_message_type_debug'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_message_type_warning">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_message_type_warning'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_message_type_error">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_message_type_error'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_message_type_fatal_error">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_message_type_fatal_error'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_message_type_count">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_message_type_count'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_value_type_unset">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_value_type_unset'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_value_type_null">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_value_type_null'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_value_type_int">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_value_type_int'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_value_type_float">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_value_type_float'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_value_type_string">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_value_type_string'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_usage_format_short">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_usage_format_short'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_usage_format_abstract">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_usage_format_abstract'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_usage_format_details">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_usage_format_details'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_message_warning_ignore_endofarguments">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_message_warning_ignore_endofarguments'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_message_error_invalid_option_argument">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_message_error_invalid_option_argument'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_message_error_invalid_pa_argument">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_message_error_invalid_pa_argument'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_message_error_missing_option_argument">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_message_error_missing_option_argument'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_message_error_missing_required_option">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_message_error_missing_required_option'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_message_error_missing_required_group_option">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_message_error_missing_required_group_option'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_message_error_missing_required_xgroup_option">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_message_error_missing_required_xgroup_option'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_message_error_missing_required_pa">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_message_error_missing_required_pa'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_message_error_program_pa_not_allowed">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_message_error_program_pa_not_allowed'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_message_error_subcommand_pa_not_allowed">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_message_error_subcommand_pa_not_allowed'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_message_error_too_many_pa">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_message_error_too_many_pa'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_message_error_not_enough_arguments">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_message_error_not_enough_arguments'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_message_error_unexpected_option">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_message_error_unexpected_option'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_message_error_option_argument_not_allowed">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_message_error_option_argument_not_allowed'" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.c.parser.variableName.nsxml_message_fatal_error_unknown_option">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'nsxml_message_fatal_error_unknown_option'" />
		</xsl:call-template>
	</xsl:variable>
</xsl:stylesheet>

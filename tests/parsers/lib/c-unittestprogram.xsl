<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 - 2021 by Renaud Guillard (dev@nore.fr) -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	<xsl:output method="text" encoding="utf-8" />
	<xsl:include href="../../../ns/xsl/languages/base.xsl" />
	<xsl:include href="../../../ns/xsl/languages/c.xsl" />
	<!-- copy of c/parser-base -->
	<xsl:template match="prg:databinding/prg:variable|prg:subcommand/prg:name">
		<xsl:call-template name="c.validIdentifierName">
			<xsl:with-param name="name" select="translate(normalize-space(.),'-','_')" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.c.unittest.owningStruct">
		<xsl:param name="optionNode" select="." />
		<xsl:param name="n" select="$optionNode" />
		<xsl:variable name="p" select="$n/../.." />
		<xsl:choose>
			<xsl:when test="$p/self::prg:group">
				<xsl:call-template name="prg.c.unittest.owningStruct">
					<xsl:with-param name="optionNode" select="$optionNode" />
					<xsl:with-param name="n" select="$p" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$p/self::prg:subcommand">
				<xsl:text>result-&gt;subcommands.</xsl:text>
				<xsl:apply-templates select="$p/prg:name" />
				<xsl:text>.</xsl:text>
				<xsl:apply-templates select="$optionNode/prg:databinding/prg:variable" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>result-&gt;options.</xsl:text>
				<xsl:apply-templates select="$optionNode/prg:databinding/prg:variable" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="prg.c.unittest.optionDisplayPrefix">
		<xsl:param name="optionNode" select="." />
		<xsl:param name="n" select="$optionNode" />
		<xsl:variable name="p" select="$n/../.." />
		<xsl:choose>
			<xsl:when test="$p/self::prg:subcommand">
				<xsl:value-of select="normalize-space($p/prg:name)" />
				<xsl:text>_</xsl:text>
			</xsl:when>
			<xsl:when test="$p/self::prg:program">

			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="prg.c.unittest.optionDisplayPrefix">
					<xsl:with-param name="optionNode" select="$optionNode" />
					<xsl:with-param name="n" select="$p" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="prg:switch">
		<xsl:if test="prg:databinding/prg:variable">
			<xsl:text>printf("%s=%s\n", "</xsl:text>
			<xsl:call-template name="prg.c.unittest.optionDisplayPrefix" />
			<xsl:apply-templates select="prg:databinding/prg:variable" />
			<xsl:text>", bool_to_string(</xsl:text>
			<xsl:call-template name="prg.c.unittest.owningStruct" />
			<xsl:text>.is_set));</xsl:text>
			<xsl:value-of select="$str.unix.endl" />
		</xsl:if>
	</xsl:template>

	<xsl:template match="prg:argument">
		<xsl:if test="prg:databinding/prg:variable">
			<xsl:text>printf("%s=%s\n", "</xsl:text>
			<xsl:call-template name="prg.c.unittest.optionDisplayPrefix" />
			<xsl:apply-templates select="prg:databinding/prg:variable" />
			<xsl:text>", safe_string(</xsl:text>
			<xsl:call-template name="prg.c.unittest.owningStruct" />
			<xsl:text>.argument.string_value));</xsl:text>
			<xsl:value-of select="$str.unix.endl" />
		</xsl:if>
	</xsl:template>

	<xsl:template match="prg:multiargument">
		<xsl:if test="prg:databinding/prg:variable">
			<xsl:text>printf("%s=", "</xsl:text>
			<xsl:call-template name="prg.c.unittest.optionDisplayPrefix" />
			<xsl:apply-templates select="prg:databinding/prg:variable" />
			<xsl:text>");</xsl:text>
			<xsl:value-of select="$str.unix.endl" />
			<xsl:text>value_list(</xsl:text>
			<xsl:call-template name="prg.c.unittest.owningStruct" />
			<xsl:text>.arguments, NULL, NULL, " ");</xsl:text>
			<xsl:value-of select="$str.unix.endl" />
			<xsl:text>printf("\n");</xsl:text>
			<xsl:value-of select="$str.unix.endl" />
		</xsl:if>
	</xsl:template>

	<xsl:template match="prg:group">
		<xsl:if test="prg:databinding/prg:variable">
			<xsl:text>printf("%s=%s\n", "</xsl:text>
			<xsl:call-template name="prg.c.unittest.optionDisplayPrefix" />
			<xsl:apply-templates select="prg:databinding/prg:variable" />
			<xsl:text>", safe_string(</xsl:text>
			<xsl:call-template name="prg.c.unittest.owningStruct" />
			<xsl:text>.selected_option_name));</xsl:text>
			<xsl:value-of select="$str.unix.endl" />
		</xsl:if>
	</xsl:template>

	<xsl:template match="/">
		<xsl:text><![CDATA[#include "program-parser.h"
#include <stdio.h>
#include <string.h>
void value_list(const nsxml_value *list, const char *pre, const char *post, const char *sep);
void value_list(const nsxml_value *list, const char *pre, const char *post, const char *sep)
{
	int first = 1;
	const nsxml_value *v = list;
	while (v)
	{
		if (first)
		{
			first = 0;
		}
		else if (sep)
		{
			printf("%s", sep);
		}
		
		printf("%s%s%s", ((pre) ? pre : ""), v->string_value, ((post) ? post : ""));
		
		v = v->next_value;
	}
}

const char *safe_string(const char *value);
const char *safe_string(const char *value)
{
	return (value) ? value : "";	
}

const char *bool_to_string(int v);
const char *bool_to_string(int v)
{
	return (v) ? "True" : "False";
}

int main(int argc, const char **argv);
int main(int argc, const char **argv)
{
	/* Display command line arguments */
	int first = 1;
	int display_messages = 0;
	int display_help = 0;
	int display_subcommand_list = 0;
	int i;
	app_info info;
	app_result *result;
	printf("%s", "CLI: ");
	for (i = 1; i < argc; ++i)
	{
		if (first)
		{
			printf("\"%s\"", argv[i]);
			first = 0;
		}
		else
		{
			printf(", \"%s\"", argv[i]);
		}
		
		if (strcmp(argv[i], "__msg__") == 0)
		{
			display_messages = 1;
		}
		else if (strcmp(argv[i], "__help__") == 0)
		{
			display_help = 1;
		}
		else if (strcmp(argv[i], "__sc__") == 0)
		{
			display_subcommand_list = 1;
		}
	}
	printf("\n");
	
	app_info_init(&info);
	result = app_parse(&info, argc, argv, 1);
	if (display_help)
	{
		app_usage(stdout, &info, result, nsxml_usage_format_details, NULL);
		goto app_end;
	}
	
	/* Positional arguments */
	printf("Value count: %d\n", (int)result->value_count);
	printf("Values: ");
	value_list(result->values, "\"", "\"", ", ");
	printf("\n");
	
	/* Errors */
	printf("Error count: %d\n", (int)app_result_error_count(result));
	if (display_messages && (int)app_result_error_count(result))
	{
		printf("Errors: ");
		app_result_display_errors(stderr, result, "- ");
	}
	
	if (display_subcommand_list)
	{
		printf ("%s:\n", "Subcommand names");
		nsxml_program_info_display_subcommand_names(stdout, &info);
		return 0;
	}	
	printf("Subcommand: %s\n", ((result->subcommand_name) ? result->subcommand_name : ""));
]]></xsl:text>
		<xsl:call-template name="str.prependLine">
			<xsl:with-param name="prependedText" select="'&#9;'" />
			<xsl:with-param name="text"><!-- Global args -->
				<xsl:if test="/prg:program/prg:options">
					<xsl:variable name="root" select="/prg:program/prg:options" />
					<xsl:apply-templates select="$root//prg:switch | $root//prg:argument | $root//prg:multiargument | .//prg:group" />
				</xsl:if><!-- Subcommands -->
				<xsl:for-each select="/prg:program/prg:subcommands/*">
					<xsl:if test="./prg:options"><!-- <apply-templates select=".//prg:switch | .//prg:argument | .//prg:multiargument | .//prg:group"/> -->
						<xsl:call-template name="c.if">
							<xsl:with-param name="condition">
								<xsl:text>result-&gt;subcommand_name &amp;&amp; strcmp(result-&gt;subcommand_name, "</xsl:text>
								<xsl:call-template name="c.escapeLiteral">
									<xsl:with-param name="value" select="prg:name" />
								</xsl:call-template>
								<xsl:text>") == 0</xsl:text>
							</xsl:with-param>
							<xsl:with-param name="then">
								<xsl:apply-templates select=".//prg:switch | .//prg:argument | .//prg:multiargument | .//prg:group" />
							</xsl:with-param>
						</xsl:call-template>
					</xsl:if>
				</xsl:for-each>
			</xsl:with-param>
		</xsl:call-template><![CDATA[
app_end:
	app_result_free(result);
	app_info_cleanup(&info);
	return 0;
}
]]></xsl:template>

</xsl:stylesheet>

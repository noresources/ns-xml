<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" version="1.0">
	<output method="text" encoding="utf-8" />
	<include href="../../../ns/xsl/languages/base.xsl" />
	<include href="../../../ns/xsl/languages/c.xsl" />
	<!-- copy of c/parser-base -->
	<template match="prg:databinding/prg:variable">
		<call-template name="c.validIdentifierName">
			<with-param name="name" select="translate(normalize-space(.),'-','_')" />
		</call-template>
	</template>

	<template name="prg.c.unittest.owningStruct">
		<param name="optionNode" select="." />
		<param name="n" select="$optionNode" />
		<variable name="p" select="$n/../.." />
		<choose>
			<when test="$p/self::prg:group">
				<call-template name="prg.c.unittest.owningStruct">
					<with-param name="optionNode" select="$optionNode" />
					<with-param name="n" select="$p" />
				</call-template>
			</when>
			<when test="$p/self::prg:subcommand">
				<text>result-&gt;subcommands.</text>
				<apply-templates select="$p/prg:name" />
				<text>.</text>
				<apply-templates select="$optionNode/prg:databinding/prg:variable" />
			</when>
			<otherwise>
				<text>result-&gt;options.</text>
				<apply-templates select="$optionNode/prg:databinding/prg:variable" />
			</otherwise>
		</choose>
	</template>

	<template name="prg.c.unittest.optionDisplayPrefix">
		<param name="optionNode" select="." />
		<param name="n" select="$optionNode" />
		<variable name="p" select="$n/../.." />
		<choose>
			<when test="$p/self::prg:subcommand">
				<value-of select="$p/prg:name" />
				<text>_</text>
			</when>
			<when test="$p/self::prg:program">

			</when>
			<otherwise>
				<call-template name="prg.c.unittest.optionDisplayPrefix">
					<with-param name="optionNode" select="$optionNode" />
					<with-param name="n" select="$p" />
				</call-template>
			</otherwise>
		</choose>
	</template>

	<template match="prg:switch">
		<if test="prg:databinding/prg:variable">
			<text>printf("%s=%s\n", "</text>
			<call-template name="prg.c.unittest.optionDisplayPrefix" />
			<apply-templates select="prg:databinding/prg:variable" />
			<text>", bool_to_string(</text>
			<call-template name="prg.c.unittest.owningStruct" />
			<text>.is_set));</text>
			<value-of select="$str.unix.endl" />
		</if>
	</template>

	<template match="prg:argument">
		<if test="prg:databinding/prg:variable">
			<text>printf("%s=%s\n", "</text>
			<call-template name="prg.c.unittest.optionDisplayPrefix" />
			<apply-templates select="prg:databinding/prg:variable" />
			<text>", safe_string(</text>
			<call-template name="prg.c.unittest.owningStruct" />
			<text>.argument.string_value));</text>
			<value-of select="$str.unix.endl" />
		</if>
	</template>

	<template match="prg:multiargument">
		<if test="prg:databinding/prg:variable">
			<text>printf("%s=", "</text>
			<call-template name="prg.c.unittest.optionDisplayPrefix" />
			<apply-templates select="prg:databinding/prg:variable" />
			<text>");</text>
			<value-of select="$str.unix.endl" />
			<text>value_list(</text>
			<call-template name="prg.c.unittest.owningStruct" />
			<text>.arguments, NULL, NULL, " ");</text>
			<value-of select="$str.unix.endl" />
			<text>printf("\n");</text>
			<value-of select="$str.unix.endl" />
		</if>
	</template>

	<template match="prg:group">
		<if test="prg:databinding/prg:variable">
			<text>printf("%s=%s\n", "</text>
			<call-template name="prg.c.unittest.optionDisplayPrefix" />
			<apply-templates select="prg:databinding/prg:variable" />
			<text>", safe_string(</text>
			<call-template name="prg.c.unittest.owningStruct" />
			<text>.selected_option_name));</text>
			<value-of select="$str.unix.endl" />
		</if>
	</template>

	<template match="/">
		<text><![CDATA[#include "program-parser.h"
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
	}
	printf("\n");
	
	app_info_init(&info);
	result = app_parse(&info, argc, argv, 1);
	
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
	
	printf("Subcommand: %s\n", ((result->subcommand_name) ? result->subcommand_name : ""));
]]></text>
		<call-template name="str.prependLine">
			<with-param name="prependedText" select="'&#9;'" />
			<with-param name="text"><!-- Global args -->
				<if test="/prg:program/prg:options">
					<variable name="root" select="/prg:program/prg:options" />
					<apply-templates select="$root//prg:switch | $root//prg:argument | $root//prg:multiargument | .//prg:group" />
				</if><!-- Subcommands -->
				<for-each select="/prg:program/prg:subcommands/*">
					<if test="./prg:options"><!-- <apply-templates select=".//prg:switch | .//prg:argument | .//prg:multiargument | .//prg:group"/> -->
						<call-template name="c.if">
							<with-param name="condition">
								<text>result-&gt;subcommand_name &amp;&amp; strcmp(result-&gt;subcommand_name, "</text>
								<apply-templates select="prg:name" />
								<text>") == 0</text>
							</with-param>
							<with-param name="then">
								<apply-templates select=".//prg:switch | .//prg:argument | .//prg:multiargument | .//prg:group" />
							</with-param>
						</call-template>
					</if>
				</for-each>
			</with-param>
		</call-template><![CDATA[
	app_result_free(result);
	app_info_cleanup(&info);
	return 0;
}
]]></template>

</stylesheet>

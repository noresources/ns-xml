<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2012 by Renaud Guillard (dev@niao.fr) -->
<!-- Distributed under the terms of the BSD License, see LICENSE -->
<!-- Create C parser result definitions -->
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" version="1.0">
	<import href="parser.base.xsl"/>
	<import href="parser.generic-names.xsl"/>
	<import href="parser.names.xsl"/>
	<!-- Declare an option result variable depending on the type of option -->
	<template name="prg.c.parser.optionResultDeclaration">
		<!-- Option node -->
		<param name="optionNode" select="."/>
		<variable name="structName">
			<text>nsxml_</text>
			<call-template name="prg.c.parser.itemTypeName">
				<with-param name="itemNode" select="$optionNode"/>
			</call-template>
			<text>_option_result</text>
		</variable>
		<call-template name="c.structVariableDeclaration">
			<with-param name="name" select="$structName"/>
			<with-param name="variableName">
				<apply-templates select="$optionNode/prg:databinding/prg:variable"/>
			</with-param>
			<with-param name="variableNameStyle" select="'none'"/>
			<!-- TEMP -->
			<with-param name="nameStyle" select="'none'"/>
		</call-template>
	</template>

	<!-- Declare all option result variables from a root item (subcommand or 
		program) -->
	<template name="prg.c.parser.optionResultsDeclaration">
		<param name="rootNode" select="."/>
		<variable name="rootOptionsNode" select="$rootNode/prg:options"/>
		<for-each select="$rootOptionsNode//*[prg:databinding/prg:variable]">
			<call-template name="prg.c.parser.optionResultDeclaration"/>
			<call-template name="endl"/>
		</for-each>
	</template>

	<variable name="prg.c.parser.subcommandResultStructBaseName" select="'subcommand_result'"/>
	<!-- struct type name of a subcommand result struct -->
	<template name="prg.c.parser.subcommandResultStructName">
		<param name="subcommandNode" select="."/>
		<value-of select="$prg.c.parser.prefix"/>
		<text>_</text>
		<call-template name="c.validIdentifierName">
			<with-param name="name">
				<apply-templates select="$subcommandNode/prg:name"/>
			</with-param>
		</call-template>
		<text>_</text>
		<value-of select="$prg.c.parser.subcommandResultStructBaseName"/>
	</template>

	<template name="prg.c.parser.subcommandResultDefinition">
		<param name="subcommandNode" select="."/>
		<variable name="structName">
			<call-template name="prg.c.parser.subcommandResultStructName">
				<with-param name="subcommandNode" select="$subcommandNode"/>
			</call-template>
		</variable>
		<call-template name="c.structDefinition">
			<with-param name="name" select="$structName"/>
			<with-param name="variableName">
				<call-template name="c.validIdentifierName">
					<with-param name="name">
						<apply-templates select="$subcommandNode/prg:name"/>
					</with-param>
				</call-template>
			</with-param>
			<with-param name="content">
				<call-template name="c.inlineComment">
					<with-param name="content" select="'Subcommand options'"/>
				</call-template>
				<call-template name="endl"/>
				<call-template name="prg.c.parser.optionResultsDeclaration">
					<with-param name="rootNode" select="$subcommandNode"/>
				</call-template>
			</with-param>
		</call-template>
		<call-template name="endl"/>
	</template>

	<!-- Define the main program result type -->
	<template name="prg.c.parser.programResultDefinition">
		<!-- Program node -->
		<param name="programNode" select="."/>
		<variable name="structName">
			<value-of select="$prg.c.parser.structName.program_result"/>
		</variable>
		<call-template name="c.structDefinition">
			<with-param name="name" select="concat('_', $structName)"/>
			<with-param name="content">
				<!-- Base -->
				<!-- Parser messages -->
				<call-template name="c.inlineComment">
					<with-param name="content" select="'Messages - Sorted by severity'"/>
				</call-template>
				<call-template name="endl"/>
				<value-of select="$prg.c.parser.structName.nsxml_message"/>
				<text> *messages[</text>
				<value-of select="$prg.c.parser.variableName.nsxml_message_type_count"/>
				<text>];</text>
				<call-template name="endl"/>
				<call-template name="c.inlineComment">
					<with-param name="content" select="'Messages - Sorted by apparition'"/>
				</call-template>
				<call-template name="endl"/>
				<value-of select="$prg.c.parser.structName.nsxml_message"/>
				<text> *first_message;</text>
				<call-template name="endl"/>
				<!-- Values (positional arguments) -->
				<call-template name="endl"/>
				<call-template name="c.inlineComment">
					<with-param name="content" select="'Subcommand'"/>
				</call-template>
				<call-template name="endl"/>
				<call-template name="c.variableDeclaration">
					<with-param name="type" select="'const char'"/>
					<with-param name="pointer" select="1"/>
					<with-param name="name" select="'subcommand_name'"/>
					<with-param name="nameStyle" select="'none'"/>
				</call-template>
				<call-template name="endl"/>
				<call-template name="c.inlineComment">
					<with-param name="content" select="'Values'"/>
				</call-template>
				<call-template name="endl"/>
				<call-template name="c.variableDeclaration">
					<with-param name="type" select="'size_t'"/>
					<with-param name="nameStyle" select="'none'"/>
					<with-param name="name" select="'value_count'"/>
					<with-param name="variableNameStyle" select="'none'"/>
				</call-template>
				<call-template name="endl"/>
				<call-template name="c.variableDeclaration">
					<with-param name="type" select="$prg.c.parser.structName.nsxml_value"/>
					<with-param name="nameStyle" select="'none'"/>
					<with-param name="name" select="'values'"/>
					<with-param name="pointer" select="1"/>
				</call-template>
				<call-template name="endl"/>
				<!-- Dynamic part -->
				<!-- Global options -->
				<call-template name="c.inlineComment">
					<with-param name="content" select="'Global options'"/>
				</call-template>
				<call-template name="endl"/>
				<call-template name="c.structDefinition">
					<with-param name="variableName" select="'options'"/>
					<with-param name="content">
						<call-template name="prg.c.parser.optionResultsDeclaration">
							<with-param name="rootNode" select="$programNode"/>
						</call-template>
					</with-param>
				</call-template>
				<!-- Subcommands (if any) -->
				<if test="$programNode/prg:subcommands">
					<call-template name="endl"/>
					<call-template name="c.inlineComment">
						<with-param name="content" select="'Subcommands'"/>
					</call-template>
					<call-template name="endl"/>
					<call-template name="c.structDefinition">
						<with-param name="variableName" select="'subcommands'"/>
						<with-param name="variableNameStyle" select="'none'"/>
						<with-param name="content">
							<for-each select="$programNode/prg:subcommands/prg:subcommand[prg:options]">
								<call-template name="prg.c.parser.subcommandResultDefinition"/>
								<call-template name="endl"/>
							</for-each>
						</with-param>
					</call-template>
				</if>
			</with-param>
		</call-template>
		<call-template name="endl"/>
		<text>typedef struct </text>
		<value-of select="concat('_', $structName)"/>
		<text> </text>
		<value-of select="$structName"/>
		<text>;</text>
	</template>

	<!-- Program result life cycle functions -->
	<template name="prg.c.parser.programResultFreeFunctionDeclaration">
		<param name="programNode" select="."/>
		<call-template name="c.functionDeclaration">
			<with-param name="name" select="$prg.c.parser.functionName.program_result_free"/>
			<with-param name="parameters">
				<value-of select="$prg.c.parser.structName.program_result"/>
				<text> *result</text>
			</with-param>
		</call-template>
	</template>

	<template name="prg.c.parser.programResultFreeFunctionDefinition">
		<param name="programNode" select="."/>
		<call-template name="c.functionDefinition">
			<with-param name="name" select="$prg.c.parser.functionName.program_result_free"/>
			<with-param name="parameters">
				<value-of select="$prg.c.parser.structName.program_result"/>
				<text> *result</text>
			</with-param>
			<with-param name="content">
				<text>nsxml_program_result_cleanup(result);</text>
				<call-template name="endl"/>
				<call-template name="prg.c.parser.option_resultFunctionCall">
					<with-param name="programNode" select="$programNode"/>
					<with-param name="functionName" select="'nsxml_option_result_cleanup'"/>
					<with-param name="cast" select="false()"/>
				</call-template>
				<text>free(result);</text>
			</with-param>
		</call-template>
	</template>

	<!-- Result messages helper functions -->
	<template name="prg.c.parser.programResultErrorCountFunctionDeclaration">
		<param name="programNode" select="."/>
		<call-template name="c.functionDeclaration">
			<with-param name="name" select="$prg.c.parser.functionName.program_result_error_count"/>
			<with-param name="returnType" select="'size_t'"/>
			<with-param name="parameters">
				<value-of select="$prg.c.parser.structName.program_result"/>
				<text> *result</text>
			</with-param>
		</call-template>
	</template>

	<template name="prg.c.parser.programResultErrorCountFunctionDefinition">
		<param name="programNode" select="."/>
		<call-template name="c.functionDefinition">
			<with-param name="name" select="$prg.c.parser.functionName.program_result_error_count"/>
			<with-param name="returnType" select="'size_t'"/>
			<with-param name="parameters">
				<value-of select="$prg.c.parser.structName.program_result"/>
				<text> *result</text>
			</with-param>
			<with-param name="content">
				<text>return (nsxml_message_count(result-&gt;messages[</text>
				<value-of select="$prg.c.parser.variableName.nsxml_message_type_error"/>
				<text>]) + nsxml_message_count(result-&gt;messages[</text>
				<value-of select="$prg.c.parser.variableName.nsxml_message_type_fatal_error"/>
				<text>]));</text>
			</with-param>
		</call-template>
	</template>

	<template name="prg.c.parser.programResultGetMessageFunctionName">
		<param name="type"/>
		<call-template name="prg.c.parser.functionName">
			<with-param name="name">
				<choose>
					<when test="$type = 'fatal_error'">
						<value-of select="concat(concat($prg.c.parser.prefix, '_result_get_'), $type)"/>
					</when>
					<otherwise>
						<value-of select="concat(concat(concat($prg.c.parser.prefix, '_result_get_'), $type), 's')"/>
					</otherwise>
				</choose>
			</with-param>
		</call-template>
	</template>

	<template name="prg.c.parser.programResultGetMessageFunctionDeclaration">
		<param name="type"/>
		<call-template name="c.functionDeclaration">
			<with-param name="name">
				<call-template name="prg.c.parser.programResultGetMessageFunctionName">
					<with-param name="type" select="$type"/>
				</call-template>
			</with-param>
			<with-param name="returnType" select="concat($prg.c.parser.structName.nsxml_message, ' *')"/>
			<with-param name="parameters">
				<value-of select="$prg.c.parser.structName.program_result"/>
				<text> *result</text>
			</with-param>
		</call-template>
	</template>

	<template name="prg.c.parser.programResultGetMessageFunctionDefinition">
		<param name="type"/>
		<call-template name="c.functionDefinition">
			<with-param name="name">
				<call-template name="prg.c.parser.programResultGetMessageFunctionName">
					<with-param name="type" select="$type"/>
				</call-template>
			</with-param>
			<with-param name="returnType" select="concat($prg.c.parser.structName.nsxml_message, ' *')"/>
			<with-param name="parameters">
				<value-of select="$prg.c.parser.structName.program_result"/>
				<text> *result</text>
			</with-param>
			<with-param name="content">
				<text>return result-&gt;messages[</text>
				<choose>
					<when test="$type = 'warning'">
						<value-of select="$prg.c.parser.variableName.nsxml_message_type_warning"/>
					</when>
					<when test="$type = 'error'">
						<value-of select="$prg.c.parser.variableName.nsxml_message_type_error"/>
					</when>
					<when test="$type = 'fatal_error'">
						<value-of select="$prg.c.parser.variableName.nsxml_message_type_fatal_error"/>
					</when>
				</choose>
				<text>];</text>
			</with-param>
		</call-template>
	</template>

	<variable name="prg.c.parser.programResultDisplayErrorsFunctionSignature">
		<call-template name="c.functionSignature">
			<with-param name="returnType" select="'void'"/>
			<with-param name="name">
				<value-of select="$prg.c.parser.functionName.program_result_display_errors"/>
			</with-param>
			<with-param name="parameters">
				<text>FILE *stream, </text>
				<value-of select="$prg.c.parser.structName.program_result"/>
				<text> *result, const char *line_prefix</text>
			</with-param>
		</call-template>
	</variable>
	<template name="prg.c.parser.programResultDisplayErrorsFunctionDeclaration">
		<call-template name="c.functionDeclaration">
			<with-param name="signature" select="$prg.c.parser.programResultDisplayErrorsFunctionSignature"/>
		</call-template>
	</template>

	<template name="prg.c.parser.programResultDisplayErrorsFunctionDefinition">
		<call-template name="c.functionDefinition">
			<with-param name="signature" select="$prg.c.parser.programResultDisplayErrorsFunctionSignature"/>
			<with-param name="content">
				<value-of select="$prg.c.parser.structName.nsxml_message"/>
				<text> *m = result-&gt;messages[</text>
				<value-of select="$prg.c.parser.variableName.nsxml_message_type_error"/>
				<text>];</text>
				<call-template name="endl"/>
				<text>int use_prefix = 1;</text>
				<call-template name="endl"/>
				<call-template name="c.while">
					<with-param name="condition" select="'m'"/>
					<with-param name="do">
						<text>size_t len = (m-&gt;message) ? strlen(m-&gt;message) : 0;</text>
						<call-template name="endl"/>
						<text>fprintf(stream, "%s%s", ((use_prefix &amp;&amp; line_prefix) ? line_prefix : ""), m-&gt;message);</text>
						<call-template name="endl"/>
						<text>use_prefix = (len &amp;&amp; (m-&gt;message[len - 1] == '\n'));</text>
						<call-template name="endl"/>
						<text>m = m-&gt;next_message;</text>
					</with-param>
				</call-template>
				<call-template name="endl"/>
				<call-template name="c.if">
					<with-param name="condition" select="'!use_prefix'"/>
					<with-param name="then">
						<text>fprintf(stream, "%s", "\n");</text>
					</with-param>
				</call-template>
				<call-template name="endl"/>
				<text>m = result-&gt;messages[</text>
				<value-of select="$prg.c.parser.variableName.nsxml_message_type_fatal_error"/>
				<text>];</text>
				<call-template name="endl"/>
				<call-template name="c.if">
					<with-param name="condition" select="'m'"/>
					<with-param name="then">
						<text>size_t len = (m-&gt;message) ? strlen(m-&gt;message) : 0;</text>
						<call-template name="endl"/>
						<text>fprintf(stream, "%s%s", ((line_prefix) ? line_prefix : ""), m-&gt;message);</text>
						<call-template name="endl"/>
						<call-template name="c.if">
							<with-param name="condition">
								<text>m-&gt;message[len - 1] != '\n'</text>
							</with-param>
							<with-param name="then">
								<text>fprintf(stream, "%s", "\n");</text>
							</with-param>
						</call-template>
					</with-param>
				</call-template>
			</with-param>
		</call-template>
	</template>

</stylesheet>

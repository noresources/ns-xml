<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->

<!-- Shell parser base templates -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">

	<import href="sh-base.xsl" />
	
	<param name="prg.sh.parser.prefixSubcommandOptionVariable" select="'no'" />
	
	<template name="prg.sh.parser.boundVariableName">
		<param name="variableNode" />
		<param name="node" select="$variableNode/../.." />
		
		<choose>
			<when test="$node/self::prg:program">
				<value-of select="normalize-space($variableNode)" />
			</when>
			<when test="$node/self::prg:subcommand">
				<if test="$prg.sh.parser.prefixSubcommandOptionVariable = 'yes'">
					<value-of select="normalize-space($node/prg:name)" />
					<text>_</text>
				</if>
				<value-of select="normalize-space($variableNode)" />
			</when>
			<when test="$node/../..">
				<call-template name="prg.sh.parser.boundVariableName">
					<with-param name="variableNode" select="$variableNode" />
					<with-param name="node" select="$node/../.." />
				</call-template>
			</when>
			<otherwise>
				<value-of select="normalize-space($variableNode)" />
			</otherwise>
		</choose>
	</template>
	
	<!-- Prefix of all parser functions -->
	<variable name="prg.sh.parser.functionNamePrefix">
		<text>parse_</text>
	</variable>

	<!-- Prefix of all parser variable -->
	<variable name="prg.sh.parser.variableNamePrefix">
		<text>parser_</text>
	</variable>

	<template match="//prg:databinding/prg:variable">
		<call-template name="prg.sh.parser.boundVariableName">
			<with-param name="variableNode" select="." />
		</call-template>
	</template>
	
</stylesheet>

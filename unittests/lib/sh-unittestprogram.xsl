<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
<output method="text" encoding="utf-8" />
	
	<template name="prg.unittest.sh.variablePrefix">
		<param name="node"/>
		<choose>
			<when test="$node/self::prg:subcommand">
				<apply-templates select="$node/prg:name" />
				<text>_</text>
			</when>
			<when test="$node/..">
				<call-template name="prg.unittest.sh.variablePrefix">
					<with-param name="node" select="$node/.." />
				</call-template>
			</when>
		</choose>
	</template>
	
	<template match="prg:databinding/prg:variable">
		<call-template name="prg.unittest.sh.variablePrefix" >
			<with-param name="node" select="." />
		</call-template>
		<value-of select="normalize-space(.)" />
	</template>
	
	<template match="prg:subcommand/prg:name">
		<value-of select="normalize-space(.)" />
	</template>
	
	<template match="/">
		<text><![CDATA[parse "${@}"
echo "CLI: ${@}"
echo "Value count: ${#parser_values[*]}"
echo "Values: ${parser_values[*]}"
echo "Error count: ${#parser_errors[*]}"
echo "Subcommand: ${parser_subcommand}"
]]></text>
		<!-- Global args -->
		<if test="/prg:program/prg:options">
			<variable name="root" select="/prg:program/prg:options" />
			<apply-templates select="$root//prg:switch | $root//prg:argument | $root//prg:multiargument" />
		</if>
		
		<for-each select="/prg:program/prg:subcommands/*">
			<if test="./prg:options">
				<text>if [ "${parser_subcommand}" == "</text>
				<apply-templates select="prg:name" />
				<text>" ]; then</text>
				<text>&#10;</text>
				<apply-templates select=".//prg:switch | .//prg:argument | .//prg:multiargument" />
				<text>fi</text>
				<text>&#10;</text>
			</if>
		</for-each>
	</template>
	
	<template match="//prg:switch">
		<if test="./prg:databinding/prg:variable">
			<text>switchval </text><apply-templates select="prg:databinding/prg:variable"/><text>&#10;</text>
		</if>	
	</template>
	
	<template match="//prg:argument">
		<if test="./prg:databinding/prg:variable">
			<text>echo </text><apply-templates select="prg:databinding/prg:variable"/>=${<apply-templates select="prg:databinding/prg:variable"/>}<text>&#10;</text>
		</if>	
	</template>
	
	<template match="//prg:multiargument">
		<if test="./prg:databinding/prg:variable">
			<text>echo </text><apply-templates select="prg:databinding/prg:variable"/>=${<apply-templates select="prg:databinding/prg:variable"/>[*]}<text>&#10;</text>
		</if>	
	</template>
</stylesheet>
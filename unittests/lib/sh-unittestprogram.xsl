<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" version="1.0">
	<output method="text" encoding="utf-8"/>
	<template name="prg.unittest.sh.variablePrefix">
		<param name="node"/>
		<choose>
			<when test="$node/self::prg:subcommand">
				<apply-templates select="$node/prg:name"/>
				<text>_</text>
			</when>
			<when test="$node/..">
				<call-template name="prg.unittest.sh.variablePrefix">
					<with-param name="node" select="$node/.."/>
				</call-template>
			</when>
		</choose>
	</template>

	<template match="prg:databinding/prg:variable">
		<call-template name="prg.unittest.sh.variablePrefix">
			<with-param name="node" select="."/>
		</call-template>
		<value-of select="normalize-space(.)"/>
	</template>

	<template match="prg:subcommand/prg:name">
		<value-of select="normalize-space(.)"/>
	</template>

	<template match="/">
		<text><![CDATA[
parse "${@}"
echo -n "CLI: "
cpt="${#}"
i=1
for argv in "${@}"
do
	if [ ${i} -gt 1 ]
	then
		echo -n ", "
	fi
	echo -n "\"${argv}\""
	i=$(expr ${i} + 1)
done
echo ""
echo "Value count: ${#parser_values[*]}"
cpt="${#parser_values[*]}"
echo -n "Values: "
i=1
if [ ${#parser_values[*]} -gt 0 ]
then
	for v in "${parser_values[@]}"
	do
		if [ ${i} -gt 1 ]
		then
			echo -n ", "
		fi
		echo -n "\"${v}\""
		i=$(expr ${i} + 1)
	done
fi
echo ""
echo "Error count: ${#parser_errors[*]}"
echo "Subcommand: ${parser_subcommand}"
]]></text>
		<!-- Global args -->
		<if test="/prg:program/prg:options">
			<variable name="root" select="/prg:program/prg:options"/>
			<apply-templates select="$root//prg:switch | $root//prg:argument | $root//prg:multiargument | .//prg:group"/>
		</if>
		<for-each select="/prg:program/prg:subcommands/*">
			<if test="./prg:options">
				<text>if [ "${parser_subcommand}" = "</text>
				<apply-templates select="prg:name"/>
				<text>" ]; then</text>
				<value-of select="'&#10;'"/>
				<apply-templates select=".//prg:switch | .//prg:argument | .//prg:multiargument | .//prg:group"/>
				<text>fi</text>
				<value-of select="'&#10;'"/>
			</if>
		</for-each>
	</template>

	<template match="//prg:switch">
		<if test="./prg:databinding/prg:variable">
			<text>switchval </text>
			<apply-templates select="prg:databinding/prg:variable"/>
			<value-of select="'&#10;'"/>
		</if>
	</template>

	<template match="//prg:argument">
		<if test="./prg:databinding/prg:variable"><text>echo </text><apply-templates select="prg:databinding/prg:variable"/>=${<apply-templates select="prg:databinding/prg:variable"/>}<value-of select="'&#10;'"/></if>
	</template>

	<template match="//prg:multiargument">
		<if test="./prg:databinding/prg:variable"><text>echo </text><apply-templates select="prg:databinding/prg:variable"/>=${<apply-templates select="prg:databinding/prg:variable"/>[*]}<value-of select="'&#10;'"/></if>
	</template>

	<template match="//prg:group">
		<if test="./prg:databinding/prg:variable"><text>echo </text><apply-templates select="prg:databinding/prg:variable"/>=${<apply-templates select="prg:databinding/prg:variable"/>}<value-of select="'&#10;'"/></if>
	</template>

</stylesheet>

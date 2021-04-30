<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 - 2021 by Renaud Guillard (dev@nore.fr) -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	<xsl:import href="../../../ns/xsl/program/2.0/sh/parser.base.xsl" />

	<xsl:output method="text" encoding="utf-8" />

	<xsl:template name="prg.unittest.sh.variablePrefix">
		<xsl:param name="node" select="." />
		<xsl:choose>
			<xsl:when test="$node/self::prg:subcommand">
				<xsl:apply-templates select="$node/prg:name" />
				<xsl:text>_</xsl:text>
			</xsl:when>
			<xsl:when test="$node/..">
				<xsl:call-template name="prg.unittest.sh.variablePrefix">
					<xsl:with-param name="node" select="$node/.." />
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="prg:databinding/prg:variable">
		<xsl:call-template name="prg.sh.parser.boundVariableName">
			<xsl:with-param name="variableNode" select="." />
			<xsl:with-param name="usePrefix" select="true()" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="prg:subcommand/prg:name">
		<xsl:value-of select="normalize-space(.)" />
	</xsl:template>

	<xsl:template match="/">
		<xsl:text><![CDATA[
parse "${@}"
echo -n "CLI: "
cpt="${#}"
debugMode=false
displayHelp=false
i=1
for argv in "${@}"
do
	[ "${argv}" = '__msg__' ] && debugMode=true
	[ "${argv}" = '__help__' ] && displayHelp=true
	[ ${i} -gt 1 ] && echo -n ", "
	echo -n "\"${argv}\""
	i=$(expr ${i} + 1)
done
if ${displayHelp}
then
	usage "${parser_subcommand}"
	exit 0
fi
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
if ${debugMode}
then
	echo "Errors: "
	parse_displayerrors
	echo "Required options: ${#parser_required[*]}"
	for e in "${parser_required[@]}"
	do
		echo " - ${e}"
	done
	echo "Present options: ${#parser_present[*]}"
	for e in "${parser_present[@]}"
	do
		echo " - ${e}"
	done
fi
echo "Subcommand: ${parser_subcommand}"
]]></xsl:text>
		<!-- Global args -->
		<xsl:if test="/prg:program/prg:options">
			<xsl:variable name="root" select="/prg:program/prg:options" />
			<xsl:apply-templates select="$root//prg:switch | $root//prg:argument | $root//prg:multiargument | .//prg:group" />
		</xsl:if>
		<!-- Sub command options -->
		<xsl:for-each select="/prg:program/prg:subcommands/*">
			<xsl:if test="./prg:options">
				<xsl:text>if [ "${parser_subcommand}" = "</xsl:text>
				<xsl:apply-templates select="prg:name" />
				<xsl:text>" ]; then</xsl:text>
				<xsl:value-of select="'&#10;'" />
				<xsl:apply-templates select=".//prg:switch | .//prg:argument | .//prg:multiargument | .//prg:group" />
				<xsl:text>fi</xsl:text>
				<xsl:value-of select="'&#10;'" />
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="//prg:switch">
		<xsl:if test="./prg:databinding/prg:variable">
			<xsl:text>echo </xsl:text>
			<xsl:call-template name="prg.unittest.sh.variablePrefix" />
			<xsl:value-of select="normalize-space(prg:name)" />
			<xsl:value-of select="normalize-space(prg:databinding/prg:variable)" />
			<xsl:text>=$(toboolstr "${</xsl:text>
			<xsl:apply-templates select="prg:databinding/prg:variable" />
			<xsl:text>}")</xsl:text>
			<xsl:value-of select="'&#10;'" />
		</xsl:if>
	</xsl:template>

	<xsl:template match="//prg:argument">
		<xsl:if test="./prg:databinding/prg:variable">
			<xsl:text>echo </xsl:text>
			<xsl:call-template name="prg.unittest.sh.variablePrefix" />
			<xsl:value-of select="normalize-space(prg:name)" />
			<xsl:value-of select="normalize-space(prg:databinding/prg:variable)" />
			<xsl:text>=${</xsl:text>
			<xsl:apply-templates select="prg:databinding/prg:variable" />
			<xsl:text>}</xsl:text>
			<xsl:value-of select="'&#10;'" />
		</xsl:if>
	</xsl:template>

	<xsl:template match="//prg:multiargument">
		<xsl:if test="./prg:databinding/prg:variable">
			<xsl:text>echo </xsl:text>
			<xsl:call-template name="prg.unittest.sh.variablePrefix" />
			<xsl:value-of select="normalize-space(prg:name)" />
			<xsl:value-of select="normalize-space(prg:databinding/prg:variable)" />
			<xsl:text>=${</xsl:text>
			<xsl:apply-templates select="prg:databinding/prg:variable" />
			<xsl:text>[*]}</xsl:text>
			<xsl:value-of select="'&#10;'" />
		</xsl:if>
	</xsl:template>

	<xsl:template match="//prg:group">
		<xsl:if test="./prg:databinding/prg:variable">
			<xsl:text>echo </xsl:text>
			<xsl:apply-templates select="prg:databinding/prg:variable" />
			<xsl:text>=${</xsl:text>
			<xsl:apply-templates select="prg:databinding/prg:variable" />
			<xsl:text>}</xsl:text>
			<xsl:value-of select="'&#10;'" />
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Shell parser base templates -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">

	<xsl:import href="base.xsl" />

	<xsl:param name="prg.sh.parser.prefixSubcommandOptionVariable" select="'no'" />

	<xsl:template name="prg.sh.parser.boundVariableName">
		<!-- Variable name node -->
		<xsl:param name="variableNode" />
		<!-- Option/Positional argument node -->
		<xsl:param name="node" select="$variableNode/../.." />
		<xsl:param name="usePrefix" select="($prg.sh.parser.prefixSubcommandOptionVariable = 'yes')" />

		<xsl:choose>
			<xsl:when test="$node/self::prg:program">
				<xsl:call-template name="sh.validIdentifierName">
					<xsl:with-param name="name" select="$variableNode" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$node/self::prg:subcommand">
				<xsl:call-template name="sh.validIdentifierName">
					<xsl:with-param name="name">
						<xsl:if test="$usePrefix">
							<xsl:value-of select="normalize-space($node/prg:name)" />
							<xsl:text>_</xsl:text>
						</xsl:if>
						<xsl:value-of select="normalize-space($variableNode)" />
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$node/../..">
				<xsl:call-template name="prg.sh.parser.boundVariableName">
					<xsl:with-param name="variableNode" select="$variableNode" />
					<xsl:with-param name="node" select="$node/../.." />
					<xsl:with-param name="usePrefix" select="$usePrefix" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space($variableNode)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Prefix of all parser functions -->
	<xsl:variable name="prg.sh.parser.functionNamePrefix">
		<xsl:text>parse_</xsl:text>
	</xsl:variable>

	<!-- Prefix of all parser variable -->
	<xsl:variable name="prg.sh.parser.variableNamePrefix">
		<xsl:text>parser_</xsl:text>
	</xsl:variable>

	<xsl:template match="//prg:databinding/prg:variable">
		<xsl:call-template name="prg.sh.parser.boundVariableName">
			<xsl:with-param name="variableNode" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="prg:default|prg:select/prg:option">
		<!-- Escape special character. Assumes the literal is enclosed by single-quotes -->
		<xsl:call-template name="sh.escapeLiteral">
			<xsl:with-param name="value" select="." />
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>

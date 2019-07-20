<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 - 2020 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Basic templates and variable used in most of shell generation stylesheets -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">

	<xsl:import href="../../../languages/shellscript.xsl" />
	<xsl:import href="../base.xsl" />

	<!-- Display of on option name using the UNIX conventions -->
	<!-- - Single minus for mono-character options -->
	<!-- - Double minus for multi-characters options -->
	<xsl:template name="prg.sh.optionDisplayName">
		<xsl:param name="optionNode" select="." />
		<xsl:param name="recursive" select="true()" />
		<xsl:choose>
			<xsl:when test="$recursive and $optionNode/self::prg:group">
				<xsl:text>(</xsl:text>
				<xsl:for-each select="$optionNode/prg:options/*">
					<xsl:call-template name="prg.sh.optionDisplayName">
						<xsl:with-param name="recursive" select="true()" />
					</xsl:call-template>
					<xsl:if test="position() != last()">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:for-each>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:when test="$optionNode/prg:names/prg:long">
				<xsl:call-template name="prg.cliOptionName">
					<xsl:with-param name="nameNode" select="$optionNode/prg:names/prg:long[1]" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="prg.cliOptionName">
					<xsl:with-param name="nameNode" select="$optionNode/prg:names/prg:short[1]" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>

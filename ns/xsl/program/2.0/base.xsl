<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2018 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Basic templates and variable used in many program interface definition schema processing -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	<xsl:import href="../../strings.xsl" />
	<xsl:import href="../../languages/base.xsl" />

	<xsl:param name="prg.prefix" />
	<xsl:param name="prg.debug" select="false()" />

	<!-- Strip spaces -->
	<xsl:template match="prg:short|prg:long|prg:name|prg:abstract|prg:author|prg:copyright|prg:version">
		<xsl:value-of select="normalize-space(.)" />
	</xsl:template>

	<!-- Display the given name prefixed by the value of the parameter prg.prefix -->
	<xsl:template name="prg.prefixedName">
		<xsl:param name="name" />
		<xsl:value-of select="normalize-space($prg.prefix)" />
		<xsl:value-of select="normalize-space($name)" />
	</xsl:template>

	<!-- Option name as it appears on a command line -->
	<xsl:template name="prg.cliOptionName">
		<xsl:param name="nameNode" select="." />
		<xsl:choose>
			<xsl:when test="$nameNode/self::prg:long">
				<xsl:text>-</xsl:text>
				<xsl:text>-</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>-</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="$nameNode" />
	</xsl:template>

	<!-- Option level in the Option tree -->
	<xsl:template name="prg.optionLevel">
		<!-- Option node -->
		<xsl:param name="optionNode" select="." />
		<!-- For internal use -->
		<xsl:param name="_level" select="0" />
		<xsl:variable name="grandParent" select="$optionNode/../.." />
		<xsl:choose>
			<xsl:when test="$grandParent/self::prg:group">
				<xsl:call-template name="prg.optionLevel">
					<xsl:with-param name="optionNode" select="$grandParent" />
					<xsl:with-param name="_level" select="$_level + 1" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$_level" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Build a unique option id using the full path of the option from the prg:program node -->
	<xsl:template name="prg.optionId">
		<xsl:param name="optionNode" select="." />

		<xsl:variable name="grandParent" select="$optionNode/../.." />
		<xsl:variable name="isFinal" select="($optionNode/self::prg:program or $optionNode/self::prg:subcommand)" />
		<xsl:variable name="index" select="count($optionNode/preceding-sibling::*)+1" />

		<!-- Recursive call -->
		<xsl:choose>
			<xsl:when test="$isFinal">
				<xsl:choose>
					<xsl:when test="$optionNode/self::prg:subcommand">
						<xsl:text>SC</xsl:text>
						<xsl:text>_</xsl:text>
						<xsl:value-of select="$index" />
						<xsl:text>_</xsl:text>
						<xsl:call-template name="cede.validIdentifierName">
							<xsl:with-param name="name" select="$optionNode/prg:name" />
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$optionNode/self::prg:program">
						<xsl:text>G</xsl:text>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="prg.optionId">
					<xsl:with-param name="optionNode" select="$grandParent" />
				</xsl:call-template>
				<xsl:text>_</xsl:text>
				<xsl:value-of select="$index" />
				<xsl:text>_</xsl:text>
				<xsl:choose>
					<xsl:when test="$optionNode/self::prg:group">
						<xsl:text>g</xsl:text>
					</xsl:when>
					<xsl:when test="$optionNode/prg:names/prg:long">
						<xsl:call-template name="cede.validIdentifierName">
							<xsl:with-param name="name">
								<xsl:apply-templates select="$optionNode/prg:names/prg:long[1]" />
							</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="cede.validIdentifierName">
							<xsl:with-param name="name">
								<xsl:apply-templates select="$optionNode/prg:names/prg:short[1]" />
							</xsl:with-param>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- 'User-friendly name' of the program -->
	<xsl:template name="prg.programDisplayName">
		<xsl:choose>
			<xsl:when test="/prg:program/prg:ui/prg:label">
				<xsl:value-of select="normalize-space(/prg:program/prg:ui/prg:label)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space(/prg:program/prg:name)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>

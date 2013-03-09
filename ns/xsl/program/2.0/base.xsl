<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Basic templates and variable used in many program interface definition schema processing -->
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" version="1.0">
	<import href="../../strings.xsl"/>
	<import href="../../languages/base.xsl"/>
	
	<param name="prg.prefix" />
	<param name="prg.debug" select="false()" />
	
	<!-- Strip spaces -->
	<template match="prg:short|prg:long|prg:name|prg:abstract|prg:author|prg:copyright|prg:version">
		<value-of select="normalize-space(.)"/>
	</template>

	<!-- Display the given name prefixed by the value of the parameter prg.prefix -->
	<template name="prg.prefixedName">
		<param name="name"/>
		<value-of select="normalize-space($prg.prefix)"/>
		<value-of select="normalize-space($name)"/>
	</template>

	<!-- Option name as it appears on a command line -->
	<template name="prg.cliOptionName">
		<param name="nameNode" select="."/>
		<choose>
			<when test="$nameNode/self::prg:long">
				<text>-</text>
				<text>-</text>
			</when>
			<otherwise>
				<text>-</text>
			</otherwise>
		</choose>
		<value-of select="$nameNode"/>
	</template>

	<!-- Option level in the Option tree -->
	<template name="prg.optionLevel">
		<!-- Option node -->
		<param name="optionNode" select="."/>
		<!-- For internal use -->
		<param name="_level" select="0"/>
		<variable name="grandParent" select="$optionNode/../.."/>
		<choose>
			<when test="$grandParent/self::prg:group">
				<call-template name="prg.optionLevel">
					<with-param name="optionNode" select="$grandParent"/>
					<with-param name="_level" select="$_level + 1"/>
				</call-template>
			</when>
			<otherwise>
				<value-of select="$_level"/>
			</otherwise>
		</choose>
	</template>

	<!-- Build a unique option id using the full path of the option from the prg:program node -->
	<template name="prg.optionId">
		<param name="optionNode" select="."/>
		
		<variable name="grandParent" select="$optionNode/../.."/>
		<variable name="isFinal" select="($optionNode/self::prg:program or $optionNode/self::prg:subcommand)"/>
		<variable name="index" select="count($optionNode/preceding-sibling::*)+1"/>
		
		<!-- Recursive call -->
		<choose>
			<when test="$isFinal">
				<choose>
					<when test="$optionNode/self::prg:subcommand">
						<text>SC</text>
						<text>_</text>
						<value-of select="$index"/>
						<text>_</text>
						<call-template name="cede.validIdentifierName">
							<with-param name="name" select="$optionNode/prg:name" />
						</call-template>
					</when>
					<when test="$optionNode/self::prg:program">
						<text>G</text>
					</when>
				</choose>
			</when>
			<otherwise>
				<call-template name="prg.optionId">
					<with-param name="optionNode" select="$grandParent"/>
				</call-template>
				<text>_</text>
				<value-of select="$index"/>
				<text>_</text>
				<choose>
					<when test="$optionNode/self::prg:group">
						<text>g</text>
					</when>
					<when test="$optionNode/prg:names/prg:long">
						<call-template name="cede.validIdentifierName">
							<with-param name="name">
								<apply-templates select="$optionNode/prg:names/prg:long[1]"/>
							</with-param>
						</call-template>
					</when>
					<otherwise>
						<call-template name="cede.validIdentifierName">
							<with-param name="name">
								<apply-templates select="$optionNode/prg:names/prg:short[1]"/>
							</with-param>
						</call-template>
					</otherwise>
				</choose>
			</otherwise>
		</choose>
	</template>

	<!-- 'User-friendly name' of the program -->
	<template name="prg.programDisplayName">
		<choose>
			<when test="/prg:program/prg:ui/prg:label">
				<value-of select="normalize-space(/prg:program/prg:ui/prg:label)"/>
			</when>
			<otherwise>
				<value-of select="normalize-space(/prg:program/prg:name)"/>
			</otherwise>
		</choose>
	</template>

</stylesheet>

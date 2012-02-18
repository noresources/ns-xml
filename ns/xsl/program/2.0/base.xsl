<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (c) 2011 by Renaud Guillard (dev@niao.fr) -->

<!-- Basic templates and variable used in many program schema processing -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">

	<import href="../../strings.xsl" />

	<param name="prg.prefix" />

	<param name="prg.debug" select="false()" />

	<!-- Display the given name prefixed by the value of the parameter prg.prefix -->
	<template name="prg.prefixedName">
		<param name="name" />
		<value-of select="$prg.prefix" />
		<value-of select="$name" />
	</template>

	<!-- Build a unique option id using the full path of the option from the prg:program node -->
	<template name="prg.optionId">
		<param name="optionNode" select="." />

		<variable name="grandParent" select="$optionNode/../.." />

		<variable name="isFinal" select="($optionNode/self::prg:program or $optionNode/self::prg:subcommand)" />
		<variable name="index" select="count($optionNode/preceding-sibling::*)+1" />

		<!-- Recursive call -->
		<choose>
			<when test="$isFinal">
				<choose>
					<when test="$optionNode/self::prg:subcommand">
						<text>SC</text>
						<text>_</text>
						<value-of select="$index" />
						<text>_</text>
						<value-of select="$optionNode/prg:name" />
					</when>
					<when test="$optionNode/self::prg:program">
						<text>G</text>
					</when>
				</choose>
			</when>
			<otherwise>
				<call-template name="prg.optionId">
					<with-param name="optionNode" select="$grandParent" />
				</call-template>

				<text>_</text>
				<value-of select="$index" />
				<text>_</text>
				<choose>
					<when test="$optionNode/self::prg:group">
						<text>g</text>
					</when>
					<when test="$optionNode/prg:names/prg:long">
						<value-of select="$optionNode/prg:names/prg:long[1]" />
					</when>
					<otherwise>
						<value-of select="$optionNode/prg:names/prg:short[1]" />
					</otherwise>
				</choose>
			</otherwise>
		</choose>
	</template>

	<!-- 'User-friendly name' of the program -->
	<template name="prg.programDisplayName">
		<choose>
			<when test="/prg:program/prg:ui/prg:label">
				<value-of select="/prg:program/prg:ui/prg:label" />
			</when>
			<otherwise>
				<value-of select="/prg:program/prg:name" />
			</otherwise>
		</choose>
	</template>

</stylesheet>

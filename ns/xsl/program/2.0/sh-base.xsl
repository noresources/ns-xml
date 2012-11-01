<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the BSD License, see LICENSE -->

<!-- Basic templates and variable used in most of shell generation stylesheets -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">

	<import href="../../languages/shellscript.xsl" />
	<import href="base.xsl" />
	
	<!-- Display of on option name using the UNIX conventions -->
	<!-- - Single minus for mono-character options -->
	<!-- - Double minus for multi-characters options -->
	<template name="prg.sh.optionDisplayName">
		<param name="optionNode" select="." />
		<param name="recursive" select="true()" />
		<choose>
			<when test="$recursive and $optionNode/self::prg:group">
				<text>(</text>
				<for-each select="$optionNode/prg:options/*">
					<call-template name="prg.sh.optionDisplayName">
						<with-param name="recursive" select="true()" />
					</call-template>
					<if test="position() != last()">
						<text>, </text>
					</if>
				</for-each>
				<text>)</text>
			</when>
			<when test="$optionNode/prg:names/prg:long">
				<call-template name="prg.cliOptionName">
					<with-param name="nameNode" select="$optionNode/prg:names/prg:long[1]" />
				</call-template>
			</when>
			<otherwise>
				<call-template name="prg.cliOptionName">
					<with-param name="nameNode" select="$optionNode/prg:names/prg:short[1]" />
				</call-template>
			</otherwise>
		</choose>
	</template>

</stylesheet>

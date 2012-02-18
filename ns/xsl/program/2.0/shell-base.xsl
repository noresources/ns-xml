<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (c) 2011 by Renaud Guillard (dev@niao.fr) -->
<!--Basic templates and variable used in most of shell generation stylesheets -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">

	<import href="base.xsl" />
	<import href="../../languages/shellscript.xsl" />

	<param name="prg.sh.indentChar">
		<text>&#32;&#32;</text>
	</param>

	<!-- Display of on option name using the UNIX conventions -->
	<!-- - Single minus for mono-character options -->
	<!-- - Double minus for multi-characters options -->
	<template name="prg.sh.optionDisplayName">
		<param name="optionNode" select="." />
		<choose>
			<when test="$optionNode/prg:names/prg:long">
				<call-template name="prg.sh.optionName">
					<with-param name="nameNode" select="$optionNode/prg:names/prg:long[1]" />
				</call-template>
			</when>
			<otherwise>
				<call-template name="prg.sh.optionName">
					<with-param name="nameNode" select="$optionNode/prg:names/prg:short[1]" />
				</call-template>
			</otherwise>
		</choose>
	</template>

	<template name="prg.sh.optionName">
		<param name="nameNode" select="." />
		<choose>
			<when test="$nameNode/self::prg:long">
				<text>&#45;</text>
				<text>&#45;</text>
			</when>
			<otherwise>
				<text>&#45;</text>
			</otherwise>
		</choose>
		<value-of select="$nameNode" />
	</template>

	<template match="prg:br">
		<call-template name="endl" />
	</template>

	<template match="prg:endl">
		<call-template name="endl" />
	</template>

	<template match="prg:block">
		<call-template name="endl" />
		<call-template name="str.prependLine">
			<with-param name="prependedText" select="$prg.sh.indentChar" />
			<with-param name="content">
				<apply-templates />
			</with-param>
		</call-template>
	</template>

</stylesheet>

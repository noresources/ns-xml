<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->
<!-- Usage chunks for usage -->
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" version="1.0">
	<import href="usage.chunks.xsl"/>
	<param name="prg.sh.usage.indentChar">
		<text>  </text>
	</param>
	<!-- override default param prg.usage.indentChar -->
	<variable name="prg.usage.indentChar" select="$prg.sh.usage.indentChar"/>
	<template match="prg:details/text()">
		<value-of select="normalize-space(.)"/>
	</template>

	<template match="prg:block">
		<call-template name="endl"/>
		<call-template name="str.prependLine">
			<with-param name="prependedText" select="$prg.usage.indentChar"/>
			<with-param name="text">
				<call-template name="prg.usage.descriptionDisplay"/>
			</with-param>
		</call-template>
	</template>

	<!-- Name of the usage() function -->
	<variable name="prg.sh.usage.usageFunctionName">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<text>usage</text>
			</with-param>
		</call-template>
	</variable>
</stylesheet>

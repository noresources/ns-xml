<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->

<!-- Usage chunks for usage -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">

	<import href="usage.chunks.xsl" />

	<param name="prg.sh.usage.indentChar">
		<text>&#32;&#32;</text>
	</param>
	
	<template match="prg:details/text()">
		<value-of select="normalize-space(.)" />
	</template>
	
	<template match="prg:block">
		<call-template name="endl" />
		<call-template name="str.prependLine">
			<with-param name="prependedText" select="$prg.sh.usage.indentChar" />
			<with-param name="text">
				<call-template name="prg.usage.descriptionDisplay" />
			</with-param>
			<!-- 
			<with-param name="wrap" select="true()" />
			<with-param name="lineMaxLength" select="80" /> -->
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

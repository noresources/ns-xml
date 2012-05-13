<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->

<!-- Common templates for code generation -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform">

	<import href="../strings.xsl" />

	<param name="code.indentChar">
		<text>&#9;</text>
	</param>

	<!-- Prepend all lines with a comment marker -->
	<template name="code.comment">
		<!-- Comment marker for all lines (except first and last) -->
		<param name="marker" />
		<!-- Comment marker for the first line -->
		<param name="beginMarker" select="$marker" />
		<!-- Comment marker for the last line -->
		<param name="endMarker" select="$marker" />
		<!-- Comment text -->
		<param name="content" select="." />

		<if test="$beginMarker != $marker">
			<value-of select="$beginMarker" />
			<call-template name="endl" />
		</if>
		<value-of select="$marker" />
		<call-template name="str.trim">
			<with-param name="text">
				<call-template name="str.replaceAll">
					<with-param name="text" select="$content" />
					<with-param name="replace">
						<text>&#10;</text>
					</with-param>
					<with-param name="by">
						<text>&#10;</text>
						<value-of select="$marker" />
					</with-param>
				</call-template>
			</with-param>
		</call-template>
		<call-template name="endl" />
		<if test="$endMarker != $marker">
			<value-of select="$endMarker" />
			<call-template name="endl" />
		</if>
	</template>

	<!-- Indent a block of text, prepending any line with the code.indentChar
		A new line is also added at beginning and end of block -->
	<template name="code.block">
		<param name="content" />
		<param name="indentChar" select="$code.indentChar" />
		<param name="endl"><call-template name="endl" /></param>
		<param name="addInitialEndl" select="true()" />
		<param name="addFinalEndl" select="true()" />
		<if test="$addInitialEndl">
			<value-of select="$endl" />
		</if>
		<value-of select="$indentChar" />
		<call-template name="str.trim">
			<with-param name="text">
				<call-template name="str.replaceAll">
					<with-param name="text" select="$content" />
					<with-param name="replace">
						<text>&#10;</text>
					</with-param>
					<with-param name="by">
						<text>&#10;</text>
						<value-of select="$indentChar" />
					</with-param>
				</call-template>
			</with-param>
		</call-template>
		<if test="$addFinalEndl">
			<value-of select="$endl" />
		</if>
	</template>

</stylesheet>
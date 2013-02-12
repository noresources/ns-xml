<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

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
			<value-of select="$str.endl" />
		</if>
		<value-of select="$marker" />
		<call-template name="str.trim">
			<with-param name="text">
				<call-template name="str.replaceAll">
					<with-param name="text" select="$content" />
					<with-param name="replace" select="'&#10;'" />
					<with-param name="by" select="concat('&#10;', $marker)" />
				</call-template>
			</with-param>
		</call-template>
		<if test="$endMarker != $marker">
			<value-of select="$str.endl" />
			<value-of select="$endMarker" />
		</if>
	</template>

	<!-- Indent a block of text, prepending any line with the code.indentChar
		A new line is also added at beginning and end of block -->
	<template name="code.block">
		<param name="content" />
		<param name="indentChar" select="$code.indentChar" />
		<param name="endl">
			<value-of select="$str.endl" />
		</param>
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
					<with-param name="replace" select="'&#10;'" />
					<with-param name="by" select="concat('&#10;', $indentChar)" />
				</call-template>
			</with-param>
		</call-template>
		<if test="$addFinalEndl">
			<value-of select="$endl" />
		</if>
	</template>


	<!-- Transform a identifier name from a naming style to another -->
	<template name="code.identifierNamingStyle">
		<!-- Identifier to transform -->
		<param name="identifier" />
		<!-- Current naming style of the identifier. Possible values: 'auto' (recommended), 'CamelCase', 'camelCase', 'underscore', 'hyphen', 'mixed' -->
		<param name="from" select="'auto'" />
		<!-- Targeted naming style. Possible values: 'CamelCase', 'camelCase', 'underscore', 'hyphen', 'none' -->
		<param name="to" select="'camelCase'" />
		<!-- A string that will never appear in an identifier string -->
		<param name="transitionalChar" select="'&#10;'" />

		<choose>
			<!-- Auto-detect and re-call template -->
			<when test="$from = 'auto'">
				<variable name="autoDetectFrom">
					<call-template name="code.identifierNamingStyleAutoDetect">
						<with-param name="identifier" select="$identifier" />
					</call-template>
				</variable>
				<call-template name="code.identifierNamingStyle">
					<with-param name="identifier" select="$identifier" />
					<with-param name="from" select="$autoDetectFrom" />
					<with-param name="to" select="$to" />
				</call-template>
			</when>
			<!-- Ignore if from and to are the same -->
			<when test="$from = $to">
				<value-of select="$identifier" />
			</when>
			<!-- Convert to hypen or underscore style -->
			<when test="($to = 'underscore') or ($to = 'hyphen')">
				<variable name="prefixFrom">
					<choose>
						<when test="($to = 'underscore')">
							<text>-</text>
						</when>
						<otherwise>
							<text>_</text>
						</otherwise>
					</choose>
				</variable>
				<variable name="prefixTo">
					<choose>
						<when test="($to = 'underscore')">
							<text>_</text>
						</when>
						<otherwise>
							<text>-</text>
						</otherwise>
					</choose>
				</variable>
				<call-template name="code.identifierNamingStyleLowerPrepend">
					<with-param name="identifier" select="translate($identifier, '-_', concat($prefixTo, $prefixTo))" />
					<with-param name="prefix" select="$prefixTo" />
				</call-template>
			</when>
			<!-- CamelCase styles -->
			<when test="($to = 'camelCase') or ($to = 'CamelCase')">
				<variable name="separator">
					<choose>
						<when test="($from = 'underscore')">
							<text>_</text>
						</when>
						<when test="($from = 'hyphen')">
							<text>-</text>
						</when>
						<otherwise />
					</choose>
				</variable>
				
				<variable name="before">
					<call-template name="str.startsWithCount">
						<with-param name="text" select="$identifier" />
						<with-param name="needle" select="$separator" />
					</call-template>
				</variable>
				
				<variable name="after">
					<call-template name="str.endsWithCount">
						<with-param name="text" select="$identifier" />
						<with-param name="needle" select="$separator" />
					</call-template>
				</variable>
				
				<!-- temporary trim identifier -->
				<variable name="identifierPart" select="substring($identifier, $before + 1, (string-length($identifier) - ($before + $after)))" />
				
				<variable name="result">
					<call-template name="code.identifierNamingStyleUpperUnprepend">
						<with-param name="identifier" select="translate($identifierPart, '-_', concat($transitionalChar, $transitionalChar))" />
						<with-param name="prefix" select="$transitionalChar" />
					</call-template>
				</variable>
											
				<call-template name="str.repeat">
					<with-param name="text" select="$separator" />
					<with-param name="iterations" select="$before" />
				</call-template>	
				<choose>
					<when test="$to = 'camelCase'">
						<call-template name="str.toLower">
							<with-param name="text" select="substring($result, 1, 1)" />
						</call-template>
						<value-of select="substring($result, 2)" />
					</when>
					<otherwise>
						<call-template name="str.toUpper">
							<with-param name="text" select="substring($result, 1, 1)" />
						</call-template>
						<value-of select="substring($result, 2)" />
					</otherwise>
				</choose>
				<call-template name="str.repeat">
					<with-param name="text" select="$separator" />
					<with-param name="iterations" select="$after" />
				</call-template>
			</when>
			<otherwise>
				<value-of select="$identifier" />
			</otherwise>
		</choose>
	</template>

	<!-- Auto-detect identifier naming convention -->
	<template name="code.identifierNamingStyleAutoDetect">
		<param name="identifier" />

		<choose>
			<when test="contains($identifier, '_')">	
				<choose>
					<when test="contains($identifier, '-')">
						<text>mixed</text>
					</when>
					<otherwise>
						<text>underscore</text>
					</otherwise>
				</choose>
			</when>
			<when test="contains($identifier, '-')">
				<text>hyphen</text>
			</when>
			<otherwise>
				<variable name="lower" select="translate($identifier, 'abcdefghijklmnopqrstuvwxyz', 'aaaaaaaaaaaaaaaaaaaaaaaaaa')" />
				<choose>
					<when test="starts-with($lower, 'a')">
						<text>camelCase</text>
					</when>
					<otherwise>
						<text>CamelCase</text>
					</otherwise>
				</choose>
			</otherwise>
		</choose>
	</template>

	<!-- Transform all uppercase letter to lowercase prefixed with the given characted -->
	<template name="code.identifierNamingStyleLowerPrepend">
		<!-- Identifier to transform -->
		<param name="identifier" />
		<!-- Prefix to add before any uppercase letter -->
		<param name="prefix" />
		<!-- Internal use -->
		<param name="index" select="1" />

		<variable name="lowerLetter" select="substring($str.smallCase, $index, 1)" />
		<variable name="upperLetter" select="substring($str.upperCase, $index, 1)" />

		<!-- <value-of select="$lowerLetter"/>
			<text> </text>
			<value-of select="$upperLetter"/> -->

		<variable name="result">
			<call-template name="str.replaceAll">
				<with-param name="text">
					<call-template name="str.replaceAll">
						<with-param name="text" select="$identifier" />
						<with-param name="replace" select="concat($prefix, $upperLetter)" />
						<with-param name="by" select="$upperLetter" />
					</call-template>
				</with-param>
				<with-param name="replace" select="$upperLetter" />
				<with-param name="by" select="concat($prefix, $lowerLetter)" />
			</call-template>
		</variable>

		<choose>
			<when test="$index &lt; 26">
				<call-template name="code.identifierNamingStyleLowerPrepend">
					<with-param name="identifier" select="$result" />
					<with-param name="prefix" select="$prefix" />
					<with-param name="index" select="$index + 1" />
				</call-template>
			</when>
			<otherwise>
				<choose>
					<when test="starts-with($result, $prefix)">
						<value-of select="substring($result, string-length($prefix) + 1)" />
					</when>
					<otherwise>
						<value-of select="$result" />
					</otherwise>
				</choose>
			</otherwise>
		</choose>
	</template>

	<template name="code.identifierNamingStyleUpperUnprepend">
		<param name="identifier" />
		<param name="prefix" />
		<param name="index" select="1" />

		<variable name="lowerLetter" select="substring($str.smallCase, $index, 1)" />
		<variable name="upperLetter" select="substring($str.upperCase, $index, 1)" />

		<variable name="result">
			<call-template name="str.replaceAll">
				<with-param name="text">
					<call-template name="str.replaceAll">
						<with-param name="text" select="$identifier" />
						<with-param name="replace" select="concat($prefix, $upperLetter)" />
						<with-param name="by" select="$upperLetter" />
					</call-template>
				</with-param>
				<with-param name="replace" select="concat($prefix, $lowerLetter)" />
				<with-param name="by" select="$upperLetter" />
			</call-template>
		</variable>

		<choose>
			<when test="$index &lt; 26">
				<call-template name="code.identifierNamingStyleUpperUnprepend">
					<with-param name="identifier" select="$result" />
					<with-param name="prefix" select="$prefix" />
					<with-param name="index" select="$index + 1" />
				</call-template>
			</when>
			<otherwise>
				<value-of select="$result" />
			</otherwise>
		</choose>
	</template>
</stylesheet>
<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2018 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Common templates for code generation -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:import href="../strings.xsl" />

	<xsl:param name="code.indentChar">
		<xsl:text>&#9;</xsl:text>
	</xsl:param>
	
	<!-- Attempt to transform a name to fit common identifier name restriction (no 
		spaces, etc) -->
	<xsl:template name="cede.validIdentifierName">
		<!-- Identifier name to transform -->
		<xsl:param name="name" />
		
		<!-- replace some characters into _ -->
		<xsl:variable name="tname" select="translate(normalize-space($name),'- ','_')" />
		
		<!-- add _ if the variable start with a digit -->
		<xsl:value-of select="translate(substring($tname, 1, 1), '1234567890', '_')" />
		<xsl:value-of select="substring($tname, 2)" />
	</xsl:template>
	

	<!-- Prepend all lines with a comment marker -->
	<xsl:template name="code.comment">
		<!-- Comment marker for all lines (except first and last) -->
		<xsl:param name="marker" />
		<!-- Comment marker for the first line -->
		<xsl:param name="beginMarker" select="$marker" />
		<!-- Comment marker for the last line -->
		<xsl:param name="endMarker" select="$marker" />
		<!-- Comment text -->
		<xsl:param name="content" select="." />

		<xsl:if test="$beginMarker != $marker">
			<xsl:value-of select="$beginMarker" />
			<xsl:value-of select="$str.endl" />
		</xsl:if>
		<xsl:value-of select="$marker" />
		<xsl:call-template name="str.trim">
			<xsl:with-param name="text">
				<xsl:call-template name="str.replaceAll">
					<xsl:with-param name="text" select="$content" />
					<xsl:with-param name="replace" select="'&#10;'" />
					<xsl:with-param name="by" select="concat('&#10;', $marker)" />
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:if test="$endMarker != $marker">
			<xsl:value-of select="$str.endl" />
			<xsl:value-of select="$endMarker" />
		</xsl:if>
	</xsl:template>

	<!-- Indent a block of text, prepending any line with the code.indentChar
		A new line is also added at beginning and end of block -->
	<xsl:template name="code.block">
		<xsl:param name="content" />
		<xsl:param name="indentChar" select="$code.indentChar" />
		<xsl:param name="endl">
			<xsl:value-of select="$str.endl" />
		</xsl:param>
		<xsl:param name="addInitialEndl" select="true()" />
		<xsl:param name="addFinalEndl" select="true()" />
		<xsl:if test="$addInitialEndl">
			<xsl:value-of select="$endl" />
		</xsl:if>
		<xsl:value-of select="$indentChar" />
		<xsl:call-template name="str.trim">
			<xsl:with-param name="text">
				<xsl:call-template name="str.replaceAll">
					<xsl:with-param name="text" select="$content" />
					<xsl:with-param name="replace" select="'&#10;'" />
					<xsl:with-param name="by" select="concat('&#10;', $indentChar)" />
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:if test="$addFinalEndl">
			<xsl:value-of select="$endl" />
		</xsl:if>
	</xsl:template>


	<!-- Transform a identifier name from a naming style to another -->
	<xsl:template name="code.identifierNamingStyle">
		<!-- Identifier to transform -->
		<xsl:param name="identifier" />
		<!-- Current naming style of the identifier. Possible values: 'auto' (recommended), 'CamelCase', 'camelCase', 'underscore', 'hyphen', 'mixed' -->
		<xsl:param name="from" select="'auto'" />
		<!-- Targeted naming style. Possible values: 'CamelCase', 'camelCase', 'underscore', 'hyphen', 'none' -->
		<xsl:param name="to" select="'camelCase'" />
		<!-- A string that will never appear in an identifier string -->
		<xsl:param name="transitionalChar" select="'&#10;'" />

		<xsl:choose>
			<!-- Auto-detect and re-call template -->
			<xsl:when test="$from = 'auto'">
				<xsl:variable name="autoDetectFrom">
					<xsl:call-template name="code.identifierNamingStyleAutoDetect">
						<xsl:with-param name="identifier" select="$identifier" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:call-template name="code.identifierNamingStyle">
					<xsl:with-param name="identifier" select="$identifier" />
					<xsl:with-param name="from" select="$autoDetectFrom" />
					<xsl:with-param name="to" select="$to" />
				</xsl:call-template>
			</xsl:when>
			<!-- Ignore if from and to are the same -->
			<xsl:when test="$from = $to">
				<xsl:value-of select="$identifier" />
			</xsl:when>
			<!-- Convert to hypen or underscore style -->
			<xsl:when test="($to = 'underscore') or ($to = 'hyphen')">
				<xsl:variable name="prefixFrom">
					<xsl:choose>
						<xsl:when test="($to = 'underscore')">
							<xsl:text>-</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>_</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="prefixTo">
					<xsl:choose>
						<xsl:when test="($to = 'underscore')">
							<xsl:text>_</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>-</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:call-template name="code.identifierNamingStyleLowerPrepend">
					<xsl:with-param name="identifier" select="translate($identifier, '-_', concat($prefixTo, $prefixTo))" />
					<xsl:with-param name="prefix" select="$prefixTo" />
				</xsl:call-template>
			</xsl:when>
			<!-- CamelCase styles -->
			<xsl:when test="($to = 'camelCase') or ($to = 'CamelCase')">
				<xsl:variable name="separator">
					<xsl:choose>
						<xsl:when test="($from = 'underscore')">
							<xsl:text>_</xsl:text>
						</xsl:when>
						<xsl:when test="($from = 'hyphen')">
							<xsl:text>-</xsl:text>
						</xsl:when>
						<xsl:otherwise />
					</xsl:choose>
				</xsl:variable>
				
				<xsl:variable name="before">
					<xsl:call-template name="str.startsWithCount">
						<xsl:with-param name="text" select="$identifier" />
						<xsl:with-param name="needle" select="$separator" />
					</xsl:call-template>
				</xsl:variable>
				
				<xsl:variable name="after">
					<xsl:call-template name="str.endsWithCount">
						<xsl:with-param name="text" select="$identifier" />
						<xsl:with-param name="needle" select="$separator" />
					</xsl:call-template>
				</xsl:variable>
				
				<!-- temporary trim identifier -->
				<xsl:variable name="identifierPart" select="substring($identifier, $before + 1, (string-length($identifier) - ($before + $after)))" />
				
				<xsl:variable name="result">
					<xsl:call-template name="code.identifierNamingStyleUpperUnprepend">
						<xsl:with-param name="identifier" select="translate($identifierPart, '-_', concat($transitionalChar, $transitionalChar))" />
						<xsl:with-param name="prefix" select="$transitionalChar" />
					</xsl:call-template>
				</xsl:variable>
											
				<xsl:call-template name="str.repeat">
					<xsl:with-param name="text" select="$separator" />
					<xsl:with-param name="iterations" select="$before" />
				</xsl:call-template>	
				<xsl:choose>
					<xsl:when test="$to = 'camelCase'">
						<xsl:call-template name="str.toLower">
							<xsl:with-param name="text" select="substring($result, 1, 1)" />
						</xsl:call-template>
						<xsl:value-of select="substring($result, 2)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="str.toUpper">
							<xsl:with-param name="text" select="substring($result, 1, 1)" />
						</xsl:call-template>
						<xsl:value-of select="substring($result, 2)" />
					</xsl:otherwise>
				</xsl:choose>
				<xsl:call-template name="str.repeat">
					<xsl:with-param name="text" select="$separator" />
					<xsl:with-param name="iterations" select="$after" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$identifier" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Auto-detect identifier naming convention -->
	<xsl:template name="code.identifierNamingStyleAutoDetect">
		<xsl:param name="identifier" />

		<xsl:choose>
			<xsl:when test="contains($identifier, '_')">	
				<xsl:choose>
					<xsl:when test="contains($identifier, '-')">
						<xsl:text>mixed</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>underscore</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="contains($identifier, '-')">
				<xsl:text>hyphen</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="lower" select="translate($identifier, 'abcdefghijklmnopqrstuvwxyz', 'aaaaaaaaaaaaaaaaaaaaaaaaaa')" />
				<xsl:choose>
					<xsl:when test="starts-with($lower, 'a')">
						<xsl:text>camelCase</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>CamelCase</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Transform all uppercase letter to lowercase prefixed with the given characted -->
	<xsl:template name="code.identifierNamingStyleLowerPrepend">
		<!-- Identifier to transform -->
		<xsl:param name="identifier" />
		<!-- Prefix to add before any uppercase letter -->
		<xsl:param name="prefix" />
		<!-- Internal use -->
		<xsl:param name="index" select="1" />

		<xsl:variable name="lowerLetter" select="substring($str.smallCase, $index, 1)" />
		<xsl:variable name="upperLetter" select="substring($str.upperCase, $index, 1)" />

		<!-- <value-of select="$lowerLetter"/>
			<text> </text>
			<value-of select="$upperLetter"/> -->

		<xsl:variable name="result">
			<xsl:call-template name="str.replaceAll">
				<xsl:with-param name="text">
					<xsl:call-template name="str.replaceAll">
						<xsl:with-param name="text" select="$identifier" />
						<xsl:with-param name="replace" select="concat($prefix, $upperLetter)" />
						<xsl:with-param name="by" select="$upperLetter" />
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="replace" select="$upperLetter" />
				<xsl:with-param name="by" select="concat($prefix, $lowerLetter)" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$index &lt; 26">
				<xsl:call-template name="code.identifierNamingStyleLowerPrepend">
					<xsl:with-param name="identifier" select="$result" />
					<xsl:with-param name="prefix" select="$prefix" />
					<xsl:with-param name="index" select="$index + 1" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="starts-with($result, $prefix)">
						<xsl:value-of select="substring($result, string-length($prefix) + 1)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$result" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="code.identifierNamingStyleUpperUnprepend">
		<xsl:param name="identifier" />
		<xsl:param name="prefix" />
		<xsl:param name="index" select="1" />

		<xsl:variable name="lowerLetter" select="substring($str.smallCase, $index, 1)" />
		<xsl:variable name="upperLetter" select="substring($str.upperCase, $index, 1)" />

		<xsl:variable name="result">
			<xsl:call-template name="str.replaceAll">
				<xsl:with-param name="text">
					<xsl:call-template name="str.replaceAll">
						<xsl:with-param name="text" select="$identifier" />
						<xsl:with-param name="replace" select="concat($prefix, $upperLetter)" />
						<xsl:with-param name="by" select="$upperLetter" />
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="replace" select="concat($prefix, $lowerLetter)" />
				<xsl:with-param name="by" select="$upperLetter" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$index &lt; 26">
				<xsl:call-template name="code.identifierNamingStyleUpperUnprepend">
					<xsl:with-param name="identifier" select="$result" />
					<xsl:with-param name="prefix" select="$prefix" />
					<xsl:with-param name="index" select="$index + 1" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$result" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
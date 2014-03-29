<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- C language elements -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:import href="base.xsl" />
	<!-- Naming convention for variables, parameters etc. -->
	<xsl:param name="c.indentifierNamingStyle" select="'none'" />
	<!-- Naming convention for structs -->
	<xsl:param name="c.structNamingStyle" select="'none'" />

	<!-- C-style comment -->

	<xsl:template name="c.comment">
		-		<!-- Comment content -->
		<xsl:param name="content" />
		<!-- Indicates if the comment should be displayed on one line -->
		<xsl:param name="inline" select="false()" />
		<xsl:choose>
			<xsl:when test="$inline = true()">
				<xsl:text>/* </xsl:text>
				<xsl:value-of select="translate(normalize-space($content),'&#10;&#13;', '  ')" />
				<xsl:text> */</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="code.comment">
					<xsl:with-param name="beginMarker" select="'/* '" />
					<xsl:with-param name="endMarker" select="'*/'" />
					<xsl:with-param name="marker" select="'* '" />
					<xsl:with-param name="content" select="$content" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- A shortcut for inline comments output -->
	<xsl:template name="c.inlineComment">
		<!-- Comment content -->
		<xsl:param name="content" />
		<xsl:call-template name="c.comment">
			<xsl:with-param name="content" select="$content" />
			<xsl:with-param name="inline" select="true()" />
		</xsl:call-template>
	</xsl:template>

	<!-- C code block -->
	<xsl:template name="c.block">
		<!-- Indicates if the block should be indented -->
		<xsl:param name="indent" select="true()" />
		<!-- Block content -->
		<xsl:param name="content" />
		<!-- Add a linebreak before the block -->
		<xsl:param name="addInitialEndl" select="true()" />
		<!-- Add a linebreak after the block -->
		<xsl:param name="addFinalEndl" select="false()" />
		<xsl:if test="$addInitialEndl = true()">
			<xsl:value-of select="$str.endl" />
		</xsl:if>
		<xsl:text>{</xsl:text>
		<xsl:choose>
			<xsl:when test="string-length($content) &gt; 0">
				<xsl:choose>
					<xsl:when test="$indent">
						<xsl:call-template name="code.block">
							<xsl:with-param name="content" select="$content" />
							<xsl:with-param name="indent" select="true()" />
							<xsl:with-param name="addInitialEndl" select="true()" />
							<xsl:with-param name="addFinalEndl" select="true()" />
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$str.endl" />
						<xsl:value-of select="$content" />
						<xsl:value-of select="$str.endl" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- otherwise, no content -->
		</xsl:choose>
		<xsl:text>}</xsl:text>
		<xsl:if test="$addFinalEndl">
			<xsl:value-of select="$str.endl" />
		</xsl:if>
	</xsl:template>

	<!-- A basic proprocessor #if with optional #else -->
	<xsl:template name="c.preprocessor.if">
		<!-- Condition -->
		<xsl:param name="condition" />
		<!-- Content if condition evaluates to true (required) -->
		<xsl:param name="then" />
		<!-- Content if condition evaluates to false (optional) -->
		<xsl:param name="else" />
		<!-- Indicate if the inner code have to be indented -->
		<xsl:param name="indent" select="false()" />
		<xsl:text>#if (</xsl:text>
		<xsl:value-of select="$condition" />
		<xsl:text>)</xsl:text>
		<xsl:choose>
			<xsl:when test="$indent">
				<xsl:call-template name="code.block">
					<xsl:with-param name="content" select="$then" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$str.endl" />
				<xsl:value-of select="$then" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="$else and string-length($else) &gt; 0">
			<xsl:text>#else</xsl:text>
			<xsl:choose>
				<xsl:when test="$indent">
					<xsl:call-template name="code.block">
						<xsl:with-param name="content" select="$else" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$str.endl" />
					<xsl:value-of select="$else" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:text>#endif</xsl:text>
	</xsl:template>

	<xsl:template name="c.preprocessor.ifdef">
		<!-- Condition -->
		<xsl:param name="condition" />
		<!-- Content if condition evaluates to true (required) -->
		<xsl:param name="then" />
		<!-- Content if condition evaluates to false (optional) -->
		<xsl:param name="else" />
		<xsl:param name="indent" select="false()" />
		<xsl:call-template name="c.preprocessor.if">
			<xsl:with-param name="condition" select="concat(concat('defined(', $condition),')')" />
			<xsl:with-param name="then" select="$then" />
			<xsl:with-param name="else" select="$else" />
			<xsl:with-param name="indent" select="$indent" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="c.preprocessor.ifndef">
		<!-- Condition -->
		<xsl:param name="condition" />
		<!-- Content if condition evaluates to true (required) -->
		<xsl:param name="then" />
		<!-- Content if condition evaluates to false (optional) -->
		<xsl:param name="else" />
		<xsl:param name="indent" select="false()" />
		<xsl:call-template name="c.preprocessor.if">
			<xsl:with-param name="condition" select="concat(concat('!defined(', $condition),')')" />
			<xsl:with-param name="then" select="$then" />
			<xsl:with-param name="else" select="$else" />
			<xsl:with-param name="indent" select="$indent" />
		</xsl:call-template>
	</xsl:template>

	<!-- Attempt to transform a name to fit C identifier name restriction (no
		spaces, etc) -->
	<xsl:template name="c.validIdentifierName">
		<xsl:param name="name" />

		<xsl:variable name="tname2">
			<xsl:call-template name="cede.validIdentifierName">
				<xsl:with-param name="name" select="$name" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<!-- @todo other C keywords -->
			<xsl:when test="($tname2 = 'extern') or ($tname2 = 'static') or ($tname2 = 'switch')">
				<xsl:text>_</xsl:text>
				<xsl:value-of select="$tname2" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$tname2" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Output a variable or parameter definition -->
	<xsl:template name="c.identifierDefinition">
		<!-- Variable type, including modifiers -->
		<xsl:param name="type" />
		<!-- Number of indirections (0 <=> standard variable, 1 <=> pointer, ...) -->
		<xsl:param name="pointer" select="0" />
		<!-- Variable name -->
		<xsl:param name="name" />
		<!-- Name suffix. Untransformed text to append after the name. Should be
			used for array specification -->
		<xsl:param name="nameSuffix" />
		<!-- Variable value -->
		<xsl:param name="value" />
		<!-- Naming style convention -->
		<xsl:param name="nameStyle" select="$c.indentifierNamingStyle" />
		<xsl:value-of select="normalize-space($type)" />
		<xsl:text> </xsl:text>
		<xsl:call-template name="str.repeat">
			<xsl:with-param name="text" select="'*'" />
			<xsl:with-param name="iterations" select="$pointer" />
		</xsl:call-template>
		<xsl:call-template name="code.identifierNamingStyle">
			<xsl:with-param name="identifier" select="normalize-space($name)" />
			<xsl:with-param name="from" select="'auto'" />
			<xsl:with-param name="to" select="normalize-space($nameStyle)" />
		</xsl:call-template>
		<xsl:value-of select="normalize-space($nameSuffix)" />
		<xsl:if test="string-length($value) &gt; 0">
			<xsl:text> = </xsl:text>
			<xsl:value-of select="$value" />
		</xsl:if>
	</xsl:template>

	<!-- Output a variable declaration -->
	<xsl:template name="c.variableDeclaration">
		<!-- Variable type, including modifiers -->
		<xsl:param name="type" />
		<!-- Number of indirections (0 <=> standard variable, 1 <=> pointer, ...) -->
		<xsl:param name="pointer" select="0" />
		<!-- Variable name -->
		<xsl:param name="name" />
		<!-- Name suffix. Untransformed text to append after the name. Should be
			used for array specification -->
		<xsl:param name="nameSuffix" />
		<!-- Variable value -->
		<xsl:param name="value" />
		<!-- Naming style convention -->
		<xsl:param name="nameStyle" select="$c.indentifierNamingStyle" />
		<xsl:call-template name="c.identifierDefinition">
			<xsl:with-param name="type" select="$type" />
			<xsl:with-param name="name" select="$name" />
			<xsl:with-param name="value" select="$value" />
			<xsl:with-param name="nameStyle" select="$nameStyle" />
			<xsl:with-param name="pointer" select="$pointer" />
			<xsl:with-param name="nameSuffix" select="$nameSuffix" />
		</xsl:call-template>
		<xsl:text>;</xsl:text>
	</xsl:template>

	<!-- Output a function parameter definition (alias of c.identifierDefinition) -->
	<xsl:template name="c.parameterDefinition">
		<!-- Variable type, including modifiers -->
		<xsl:param name="type" />
		<!-- Number of indirections (0 <=> standard variable, 1 <=> pointer, ...) -->
		<xsl:param name="pointer" select="0" />
		<!-- Variable name -->
		<xsl:param name="name" />
		<!-- Variable Name suffix. Untransformed text to append after the name.
			Should be used for array specification -->
		<xsl:param name="nameSuffix" />
		<!-- Variable value -->
		<xsl:param name="value" />
		<!-- Naming style convention -->
		<xsl:param name="nameStyle" select="'none'" />
		<xsl:call-template name="c.identifierDefinition">
			<xsl:with-param name="type" select="$type" />
			<xsl:with-param name="pointer" select="$pointer" />
			<xsl:with-param name="name" select="$name" />
			<xsl:with-param name="nameSuffix" select="$nameSuffix" />
			<xsl:with-param name="value" select="$value" />
			<xsl:with-param name="nameStyle" select="$nameStyle" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="c.escapeLiteral">
		<xsl:param name="value" />

		<xsl:call-template name="str.replaceAll">
			<xsl:with-param name="replace" select="'&quot;'" />
			<xsl:with-param name="by" select="concat('\', '&quot;')" />
			<xsl:with-param name="text" select="$value" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="c.structDefinition">
		<!-- struct type name -->
		<xsl:param name="name" />
		<!-- struct type name style -->
		<xsl:param name="nameStyle" select="$c.structNamingStyle" />
		<!-- Optional variable nmae -->
		<xsl:param name="variableName" />
		<!-- Variable name style -->
		<xsl:param name="variableNameStyle" select="$c.indentifierNamingStyle" />
		<!-- Struct content -->
		<xsl:param name="content" />
		<xsl:text>struct </xsl:text>
		<xsl:call-template name="code.identifierNamingStyle">
			<xsl:with-param name="identifier" select="normalize-space($name)" />
			<xsl:with-param name="from" select="'auto'" />
			<xsl:with-param name="to" select="normalize-space($nameStyle)" />
		</xsl:call-template>
		<xsl:call-template name="c.block">
			<xsl:with-param name="content" select="$content" />
		</xsl:call-template>
		<xsl:if test="$variableName">
			<xsl:text> </xsl:text>
			<xsl:call-template name="code.identifierNamingStyle">
				<xsl:with-param name="identifier" select="normalize-space($variableName)" />
				<xsl:with-param name="from" select="'auto'" />
				<xsl:with-param name="to" select="normalize-space($variableNameStyle)" />
			</xsl:call-template>
		</xsl:if>
		<xsl:text>;</xsl:text>
	</xsl:template>

	<!-- Declare a variable of type struct -->
	<xsl:template name="c.structVariableDeclaration">
		<!-- Number of indirections (0 <=> standard variable, 1 <=> pointer, ...) -->
		<xsl:param name="pointer" select="0" />
		<!-- struct type name -->
		<xsl:param name="name" />
		<!-- struct type name style -->
		<xsl:param name="nameStyle" select="$c.structNamingStyle" />
		<!-- Optional variable nmae -->
		<xsl:param name="variableName" />
		<!-- Variable name suffix. Untransformed text to append after the name.
			Should be used for array specification -->
		<xsl:param name="variableNameSuffix" />
		<!-- Variable name style -->
		<xsl:param name="variableNameStyle" select="$c.indentifierNamingStyle" />
		<!-- Variable initial value -->
		<xsl:param name="value" />
		<xsl:text>struct </xsl:text>
		<xsl:call-template name="code.identifierNamingStyle">
			<xsl:with-param name="identifier" select="normalize-space($name)" />
			<xsl:with-param name="from" select="'auto'" />
			<xsl:with-param name="to" select="normalize-space($nameStyle)" />
		</xsl:call-template>
		<xsl:text> </xsl:text>
		<xsl:call-template name="str.repeat">
			<xsl:with-param name="text" select="'*'" />
			<xsl:with-param name="iterations" select="$pointer" />
		</xsl:call-template>
		<xsl:call-template name="code.identifierNamingStyle">
			<xsl:with-param name="identifier" select="normalize-space($variableName)" />
			<xsl:with-param name="from" select="'auto'" />
			<xsl:with-param name="to" select="normalize-space($variableNameStyle)" />
		</xsl:call-template>
		<xsl:value-of select="normalize-space($variableNameSuffix)" />
		<xsl:if test="$value">
			<xsl:text> = </xsl:text>
			<xsl:value-of select="$value" />
		</xsl:if>
		<xsl:text>;</xsl:text>
	</xsl:template>

	<xsl:template name="c.functionSignature">
		<xsl:param name="returnType" select="'void'" />
		<xsl:param name="name" />
		<!-- Function parameters -->
		<xsl:param name="parameters" />
		<xsl:value-of select="normalize-space($returnType)" />
		<xsl:text> </xsl:text>
		<xsl:value-of select="normalize-space($name)" />
		<xsl:text>(</xsl:text>
		<xsl:choose>
			<xsl:when test="$parameters">
				<xsl:value-of select="normalize-space($parameters)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>void</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template name="c.functionDeclaration">
		<xsl:param name="signature" />
		<xsl:param name="returnType" select="'void'" />
		<xsl:param name="name" />
		<xsl:param name="parameters" />
		<xsl:choose>
			<xsl:when test="$signature">
				<xsl:value-of select="normalize-space($signature)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="c.functionSignature">
					<xsl:with-param name="returnType" select="$returnType" />
					<xsl:with-param name="name" select="$name" />
					<xsl:with-param name="parameters" select="$parameters" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>;</xsl:text>
	</xsl:template>

	<xsl:template name="c.functionDefinition">
		<xsl:param name="signature" />
		<xsl:param name="returnType" select="'void'" />
		<xsl:param name="name" />
		<xsl:param name="parameters" />
		<xsl:param name="content" />
		<xsl:choose>
			<xsl:when test="$signature">
				<xsl:value-of select="normalize-space($signature)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="c.functionSignature">
					<xsl:with-param name="returnType" select="$returnType" />
					<xsl:with-param name="name" select="$name" />
					<xsl:with-param name="parameters" select="$parameters" />
				</xsl:call-template>
			</xsl:otherwise>
			<xsl:text>;</xsl:text>
		</xsl:choose>
		<xsl:call-template name="c.block">
			<xsl:with-param name="content" select="$content" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="c.if">
		<xsl:param name="condition" />
		<xsl:param name="then" />
		<xsl:param name="else" />
		<xsl:text>if (</xsl:text>
		<xsl:value-of select="$condition" />
		<xsl:text>)</xsl:text>
		<xsl:call-template name="c.block">
			<xsl:with-param name="content" select="$then" />
		</xsl:call-template>
		<xsl:if test="$else">
			<xsl:text>else</xsl:text>
			<xsl:call-template name="c.block">
				<xsl:with-param name="content" select="$else" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="c.while">
		<xsl:param name="condition" />
		<xsl:param name="do" />
		<xsl:text>while (</xsl:text>
		<xsl:value-of select="$condition" />
		<xsl:text>)</xsl:text>
		<xsl:call-template name="c.block">
			<xsl:with-param name="content" select="$do" />
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- C language elements -->
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<import href="base.xsl"/>
	<!-- Naming convention for variables, parameters etc. -->
	<param name="c.indentifierNamingStyle" select="'none'"/>
	<!-- Naming convention for structs -->
	<param name="c.structNamingStyle" select="'none'"/>
	<!-- C-style comment -->
	<template name="c.comment">
		<!-- Comment content -->
		<param name="content"/>
		<!-- Indicates if the comment should be displayed on one line -->
		<param name="inline" select="false()"/>
		<choose>
			<when test="$inline = true()">
				<text>/* </text>
				<value-of select="translate(normalize-space($content),'&#10;&#13;', '  ')"/>
				<text> */</text>
			</when>
			<otherwise>
				<call-template name="code.comment">
					<with-param name="beginMarker" select="'/* '"/>
					<with-param name="endMarker" select="'*/'"/>
					<with-param name="marker" select="'* '"/>
					<with-param name="content" select="$content"/>
				</call-template>
			</otherwise>
		</choose>
	</template>

	<!-- A shortcut for inline comments output -->
	<template name="c.inlineComment">
		<!-- Comment content -->
		<param name="content"/>
		<call-template name="c.comment">
			<with-param name="content" select="$content"/>
			<with-param name="inline" select="true()"/>
		</call-template>
	</template>

	<!-- C code block -->
	<template name="c.block">
		<!-- Indicates if the block should be indented -->
		<param name="indent" select="true()"/>
		<!-- Block content -->
		<param name="content"/>
		<!-- Add a linebreak before the block -->
		<param name="addInitialEndl" select="true()"/>
		<!-- Add a linebreak after the block -->
		<param name="addFinalEndl" select="false()"/>
		<if test="$addInitialEndl = true()">
			<call-template name="endl"/>
		</if>
		<text>{</text>
		<choose>
			<when test="string-length($content) &gt; 0">
				<choose>
					<when test="$indent">
						<call-template name="code.block">
							<with-param name="content" select="$content"/>
							<with-param name="indent" select="true()"/>
							<with-param name="addInitialEndl" select="true()"/>
							<with-param name="addFinalEndl" select="true()"/>
						</call-template>
					</when>
					<otherwise>
						<call-template name="endl"/>
						<value-of select="$content"/>
						<call-template name="endl"/>
					</otherwise>
				</choose>
			</when>
			<!-- otherwise, no content -->
		</choose>
		<text>}</text>
		<if test="$addFinalEndl">
			<call-template name="endl"/>
		</if>
	</template>

	<!-- A basic proprocessor #if with optional #else -->
	<template name="c.preprocessor.if">
		<!-- Condition -->
		<param name="condition"/>
		<!-- Content if condition evaluates to true (required) -->
		<param name="then"/>
		<!-- Content if condition evaluates to false (optional) -->
		<param name="else"/>
		<!-- Indicate if the inner code have to be indented -->
		<param name="indent" select="false()"/>
		<text>#if (</text>
		<value-of select="$condition"/>
		<text>)</text>
		<choose>
			<when test="$indent">
				<call-template name="code.block">
					<with-param name="content" select="$then"/>
				</call-template>
			</when>
			<otherwise>
				<call-template name="endl"/>
				<value-of select="$then"/>
			</otherwise>
		</choose>
		<if test="$else and string-length($else) &gt; 0">
			<text>#else</text>
			<choose>
				<when test="$indent">
					<call-template name="code.block">
						<with-param name="content" select="$else"/>
					</call-template>
				</when>
				<otherwise>
					<call-template name="endl"/>
					<value-of select="$else"/>
				</otherwise>
			</choose>
		</if>
		<text>#endif</text>
	</template>

	<template name="c.preprocessor.ifdef">
		<!-- Condition -->
		<param name="condition"/>
		<!-- Content if condition evaluates to true (required) -->
		<param name="then"/>
		<!-- Content if condition evaluates to false (optional) -->
		<param name="else"/>
		<param name="indent" select="false()"/>
		<call-template name="c.preprocessor.if">
			<with-param name="condition" select="concat(concat('defined(', $condition),')')"/>
			<with-param name="then" select="$then"/>
			<with-param name="else" select="$else"/>
			<with-param name="indent" select="$indent"/>
		</call-template>
	</template>

	<template name="c.preprocessor.ifndef">
		<!-- Condition -->
		<param name="condition"/>
		<!-- Content if condition evaluates to true (required) -->
		<param name="then"/>
		<!-- Content if condition evaluates to false (optional) -->
		<param name="else"/>
		<param name="indent" select="false()"/>
		<call-template name="c.preprocessor.if">
			<with-param name="condition" select="concat(concat('!defined(', $condition),')')"/>
			<with-param name="then" select="$then"/>
			<with-param name="else" select="$else"/>
			<with-param name="indent" select="$indent"/>
		</call-template>
	</template>

	<!-- Attempt to transform a name to fit C identifier name restriction (no 
		spaces, et) -->
	<template name="c.validIdentifierName">
		<param name="name"/>
		<!-- replace some characters into _ -->
		<variable name="tname" select="translate(normalize-space($name),'- ','_')"/>
		<variable name="tname2">
			<value-of select="translate(substring($tname, 1, 1), '1234567890', '_')"/>
			<value-of select="substring($tname, 2)"/>
		</variable>
		<choose>
			<!-- @todo other C keywords -->
			<when test="($tname2 = 'extern') or ($tname2 = 'static') or ($tname2 = 'switch')">
				<text>_</text>
				<value-of select="$tname2"/>
			</when>
			<otherwise>
				<value-of select="$tname2"/>
			</otherwise>
		</choose>
	</template>

	<!-- Output a variable or parameter definition -->
	<template name="c.identifierDefinition">
		<!-- Variable type, including modifiers -->
		<param name="type"/>
		<!-- Number of indirections (0 <=> standard variable, 1 <=> pointer, ...) -->
		<param name="pointer" select="0"/>
		<!-- Variable name -->
		<param name="name"/>
		<!-- Name suffix. Untransformed text to append after the name. Should be 
			used for array specification -->
		<param name="nameSuffix"/>
		<!-- Variable value -->
		<param name="value"/>
		<!-- Naming style convention -->
		<param name="nameStyle" select="$c.indentifierNamingStyle"/>
		<value-of select="normalize-space($type)"/>
		<text> </text>
		<call-template name="str.repeat">
			<with-param name="text" select="'*'"/>
			<with-param name="iterations" select="$pointer"/>
		</call-template>
		<call-template name="code.identifierNamingStyle">
			<with-param name="identifier" select="normalize-space($name)"/>
			<with-param name="from" select="'auto'"/>
			<with-param name="to" select="normalize-space($nameStyle)"/>
		</call-template>
		<value-of select="normalize-space($nameSuffix)"/>
		<if test="string-length($value) &gt; 0">
			<text> = </text>
			<value-of select="$value"/>
		</if>
	</template>

	<!-- Output a variable declaration -->
	<template name="c.variableDeclaration">
		<!-- Variable type, including modifiers -->
		<param name="type"/>
		<!-- Number of indirections (0 <=> standard variable, 1 <=> pointer, ...) -->
		<param name="pointer" select="0"/>
		<!-- Variable name -->
		<param name="name"/>
		<!-- Name suffix. Untransformed text to append after the name. Should be 
			used for array specification -->
		<param name="nameSuffix"/>
		<!-- Variable value -->
		<param name="value"/>
		<!-- Naming style convention -->
		<param name="nameStyle" select="$c.indentifierNamingStyle"/>
		<call-template name="c.identifierDefinition">
			<with-param name="type" select="$type"/>
			<with-param name="name" select="$name"/>
			<with-param name="value" select="$value"/>
			<with-param name="nameStyle" select="$nameStyle"/>
			<with-param name="pointer" select="$pointer"/>
			<with-param name="nameSuffix" select="$nameSuffix"/>
		</call-template>
		<text>;</text>
	</template>

	<!-- Output a function parameter definition (alias of c.identifierDefinition) -->
	<template name="c.parameterDefinition">
		<!-- Variable type, including modifiers -->
		<param name="type"/>
		<!-- Number of indirections (0 <=> standard variable, 1 <=> pointer, ...) -->
		<param name="pointer" select="0"/>
		<!-- Variable name -->
		<param name="name"/>
		<!-- Variable Name suffix. Untransformed text to append after the name. 
			Should be used for array specification -->
		<param name="nameSuffix"/>
		<!-- Variable value -->
		<param name="value"/>
		<!-- Naming style convention -->
		<param name="nameStyle" select="'none'"/>
		<call-template name="c.identifierDefinition">
			<with-param name="type" select="$type"/>
			<with-param name="pointer" select="$pointer"/>
			<with-param name="name" select="$name"/>
			<with-param name="nameSuffix" select="$nameSuffix"/>
			<with-param name="value" select="$value"/>
			<with-param name="nameStyle" select="$nameStyle"/>
		</call-template>
	</template>

	<template name="c.structDefinition">
		<!-- struct type name -->
		<param name="name"/>
		<!-- struct type name style -->
		<param name="nameStyle" select="$c.structNamingStyle"/>
		<!-- Optional variable nmae -->
		<param name="variableName"/>
		<!-- Variable name style -->
		<param name="variableNameStyle" select="$c.indentifierNamingStyle"/>
		<!-- Struct content -->
		<param name="content"/>
		<text>struct </text>
		<call-template name="code.identifierNamingStyle">
			<with-param name="identifier" select="normalize-space($name)"/>
			<with-param name="from" select="'auto'"/>
			<with-param name="to" select="normalize-space($nameStyle)"/>
		</call-template>
		<call-template name="c.block">
			<with-param name="content" select="$content"/>
		</call-template>
		<if test="$variableName">
			<text> </text>
			<call-template name="code.identifierNamingStyle">
				<with-param name="identifier" select="normalize-space($variableName)"/>
				<with-param name="from" select="'auto'"/>
				<with-param name="to" select="normalize-space($variableNameStyle)"/>
			</call-template>
		</if>
		<text>;</text>
	</template>

	<!-- Declare a variable of type struct -->
	<template name="c.structVariableDeclaration">
		<!-- Number of indirections (0 <=> standard variable, 1 <=> pointer, ...) -->
		<param name="pointer" select="0"/>
		<!-- struct type name -->
		<param name="name"/>
		<!-- struct type name style -->
		<param name="nameStyle" select="$c.structNamingStyle"/>
		<!-- Optional variable nmae -->
		<param name="variableName"/>
		<!-- Variable name suffix. Untransformed text to append after the name. 
			Should be used for array specification -->
		<param name="variableNameSuffix"/>
		<!-- Variable name style -->
		<param name="variableNameStyle" select="$c.indentifierNamingStyle"/>
		<!-- Variable initial value -->
		<param name="value"/>
		<text>struct </text>
		<call-template name="code.identifierNamingStyle">
			<with-param name="identifier" select="normalize-space($name)"/>
			<with-param name="from" select="'auto'"/>
			<with-param name="to" select="normalize-space($nameStyle)"/>
		</call-template>
		<text> </text>
		<call-template name="str.repeat">
			<with-param name="text" select="'*'"/>
			<with-param name="iterations" select="$pointer"/>
		</call-template>
		<call-template name="code.identifierNamingStyle">
			<with-param name="identifier" select="normalize-space($variableName)"/>
			<with-param name="from" select="'auto'"/>
			<with-param name="to" select="normalize-space($variableNameStyle)"/>
		</call-template>
		<value-of select="normalize-space($variableNameSuffix)"/>
		<if test="$value">
			<text> = </text>
			<value-of select="$value"/>
		</if>
		<text>;</text>
	</template>

	<template name="c.functionSignature">
		<param name="returnType" select="'void'"/>
		<param name="name"/>
		<!-- Function parameters -->
		<param name="parameters"/>
		<value-of select="normalize-space($returnType)"/>
		<text> </text>
		<value-of select="normalize-space($name)"/>
		<text>(</text>
		<choose>
			<when test="$parameters">
				<value-of select="normalize-space($parameters)"/>
			</when>
			<otherwise>
				<text>void</text>
			</otherwise>
		</choose>
		<text>)</text>
	</template>

	<template name="c.functionDeclaration">
		<param name="signature"/>
		<param name="returnType" select="'void'"/>
		<param name="name"/>
		<param name="parameters"/>
		<choose>
			<when test="$signature">
				<value-of select="normalize-space($signature)"/>
			</when>
			<otherwise>
				<call-template name="c.functionSignature">
					<with-param name="returnType" select="$returnType"/>
					<with-param name="name" select="$name"/>
					<with-param name="parameters" select="$parameters"/>
				</call-template>
			</otherwise>
		</choose>
		<text>;</text>
	</template>

	<template name="c.functionDefinition">
		<param name="signature"/>
		<param name="returnType" select="'void'"/>
		<param name="name"/>
		<param name="parameters"/>
		<param name="content"/>
		<choose>
			<when test="$signature">
				<value-of select="normalize-space($signature)"/>
			</when>
			<otherwise>
				<call-template name="c.functionSignature">
					<with-param name="returnType" select="$returnType"/>
					<with-param name="name" select="$name"/>
					<with-param name="parameters" select="$parameters"/>
				</call-template>
			</otherwise>
			<text>;</text>
		</choose>
		<call-template name="c.block">
			<with-param name="content" select="$content"/>
		</call-template>
	</template>

	<template name="c.if">
		<param name="condition"/>
		<param name="then"/>
		<param name="else"/>
		<text>if (</text>
		<value-of select="$condition"/>
		<text>)</text>
		<call-template name="c.block">
			<with-param name="content" select="$then"/>
		</call-template>
		<if test="$else">
			<text>else</text>
			<call-template name="c.block">
				<with-param name="content" select="$else"/>
			</call-template>
		</if>
	</template>

	<template name="c.while">
		<param name="condition"/>
		<param name="do"/>
		<text>while (</text>
		<value-of select="$condition"/>
		<text>)</text>
		<call-template name="c.block">
			<with-param name="content" select="$do"/>
		</call-template>
	</template>

</stylesheet>

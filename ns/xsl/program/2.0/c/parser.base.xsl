<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the BSD License, see LICENSE -->

<!-- Base functions and transformation rules for the C parser -->
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" version="1.0">
	<import href="../base.xsl"/>
	<import href="../../../languages/c.xsl"/>
	<!-- Program-relative prefix -->
	<param name="prg.c.parser.prefix">
		<call-template name="c.validIdentifierName">
			<with-param name="name" select="normalize-space(/prg:program/prg:name)"/>
		</call-template>
	</param>
	<!-- If not empty, use #include to add nsxml header -->
	<param name="prg.c.parser.nsxmlHeaderPath" select="''"/>
	<!-- Naming style for variable and enum names -->
	<param name="prg.c.parser.variableNamingStyle" select="'none'"/>
	<!-- Naming style for structs -->
	<param name="prg.c.parser.structNamingStyle" select="'none'"/>
	<!-- Naming style for functions -->
	<param name="prg.c.parser.functionNamingStyle" select="'none'"/>
	<!-- Transform a variable name according to parser naming style -->
	<template name="prg.c.parser.variableName">
		<param name="name"/>
		<call-template name="code.identifierNamingStyle">
			<with-param name="identifier" select="$name"/>
			<with-param name="to" select="$prg.c.parser.variableNamingStyle"/>
		</call-template>
	</template>

	<!-- Transform a function name according to parser naming style -->
	<template name="prg.c.parser.functionName">
		<param name="name"/>
		<call-template name="code.identifierNamingStyle">
			<with-param name="identifier" select="$name"/>
			<with-param name="to" select="$prg.c.parser.functionNamingStyle"/>
		</call-template>
	</template>

	<!-- Transform a struct name according to parser naming style -->
	<template name="prg.c.parser.structName">
		<param name="name"/>
		<call-template name="code.identifierNamingStyle">
			<with-param name="identifier" select="$name"/>
			<with-param name="to" select="$prg.c.parser.structNamingStyle"/>
		</call-template>
	</template>

	<!-- Keyword used for the given item (node name is used) -->
	<template name="prg.c.parser.itemTypeName">
		<!-- Node -->
		<param name="itemNode"/>
		<!-- If @c true all option nodes will return 'option' -->
		<param name="base" select="false()"/>
		<choose>
			<when test="$base and ($itemNode/self::prg:switch|$itemNode/self::prg:argument|$itemNode/self::prg:multiargument|$itemNode/self::prg:group)">
				<text>option</text>
			</when>
			<when test="$itemNode/self::prg:switch">
				<text>switch</text>
			</when>
			<when test="$itemNode/self::prg:argument">
				<text>argument</text>
			</when>
			<when test="$itemNode/self::prg:multiargument">
				<text>multiargument</text>
			</when>
			<when test="$itemNode/self::prg:group">
				<text>group</text>
			</when>
			<when test="$itemNode/self::prg:program">
				<text>program</text>
			</when>
			<when test="$itemNode/self::prg:subcommand">
				<text>subcommand</text>
			</when>
			<when test="$itemNode/self::prg:value|$itemNode/self::prg:other">
				<text>positional_argument</text>
			</when>
			<otherwise>
				<value-of select="name($itemNode)"/>
			</otherwise>
		</choose>
	</template>

	<template name="prg.c.parser.itemTypeBasedName">
		<param name="itemNode" select="."/>
		<param name="name"/>
		<value-of select="substring-before($name,'(itemType)')"/>
		<call-template name="prg.c.parser.itemTypeName">
			<with-param name="itemNode" select="$itemNode"/>
		</call-template>
		<value-of select="substring-after($name,'(itemType)')"/>
	</template>

	<!-- Get the option index (relative to root item) -->
	<template name="prg.c.parser.optionIndex">
		<param name="rootNode"/>
		<param name="optionNode"/>
		<for-each select="$rootNode//prg:options/*">
			<if test="$optionNode = .">
				<value-of select="position() - 1"/>
			</if>
		</for-each>
	</template>

	<!-- Get the anonymous option index (relative to program node) -->
	<template name="prg.c.parser.anonymousOptionIndex">
		<param name="programNode"/>
		<param name="optionNode"/>
		<for-each select="$programNode//prg:options/*[not(prg:databinding/prg:variable)]">
			<if test="$optionNode = .">
				<value-of select="position() - 1"/>
			</if>
		</for-each>
	</template>

	<!-- Global item index -->
	<template name="prg.c.parser.itemIndex">
		<param name="itemNode" select="."/>
		<param name="rootNode" select="$itemNode/.."/>
		<for-each select="$rootNode//*">
			<if test="$itemNode = .">
				<value-of select="position() - 1"/>
			</if>
		</for-each>
	</template>

	<!-- Return the number of options in a program or subcommand, including 
		group options -->
	<template name="prg.c.parser.rootElementOptionCount">
		<!-- program or subcommand node -->
		<param name="rootNode" select="."/>
		<value-of select="count($rootNode//prg:options/*)"/>
	</template>

	<!-- Return the number of anonymous options in a program -->
	<template name="prg.c.parser.anonymousOptionCount">
		<param name="programNode" select="."/>
		<value-of select="count($programNode//prg:options/*[not(prg:databinding/prg:variable)])"/>
	</template>

	<template match="prg:databinding/prg:variable">
		<call-template name="c.validIdentifierName">
			<with-param name="name" select="translate(normalize-space(.),'-','_')"/>
		</call-template>
	</template>

	<template match="prg:details/text() | prg:block/text()">
		<call-template name="str.replaceAll">
			<with-param name="text">
				<call-template name="str.replaceAll">
					<with-param name="text" select="normalize-space(.)"/>
					<with-param name="replace" select="'\'"/>
					<with-param name="by" select="'\\'"/>
				</call-template>
			</with-param>
			<with-param name="replace" select="'&quot;'"/>
			<with-param name="by" select="'\&quot;'"/>
		</call-template>
	</template>

	<template match="prg:br|prg:endl">
		<text>\n</text>
	</template>

	<template match="prg:block">
		<call-template name="str.prependLine">
			<with-param name="text">
				<apply-templates/>
			</with-param>
			<with-param name="prependedText" select="'\t'"/>
		</call-template>
	</template>

</stylesheet>

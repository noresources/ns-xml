<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Base functions and transformation rules for the C parser -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	<xsl:import href="../base.xsl" />
	<xsl:import href="../../../languages/c.xsl" />
	<!-- Program-relative prefix -->
	<xsl:param name="prg.c.parser.prefix">
		<xsl:call-template name="c.validIdentifierName">
			<xsl:with-param name="name" select="normalize-space(/prg:program/prg:name)" />
		</xsl:call-template>
	</xsl:param>
	<!-- If not empty, use #include to add nsxml header -->
	<xsl:param name="prg.c.parser.nsxmlHeaderPath" select="''" />
	<!-- Naming style for variable and enum names -->
	<xsl:param name="prg.c.parser.variableNamingStyle" select="'none'" />
	<!-- Naming style for structs -->
	<xsl:param name="prg.c.parser.structNamingStyle" select="'none'" />
	<!-- Naming style for functions -->
	<xsl:param name="prg.c.parser.functionNamingStyle" select="'none'" />
	<!-- Transform a variable name according to parser naming style -->
	<xsl:template name="prg.c.parser.variableName">
		<xsl:param name="name" />
		<xsl:call-template name="code.identifierNamingStyle">
			<xsl:with-param name="identifier" select="$name" />
			<xsl:with-param name="to" select="$prg.c.parser.variableNamingStyle" />
		</xsl:call-template>
	</xsl:template>

	<!-- Transform a function name according to parser naming style -->
	<xsl:template name="prg.c.parser.functionName">
		<xsl:param name="name" />
		<xsl:call-template name="code.identifierNamingStyle">
			<xsl:with-param name="identifier" select="$name" />
			<xsl:with-param name="to" select="$prg.c.parser.functionNamingStyle" />
		</xsl:call-template>
	</xsl:template>

	<!-- Transform a struct name according to parser naming style -->
	<xsl:template name="prg.c.parser.structName">
		<xsl:param name="name" />
		<xsl:call-template name="code.identifierNamingStyle">
			<xsl:with-param name="identifier" select="$name" />
			<xsl:with-param name="to" select="$prg.c.parser.structNamingStyle" />
		</xsl:call-template>
	</xsl:template>

	<!-- Keyword used for the given item (node name is used) -->
	<xsl:template name="prg.c.parser.itemTypeName">
		<!-- Node -->
		<xsl:param name="itemNode" />
		<!-- If @c true all option nodes will return 'option' -->
		<xsl:param name="base" select="false()" />
		<xsl:choose>
			<xsl:when test="$base and ($itemNode/self::prg:switch|$itemNode/self::prg:argument|$itemNode/self::prg:multiargument|$itemNode/self::prg:group)">
				<xsl:text>option</xsl:text>
			</xsl:when>
			<xsl:when test="$itemNode/self::prg:switch">
				<xsl:text>switch</xsl:text>
			</xsl:when>
			<xsl:when test="$itemNode/self::prg:argument">
				<xsl:text>argument</xsl:text>
			</xsl:when>
			<xsl:when test="$itemNode/self::prg:multiargument">
				<xsl:text>multiargument</xsl:text>
			</xsl:when>
			<xsl:when test="$itemNode/self::prg:group">
				<xsl:text>group</xsl:text>
			</xsl:when>
			<xsl:when test="$itemNode/self::prg:program">
				<xsl:text>program</xsl:text>
			</xsl:when>
			<xsl:when test="$itemNode/self::prg:subcommand">
				<xsl:text>subcommand</xsl:text>
			</xsl:when>
			<xsl:when test="$itemNode/self::prg:value|$itemNode/self::prg:other">
				<xsl:text>positional_argument</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="name($itemNode)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="prg.c.parser.itemTypeBasedName">
		<xsl:param name="itemNode" select="." />
		<xsl:param name="name" />
		<xsl:value-of select="substring-before($name,'(itemType)')" />
		<xsl:call-template name="prg.c.parser.itemTypeName">
			<xsl:with-param name="itemNode" select="$itemNode" />
		</xsl:call-template>
		<xsl:value-of select="substring-after($name,'(itemType)')" />
	</xsl:template>

	<!-- Get the option index (relative to root item) -->
	<xsl:template name="prg.c.parser.optionIndex">
		<xsl:param name="rootNode" />
		<xsl:param name="optionNode" />
		<xsl:for-each select="$rootNode//prg:options/*">
			<xsl:if test="$optionNode = .">
				<xsl:value-of select="position() - 1" />
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- Get the anonymous option index (relative to program node) -->
	<xsl:template name="prg.c.parser.anonymousOptionIndex">
		<xsl:param name="programNode" />
		<xsl:param name="optionNode" />
		<xsl:for-each select="$programNode//prg:options/*[not(prg:databinding/prg:variable)]">
			<xsl:if test="$optionNode = .">
				<xsl:value-of select="position() - 1" />
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- Global item index -->
	<xsl:template name="prg.c.parser.itemIndex">
		<xsl:param name="itemNode" select="." />
		<xsl:param name="rootNode" select="$itemNode/.." />
		<xsl:for-each select="$rootNode//*">
			<xsl:if test="$itemNode = .">
				<xsl:value-of select="position() - 1" />
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- Return the number of options in a program or subcommand, including
		group options -->
	<xsl:template name="prg.c.parser.rootElementOptionCount">
		<!-- program or subcommand node -->
		<xsl:param name="rootNode" select="." />
		<xsl:value-of select="count($rootNode//prg:options/*)" />
	</xsl:template>

	<!-- Return the number of anonymous options in a program -->
	<xsl:template name="prg.c.parser.anonymousOptionCount">
		<xsl:param name="programNode" select="." />
		<xsl:value-of select="count($programNode//prg:options/*[not(prg:databinding/prg:variable)])" />
	</xsl:template>

	<xsl:template match="prg:databinding/prg:variable">
		<xsl:call-template name="c.validIdentifierName">
			<xsl:with-param name="name" select="translate(normalize-space(.),'-','_')" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="prg:default|prg:select/prg:option">
		<xsl:call-template name="c.escapeLiteral">
			<xsl:with-param name="value" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="prg:abstract/text() | prg:details/text() | prg:block/text()">
		<xsl:call-template name="str.replaceAll">
			<xsl:with-param name="text">
				<xsl:call-template name="str.replaceAll">
					<xsl:with-param name="text" select="normalize-space(.)" />
					<xsl:with-param name="replace" select="'\'" />
					<xsl:with-param name="by" select="'\\'" />
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="replace" select="'&quot;'" />
			<xsl:with-param name="by" select="'\&quot;'" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="prg:br|prg:endl">
		<xsl:text>\n</xsl:text>
	</xsl:template>

	<xsl:template match="prg:block">
		<xsl:variable name="precedingNode" select="./preceding-sibling::*[1]" />
		<xsl:if test="not($precedingNode[self::prg:endl] | $precedingNode[self::prg:br] | $precedingNode[self::prg:block])">
			<xsl:text>\n</xsl:text>
		</xsl:if>
		<xsl:call-template name="str.prependLine">
			<xsl:with-param name="text">
				<xsl:apply-templates />
			</xsl:with-param>
			<xsl:with-param name="endlChar" select="'\n'" />
			<xsl:with-param name="prependedText" select="'\t'" />
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>

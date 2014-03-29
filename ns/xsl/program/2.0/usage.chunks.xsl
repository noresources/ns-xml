<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Program usage text chunks -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	<xsl:import href="../../languages/shellscript.xsl" />
	<xsl:import href="base.xsl" />
	<xsl:import href="usage.strings.xsl" />

	<!-- String representing an indentation level -->
	<xsl:param name="prg.usage.indentChar" select="'&#9;'" />
	<!-- Indicates if documentation text have to be wrapped -->
	<xsl:param name="prg.usage.wrap" select="true()" />
	<!-- Maximum text line length (for text wrapping) -->
	<xsl:param name="prg.usage.lineMaxLength" select="80" />

	<!-- Literal representation of an option argument/value type -->
	<xsl:template name="prg.usage.typeDisplay">
		<!-- type Node -->
		<xsl:param name="typeNode" />
		<xsl:choose>
			<xsl:when test="$typeNode/prg:string">
				<xsl:text>string</xsl:text>
			</xsl:when>
			<xsl:when test="$typeNode/prg:number">
				<xsl:text>number</xsl:text>
			</xsl:when>
			<xsl:when test="$typeNode/prg:integer">
				<xsl:text>integer</xsl:text>
			</xsl:when>
			<xsl:when test="$typeNode/prg:path">
				<xsl:text>path</xsl:text>
			</xsl:when>
			<xsl:when test="$typeNode/prg:existingcommand">
				<xsl:text>existing command</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>...</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Display the option description -->
	<xsl:template name="prg.usage.descriptionDisplay">
		<xsl:param name="textNode" select="." />
		<xsl:for-each select="$textNode/node()">
			<xsl:choose>
				<xsl:when test="self::node()[1][self::text()]">
					<xsl:value-of select="normalize-space(self::node()[1])" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="." />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<!-- List of enumerated values -->
	<xsl:template name="prg.usage.selectValueList">
		<!-- Option node -->
		<xsl:param name="optionNode" select="." />
		<!-- Display mode: 'inline' or anything else -->
		<xsl:param name="mode" />
		<!-- Indicates if the text have to be wrapped -->
		<xsl:param name="wrap" select="$prg.usage.wrap" />
		<xsl:variable name="level">
			<xsl:call-template name="prg.optionLevel">
				<xsl:with-param name="optionNode" select="$optionNode" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="preIndentLength" select="string-length($prg.usage.indentChar) * ($level + 3)" />
		<xsl:call-template name="str.prependLine">
			<xsl:with-param name="prependedText" select="$prg.usage.indentChar" />
			<xsl:with-param name="wrap" select="$wrap" />
			<xsl:with-param name="lineMaxLength" select="$prg.usage.lineMaxLength - $preIndentLength" />
			<xsl:with-param name="text">
				<xsl:choose>
					<xsl:when test="$mode = 'inline'">
						<xsl:value-of select="$str.endl" />
						<xsl:for-each select="$optionNode/prg:option">
							<xsl:value-of select="." />
							<xsl:choose>
								<xsl:when test="position() = (last() - 1)">
									<xsl:text> </xsl:text>
									<xsl:value-of select="$prg.usage.str.or" />
									<xsl:text> </xsl:text>
								</xsl:when>
								<xsl:when test="position() != last()">
									<xsl:text>, </xsl:text>
								</xsl:when>
							</xsl:choose>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="$optionNode/prg:option">
							<xsl:value-of select="$str.endl" />
							<xsl:text>- </xsl:text>
							<xsl:value-of select="normalize-space(.)" />
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.usage.firstOptionNameDisplay">
		<xsl:param name="optionNode" select="." />
		<xsl:choose>
			<xsl:when test="$optionNode/prg:names/prg:short">
				<xsl:call-template name="prg.cliOptionName">
					<xsl:with-param name="nameNode" select="$optionNode/prg:names/prg:short[1]" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$optionNode/prg:names/prg:long">
				<xsl:call-template name="prg.cliOptionName">
					<xsl:with-param name="nameNode" select="$optionNode/prg:names/prg:long[1]" />
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- Display all option's names like they could appear on the command line -->
	<xsl:template name="prg.usage.allOptionNameDisplay">
		<xsl:param name="optionNode" select="." />
		<xsl:for-each select="$optionNode/prg:names/prg:short">
			<xsl:call-template name="prg.cliOptionName">
				<xsl:with-param name="nameNode" select="." />
			</xsl:call-template>
			<xsl:if test="(position() != last())">
				<xsl:text>, </xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:if test="$optionNode/prg:names/prg:short and $optionNode/prg:names/prg:long">
			<xsl:text>, </xsl:text>
		</xsl:if>
		<xsl:for-each select="$optionNode/prg:names/prg:long">
			<xsl:call-template name="prg.cliOptionName">
				<xsl:with-param name="nameNode" select="." />
			</xsl:call-template>
			<xsl:if test="(position() != last())">
				<xsl:text>, </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- inline display of a switch argument (choose the first option name) -->
	<xsl:template name="prg.usage.switchInline">
		<xsl:param name="optionNode" select="." />
		<xsl:call-template name="prg.usage.firstOptionNameDisplay">
			<xsl:with-param name="optionNode" select="$optionNode" />
		</xsl:call-template>
	</xsl:template>

	<!-- Description of a switch argument (all option names + description) -->
	<xsl:template name="prg.usage.switchDescription">
		<xsl:param name="optionNode" select="." />
		<xsl:param name="details" select="true()" />
		<xsl:variable name="level">
			<xsl:call-template name="prg.optionLevel">
				<xsl:with-param name="optionNode" select="$optionNode" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="preIndentLength" select="string-length($prg.usage.indentChar) * ($level + 2)" />
		<xsl:call-template name="prg.usage.allOptionNameDisplay">
			<xsl:with-param name="optionNode" select="$optionNode" />
		</xsl:call-template>
		<xsl:text>: </xsl:text>
		<xsl:call-template name="prg.usage.descriptionDisplay">
			<xsl:with-param name="textNode" select="$optionNode/prg:documentation/prg:abstract" />
		</xsl:call-template>
		<xsl:if test="$details and $optionNode/prg:documentation/prg:details">
			<xsl:value-of select="$str.endl" />
			<xsl:call-template name="str.prependLine">
				<xsl:with-param name="prependedText" select="$prg.usage.indentChar" />
				<xsl:with-param name="text">
					<xsl:call-template name="prg.usage.descriptionDisplay">
						<xsl:with-param name="textNode" select="$optionNode/prg:documentation/prg:details" />
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="wrap" select="$prg.usage.wrap" />
				<xsl:with-param name="lineMaxLength" select="$prg.usage.lineMaxLength - $preIndentLength" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- Inline description of argument option -->
	<xsl:template name="prg.usage.argumentInline">
		<xsl:param name="optionNode" select="." />
		<xsl:call-template name="prg.usage.firstOptionNameDisplay">
			<xsl:with-param name="optionNode" select="$optionNode" />
		</xsl:call-template>
		<xsl:choose>
			<xsl:when test="$optionNode/prg:type">
				<xsl:text> &lt;</xsl:text>
				<xsl:call-template name="prg.usage.typeDisplay">
					<xsl:with-param name="typeNode" select="$optionNode/prg:type" />
				</xsl:call-template>
				<xsl:text>&gt;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> &lt;...&gt;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Inline description of argument option value type -->
	<xsl:template name="prg.usage.argumentValueDescription">
		<xsl:param name="optionNode" select="." />
		<xsl:if test="$optionNode/prg:select">
			<xsl:value-of select="$str.endl" />
			<xsl:choose>
				<xsl:when test="$optionNode/prg:select/@restrict">
					<xsl:value-of select="$prg.usage.str.argumentValueSelectRestricted" />
					<xsl:text>:</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$prg.usage.str.argumentValueSelect" />
					<xsl:text>:</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:call-template name="prg.usage.selectValueList">
				<xsl:with-param name="mode">
					<xsl:text>inline</xsl:text>
				</xsl:with-param>
				<xsl:with-param name="optionNode" select="$optionNode/prg:select" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$optionNode/prg:default">
			<xsl:value-of select="$str.endl" />
			<xsl:value-of select="$prg.usage.str.defaultValue" />
			<xsl:value-of select="$optionNode/prg:default" />
		</xsl:if>
		<xsl:if test="$optionNode/@min">
			<xsl:value-of select="$str.endl" />
			<xsl:text>Minimal argument count: </xsl:text>
			<xsl:value-of select="$optionNode/@min" />
		</xsl:if>
		<xsl:if test="$optionNode/@max">
			<xsl:value-of select="$str.endl" />
			<xsl:text>Maximal argument count: </xsl:text>
			<xsl:value-of select="$optionNode/@max" />
		</xsl:if>
	</xsl:template>

	<xsl:template name="prg.usage.argumentDescription">
		<xsl:param name="optionNode" select="." />
		<xsl:param name="details" select="true()" />
		<xsl:variable name="level">
			<xsl:call-template name="prg.optionLevel">
				<xsl:with-param name="optionNode" select="$optionNode" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="preIndentLength" select="string-length($prg.usage.indentChar) * ($level + 2)" />
		<xsl:call-template name="prg.usage.allOptionNameDisplay">
			<xsl:with-param name="optionNode" select="$optionNode" />
		</xsl:call-template>
		<xsl:text>: </xsl:text>
		<xsl:call-template name="prg.usage.descriptionDisplay">
			<xsl:with-param name="textNode" select="$optionNode/prg:documentation/prg:abstract" />
		</xsl:call-template>
		<xsl:if test="$details and $optionNode/prg:documentation/prg:details">
			<xsl:value-of select="$str.endl" />
			<xsl:call-template name="str.prependLine">
				<xsl:with-param name="prependedText" select="$prg.usage.indentChar" />
				<xsl:with-param name="text">
					<xsl:call-template name="prg.usage.descriptionDisplay">
						<xsl:with-param name="textNode" select="$optionNode/prg:documentation/prg:details" />
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="wrap" select="$prg.usage.wrap" />
				<xsl:with-param name="lineMaxLength" select="$prg.usage.lineMaxLength - $preIndentLength" />
			</xsl:call-template>
		</xsl:if>
		<xsl:variable name="argumentValueDesc">
			<xsl:call-template name="prg.usage.argumentValueDescription">
				<xsl:with-param name="optionNode" select="$optionNode" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="string-length($argumentValueDesc)">
			<xsl:call-template name="str.prependLine">
				<xsl:with-param name="prependedText" select="$prg.usage.indentChar" />
				<xsl:with-param name="text">
					<xsl:value-of select="$argumentValueDesc" />
				</xsl:with-param>
				<xsl:with-param name="wrap" select="$prg.usage.wrap" />
				<xsl:with-param name="lineMaxLength" select="$prg.usage.lineMaxLength - (string-length($prg.usage.indentChar) * 2)" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="prg.usage.multiargumentInline">
		<xsl:param name="optionNode" select="." />
		<xsl:call-template name="prg.usage.firstOptionNameDisplay">
			<xsl:with-param name="optionNode" select="$optionNode" />
		</xsl:call-template>
		<xsl:choose>
			<xsl:when test="$optionNode/prg:type">
				<xsl:text> &lt;</xsl:text>
				<xsl:call-template name="prg.usage.typeDisplay">
					<xsl:with-param name="typeNode" select="$optionNode/prg:type" />
				</xsl:call-template>
				<xsl:text> [ ... ]&gt;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> &lt;...  [ ... ]&gt;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="prg.usage.multiargumentDescription">
		<xsl:param name="optionNode" select="." />
		<xsl:param name="details" select="true()" />
		<xsl:call-template name="prg.usage.argumentDescription">
			<xsl:with-param name="optionNode" select="$optionNode" />
			<xsl:with-param name="details" select="true()" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.usage.groupInline">
		<xsl:param name="optionNode" select="." />
		<xsl:if test="$optionNode[@type = 'exclusive']">
			<xsl:text>(</xsl:text>
		</xsl:if>
		<xsl:call-template name="prg.usage.optionListInline">
			<xsl:with-param name="optionsNode" select="$optionNode/prg:options" />
			<xsl:with-param name="separator">
				<xsl:choose>
					<xsl:when test="$optionNode[@type = 'exclusive']">
						<xsl:text> | </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text> </xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:if test="$optionNode[@type = 'exclusive']">
			<xsl:text>)</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template name="prg.usage.groupDescription">
		<xsl:param name="optionNode" select="." />
		<xsl:param name="details" select="true()" />
		<xsl:variable name="level">
			<xsl:call-template name="prg.optionLevel">
				<xsl:with-param name="optionNode" select="$optionNode" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="preIndentLength" select="string-length($prg.usage.indentChar) * ($level + 2)" />
		<xsl:call-template name="prg.usage.descriptionDisplay">
			<xsl:with-param name="textNode" select="$optionNode/prg:documentation/prg:abstract" />
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />
		<xsl:call-template name="str.prependLine">
			<xsl:with-param name="prependedText" select="$prg.usage.indentChar" />
			<xsl:with-param name="text">
				<xsl:if test="$details and $optionNode/prg:documentation/prg:details">
					<xsl:call-template name="prg.usage.descriptionDisplay">
						<xsl:with-param name="textNode" select="$optionNode/prg:documentation/prg:details" />
					</xsl:call-template>
					<xsl:value-of select="$str.endl" />
					<xsl:value-of select="$str.endl" />
				</xsl:if>
				<xsl:call-template name="prg.usage.optionListDescription">
					<xsl:with-param name="optionsNode" select="$optionNode/prg:options" />
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="wrap" select="$prg.usage.wrap" />
			<xsl:with-param name="lineMaxLength" select="$prg.usage.lineMaxLength - $preIndentLength" />
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />
	</xsl:template>

	<!-- Display the option list -->
	<xsl:template name="prg.usage.optionListInline">
		<xsl:param name="optionsNode" />
		<xsl:param name="separator">
			<xsl:text>, </xsl:text>
		</xsl:param>
		<xsl:variable name="inGroup" select="$optionsNode/../self::prg:group" />
		<!-- Group all short-named switches -->
		<xsl:if test="$optionsNode/prg:switch[prg:names/prg:short and @required='true']">
			<xsl:text>-</xsl:text>
			<xsl:for-each select="$optionsNode/prg:switch[prg:names/prg:short and @required='true']">
				<xsl:apply-templates select="./prg:names/prg:short[1]" />
			</xsl:for-each>
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:if test="$optionsNode/prg:switch[prg:names/prg:short and not(@required='true')]">
			<xsl:text>[-</xsl:text>
			<xsl:for-each select="$optionsNode/prg:switch[prg:names/prg:short and not(@required='true')]">
				<xsl:apply-templates select="./prg:names/prg:short[1]" />
			</xsl:for-each>
			<xsl:text>] </xsl:text>
		</xsl:if>
		<xsl:for-each select="$optionsNode/prg:switch[not(prg:names/prg:short)] | $optionsNode/prg:argument | $optionsNode/prg:multiargument | $optionsNode/prg:group">
			<xsl:if test="not(@required = 'true') and not($inGroup)">
				<xsl:text>[</xsl:text>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="./self::prg:switch">
					<xsl:call-template name="prg.usage.switchInline">
						<xsl:with-param name="optionNode" select="." />
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="./self::prg:argument">
					<xsl:call-template name="prg.usage.argumentInline">
						<xsl:with-param name="optionNode" select="." />
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="./self::prg:multiargument">
					<xsl:call-template name="prg.usage.multiargumentInline">
						<xsl:with-param name="optionNode" select="." />
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="./self::prg:group">
					<xsl:call-template name="prg.usage.groupInline">
						<xsl:with-param name="optionNode" select="." />
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
			<xsl:if test="not(@required = 'true') and not($inGroup)">
				<xsl:text>]</xsl:text>
			</xsl:if>
			<xsl:if test="(position() != last())">
				<xsl:value-of select="$separator" />
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- Display positional argument list -->
	<xsl:template name="prg.usage.positionalArgumentsInline">
		<!-- prg:values node -->
		<xsl:param name="valuesNode" select="." />
		<!-- Element separator string -->
		<xsl:param name="separator" select="' '" />

		<xsl:for-each select="$valuesNode/*">
			<xsl:choose>
				<xsl:when test="@required = 'true'">
					<xsl:text>&lt;</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>[</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="prg:documentation/prg:abstract">
					<xsl:apply-templates select="prg:documentation/prg:abstract" />
				</xsl:when>
				<xsl:when test="prg:databinding/prg:variable">
					<xsl:apply-templates select="prg:databinding/prg:variable" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>arg</xsl:text>
					<xsl:value-of select="position()" />
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="self::prg:other">
				<xsl:text> ...</xsl:text>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="@required = 'true'">
					<xsl:text>&gt;</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>]</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="position() != last()">
				<xsl:value-of select="$separator" />
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- Display the full documentation for each option -->
	<xsl:template name="prg.usage.optionListDescription">
		<xsl:param name="optionsNode" />
		<xsl:param name="details" select="true()" />
		<xsl:for-each select="$optionsNode/*">
			<xsl:if test="position() != 1">
				<xsl:value-of select="$str.endl" />
			</xsl:if>
			<xsl:choose>
				<xsl:when test="./self::prg:switch">
					<xsl:call-template name="prg.usage.switchDescription">
						<xsl:with-param name="optionNode" select="." />
						<xsl:with-param name="details" select="$details" />
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="./self::prg:argument">
					<xsl:call-template name="prg.usage.argumentDescription">
						<xsl:with-param name="optionNode" select="." />
						<xsl:with-param name="details" select="$details" />
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="./self::prg:multiargument">
					<xsl:call-template name="prg.usage.multiargumentDescription">
						<xsl:with-param name="optionNode" select="." />
						<xsl:with-param name="details" select="$details" />
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="./self::prg:group">
					<xsl:call-template name="prg.usage.groupDescription">
						<xsl:with-param name="optionNode" select="." />
						<xsl:with-param name="details" select="$details" />
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<!-- Default behavior for documentation blocks -->
	<xsl:template match="prg:br">
		<xsl:value-of select="$str.endl" />
	</xsl:template>

	<xsl:template match="prg:endl">
		<xsl:value-of select="$str.endl" />
	</xsl:template>

	<xsl:template match="prg:block">
		<xsl:value-of select="$str.endl" />
		<xsl:call-template name="str.prependLine">
			<xsl:with-param name="prependedText" select="$prg.usage.indentChar" />
			<xsl:with-param name="text">
				<xsl:apply-templates />
			</xsl:with-param>
			<xsl:with-param name="wrap" select="$prg.usage.wrap" />
			<xsl:with-param name="lineMaxLength" select="$prg.usage.lineMaxLength" />
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>

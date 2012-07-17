<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->

<!-- Program usage text chunks -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">

	<import href="./base.xsl" />
	<import href="usage.strings.xsl" />

	<param name="prg.usage.indentChar" select="'&#9;'" />
	<param name="prg.usage.wrap" select="true()" />
	<param name="prg.usage.lineMaxLength" select="80" />

	<template name="prg.usage.typeDisplay">
		<param name="typeNode" />
		<param name="detailed" select="false()" />
		<choose>
			<when test="$typeNode/prg:string">
				<text>string</text>
			</when>
			<when test="$typeNode/prg:number">
				<text>number</text>
			</when>
			<when test="$typeNode/prg:integer">
				<text>integer</text>
			</when>
			<when test="$typeNode/prg:path">
				<text>path</text>
			</when>
			<when test="$typeNode/prg:existingcommand">
				<text>existing command</text>
			</when>
			<otherwise>
				<text>...</text>
			</otherwise>
		</choose>
	</template>

	<!-- Display the option description -->
	<template name="prg.usage.descriptionDisplay">
		<param name="textNode" select="." />

		<for-each select="$textNode/node()">
			<choose>
				<when test="self::node()[1][self::text()]">
					<value-of select="normalize-space(self::node()[1])" />
				</when>
				<otherwise>
					<apply-templates select="." />
				</otherwise>
			</choose>
		</for-each>
	</template>

	<template name="prg.usage.selectValueList">
		<param name="optionNode" select="." />
		<param name="mode" />
		<call-template name="str.prependLine">
			<with-param name="prependedText" select="$prg.usage.indentChar" />
			<with-param name="wrap" select="$prg.usage.wrap" />
			<with-param name="lineMaxLength" select="$prg.usage.lineMaxLength - 3 * string-length($prg.usage.indentChar)" />
			<with-param name="text">
				<choose>
					<when test="$mode = 'inline'">
						<call-template name="endl" />
						<for-each select="$optionNode/prg:option">
							<value-of select="normalize-space(.)" />
							<choose>
								<when test="position() = (last() - 1)">
									<text> </text>
									<value-of select="$prg.usage.str.or" />
									<text> </text>
								</when>
								<when test="position() != last()">
									<text>, </text>
								</when>
							</choose>
						</for-each>
					</when>
					<otherwise>
						<for-each select="$optionNode/prg:option">
							<call-template name="endl" />
							<text>- </text>
							<value-of select="normalize-space(.)" />
						</for-each>
					</otherwise>
				</choose>
			</with-param>
		</call-template>
	</template>

	<template name="prg.usage.firstOptionNameDisplay">
		<param name="optionNode" select="." />
		<choose>
			<when test="$optionNode/prg:names/prg:short">
				<call-template name="prg.cliOptionName">
					<with-param name="nameNode" select="$optionNode/prg:names/prg:short[1]" />
				</call-template>
			</when>
			<when test="$optionNode/prg:names/prg:long">
				<call-template name="prg.cliOptionName">
					<with-param name="nameNode" select="$optionNode/prg:names/prg:long[1]" />
				</call-template>
			</when>
		</choose>
	</template>

	<!-- Display all option's names like they could appear on the command line -->
	<template name="prg.usage.allOptionNameDisplay">
		<param name="optionNode" select="." />
		<for-each select="$optionNode/prg:names/prg:short|$optionNode/prg:names/prg:long">
			<call-template name="prg.cliOptionName">
				<with-param name="nameNode" select="." />
			</call-template>
			<if test="(position() != last())">
				<text>, </text>
			</if>
		</for-each>
	</template>

	<!-- inline display of a switch argument (choose the first option name) -->
	<template name="prg.usage.switchInline">
		<param name="optionNode" select="." />

		<call-template name="prg.usage.firstOptionNameDisplay">
			<with-param name="optionNode" select="$optionNode" />
		</call-template>
	</template>

	<!-- Description of a switch argument (all option names + description) -->
	<template name="prg.usage.switchDescription">
		<param name="optionNode" select="." />
		<param name="details" select="true()" />

		<call-template name="prg.usage.allOptionNameDisplay">
			<with-param name="optionNode" select="$optionNode" />
		</call-template>
		<text>: </text>
		<call-template name="prg.usage.descriptionDisplay">
			<with-param name="textNode" select="$optionNode/prg:documentation/prg:abstract" />
		</call-template>

		<if test="$details and $optionNode/prg:documentation/prg:details">
			<call-template name="endl" />
			<call-template name="str.prependLine">
				<with-param name="prependedText" select="$prg.usage.indentChar" />
				<with-param name="text">
					<call-template name="prg.usage.descriptionDisplay">
						<with-param name="textNode" select="$optionNode/prg:documentation/prg:details" />
					</call-template>
				</with-param>
				<with-param name="wrap" select="$prg.usage.wrap" />
				<with-param name="lineMaxLength" select="$prg.usage.lineMaxLength - string-length($prg.usage.indentChar) * 2" />
			</call-template>
		</if>
	</template>

	<template name="prg.usage.argumentInline">
		<param name="optionNode" select="." />

		<call-template name="prg.usage.firstOptionNameDisplay">
			<with-param name="optionNode" select="$optionNode" />
		</call-template>
		<choose>
			<when test="$optionNode/prg:type">
				<text> &lt;</text>
				<call-template name="prg.usage.typeDisplay">
					<with-param name="typeNode" select="$optionNode/prg:type" />
				</call-template>
				<text>&gt;</text>
			</when>
			<otherwise>
				<text> &lt;...&gt;</text>
			</otherwise>
		</choose>
	</template>

	<template name="prg.usage.argumentValueDescription">
		<param name="optionNode" select="." />

		<if test="$optionNode/prg:select">
			<call-template name="endl" />
			<choose>
				<when test="$optionNode/prg:select/@restrict">
					<text>The argument value have to be one of the following:</text>
				</when>
				<otherwise>
					<text>The argument can be:</text>
				</otherwise>
			</choose>
			<call-template name="prg.usage.selectValueList">
				<with-param name="mode">
					<text>inline</text>
				</with-param>
				<with-param name="optionNode" select="$optionNode/prg:select" />
			</call-template>
		</if>

		<if test="$optionNode/prg:default">
			<call-template name="endl" />
			<text>Default value: </text>
			<value-of select="$optionNode/prg:default" />
		</if>

		<if test="$optionNode/@min">
			<call-template name="endl" />
			<text>Minimal argument count: </text>
			<value-of select="$optionNode/@min" />
		</if>

		<if test="$optionNode/@max">
			<call-template name="endl" />
			<text>Maximal argument count: </text>
			<value-of select="$optionNode/@max" />
		</if>

	</template>

	<template name="prg.usage.argumentDescription">
		<param name="optionNode" select="." />
		<param name="details" select="true()" />

		<call-template name="prg.usage.allOptionNameDisplay">
			<with-param name="optionNode" select="$optionNode" />
		</call-template>
		<text>: </text>
		<call-template name="prg.usage.descriptionDisplay">
			<with-param name="textNode" select="$optionNode/prg:documentation/prg:abstract" />
		</call-template>

		<if test="$details and $optionNode/prg:documentation/prg:details">
			<call-template name="endl" />
			<call-template name="str.prependLine">
				<with-param name="prependedText" select="$prg.usage.indentChar" />
				<with-param name="text">
					<call-template name="prg.usage.descriptionDisplay">
						<with-param name="textNode" select="$optionNode/prg:documentation/prg:details" />
					</call-template>
				</with-param>
				<with-param name="wrap" select="$prg.usage.wrap" />
				<with-param name="lineMaxLength" select="$prg.usage.lineMaxLength - string-length($prg.usage.indentChar) * 2" />
			</call-template>
		</if>

		<variable name="argumentValueDesc">
			<call-template name="prg.usage.argumentValueDescription">
				<with-param name="optionNode" select="$optionNode" />
			</call-template>
		</variable>

		<if test="string-length($argumentValueDesc)">
			<call-template name="str.prependLine">
				<with-param name="prependedText" select="$prg.usage.indentChar" />
				<with-param name="text">
					<value-of select="$argumentValueDesc" />
				</with-param>
				<with-param name="wrap" select="$prg.usage.wrap" />
				<with-param name="lineMaxLength" select="$prg.usage.lineMaxLength - string-length($prg.usage.indentChar) * 2" />
			</call-template>
		</if>
	</template>

	<template name="prg.usage.multiargumentInline">
		<param name="optionNode" select="." />
		<call-template name="prg.usage.firstOptionNameDisplay">
			<with-param name="optionNode" select="$optionNode" />
		</call-template>
		<choose>
			<when test="$optionNode/prg:type">
				<text> &lt;</text>
				<call-template name="prg.usage.typeDisplay">
					<with-param name="typeNode" select="$optionNode/prg:type" />
				</call-template>
				<text> [ ... ]&gt;</text>
			</when>
			<otherwise>
				<text> &lt;...  [ ... ]&gt;</text>
			</otherwise>
		</choose>
	</template>

	<template name="prg.usage.multiargumentDescription">
		<param name="optionNode" select="." />
		<param name="details" select="true()" />
		<call-template name="prg.usage.argumentDescription">
			<with-param name="optionNode" select="$optionNode" />
			<with-param name="details" select="true()" />
		</call-template>
	</template>

	<template name="prg.usage.groupInline">
		<param name="optionNode" select="." />

		<if test="$optionNode[@type = 'exclusive']">
			<text>(</text>
		</if>
		<call-template name="prg.usage.optionListInline">
			<with-param name="optionsNode" select="$optionNode/prg:options" />
			<with-param name="separator">
				<choose>
					<when test="$optionNode[@type = 'exclusive']">
						<text> | </text>
					</when>
					<otherwise>
						<text> </text>
					</otherwise>
				</choose>
			</with-param>
		</call-template>
		<if test="$optionNode[@type = 'exclusive']">
			<text>)</text>
		</if>
	</template>

	<template name="prg.usage.groupDescription">
		<param name="optionNode" select="." />
		<param name="details" select="true()" />

		<call-template name="prg.usage.descriptionDisplay">
			<with-param name="textNode" select="$optionNode/prg:documentation/prg:abstract" />
		</call-template>
		<call-template name="endl" />
		<call-template name="str.prependLine">
			<with-param name="prependedText" select="$prg.usage.indentChar" />
			<with-param name="text">
				<call-template name="prg.usage.optionListDescription">
					<with-param name="optionsNode" select="$optionNode/prg:options" />
				</call-template>
			</with-param>
			<with-param name="wrap" select="$prg.usage.wrap" />
			<with-param name="lineMaxLength" select="$prg.usage.lineMaxLength - string-length($prg.usage.indentChar) * 2" />
		</call-template>
		<call-template name="endl" />

	</template>

	<!-- Display the option list -->
	<template name="prg.usage.optionListInline">
		<param name="optionsNode" />
		<param name="separator">
			<text>, </text>
		</param>
		<variable name="inGroup" select="$optionsNode/../self::prg:group" />

		<!-- Group all short-named switches -->
		<if test="$optionsNode/prg:switch[prg:names/prg:short and @required='true']">
			<text>-</text>
			<for-each select="$optionsNode/prg:switch[prg:names/prg:short and @required='true']">
				<apply-templates select="./prg:names/prg:short[1]" />
			</for-each>
			<text> </text>
		</if>
		
		<if test="$optionsNode/prg:switch[prg:names/prg:short and not(@required='true')]">
			<text>[-</text>
			<for-each select="$optionsNode/prg:switch[prg:names/prg:short and not(@required='true')]">
				<apply-templates select="./prg:names/prg:short[1]" />
			</for-each>
			<text>] </text>
		</if>

		<for-each select="$optionsNode/prg:switch[not(prg:names/prg:short)] | $optionsNode/prg:argument | $optionsNode/prg:multiargument | $optionsNode/prg:group">
			<if test="not(@required = 'true') and not($inGroup)">
				<text>[</text>
			</if>
			<choose>
				<when test="./self::prg:switch">
					<call-template name="prg.usage.switchInline">
						<with-param name="optionNode" select="." />
					</call-template>
				</when>
				<when test="./self::prg:argument">
					<call-template name="prg.usage.argumentInline">
						<with-param name="optionNode" select="." />
					</call-template>
				</when>
				<when test="./self::prg:multiargument">
					<call-template name="prg.usage.multiargumentInline">
						<with-param name="optionNode" select="." />
					</call-template>
				</when>
				<when test="./self::prg:group">
					<call-template name="prg.usage.groupInline">
						<with-param name="optionNode" select="." />
					</call-template>
				</when>
			</choose>
			<if test="not(@required = 'true') and not($inGroup)">
				<text>]</text>
			</if>
			<if test="(position() != last())">
				<value-of select="$separator" />
			</if>
		</for-each>
	</template>

	<!-- Display the full documentation for each option -->
	<template name="prg.usage.optionListDescription">
		<param name="optionsNode" />
		<param name="details" select="true()" />

		<for-each select="$optionsNode/*">
			<if test="position() != 1">
				<call-template name="endl" />
			</if>
			<choose>
				<when test="./self::prg:switch">
					<call-template name="prg.usage.switchDescription">
						<with-param name="optionNode" select="." />
						<with-param name="details" select="$details" />
					</call-template>
				</when>
				<when test="./self::prg:argument">
					<call-template name="prg.usage.argumentDescription">
						<with-param name="optionNode" select="." />
						<with-param name="details" select="$details" />
					</call-template>
				</when>
				<when test="./self::prg:multiargument">
					<call-template name="prg.usage.multiargumentDescription">
						<with-param name="optionNode" select="." />
						<with-param name="details" select="$details" />
					</call-template>
				</when>
				<when test="./self::prg:group">
					<call-template name="prg.usage.groupDescription">
						<with-param name="optionNode" select="." />
						<with-param name="details" select="$details" />
					</call-template>
				</when>
			</choose>
		</for-each>
	</template>
</stylesheet>

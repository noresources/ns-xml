<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Generate a GNU Gengetopts file -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	<!-- Limitations
		- Options without at least a long name can't be handled
		- Only the first long and short name is used
	-->

	<import href="../../documents/gengetopts-base.xsl" />
	<import href="base.xsl" />

	<!-- If 'yes', convert all switches into yes/no enums.
	If 'no', only switches inside a group will be converted -->
	<param name="prg.c.ggo.allSwitchesAsEnum" select="'yes'" />

	<output method="text" encoding="utf-8" />

	<template name="prg.c.ggo.indent">
		<param name="text" />

		<call-template name="str.prependLine">
			<with-param name="prependedText" select="'&#9;'" />
			<with-param name="text" select="$text" />
		</call-template>
	</template>

	<template name="prg.c.ggo.escapeString">
		<param name="text" />
		<call-template name="str.replaceAll">
			<with-param name="replace" select="'&#13;'" />
			<with-param name="by" select="''" />
			<with-param name="text">
				<call-template name="str.replaceAll">
					<with-param name="replace" select="'&#10;'" />
					<with-param name="by" select="'\n'" />
					<with-param name="text">
						<call-template name="str.replaceAll">
							<with-param name="replace" select="'&#34;'" />
							<with-param name="by" select="'\&#34;'" />
							<with-param name="text">
								<value-of select="$text" />
							</with-param>
						</call-template>
					</with-param>
				</call-template>
			</with-param>
		</call-template>
	</template>

	<template name="prg.c.ggo.argumentType">
		<param name="optionNode" select="." />
		<variable name="type" select="$optionNode/prg:type" />

		<choose>
			<when test="$optionNode/prg:select[@restrict='true']">
				<text> values="</text>
				<for-each select="$optionNode/prg:select/prg:option">
					<call-template name="prg.c.ggo.escapeString">
						<with-param name="text">
							<value-of select="normalize-space(.)" />
						</with-param>
					</call-template>
					<if test="position() != last()">
						<text>,</text>
					</if>
				</for-each>
				<!-- Enum doesn't work when values contains spaces -->
				<!-- <text>" enum</text> -->
				<text>"</text>
			</when>
			<otherwise>
				<choose>
					<when test="$type/prg:number">
						<variable name="number" select="$type/prg:number" />
						<choose>
							<when test="$number[@decimal &gt; 0]">
								<text> float</text>
							</when>
							<otherwise>
								<text> int</text>
							</otherwise>
						</choose>
					</when>
					<otherwise>
						<text> string</text>
						<choose>
							<when test="$type/prg:path">
								<text> typestr="path"</text>
							</when>
							<when test="$type/prg:hostname">
								<text> typestr="hostname"</text>
							</when>
							<when test="$type/prg:existingcommand">
								<text> typestr="commandname"</text>
							</when>
						</choose>
					</otherwise>
				</choose>
			</otherwise>
		</choose>
	</template>

	<template name="prg.c.ggo.optionDefinitionBase">
		<param name="optionNode" select="." />
		<param name="groupType" select="'none'" />
		<param name="groupId" />
		
		<!-- mode or group -->
		<if test="$groupType != 'none'">
			<value-of select="$groupType" />
		</if>

		<text>option "</text>
		<choose>
			<when test="$optionNode/prg:names/prg:long">
				<value-of select="normalize-space($optionNode/prg:names/prg:long[1])" />
			</when>
			<otherwise>
				<!-- use a short option name as 'long' option -->
				<!-- Note: since the XSD schema does not allow empty <names/> tags
					we know there is at least a short one -->
				<value-of select="normalize-space($optionNode/prg:names/prg:short[1])" />
			</otherwise>
		</choose>
		<text>" </text>

		<choose>
			<when test="$optionNode/prg:names/prg:short">
				<value-of select="normalize-space($optionNode/prg:names/prg:short[1])" />
			</when>
			<otherwise>
				<text>-</text>
			</otherwise>
		</choose>
		<text> </text>

		<!-- Abstract and details-->
		<text>"</text>
		<apply-templates select="$optionNode/prg:documentation/prg:abstract" />
		<if test="$optionNode/prg:documentation/prg:details">
			<if test="$optionNode/prg:documentation/prg:abstract">
				<text>\n</text>
			</if>
			<apply-templates select="$optionNode/prg:documentation/prg:details" />
		</if>
		<text>"</text>


		<call-template name="endl" />
		<call-template name="prg.c.ggo.indent">
			<with-param name="text">
				<!-- Optional/required -->
				<choose>
					<when test="$optionNode/self::prg:switch">
						<choose>
							<when test="($groupType = 'none') and ($prg.c.ggo.allSwitchesAsEnum = 'no')">
								<text> flag off</text>
							</when>
							<otherwise>
								<text> optional int argoptional values="no","yes" enum default="yes"</text>
							</otherwise>
						</choose>
					</when>
					<when test="$optionNode/@required = 'true'">
						<text> required</text>
					</when>
					<otherwise>
						<text> optional</text>
					</otherwise>
				</choose>
			</with-param>
		</call-template>

		<if test="$groupType != 'none'">
			<text> </text>
			<value-of select="$groupType" />
			<text>="</text>
			<value-of select="$groupId" />
			<text>"</text>
		</if>
	</template>

	<template name="prg.c.ggo.optionDefinition">
		<param name="optionNode" select="." />
		<param name="groupType" select="'none'" />
		<param name="groupId" />

		<choose>
			<when test="$optionNode/self::prg:group">
				<call-template name="prg.c.ggo.groupOptionDefinition">
					<with-param name="optionNode" select="$optionNode" />
				</call-template>
			</when>
			<when test="$optionNode/self::prg:switch">
				<call-template name="prg.c.ggo.switchOptionDefinition">
					<with-param name="optionNode" select="$optionNode" />
					<with-param name="groupType" select="$groupType" />
					<with-param name="groupId" select="$groupId" />
				</call-template>
			</when>
			<when test="$optionNode/self::prg:argument">
				<call-template name="prg.c.ggo.argumentOptionDefinition">
					<with-param name="optionNode" select="$optionNode" />
					<with-param name="groupType" select="$groupType" />
					<with-param name="groupId" select="$groupId" />
				</call-template>
			</when>
			<when test="$optionNode/self::prg:multiargument">
				<call-template name="prg.c.ggo.multiargumentOptionDefinition">
					<with-param name="optionNode" select="$optionNode" />
					<with-param name="groupType" select="$groupType" />
					<with-param name="groupId" select="$groupId" />
				</call-template>
			</when>
		</choose>
	</template>

	<template name="prg.c.ggo.switchOptionDefinition">
		<param name="optionNode" select="." />
		<param name="groupType" select="'none'" />
		<param name="groupId" />

		<call-template name="prg.c.ggo.optionDefinitionBase">
			<with-param name="optionNode" select="$optionNode" />
			<with-param name="groupType" select="$groupType" />
			<with-param name="groupId" select="$groupId" />
		</call-template>
		<call-template name="endl" />
	</template>

	<template name="prg.c.ggo.argumentOptionDefinition">
		<param name="optionNode" select="." />
		<param name="groupType" select="'none'" />
		<param name="groupId" />

		<call-template name="prg.c.ggo.optionDefinitionBase">
			<with-param name="optionNode" select="$optionNode" />
			<with-param name="groupType" select="$groupType" />
			<with-param name="groupId" select="$groupId" />
		</call-template>
		<call-template name="prg.c.ggo.argumentType">
			<with-param name="optionNode" select="$optionNode" />
			<with-param name="groupType" select="$groupType" />
			<with-param name="groupId" select="$groupId" />
		</call-template>
		<call-template name="endl" />
	</template>

	<template name="prg.c.ggo.multiargumentOptionDefinition">
		<param name="optionNode" select="." />
		<param name="groupType" select="'none'" />
		<param name="groupId" />

		<call-template name="prg.c.ggo.optionDefinitionBase">
			<with-param name="optionNode" select="$optionNode" />
			<with-param name="groupType" select="$groupType" />
			<with-param name="groupId" select="$groupId" />
		</call-template>
		<call-template name="prg.c.ggo.argumentType">
			<with-param name="optionNode" select="$optionNode" />
			<with-param name="groupType" select="$groupType" />
			<with-param name="groupId" select="$groupId" />
		</call-template>
		<text> multiple</text>
		<call-template name="endl" />
	</template>

	<template name="prg.c.ggo.groupOptionDefinition">
		<param name="optionNode" select="." />

		<!-- Group is a top level group -->
		<variable name="topLevelGroup" select="$optionNode/../../self::prg:program or $optionNode/../../self::prg:subcommand" />

		<!-- 
			Groups can't contain nested groups 
		 -->

		<variable name="validSubOptions" select="not($optionNode/prg:options/*/self::prg:group)" />

		<choose>
			<when test="$topLevelGroup and $validSubOptions and ($optionNode/@type = 'exclusive')">
				<variable name="groupId">
					<choose>
						<when test="$optionNode/prg:documentation/prg:abstract">
							<apply-templates select="$optionNode/prg:documentation/prg:abstract" />
						</when>
						<otherwise>
							<call-template name="prg.optionId">
								<with-param name="optionNode" select="$optionNode" />
							</call-template>
						</otherwise>
					</choose>
				</variable>

				<text>defgroup "</text>
				<value-of select="$groupId" />
				<text>"</text>
				<if test="$optionNode/prg:documentation/prg:abstract">
					<text> groupdesc="</text>
					<apply-templates select="$optionNode/prg:documentation/prg:details" />
					<text>"</text>
				</if>
				<if test="/@required = 'true'">
					<text> required</text>
				</if>
				<call-template name="endl" />
				<for-each select="$optionNode/prg:options/*">
					<call-template name="prg.c.ggo.optionDefinition">
						<with-param name="optionNode" select="." />
						<with-param name="groupType" select="'group'" />
						<with-param name="groupId" select="$groupId" />
					</call-template>
				</for-each>
			</when>
			<otherwise>
				<call-template name="ggo.comment">
					<with-param name="content">
						<text>Unsupported group</text>
						<if test="not($topLevelGroup)">
							<call-template name="endl" />
							<text>- not a top level group</text>
						</if>
						<if test="$validSubOptions">
							<call-template name="endl" />
							<text>- contains nested group(s)</text>
						</if>
						<if test="not($optionNode/@type = 'exclusive')">
							<call-template name="endl" />
							<text>- not exclusive</text>
						</if>
					</with-param>
				</call-template>

				<if test="$optionNode/prg:documentation/prg:abstract">
					<text>section "</text>
					<apply-templates select="$optionNode/prg:documentation/prg:abstract" />
					<text>"</text>
					<call-template name="unixEndl" />
				</if>
				<if test="$optionNode/prg:documentation/prg:details">
					<text>text "</text>
					<apply-templates select="$optionNode/prg:documentation/prg:details" />
					<text>"</text>
					<call-template name="unixEndl" />
				</if>

				<for-each select="$optionNode/prg:options/*">
					<call-template name="prg.c.ggo.optionDefinition">
						<with-param name="optionNode" select="." />
					</call-template>
				</for-each>
				
				<if test="$optionNode/prg:documentation/prg:abstract">
					<text>section ""</text>
					<call-template name="unixEndl" />
				</if>
			</otherwise>
		</choose>
	</template>

	<template match="prg:br|prg:endl">
		<text>\n</text>
	</template>

	<template match="prg:block/prg:block">
		<text>\n</text>
		<call-template name="str.prependLine">
			<with-param name="text">
				<apply-templates />
			</with-param>
			<with-param name="prependedText" select="'\t'" />
			<with-param name="endlChar" select="'\n'" />
		</call-template>
	</template>

	<template match="prg:block">
		<text>\n</text>
		<call-template name="str.prependLine">
			<with-param name="text">
				<apply-templates />
			</with-param>
			<with-param name="prependedText" select="'\t'" />
			<with-param name="endlChar" select="'\n'" />
		</call-template>
		<text>\n</text>
	</template>

	<template match="prg:abstract|prg:option|prg:details/text()|prg:block/text()">
		<call-template name="prg.c.ggo.escapeString">
			<with-param name="text">
				<value-of select="normalize-space(.)" />
			</with-param>
		</call-template>
	</template>

	<template match="/prg:program">
		<text>package "</text>
		<value-of select="./prg:name"></value-of>
		<text>"</text>
		<call-template name="endl" />

		<!-- <text>args "- -no-help - -no-version"</text> -->
		<!-- <call-template name="endl" /> -->

		<if test="./prg:version">
			<text>version "</text>
			<value-of select="./prg:version" />
			<text>"</text>
			<call-template name="endl" />
		</if>
		<if test="./prg:documentation/prg:abstract">
			<text>description "</text>
			<apply-templates select="./prg:documentation/prg:abstract" />
			<text>"</text>
			<call-template name="endl" />
		</if>

		<!-- -->
		<call-template name="ggo.comment">
			<with-param name="content" select="'Options'" />
		</call-template>

		<for-each select="./prg:options/*">
			<call-template name="prg.c.ggo.optionDefinition">
				<with-param name="optionNode" select="." />
			</call-template>
		</for-each>

	</template>

</stylesheet>

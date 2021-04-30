<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 - 2021 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Generate a GNU Gengetopts file -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	<!-- Limitations
		- Options without at least a long name can't be handled
		- Only the first long and short name is used
	-->

	<xsl:import href="../../documents/gengetopts-base.xsl" />
	<xsl:import href="base.xsl" />

	<!-- If 'yes', convert all switches into yes/no enums.
	If 'no', only switches inside a group will be converted -->
	<xsl:param name="prg.c.ggo.allSwitchesAsEnum" select="'yes'" />

	<xsl:output method="text" encoding="utf-8" />

	<xsl:template name="prg.c.ggo.indent">
		<xsl:param name="text" />

		<xsl:call-template name="str.prependLine">
			<xsl:with-param name="prependedText" select="'&#9;'" />
			<xsl:with-param name="text" select="$text" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.c.ggo.escapeString">
		<xsl:param name="text" />
		<xsl:call-template name="str.replaceAll">
			<xsl:with-param name="replace" select="'&#13;'" />
			<xsl:with-param name="by" select="''" />
			<xsl:with-param name="text">
				<xsl:call-template name="str.replaceAll">
					<xsl:with-param name="replace" select="'&#10;'" />
					<xsl:with-param name="by" select="'\n'" />
					<xsl:with-param name="text">
						<xsl:call-template name="str.replaceAll">
							<xsl:with-param name="replace" select="'&#34;'" />
							<xsl:with-param name="by" select="'\&#34;'" />
							<xsl:with-param name="text">
								<xsl:value-of select="$text" />
							</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.c.ggo.argumentType">
		<xsl:param name="optionNode" select="." />
		<xsl:variable name="type" select="$optionNode/prg:type" />

		<xsl:choose>
			<xsl:when test="$optionNode/prg:select[@restrict='true']">
				<xsl:text> values="</xsl:text>
				<xsl:for-each select="$optionNode/prg:select/prg:option">
					<xsl:call-template name="prg.c.ggo.escapeString">
						<xsl:with-param name="text">
							<xsl:value-of select="normalize-space(.)" />
						</xsl:with-param>
					</xsl:call-template>
					<xsl:if test="position() != last()">
						<xsl:text>,</xsl:text>
					</xsl:if>
				</xsl:for-each>
				<!-- Enum doesn't work when values contains spaces -->
				<!-- <text>" enum</text> -->
				<xsl:text>"</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$type/prg:number">
						<xsl:variable name="number" select="$type/prg:number" />
						<xsl:choose>
							<xsl:when test="$number[@decimal &gt; 0]">
								<xsl:text> float</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text> int</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text> string</xsl:text>
						<xsl:choose>
							<xsl:when test="$type/prg:path">
								<xsl:text> typestr="path"</xsl:text>
							</xsl:when>
							<xsl:when test="$type/prg:hostname">
								<xsl:text> typestr="hostname"</xsl:text>
							</xsl:when>
							<xsl:when test="$type/prg:existingcommand">
								<xsl:text> typestr="commandname"</xsl:text>
							</xsl:when>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="prg.c.ggo.optionDefinitionBase">
		<xsl:param name="optionNode" select="." />
		<xsl:param name="groupType" select="'none'" />
		<xsl:param name="groupId" />
		
		<!-- mode or group -->
		<xsl:if test="$groupType != 'none'">
			<xsl:value-of select="$groupType" />
		</xsl:if>

		<xsl:text>option "</xsl:text>
		<xsl:choose>
			<xsl:when test="$optionNode/prg:names/prg:long">
				<xsl:value-of select="normalize-space($optionNode/prg:names/prg:long[1])" />
			</xsl:when>
			<xsl:otherwise>
				<!-- use a short option name as 'long' option -->
				<!-- Note: since the XSD schema does not allow empty <names/> tags
					we know there is at least a short one -->
				<xsl:value-of select="normalize-space($optionNode/prg:names/prg:short[1])" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>" </xsl:text>

		<xsl:choose>
			<xsl:when test="$optionNode/prg:names/prg:short">
				<xsl:value-of select="normalize-space($optionNode/prg:names/prg:short[1])" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>-</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text> </xsl:text>

		<!-- Abstract and details-->
		<xsl:text>"</xsl:text>
		<xsl:apply-templates select="$optionNode/prg:documentation/prg:abstract" />
		<xsl:if test="$optionNode/prg:documentation/prg:details">
			<xsl:if test="$optionNode/prg:documentation/prg:abstract">
				<xsl:text>\n</xsl:text>
			</xsl:if>
			<xsl:apply-templates select="$optionNode/prg:documentation/prg:details" />
		</xsl:if>
		<xsl:text>"</xsl:text>


		<xsl:value-of select="$str.endl" />
		<xsl:call-template name="prg.c.ggo.indent">
			<xsl:with-param name="text">
				<!-- Optional/required -->
				<xsl:choose>
					<xsl:when test="$optionNode/self::prg:switch">
						<xsl:choose>
							<xsl:when test="($groupType = 'none') and ($prg.c.ggo.allSwitchesAsEnum = 'no')">
								<xsl:text> flag off</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text> optional int argoptional values="no","yes" enum default="yes"</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$optionNode/@required = 'true'">
						<xsl:text> required</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text> optional</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>

		<xsl:if test="$groupType != 'none'">
			<xsl:text> </xsl:text>
			<xsl:value-of select="$groupType" />
			<xsl:text>="</xsl:text>
			<xsl:value-of select="$groupId" />
			<xsl:text>"</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template name="prg.c.ggo.optionDefinition">
		<xsl:param name="optionNode" select="." />
		<xsl:param name="groupType" select="'none'" />
		<xsl:param name="groupId" />

		<xsl:choose>
			<xsl:when test="$optionNode/self::prg:group">
				<xsl:call-template name="prg.c.ggo.groupOptionDefinition">
					<xsl:with-param name="optionNode" select="$optionNode" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$optionNode/self::prg:switch">
				<xsl:call-template name="prg.c.ggo.switchOptionDefinition">
					<xsl:with-param name="optionNode" select="$optionNode" />
					<xsl:with-param name="groupType" select="$groupType" />
					<xsl:with-param name="groupId" select="$groupId" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$optionNode/self::prg:argument">
				<xsl:call-template name="prg.c.ggo.argumentOptionDefinition">
					<xsl:with-param name="optionNode" select="$optionNode" />
					<xsl:with-param name="groupType" select="$groupType" />
					<xsl:with-param name="groupId" select="$groupId" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$optionNode/self::prg:multiargument">
				<xsl:call-template name="prg.c.ggo.multiargumentOptionDefinition">
					<xsl:with-param name="optionNode" select="$optionNode" />
					<xsl:with-param name="groupType" select="$groupType" />
					<xsl:with-param name="groupId" select="$groupId" />
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="prg.c.ggo.switchOptionDefinition">
		<xsl:param name="optionNode" select="." />
		<xsl:param name="groupType" select="'none'" />
		<xsl:param name="groupId" />

		<xsl:call-template name="prg.c.ggo.optionDefinitionBase">
			<xsl:with-param name="optionNode" select="$optionNode" />
			<xsl:with-param name="groupType" select="$groupType" />
			<xsl:with-param name="groupId" select="$groupId" />
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />
	</xsl:template>

	<xsl:template name="prg.c.ggo.argumentOptionDefinition">
		<xsl:param name="optionNode" select="." />
		<xsl:param name="groupType" select="'none'" />
		<xsl:param name="groupId" />

		<xsl:call-template name="prg.c.ggo.optionDefinitionBase">
			<xsl:with-param name="optionNode" select="$optionNode" />
			<xsl:with-param name="groupType" select="$groupType" />
			<xsl:with-param name="groupId" select="$groupId" />
		</xsl:call-template>
		<xsl:call-template name="prg.c.ggo.argumentType">
			<xsl:with-param name="optionNode" select="$optionNode" />
			<xsl:with-param name="groupType" select="$groupType" />
			<xsl:with-param name="groupId" select="$groupId" />
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />
	</xsl:template>

	<xsl:template name="prg.c.ggo.multiargumentOptionDefinition">
		<xsl:param name="optionNode" select="." />
		<xsl:param name="groupType" select="'none'" />
		<xsl:param name="groupId" />

		<xsl:call-template name="prg.c.ggo.optionDefinitionBase">
			<xsl:with-param name="optionNode" select="$optionNode" />
			<xsl:with-param name="groupType" select="$groupType" />
			<xsl:with-param name="groupId" select="$groupId" />
		</xsl:call-template>
		<xsl:call-template name="prg.c.ggo.argumentType">
			<xsl:with-param name="optionNode" select="$optionNode" />
			<xsl:with-param name="groupType" select="$groupType" />
			<xsl:with-param name="groupId" select="$groupId" />
		</xsl:call-template>
		<xsl:text> multiple</xsl:text>
		<xsl:value-of select="$str.endl" />
	</xsl:template>

	<xsl:template name="prg.c.ggo.groupOptionDefinition">
		<xsl:param name="optionNode" select="." />

		<!-- Group is a top level group -->
		<xsl:variable name="topLevelGroup" select="$optionNode/../../self::prg:program or $optionNode/../../self::prg:subcommand" />

		<!-- 
			Groups can't contain nested groups 
		 -->

		<xsl:variable name="validSubOptions" select="not($optionNode/prg:options/*/self::prg:group)" />

		<xsl:choose>
			<xsl:when test="$topLevelGroup and $validSubOptions and ($optionNode/@type = 'exclusive')">
				<xsl:variable name="groupId">
					<xsl:choose>
						<xsl:when test="$optionNode/prg:documentation/prg:abstract">
							<xsl:apply-templates select="$optionNode/prg:documentation/prg:abstract" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="prg.optionId">
								<xsl:with-param name="optionNode" select="$optionNode" />
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:text>defgroup "</xsl:text>
				<xsl:value-of select="$groupId" />
				<xsl:text>"</xsl:text>
				<xsl:if test="$optionNode/prg:documentation/prg:abstract">
					<xsl:text> groupdesc="</xsl:text>
					<xsl:apply-templates select="$optionNode/prg:documentation/prg:details" />
					<xsl:text>"</xsl:text>
				</xsl:if>
				<xsl:if test="/@required = 'true'">
					<xsl:text> required</xsl:text>
				</xsl:if>
				<xsl:value-of select="$str.endl" />
				<xsl:for-each select="$optionNode/prg:options/*">
					<xsl:call-template name="prg.c.ggo.optionDefinition">
						<xsl:with-param name="optionNode" select="." />
						<xsl:with-param name="groupType" select="'group'" />
						<xsl:with-param name="groupId" select="$groupId" />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="ggo.comment">
					<xsl:with-param name="content">
						<xsl:text>Unsupported group</xsl:text>
						<xsl:if test="not($topLevelGroup)">
							<xsl:value-of select="$str.endl" />
							<xsl:text>- not a top level group</xsl:text>
						</xsl:if>
						<xsl:if test="$validSubOptions">
							<xsl:value-of select="$str.endl" />
							<xsl:text>- contains nested group(s)</xsl:text>
						</xsl:if>
						<xsl:if test="not($optionNode/@type = 'exclusive')">
							<xsl:value-of select="$str.endl" />
							<xsl:text>- not exclusive</xsl:text>
						</xsl:if>
					</xsl:with-param>
				</xsl:call-template>

				<xsl:if test="$optionNode/prg:documentation/prg:abstract">
					<xsl:text>section "</xsl:text>
					<xsl:apply-templates select="$optionNode/prg:documentation/prg:abstract" />
					<xsl:text>"</xsl:text>
					<xsl:value-of select="$str.unix.endl" />
				</xsl:if>
				<xsl:if test="$optionNode/prg:documentation/prg:details">
					<xsl:text>text "</xsl:text>
					<xsl:apply-templates select="$optionNode/prg:documentation/prg:details" />
					<xsl:text>"</xsl:text>
					<xsl:value-of select="$str.unix.endl" />
				</xsl:if>

				<xsl:for-each select="$optionNode/prg:options/*">
					<xsl:call-template name="prg.c.ggo.optionDefinition">
						<xsl:with-param name="optionNode" select="." />
					</xsl:call-template>
				</xsl:for-each>
				
				<xsl:if test="$optionNode/prg:documentation/prg:abstract">
					<xsl:text>section ""</xsl:text>
					<xsl:value-of select="$str.unix.endl" />
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="prg:br|prg:endl">
		<xsl:text>\n</xsl:text>
	</xsl:template>

	<xsl:template match="prg:block/prg:block">
		<xsl:text>\n</xsl:text>
		<xsl:call-template name="str.prependLine">
			<xsl:with-param name="text">
				<xsl:apply-templates />
			</xsl:with-param>
			<xsl:with-param name="prependedText" select="'\t'" />
			<xsl:with-param name="endlChar" select="'\n'" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="prg:block">
		<xsl:text>\n</xsl:text>
		<xsl:call-template name="str.prependLine">
			<xsl:with-param name="text">
				<xsl:apply-templates />
			</xsl:with-param>
			<xsl:with-param name="prependedText" select="'\t'" />
			<xsl:with-param name="endlChar" select="'\n'" />
		</xsl:call-template>
		<xsl:text>\n</xsl:text>
	</xsl:template>

	<xsl:template match="prg:abstract|prg:option|prg:details/text()|prg:block/text()">
		<xsl:call-template name="prg.c.ggo.escapeString">
			<xsl:with-param name="text">
				<xsl:value-of select="normalize-space(.)" />
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/prg:program">
		<xsl:text>package "</xsl:text>
		<xsl:value-of select="./prg:name"></xsl:value-of>
		<xsl:text>"</xsl:text>
		<xsl:value-of select="$str.endl" />

		<!-- <text>args "- -no-help - -no-version"</text> -->
		<!-- <value-of select="$str.endl" /> -->

		<xsl:if test="./prg:version">
			<xsl:text>version "</xsl:text>
			<xsl:value-of select="./prg:version" />
			<xsl:text>"</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>
		<xsl:if test="./prg:documentation/prg:abstract">
			<xsl:text>description "</xsl:text>
			<xsl:apply-templates select="./prg:documentation/prg:abstract" />
			<xsl:text>"</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>

		<!-- -->
		<xsl:call-template name="ggo.comment">
			<xsl:with-param name="content" select="'Options'" />
		</xsl:call-template>

		<xsl:for-each select="./prg:options/*">
			<xsl:call-template name="prg.c.ggo.optionDefinition">
				<xsl:with-param name="optionNode" select="." />
			</xsl:call-template>
		</xsl:for-each>

	</xsl:template>

</xsl:stylesheet>

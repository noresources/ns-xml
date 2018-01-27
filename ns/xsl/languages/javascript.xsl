<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2018 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Javascript language elements -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:import href="base.xsl" />

	<xsl:template name="js.comment">
		<xsl:param name="content" select="." />
		<xsl:call-template name="code.comment">
			<xsl:with-param name="marker">
				<xsl:text>// </xsl:text>
			</xsl:with-param>
			<xsl:with-param name="content" select="$content" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="js.block">
		<xsl:param name="indent" select="true()" />
		<xsl:param name="content" />
		<xsl:choose>
			<xsl:when test="$content">
				<xsl:choose>
					<xsl:when test="$indent">
						<xsl:call-template name="code.block">
							<xsl:with-param name="content" select="$content" />
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$str.endl" />
						<xsl:value-of select="$content" />
						<xsl:value-of select="$str.endl" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$str.endl" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="js.callblock">
		<xsl:param name="name" />
		<xsl:param name="context" />
		<xsl:param name="content" />
		<xsl:param name="indent" select="true()" />
		<xsl:if test="$name">
			<xsl:value-of select="normalize-space($name)" />
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:text>(</xsl:text>
		<xsl:value-of select="$context" />
		<xsl:text>)</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:text>{</xsl:text>
		<xsl:call-template name="js.block">
			<xsl:with-param name="content" select="$content" />
			<xsl:with-param name="indent" select="$indent" />
		</xsl:call-template>
		<xsl:text>}</xsl:text>
		<xsl:value-of select="$str.endl" />
	</xsl:template>

	<!-- Javascript function definition -->
	<xsl:template name="js.function">
		<xsl:param name="name" />
		<xsl:param name="args" />
		<xsl:param name="content" />
		<xsl:param name="indent" select="true()" />
		<xsl:text>function </xsl:text>
		<xsl:call-template name="js.callblock">
			<xsl:with-param name="name" select="$name" />
			<xsl:with-param name="context" select="normalize-space($args)" />
			<xsl:with-param name="content" select="$content" />
			<xsl:with-param name="indent" select="$indent" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="js.if">
		<xsl:param name="condition" />
		<xsl:param name="content" />
		<xsl:param name="indent" select="true()" />
		<xsl:call-template name="js.callblock">
			<xsl:with-param name="name">
				<xsl:text>if</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="context" select="normalize-space($condition)" />
			<xsl:with-param name="content" select="$content" />
			<xsl:with-param name="indent" select="$indent" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="js.elseif">
		<xsl:param name="condition" />
		<xsl:param name="content" />
		<xsl:param name="indent" select="true()" />
		<xsl:call-template name="js.callblock">
			<xsl:with-param name="name">
				<xsl:text>else if</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="context" select="normalize-space($condition)" />
			<xsl:with-param name="content" select="$content" />
			<xsl:with-param name="indent" select="$indent" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="js.else">
		<xsl:param name="name" />
		<xsl:param name="condition" />
		<xsl:param name="content" />
		<xsl:param name="indent" select="true()" />
		<xsl:text>else</xsl:text>
		<xsl:call-template name="js.block">
			<xsl:with-param name="content" select="$content" />
			<xsl:with-param name="indent" select="$indent" />
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>
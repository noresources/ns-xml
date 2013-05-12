<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- CSS language elements -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:import href="base.xsl" />

	<xsl:template match="text()">
		<xsl:value-of select="normalize-space(.)" />
	</xsl:template>

	<xsl:template name="css.comment">
		<xsl:param name="content" select="." />
		<xsl:text>/*</xsl:text>
		<xsl:value-of select="normalize-space($content)" />
		<xsl:text>*/</xsl:text>
	</xsl:template>

	<xsl:template name="css.block">
		<xsl:param name="indent" select="true()" />
		<xsl:param name="content" />
		<xsl:text>{</xsl:text>
		<xsl:if test="$content">
			<xsl:choose>
				<xsl:when test="$indent">
					<xsl:call-template name="code.block">
						<xsl:with-param name="content" select="normalize-space($content)" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="endl" />
					<xsl:value-of select="normalize-space($content)" />
					<xsl:call-template name="endl" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:text>}</xsl:text>
	</xsl:template>

	<xsl:template name="css.rule">
		<xsl:param name="name" />
		<xsl:param name="content" />
		<xsl:value-of select="normalize-space($name)" />
		<xsl:call-template name="endl" />
		<xsl:call-template name="css.block">
			<xsl:with-param name="content" select="normalize-space($content)" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="css.property">
		<xsl:param name="name" />
		<xsl:param name="value" />
		<xsl:value-of select="normalize-space($name)" />
		<xsl:text>: </xsl:text>
		<xsl:value-of select="normalize-space($value)" />
		<xsl:text>;</xsl:text>
	</xsl:template>

</xsl:stylesheet>
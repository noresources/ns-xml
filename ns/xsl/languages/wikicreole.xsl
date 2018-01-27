<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2018 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Creole 1.0 basic syntax -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:import href="../strings.xsl" />
	<xsl:param name="creole.support.anchor" select="false()" />
	<!-- Force linebreak -->
	<xsl:param name="creole.endl">
		<xsl:text>\\</xsl:text>
	</xsl:param>
	<!-- Horizontal line -->
	<xsl:param name="creole.line">
		<xsl:value-of select="$str.endl" />
		<xsl:text>----</xsl:text>
		<xsl:value-of select="$str.endl" />
	</xsl:param>
	<!-- base for all surrounding-based syntax -->
	<xsl:template name="creole.surround">
		<xsl:param name="content" select="." />
		<xsl:param name="before" />
		<xsl:param name="after" select="$before" />
		<xsl:param name="acceptEmpty" select="false" />
		<xsl:if test="$acceptEmpty or (string-length($content) &gt; 0)">
			<xsl:value-of select="$before" />
			<xsl:value-of select="$content" />
			<xsl:value-of select="$after" />
		</xsl:if>
	</xsl:template>

	<xsl:template name="creole.prepend">
		<xsl:param name="content" select="." />
		<xsl:param name="before" />
		<xsl:param name="repeat" select="1" />
		<xsl:param name="acceptEmpty" select="false" />
		<xsl:if test="$acceptEmpty or (string-length($content) &gt; 0)">
			<xsl:value-of select="$str.endl" />
			<xsl:call-template name="str.repeat">
				<xsl:with-param name="iterations" select="$repeat" />
				<xsl:with-param name="text" select="$before" />
			</xsl:call-template>
			<xsl:text> </xsl:text>
			<xsl:value-of select="normalize-space($content)" />
		</xsl:if>
	</xsl:template>

	<!-- Bold -->
	<xsl:template name="creole.bold">
		<xsl:param name="content" select="." />
		<xsl:call-template name="creole.surround">
			<xsl:with-param name="content" select="$content" />
			<xsl:with-param name="before" select="'**'" />
		</xsl:call-template>
	</xsl:template>

	<!-- Italic -->
	<xsl:template name="creole.italic">
		<xsl:param name="content" select="." />
		<xsl:call-template name="creole.surround">
			<xsl:with-param name="content" select="$content" />
			<xsl:with-param name="before" select="'//'" />
		</xsl:call-template>
	</xsl:template>

	<!-- Preformatted (no wiki markup) -->
	<xsl:template name="creole.pre">
		<xsl:param name="content" select="." />
		<!-- If false, add line break before and after preformat markers -->
		<xsl:param name="inline" select="true()" />
		<xsl:if test="string-length($content) &gt; 0">
			<xsl:if test="not ($inline)">
				<xsl:value-of select="$str.endl" />
			</xsl:if>
			<xsl:text>{{{</xsl:text>
			<xsl:if test="not ($inline)">
				<xsl:value-of select="$str.endl" />
			</xsl:if>
			<xsl:value-of select="$content" />
			<xsl:if test="not ($inline)">
				<xsl:value-of select="$str.endl" />
			</xsl:if>
			<xsl:text>}}}</xsl:text>
		</xsl:if>
	</xsl:template>

	<!-- Unordered list item -->
	<xsl:template name="creole.unorderedList">
		<xsl:param name="content" select="." />
		<xsl:param name="level" select="1" />
		<xsl:call-template name="creole.prepend">
			<xsl:with-param name="content" select="$content" />
			<xsl:with-param name="before" select="':'" />
			<xsl:with-param name="repeat" select="$level" />
		</xsl:call-template>
	</xsl:template>

	<!-- Heading -->
	<xsl:template name="creole.heading">
		<xsl:param name="content" select="." />
		<xsl:param name="level" select="1" />
		<xsl:param name="addAnchor" select="true()" />
		<xsl:value-of select="$str.endl" />
		<xsl:call-template name="str.repeat">
			<xsl:with-param name="iterations" select="$level" />
			<xsl:with-param name="text" select="'='" />
		</xsl:call-template>
		<xsl:text> </xsl:text>
		<xsl:value-of select="$content" />
		<xsl:if test="$addAnchor">
			<xsl:call-template name="creole.anchor">
				<xsl:with-param name="name" select="normalize-space($content)" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- Anchor (not supported) -->
	<xsl:template name="creole.anchor">
		<!-- 
		<param name="name" select="." />
		<if test="string-length($name) > 0">
			<text>[[</text>
			<text>#</text>
			<value-of select="normalize-space($name)" />
			<text>]]</text>
		</if>
		 -->
	</xsl:template>

	<!-- Link -->
	<xsl:template name="creole.link">
		<xsl:param name="url" select="." />
		<xsl:param name="label" />
		<xsl:if test="string-length($url) &gt; 0">
			<xsl:text>[[</xsl:text>
			<xsl:value-of select="$url" />
			<xsl:if test="$label">
				<xsl:text>|</xsl:text>
				<xsl:value-of select="$label" />
			</xsl:if>
			<xsl:text>]]</xsl:text>
		</xsl:if>
	</xsl:template>

	<!-- Image -->
	<xsl:template name="creole.image">
		<xsl:param name="url" select="." />
		<xsl:param name="label" />
		<xsl:if test="string-length($url) &gt; 0">
			<xsl:text>{{</xsl:text>
			<xsl:value-of select="$url" />
			<xsl:if test="$label">
				<xsl:text>|</xsl:text>
				<xsl:value-of select="$label" />
			</xsl:if>
			<xsl:text>}}</xsl:text>
		</xsl:if>
	</xsl:template>

	<!-- Table header cell -->
	<xsl:template name="creole.table.header">
		<xsl:param name="content" select="." />
		<xsl:param name="last" select="false()" />
		<xsl:text>|= </xsl:text>
		<xsl:value-of select="$content" />
		<xsl:if test="$last">
			<xsl:text> |</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>
	</xsl:template>

	<!-- Table cell -->
	<xsl:template name="creole.table.cell">
		<xsl:param name="content" select="." />
		<xsl:param name="last" select="false()" />
		<xsl:text>| </xsl:text>
		<xsl:value-of select="$content" />
		<xsl:if test="$last">
			<xsl:text> |</xsl:text>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>

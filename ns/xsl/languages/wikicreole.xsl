<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->
<!-- Distributed under the terms of the BSD License, see LICENSE -->
<!-- Creole 1.0 basic syntax -->
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<import href="../strings.xsl"/>
	<param name="creole.support.anchor" select="false()"/>
	<!-- Force linebreak -->
	<param name="creole.endl">
		<text>\\</text>
	</param>
	<!-- Horizontal line -->
	<param name="creole.line">
		<call-template name="endl"/>
		<text>----</text>
		<call-template name="endl"/>
	</param>
	<!-- base for all surrounding-based syntax -->
	<template name="creole.surround">
		<param name="content" select="."/>
		<param name="before"/>
		<param name="after" select="$before"/>
		<param name="acceptEmpty" select="false"/>
		<if test="$acceptEmpty or (string-length($content) &gt; 0)">
			<value-of select="$before"/>
			<value-of select="$content"/>
			<value-of select="$after"/>
		</if>
	</template>

	<template name="creole.prepend">
		<param name="content" select="."/>
		<param name="before"/>
		<param name="repeat" select="1"/>
		<param name="acceptEmpty" select="false"/>
		<if test="$acceptEmpty or (string-length($content) &gt; 0)">
			<call-template name="endl"/>
			<call-template name="str.repeat">
				<with-param name="iterations" select="$repeat"/>
				<with-param name="text" select="$before"/>
			</call-template>
			<text> </text>
			<value-of select="normalize-space($content)"/>
		</if>
	</template>

	<!-- Bold -->
	<template name="creole.bold">
		<param name="content" select="."/>
		<call-template name="creole.surround">
			<with-param name="content" select="$content"/>
			<with-param name="before" select="'**'"/>
		</call-template>
	</template>

	<!-- Italic -->
	<template name="creole.italic">
		<param name="content" select="."/>
		<call-template name="creole.surround">
			<with-param name="content" select="$content"/>
			<with-param name="before" select="'//'"/>
		</call-template>
	</template>

	<!-- Preformatted (no wiki markup) -->
	<template name="creole.pre">
		<param name="content" select="."/>
		<!-- If false, add line break before and after preformat markers -->
		<param name="inline" select="true()"/>
		<if test="string-length($content) &gt; 0">
			<if test="not ($inline)">
				<call-template name="endl"/>
			</if>
			<text>{{{</text>
			<if test="not ($inline)">
				<call-template name="endl"/>
			</if>
			<value-of select="$content"/>
			<if test="not ($inline)">
				<call-template name="endl"/>
			</if>
			<text>}}}</text>
		</if>
	</template>

	<!-- Unordered list item -->
	<template name="creole.unorderedList">
		<param name="content" select="."/>
		<param name="level" select="1"/>
		<call-template name="creole.prepend">
			<with-param name="content" select="$content"/>
			<with-param name="before" select="':'"/>
			<with-param name="repeat" select="$level"/>
		</call-template>
	</template>

	<!-- Heading -->
	<template name="creole.heading">
		<param name="content" select="."/>
		<param name="level" select="1"/>
		<param name="addAnchor" select="true()"/>
		<call-template name="endl"/>
		<call-template name="str.repeat">
			<with-param name="iterations" select="$level"/>
			<with-param name="text" select="'='"/>
		</call-template>
		<text> </text>
		<value-of select="$content"/>
		<if test="$addAnchor">
			<call-template name="creole.anchor">
				<with-param name="name" select="normalize-space($content)"/>
			</call-template>
		</if>
	</template>

	<!-- Anchor (not supported) -->
	<template name="creole.anchor">
		<!-- 
		<param name="name" select="." />
		<if test="string-length($name) > 0">
			<text>[[</text>
			<text>#</text>
			<value-of select="normalize-space($name)" />
			<text>]]</text>
		</if>
		 -->
	</template>

	<!-- Link -->
	<template name="creole.link">
		<param name="url" select="."/>
		<param name="label"/>
		<if test="string-length($url) &gt; 0">
			<text>[[</text>
			<value-of select="$url"/>
			<if test="$label">
				<text>|</text>
				<value-of select="$label"/>
			</if>
			<text>]]</text>
		</if>
	</template>

	<!-- Image -->
	<template name="creole.image">
		<param name="url" select="."/>
		<param name="label"/>
		<if test="string-length($url) &gt; 0">
			<text>{{</text>
			<value-of select="$url"/>
			<if test="$label">
				<text>|</text>
				<value-of select="$label"/>
			</if>
			<text>}}</text>
		</if>
	</template>

	<!-- Table header cell -->
	<template name="creole.table.header">
		<param name="content" select="."/>
		<param name="last" select="false()"/>
		<text>|= </text>
		<value-of select="$content"/>
		<if test="$last">
			<text> |</text>
			<call-template name="endl"/>
		</if>
	</template>

	<!-- Table cell -->
	<template name="creole.table.cell">
		<param name="content" select="."/>
		<param name="last" select="false()"/>
		<text>| </text>
		<value-of select="$content"/>
		<if test="$last">
			<text> |</text>
		</if>
	</template>

</stylesheet>

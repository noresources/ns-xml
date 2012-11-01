<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the BSD License, see LICENSE -->

<!-- CSS language elements -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform">

	<import href="base.xsl" />

	<template match="text()">
		<value-of select="normalize-space(.)" />
	</template>

	<template name="css.comment">
		<param name="content" select="." />
		<text>/*</text>
		<value-of select="normalize-space($content)" />
		<text>*/</text>
	</template>

	<template name="css.block">
		<param name="indent" select="true()" />
		<param name="content" />
		<text>{</text>
		<if test="$content">
			<choose>
				<when test="$indent">
					<call-template name="code.block">
						<with-param name="content" select="normalize-space($content)" />
					</call-template>
				</when>
				<otherwise>
					<call-template name="endl" />
					<value-of select="normalize-space($content)" />
					<call-template name="endl" />
				</otherwise>
			</choose>
		</if>
		<text>}</text>
	</template>

	<template name="css.rule">
		<param name="name" />
		<param name="content" />
		<value-of select="normalize-space($name)" />
		<call-template name="endl" />
		<call-template name="css.block">
			<with-param name="content" select="normalize-space($content)" />
		</call-template>
	</template>

	<template name="css.property">
		<param name="name" />
		<param name="value" />
		<value-of select="normalize-space($name)" />
		<text>: </text>
		<value-of select="normalize-space($value)" />
		<text>;</text>
	</template>

</stylesheet>
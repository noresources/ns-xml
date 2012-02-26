<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (c) 2011 by Renaud Guillard (dev@niao.fr) -->

<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform">

	<import href="base.xsl" />

	<template name="js.comment">
		<param name="content" select="." />
		<call-template name="code.comment">
			<with-param name="marker">
				<text>// </text>
			</with-param>
			<with-param name="content" select="$content" />
		</call-template>
	</template>

	<template name="js.block">
		<param name="indent" select="true()" />
		<param name="content" />
		<choose>
			<when test="$content">
				<choose>
					<when test="$indent">
						<call-template name="code.block">
							<with-param name="content" select="$content" />
						</call-template>
					</when>
					<otherwise>
						<call-template name="endl" />
						<value-of select="$content" />
						<call-template name="endl" />
					</otherwise>
				</choose>
			</when>
			<otherwise>
				<call-template name="endl" />
			</otherwise>
		</choose>
	</template>

	<template name="js.callblock">
		<param name="name" />
		<param name="context" />
		<param name="content" />
		<param name="indent" select="true()" />
		<if test="$name">
			<value-of select="normalize-space($name)" />
			<text> </text>
		</if>
		<text>(</text>
		<value-of select="$context" />
		<text>)</text>
		<call-template name="endl" />
		<text>{</text>
		<call-template name="js.block">
			<with-param name="content" select="$content" />
			<with-param name="indent" select="$indent" />
		</call-template>
		<text>}</text>
		<call-template name="endl" />
	</template>

	<!-- Javascript function definition -->
	<template name="js.function">
		<param name="name" />
		<param name="args" />
		<param name="content" />
		<param name="indent" select="true()" />
		<text>function </text>
		<call-template name="js.callblock">
			<with-param name="name" select="$name" />
			<with-param name="context" select="normalize-space($args)" />
			<with-param name="content" select="$content" />
			<with-param name="indent" select="$indent" />
		</call-template>
	</template>

	<template name="js.if">
		<param name="condition" />
		<param name="content" />
		<param name="indent" select="true()" />
		<call-template name="js.callblock">
			<with-param name="name">
				<text>if</text>
			</with-param>
			<with-param name="context" select="normalize-space($condition)" />
			<with-param name="content" select="$content" />
			<with-param name="indent" select="$indent" />
		</call-template>
	</template>

	<template name="js.elseif">
		<param name="condition" />
		<param name="content" />
		<param name="indent" select="true()" />
		<call-template name="js.callblock">
			<with-param name="name">
				<text>else if</text>
			</with-param>
			<with-param name="context" select="normalize-space($condition)" />
			<with-param name="content" select="$content" />
			<with-param name="indent" select="$indent" />
		</call-template>
	</template>

	<template name="js.else">
		<param name="name" />
		<param name="condition" />
		<param name="content" />
		<param name="indent" select="true()" />
		<text>else</text>
		<call-template name="js.block">
			<with-param name="content" select="$content" />
			<with-param name="indent" select="$indent" />
		</call-template>
	</template>

</stylesheet>
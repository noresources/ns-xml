<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->

<!-- Creole 1.0 common extensions -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform">

	<import href="wikicreole.xsl" />

	
	<!-- Monospace character style -->
	<template name="creole.monospace">
		<param name="content" select="." />
		
		<call-template name="creole.surround">
			<with-param name="content" select="$content" />
			<with-param name="before" select="'##'" />
		</call-template>
	</template>
	
	<!-- Subscript character style -->
	<template name="creole.subscript">
		<param name="content" select="." />
		
		<call-template name="creole.surround">
			<with-param name="content" select="$content" />
			<with-param name="before" select="',,'" />
		</call-template>
	</template>
	
	<!-- Superscript character style -->
	<template name="creole.superscript">
		<param name="content" select="." />
		
		<call-template name="creole.surround">
			<with-param name="content" select="$content" />
			<with-param name="before" select="'^^'" />
		</call-template>
	</template>
	
	<!-- Underline character style -->
	<template name="creole.underline">
		<param name="content" select="." />
		
		<call-template name="creole.surround">
			<with-param name="content" select="$content" />
			<with-param name="before" select="'__'" />
		</call-template>
	</template>
	
	<!-- Indent -->
	<template name="creole.indent">
		<!-- Term definition -->
		<param name="content" select="." />
		<param name="level" select="1" />
		
		<call-template name="endl" />
		<call-template name="str.repeat">
			<with-param name="iterations" select="$level" />
			<with-param name="text" select="':'" />
		</call-template>
		<value-of select="$content" />
	</template>
	
	<!-- Definition title -->
	<template name="creole.definitionTitle">
		<!-- Term -->
		<param name="content" select="." />
		
		<call-template name="endl" />
		<text>;</text>
		<value-of select="$content" />
	</template>
	

	<!-- Definition item -->
	<template name="creole.definition">
		<!-- Term definition -->
		<param name="content" select="." />
		
		<call-template name="endl" />
		<text>:</text>
		<value-of select="$content" />
	</template>

	<!-- Term with a single definition -->
	<template name="creole.simpleDefinition">
		<param name="title" />
		<param name="definition" />

		<if test="string-length($title) > 0">
			<call-template name="creole.definitionTitle">
				<with-param name="content" select="$title" />
			</call-template>
			<call-template name="creole.definition">
				<with-param name="content" select="$definition" />
			</call-template>
		</if>
	</template>

</stylesheet>
<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Creole 1.0 common extensions -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:import href="wikicreole.xsl" />

	
	<!-- Monospace character style -->
	<xsl:template name="creole.monospace">
		<xsl:param name="content" select="." />
		
		<xsl:call-template name="creole.surround">
			<xsl:with-param name="content" select="$content" />
			<xsl:with-param name="before" select="'##'" />
		</xsl:call-template>
	</xsl:template>
	
	<!-- Subscript character style -->
	<xsl:template name="creole.subscript">
		<xsl:param name="content" select="." />
		
		<xsl:call-template name="creole.surround">
			<xsl:with-param name="content" select="$content" />
			<xsl:with-param name="before" select="',,'" />
		</xsl:call-template>
	</xsl:template>
	
	<!-- Superscript character style -->
	<xsl:template name="creole.superscript">
		<xsl:param name="content" select="." />
		
		<xsl:call-template name="creole.surround">
			<xsl:with-param name="content" select="$content" />
			<xsl:with-param name="before" select="'^^'" />
		</xsl:call-template>
	</xsl:template>
	
	<!-- Underline character style -->
	<xsl:template name="creole.underline">
		<xsl:param name="content" select="." />
		
		<xsl:call-template name="creole.surround">
			<xsl:with-param name="content" select="$content" />
			<xsl:with-param name="before" select="'__'" />
		</xsl:call-template>
	</xsl:template>
	
	<!-- Indent -->
	<xsl:template name="creole.indent">
		<!-- Term definition -->
		<xsl:param name="content" select="." />
		<xsl:param name="level" select="1" />
		
		<xsl:value-of select="$str.endl" />
		<xsl:call-template name="str.repeat">
			<xsl:with-param name="iterations" select="$level" />
			<xsl:with-param name="text" select="':'" />
		</xsl:call-template>
		<xsl:value-of select="$content" />
	</xsl:template>
	
	<!-- Definition title -->
	<xsl:template name="creole.definitionTitle">
		<!-- Term -->
		<xsl:param name="content" select="." />
		
		<xsl:value-of select="$str.endl" />
		<xsl:text>;</xsl:text>
		<xsl:value-of select="$content" />
	</xsl:template>
	

	<!-- Definition item -->
	<xsl:template name="creole.definition">
		<!-- Term definition -->
		<xsl:param name="content" select="." />
		
		<xsl:value-of select="$str.endl" />
		<xsl:text>:</xsl:text>
		<xsl:value-of select="$content" />
	</xsl:template>

	<!-- Term with a single definition -->
	<xsl:template name="creole.simpleDefinition">
		<xsl:param name="title" />
		<xsl:param name="definition" />

		<xsl:if test="string-length($title) &gt; 0">
			<xsl:call-template name="creole.definitionTitle">
				<xsl:with-param name="content" select="$title" />
			</xsl:call-template>
			<xsl:call-template name="creole.definition">
				<xsl:with-param name="content" select="$definition" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
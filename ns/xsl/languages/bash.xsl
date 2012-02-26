<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (c) 2011 by Renaud Guillard (dev@niao.fr) -->

<!-- - Extends shellscript templates -->
<!-- - Transform elements of the bash schema -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sh="http://xsd.nore.fr/bash">

	<xsl:output method="text" encoding="utf-8" />

	<xsl:include href="shellscript.xsl" />

	<xsl:param name="bash.def.elementType" />
	<xsl:param name="bash.def.functionName" />

	<xsl:template match="sh:body">
		<xsl:call-template name="str.trim">
			<xsl:with-param name="text" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="sh:function">
		<xsl:if test="(not($bash.def.elementType) or ($bash.def.elementType = 'function')) and (not($bash.def.functionName) or ($bash.def.functionName = @name))">
			<xsl:call-template name="sh.functionDefinition">
				<xsl:with-param name="name" select="@name" />
				<xsl:with-param name="content">
					<xsl:for-each select="sh:parameter">
						<xsl:text>local </xsl:text>
						<xsl:value-of select="normalize-space(@name)" />
						<xsl:text>=</xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="position()" />
							<xsl:with-param name="quoted" select="true()" />
						</xsl:call-template>
						<xsl:call-template name="unixEndl" />
					</xsl:for-each>
					<xsl:apply-templates select="sh:body" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="sh:functions">
		<xsl:apply-templates select="sh:function" />
	</xsl:template>
	
</xsl:stylesheet>
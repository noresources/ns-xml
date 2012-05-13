<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->

<!-- Transform document based on the bash XML schema to shell script code -->
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
			<xsl:value-of select="normalize-space(@name)" />
			<text>()</text>
			<xsl:call-template name="unixEndl" />
			<xsl:text>{</xsl:text>
			
			<!-- parameters -->
			<xsl:if test="sh:parameter">
				<xsl:call-template name="sh.block">
					<xsl:with-param name="addFinalEndl" select="false()" />
					<xsl:with-param name="addInitialEndl" select="false()" />
					<xsl:with-param name="endl"><text>&#10;</text></xsl:with-param>
					<xsl:with-param name="content">
						<xsl:for-each select="sh:parameter">
							<xsl:variable name="default" select="." />
							<xsl:variable name="quoted" select="not(@type) or (@type = 'string')" />
							<xsl:text>local </xsl:text>
							<xsl:value-of select="normalize-space(@name)" />
							<xsl:text>=</xsl:text>
							<xsl:call-template name="sh.var">
								<xsl:with-param name="name" select="1" />
								<xsl:with-param name="quoted" select="$quoted" />
							</xsl:call-template>
							<xsl:call-template name="unixEndl" />
							<xsl:if test="string-length($default) > 0">
								<xsl:text>[ -z "</xsl:text>
								<xsl:call-template name="sh.var">
									<xsl:with-param name="name" select="normalize-space(@name)" />
								</xsl:call-template>
								<xsl:text>" ]</xsl:text>
								<xsl:text> &amp;&amp; </xsl:text>
								<xsl:value-of select="normalize-space(@name)" />
								<xsl:text>=</xsl:text>
								<xsl:if test="$quoted">
									<text>"</text>
								</xsl:if>
								<xsl:value-of select="$default" />
								<xsl:if test="$quoted">
									<text>"</text>
								</xsl:if>
								<xsl:call-template name="unixEndl" />
							</xsl:if>
							<text>shift</text>
							<xsl:call-template name="unixEndl" />
						</xsl:for-each>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			
			<!-- body -->
			<xsl:choose>
				<xsl:when test="sh:body">
					<xsl:for-each select="sh:body">
						<xsl:choose>
							<xsl:when test="@indent = 'false'">
								<xsl:apply-templates select="." />
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="sh.block">
									<xsl:with-param name="addFinalEndl" select="false()" />
									<xsl:with-param name="content">
										<xsl:apply-templates select="." />
									</xsl:with-param>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:call-template name="unixEndl" />
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="unixEndl" />
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>}</xsl:text>
			<xsl:call-template name="unixEndl" />
		</xsl:if>
	</xsl:template>

	<xsl:template match="sh:functions">
		<xsl:apply-templates select="sh:function" />
	</xsl:template>

</xsl:stylesheet>
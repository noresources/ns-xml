<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2016 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Common template for sql schema to C struct conversion -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sql="http://xsd.nore.fr/sql">
	<xsl:import href="base.xsl" />

	<xsl:output method="text" indent="yes" encoding="utf-8" />

	<xsl:param name="sql.c.embeddedBase" select="'no'" />

	<xsl:param name="sql.c.headerGuard">
		<xsl:text>__</xsl:text>
		<xsl:call-template name="str.toUpper">
			<xsl:with-param name="text">
				<xsl:call-template name="c.validIdentifierName">
					<xsl:with-param name="name" select="concat($sql.c.exportIdentifierName, '_HEADER')" />
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:text>__</xsl:text>
	</xsl:param>
	
	<xsl:param name="sql.c.apiExportDefine">
		<xsl:call-template name="str.toUpper">
			<xsl:with-param name="text">
				<xsl:call-template name="c.validIdentifierName">
					<xsl:with-param name="name" select="concat($sql.c.exportIdentifierName, '_API')" />
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:param>
	
	<xsl:template match="sql:datasource">
		<xsl:if test="string-length($sql.c.headerGuard)">
			<xsl:call-template name="c.chunk.headerGuardOpen">
				<xsl:with-param name="identifier" select="$sql.c.headerGuard" />
			</xsl:call-template>
		</xsl:if>

		<xsl:call-template name="c.preprocessor.if">
			<xsl:with-param name="condition">
				<xsl:text>!defined (</xsl:text>
				<xsl:value-of select="$sql.c.apiExportDefine" />
				<xsl:text>)</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="then">
				<xsl:text>#define </xsl:text>
				<xsl:value-of select="$sql.c.apiExportDefine" />
				<xsl:value-of select="$str.endl" />
			</xsl:with-param>
		</xsl:call-template>		
		<xsl:value-of select="$str.endl" />

		<xsl:call-template name="c.chunk.cplusplusGuardOpen" />

		<xsl:text>#include &lt;stdlib.h&gt;</xsl:text>
		<xsl:value-of select="$str.endl" />

		<xsl:if test="$sql.c.embeddedBase = 'yes'">
			<xsl:call-template name="sql.c.baseDefinitions">
				<xsl:with-param name="datasource" select="." />
			</xsl:call-template>
		</xsl:if>
		<xsl:value-of select="$str.endl" />

		<xsl:choose>
			<xsl:when test="$sql.c.exportMode = 'variable'">
				<xsl:text>extern </xsl:text>
				<xsl:call-template name="c.identifierDefinition">
					<xsl:with-param name="type" select="$sql.c.datasourceStructureName" />
					<xsl:with-param name="pointer" select="1" />
					<xsl:with-param name="name" select="$sql.c.exportIdentifierName" />
				</xsl:call-template>
				<xsl:text>;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="c.functionDeclaration">
					<xsl:with-param name="returnType">
						<xsl:value-of select="$sql.c.datasourceStructureName" />
						<xsl:text> *</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="name">
						<xsl:value-of select="$sql.c.functionsPrefix" />
						<xsl:text>_get_structure</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:value-of select="$str.endl" />

		<xsl:call-template name="c.chunk.cplusplusGuardClose" />

		<xsl:if test="string-length($sql.c.headerGuard)">
			<xsl:call-template name="c.chunk.headerGuardClose">
				<xsl:with-param name="identifier" select="$sql.c.headerGuard" />
			</xsl:call-template>
		</xsl:if>

		<!-- End of file -->
		<xsl:value-of select="$str.endl" />
	</xsl:template>

</xsl:stylesheet>
	
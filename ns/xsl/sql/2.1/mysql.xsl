<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 - 2021 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Transforms sql:datasource xml document into MySQL instructions -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sql="http://xsd.nore.fr/sql/2.1">

	<xsl:import href="dbms-base.xsl" />

	<xsl:output method="text" indent="yes" encoding="utf-8" />

	<xsl:strip-space elements="*" />

	<!-- Template functions -->

	<!-- Protect string -->
	<xsl:template name="sql.protectString">
		<xsl:param name="string" select="." />
		<xsl:text>'</xsl:text>
		<xsl:call-template name="str.replaceAll">
			<xsl:with-param name="text">
				<xsl:value-of select="$string" />
			</xsl:with-param>
			<xsl:with-param name="replace">
				<xsl:text>'</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="by">
				<xsl:text>''</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:text>'</xsl:text>
	</xsl:template>

	<!-- MySQL use backquotes for identifiers -->
	<xsl:template name="sql.elementName">
		<xsl:param name="name" select="./@name" />

		<xsl:text>`</xsl:text>
		<xsl:value-of select="normalize-space($name)" />
		<xsl:text>`</xsl:text>
	</xsl:template>

	<!-- Text translations -->

	<!-- Convert generic data types into MySQL type affinity. -->
	<!-- See http://www.postgresql.org/docs/9.3/static/datatype.html -->
	<xsl:template name="sql.dataTypeTranslation">
		<xsl:param name="dataTypeNode" />
		<xsl:choose>
			<xsl:when test="not ($dataTypeNode)">
				<xsl:text>TEXT</xsl:text>
			</xsl:when>
			<xsl:when test="$dataTypeNode/sql:boolean">
				<xsl:text>BOOLEAN</xsl:text>
			</xsl:when>
			<xsl:when test="$dataTypeNode/sql:integer">
				<xsl:text>INTEGER</xsl:text>
			</xsl:when>
			<xsl:when test="$dataTypeNode/sql:numeric">
				<xsl:text>REAL</xsl:text>
			</xsl:when>
			<xsl:when test="$dataTypeNode/sql:timestamp">
				<xsl:variable name="timestampNode" select="$dataTypeNode/sql:timestamp" />
				<xsl:choose>
					<xsl:when test="($timestampNode/sql:date and $timestampNode/sql:time) or (count($timestampNode/child::*) = 0)">
						<xsl:text>datetime</xsl:text>
					</xsl:when>
					<xsl:when test="$timestampNode/sql:date">
						<xsl:text>date</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>time</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$dataTypeNode/sql:string">
				<xsl:choose>
					<xsl:when test="$dataTypeNode/sql:string/sql:enumeration">
						<xsl:text>ENUM(</xsl:text>
						<xsl:for-each select="$dataTypeNode/sql:string/sql:enumeration/sql:value">
							<xsl:if test="position() &gt; 1">
								<xsl:text>, </xsl:text>
							</xsl:if>
							<xsl:call-template name="sql.protectString" />
						</xsl:for-each>
						<xsl:text>)</xsl:text>
					</xsl:when>
					<xsl:when test="$dataTypeNode/sql:string/@length">
						<xsl:text>VARCHAR</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>TEXT</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$dataTypeNode/sql:binary">
				<xsl:text>BYTEA</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>TEXT</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="sql.dataTypeSizeSpecification">
		<xsl:param name="dataTypeNode" select="." />
		<xsl:choose>
			<xsl:when test="$dataTypeNode/sql:string">
				<xsl:if test="$dataTypeNode/sql:string/@length and not ($dataTypeNode/sql:string/sql:enumeration)">
					<xsl:text>(</xsl:text>
					<xsl:value-of select="$dataTypeNode/sql:string/@length" />
					<xsl:text>)</xsl:text>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- Objects -->

	<xsl:template match="sql:namespace">
		<xsl:text>CREATE DATABASE </xsl:text>
		<xsl:text>IF NOT EXISTS </xsl:text>
		<xsl:call-template name="sql.elementName" />
		<xsl:text>;</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:apply-templates />
	</xsl:template>

</xsl:stylesheet>

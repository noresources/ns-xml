<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 - 2021 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Transforms sql:datasource xml document into PostgreSQL instructions -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sql="http://xsd.nore.fr/sql/2.1">

	<xsl:import href="dbms-base.xsl" />

	<!-- The PostgreSQL target version -->
	<xsl:param name="sql.pgsql.targetVersion" select="9.4" />

	<xsl:output method="text" indent="yes" encoding="utf-8" />

	<xsl:strip-space elements="*" />

	<!-- Template functions -->

	<!-- Protect string -->
	<xsl:template name="sql.protectString">
		<xsl:param name="string" />
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

	<!-- Text translations -->

	<!-- Convert generic data types into PostgreSQL type affinity. -->
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
				<xsl:variable name="numericNode" select="$dataTypeNode/sql:integer" />
				<xsl:choose>
					<xsl:when test="$numericNode/@autoincrement = 'yes'">
						<xsl:text>SERIAL</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>INTEGER</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$dataTypeNode/sql:numeric">
				<xsl:text>REAL</xsl:text>
			</xsl:when>
			<xsl:when test="$dataTypeNode/sql:timestamp">
				<xsl:variable name="timestampNode" select="$dataTypeNode/sql:timestamp" />
				<xsl:choose>
					<xsl:when test="($timestampNode/sql:date and $timestampNode/sql:time) or (count($timestampNode/child::*) = 0)">
						<xsl:text>timestamp</xsl:text>
						<xsl:if test="count($timestampNode/child::*) = 0">
							<xsl:text> with time zone</xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$timestampNode/sql:date">
						<xsl:text>date</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>time</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="$timestampNode/sql:time">
					<xsl:text> with</xsl:text>
					<xsl:if test="not($timestampNode/sql:time[@timezone = 'yes'])">
						<xsl:text>out</xsl:text>
					</xsl:if>
					<xsl:text> time zone</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$dataTypeNode/sql:string">
				<xsl:choose>
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
				<xsl:if test="$dataTypeNode/sql:string/@length">
					<xsl:text>(</xsl:text>
					<xsl:value-of select="$dataTypeNode/sql:string/@length" />
					<xsl:text>)</xsl:text>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="sql.indexName">
		<!-- Index node -->
		<xsl:param name="element" select="." />
		<!-- 'declare' or 'reference' -->
		<xsl:param name="usage" select="reference" />

		<xsl:if test="$element/../@name and ($usage = 'reference')">
			<xsl:call-template name="sql.elementName">
				<xsl:with-param name="name" select="$element/../@name" />
			</xsl:call-template>
			<xsl:text>.</xsl:text>
		</xsl:if>
		<xsl:call-template name="sql.elementName">
			<xsl:with-param name="name" select="$element/@name" />
		</xsl:call-template>
	</xsl:template>

	<!-- Objects -->

	<xsl:template match="sql:namespace">
		<xsl:text>CREATE SCHEMA </xsl:text>
		<xsl:if test="$sql.pgsql.targetVersion &gt;= 9.3">
			<xsl:text>IF NOT EXISTS </xsl:text>
		</xsl:if>
		<xsl:call-template name="sql.elementName" />
		<xsl:text>;</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="sql:default/sql:hexBinary">
		<xsl:text>E'</xsl:text>
		<xsl:call-template name="sql.pgsql.hexPrefix" />
		<xsl:text>'</xsl:text>
	</xsl:template>

	<xsl:template match="sql:default/sql:base64Binary">
		<xsl:text>E'</xsl:text>
		<xsl:call-template name="sql.pgsql.hexPrefix">
			<xsl:with-param name="string">
				<xsl:call-template name="str.base64ToHex">
					<xsl:with-param name="text" select="." />
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:text>'</xsl:text>
	</xsl:template>

	<xsl:template name="sql.pgsql.hexPrefix">
		<xsl:param name="string" select="translate(normalize-space(.),' ','')" />

		<xsl:text>\x</xsl:text>
		<xsl:value-of select="substring($string, 1, 2)" />
		<xsl:if test="string-length($string) &gt; 2">
			<xsl:call-template name="sql.pgsql.hexPrefix">
				<xsl:with-param name="string" select="substring($string, 3)" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>

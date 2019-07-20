<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 - 2020 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Common template for sql schema to C struct conversion -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sql="http://xsd.nore.fr/sql">
	<xsl:import href="../../../languages/c.xsl" />
	<xsl:output method="text" indent="yes" encoding="utf-8" />

	<!-- Header to include on top of file -->
	<xsl:param name="sql.c.sourceHeader" />

	<!-- Prefix for constant names -->
	<xsl:param name="sql.c.constantsPrefix" select="'kNsXml'" />

	<!-- Prefix for type names -->
	<xsl:param name="sql.c.structuresPrefix" select="'NsXml'" />

	<!-- Prefix for function names -->
	<xsl:param name="sql.c.functionsPrefix" select="'nsXml'" />

	<!-- 'variable' or 'function' -->
	<xsl:param name="sql.c.exportMode" select="'variable'" />

	<!-- Name of the exported variable or function -->
	<xsl:param name="sql.c.exportIdentifierName">
		<xsl:call-template name="code.identifierNamingStyle">
			<xsl:with-param name="identifier">
				<xsl:value-of select="$sql.c.structuresPrefix" />
				<xsl:text>Structure</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="from" select="'auto'" />
			<xsl:with-param name="to" select="$c.structNamingStyle" />
		</xsl:call-template>
	</xsl:param>

	<xsl:param name="sql.c.headerGuard">
		<xsl:text>__</xsl:text>
		<xsl:call-template name="str.toUpper">
			<xsl:with-param name="text">
				<xsl:call-template name="c.validIdentifierName">
					<xsl:with-param name="name" select="concat($sql.c.exportIdentifierName, '_BASE')" />
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:text>__</xsl:text>
	</xsl:param>

	<xsl:variable name="sql.c.columnStructureName">
		<xsl:call-template name="code.identifierNamingStyle">
			<xsl:with-param name="identifier">
				<xsl:value-of select="$sql.c.structuresPrefix" />
				<xsl:text>SqlColumn</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="from" select="'auto'" />
			<xsl:with-param name="to" select="$c.structNamingStyle" />
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="sql.c.columnReferenceStructureName">
		<xsl:call-template name="code.identifierNamingStyle">
			<xsl:with-param name="identifier">
				<xsl:value-of select="$sql.c.structuresPrefix" />
				<xsl:text>SqlColumnReference</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="from" select="'auto'" />
			<xsl:with-param name="to" select="$c.structNamingStyle" />
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="sql.c.tableStructureName">
		<xsl:call-template name="code.identifierNamingStyle">
			<xsl:with-param name="identifier">
				<xsl:value-of select="$sql.c.structuresPrefix" />
				<xsl:text>SqlTable</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="from" select="'auto'" />
			<xsl:with-param name="to" select="$c.structNamingStyle" />
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="sql.c.tablesetStructureName">
		<xsl:call-template name="code.identifierNamingStyle">
			<xsl:with-param name="identifier">
				<xsl:value-of select="$sql.c.structuresPrefix" />
				<xsl:text>SqlTableset</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="from" select="'auto'" />
			<xsl:with-param name="to" select="$c.structNamingStyle" />
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="sql.c.datasourceStructureName">
		<xsl:call-template name="code.identifierNamingStyle">
			<xsl:with-param name="identifier">
				<xsl:value-of select="$sql.c.structuresPrefix" />
				<xsl:text>SqlDatasource</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="from" select="'auto'" />
			<xsl:with-param name="to" select="$c.structNamingStyle" />
		</xsl:call-template>
	</xsl:variable>

	<xsl:template name="sql.c.elementSuffix">
		<xsl:param name="node" select="." />
		<xsl:choose>
			<xsl:when test="$node/self::sql:column">
				<xsl:call-template name="sql.c.elementSuffix">
					<xsl:with-param name="node" select="$node/.." />
				</xsl:call-template>
				<xsl:text>_</xsl:text>
				<xsl:number count="sql:table/sql:column" />
			</xsl:when>
			<xsl:when test="$node/self::sql:table">
				<xsl:call-template name="sql.c.elementSuffix">
					<xsl:with-param name="node" select="$node/.." />
				</xsl:call-template>
				<xsl:text>_</xsl:text>
				<xsl:number count="sql:database/sql:table" />
			</xsl:when>
			<xsl:when test="$node/self::sql:database">
				<xsl:choose>
					<xsl:when test="$node/../self::sql:datasource">
						<xsl:call-template name="sql.c.elementSuffix">
							<xsl:with-param name="node" select="$node/.." />
						</xsl:call-template>
						<xsl:text>_</xsl:text>
						<xsl:number count="sql:datasource/sql:database" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>_1</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="sql.c.dataType">
		<xsl:param name="element" select="." />
		<xsl:choose>
			<xsl:when test="sql:datatype">
				<xsl:apply-templates select="sql:datatype" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$sql.c.constantsPrefix" />
				<xsl:text>DataTypeString</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="sql:datatype">
		<xsl:value-of select="$sql.c.constantsPrefix" />
		<xsl:text>DataType</xsl:text>
		<xsl:choose>
			<xsl:when test="./sql:numeric">
				<xsl:text>Numeric</xsl:text>
			</xsl:when>
			<xsl:when test="./sql:string">
				<xsl:text>String</xsl:text>
			</xsl:when>
			<xsl:when test="./sql:timestamp">
				<xsl:text>Timestamp</xsl:text>
			</xsl:when>
			<xsl:when test="./sql:binary">
				<xsl:text>Binary</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="sql.c.baseDefinitions">
		<xsl:param name="datasource" select="." />

		<!-- Datatypes -->
		<xsl:call-template name="c.comment">
			<xsl:with-param name="content">
				<xsl:text>SQL data types</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />
		<xsl:call-template name="c.enumDefinition">
			<xsl:with-param name="name">
				<xsl:value-of select="$sql.c.structuresPrefix" />
				<xsl:text>SqlDataTypes</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="content">
				<xsl:value-of select="$sql.c.constantsPrefix" />
				<xsl:text>DataTypeNumeric = 0,</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:value-of select="$sql.c.constantsPrefix" />
				<xsl:text>DataTypeString,</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:value-of select="$sql.c.constantsPrefix" />
				<xsl:text>DataTypeTimestamp,</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:value-of select="$sql.c.constantsPrefix" />
				<xsl:text>DataTypeBinary,</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:value-of select="$sql.c.constantsPrefix" />
				<xsl:text>DataTypeCount</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />

		<!-- Column flags -->
		<xsl:call-template name="c.enumDefinition">
			<xsl:with-param name="name">
				<xsl:value-of select="$sql.c.structuresPrefix" />
				<xsl:text>SqlColumnFlags</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="content">
				<xsl:value-of select="$sql.c.constantsPrefix" />
				<xsl:text>ColumnPrimary = 0x01,</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:value-of select="$sql.c.constantsPrefix" />
				<xsl:text>ColumnAcceptNull = 0x02,</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:value-of select="$sql.c.constantsPrefix" />
				<xsl:text>ColumnAutoincrement = 0x04</xsl:text>
				<xsl:value-of select="$str.endl" />
			</xsl:with-param>
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />

		<!-- Forward declarations -->
		<xsl:text>struct _</xsl:text>
		<xsl:value-of select="$sql.c.datasourceStructureName" />
		<xsl:text>;</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:text>typedef struct _</xsl:text>
		<xsl:value-of select="$sql.c.datasourceStructureName" />
		<xsl:text> </xsl:text>
		<xsl:value-of select="$sql.c.datasourceStructureName" />
		<xsl:text>;</xsl:text>
		<xsl:value-of select="$str.endl" />

		<xsl:text>struct _</xsl:text>
		<xsl:value-of select="$sql.c.tablesetStructureName" />
		<xsl:text>;</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:text>typedef struct _</xsl:text>
		<xsl:value-of select="$sql.c.tablesetStructureName" />
		<xsl:text> </xsl:text>
		<xsl:value-of select="$sql.c.tablesetStructureName" />
		<xsl:text>;</xsl:text>
		<xsl:value-of select="$str.endl" />

		<xsl:text>struct _</xsl:text>
		<xsl:value-of select="$sql.c.tableStructureName" />
		<xsl:text>;</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:text>typedef struct _</xsl:text>
		<xsl:value-of select="$sql.c.tableStructureName" />
		<xsl:text> </xsl:text>
		<xsl:value-of select="$sql.c.tableStructureName" />
		<xsl:text>;</xsl:text>
		<xsl:value-of select="$str.endl" />

		<xsl:text>struct _</xsl:text>
		<xsl:value-of select="$sql.c.columnStructureName" />
		<xsl:text>;</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:text>typedef struct _</xsl:text>
		<xsl:value-of select="$sql.c.columnStructureName" />
		<xsl:text> </xsl:text>
		<xsl:value-of select="$sql.c.columnStructureName" />
		<xsl:text>;</xsl:text>
		<xsl:value-of select="$str.endl" />

		<xsl:text>struct _</xsl:text>
		<xsl:value-of select="$sql.c.columnReferenceStructureName" />
		<xsl:text>;</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:text>typedef struct _</xsl:text>
		<xsl:value-of select="$sql.c.columnReferenceStructureName" />
		<xsl:text> </xsl:text>
		<xsl:value-of select="$sql.c.columnReferenceStructureName" />
		<xsl:text>;</xsl:text>
		<xsl:value-of select="$str.endl" />

		<!-- Structure declarations -->
		<xsl:call-template name="c.structDefinition">
			<xsl:with-param name="name" select="concat ('_', $sql.c.columnStructureName)" />
			<xsl:with-param name="content">
				<xsl:call-template name="c.identifierDefinition">
					<xsl:with-param name="type" select="'const char'" />
					<xsl:with-param name="pointer" select="1" />
					<xsl:with-param name="name" select="'columnName'" />
				</xsl:call-template>
				<xsl:text>;</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:call-template name="c.identifierDefinition">
					<xsl:with-param name="type" select="'int'" />
					<xsl:with-param name="name" select="'columnDataType'" />
				</xsl:call-template>
				<xsl:text>;</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:call-template name="c.identifierDefinition">
					<xsl:with-param name="type" select="'int'" />
					<xsl:with-param name="name" select="'columnFlags'" />
				</xsl:call-template>
				<xsl:text>;</xsl:text>
				<xsl:value-of select="$str.endl" />
			</xsl:with-param>
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />

		<xsl:call-template name="c.structDefinition">
			<xsl:with-param name="name" select="concat ('_', $sql.c.columnReferenceStructureName)" />
			<xsl:with-param name="content">
				<xsl:call-template name="c.identifierDefinition">
					<xsl:with-param name="type" select="$sql.c.tableStructureName" />
					<xsl:with-param name="pointer" select="1" />
					<xsl:with-param name="name" select="'table'" />
				</xsl:call-template>
				<xsl:text>;</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:call-template name="c.identifierDefinition">
					<xsl:with-param name="type" select="$sql.c.columnStructureName" />
					<xsl:with-param name="pointer" select="1" />
					<xsl:with-param name="name" select="'column'" />
				</xsl:call-template>
				<xsl:text>;</xsl:text>
				<xsl:value-of select="$str.endl" />
			</xsl:with-param>
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />

		<xsl:call-template name="c.structDefinition">
			<xsl:with-param name="name" select="concat('_', $sql.c.tableStructureName)" />
			<xsl:with-param name="content">
				<xsl:call-template name="c.identifierDefinition">
					<xsl:with-param name="type" select="'const char'" />
					<xsl:with-param name="pointer" select="1" />
					<xsl:with-param name="name" select="'tableName'" />
				</xsl:call-template>
				<xsl:text>;</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:call-template name="c.identifierDefinition">
					<xsl:with-param name="type" select="'size_t'" />
					<xsl:with-param name="name" select="'columnCount'" />
				</xsl:call-template>
				<xsl:text>;</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:call-template name="c.identifierDefinition">
					<xsl:with-param name="type" select="$sql.c.columnStructureName" />
					<xsl:with-param name="pointer" select="2" />
					<xsl:with-param name="name" select="'columns'" />
				</xsl:call-template>
				<xsl:text>;</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:call-template name="c.identifierDefinition">
					<xsl:with-param name="type" select="$sql.c.columnReferenceStructureName" />
					<xsl:with-param name="pointer" select="2" />
					<xsl:with-param name="name" select="'foreignKeys'" />
				</xsl:call-template>
				<xsl:text>;</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />

		<xsl:call-template name="c.structDefinition">
			<xsl:with-param name="name" select="concat ('_', $sql.c.tablesetStructureName)" />
			<xsl:with-param name="content">
				<xsl:call-template name="c.identifierDefinition">
					<xsl:with-param name="type" select="'const char'" />
					<xsl:with-param name="pointer" select="1" />
					<xsl:with-param name="name" select="'tablesetName'" />
				</xsl:call-template>
				<xsl:text>;</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:call-template name="c.identifierDefinition">
					<xsl:with-param name="type" select="'size_t'" />
					<xsl:with-param name="name" select="'tableCount'" />
				</xsl:call-template>
				<xsl:text>;</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:call-template name="c.identifierDefinition">
					<xsl:with-param name="type" select="$sql.c.tableStructureName" />
					<xsl:with-param name="pointer" select="2" />
					<xsl:with-param name="name" select="'tables'" />
				</xsl:call-template>
				<xsl:text>;</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />

		<xsl:call-template name="c.structDefinition">
			<xsl:with-param name="name" select="concat ('_', $sql.c.datasourceStructureName)" />
			<xsl:with-param name="content">
				<xsl:call-template name="c.identifierDefinition">
					<xsl:with-param name="type" select="'size_t'" />
					<xsl:with-param name="name" select="'tablesetCount'" />
				</xsl:call-template>
				<xsl:text>;</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:call-template name="c.identifierDefinition">
					<xsl:with-param name="type" select="$sql.c.tablesetStructureName" />
					<xsl:with-param name="pointer" select="2" />
					<xsl:with-param name="name" select="'tablesets'" />
				</xsl:call-template>
				<xsl:text>;</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/sql:datasource|/sql:database">
		<xsl:value-of select="$sql.c.sourceHeader" />
		<xsl:if test="./self::sql:datasource">
			<xsl:call-template name="c.comment">
				<xsl:with-param name="content">
					<xsl:text>Schema version: </xsl:text>
					<xsl:value-of select="@version" />
					<xsl:if test="@author">
						<xsl:value-of select="$str.endl" />
						<xsl:text>Author: </xsl:text>
						<xsl:value-of select="@author" />
					</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:value-of select="$str.endl" />
		</xsl:if>

		<xsl:if test="string-length($sql.c.headerGuard)">
			<xsl:call-template name="c.chunk.headerGuardOpen">
				<xsl:with-param name="identifier" select="$sql.c.headerGuard" />
			</xsl:call-template>
		</xsl:if>

		<xsl:call-template name="c.chunk.cplusplusGuardOpen" />

		<xsl:text>#include &lt;stdlib.h&gt;</xsl:text>
		<xsl:value-of select="$str.endl" />

		<xsl:call-template name="sql.c.baseDefinitions">
			<xsl:with-param name="datasource" select="." />
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />

		<xsl:if test="string-length($sql.c.headerGuard)">
			<xsl:call-template name="c.chunk.headerGuardClose">
				<xsl:with-param name="identifier" select="$sql.c.headerGuard" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
	
<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 - 2020 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Common template for sql schema to C struct conversion -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sql="http://xsd.nore.fr/sql">
	<xsl:import href="base.xsl" />

	<xsl:output method="text" indent="yes" encoding="utf-8" />

	<xsl:param name="sql.c.headerInclude" />

	<xsl:variable name="sql.c.source.datasourceIdentifierName">
		<xsl:text>internal_</xsl:text>
		<xsl:value-of select="$sql.c.exportIdentifierName" />
	</xsl:variable>

	<xsl:template name="sql.c.source.tableColumnIndex">
		<xsl:param name="table" />
		<xsl:param name="columnName" />

		<xsl:for-each select="$table/sql:column">
			<xsl:if test="@name = $columnName">
				<xsl:value-of select="position()" />
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- Output the table variable name corresponding to a given table reference -->
	<xsl:template name="sql.c.source.tableReferenceVariable">
		<!-- sql:tableref node -->
		<xsl:param name="tableReference" select="." />

		<xsl:variable name="parentTable" select="$tableReference/../../.." />
		<xsl:variable name="parentTableset" select="$parentTable/.." />
		<xsl:variable name="datasource" select="$parentTableset/.." />

		<xsl:choose>
			<xsl:when test="$tableReference/@name">
				<xsl:choose>
					<xsl:when test="$parentTableset/sql:table[@name = $tableReference/@name]">
					</xsl:when>
					<xsl:otherwise>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="sql.c.source.columnReference">
		<xsl:param name="foreignKey" select="." />
		<xsl:param name="tablesetIndex" />
		<xsl:param name="tableIndex" />
		<xsl:param name="columnIndex" select="position()" />
		<xsl:param name="declare" select="false()" />

		<xsl:if test="$declare">
			<xsl:call-template name="c.inlineComment">
				<xsl:with-param name="content">
					<xsl:text>-- Column reference </xsl:text>
					<xsl:value-of select="$foreignKey/sql:column/@name" />
					<xsl:text> -> </xsl:text>
					<xsl:value-of select="$foreignKey/sql:reference/sql:column/@name"></xsl:value-of>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:value-of select="$str.endl" />
			<xsl:text>static </xsl:text>
			<xsl:value-of select="$sql.c.columnReferenceStructureName" />
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:text>column_ref</xsl:text>
		<xsl:apply-templates select="$foreignKey/../sql:column[@name = $foreignKey/sql:column/@name]">
			<xsl:with-param name="suffixOnly" select="true()" />
		</xsl:apply-templates>
		<xsl:if test="$declare">
			<xsl:text> = {</xsl:text>
			<xsl:text> &amp;</xsl:text>
			<xsl:apply-templates select="$foreignKey/sql:reference/sql:tableref" />
			<xsl:text>, &amp;</xsl:text>
			<xsl:apply-templates select="$foreignKey/sql:reference/sql:tableref">
				<xsl:with-param name="columnName" select="$foreignKey/sql:reference/sql:column/@name" />
			</xsl:apply-templates>
			<xsl:text> };</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template name="sql.c.source.column">
		<xsl:param name="declare" select="false()" />

		<xsl:variable name="columnName" select="@name" />

		<xsl:if test="$declare">
			<xsl:call-template name="c.inlineComment">
				<xsl:with-param name="content">
					<xsl:text>	-- Column "</xsl:text>
					<xsl:call-template name="sql.c.elementSuffix" />
					<xsl:text>"</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:value-of select="$str.endl" />

			<xsl:text>static </xsl:text>
			<xsl:value-of select="$sql.c.columnStructureName" />
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:text>column</xsl:text>
		<xsl:call-template name="sql.c.elementSuffix" />
		<xsl:if test="$declare">
			<xsl:text> = {</xsl:text>
			<xsl:text>"</xsl:text>
			<xsl:value-of select="$columnName" />
			<xsl:text>", </xsl:text>
			<xsl:call-template name="sql.c.dataType" />
			<xsl:text>, (0</xsl:text>
			<xsl:if test="../sql:primarykey/sql:column[@name = $columnName]">
				<xsl:text> | </xsl:text>
				<xsl:value-of select="$sql.c.constantsPrefix" />
				<xsl:text>ColumnPrimary</xsl:text>
			</xsl:if>
			<xsl:if test="not (sql:notnull)">
				<xsl:text> | </xsl:text>
				<xsl:value-of select="$sql.c.constantsPrefix" />
				<xsl:text>ColumnAcceptNull</xsl:text>
			</xsl:if>
			<xsl:if test="sql:datatype/sql:numeric[@autoincrement = 'yes']">
				<xsl:text> | </xsl:text>
				<xsl:value-of select="$sql.c.constantsPrefix" />
				<xsl:text>ColumnAutoincrement</xsl:text>
			</xsl:if>
			<xsl:text>)}</xsl:text>
			<xsl:text>;</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template name="sql.c.source.table">
		<xsl:param name="tableIndex" select="position()" />
		<xsl:param name="tablesetIndex" select="position()" />
		<xsl:param name="declare" select="false()" />

		<xsl:if test="$declare">
			<xsl:call-template name="c.inlineComment">
				<xsl:with-param name="content">
					<xsl:text>	- Table "</xsl:text>
					<xsl:value-of select="@name" />
					<xsl:text>"</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:value-of select="$str.endl" />

			<!-- columns -->
			<xsl:for-each select="sql:column">
				<xsl:call-template name="sql.c.source.column">
					<xsl:with-param name="declare" select="true()" />
				</xsl:call-template>
				<xsl:value-of select="$str.endl" />
			</xsl:for-each>

			<!-- array of columns -->
			<xsl:text>static </xsl:text>
			<xsl:value-of select="$sql.c.columnStructureName" />
			<xsl:text> *columns</xsl:text>
			<xsl:call-template name="sql.c.elementSuffix" />
			<xsl:text>[</xsl:text>
			<xsl:value-of select="count(sql:column)" />
			<xsl:text>] = {</xsl:text>
			<xsl:for-each select="./sql:column">
				<xsl:text>&amp;</xsl:text>
				<xsl:call-template name="sql.c.source.column" />
				<xsl:if test="position() != last()">
					<xsl:text>, </xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:text>};</xsl:text>
			<xsl:value-of select="$str.endl" />

			<!-- foreign keys -->
			<xsl:for-each select="sql:foreignkey">
				<xsl:variable name="columnName" select="sql:column/@name" />
				<xsl:call-template name="sql.c.source.columnReference">
					<xsl:with-param name="tablesetIndex" select="$tablesetIndex" />
					<xsl:with-param name="tableIndex" select="$tableIndex" />
					<xsl:with-param name="columnIndex">
						<xsl:call-template name="sql.c.source.tableColumnIndex">
							<xsl:with-param name="table" select=".." />
							<xsl:with-param name="columnName" select="$columnName" />
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="declare" select="true()" />
				</xsl:call-template>
				<xsl:value-of select="$str.endl" />
			</xsl:for-each>

			<!-- array of column reference -->
			<xsl:text>static </xsl:text>
			<xsl:value-of select="$sql.c.columnReferenceStructureName" />
			<xsl:text> *column_references</xsl:text>
			<xsl:call-template name="sql.c.elementSuffix" />
			<xsl:text>[</xsl:text>
			<xsl:value-of select="count(sql:column)" />
			<xsl:text>] = {</xsl:text>
			<xsl:for-each select="./sql:column">
				<xsl:variable name="columnName" select="@name" />
				<xsl:choose>
					<xsl:when test="../sql:foreignkey/sql:column[@name = $columnName]">
						<xsl:text>&amp;</xsl:text>
						<xsl:call-template name="sql.c.source.columnReference">
							<xsl:with-param name="foreignKey" select="../sql:foreignkey[./sql:column[@name = $columnName]]" />
							<xsl:with-param name="tablesetIndex" select="$tablesetIndex" />
							<xsl:with-param name="tableIndex" select="$tableIndex" />
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>NULL</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="position() != last()">
					<xsl:text>, </xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:text>};</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>

		<xsl:if test="$declare">
			<xsl:text>static </xsl:text>
			<xsl:value-of select="$sql.c.tableStructureName" />
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:text>table</xsl:text>
		<xsl:call-template name="sql.c.elementSuffix" />
		<xsl:if test="$declare">
			<xsl:text> = { "</xsl:text>
			<xsl:value-of select="@name" />
			<xsl:text>", </xsl:text>
			<xsl:value-of select="count(sql:column)" />
			<xsl:text>, &amp;columns</xsl:text>
			<xsl:call-template name="sql.c.elementSuffix" />
			<xsl:text>[0], &amp;column_references</xsl:text>
			<xsl:call-template name="sql.c.elementSuffix" />
			<xsl:text>[0]};</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>
	</xsl:template>

	<xsl:template name="sql.c.source.tableset">
		<xsl:param name="element" select="." />
		<xsl:param name="tablesetIndex">
			<xsl:choose>
				<xsl:when test="position()">
					<xsl:value-of select="position()" />
				</xsl:when>
				<xsl:otherwise>
					x
				</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<xsl:param name="declare" select="false()" />

		<xsl:if test="$declare">
			<xsl:call-template name="c.inlineComment">
				<xsl:with-param name="content">
					<xsl:text>Tableset "</xsl:text>
					<xsl:value-of select="$element/@name" />
					<xsl:text>"</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:value-of select="$str.endl" />

			<xsl:for-each select="$element/sql:table">
				<xsl:call-template name="sql.c.source.table">
					<xsl:with-param name="tablesetIndex" select="$tablesetIndex" />
					<xsl:with-param name="declare" select="true()" />
				</xsl:call-template>
			</xsl:for-each>

			<!-- array of tables -->
			<xsl:text>static </xsl:text>
			<xsl:value-of select="$sql.c.tableStructureName" />
			<xsl:text> *tables_</xsl:text>
			<xsl:value-of select="$tablesetIndex" />
			<xsl:text>[</xsl:text>
			<xsl:value-of select="count($element/sql:table)" />
			<xsl:text>] = {</xsl:text>
			<xsl:for-each select="$element/sql:table">
				<xsl:text>&amp;</xsl:text>
				<xsl:call-template name="sql.c.source.table">
					<xsl:with-param name="tablesetIndex" select="$tablesetIndex" />
					<xsl:with-param name="declare" select="false()" />
				</xsl:call-template>

				<xsl:if test="position() != last()">
					<xsl:text>, </xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:text>};</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>

		<xsl:if test="$declare">
			<xsl:text>static </xsl:text>
			<xsl:value-of select="$sql.c.tablesetStructureName" />
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:text>tableset_</xsl:text>
		<xsl:value-of select="$tablesetIndex" />

		<xsl:if test="$declare">
			<xsl:text> = {</xsl:text>
			<xsl:text>"</xsl:text>
			<xsl:value-of select="@name" />
			<xsl:text>", </xsl:text>
			<xsl:value-of select="count (sql:table)" />
			<xsl:text>, </xsl:text>
			<xsl:text>&amp;tables_</xsl:text>
			<xsl:value-of select="$tablesetIndex" />
			<xsl:text>[0]};</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template name="sql.c.source.tablesetArray">
		<!-- array of tablesets -->

		<xsl:param name="database" />
		<!-- for single tableset -->

		<xsl:text>static </xsl:text>
		<xsl:value-of select="$sql.c.tablesetStructureName" />
		<xsl:text> *tablesets[</xsl:text>
		<xsl:choose>
			<xsl:when test="$database">
				<xsl:text>1</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="count(sql:database)" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>] = {</xsl:text>

		<xsl:choose>
			<xsl:when test="$database">
				<xsl:text>&amp;</xsl:text>
				<xsl:call-template name="sql.c.source.tableset">
					<xsl:with-param name="declare" select="false()" />
					<xsl:with-param name="element" select="$database" />
					<xsl:with-param name="tablesetIndex" select="1" />
				</xsl:call-template>
				<xsl:if test="position() != last()">
					<xsl:text>, </xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="sql:database">
					<xsl:text>&amp;</xsl:text>
					<xsl:call-template name="sql.c.source.tableset">
						<xsl:with-param name="declare" select="false()" />
					</xsl:call-template>
					<xsl:if test="position() != last()">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>};</xsl:text>
	</xsl:template>

	<xsl:template name="sql.c.source.datasource">
		<xsl:param name="declare" select="false()" />
		<xsl:if test="$declare">
			<xsl:text>static </xsl:text>
			<xsl:value-of select="$sql.c.datasourceStructureName" />
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:value-of select="$sql.c.source.datasourceIdentifierName" />

		<xsl:if test="$declare">
			<xsl:text> = {</xsl:text>
			<xsl:choose>
				<xsl:when test="count (sql:database) = 0">
					<xsl:text>1</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="count (sql:database)" />
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>, </xsl:text>
			<xsl:text>&amp;tablesets[0]</xsl:text>
			<xsl:text>};</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="sql:column">
		<xsl:param name="declare" select="false()" />
		<xsl:param name="suffixOnly" select="false" />

		<xsl:choose>
			<xsl:when test="$suffixOnly">
				<xsl:call-template name="sql.c.elementSuffix" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="sql.c.source.column">
					<xsl:with-param name="declare" select="$declare" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="sql:table">
		<xsl:param name="declare" select="false()" />
		<xsl:param name="suffixOnly" select="false()" />

		<xsl:choose>
			<xsl:when test="$suffixOnly">
				<xsl:call-template name="sql.c.elementSuffix" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="sql.c.source.table">
					<xsl:with-param name="declare" select="$declare" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="sql:tableref">
		<xsl:param name="declare" select="false()" />
		<xsl:param name="table" select="../../.." />
		<xsl:param name="columnName" />

		<xsl:choose>
			<xsl:when test="@name">
				<xsl:variable name="name" select="@name" />
				<xsl:variable name="tableref" select="$table/../sql:table[@name = $name]" />
				<xsl:choose>
					<xsl:when test="$columnName">
						<xsl:apply-templates select="$tableref/sql:column[@name = $columnName]">
							<xsl:with-param name="declare" select="$declare" />
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="$tableref">
							<xsl:with-param name="declare" select="$declare" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="id" select="	@id" />
				<xsl:variable name="tableref" select="$table/../..//sql:table[@id = $id]" />
				<xsl:choose>
					<xsl:when test="$columnName">
						<xsl:apply-templates select="$tableref/sql:column[@name = $columnName]">
							<xsl:with-param name="declare" select="$declare" />
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="$tableref">
							<xsl:with-param name="declare" select="$declare" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="/sql:datasource|/sql:database">

		<xsl:if test="string-length($sql.c.headerInclude)">
			<xsl:text>#include "</xsl:text>
			<xsl:value-of select="$sql.c.headerInclude" />
			<xsl:text>"</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>

		<xsl:value-of select="$str.endl" />

		<xsl:choose>
			<xsl:when test="./self::sql:datasource">
				<!-- declare tablesets -->
				<xsl:for-each select="sql:database">
					<xsl:call-template name="sql.c.source.tableset">
						<xsl:with-param name="declare" select="true()" />
					</xsl:call-template>
				</xsl:for-each>
				<xsl:value-of select="$str.endl" />
				<xsl:call-template name="sql.c.source.tablesetArray" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="sql.c.source.tableset">
					<xsl:with-param name="declare" select="true()" />
				</xsl:call-template>
				<xsl:value-of select="$str.endl" />

				<xsl:call-template name="sql.c.source.tablesetArray">
					<xsl:with-param name="database" select="." />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>


		<xsl:value-of select="$str.endl" />
		<xsl:call-template name="sql.c.source.datasource">
			<xsl:with-param name="declare" select="true()" />
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />

		<xsl:choose>
			<xsl:when test="$sql.c.exportMode = 'variable'">
				<xsl:call-template name="c.identifierDefinition">
					<xsl:with-param name="type" select="$sql.c.datasourceStructureName" />
					<xsl:with-param name="pointer" select="1" />
					<xsl:with-param name="name" select="$sql.c.exportIdentifierName" />
				</xsl:call-template>
				<xsl:text> = &amp;</xsl:text>
				<xsl:value-of select="$sql.c.source.datasourceIdentifierName" />
				<xsl:text>;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="c.functionDefinition">
					<xsl:with-param name="returnType">
						<xsl:value-of select="$sql.c.datasourceStructureName" />
						<xsl:text> *</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="name">
						<xsl:value-of select="$sql.c.functionsPrefix" />
						<xsl:text>_get_structure</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="content">
						<xsl:text>return &amp;</xsl:text>
						<xsl:value-of select="$sql.c.source.datasourceIdentifierName" />
						<xsl:text>;</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>


		<!-- End of file -->
		<xsl:value-of select="$str.endl" />
	</xsl:template>

</xsl:stylesheet>
	
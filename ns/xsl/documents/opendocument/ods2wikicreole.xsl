<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2018 - 2020 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Convert OpenDocument spreadsheet into a WikiCreole table -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" version="1.0">
	<xsl:import href="spreadsheet-base.xsl"/>
	<xsl:import href="../../languages/wikicreole.xsl"/>
	<xsl:output method="text" encoding="utf-8"/>
	<!-- Table to export (0: all) -->
	<xsl:param name="odf.spreadsheet2wikicreole.tableIndex" select="0"/>
	<!-- First column to add -->
	<xsl:param name="odf.spreadsheet2wikicreole.firstColumnIndex" select="0"/>
	<!-- Last column to add (0 = all) -->
	<xsl:param name="odf.spreadsheet2wikicreole.lastColumnIndex" select="0"/>
	<!-- Use WikiCreole Table heading style for the first spreadsheet row -->
	<xsl:param name="odf.spreadsheet2wikicreole.header" select="true()"/>
	<!-- Skip first spreadsheet row -->
	<xsl:param name="odf.spreadsheet2wikicreole.ignoreFirstRow" select="not($odf.spreadsheet2wikicreole.header)"/>
	<!-- Index of the header row -->
	<xsl:variable name="odf.spreadsheet2wikicreole.headerRowIndex">
		<xsl:choose>
			<xsl:when test="not($odf.spreadsheet2wikicreole.header)">
				<xsl:value-of select="-1"/>
			</xsl:when>
			<xsl:when test="$odf.spreadsheet2wikicreole.ignoreFirstRow">
				<xsl:value-of select="2"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="1"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<!-- Process a table cell -->
	<xsl:template name="odf.spreadsheet2wikicreole.cell">
		<!-- cell -->
		<xsl:param name="cell" select="."/>
		<!-- Position of the cell in the row -->
		<xsl:param name="cellIndex"/>
		<!-- Position of the row in the table -->
		<xsl:param name="rowIndex"/>
		<!-- Last cell position to consider -->
		<xsl:param name="last" select="$last"/>
		<!-- Internal use -->
		<xsl:param name="_subIndex" select="0"/>
		<xsl:if test="($last = 0) or (($cellIndex + $_subIndex) &lt;= $last)">
			<xsl:choose>
				<xsl:when test="$rowIndex = $odf.spreadsheet2wikicreole.headerRowIndex">
					<xsl:call-template name="creole.table.header">
						<xsl:with-param name="content">
							<xsl:apply-templates select="$cell"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="creole.table.cell">
						<xsl:with-param name="content">
							<xsl:apply-templates select="$cell"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="$cell/@table:number-columns-repeated and (($_subIndex + 1) &lt; $cell/@table:number-columns-repeated)">
				<xsl:call-template name="odf.spreadsheet2wikicreole.cell">
					<xsl:with-param name="cell" select="$cell"/>
					<xsl:with-param name="cellIndex" select="$cellIndex"/>
					<xsl:with-param name="rowIndex" select="$rowIndex"/>
					<xsl:with-param name="last" select="$last"/>
					<xsl:with-param name="_subIndex" select="$_subIndex + 1"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<!-- Write a table row into WikiCreole -->
	<xsl:template name="odf.spreadsheet2wikicreole.row">
		<!-- Table row (table:table-row) -->
		<xsl:param name="row" select="."/>
		<!-- Table row index -->
		<xsl:param name="index"/>
		<xsl:variable name="first" select="$odf.spreadsheet2wikicreole.firstColumnIndex"/>
		<xsl:variable name="last" select="$odf.spreadsheet2wikicreole.lastColumnIndex"/>
		<xsl:for-each select="$row/table:table-cell">
			<xsl:variable name="position">
				<xsl:call-template name="odf.spreadsheet.cellIndex">
					<xsl:with-param name="cell" select="."/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:if test="(position() != last()) and ($position &gt;= $first) and (($last = 0) or ($position &lt;= $last))">
				<xsl:call-template name="odf.spreadsheet2wikicreole.cell">
					<xsl:with-param name="cellIndex" select="$position"/>
					<xsl:with-param name="rowIndex" select="$index"/>
					<xsl:with-param name="last" select="$last"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
		<!-- manually set end-of-row  -->
		<xsl:text>|</xsl:text>
		<xsl:value-of select="$str.endl"/>
	</xsl:template>

	<!--  -->
	<xsl:template match="/office:document-content">
		<xsl:apply-templates select="office:body"/>
	</xsl:template>

	<xsl:template match="office:body">
		<xsl:apply-templates select="office:spreadsheet"/>
	</xsl:template>

	<xsl:template match="office:spreadsheet">
		<xsl:choose>
			<xsl:when test="$odf.spreadsheet2wikicreole.tableIndex &gt; 0">
				<xsl:apply-templates select="table:table[$odf.spreadsheet2wikicreole.tableIndex]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="table:table"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="table:table">
		<xsl:for-each select="./table:table-row[table:table-cell/text:p]">
			<xsl:if test="(position() &gt; 1) or not($odf.spreadsheet2wikicreole.ignoreFirstRow)">
				<xsl:call-template name="odf.spreadsheet2wikicreole.row">
					<xsl:with-param name="index" select="position()"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="table:table-cell/text()">
		
	</xsl:template>

	<!-- Default text processing  -->
	<xsl:template match="text:p">
		<xsl:value-of select="normalize-space(.)"/>
	</xsl:template>

</xsl:stylesheet>

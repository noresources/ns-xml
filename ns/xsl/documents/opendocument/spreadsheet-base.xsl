<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 - 2021 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!--  -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" version="1.0">
	<xsl:import href="../../languages/wikicreole.xsl"/>
	<xsl:template name="odf.spreadsheet.cellIndex">
		<!-- Table cell (table:table-cell) -->
		<xsl:param name="cell" select="."/>
		<xsl:param name="_cellIndex" select="1"/>
		<!-- Internal use -->
		<xsl:param name="_count" select="1"/>
		<xsl:variable name="row" select="$cell/.."/>
		<xsl:variable name="currentCell" select="$row/table:table-cell[$_cellIndex]"/>
		<xsl:choose>
			<xsl:when test="$currentCell = $cell">
				<xsl:value-of select="$_count"/>
			</xsl:when>
			<xsl:when test="$currentCell/@table:number-columns-repeated">
				<xsl:call-template name="odf.spreadsheet.cellIndex">
					<xsl:with-param name="cell" select="$cell"/>
					<xsl:with-param name="_cellIndex" select="($_cellIndex + 1)"/>
					<xsl:with-param name="_count" select="$_count + $currentCell/@table:number-columns-repeated"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="odf.spreadsheet.cellIndex">
					<xsl:with-param name="cell" select="$cell"/>
					<xsl:with-param name="_cellIndex" select="$_cellIndex + 1"/>
					<xsl:with-param name="_count" select="$_count + 1"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>

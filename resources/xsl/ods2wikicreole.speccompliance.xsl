<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Convert OpenDocument spreadsheet into a WikiCreole table -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" version="1.0">
	<xsl:import href="../../ns/xsl/documents/opendocument/ods2wikicreole.xsl"/>
	<xsl:template match="table:table-cell">
		<xsl:variable name="index" select="count(./preceding-sibling::*)" />
		<xsl:choose>
			<xsl:when test="(./@office:value-type = 'float') and ($index != 1)">
				<xsl:text>{{images/</xsl:text>
				<xsl:choose>
					<xsl:when test="./@office:value = 0">
						<xsl:text>question-16.png|Not tested/Unknown}}</xsl:text>
					</xsl:when>
					<xsl:when test="./@office:value &gt; 0">
						<xsl:text>valid-16.png|Supported}}</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>error-16.png|Not supported}}</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>

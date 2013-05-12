<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!--
	Mac OS X property list elements
	Documents which use these templates should set output as
	<output method="xml"
	doctype-system="http://www.apple.com/DTDs/PropertyList-1.0.dtd"
	doctype-public="-//Apple Computer//DTD PLIST 1.0//EN"
	encoding="utf-8" indent="yes" />
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template name="plist.string">
		<xsl:param name="key" />
		<xsl:param name="value" />
		<xsl:element name="key">
			<xsl:value-of select="$key" />
		</xsl:element>
		<xsl:element name="string">
			<xsl:value-of select="$value" />
		</xsl:element>
	</xsl:template>

	<xsl:template name="plist.boolean">
		<xsl:param name="key" />
		<xsl:param name="value" select="false()" />
		<xsl:element name="key">
			<xsl:value-of select="$key" />
		</xsl:element>
		<xsl:choose>
			<xsl:when test="$value">
				<xsl:element name="true" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="false" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="plist.dict">
		<xsl:param name="content" />
		<xsl:element name="dict">
			<xsl:copy-of select="$content" />
		</xsl:element>
	</xsl:template>

	<xsl:template name="plist.document">
		<xsl:param name="content" />
		<xsl:param name="version">
			<xsl:text>1.0</xsl:text>
		</xsl:param>
		<xsl:element name="plist">
			<xsl:attribute name="version"><xsl:value-of select="$version" /></xsl:attribute>
			<xsl:call-template name="plist.dict">
				<xsl:with-param name="content" select="$content" />
			</xsl:call-template>
		</xsl:element>
	</xsl:template>

</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Helper template to Retrieve program informations in scripts  -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	<xsl:output method="text" encoding="utf-8" />
	<xsl:param name="name" />
	<xsl:template match="/prg:program">
		<xsl:choose>
			<xsl:when test="$name = 'name'">
				<xsl:value-of select="normalize-space(prg:name)" />
			</xsl:when>
			<xsl:when test="$name = 'label'">
				<xsl:choose>
					<xsl:when test="prg:ui/prg:label">
						<xsl:value-of select="normalize-space(prg:ui/prg:label)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="normalize-space(prg:name)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$name = 'author'">
				<xsl:value-of select="normalize-space(prg:author)" />
			</xsl:when>
			<xsl:when test="$name = 'version'">
				<xsl:value-of select="normalize-space(prg:version)" />
			</xsl:when>
		</xsl:choose>
		<xsl:value-of select="'&#10;'" />
	</xsl:template>

</xsl:stylesheet>

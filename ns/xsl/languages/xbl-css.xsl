<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Create CSS rules for XBL control bindings -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xbl="http://www.mozilla.org/xbl">

	<xsl:import href="css.xsl" />

	<xsl:output method="text" encoding="utf-8" />
	
	<xsl:param name="xbl.css.displayHeader" select="false()" />

	<xsl:template match="/">
		<xsl:if test="$xbl.css.displayHeader">
			<xsl:text>@CHARSET "UTF-8";</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>

		<xsl:for-each select="//xbl:binding">
			<xsl:call-template name="css.rule">
				<xsl:with-param name="name">
					<xsl:text>.</xsl:text>
					<xsl:value-of select="@id" />
				</xsl:with-param>
				<xsl:with-param name="content">
					<xsl:call-template name="css.property">
						<xsl:with-param name="name">
							<xsl:text>-moz-binding</xsl:text>
						</xsl:with-param>
						<xsl:with-param name="value">
							<xsl:text>url("</xsl:text>
							<xsl:value-of select="$resourceURI" />
							<xsl:text>#</xsl:text>
							<xsl:value-of select="@id" />
							<xsl:text>")</xsl:text>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:value-of select="$str.endl" />
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>

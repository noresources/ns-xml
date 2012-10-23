<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->
<!-- Indicates if a XSLT stylesheet contains elements that can be processed using documentation-html.xsl. Return 'yes'
if something can be processed. Otherwise 'no' -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:import href="documentation-html.xsl"/>
	<xsl:output method="text" indent="yes" encoding="utf-8"/>
	<!-- Indicates if the stylesheet abstract have to be displayed -->
	<xsl:param name="xsl.doc.html.stylesheetAbstract" select="false()"/>
	<!-- Root -->
	<xsl:template match="/">
		<xsl:variable name="abstract">
			<xsl:call-template name="xsl.doc.html.comment">
				<xsl:with-param name="node" select="./xsl:stylesheet"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="displayAbstract" select="(($xsl.doc.html.stylesheetAbstract = true()) and (string-length($abstract) &gt; 0))"/>
		<xsl:variable name="hasContent" select="./xsl:stylesheet/xsl:template[@name] or ./xsl:stylesheet/xsl:param or ./xsl:stylesheet/xsl:variable"/>
		<xsl:choose>
			<xsl:when test="$displayAbstract or ($hasContent)">
				<xsl:text>yes</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>no</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="endl"/>
	</xsl:template>

</xsl:stylesheet>

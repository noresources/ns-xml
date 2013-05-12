<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Basic GNU Gengetopts elements -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:import href="../languages/base.xsl" />

	<!-- Comment block -->
	<xsl:template name="ggo.comment">
		<!-- Comment text -->
		<xsl:param name="content" select="." />
		<xsl:call-template name="code.comment">
			<xsl:with-param name="marker">
				<xsl:text># </xsl:text>
			</xsl:with-param>
			<xsl:with-param name="content" select="$content" />
		</xsl:call-template>
	</xsl:template>	
	
</xsl:stylesheet>
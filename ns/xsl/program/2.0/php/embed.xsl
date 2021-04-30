<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2018 - 2021 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!--  -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	
	<xsl:import href="parser.xsl" />
	<xsl:import href="programinfo.xsl" />
	
	<xsl:output method="text" encoding="utf-8" />

	<xsl:template match="/">
		<xsl:if test="$prg.php.phpmarkers">
			<xsl:text>&lt;?php</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>
		
		<xsl:call-template name="prg.php.base.output" />
		<xsl:call-template name="prg.php.programinfo.output" />
		
		<xsl:if test="$prg.php.phpmarkers">
			<xsl:text>?&gt;</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>
		
	</xsl:template>

</xsl:stylesheet>

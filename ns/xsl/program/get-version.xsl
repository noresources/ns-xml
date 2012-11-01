<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the BSD License, see LICENSE -->

<!-- Output the program interface definition schema version -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" version="1.0">
	<xsl:output method="text" encoding="utf-8"/>
	<xsl:template match="/prg:program">
		<xsl:value-of select="@version"/>
		<value-of select="'&#10;'"/>
	</xsl:template>

</xsl:stylesheet>

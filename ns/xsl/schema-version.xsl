<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!--
		Output the version of a given The target XML schema is expected to ends with
		the schema version number.

		Template inspired by https://stackoverflow.com/questions/3747049/xslt-how-to-get-a-list-of-all-used-namespaces
	-->
	<xsl:output method="text" />

	<xsl:param name="namespacePrefix" />
	<xsl:param name="defaultVersion" select="'1.0'" />

	<xsl:template name="trim">
		<xsl:param name="text" />
		<xsl:choose>
			<xsl:when test="starts-with ($text, '/')">
				<xsl:value-of select="substring($text, 2)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="/">
		<xsl:for-each select="//*/namespace::*[not(. = ../../namespace::*|preceding::*/namespace::*)]">
			<xsl:if test="starts-with (., $namespacePrefix)">
				<xsl:variable name="version">
					<xsl:call-template name="trim">
						<xsl:with-param name="text" select="substring (., string-length ($namespacePrefix) + 1)" />
					</xsl:call-template>
				</xsl:variable>

				<xsl:choose>
					<xsl:when test="string-length($version) = 0">
						<xsl:value-of select="concat($defaultVersion,'&#xA;')" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($version,'&#xA;')" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
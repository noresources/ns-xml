<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" xmlns:xul="http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul">

	<xsl:import href="./xul-ui-base.xsl" />

	<xsl:output method="xml" encoding="utf-8" indent="yes" />

	<xsl:template match="/">
		<xsl:processing-instruction name="xml-stylesheet">
			<xsl:text>type="text/css" href="chrome://global/skin/"</xsl:text>
		</xsl:processing-instruction>
		<xsl:call-template name="endl" />
		<xsl:processing-instruction name="xml-stylesheet">
			<xsl:text>type="text/css" href="chrome://</xsl:text>
			<xsl:value-of select="$prg.xul.appName" />
			<xsl:text>/content/</xsl:text>
			<xsl:value-of select="$prg.xul.appName" />
			<xsl:text>.css"</xsl:text>
		</xsl:processing-instruction>
		<xsl:call-template name="endl" />

		<xsl:processing-instruction name="xul-overlay">
			<xsl:text>href="chrome://</xsl:text>
			<xsl:value-of select="$prg.xul.appName" />
			<xsl:text>/content/</xsl:text>
			<xsl:value-of select="$prg.xul.appName" />
			<xsl:text>-overlay.xul"</xsl:text>
		</xsl:processing-instruction>
		<xsl:call-template name="endl" />

		<xsl:apply-templates select="prg:program" />
	</xsl:template>

	<xsl:template match="/prg:program">
		<xsl:element name="xul:window">
			<xsl:attribute name="id"><xsl:text>hiddenWindow</xsl:text></xsl:attribute>
			<xsl:attribute name="title"><xsl:call-template name="prg.programDisplayName" /></xsl:attribute>
			<xsl:attribute name="xmlns:xul" namespace="whatever">http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul</xsl:attribute>
			<xsl:attribute name="accelerated">true</xsl:attribute>

			<xsl:element name="xul:script"><![CDATA[
			Components.utils.import("chrome://]]><xsl:value-of select="$prg.xul.appName" /><![CDATA[/content/]]><xsl:value-of select="$prg.xul.appName" /><![CDATA[.jsm");  
			]]></xsl:element>

			<xsl:element name="xul:keyset">
				<xsl:attribute name="id">prg.ui.keyset</xsl:attribute>
			</xsl:element>
			<xsl:element name="xul:commandset">
				<xsl:attribute name="id">prg.ui.commandset</xsl:attribute>
			</xsl:element>
			<xsl:element name="xul:menubar">
				<xsl:attribute name="id">main-menubar</xsl:attribute>
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:stylesheet>

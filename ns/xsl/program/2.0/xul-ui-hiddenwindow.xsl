<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (c) 2011 by Renaud Guillard (dev@niao.fr) -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" xmlns:xul="http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul">

	<import href="./xul-ui-base.xsl" />

	<output method="xml" encoding="utf-8" indent="yes" />

	<strip-space elements="*" />

	<template match="/">
		<processing-instruction name="xml-stylesheet">
			<text>type="text/css" href="chrome://global/skin/"</text>
		</processing-instruction>
		<call-template name="endl" />
		<processing-instruction name="xml-stylesheet">
			<text>type="text/css" href="chrome://</text>
			<value-of select="$prg.xul.appName" />
			<text>/content/</text>
			<value-of select="$prg.xul.appName" />
			<text>.css"</text>
		</processing-instruction>
		<call-template name="endl" />

		<processing-instruction name="xul-overlay">
			<text>href="chrome://</text>
			<value-of select="$prg.xul.appName" />
			<text>/content/</text>
			<value-of select="$prg.xul.appName" />
			<text>-overlay.xul"</text>
		</processing-instruction>
		<call-template name="endl" />

		<apply-templates select="prg:program" />
	</template>

	<template match="/prg:program">
		<element name="xul:window">
			<attribute name="id"><text>hiddenWindow</text></attribute>
			<attribute name="title"><call-template name="prg.programDisplayName" /></attribute>
			<attribute name="xmlns:xul" namespace="whatever">http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul</attribute>
			<attribute name="accelerated">true</attribute>

			<element name="xul:script"><![CDATA[
			Components.utils.import("chrome://]]><value-of select="$prg.xul.appName" /><![CDATA[/content/]]><value-of select="$prg.xul.appName" /><![CDATA[.jsm");  
			]]></element>

			<element name="xul:keyset">
				<attribute name="id">prg.ui.keyset</attribute>
			</element>
			<element name="xul:commandset">
				<attribute name="id">prg.ui.commandset</attribute>
			</element>
			<element name="xul:menubar">
				<attribute name="id">prg.ui.mainMenubar</attribute>
			</element>

		</element>
	</template>

</stylesheet>

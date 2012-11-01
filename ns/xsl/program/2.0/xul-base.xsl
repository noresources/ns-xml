<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the BSD License, see LICENSE -->

<!-- Basic includes and parameter relative to XUL application generation -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">

	<import href="./base.xsl" />

	<!-- platform name ("linux" or "macosx") -->
	<param name="prg.xul.platform" />

	<param name="prg.xul.appName">
		<value-of select="/prg:program/prg:name" />
	</param>
	
	<param name="prg.xul.js.mainWindowInstanceName">
		<value-of select="$prg.xul.appName" /><text>MainWindow</text>
	</param>
	
	<param name="prg.xul.js.applicationInstanceName">
		<value-of select="$prg.xul.appName" /><text>Application</text>
	</param>

	<!-- Id for anonymous value command line parameters -->
	<template name="prg.xul.valueId">
		<param name="valueNode" select="." />
		<param name="index" />

		<variable name="grandParent" select="$valueNode/../.." />

		<text>VALUE_</text>
		<if test="$grandParent/self::prg:subcommand">
			<value-of select="$grandParent/prg:name" />
			<text>_</text>
		</if>
		<choose>
			<when test="$valueNode/self::prg:value">
				<value-of select="$index"></value-of>
			</when>
			<otherwise>
				<text>OTHER</text>
			</otherwise>
		</choose>
	</template>

</stylesheet>

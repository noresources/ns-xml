<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2013 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!--  -->
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:prg="http://xsd.nore.fr/program">
	<output method="text" encoding="utf-8" />

	<!-- Add php markers -->
	<param name="prg.php.phpmarkers" select="true()" />

	<!-- Set current namespace -->
	<param name="prg.php.programinfo.namespace" select="''" />

	<!-- PHP Parser base class namespace -->
	<param name="prg.php.parser.namespace" select="''" />

	<!-- Local item index -->
	<template name="prg.php.itemLocalIndex">
		<param name="itemNode" select="." />
		<param name="rootNode" select="$itemNode/.." />
		<for-each select="$rootNode/*">
			<if test="$itemNode = .">
				<value-of select="position() - 1" />
			</if>
		</for-each>
	</template>

	<!-- Canonical class name of the Parser base classes -->
	<template name="prg.php.base.classname">
		<param name="classname" />

		<text>\</text>
		<if test="string-length($prg.php.parser.namespace) &gt; 1 and ($prg.php.parser.namespace != '\')">
			<value-of select="$prg.php.parser.namespace" />
			<text>\</text>
		</if>
		<value-of select="$classname" />
	</template>
	
</stylesheet>

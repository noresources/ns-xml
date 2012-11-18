<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the BSD License, see LICENSE -->

<!-- Generate option parsing code for shell programs -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	<import href="parser.chunks.xsl" />
	<import href="parser.functions.xsl" />
	
	<output method="text" indent="no" encoding="utf-8" />
	
	<!-- Default behavior for 'standalone' program interface definition file -->
	<template match="/">
		<call-template name="prg.sh.parser.main">
			<with-param name="programNode" select="/prg:program" />
		</call-template>
	</template>
</stylesheet>
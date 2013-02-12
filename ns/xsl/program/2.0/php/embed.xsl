<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2013 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!--  -->
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:prg="http://xsd.nore.fr/program">
	
	<import href="parser.xsl" />
	<import href="programinfo.xsl" />
	
	<output method="text" encoding="utf-8" />

	<template match="/">
		<if test="$prg.php.phpmarkers">
			<text>&lt;?php</text>
			<value-of select="$str.endl" />
		</if>
		
		<call-template name="prg.php.base.output" />
		<call-template name="prg.php.programinfo.output" />
		
		<if test="$prg.php.phpmarkers">
			<text>?&gt;</text>
			<value-of select="$str.endl" />
		</if>
		
	</template>

</stylesheet>

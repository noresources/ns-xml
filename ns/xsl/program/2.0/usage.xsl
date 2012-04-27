<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->
<!-- Display help message for a command line program -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">

	<import href="usage.chunks.xsl" />
	
	<output method="text" indent="yes" encoding="utf-8" />
		
	<!-- Element templates -->
	<template match="comment()" />

	<template match="text()">
		<value-of select="normalize-space(.)" />
	</template>
	
	<template match="/prg:program">
		<call-template name="prg.help.programHelp" >
			<with-param name="programNode" select="/prg:program" />
		</call-template>		
	</template>
</stylesheet>

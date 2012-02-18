<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (c) 2011 by Renaud Guillard (dev@niao.fr) -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" xmlns:xul="http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul">

	<import href="./xul-base.xsl" />
	
	<variable name="prg.xul.availableSubcommands" select="/prg:program/prg:subcommands/prg:subcommand[not(prg:ui/@mode = 'disabled')]" />

	<template name="prg.xul.subCommandLabel">
		<param name="subcommandNode" select="." />
		<choose>
			<when test="$subcommandNode/prg:ui/prg:label">
				<value-of select="$subcommandNode/prg:ui/prg:label" />
			</when>
			<otherwise>
				<value-of select="prg:name" />
			</otherwise>
		</choose>
	</template>

</stylesheet>

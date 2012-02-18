<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (c) 2011 by Renaud Guillard (dev@niao.fr) -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:sh="http://xsd.nore.fr/bash">

	<output method="text" encoding="utf-8" />
	
	<strip-space elements="*" />

	<include href="shellscript.xsl" />

	<param name="bash.def.elementType" />
	<param name="bash.def.functionName" />

	<template match="sh:function">
		<if test="(not($bash.def.elementType) or ($bash.def.elementType = 'function')) and (not($bash.def.functionName) or ($bash.def.functionName = @name))">
			<call-template name="sh.functionDefinition">
				<with-param name="name" select="@name" />
				<with-param name="content">
					<for-each select="sh:parameter">
						<text>local </text>
						<value-of select="@name" />
						<text>=</text>
						<call-template name="sh.var">
							<with-param name="name" select="position()" />
							<with-param name="quoted" select="true()" />
						</call-template>
						<call-template name="unixEndl" />
					</for-each>
					<value-of select="sh:body" />
				</with-param>
			</call-template>
		</if>
	</template>

</stylesheet>
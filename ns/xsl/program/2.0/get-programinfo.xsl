<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (c) 2011 by Renaud Guillard (dev@niao.fr) -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	
	<output method="text" encoding="utf-8" />
	
	<strip-space elements="*" />
	
	<param name="name"></param>
	
	<template match="/prg:program">
		<choose>
			<when test="$name = 'name'">
				<value-of select="prg:name" />
			</when>
			<when test="$name = 'label'">
				<choose>
					<when test="prg:ui/prg:label">
						<value-of select="prg:ui/prg:label" />
					</when>
					<otherwise>
						<value-of select="prg:name" />
					</otherwise>
				</choose>
			</when>
			<when test="$name = 'author'">
				<value-of select="prg:author" />
			</when>
			<when test="$name = 'version'">
				<value-of select="prg:version" />
			</when>
		</choose>
		
		<text>&#10;</text>
	</template>
</stylesheet>

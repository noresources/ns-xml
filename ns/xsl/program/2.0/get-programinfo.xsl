<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Helper template to Retrieve program informations in scripts  -->
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" version="1.0">
	<output method="text" encoding="utf-8"/>
	<param name="name"/>
	<template match="/prg:program">
		<choose>
			<when test="$name = 'name'">
				<value-of select="normalize-space(prg:name)"/>
			</when>
			<when test="$name = 'label'">
				<choose>
					<when test="prg:ui/prg:label">
						<value-of select="normalize-space(prg:ui/prg:label)"/>
					</when>
					<otherwise>
						<value-of select="normalize-space(prg:name)"/>
					</otherwise>
				</choose>
			</when>
			<when test="$name = 'author'">
				<value-of select="normalize-space(prg:author)"/>
			</when>
			<when test="$name = 'version'">
				<value-of select="normalize-space(prg:version)"/>
			</when>
		</choose>
		<value-of select="'&#10;'"/>
	</template>

</stylesheet>

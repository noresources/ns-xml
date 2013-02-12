<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!--
	Mac OS X property list elements
	Documents which use these templates should set output as
	<output method="xml"
	doctype-system="http://www.apple.com/DTDs/PropertyList-1.0.dtd"
	doctype-public="-//Apple Computer//DTD PLIST 1.0//EN"
	encoding="utf-8" indent="yes" />
-->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform">

	<template name="plist.string">
		<param name="key" />
		<param name="value" />
		<element name="key">
			<value-of select="$key" />
		</element>
		<element name="string">
			<value-of select="$value" />
		</element>
	</template>

	<template name="plist.boolean">
		<param name="key" />
		<param name="value" select="false()" />
		<element name="key">
			<value-of select="$key" />
		</element>
		<choose>
			<when test="$value">
				<element name="true" />
			</when>
			<otherwise>
				<element name="false" />
			</otherwise>
		</choose>
	</template>

	<template name="plist.dict">
		<param name="content" />
		<element name="dict">
			<copy-of select="$content" />
		</element>
	</template>

	<template name="plist.document">
		<param name="content" />
		<param name="version">
			<text>1.0</text>
		</param>
		<element name="plist">
			<attribute name="version"><value-of select="$version" /></attribute>
			<call-template name="plist.dict">
				<with-param name="content" select="$content" />
			</call-template>
		</element>
	</template>

</stylesheet>

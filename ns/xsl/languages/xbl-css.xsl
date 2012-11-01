<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the BSD License, see LICENSE -->

<!-- Create CSS rules for XBL control bindings -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:xbl="http://www.mozilla.org/xbl">

	<import href="css.xsl" />

	<output method="text" encoding="utf-8" />
	
	<param name="xbl.css.displayHeader" select="false()" />

	<template match="/">
		<if test="$xbl.css.displayHeader">
			<text>@CHARSET "UTF-8";</text>
			<call-template name="endl" />
		</if>

		<for-each select="//xbl:binding">
			<call-template name="css.rule">
				<with-param name="name">
					<text>.</text>
					<value-of select="@id" />
				</with-param>
				<with-param name="content">
					<call-template name="css.property">
						<with-param name="name">
							<text>-moz-binding</text>
						</with-param>
						<with-param name="value">
							<text>url("</text>
							<value-of select="$resourceURI" />
							<text>#</text>
							<value-of select="@id" />
							<text>")</text>
						</with-param>
					</call-template>
				</with-param>
			</call-template>
			<call-template name="endl" />
		</for-each>
	</template>

</stylesheet>

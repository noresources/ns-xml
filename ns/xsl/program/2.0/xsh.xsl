<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->

<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" xmlns:sh="http://xsd.nore.fr/bash" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

	<import href="../../languages/bash.xsl" />
	<import href="usage.chunks.xsl" />
	<import href="sh-parser.chunks.xsl" />
	<import href="sh-parser.functions.xsl" />

	<output method="text" encoding="utf-8" />

	<param name="prg.xsh.defaultInterpreter">
		<text>/bin/bash</text>
	</param>
	<template match="/sh:program">
		<text>#!</text>
		<choose>
			<when test="./@interpreter">
				<value-of select="normalize-space(./@interpreter)" />
			</when>
			<otherwise>
				<value-of select="normalize-space($prg.xsh.defaultInterpreter)" />
			</otherwise>
		</choose>

		<call-template name="endl" />

		<choose>
			<when test="./sh:info">
				<if test="./sh:info/prg:program">
					<variable name="programNode" select="./sh:info/prg:program" />
					<if test="$programNode[prg:author|prg:version|prg:license|prg:documentation/prg:abstract]">
						<call-template name="sh.comment">
							<with-param name="content">
								<text>####################################</text>
								<call-template name="endl" />
								<if test="$programNode/prg:license">
									<value-of select="$programNode/prg:license" />
									<call-template name="endl" />
								</if>
								<if test="$programNode/prg:author">
									<text>Author: </text>
									<value-of select="$programNode/prg:author" />
									<call-template name="endl" />
								</if>
								<if test="$programNode/prg:version">
									<text>Version: </text>
									<value-of select="$programNode/prg:version" />
									<call-template name="endl" />
								</if>
								<if test="$programNode/prg:documentation/prg:abstract">
									<call-template name="endl" />
									<apply-templates select="$programNode/prg:documentation/prg:abstract" />
									<call-template name="endl" />
								</if>
							</with-param>
						</call-template>
					</if>
					<call-template name="sh.comment">
						<with-param name="content">
							<text>Program help</text>
						</with-param>
					</call-template>
					<call-template name="prg.help.programHelp">
						<with-param name="programNode" select="$programNode" />
					</call-template>
					<call-template name="endl" />
					<call-template name="sh.comment">
						<with-param name="content">
							<text>Program parameter parsing</text>
						</with-param>
					</call-template>
					<call-template name="prg.sh.parser.main">
						<with-param name="programNode" select="$programNode" />
					</call-template>
					<call-template name="endl" />
				</if>
			</when>
		</choose>

		<apply-templates select="./sh:functions" />

		<apply-templates select="./sh:code" />

	</template>

</stylesheet>
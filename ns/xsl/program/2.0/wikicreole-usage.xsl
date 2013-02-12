<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Generate a wiki page using the Creole syntax (http://www.wikicreole.org/) -->
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" version="1.0">
	<import href="../../languages/wikicreole.xsl"/>
	<import href="../../languages/wikicreole-extensions.xsl"/>
	<import href="usage.chunks.xsl"/>
	<output method="text" encoding="utf-8"/>
	<!-- <param name="prg.usage.indentChar" select="':'"/> -->
	<!-- <param name="prg.usage.lineMaxLength" select="40" /> -->
	<param name="prg.usage.creole.subcommandInlineUsageLabel">
		<text>subcommand [subcommand option(s)]</text>
	</param>
	<param name="prg.usage.creole.globalOptionsLabel">
		<text>Global options</text>
	</param>
	<param name="prg.usage.creole.subcommandOptionsLabel">
		<text>Subcommand options</text>
	</param>
	<param name="prg.usage.creole.subcommandsLabel">
		<text>Sub commands</text>
	</param>
	<param name="prg.usage.creole.aliasesLabel">
		<text>Aliases</text>
	</param>
	<template match="/prg:program">
		<call-template name="creole.heading">
			<with-param name="content" select="normalize-space(prg:name)"/>
		</call-template>
		<call-template name="endl"/>
		<call-template name="creole.italic">
			<with-param name="content" select="normalize-space(prg:documentation/prg:abstract)"/>
		</call-template>
		<call-template name="creole.simpleDefinition">
			<with-param name="title" select="$prg.usage.str.author"/>
			<with-param name="definition" select="normalize-space(prg:author)"/>
		</call-template>
		<call-template name="creole.simpleDefinition">
			<with-param name="title" select="$prg.usage.str.version"/>
			<with-param name="definition" select="normalize-space(prg:version)"/>
		</call-template>
		<call-template name="endl"/>
		<call-template name="creole.heading">
			<with-param name="level" select="2"/>
			<with-param name="content" select="$prg.usage.str.usage"/>
		</call-template>
		<!-- Inline usage -->
		<call-template name="endl"/>
		<call-template name="creole.pre">
			<with-param name="content">
				<call-template name="endl"/>
				<value-of select="normalize-space(prg:name)"/>
				<if test="prg:subcommands">
					<text> </text>
					<choose>
						<when test="$creole.support.anchor">
							<call-template name="creole.link">
								<with-param name="url">
									<text>#</text>
									<value-of select="$prg.usage.creole.subcommandsLabel"/>
								</with-param>
								<with-param name="label" select="$prg.usage.creole.subcommandInlineUsageLabel"/>
							</call-template>
						</when>
						<otherwise>
							<value-of select="$prg.usage.creole.subcommandInlineUsageLabel"/>
						</otherwise>
					</choose>
				</if>
				<if test="./prg:options">
					<text> </text>
					<call-template name="prg.usage.optionListInline">
						<with-param name="optionsNode" select="./prg:options"/>
						<with-param name="separator">
							<text> </text>
						</with-param>
					</call-template>
					<call-template name="endl"/>
				</if>
			</with-param>
		</call-template>
		<if test="./prg:options">
			<call-template name="creole.heading">
				<with-param name="level" select="3"/>
				<with-param name="content" select="$prg.usage.creole.globalOptionsLabel"/>
			</call-template>
			<call-template name="endl"/>
			<!-- Global option doc -->
			<call-template name="creole.pre">
				<with-param name="inline" select="false()"/>
				<with-param name="content">
					<call-template name="str.prependLine">
						<with-param name="prependedText" select="$prg.usage.indentChar"/>
						<with-param name="text">
							<call-template name="prg.usage.optionListDescription">
								<with-param name="optionsNode" select="./prg:options"/>
							</call-template>
						</with-param>
						<with-param name="wrap" select="$prg.usage.wrap"/>
						<with-param name="lineMaxLength" select="$prg.usage.lineMaxLength"/>
					</call-template>
				</with-param>
			</call-template>
		</if>
		<if test="./prg:subcommands">
			<call-template name="creole.heading">
				<with-param name="level" select="3"/>
				<with-param name="content" select="$prg.usage.creole.subcommandsLabel"/>
			</call-template>
			<for-each select="./prg:subcommands/prg:subcommand">
				<call-template name="creole.heading">
					<with-param name="level" select="4"/>
					<with-param name="content" select="./prg:name"/>
				</call-template>
				<call-template name="endl"/>
				<call-template name="creole.italic">
					<with-param name="content" select="prg:documentation/prg:abstract"/>
				</call-template>
				<if test="prg:aliases">
					<call-template name="creole.definitionTitle">
						<with-param name="content" select="$prg.usage.creole.aliasesLabel"/>
					</call-template>
					<for-each select="prg:aliases/prg:alias">
						<call-template name="creole.definition"/>
					</for-each>
				</if>
				<if test="prg:options">
					<call-template name="creole.heading">
						<with-param name="content" select="$prg.usage.str.usage"/>
						<with-param name="level" select="5"/>
					</call-template>
					<!-- Inline usage -->
					<call-template name="creole.pre">
						<with-param name="inline" select="false()"/>
						<with-param name="content">
							<value-of select="normalize-space(../../prg:name)"/>
							<text> </text>
							<value-of select="normalize-space(prg:name)"/>
							<text> </text>
							<call-template name="prg.usage.optionListInline">
								<with-param name="optionsNode" select="./prg:options"/>
								<with-param name="separator">
									<text> </text>
								</with-param>
							</call-template>
						</with-param>
					</call-template>
					<!-- Details usage (@todo nicer display) -->
					<!-- <call-template name="prg.usage.optionListDescription"> <with-param 
						name="optionsNode" select="./prg:options" /> </call-template> -->
					<call-template name="creole.pre">
						<with-param name="inline" select="false()"/>
						<with-param name="content">
							<call-template name="str.prependLine">
								<with-param name="prependedText" select="$prg.usage.indentChar"/>
								<with-param name="text">
									<call-template name="prg.usage.optionListDescription">
										<with-param name="optionsNode" select="./prg:options"/>
									</call-template>
								</with-param>
								<with-param name="wrap" select="$prg.usage.wrap"/>
								<with-param name="lineMaxLength" select="$prg.usage.lineMaxLength"/>
							</call-template>
						</with-param>
					</call-template>
				</if>
			</for-each>
		</if>
		<if test="prg:copyright|prg:license">
			<call-template name="creole.heading">
				<with-param name="content" select="'Copyright &amp; Licensing'"/>
			</call-template>
			<call-template name="endl"/>
			<if test="prg:copyright">
				<call-template name="creole.italic">
					<with-param name="content">
						<apply-templates select="prg:copyright"/>
					</with-param>
				</call-template>
				<call-template name="endl"/>
				<call-template name="endl"/>
			</if>
			<if test="prg:license">
				<call-template name="creole.italic">
					<with-param name="content">
						<apply-templates select="prg:license"/>
					</with-param>
				</call-template>
				<call-template name="endl"/>
				<call-template name="endl"/>
			</if>
		</if>
	</template>

	<template match="/">
		<apply-templates select="/prg:program"/>
	</template>

</stylesheet>

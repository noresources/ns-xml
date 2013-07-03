<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Generate a wiki page using the Creole syntax (http://www.wikicreole.org/) -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	<xsl:import href="../../languages/wikicreole.xsl" />
	<xsl:import href="../../languages/wikicreole-extensions.xsl" />
	<xsl:import href="usage.chunks.xsl" />
	<xsl:output method="text" encoding="utf-8" />
	<!-- <param name="prg.usage.indentChar" select="':'"/> -->
	<!-- <param name="prg.usage.lineMaxLength" select="40" /> -->
	<xsl:param name="prg.usage.creole.subcommandInlineUsageLabel">
		<xsl:text>subcommand [subcommand option(s)]</xsl:text>
	</xsl:param>
	<xsl:param name="prg.usage.creole.globalOptionsLabel">
		<xsl:text>Global options</xsl:text>
	</xsl:param>
	<xsl:param name="prg.usage.creole.subcommandOptionsLabel">
		<xsl:text>Subcommand options</xsl:text>
	</xsl:param>
	<xsl:param name="prg.usage.creole.subcommandsLabel">
		<xsl:text>Sub commands</xsl:text>
	</xsl:param>
	<xsl:param name="prg.usage.creole.aliasesLabel">
		<xsl:text>Aliases</xsl:text>
	</xsl:param>
	<xsl:template match="/prg:program">
		<xsl:call-template name="creole.heading">
			<xsl:with-param name="content" select="normalize-space(prg:name)" />
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />
		<xsl:call-template name="creole.italic">
			<xsl:with-param name="content" select="normalize-space(prg:documentation/prg:abstract)" />
		</xsl:call-template>
		<xsl:call-template name="creole.simpleDefinition">
			<xsl:with-param name="title" select="$prg.usage.str.author" />
			<xsl:with-param name="definition" select="normalize-space(prg:author)" />
		</xsl:call-template>
		<xsl:call-template name="creole.simpleDefinition">
			<xsl:with-param name="title" select="$prg.usage.str.version" />
			<xsl:with-param name="definition" select="normalize-space(prg:version)" />
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />
		<xsl:call-template name="creole.heading">
			<xsl:with-param name="level" select="2" />
			<xsl:with-param name="content" select="$prg.usage.str.usage" />
		</xsl:call-template>
		<!-- Inline usage -->
		<xsl:value-of select="$str.endl" />
		<xsl:call-template name="creole.pre">
			<xsl:with-param name="content">
				<xsl:value-of select="$str.endl" />
				<xsl:value-of select="normalize-space(prg:name)" />
				<xsl:if test="prg:subcommands">
					<xsl:text> </xsl:text>
					<xsl:choose>
						<xsl:when test="$creole.support.anchor">
							<xsl:call-template name="creole.link">
								<xsl:with-param name="url">
									<xsl:text>#</xsl:text>
									<xsl:value-of select="$prg.usage.creole.subcommandsLabel" />
								</xsl:with-param>
								<xsl:with-param name="label" select="$prg.usage.creole.subcommandInlineUsageLabel" />
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$prg.usage.creole.subcommandInlineUsageLabel" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<xsl:if test="./prg:options">
					<xsl:text> </xsl:text>
					<xsl:call-template name="prg.usage.optionListInline">
						<xsl:with-param name="optionsNode" select="./prg:options" />
						<xsl:with-param name="separator">
							<xsl:text> </xsl:text>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:value-of select="$str.endl" />
				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:if test="./prg:options">
			<xsl:call-template name="creole.heading">
				<xsl:with-param name="level" select="3" />
				<xsl:with-param name="content" select="$prg.usage.creole.globalOptionsLabel" />
			</xsl:call-template>
			<xsl:value-of select="$str.endl" />
			<!-- Global option doc -->
			<xsl:call-template name="creole.pre">
				<xsl:with-param name="inline" select="false()" />
				<xsl:with-param name="content">
					<xsl:call-template name="str.prependLine">
						<xsl:with-param name="prependedText" select="$prg.usage.indentChar" />
						<xsl:with-param name="text">
							<xsl:call-template name="prg.usage.optionListDescription">
								<xsl:with-param name="optionsNode" select="./prg:options" />
							</xsl:call-template>
						</xsl:with-param>
						<xsl:with-param name="wrap" select="$prg.usage.wrap" />
						<xsl:with-param name="lineMaxLength" select="$prg.usage.lineMaxLength" />
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="./prg:subcommands">
			<xsl:call-template name="creole.heading">
				<xsl:with-param name="level" select="3" />
				<xsl:with-param name="content" select="$prg.usage.creole.subcommandsLabel" />
			</xsl:call-template>
			<xsl:for-each select="./prg:subcommands/prg:subcommand">
				<xsl:call-template name="creole.heading">
					<xsl:with-param name="level" select="4" />
					<xsl:with-param name="content" select="./prg:name" />
				</xsl:call-template>
				<xsl:value-of select="$str.endl" />
				<xsl:call-template name="creole.italic">
					<xsl:with-param name="content" select="prg:documentation/prg:abstract" />
				</xsl:call-template>
				<xsl:if test="prg:aliases">
					<xsl:call-template name="creole.definitionTitle">
						<xsl:with-param name="content" select="$prg.usage.creole.aliasesLabel" />
					</xsl:call-template>
					<xsl:for-each select="prg:aliases/prg:alias">
						<xsl:call-template name="creole.definition" />
					</xsl:for-each>
				</xsl:if>
				<xsl:if test="prg:options">
					<xsl:call-template name="creole.heading">
						<xsl:with-param name="content" select="$prg.usage.str.usage" />
						<xsl:with-param name="level" select="5" />
					</xsl:call-template>
					<!-- Inline usage -->
					<xsl:call-template name="creole.pre">
						<xsl:with-param name="inline" select="false()" />
						<xsl:with-param name="content">
							<xsl:value-of select="normalize-space(../../prg:name)" />
							<xsl:text> </xsl:text>
							<xsl:value-of select="normalize-space(prg:name)" />
							<xsl:text> </xsl:text>
							<xsl:call-template name="prg.usage.optionListInline">
								<xsl:with-param name="optionsNode" select="./prg:options" />
								<xsl:with-param name="separator">
									<xsl:text> </xsl:text>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
					<!-- Details usage (@todo nicer display) -->
					<!-- <call-template name="prg.usage.optionListDescription"> <with-param 
						name="optionsNode" select="./prg:options" /> </call-template> -->
					<xsl:call-template name="creole.pre">
						<xsl:with-param name="inline" select="false()" />
						<xsl:with-param name="content">
							<xsl:call-template name="str.prependLine">
								<xsl:with-param name="prependedText" select="$prg.usage.indentChar" />
								<xsl:with-param name="text">
									<xsl:call-template name="prg.usage.optionListDescription">
										<xsl:with-param name="optionsNode" select="./prg:options" />
									</xsl:call-template>
								</xsl:with-param>
								<xsl:with-param name="wrap" select="$prg.usage.wrap" />
								<xsl:with-param name="lineMaxLength" select="$prg.usage.lineMaxLength" />
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="prg:copyright|prg:license">
			<xsl:call-template name="creole.heading">
				<xsl:with-param name="content" select="'Copyright &amp; Licensing'" />
			</xsl:call-template>
			<xsl:value-of select="$str.endl" />
			<xsl:if test="prg:copyright">
				<xsl:call-template name="creole.italic">
					<xsl:with-param name="content">
						<xsl:apply-templates select="prg:copyright" />
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$str.endl" />
				<xsl:value-of select="$str.endl" />
			</xsl:if>
			<xsl:if test="prg:license">
				<xsl:call-template name="creole.italic">
					<xsl:with-param name="content">
						<xsl:apply-templates select="prg:license" />
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$str.endl" />
				<xsl:value-of select="$str.endl" />
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/">
		<xsl:apply-templates select="/prg:program" />
	</xsl:template>

</xsl:stylesheet>

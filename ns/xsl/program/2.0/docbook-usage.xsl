<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Generate a wiki page using the Creole syntaxe (http://www.wikicreole.org/) -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" xmlns:db="http://docbook.org/ns/docbook" version="1.0">
	<xsl:import href="usage.chunks.xsl" />
	<xsl:output method="xml" encoding="utf-8" indent="yes" />
	<xsl:template name="prg.usage.docbook.optionsDescription">
		<xsl:param name="optionsNode" select="." />
		<xsl:if test="$optionsNode/*">
			<xsl:element name="db:itemizedlist">
				<xsl:for-each select="$optionsNode/*">
					<xsl:element name="db:listitem">
						<xsl:call-template name="prg.usage.docbook.optionDescription">
							<xsl:with-param name="optionNode" select="." />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template name="prg.usage.docbook.optionDescription">
		<xsl:param name="optionNode" select="." />
		<xsl:element name="db:para">
			<xsl:element name="db:code">
				<xsl:call-template name="prg.usage.allOptionNameDisplay" />
			</xsl:element>
			<xsl:if test="./prg:names and ./prg:documentation/prg:abstract">
				<xsl:text>: </xsl:text>
			</xsl:if>
			<xsl:apply-templates select="./prg:documentation/prg:abstract" />
			<xsl:choose>
				<xsl:when test="$optionNode/self::prg:switch">
					<xsl:call-template name="prg.usage.docbook.switchDescription" />
				</xsl:when>
				<xsl:when test="$optionNode/self::prg:argument or $optionNode/self::prg:multiargument">
					<xsl:call-template name="prg.usage.docbook.argumentDescription" />
				</xsl:when>
				<xsl:when test="$optionNode/self::prg:group">
					<xsl:call-template name="prg.usage.docbook.optionsDescription">
						<xsl:with-param name="optionsNode" select="$optionNode/prg:options" />
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

	<xsl:template name="prg.usage.docbook.switchDescription">
		<xsl:param name="optionNode" select="." />
		<xsl:if test="$optionNode/prg:documentation/prg:details">
			<xsl:element name="db:blockquote">
				<xsl:element name="db:para">
					<xsl:apply-templates select="$optionNode/prg:documentation/prg:details" />
				</xsl:element>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template name="prg.usage.docbook.argumentDescription">
		<xsl:param name="optionNode" select="." />
		<xsl:if test="$optionNode/prg:documentation/prg:details or $optionNode/prg:default or $optionNode/prg:select or $optionNode/@min or $optionNode/@max">
			<xsl:element name="db:blockquote">
				<xsl:if test="$optionNode/prg:documentation/prg:details">
					<xsl:element name="db:para">
						<xsl:apply-templates select="$optionNode/prg:documentation/prg:details" />
					</xsl:element>
				</xsl:if>
				<xsl:if test="$optionNode/prg:select">
					<xsl:element name="db:para">
						<xsl:choose>
							<xsl:when test="$optionNode/prg:select/@restrict">
								<xsl:value-of select="$prg.usage.str.argumentValueSelect" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$prg.usage.str.argumentValueSelectRestricted" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
					<xsl:element name="db:blockquote">
						<xsl:call-template name="prg.usage.selectValueList">
							<xsl:with-param name="mode" select="'inline'" />
							<xsl:with-param name="optionNode" select="$optionNode/prg:select" />
						</xsl:call-template>
					</xsl:element>
				</xsl:if>
				<xsl:if test="$optionNode/prg:default">
					<xsl:element name="db:para">
						<xsl:value-of select="$prg.usage.str.defaultValue" />
						<xsl:call-template name="sh.escapeLiteral">
							<xsl:with-param name="value" select="$optionNode/prg:default" />
							<xsl:with-param name="quoteChar" select="'&quot;'" />
							<xsl:with-param name="evaluate" select="false()" />
						</xsl:call-template>
					</xsl:element>
				</xsl:if>
				<xsl:if test="$optionNode/@min">
					<xsl:element name="db:para">
						<xsl:value-of select="$prg.usage.str.minArgumentCount" />
						<xsl:value-of select="$optionNode/@min" />
					</xsl:element>
				</xsl:if>
				<xsl:if test="$optionNode/@max">
					<xsl:element name="db:para">
						<xsl:value-of select="$prg.usage.str.maxArgumentCount" />
						<xsl:value-of select="$optionNode/@max" />
					</xsl:element>
				</xsl:if>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template match="prg:br | prg:endl">
		<xsl:element name="db:para" />
	</xsl:template>

	<xsl:template match="prg:block">
		<xsl:element name="db:blockquote">
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>

	<xsl:template match="/prg:program">
		<xsl:variable name="programNode" select="." />
		<xsl:element name="db:article">
			<xsl:attribute name="xmlns:db" namespace="http://docbook.org/ns/docbook">http://docbook.org/ns/docbook</xsl:attribute>
			<xsl:element name="db:info">
				<xsl:element name="db:title">
					<xsl:value-of select="./prg:name" />
				</xsl:element>
				<xsl:element name="db:application">
					<xsl:value-of select="./prg:name" />
				</xsl:element>
				<xsl:if test="./prg:documentation/prg:abstract">
					<xsl:element name="db:abstract">
						<xsl:apply-templates select="./prg:documentation/prg:abstract" />
					</xsl:element>
				</xsl:if>
				<xsl:if test="./prg:author">
					<xsl:element name="db:author">
						<xsl:value-of select="./prg:author" />
					</xsl:element>
				</xsl:if>
				<xsl:if test="./prg:version">

				</xsl:if>
			</xsl:element>
			<!-- Short program options -->
			<xsl:element name="db:para">
				<xsl:element name="db:computeroutput">
					<xsl:value-of select="./prg:name" />
					<xsl:text> </xsl:text>
					<xsl:if test="./prg:subcommands">
						<xsl:text>[</xsl:text>
						<xsl:for-each select="./prg:subcommands/prg:subcommand">
							<xsl:value-of select="./prg:name" />
							<xsl:if test="position() != last()">
								<xsl:text>|</xsl:text>
							</xsl:if>
						</xsl:for-each>
						<xsl:text>] </xsl:text>
					</xsl:if>
					<xsl:call-template name="prg.usage.optionListInline">
						<xsl:with-param name="optionsNode" select="./prg:options" />
						<xsl:with-param name="separator" select="' '" />
					</xsl:call-template>
				</xsl:element>
			</xsl:element>
			<xsl:element name="db:section">
				<xsl:element name="db:title">
					<xsl:value-of select="$prg.usage.str.programOptions" />
				</xsl:element>
				<xsl:element name="db:para">
					<xsl:call-template name="prg.usage.docbook.optionsDescription">
						<xsl:with-param name="optionsNode" select="./prg:options" />
					</xsl:call-template>
				</xsl:element>
			</xsl:element>
			<!-- Program Details -->
			<xsl:if test="./prg:documentation/prg:details">
				<xsl:element name="db:section">
					<xsl:element name="db:title">
						<xsl:value-of select="$prg.usage.str.details" />
					</xsl:element>
					<xsl:element name="db:para">
						<xsl:apply-templates select="././prg:documentation/prg:details" />
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Subcommands -->
			<xsl:if test="./prg:subcommands/prg:subcommand">
				<xsl:element name="db:section">
					<xsl:element name="db:title">
						<xsl:value-of select="$prg.usage.str.subcommands" />
					</xsl:element>
					<xsl:element name="db:para">
						<xsl:for-each select="./prg:subcommands/prg:subcommand">
							<xsl:element name="db:section">
								<xsl:element name="db:info">
									<xsl:element name="db:title">
										<xsl:value-of select="./prg:name" />
									</xsl:element>
									<xsl:if test="./prg:documentation/prg:abstract">
										<xsl:element name="db:abstract">
											<xsl:value-of select="./prg:documentation/prg:abstract" />
										</xsl:element>
									</xsl:if>
								</xsl:element>
								<!-- inline args -->
								<xsl:element name="db:para">
									<xsl:element name="db:programlisting">
										<xsl:value-of select="$programNode/prg:name" />
										<xsl:text> </xsl:text>
										<xsl:value-of select="./prg:name" />
										<xsl:text> </xsl:text>
										<xsl:call-template name="prg.usage.optionListInline">
											<xsl:with-param name="optionsNode" select="./prg:options" />
											<xsl:with-param name="separator" select="' '" />
										</xsl:call-template>
									</xsl:element>
								</xsl:element>
								<!-- options doc -->
								<xsl:if test="./prg:options">
									<xsl:element name="db:section">
										<xsl:element name="db:title">
											<xsl:value-of select="$prg.usage.str.subcommandOptions" />
										</xsl:element>
										<xsl:element name="db:para">
											<xsl:call-template name="prg.usage.docbook.optionsDescription">
												<xsl:with-param name="optionsNode" select="./prg:options" />
											</xsl:call-template>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<!-- Subcommand details -->
								<xsl:if test="./prg:documentation/prg:details">
									<xsl:element name="db:section">
										<xsl:element name="db:title">
											<xsl:value-of select="$prg.usage.str.details" />
										</xsl:element>
										<xsl:element name="db:para">
											<xsl:apply-templates select="././prg:documentation/prg:details" />
										</xsl:element>
									</xsl:element>
								</xsl:if>
							</xsl:element>
						</xsl:for-each>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- License & copyright -->
			<xsl:if test="./prg:copyright">
				<xsl:element name="db:section">
					<xsl:element name="db:title">
						<xsl:value-of select="$prg.usage.str.copyright" />
					</xsl:element>
					<xsl:element name="db:para">
						<xsl:apply-templates select="./prg:copyright" />
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:if test="./prg:license">
				<xsl:element name="db:section">
					<xsl:element name="db:title">
						<xsl:value-of select="$prg.usage.str.license" />
					</xsl:element>
					<xsl:element name="db:para">
						<xsl:apply-templates select="./prg:license" />
					</xsl:element>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>

</xsl:stylesheet>

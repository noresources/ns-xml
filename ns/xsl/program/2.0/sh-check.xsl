<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the BSD License, see LICENSE -->

<!-- Create a self test to check several issues that can't be checked using xml schema -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">

	<xsl:import href="../../languages/shellscript.xsl" />
	
	<xsl:output method="text" indent="yes" encoding="utf-8" />
	
	<xsl:template match="/prg:program">
		<xsl:text># Check option consitency</xsl:text>
		<xsl:call-template name="endl" />
		<xsl:text>global_switches="</xsl:text>
		<xsl:for-each select="./prg:options//prg:switch/prg:names/prg:short">
			<xsl:value-of select="." />
			<xsl:text> </xsl:text>
		</xsl:for-each>
		<xsl:for-each select="./prg:options//prg:switch/prg:names/prg:long">
			<xsl:value-of select="." />
			<xsl:text> </xsl:text>
		</xsl:for-each>
		<xsl:text>"</xsl:text>

		<xsl:variable name="hasGlobalSwitches" select="(./prg:options//prg:switch/prg:names/prg:long or ./prg:options//prg:switch/prg:names/prg:short)" />

		<xsl:variable name="hasGlobalArgs" select="(./prg:options//prg:argument/prg:names/prg:long or ./prg:options//prg:argument/prg:names/prg:short or ./prg:options//prg:multiargument/prg:names/prg:long or ./prg:options//prg:multiargument/prg:names/prg:short)" />

		<xsl:call-template name="endl" />
		<xsl:text>global_args="</xsl:text>
		<xsl:for-each select="./prg:options//prg:argument/prg:names/prg:short">
			<xsl:value-of select="." />
			<xsl:text> </xsl:text>
		</xsl:for-each>
		<xsl:for-each select="./prg:options//prg:multiargument/prg:names/prg:short">
			<xsl:value-of select="." />
			<xsl:text> </xsl:text>
		</xsl:for-each>
		<xsl:for-each select="./prg:options//prg:argument/prg:names/prg:long">
			<xsl:value-of select="." />
			<xsl:text> </xsl:text>
		</xsl:for-each>
		<xsl:for-each select="./prg:options//prg:multiargument/prg:names/prg:long">
			<xsl:value-of select="." />
			<xsl:text> </xsl:text>
		</xsl:for-each>
		<xsl:text>"</xsl:text>

		<xsl:call-template name="endl" />

		<xsl:for-each select="prg:subcommands/prg:subcommand">
			<xsl:text>#Checking </xsl:text>
			<xsl:value-of select="prg:name" />
			<xsl:call-template name="endl" />

			<xsl:if test="$hasGlobalArgs and (./prg:options//prg:switch/prg:names/prg:long or ./prg:options//prg:switch/prg:names/prg:long)">
				<xsl:text># Check subcommand switches against global arg-like options</xsl:text>
				<xsl:call-template name="endl" />
				<xsl:call-template name="prg.sh.check.checkSubCommandOptions">
					<xsl:with-param name="scname">
						<xsl:value-of select="prg:name" />
					</xsl:with-param>
					<xsl:with-param name="goptions">
						<xsl:text>${global_args}</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="scoptions">
						<xsl:for-each select="prg:options//prg:switch/prg:names/prg:short">
							<xsl:value-of select="." />
							<xsl:text> </xsl:text>
						</xsl:for-each>
						<xsl:for-each select="prg:options//prg:switch/prg:names/prg:long">
							<xsl:value-of select="." />
							<xsl:text> </xsl:text>
						</xsl:for-each>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<xsl:if test="$hasGlobalSwitches and (./prg:options//prg:argument/prg:names/prg:long or ./prg:options//prg:argument/prg:names/prg:short or ./prg:options//prg:multiargument/prg:names/prg:long or ./prg:options//prg:multiargument/prg:names/prg:short)">
				<xsl:text># Check subcommand arg-like options against global switches options</xsl:text>
				<xsl:call-template name="endl" />
				<xsl:call-template name="prg.sh.check.checkSubCommandOptions">
					<xsl:with-param name="scname">
						<xsl:value-of select="prg:name" />
					</xsl:with-param>
					<xsl:with-param name="goptions">
						<xsl:text>${global_switches}</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="scoptions">
						<xsl:for-each select="prg:options//prg:argument/prg:names/prg:short">
							<xsl:value-of select="." />
							<xsl:text> </xsl:text>
						</xsl:for-each>
						<xsl:for-each select="prg:options//prg:argument/prg:names/prg:long">
							<xsl:value-of select="." />
							<xsl:text> </xsl:text>
						</xsl:for-each>
						<xsl:for-each select="prg:options//prg:multiargument/prg:names/prg:short">
							<xsl:value-of select="." />
							<xsl:text> </xsl:text>
						</xsl:for-each>
						<xsl:for-each select="prg:options//prg:multiargument/prg:names/prg:long">
							<xsl:value-of select="." />
							<xsl:text> </xsl:text>
						</xsl:for-each>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
		<xsl:call-template name="endl" />
		<xsl:text>exit 0</xsl:text>
	</xsl:template>

	<xsl:template name="prg.sh.check.checkSubCommandOptions">
		<xsl:param name="scname" />
		<xsl:param name="scoptions" />
		<xsl:param name="goptions" />
		<xsl:call-template name="sh.for">
			<xsl:with-param name="condition">
				<xsl:text>sco in </xsl:text>
				<xsl:value-of select="$scoptions" />
			</xsl:with-param>
			<xsl:with-param name="do">
				<xsl:call-template name="sh.for">
					<xsl:with-param name="condition">
						<xsl:text>go in </xsl:text>
						<xsl:value-of select="$goptions" />
					</xsl:with-param>
					<xsl:with-param name="do">
						<xsl:call-template name="sh.if">
							<xsl:with-param name="condition">
								<prg:text>[ "${sco}" = "${go}" ]</prg:text>
							</xsl:with-param>
							<xsl:with-param name="then">
								<xsl:text>echo "Type conflict for option \"${sco}\" between \"</xsl:text>
								<xsl:value-of select="$scname" />
								<xsl:text>\" subcommand and globals - switch-type/arg-like mismatch"</xsl:text>
								<xsl:call-template name="endl" />
								<xsl:text>exit 1</xsl:text>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="endl" />
	</xsl:template>

</xsl:stylesheet>

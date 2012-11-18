<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the BSD License, see LICENSE -->

<!-- Build a shell script by combining program option parsing & usage from the XML program interface definition schema
	and shell code and functions from the XSH schema
	(hhe old bash scheam is still supported) -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" xmlns:bash="http://xsd.nore.fr/bash" xmlns:xsh="http://xsd.nore.fr/xsh">

	<xsl:import href="../../languages/bash.xsl" />
	<xsl:import href="../../languages/xsh.xsl" />
	<xsl:import href="sh/parser.chunks.xsl" />
	<xsl:import href="sh/parser.functions.xsl" />
	<xsl:import href="sh/usage.chunks.xsl" />

	<xsl:output method="text" encoding="utf-8" />

	<!-- Unix shell interpreter directive. 
		If neither prg.xsh.defaultInterpreterCommand nor
		xsh.defaultInterpreterType are defined, use '/usr/bin/env bash'.
		If xsh.defaultInterpreterType is defined, use '/usr/bin/env <type>'
	-->
	<xsl:param name="prg.xsh.defaultInterpreterCommand" />
	
	<!-- Help string -->
	<xsl:template name="prg.sh.usage.programUsage">
		<xsl:param name="programNode" select="." />
		<xsl:param name="interpreter" />

		<!-- Usage function -->
		<xsl:call-template name="sh.functionDefinition">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.usage.usageFunctionName" />
			</xsl:with-param>
			<xsl:with-param name="interpreter" select="$interpreter" />
			<xsl:with-param name="indent" select="false()" />
			<xsl:with-param name="content">
				<xsl:if test="$programNode/prg:subcommands">
					<xsl:call-template name="sh.if">
						<xsl:with-param name="indent" select="false()" />
						<xsl:with-param name="condition">
							<xsl:text>[ ! -z "${1}" ]</xsl:text>
						</xsl:with-param>
						<xsl:with-param name="then">
							<xsl:call-template name="sh.case">
								<xsl:with-param name="indent" select="false()" />
								<xsl:with-param name="case">
									<xsl:call-template name="sh.var">
										<xsl:with-param name="name" select="1" />
									</xsl:call-template>
								</xsl:with-param>
								<xsl:with-param name="in">
									<xsl:for-each select="$programNode/prg:subcommands/*">
										<xsl:call-template name="sh.caseblock">
											<xsl:with-param name="indent" select="false()" />
											<xsl:with-param name="case">
												<xsl:value-of select="normalize-space(./prg:name)" />
												<xsl:for-each select="./prg:aliases/prg:alias">
													<xsl:text> | </xsl:text>
													<xsl:value-of select="normalize-space(.)" />
												</xsl:for-each>
											</xsl:with-param>
											<xsl:with-param name="content">
												<xsl:text>cat &lt;&lt; EOFSCUSAGE</xsl:text>
												<xsl:value-of select="$sh.endl" />
												<xsl:value-of select="normalize-space(./prg:name)" />
												<xsl:text>: </xsl:text>
												<xsl:call-template name="prg.usage.descriptionDisplay">
													<xsl:with-param name="textNode" select="./prg:documentation/prg:abstract" />
												</xsl:call-template>
												<xsl:value-of select="$sh.endl" />
												<xsl:text>Usage: </xsl:text>
												<xsl:value-of select="normalize-space(../../prg:name)" />
												<xsl:text> </xsl:text>
												<xsl:value-of select="normalize-space(./prg:name)" />
												<xsl:if test="./prg:options">
													<xsl:text> </xsl:text>
													<xsl:call-template name="prg.usage.optionListInline">
														<xsl:with-param name="optionsNode" select="./prg:options" />
														<xsl:with-param name="separator">
															<xsl:text> </xsl:text>
														</xsl:with-param>
													</xsl:call-template>
													<xsl:value-of select="$sh.endl" />
													<xsl:text>With</xsl:text>
													<xsl:text>:</xsl:text>
													<xsl:call-template name="code.block">
														<xsl:with-param name="indentChar" select="$prg.sh.usage.indentChar" />
														<xsl:with-param name="addFinalEndl" select="false()" />
														<xsl:with-param name="content">
															<xsl:call-template name="prg.usage.optionListDescription">
																<xsl:with-param name="optionsNode" select="./prg:options" />
															</xsl:call-template>
															<!-- Program documentation & details -->
															<xsl:if test="./prg:documentation/prg:details">
																<xsl:call-template name="code.block">
																	<xsl:with-param name="indentChar" select="$prg.sh.usage.indentChar" />
																	<xsl:with-param name="addFinalEndl" select="false()" />
																	<xsl:with-param name="content">
																		<xsl:apply-templates select="./prg:documentation/prg:details" />
																	</xsl:with-param>
																</xsl:call-template>
															</xsl:if>
														</xsl:with-param>
													</xsl:call-template>
												</xsl:if>
												<xsl:value-of select="$sh.endl" />
												<xsl:text>EOFSCUSAGE</xsl:text>
											</xsl:with-param>
										</xsl:call-template>
									</xsl:for-each>
								</xsl:with-param>
							</xsl:call-template>
							<xsl:value-of select="$sh.endl" />
							<xsl:text>return 0</xsl:text>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
				<xsl:text>cat &lt;&lt; EOFUSAGE</xsl:text>
				<xsl:value-of select="$sh.endl" />
				<xsl:value-of select="normalize-space($programNode/prg:name)" />
				<xsl:text>: </xsl:text>
				<!-- Program description -->
				<xsl:call-template name="prg.usage.descriptionDisplay">
					<xsl:with-param name="textNode" select="$programNode/prg:documentation/prg:abstract" />
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />
				<xsl:text>Usage: </xsl:text>
				<xsl:call-template name="code.block">
					<xsl:with-param name="indentChar" select="$prg.sh.usage.indentChar" />
					<xsl:with-param name="content">
						<xsl:value-of select="normalize-space($programNode/prg:name)" />
						<xsl:if test="$programNode/prg:subcommands">
							<xsl:text> &lt;subcommand [subcommand option(s)]&gt;</xsl:text>
						</xsl:if>
						<!-- Inline options list + description of each option -->
						<xsl:if test="$programNode/prg:options">
							<xsl:text> </xsl:text>
							<xsl:call-template name="prg.usage.optionListInline">
								<xsl:with-param name="optionsNode" select="$programNode/prg:options" />
								<xsl:with-param name="separator">
									<xsl:text> </xsl:text>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:if>
						<!-- subcommands descriptions -->
						<xsl:if test="$programNode/prg:subcommands">
							<xsl:value-of select="$sh.endl" />
							<xsl:text>With subcommand:</xsl:text>
							<xsl:call-template name="code.block">
								<xsl:with-param name="indentChar" select="$prg.sh.usage.indentChar" />
								<xsl:with-param name="addFinalEndl" select="false()" />
								<xsl:with-param name="content">
									<xsl:for-each select="$programNode/prg:subcommands/prg:subcommand">
										<xsl:value-of select="normalize-space(./prg:name)" />
										<xsl:for-each select="./prg:aliases/prg:alias">
											<xsl:text>, </xsl:text>
											<xsl:value-of select="normalize-space(.)" />
										</xsl:for-each>
										<xsl:text>: </xsl:text>
										<xsl:value-of select="normalize-space(./prg:documentation/prg:abstract)" />
										<!-- Option description -->
										<xsl:if test="./prg:options">
											<xsl:call-template name="code.block">
												<xsl:with-param name="indentChar" select="$prg.sh.usage.indentChar" />
												<xsl:with-param name="addFinalEndl" select="false()" />
												<xsl:with-param name="content">
													<xsl:text>options: </xsl:text>
													<xsl:call-template name="prg.usage.optionListInline">
														<xsl:with-param name="optionsNode" select="./prg:options" />
														<xsl:with-param name="separator">
															<xsl:text> </xsl:text>
														</xsl:with-param>
													</xsl:call-template>
												</xsl:with-param>
											</xsl:call-template>
										</xsl:if>
										<xsl:value-of select="$sh.endl" />
									</xsl:for-each>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:if>
						<!-- Option descritption -->
						<xsl:if test="$programNode/prg:options">
							<xsl:value-of select="$sh.endl" />
							<xsl:text>With</xsl:text>
							<xsl:if test="$programNode/prg:subcommands">
								<xsl:text> global options</xsl:text>
							</xsl:if>
							<xsl:text>:</xsl:text>
							<xsl:call-template name="code.block">
								<xsl:with-param name="indentChar" select="$prg.sh.usage.indentChar" />
								<xsl:with-param name="addFinalEndl" select="false()" />
								<xsl:with-param name="content">
									<xsl:call-template name="prg.usage.optionListDescription">
										<xsl:with-param name="optionsNode" select="$programNode/prg:options" />
									</xsl:call-template>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:if>
					</xsl:with-param>
				</xsl:call-template>
				<!-- Program documentation & details -->
				<!-- Indent level = +1 -->
				<xsl:if test="$programNode/prg:documentation/prg:details">
					<xsl:call-template name="str.prependLine">
						<xsl:with-param name="prependedText" select="$prg.usage.indentChar" />
						<xsl:with-param name="wrap" select="$prg.usage.wrap" />
						<xsl:with-param name="lineMaxLength" select="$prg.usage.lineMaxLength - string-length($prg.usage.indentChar)" />
						<xsl:with-param name="text">
							<xsl:apply-templates select="$programNode/prg:documentation/prg:details" />
						</xsl:with-param>
					</xsl:call-template>
					<xsl:value-of select="$sh.endl" />
				</xsl:if>
				<xsl:text>EOFUSAGE</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/bash:program|/xsh:program">
		
		<xsl:variable name="interpreterCommand">
			<xsl:choose>
				<xsl:when test="./self::xsh:program">
					<xsl:call-template name="xsh.getInterpreterCommand">
						<xsl:with-param name="programNode" select="." />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<!-- bash schema attribute -->
						<xsl:when test="./@interpreter">
							<xsl:value-of select="normalize-space(./@interpreter)" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="normalize-space($prg.xsh.defaultInterpreterCommand)" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="interpreter">
			<xsl:choose>
				<xsl:when test="./self::xsh:program">
					<xsl:call-template name="xsh.getInterpreter">
						<xsl:with-param name="programNode" select="." />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<!-- old bash schema assumes 'bash' as the default interpreter -->
					<xsl:text>bash</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- Interpreter invocation command -->
		<xsl:text>#!</xsl:text>
		<xsl:choose>
			<xsl:when test="$interpreterCommand and (string-length($interpreterCommand) &gt; 0)">
				<xsl:value-of select="$interpreterCommand" />
			</xsl:when>
			<xsl:when test="$interpreter and (string-length($interpreter) &gt; 0)">
				<xsl:text>/usr/bin/env </xsl:text><xsl:value-of select="$interpreter" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space($prg.xsh.defaultInterpreterCommand)" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="$sh.endl" />
		
		<!-- <xsl:call-template name="sh.comment">
			<xsl:with-param name="content">
				<xsl:text>prg.xsh.defaultInterpreterCommand: </xsl:text>
				<xsl:value-of select="$prg.xsh.defaultInterpreterCommand" />
				<xsl:value-of select="$str.unix.endl" />
				<xsl:text>xsh.defaultInterpreterType: </xsl:text>
				<xsl:value-of select="$interpreter" />
				<xsl:value-of select="$str.unix.endl" />
				<xsl:text>nterpreterCommand: </xsl:text>
				<xsl:value-of select="$interpreterCommand" />
				<xsl:value-of select="$str.unix.endl" />
			</xsl:with-param>
		</xsl:call-template> -->
		
		<xsl:choose>
			<xsl:when test="./bash:info|./xsh:info">
				<xsl:if test="./bash:info/prg:program|./xsh:info/prg:program">
					
					<xsl:variable name="programNode" select="./bash:info/prg:program|./xsh:info/prg:program" />
					
					<xsl:if test="$programNode[prg:author|prg:version|prg:license|prg:copyright|prg:documentation/prg:abstract]">
						<xsl:call-template name="sh.comment">
							<xsl:with-param name="content">
								<xsl:text>####################################</xsl:text>
								<xsl:value-of select="$sh.endl" />
								<xsl:if test="$programNode/prg:copyright">
									<xsl:apply-templates select="$programNode/prg:copyright" />
									<xsl:value-of select="$sh.endl" />
								</xsl:if>
								<xsl:if test="$programNode/prg:license">
									<xsl:apply-templates select="$programNode/prg:license" />
									<xsl:value-of select="$sh.endl" />
								</xsl:if>
								<xsl:if test="$programNode/prg:author">
									<xsl:text>Author: </xsl:text>
									<xsl:value-of select="$programNode/prg:author" />
									<xsl:value-of select="$sh.endl" />
								</xsl:if>
								<xsl:if test="$programNode/prg:version">
									<xsl:text>Version: </xsl:text>
									<xsl:value-of select="$programNode/prg:version" />
									<xsl:value-of select="$sh.endl" />
								</xsl:if>
								<xsl:if test="$programNode/prg:documentation/prg:abstract">
									<xsl:value-of select="$sh.endl" />
									<xsl:apply-templates select="$programNode/prg:documentation/prg:abstract" />
									<xsl:value-of select="$sh.endl" />
								</xsl:if>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:if>
					<xsl:call-template name="sh.comment">
						<xsl:with-param name="content">
							<xsl:text>Program help</xsl:text>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:call-template name="prg.sh.usage.programUsage">
						<xsl:with-param name="programNode" select="$programNode" />
						<xsl:with-param name="interpreter" select="$interpreter" />
					</xsl:call-template>
					<xsl:value-of select="$sh.endl" />
					<xsl:call-template name="sh.comment">
						<xsl:with-param name="content">
							<xsl:text>Program parameter parsing</xsl:text>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:call-template name="prg.sh.parser.main">
						<xsl:with-param name="programNode" select="$programNode" />
						<xsl:with-param name="interpreter" select="$interpreter" />
					</xsl:call-template>
					<xsl:value-of select="$sh.endl" />
				</xsl:if>
			</xsl:when>
		</xsl:choose>
		<xsl:apply-templates select="./bash:functions" />
		<xsl:apply-templates select="./xsh:functions" />
		<xsl:apply-templates select="./bash:code" />
		<xsl:apply-templates select="./xsh:code" />
	</xsl:template>

</xsl:stylesheet>

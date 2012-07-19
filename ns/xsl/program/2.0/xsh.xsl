<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->

<!-- Build a shell script by combining program option parsing & usage from the XML program schema and shell code and functions from the XML bash schema -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" xmlns:sh="http://xsd.nore.fr/bash" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

	<import href="../../languages/bash.xsl" />
		<import href="sh-parser.chunks.xsl" />
	<import href="sh-parser.functions.xsl" />
	<import href="sh-usage.chunks.xsl" />

	<output method="text" encoding="utf-8" />

	<param name="prg.xsh.defaultInterpreter">
		<text>/bin/bash</text>
	</param>

	<!-- Help string -->
	<template name="prg.sh.usage.programUsage">
		<param name="programNode" select="." />

		<!-- Usage function -->
		<call-template name="sh.functionDefinition">
			<with-param name="name">
				<value-of select="$prg.sh.usage.usageFunctionName" />
			</with-param>
			<with-param name="indent" select="false()" />
			<with-param name="content">

				<!-- TODO subcommand doc case here -->
				<if test="$programNode/prg:subcommands">
					<call-template name="sh.if">
						<with-param name="indent" select="false()" />
						<with-param name="condition">
							<text>[ ! -z "${1}" ]</text>
						</with-param>
						<with-param name="then">
							<call-template name="sh.case">
								<with-param name="indent" select="false()" />
								<with-param name="case">
									<call-template name="sh.var">
										<with-param name="name" select="1" />
									</call-template>
								</with-param>
								<with-param name="in">
									<for-each select="$programNode/prg:subcommands/*">
										<call-template name="sh.caseblock">
											<with-param name="indent" select="false()" />
											<with-param name="case">
												<value-of select="./prg:name" />
												<for-each select="./prg:aliases/prg:alias">
													<text> | </text>
													<value-of select="." />
												</for-each>
											</with-param>
											<with-param name="content">
												<text>cat &lt;&lt; EOFSCUSAGE</text>
												<call-template name="endl" />
												<value-of select="./prg:name" />
												<text>: </text>
												<call-template name="prg.usage.descriptionDisplay">
													<with-param name="textNode" select="./prg:documentation/prg:abstract" />
												</call-template>
												<call-template name="endl" />

												<text>Usage: </text>
												<value-of select="../../prg:name" />
												<text> </text>
												<value-of select="./prg:name" />
												<if test="./prg:options">
													<text> </text>
													<call-template name="prg.usage.optionListInline">
														<with-param name="optionsNode" select="./prg:options" />
														<with-param name="separator">
															<text> </text>
														</with-param>
													</call-template>
													<call-template name="endl" />

													<text>With</text>
													<text>:</text>
													<call-template name="code.block">
														<with-param name="indentChar" select="$prg.sh.usage.indentChar" />
														<with-param name="addFinalEndl" select="false()" />
														<with-param name="content">
															<call-template name="prg.usage.optionListDescription">
																<with-param name="optionsNode" select="./prg:options" />
															</call-template>

															<!-- Program documentation & details -->
															<if test="./prg:documentation/prg:details">
																<call-template name="code.block">
																	<with-param name="indentChar" select="$prg.sh.usage.indentChar" />
																	<with-param name="addFinalEndl" select="false()" />
																	<with-param name="content">
																		<apply-templates select="./prg:documentation/prg:details" />
																	</with-param>
																</call-template>
															</if>
														</with-param>
													</call-template>
												</if>
												<call-template name="endl" />

												<text>EOFSCUSAGE</text>
											</with-param>
										</call-template>
									</for-each>
								</with-param>
							</call-template>
							<call-template name="endl" />
							<text>return 0</text>
						</with-param>
					</call-template>
				</if>

				<text>cat &lt;&lt; EOFUSAGE</text>
				<call-template name="endl" />

				<value-of select="$programNode/prg:name" />
				<text>: </text>

				<!-- Program description -->
				<call-template name="prg.usage.descriptionDisplay">
					<with-param name="textNode" select="$programNode/prg:documentation/prg:abstract" />
				</call-template>
				<call-template name="endl" />
				<text>Usage: </text>
				<call-template name="code.block">
					<with-param name="indentChar" select="$prg.sh.usage.indentChar" />
					<with-param name="content">
						<value-of select="$programNode/prg:name" />

						<if test="$programNode/prg:subcommands">
							<text> &lt;subcommand [subcommand option(s)]&gt;</text>
						</if>

						<!-- Inline options list + description of each option -->
						<if test="$programNode/prg:options">
							<text> </text>
							<call-template name="prg.usage.optionListInline">
								<with-param name="optionsNode" select="$programNode/prg:options" />
								<with-param name="separator">
									<text> </text>
								</with-param>
							</call-template>
						</if>

						<!-- subcommands descriptions -->
						<if test="$programNode/prg:subcommands">
							<call-template name="endl" />
							<text>With subcommand:</text>
							<call-template name="code.block">
								<with-param name="indentChar" select="$prg.sh.usage.indentChar" />
								<with-param name="addFinalEndl" select="false()" />
								<with-param name="content">
									<for-each select="$programNode/prg:subcommands/prg:subcommand">
										<value-of select="./prg:name" />
										<for-each select="./prg:aliases/prg:alias">
											<text>, </text>
											<value-of select="." />
										</for-each>
										<text>: </text>
										<value-of select="normalize-space(./prg:documentation/prg:abstract)" />

										<!-- Option descritption -->
										<if test="./prg:options">
											<call-template name="code.block">
												<with-param name="indentChar" select="$prg.sh.usage.indentChar" />
												<with-param name="addFinalEndl" select="false()" />
												<with-param name="content">
													<text>options: </text>
													<call-template name="prg.usage.optionListInline">
														<with-param name="optionsNode" select="./prg:options" />
														<with-param name="separator">
															<text> </text>
														</with-param>
													</call-template>
												</with-param>
											</call-template>
										</if>
										<call-template name="endl" />
									</for-each>
								</with-param>
							</call-template>
						</if>

						<!-- Option descritption -->
						<if test="$programNode/prg:options">
							<call-template name="endl" />
							<text>With</text>
							<if test="$programNode/prg:subcommands">
								<text> global options</text>
							</if>
							<text>:</text>
							<call-template name="code.block">
								<with-param name="indentChar" select="$prg.sh.usage.indentChar" />
								<with-param name="addFinalEndl" select="false()" />
								<with-param name="content">
									<call-template name="prg.usage.optionListDescription">
										<with-param name="optionsNode" select="$programNode/prg:options" />
									</call-template>
								</with-param>
							</call-template>
						</if>
					</with-param>
				</call-template>

				<!-- Program documentation & details -->
				<!-- @todo use str.prependLine + wrap -->
				<if test="$programNode/prg:documentation/prg:details">
					<call-template name="code.block">
						<with-param name="indentChar" select="$prg.sh.usage.indentChar" />
						<with-param name="addFinalEndl" select="false()" />
						<with-param name="content">
							<apply-templates select="$programNode/prg:documentation/prg:details" />
						</with-param>
					</call-template>
					<call-template name="endl" />
				</if>
				<text>EOFUSAGE</text>
			</with-param>
		</call-template>
	</template>

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
					<call-template name="prg.sh.usage.programUsage">
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
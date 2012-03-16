<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (c) 2011 by Renaud Guillard (dev@niao.fr) -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">

	<import href="./shell-base.xsl" />

	<variable name="prg.sh.help.usageFunctionName">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<text>usage</text>
			</with-param>
		</call-template>
	</variable>

	<template name="prg.sh.help.typeDisplay">
		<param name="typeNode" />
		<param name="detailed" select="false()" />
		<choose>
			<when test="$typeNode/prg:string">
				<text>string</text>
			</when>
			<when test="$typeNode/prg:number">
				<text>number</text>
			</when>
			<when test="$typeNode/prg:integer">
				<text>integer</text>
			</when>
			<when test="$typeNode/prg:path">
				<text>path</text>
			</when>
			<when test="$typeNode/prg:existingcommand">
				<text>existing command</text>
			</when>
			<otherwise>
				<text>...</text>
			</otherwise>
		</choose>
	</template>

	<!-- Display the option description @todo auto-split lines -->
	<template name="prg.sh.help.descriptionDisplay">
		<param name="textNode" select="." />
		<call-template name="str.replaceAll">
			<with-param name="replace">
				<call-template name="endl" />
			</with-param>
			<with-param name="by">
				<call-template name="endl" />
				<value-of select="$prg.sh.indentChar" />
			</with-param>
			<with-param name="text">
				<for-each select="$textNode/node()">
					<choose>
						<when test="self::node()[1][self::text()]">
							<value-of select="normalize-space(self::node()[1])" />
						</when>
						<otherwise>
							<apply-templates select="." />
						</otherwise>
					</choose>
				</for-each>
			</with-param>
		</call-template>
	</template>

	<template name="prg.sh.help.selectValueList">
		<param name="optionNode" select="." />
		<param name="mode" />
		<call-template name="str.prependLine">
			<with-param name="content">
				<choose>
					<when test="$mode = 'inline'">
						<call-template name="endl" />
						<for-each select="$optionNode/prg:option">
							<value-of select="normalize-space(.)" />
							<choose>
								<when test="position() = (last() - 1)">
									<text> or </text>
								</when>
								<when test="position() != last()">
									<text>, </text>
								</when>
							</choose>
						</for-each>
					</when>
					<otherwise>
						<for-each select="$optionNode/prg:option">
							<call-template name="endl" />
							<text>- </text>
							<value-of select="normalize-space(.)" />
						</for-each>
					</otherwise>
				</choose>
			</with-param>
		</call-template>
	</template>

	<template name="prg.sh.help.firstOptionNameDisplay">
		<param name="optionNode" select="." />
		<choose>
			<when test="$optionNode/prg:names/prg:short">
				<call-template name="prg.sh.optionName">
					<with-param name="nameNode" select="$optionNode/prg:names/prg:short[1]" />
				</call-template>
			</when>
			<when test="$optionNode/prg:names/prg:long">
				<call-template name="prg.sh.optionName">
					<with-param name="nameNode" select="$optionNode/prg:names/prg:long[1]" />
				</call-template>
			</when>
		</choose>
	</template>

	<template name="prg.sh.help.allOptionNameDisplay">
		<param name="optionNode" select="." />
		<for-each select="$optionNode/prg:names/prg:short|$optionNode/prg:names/prg:long">
			<call-template name="prg.sh.optionName">
				<with-param name="nameNode" select="." />
			</call-template>
			<if test="(position() != last())">
				<text>, </text>
			</if>
		</for-each>
	</template>

	<!-- inline display of a switch argument (choose the first option name) -->
	<template name="prg.sh.help.switchInline">
		<param name="optionNode" select="." />
		<call-template name="prg.sh.help.firstOptionNameDisplay">
			<with-param name="optionNode" select="$optionNode" />
		</call-template>
	</template>

	<!-- Description of a switch argument (all option names + description) -->
	<template name="prg.sh.help.switchDescription">
		<param name="optionNode" select="." />
		
		<call-template name="prg.sh.help.allOptionNameDisplay">
			<with-param name="optionNode" select="$optionNode" />
		</call-template>
		<text>: </text>
		<call-template name="prg.sh.help.descriptionDisplay">
			<with-param name="textNode" select="$optionNode/prg:documentation/prg:abstract" />
		</call-template>
		
		<if test="$optionNode/prg:documentation/prg:details">
			<call-template name="endl" />
			<call-template name="prg.sh.help.descriptionDisplay">
				<with-param name="textNode" select="$optionNode/prg:documentation/prg:details" />
			</call-template>
		</if>
	</template>

	<template name="prg.sh.help.argumentInline">
		<param name="optionNode" select="." />
		<call-template name="prg.sh.help.firstOptionNameDisplay">
			<with-param name="optionNode" select="$optionNode" />
		</call-template>
		<choose>
			<when test="$optionNode/prg:type">
				<text> &lt;</text>
				<call-template name="prg.sh.help.typeDisplay">
					<with-param name="typeNode" select="$optionNode/prg:type" />
				</call-template>
				<text>&gt;</text>
			</when>
			<otherwise>
				<text> &lt;...&gt;</text>
			</otherwise>
		</choose>
	</template>

	<template name="prg.sh.help.argumentDescription">
		<param name="optionNode" select="." />
		
		<call-template name="prg.sh.help.allOptionNameDisplay">
			<with-param name="optionNode" select="$optionNode" />
		</call-template>
		<text>: </text>
		<call-template name="prg.sh.help.descriptionDisplay">
			<with-param name="textNode" select="$optionNode/prg:documentation/prg:abstract" />
		</call-template>
		
		<if test="$optionNode/prg:documentation/prg:details">
			<call-template name="endl" />
			<call-template name="str.prependLine">
				<with-param name="content">
					<call-template name="prg.sh.help.descriptionDisplay">
						<with-param name="textNode" select="$optionNode/prg:documentation/prg:details" />
					</call-template>
				</with-param>
			</call-template>
		</if>
		
		<if test="$optionNode/prg:select">
			<call-template name="endl" />
			<call-template name="str.prependLine">
				<with-param name="content">
					<choose>
						<when test="$optionNode/prg:select/@restrict">
							<text>The argument value have to be one of the following:</text>
						</when>
						<otherwise>
							<text>The argument can be:</text>
						</otherwise>
					</choose>
					<call-template name="prg.sh.help.selectValueList">
						<with-param name="mode">
							<text>inline</text>
						</with-param>
						<with-param name="optionNode" select="$optionNode/prg:select" />
					</call-template>
				</with-param>
			</call-template>
		</if>
		
		<if test="$optionNode/prg:default">
			<call-template name="endl" />
			<call-template name="str.prependLine">
				<with-param name="content">
					<text>Default value: </text>
					<value-of select="$optionNode/prg:default" />
				</with-param>
			</call-template>
		</if>
	</template>

	<template name="prg.sh.help.multiargumentInline">
		<param name="optionNode" select="." />
		<call-template name="prg.sh.help.firstOptionNameDisplay">
			<with-param name="optionNode" select="$optionNode" />
		</call-template>
		<choose>
			<when test="$optionNode/prg:type">
				<text> &lt;</text>
				<call-template name="prg.sh.help.typeDisplay">
					<with-param name="typeNode" select="$optionNode/prg:type" />
				</call-template>
				<text> [ ... ]&gt;</text>
			</when>
			<otherwise>
				<text> &lt;...  [ ... ]&gt;</text>
			</otherwise>
		</choose>
	</template>

	<template name="prg.sh.help.multiargumentDescription">
		<param name="optionNode" select="." />
		<call-template name="prg.sh.help.argumentDescription">
			<with-param name="optionNode" select="$optionNode" />
		</call-template>
		<if test="$optionNode/@min">
			<call-template name="endl" />
			<call-template name="str.prependLine">
				<with-param name="content">
					<text>Minimal argument count: </text>
					<value-of select="$optionNode/@min" />
				</with-param>
			</call-template>
		</if>
		<if test="$optionNode/@max">
			<call-template name="endl" />
			<call-template name="str.prependLine">
				<with-param name="content">
					<text>Maximal argument count: </text>
					<value-of select="$optionNode/@max" />
				</with-param>
			</call-template>
		</if>
	</template>

	<template name="prg.sh.help.groupInline">
		<param name="optionNode" select="." />

		<if test="$optionNode[@type = 'exclusive']">
			<text>(</text>
		</if>
		<call-template name="prg.sh.help.optionListInline">
			<with-param name="optionsNode" select="$optionNode/prg:options" />
			<with-param name="separator">
				<choose>
					<when test="$optionNode[@type = 'exclusive']">
						<text> | </text>
					</when>
					<otherwise>
						<text> </text>
					</otherwise>
				</choose>
			</with-param>
		</call-template>
		<if test="$optionNode[@type = 'exclusive']">
			<text>)</text>
		</if>
	</template>

	<template name="prg.sh.help.groupDescription">
		<param name="optionNode" select="." />
		<call-template name="prg.sh.help.descriptionDisplay">
			<with-param name="textNode" select="$optionNode/prg:documentation/prg:abstract" />
		</call-template>
		<call-template name="endl" />
		<text>(</text>
		<call-template name="sh.block">
			<with-param name="indentChar" select="$prg.sh.indentChar" />
			<with-param name="content">
				<call-template name="prg.sh.help.optionListDescription">
					<with-param name="optionsNode" select="$optionNode/prg:options" />
				</call-template>
			</with-param>
		</call-template>
		<text>)</text>
	</template>

	<!-- Display the option list -->
	<template name="prg.sh.help.optionListInline">
		<param name="optionsNode" />
		<param name="separator">
			<text>, </text>
		</param>
		<variable name="inGroup" select="$optionsNode/../self::prg:group" />

		<for-each select="$optionsNode/*">
			<if test="not(@required = 'true') and not($inGroup)">
				<text>[</text>
			</if>
			<choose>
				<when test="./self::prg:switch">
					<call-template name="prg.sh.help.switchInline">
						<with-param name="optionNode" select="." />
					</call-template>
				</when>
				<when test="./self::prg:argument">
					<call-template name="prg.sh.help.argumentInline">
						<with-param name="optionNode" select="." />
					</call-template>
				</when>
				<when test="./self::prg:multiargument">
					<call-template name="prg.sh.help.multiargumentInline">
						<with-param name="optionNode" select="." />
					</call-template>
				</when>
				<when test="./self::prg:group">
					<call-template name="prg.sh.help.groupInline">
						<with-param name="optionNode" select="." />
					</call-template>
				</when>
			</choose>
			<if test="not(@required = 'true') and not($inGroup)">
				<text>]</text>
			</if>
			<if test="(position() != last())">
				<value-of select="$separator" />
			</if>
		</for-each>
	</template>

	<!-- Display the full documentation for each option -->
	<template name="prg.sh.help.optionListDescription">
		<param name="optionsNode" />
		
		<for-each select="$optionsNode/*">
			<if test="position() != 1">
				<call-template name="endl" />
			</if>
			<choose>
				<when test="./self::prg:switch">
					<call-template name="prg.sh.help.switchDescription">
						<with-param name="optionNode" select="." />
					</call-template>
				</when>
				<when test="./self::prg:argument">
					<call-template name="prg.sh.help.argumentDescription">
						<with-param name="optionNode" select="." />
					</call-template>
				</when>
				<when test="./self::prg:multiargument">
					<call-template name="prg.sh.help.multiargumentDescription">
						<with-param name="optionNode" select="." />
					</call-template>
				</when>
				<when test="./self::prg:group">
					<call-template name="prg.sh.help.groupDescription">
						<with-param name="optionNode" select="." />
					</call-template>
				</when>
			</choose>
		</for-each>
	</template>

	<!-- Main template -->
	<template name="prg.sh.help.programHelp">
		<param name="programNode" select="." />
		
		<!-- Usage function -->
		<call-template name="sh.functionDefinition">
			<with-param name="name">
				<value-of select="$prg.sh.help.usageFunctionName" />
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
												<call-template name="prg.sh.help.descriptionDisplay">
													<with-param name="textNode" select="./prg:documentation/prg:abstract" />
												</call-template>
												<call-template name="endl" />

												<text>Usage: </text>
												<value-of select="../../prg:name" />
												<text> </text>
												<value-of select="./prg:name" />
												<if test="./prg:options">
													<text> </text>
													<call-template name="prg.sh.help.optionListInline">
														<with-param name="optionsNode" select="./prg:options" />
														<with-param name="separator">
															<text> </text>
														</with-param>
													</call-template>
													<call-template name="endl" />

													<text>With</text>
													<text>:</text>
													<call-template name="code.block">
														<with-param name="indentChar" select="$prg.sh.indentChar" />
														<with-param name="addFinalEndl" select="false()" />
														<with-param name="content">
															<call-template name="prg.sh.help.optionListDescription">
																<with-param name="optionsNode" select="./prg:options" />
															</call-template>

															<!-- Program documentation & details -->
															<if test="./prg:documentation/prg:details">
																<call-template name="code.block">
																	<with-param name="indentChar" select="$prg.sh.indentChar" />
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
				<call-template name="prg.sh.help.descriptionDisplay">
					<with-param name="textNode" select="$programNode/prg:documentation/prg:abstract" />
				</call-template>
				<call-template name="endl" />
				<text>Usage: </text>
				<call-template name="code.block">
					<with-param name="indentChar" select="$prg.sh.indentChar" />
					<with-param name="content">
						<value-of select="$programNode/prg:name" />

						<if test="$programNode/prg:subcommands">
							<text> &lt;subcommand [subcommand option(s)]&gt;</text>
						</if>

						<!-- Inline options list + description of each option -->
						<if test="$programNode/prg:options">
							<text> </text>
							<call-template name="prg.sh.help.optionListInline">
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
								<with-param name="indentChar" select="$prg.sh.indentChar" />
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
												<with-param name="indentChar" select="$prg.sh.indentChar" />
												<with-param name="addFinalEndl" select="false()" />
												<with-param name="content">
													<text>options: </text>
													<call-template name="prg.sh.help.optionListInline">
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
								<with-param name="indentChar" select="$prg.sh.indentChar" />
								<with-param name="addFinalEndl" select="false()" />
								<with-param name="content">
									<call-template name="prg.sh.help.optionListDescription">
										<with-param name="optionsNode" select="$programNode/prg:options" />
									</call-template>
								</with-param>
							</call-template>
						</if>
					</with-param>
				</call-template>
				
				<!-- Program documentation & details -->
				<if test="$programNode/prg:documentation/prg:details">
					<call-template name="code.block">
						<with-param name="indentChar" select="$prg.sh.indentChar" />
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

</stylesheet>

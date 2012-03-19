<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (c) 2011 by Renaud Guillard (dev@niao.fr) -->
<!-- Generic function definitions -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">

	<import href="shell-parser.base.xsl" />
	<import href="shell-parser.variables.xsl" />

	<!-- Message functions -->
	<template name="prg.sh.parser.addMessageFunction">
		<call-template name="sh.functionDefinition">
			<with-param name="name" select="$prg.sh.parser.fName_addmessage" />
			<with-param name="content">
				<text>local type="${1}"</text>
				<call-template name="endl" />
				<text>local message="${2}"</text>
				<call-template name="endl" />
				<text>local m="[</text>
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_option" />
				</call-template>
				<text>:</text>
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_index" />
				</call-template>
				<text>:</text>
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_subindex" />
				</call-template>
				<text>] </text>
				<call-template name="sh.var">
					<with-param name="name">
						<text>message</text>
					</with-param>
				</call-template>
				<text>"</text>
				<call-template name="endl" />

				<text>eval "local c=\</text>
				<call-template name="sh.arrayLength">
					<with-param name="name">
						<value-of select="$prg.prefix" />
						<value-of select="$prg.sh.parser.variableNamePrefix" />
						<text></text>
						<call-template name="sh.var">
							<with-param name="name">
								<text>type</text>
							</with-param>
						</call-template>
						<text>s</text>
					</with-param>
				</call-template>
				<text>"</text>
				<call-template name="endl" />

				<text>c=$(expr </text>
				<call-template name="sh.var">
					<with-param name="name">
						<text>c</text>
					</with-param>
				</call-template>
				<text> + </text>
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_startindex" />
				</call-template>
				<text>)</text>
				<call-template name="endl" />

				<text>eval "</text>
				<value-of select="$prg.prefix" />
				<value-of select="$prg.sh.parser.variableNamePrefix" />
				<text></text>
				<call-template name="sh.var">
					<with-param name="name">
						<text>type</text>
					</with-param>
				</call-template>
				<text>s[</text>
				<call-template name="sh.var">
					<with-param name="name">
						<text>c</text>
					</with-param>
				</call-template>
				<text>]=\"</text>
				<call-template name="sh.var">
					<with-param name="name">
						<text>m</text>
					</with-param>
				</call-template>
				<text>\""</text>
			</with-param>
		</call-template>
	</template>

	<template name="prg.sh.parser.addMessageFunctionHelper">
		<param name="name" />
		<call-template name="sh.functionDefinition">
			<with-param name="name">
				<value-of select="$prg.prefix" />
				<value-of select="$prg.sh.parser.functionNamePrefix" />
				<text>add</text>
				<value-of select="$name" />
			</with-param>
			<with-param name="content">
				<value-of select="$prg.sh.parser.fName_addmessage" />
				<text> "</text>
				<value-of select="$name" />
				<text>" "${@}"</text>
			</with-param>
		</call-template>
	</template>

	<template name="prg.sh.parser.displayErrorFunction">
		<call-template name="sh.functionDefinition">
			<with-param name="name" select="$prg.sh.parser.fName_displayerrors" />
			<with-param name="content">
				<call-template name="sh.incrementalFor">
					<with-param name="init">
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_startindex" />
						</call-template>
					</with-param>
					<with-param name="operator">
						<text>&lt;</text>
					</with-param>
					<with-param name="limit">
						<call-template name="sh.arrayLength">
							<with-param name="name" select="$prg.sh.parser.vName_errors" />
						</call-template>
					</with-param>
					<with-param name="do">
						<text>echo -e "\t- </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_errors" />
							<with-param name="index">
								<call-template name="sh.var">
									<with-param name="name">
										<text>i</text>
									</with-param>
								</call-template>
							</with-param>
						</call-template>
						<text>"</text>
					</with-param>
				</call-template>
			</with-param>
		</call-template>
	</template>

	<template name="prg.sh.parser.messageFunctions">
		<!-- addwarning -->
		<call-template name="prg.sh.parser.addMessageFunction" />
		<call-template name="endl" />
		<call-template name="prg.sh.parser.addMessageFunctionHelper">
			<with-param name="name">
				<text>warning</text>
			</with-param>
		</call-template>

		<!-- adderror -->
		<call-template name="prg.sh.parser.addMessageFunctionHelper">
			<with-param name="name">
				<text>error</text>
			</with-param>
		</call-template>
		<call-template name="prg.sh.parser.addMessageFunctionHelper">
			<with-param name="name">
				<text>fatalerror</text>
			</with-param>
		</call-template>
		<call-template name="endl" />

		<!-- displayerror -->
		<call-template name="prg.sh.parser.displayErrorFunction" />
		<call-template name="endl" />

		<!-- parser_debug -->
		<if test="$prg.debug">
			<call-template name="sh.functionDefinition">
				<with-param name="name" select="$prg.sh.parser.fName_debug" />
				<with-param name="content">
					<text>echo "DEBUG: ${@}"</text>
				</with-param>
			</call-template>
		</if>
		<call-template name="endl" />

	</template>

	<!-- Value check functions -->

	<!-- File system item functions -->

	<template name="prg.sh.parser.pathAccessCheckFunction">
		<call-template name="sh.functionDefinition">
			<with-param name="name" select="$prg.sh.parser.fName_pathaccesscheck" />
			<with-param name="content">
				<text>local file=</text>
				<call-template name="sh.var">
					<with-param name="name" select="1" />
					<with-param name="quoted" select="true()" />
				</call-template>
				<call-template name="endl" />
				<text>local accessString=</text>
				<call-template name="sh.var">
					<with-param name="name" select="2" />
					<with-param name="quoted" select="true()" />
				</call-template>
				<call-template name="endl" />
				<call-template name="sh.while">
					<with-param name="condition">
						<text>[ ! -z </text>
						<call-template name="sh.var">
							<with-param name="name">
								<text>accessString</text>
							</with-param>
							<with-param name="quoted" select="true()" />
						</call-template>
						<text> ]</text>
					</with-param>
					<with-param name="do">
						<text>[ -</text>
						<call-template name="sh.var">
							<with-param name="name">
								<text>accessString</text>
							</with-param>
							<with-param name="start" select="0" />
							<with-param name="length" select="1" />
						</call-template>
						<text> </text>
						<call-template name="sh.var">
							<with-param name="name">
								<text>file</text>
							</with-param>
							<with-param name="quoted" />
						</call-template>
						<text> ] || return 1;</text>
						<call-template name="endl" />
						<text>accessString=</text>
						<call-template name="sh.var">
							<with-param name="name">
								<text>accessString</text>
							</with-param>
							<with-param name="quoted" />
							<with-param name="start" select="1" />
						</call-template>
					</with-param>
				</call-template>
				<call-template name="endl" />
				<text>return 0</text>
			</with-param>
		</call-template>
	</template>

	<template name="prg.sh.parser.optionSetPresenceFunctions">
		<call-template name="sh.functionDefinition">
			<with-param name="name" select="$prg.sh.parser.fName_setoptionpresence" />
			<with-param name="content">
				<call-template name="sh.incrementalFor">
					<with-param name="init">
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_startindex" />
						</call-template>
					</with-param>
					<with-param name="limit">
						<text>$(expr </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_startindex" />
						</call-template>
						<text> + </text>
						<call-template name="sh.arrayLength">
							<with-param name="name" select="$prg.sh.parser.vName_required" />
						</call-template>
						<text>)</text>
					</with-param>
					<with-param name="do">
						<variable name="requiredVar">
							<call-template name="sh.var">
								<with-param name="name" select="$prg.sh.parser.vName_required" />
								<with-param name="quoted" select="true()" />
								<with-param name="index">
									<call-template name="sh.var">
										<with-param name="name">
											<text>i</text>
										</with-param>
									</call-template>
								</with-param>
							</call-template>
						</variable>
						<text>local idPart="$(echo </text>
						<value-of select="$requiredVar" />
						<text> | cut -f 1 -d":" )"</text>
						<call-template name="endl" />

						<call-template name="sh.if">
							<with-param name="condition">
								<text>[ </text>
								<call-template name="sh.var">
									<with-param name="name">
										<text>idPart</text>
									</with-param>
									<with-param name="quoted" select="true()"></with-param>
								</call-template>
								<text> = </text>
								<call-template name="sh.var">
									<with-param name="name">
										<text>1</text>
									</with-param>
									<with-param name="quoted" select="true()" />
								</call-template>
								<text> ]</text>
							</with-param>
							<with-param name="then">
								<call-template name="sh.arraySetIndex">
									<with-param name="name" select="$prg.sh.parser.vName_required" />
									<with-param name="index">
										<call-template name="sh.var">
											<with-param name="name">
												<text>i</text>
											</with-param>
										</call-template>
									</with-param>
									<with-param name="value">
										<text>""</text>
									</with-param>
								</call-template>
								<call-template name="endl" />
								<text>return 0</text>
							</with-param>
						</call-template>
					</with-param>
				</call-template>
				<call-template name="endl" />
				<text>return 1</text>
			</with-param>
		</call-template>

		<call-template name="sh.functionDefinition">
			<with-param name="name" select="$prg.sh.parser.fName_checkrequired" />
			<with-param name="content">
				<call-template name="sh.comment">
					<with-param name="content">
						<text>First round: set default values</text>
					</with-param>
				</call-template>
				<call-template name="endl" />

				<variable name="requiredVar">
					<call-template name="sh.var">
						<with-param name="name" select="$prg.sh.parser.vName_required" />
						<with-param name="quoted" select="true()" />
						<with-param name="index">
							<call-template name="sh.var">
								<with-param name="name">
									<text>i</text>
								</with-param>
							</call-template>
						</with-param>
					</call-template>
				</variable>

				<variable name="init">
					<call-template name="sh.var">
						<with-param name="name" select="$prg.sh.parser.vName_startindex" />
					</call-template>
				</variable>
				<variable name="limit">
					<text>$(expr </text>
					<call-template name="sh.var">
						<with-param name="name" select="$prg.sh.parser.vName_startindex" />
					</call-template>
					<text> + </text>
					<call-template name="sh.arrayLength">
						<with-param name="name" select="$prg.sh.parser.vName_required" />
					</call-template>
					<text>)</text>
				</variable>

				<variable name="isNotEmpty">
					<text>[ ! -z </text>
					<value-of select="$requiredVar" />
					<text> ]</text>
				</variable>

				<call-template name="sh.incrementalFor">
					<with-param name="init" select="$init" />
					<with-param name="limit" select="$limit" />
					<with-param name="do">
						<text>local todoPart="$(echo </text>
						<value-of select="$requiredVar" />
						<text> | cut -f 3 -d":" )"</text>
						<call-template name="endl" />
						<text>[ -z "${todoPart}" ] || eval "${todoPart}"</text>
					</with-param>
				</call-template>
				<call-template name="endl" />


				<text>local c=0</text>
				<call-template name="endl" />
				<call-template name="sh.incrementalFor">
					<with-param name="init" select="$init" />
					<with-param name="limit" select="$limit" />
					<with-param name="do">
						<call-template name="sh.if">
							<with-param name="condition" select="$isNotEmpty" />
							<with-param name="then">
								<text>local displayPart="$(echo </text>
								<value-of select="$requiredVar" />
								<text> | cut -f 2 -d":" )"</text>
								<call-template name="endl" />
								<call-template name="sh.arrayAppend">
									<with-param name="name" select="$prg.sh.parser.vName_errors" />
									<with-param name="value">
										<text>"Missing required option </text>
										<call-template name="sh.var">
											<with-param name="name">
												<text>displayPart</text>
											</with-param>
										</call-template>
										<text>"</text>
									</with-param>
								</call-template>
								<call-template name="endl" />

								<call-template name="sh.varincrement">
									<with-param name="name">
										<text>c</text>
									</with-param>
								</call-template>
							</with-param>
						</call-template>
					</with-param>
				</call-template>
				<call-template name="endl" />
				<text>return </text>
				<call-template name="sh.var">
					<with-param name="name">
						<text>c</text>
					</with-param>
				</call-template>
			</with-param>
		</call-template>
	</template>

	<template name="prg.sh.parser.minmaxCheckFunction">
		<param name="programNode" />

		<call-template name="sh.functionDefinition">
			<with-param name="name" select="$prg.sh.parser.fName_checkminmax" />
			<with-param name="content">
				<text>local errorCount=0</text>
				<call-template name="endl" />
				
				<call-template name="sh.comment">
					<with-param name="content">
						<text>Check min argument for multiargument</text>
					</with-param>
				</call-template>
				
				<for-each select="$programNode//prg:multiargument[@min > 0]">
					<variable name="optionName">
						<call-template name="prg.sh.optionDisplayName">
							<with-param name="optionNode" select="." />
						</call-template>
					</variable>
					<if test="prg:databinding/prg:variable">
						<variable name="argCountVariable">
							<call-template name="sh.arrayLength">
								<with-param name="name">
									<apply-templates select="prg:databinding/prg:variable"/>
								</with-param>
							</call-template>
						</variable>
						<call-template name="sh.if">
							<with-param name="condition">
								<text>[ </text>
								<value-of select="$argCountVariable" />
								<text> -gt 0 ] &amp;&amp; [ </text>
								<value-of select="$argCountVariable" />
								<text> -lt </text>
								<value-of select="@min" />
								<text> ]</text>
							</with-param>
							<with-param name="then">
								<call-template name="prg.sh.parser.addGlobalError">
									<with-param name="value">
										<text>"Invalid argument count for option \"</text>
										<value-of select="$optionName" />
										<text>\". At least </text>
										<value-of select="@min" />
										<text> expected, </text>
										<value-of select="$argCountVariable" />
										<text> given"</text>
									</with-param>
								</call-template>
								
								<call-template name="endl" />
								<call-template name="sh.varincrement">
									<with-param name="name"><text>errorCount</text></with-param>
								</call-template>
							</with-param>
						</call-template>
					</if>
				</for-each>

				<call-template name="endl" />
				<text>return ${errorCount}</text>
			</with-param>
		</call-template>
	</template>

	<template name="prg.sh.parser.enumCheckFunction">
		<call-template name="sh.functionDefinition">
			<with-param name="name">
				<value-of select="$prg.sh.parser.fName_enumcheck" />
			</with-param>
			<with-param name="content">
				<text>local ref="${1}"</text>
				<call-template name="endl" />

				<text>shift 1</text>
				<call-template name="endl" />

				<call-template name="sh.while">
					<with-param name="condition">
						<text>[ $# -gt 0 ]</text>
					</with-param>
					<with-param name="do">
						<call-template name="sh.if">
							<with-param name="condition">
								<text>[ "${ref}" = "${1}" ]</text>
							</with-param>
							<with-param name="then">
								<text>return 0</text>
							</with-param>
						</call-template>
						<text>shift</text>
					</with-param>
				</call-template>
				<call-template name="endl" />
				<text>return 1</text>
			</with-param>
		</call-template>
	</template>

	<!-- Check and add anonymous value -->
	<template name="prg.sh.parser.addValueFunction">
		<param name="programNode" />
		
		<call-template name="sh.functionDefinition">
			<with-param name="name" select="$prg.sh.parser.fName_addvalue" />
			<with-param name="content">
				<text>local position=</text>
				<call-template name="sh.arrayLength">
					<with-param name="name" select="$prg.sh.parser.vName_values" />
				</call-template>
				<call-template name="endl" />
				
				<text>local value="${1}"</text>
				<call-template name="endl" />
				
				<call-template name="sh.if">
					<with-param name="condition">
						<text>[ -z </text>
						<value-of select="$prg.sh.parser.var_subcommand" />
						<text> ]</text>
					</with-param>
					
					<!-- Add global values -->
					<with-param name="then">
						<choose>
							<when test="count($programNode/prg:values/*)">
								<call-template name="prg.sh.parser.checkValue">
									<with-param name="valuesNode" select="$programNode/prg:values" />
								</call-template>
							</when>
							<otherwise>
								<call-template name="prg.sh.parser.addGlobalError">
									<with-param name="value">
										<text>"Positional argument not allowed"</text>
									</with-param>
								</call-template>
								<call-template name="endl" />
								<text>return </text>
								<value-of select="$prg.sh.parser.var_ERROR" />
							</otherwise>
						</choose>
					</with-param>
					
					<!-- Subcommand values -->
					<with-param name="else">
						<call-template name="sh.case">
							<with-param name="case">
								<call-template name="sh.var">
									<with-param name="name" select="$prg.sh.parser.vName_subcommand" />
								</call-template>
							</with-param>
							<with-param name="in">
								<for-each select="$programNode/prg:subcommands/*">
									<call-template name="sh.caseblock">
										<with-param name="case" select="prg:name" />
										<with-param name="content">
											<choose>
												<when test="count(./prg:values/*)">
													<call-template name="prg.sh.parser.checkValue">
														<with-param name="valuesNode" select="./prg:values" />
													</call-template>
												</when>
												<otherwise>
													<call-template name="prg.sh.parser.addGlobalError">
														<with-param name="value">
															<text>"Positional argument not allowed in subcommand </text>
															<value-of select="./prg:name" />
															<text>"</text>
														</with-param>
													</call-template>
													<call-template name="endl" />
													<text>return </text>
													<value-of select="$prg.sh.parser.var_ERROR" />
												</otherwise>
											</choose>
										</with-param>
									</call-template>
								</for-each>
								<call-template name="sh.caseblock">
									<with-param name="case"><text>*</text></with-param>
									<with-param name="content">
										<text>return </text>
										<value-of select="$prg.sh.parser.var_ERROR" />
									</with-param>
								</call-template>
							</with-param>
						</call-template>
					</with-param>
					
				</call-template>
			
				<call-template name="sh.arrayAppend">
					<with-param name="name" select="$prg.sh.parser.vName_values" />
					<with-param name="value">
						<call-template name="sh.var">
							<with-param name="name" select="1" />
							<with-param name="quoted" select="true()" />
						</call-template>
					</with-param>
				</call-template>
				
			</with-param>
		</call-template>
	</template>

	<!-- Main function for subcommand -->
	<template name="prg.sh.parser.subCommandOptionParseFunction">
		<param name="programNode" select="." />
		<variable name="onError">
			<text>return </text>
			<call-template name="sh.var">
				<with-param name="name" select="$prg.sh.parser.vName_SC_ERROR" />
			</call-template>
		</variable>
		<variable name="onSuccess">
			<text>return </text>
			<call-template name="sh.var">
				<with-param name="name" select="$prg.sh.parser.vName_SC_OK" />
			</call-template>
		</variable>
		<variable name="onUnknownOption">
			<text>return </text>
			<call-template name="sh.var">
				<with-param name="name" select="$prg.sh.parser.vName_SC_SKIP" />
			</call-template>
		</variable>

		<call-template name="sh.functionDefinition">
			<with-param name="name" select="$prg.sh.parser.fName_process_subcommand_option" />
			<with-param name="content">
				<value-of select="$prg.sh.parser.vName_item" />
				<text>=</text>
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_input" />
					<with-param name="index">
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_index" />
						</call-template>
					</with-param>
					<with-param name="quoted" select="true()" />
				</call-template>
				<call-template name="endl" />

				<if test="$prg.debug">
					<value-of select="$prg.sh.parser.fName_debug" />
					<text> "Processing subcommand </text>
					<call-template name="sh.var">
						<with-param name="name" select="$prg.sh.parser.vName_item" />
					</call-template>
					<text> [subindex: </text>
					<call-template name="sh.var">
						<with-param name="name" select="$prg.sh.parser.vName_subindex" />
					</call-template>
					<text>] (</text>
					<call-template name="sh.var">
						<with-param name="name" select="$prg.sh.parser.vName_index" />
					</call-template>
					<text> of </text>
					<call-template name="sh.var">
						<with-param name="name" select="$prg.sh.parser.vName_itemcount" />
					</call-template>
					<text>)"</text>
					<call-template name="endl" />
				</if>

				<call-template name="sh.if">
					<with-param name="condition">
						<text>[ -z </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_item" />
							<with-param name="quoted" select="true()" />
						</call-template>
						<text> ] || [ </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_item" />
							<with-param name="quoted" select="true()" />
							<with-param name="length" select="1" />
						</call-template>
						<text> != "-" ] || [ </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_item" />
							<with-param name="quoted" select="true()" />
						</call-template>
						<text> = "--" ]</text>
					</with-param>
					<with-param name="then">
						<text>return </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_SC_SKIP" />
						</call-template>
					</with-param>
				</call-template>
				<call-template name="endl" />

				<call-template name="sh.case">
					<with-param name="case">
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_subcommand" />
						</call-template>
					</with-param>
					<with-param name="in">
						<for-each select="$programNode/prg:subcommands/prg:subcommand">
							<if test="./prg:options//prg:names/prg:long or ./prg:options//prg:names/prg:short">
								<call-template name="sh.caseblock">
									<with-param name="case">
										<value-of select="./prg:name" />
									</with-param>
									<with-param name="content">
										<if test="./prg:options//prg:names/prg:long">
											<call-template name="prg.sh.parser.longOptionNameElif">
												<with-param name="optionsNode" select="./prg:options" />
												<with-param name="onError" select="$onError" />
												<with-param name="onSuccess" select="$onSuccess" />
												<with-param name="onUnknownOption" select="$onUnknownOption" />
												<with-param name="keyword">
													<text>if</text>
												</with-param>
											</call-template>
										</if>

										<!-- short option -->
										<if test="./prg:options//prg:names/prg:short">
											<call-template name="prg.sh.parser.shortOptionNameElif">
												<with-param name="optionsNode" select="./prg:options" />
												<with-param name="onError" select="$onError" />
												<with-param name="onSuccess" select="$onSuccess" />
												<with-param name="onUnknownOption" select="$onUnknownOption" />
												<with-param name="keyword">
													<choose>
														<when test="./prg:options//prg:names/prg:long">
															<text>elif</text>
														</when>
														<otherwise>
															<text>if</text>
														</otherwise>
													</choose>
												</with-param>
											</call-template>
										</if>
										<text>fi</text>
									</with-param>
								</call-template>
							</if>
						</for-each>
					</with-param>
				</call-template>
				<call-template name="endl" />
				<text>return </text>
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_SC_OK" />
				</call-template>
			</with-param>
		</call-template>
	</template>

	<!-- Main option parser function -->
	<template name="prg.sh.parser.optionParseFunction">
		<param name="programNode" select="." />
		<variable name="onError">
			<text>return </text>
			<value-of select="$prg.sh.parser.var_ERROR" />
		</variable>
		<variable name="onSuccess">
			<text>return </text>
			<call-template name="sh.var">
				<with-param name="name" select="$prg.sh.parser.vName_SC_OK" />
			</call-template>
		</variable>
		<variable name="onUnknownOption">
			<value-of select="$prg.sh.parser.fName_adderror" />
			<text> "Unknown option \"</text>
			<call-template name="sh.var">
				<with-param name="name" select="$prg.sh.parser.vName_option" />
			</call-template>
			<text>\""</text>
			<call-template name="endl" />
			<text>return </text>
			<value-of select="$prg.sh.parser.var_ERROR" />
		</variable>

		<call-template name="sh.functionDefinition">
			<with-param name="name" select="$prg.sh.parser.fName_process_option" />
			<with-param name="content">
				<call-template name="sh.if">
					<with-param name="condition">
						<text>[ ! -z </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_subcommand" />
							<with-param name="quoted" select="true()" />
						</call-template>
						<text> ] &amp;&amp; [ </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_item" />
							<with-param name="quoted" select="true()" />
						</call-template>
						<text> != "--" ]</text>
					</with-param>
					<with-param name="then">
						<if test="$prg.debug">
							<value-of select="$prg.sh.parser.fName_debug" />
							<text> "Subcommand option check"</text>
							<call-template name="endl" />
						</if>

						<call-template name="sh.if">
							<with-param name="condition">
								<value-of select="$prg.sh.parser.fName_process_subcommand_option" />
								<text> "${@}"</text>
							</with-param>
							<with-param name="then">
								<if test="$prg.debug">
									<value-of select="$prg.sh.parser.fName_debug" />
									<text> "Subcommand option parsing success"</text>
									<call-template name="endl" />
								</if>
								<text>return </text>
								<call-template name="sh.var">
									<with-param name="name" select="$prg.sh.parser.vName_OK" />
								</call-template>
							</with-param>
						</call-template>

						<call-template name="sh.if">
							<with-param name="condition">
								<text>[ </text>
								<call-template name="sh.var">
									<with-param name="name" select="$prg.sh.parser.vName_index" />
								</call-template>
								<text> -ge </text>
								<call-template name="sh.var">
									<with-param name="name" select="$prg.sh.parser.vName_itemcount" />
								</call-template>
								<text> ]</text>
							</with-param>
							<with-param name="then">
								<if test="$prg.debug">
									<value-of select="$prg.sh.parser.fName_debug" />
									<text> "End of items"</text>
									<call-template name="endl" />
								</if>
								<text>return </text>
								<call-template name="sh.var">
									<with-param name="name" select="$prg.sh.parser.vName_OK" />
								</call-template>
							</with-param>
						</call-template>
					</with-param>
				</call-template>
				<call-template name="endl" />

				<!-- get current item -->
				<value-of select="$prg.sh.parser.vName_item" />
				<text>=</text>
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_input" />
					<with-param name="quoted" select="true()" />
					<with-param name="index">
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_index" />
						</call-template>
					</with-param>
				</call-template>
				<call-template name="endl" />
				<call-template name="endl" />

				<call-template name="sh.if">
					<with-param name="condition">
						<text>[ -z </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_item" />
							<with-param name="quoted" select="true()" />
						</call-template>
						<text> ]</text>
					</with-param>
					<with-param name="then">
						<text>return </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_OK" />
						</call-template>
					</with-param>
				</call-template>
				<call-template name="endl" />

				<if test="$prg.debug">
					<value-of select="$prg.sh.parser.fName_debug" />
					<text> "Processing </text>
					<call-template name="sh.var">
						<with-param name="name" select="$prg.sh.parser.vName_item" />
					</call-template>
					<text> [subindex: </text>
					<call-template name="sh.var">
						<with-param name="name" select="$prg.sh.parser.vName_subindex" />
					</call-template>
					<text>] (</text>
					<call-template name="sh.var">
						<with-param name="name" select="$prg.sh.parser.vName_index" />
					</call-template>
					<text> of </text>
					<call-template name="sh.var">
						<with-param name="name" select="$prg.sh.parser.vName_itemcount" />
					</call-template>
					<text>)"</text>
					<call-template name="endl" />
				</if>

				<!-- End of options -->
				<text>if [ </text>
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_item" />
					<with-param name="quoted" select="true()" />
				</call-template>
				<text> = "--" ]</text>
				<call-template name="endl" />
				<text>then</text>
				<call-template name="code.block">
					<with-param name="content">
						<call-template name="prg.sh.parser.copyValues" />
						<call-template name="endl" />
						<text>return </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_OK" />
						</call-template>
					</with-param>
				</call-template>

				<variable name="optionsNode" select="$programNode/prg:options" />

				<!-- long option -->
				<if test="$optionsNode//prg:names/prg:long">
					<call-template name="prg.sh.parser.longOptionNameElif">
						<with-param name="optionsNode" select="$programNode/prg:options" />
						<with-param name="onError" select="$onError" />
						<with-param name="onSuccess" select="$onSuccess" />
						<with-param name="onUnknownOption" select="$onUnknownOption" />
					</call-template>
				</if>

				<!-- short option -->
				<if test="$optionsNode//prg:names/prg:short">
					<call-template name="prg.sh.parser.shortOptionNameElif">
						<with-param name="optionsNode" select="$programNode/prg:options" />
						<with-param name="onError" select="$onError" />
						<with-param name="onSuccess" select="$onSuccess" />
						<with-param name="onUnknownOption" select="$onUnknownOption" />
					</call-template>
				</if>

				<!-- subcommand -->
				<text>elif </text>
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_subcommand_expected" />
				</call-template>
				<text> &amp;&amp; [ -z </text>
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_subcommand" />
					<with-param name="quoted" select="true()" />
				</call-template>
				<text> ] &amp;&amp; [ </text>
				<call-template name="sh.arrayLength">
					<with-param name="name" select="$prg.sh.parser.vName_values" />
				</call-template>
				<text> -eq 0 ]</text>
				<call-template name="endl" />
				<text>then</text>
				<call-template name="code.block">
					<with-param name="content">
						<call-template name="sh.case">
							<with-param name="case">
								<call-template name="sh.var">
									<with-param name="name" select="$prg.sh.parser.vName_item" />
								</call-template>
							</with-param>
							<with-param name="in">
								<for-each select="$programNode/prg:subcommands/prg:subcommand">
									<call-template name="sh.caseblock">
										<with-param name="case">
											<value-of select="./prg:name" />
											<for-each select="./prg:aliases/prg:alias">
												<text> | </text>
												<value-of select="." />
											</for-each>
										</with-param>
										<with-param name="content">
											<value-of select="$prg.sh.parser.vName_subcommand" />
											<text>="</text>
											<value-of select="./prg:name" />
											<text>"</text>
											<call-template name="prg.sh.parser.optionAddRequired">
												<with-param name="optionsNode" select="./prg:options" />
											</call-template>
										</with-param>
									</call-template>
								</for-each>
								<call-template name="sh.caseblock">
									<with-param name="case">
										<text>*</text>
									</with-param>
									<with-param name="content">
										<!-- It's the first value -->
										<value-of select="$prg.sh.parser.fName_addvalue" />
										<text> </text>
										<call-template name="sh.var">
											<with-param name="name" select="$prg.sh.parser.vName_item" />
											<with-param name="quoted" select="true()" />
										</call-template>
									</with-param>
								</call-template>
							</with-param>
						</call-template>
					</with-param>
				</call-template>

				<!-- values -->
				<text>else</text>
				<call-template name="code.block">
					<with-param name="content">
						<value-of select="$prg.sh.parser.fName_addvalue" />
						<text> </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_item" />
							<with-param name="quoted" select="true()" />
						</call-template>
					</with-param>
				</call-template>
				<text>fi</text>
				<call-template name="endl" />
				<text>return </text>
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_OK" />
				</call-template>
			</with-param>
		</call-template>
	</template>

	<template name="prg.sh.parser.parseFunction">
		<param name="programNode" select="." />
		<call-template name="sh.functionDefinition">
			<with-param name="name" select="$prg.sh.parser.fName_parse" />
			<with-param name="content">
				<call-template name="sh.while">
					<with-param name="condition">
						<text>[ </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_index" />
						</call-template>
						<text> -lt </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_itemcount" />
						</call-template>
						<text> ]</text>
					</with-param>
					<with-param name="do">
						<value-of select="$prg.sh.parser.fName_process_option" />
						<text> </text>
						<call-template name="sh.var">
							<with-param name="name" select="0" />
							<with-param name="quoted" select="true()" />
						</call-template>
						<call-template name="endl" />

						<call-template name="sh.if">
							<with-param name="condition">
								<text>[ -z </text>
								<call-template name="sh.var">
									<with-param name="name" select="$prg.sh.parser.vName_optiontail" />
									<with-param name="quoted" select="true()" />
								</call-template>
								<text> ]</text>
							</with-param>
							<with-param name="then">
								<call-template name="prg.sh.parser.indexIncrement" />
								<call-template name="endl" />
								<value-of select="$prg.sh.parser.vName_subindex" />
								<text>=0</text>
							</with-param>
							<with-param name="else">
								<call-template name="sh.varincrement">
									<with-param name="name" select="$prg.sh.parser.vName_subindex" />
								</call-template>
							</with-param>
						</call-template>
					</with-param>
				</call-template>
				<call-template name="endl" />
				<call-template name="endl" />

				<!-- Set group default options -->
				<for-each select="$programNode//prg:group/prg:default">
					<variable name="groupNode" select=".." />
					<variable name="prg.optionId" select="@id" />
					<variable name="optionNode" select="$groupNode/prg:options/*/@id[.=$optionId]/.." />
					<if test="$groupNode/prg:databinding/prg:variable and $optionNode/prg:databinding/prg:variable">
						<text># Set default option for group </text>
						<value-of select="$groupNode/@id"></value-of>
						<text> (if not already set)</text>
						<call-template name="endl" />
						<call-template name="sh.if">
							<with-param name="condition">
								<text>[ "${</text>
								<apply-templates select="$groupNode/prg:databinding/prg:variable" />
								<text>:0:1}" = "@" ]</text>
							</with-param>
							<with-param name="then">
								<apply-templates select="$groupNode/prg:databinding/prg:variable" />
								<text>="</text>
								<apply-templates select="$optionNode/prg:databinding/prg:variable" />
								<text>"</text>
								<call-template name="endl" />
								<value-of select="$prg.sh.parser.fName_setoptionpresence" />
								<text> </text>
								<value-of select="$groupNode/@id" />
							</with-param>
						</call-template>
						<call-template name="endl" />
					</if>
				</for-each>

				<!-- Check required options -->
				<value-of select="$prg.sh.parser.fName_checkrequired" />
				<call-template name="endl" />

				<!-- Check multiargument min attribute -->
				<value-of select="$prg.sh.parser.fName_checkminmax" />
				<call-template name="endl" />

				<!-- Return error count -->
				<variable name="errorCount">
					<call-template name="prg.prefixedName">
						<with-param name="name">
							<value-of select="$prg.sh.parser.variableNamePrefix" />
							<text>errorcount</text>
						</with-param>
					</call-template>
				</variable>
				<call-template name="endl" />

				<text>local </text>
				<value-of select="$errorCount" />
				<text>=</text>
				<call-template name="sh.arrayLength">
					<with-param name="name" select="$prg.sh.parser.vName_errors" />
				</call-template>
				<call-template name="endl" />

				<call-template name="sh.if">
					<with-param name="condition">
						<text>[ </text>
						<call-template name="sh.var">
							<with-param name="name" select="$errorCount" />
						</call-template>
						<text> -eq 1 ] &amp;&amp; [ -z </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_errors" />
							<with-param name="quoted" select="true()" />
						</call-template>
						<text> ]</text>
					</with-param>
					<with-param name="then">
						<value-of select="$errorCount" />
						<text>=0</text>
					</with-param>
				</call-template>

				<text>return </text>
				<call-template name="sh.var">
					<with-param name="name" select="$errorCount" />
				</call-template>

			</with-param>
		</call-template>
	</template>

	<!-- Main -->
	<template name="prg.sh.parser.main">
		<param name="programNode" select="." />
		<call-template name="prg.sh.parser.initialize">
			<with-param name="programNode" select="$programNode" />
		</call-template>
		<call-template name="prg.sh.parser.messageFunctions">
			<with-param name="programNode" select="$programNode" />
		</call-template>
		<call-template name="prg.sh.parser.pathAccessCheckFunction">
			<with-param name="programNode" select="$programNode" />
		</call-template>
		<call-template name="prg.sh.parser.optionSetPresenceFunctions">
			<with-param name="programNode" select="$programNode" />
		</call-template>
		<call-template name="prg.sh.parser.minmaxCheckFunction">
			<with-param name="programNode" select="$programNode" />
		</call-template>
		<call-template name="prg.sh.parser.enumCheckFunction">
			<with-param name="programNode" select="$programNode" />
		</call-template>
		<call-template name="prg.sh.parser.addValueFunction">
			<with-param name="programNode" select="$programNode" />
		</call-template>
		<call-template name="prg.sh.parser.subCommandOptionParseFunction">
			<with-param name="programNode" select="$programNode" />
		</call-template>
		<call-template name="prg.sh.parser.optionParseFunction">
			<with-param name="programNode" select="$programNode" />
		</call-template>
		<call-template name="prg.sh.parser.parseFunction">
			<with-param name="programNode" select="$programNode" />
		</call-template>
	</template>

</stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Shell parser function definitions -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">

	<import href="parser.base.xsl" />
	<import href="parser.variables.xsl" />

	<!-- Message functions -->
	<template name="prg.sh.parser.addMessageFunctionHelper">
		<param name="name" />
		<param name="table" select="$name" />
		<param name="onEnd" />
		<param name="interpreter" />

		<variable name="tableName">
			<value-of select="$prg.prefix" />
			<value-of select="$prg.sh.parser.variableNamePrefix" />
			<value-of select="$table" />
			<text>s</text>
		</variable>

		<call-template name="sh.functionDefinition">
			<with-param name="name">
				<value-of select="$prg.prefix" />
				<value-of select="$prg.sh.parser.functionNamePrefix" />
				<text>add</text>
				<value-of select="$name" />
			</with-param>
			<with-param name="interpreter" select="$interpreter" />
			<with-param name="content">
				<call-template name="sh.local">
					<with-param name="name" select="'message'" />
					<with-param name="interpreter" select="$interpreter" />
					<with-param name="value" select="'${1}'" />
				</call-template>
				<value-of select="$sh.endl" />
				<call-template name="sh.local">
					<with-param name="name" select="'m'" />
					<with-param name="interpreter" select="$interpreter" />
					<with-param name="value">
						<text>[</text>
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
					</with-param>
				</call-template>
				<value-of select="$sh.endl" />

				<call-template name="sh.local">
					<with-param name="name" select="'c'" />
					<with-param name="interpreter" select="$interpreter" />
					<with-param name="value">
						<call-template name="sh.arrayLength">
							<with-param name="name" select="$tableName" />
						</call-template>
					</with-param>
					<with-param name="quoted" select="false()" />
				</call-template>
				<value-of select="$sh.endl" />

				<text>c=$(expr </text>
				<call-template name="sh.var">
					<with-param name="name">
						<text>c</text>
					</with-param>
				</call-template>
				<text> + </text>
				<value-of select="$prg.sh.parser.var_startindex" />
				<text>)</text>
				<value-of select="$sh.endl" />


				<value-of select="$tableName" />
				<text>[</text>
				<call-template name="sh.var">
					<with-param name="name">
						<text>c</text>
					</with-param>
				</call-template>
				<text>]="</text>
				<call-template name="sh.var">
					<with-param name="name">
						<text>m</text>
					</with-param>
				</call-template>
				<text>"</text>
				<if test="string-length($onEnd)">
					<value-of select="$sh.endl" />
					<value-of select="$onEnd" />
				</if>
			</with-param>
		</call-template>
	</template>

	<template name="prg.sh.parser.displayErrorFunction">
		<param name="interpreter" />
		<call-template name="sh.functionDefinition">
			<with-param name="name" select="$prg.sh.parser.fName_displayerrors" />
			<with-param name="interpreter" select="$interpreter" />
			<with-param name="content">
				<call-template name="sh.incrementalFor">
					<with-param name="init" select="$prg.sh.parser.var_startindex" />
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
		<param name="interpreter" />

		<!-- addwarning -->
		<call-template name="prg.sh.parser.addMessageFunctionHelper">
			<with-param name="name">
				<text>warning</text>
			</with-param>
			<with-param name="interpreter" select="$interpreter" />
		</call-template>

		<!-- adderror -->
		<call-template name="prg.sh.parser.addMessageFunctionHelper">
			<with-param name="name">
				<text>error</text>
			</with-param>
			<with-param name="interpreter" select="$interpreter" />
		</call-template>

		<call-template name="prg.sh.parser.addMessageFunctionHelper">
			<with-param name="name" select="'fatalerror'" />
			<with-param name="table" select="'error'" />
			<with-param name="onEnd">
				<value-of select="$prg.sh.parser.vName_aborted" />
				<text>=true</text>
			</with-param>
			<with-param name="interpreter" select="$interpreter" />
		</call-template>
		<value-of select="$sh.endl" />

		<!-- displayerror -->
		<call-template name="prg.sh.parser.displayErrorFunction">
			<with-param name="interpreter" select="$interpreter" />
		</call-template>
		<value-of select="$sh.endl" />

		<!-- parser_debug -->
		<if test="$prg.debug">
			<call-template name="sh.functionDefinition">
				<with-param name="name" select="$prg.sh.parser.fName_debug" />
				<with-param name="interpreter" select="$interpreter" />
				<with-param name="content">
					<text>echo "DEBUG: ${@}"</text>
				</with-param>
			</call-template>
		</if>
		<value-of select="$sh.endl" />

	</template>

	<!-- Value check functions -->

	<!-- File system item functions -->

	<template name="prg.sh.parser.pathAccessCheckFunction">
		<param name="interpreter" />

		<call-template name="sh.functionDefinition">
			<with-param name="name" select="$prg.sh.parser.fName_pathaccesscheck" />
			<with-param name="interpreter" select="$interpreter" />
			<with-param name="content">
				<call-template name="sh.local">
					<with-param name="name" select="'file'" />
					<with-param name="interpreter" select="$interpreter" />
					<with-param name="value">
						<call-template name="sh.var">
							<with-param name="name" select="1" />
						</call-template>
					</with-param>
				</call-template>
				<value-of select="$sh.endl" />

				<!-- We can't check access on non-existing file -->
				<call-template name="sh.if">
					<with-param name="condition">
						<text>[ ! -a "${file}" ]</text>
					</with-param>
					<with-param name="then">
						<text>return 0</text>
					</with-param>
				</call-template>
				<value-of select="$sh.endl" />

				<call-template name="sh.local">
					<with-param name="name" select="'accessString'" />
					<with-param name="interpreter" select="$interpreter" />
					<with-param name="value">
						<call-template name="sh.var">
							<with-param name="name" select="2" />
						</call-template>
					</with-param>
				</call-template>

				<value-of select="$sh.endl" />
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
						<value-of select="' '" />
						<call-template name="sh.var">
							<with-param name="name">
								<text>file</text>
							</with-param>
							<with-param name="quoted" />
						</call-template>
						<text> ] || return 1;</text>
						<value-of select="$sh.endl" />
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
				<value-of select="$sh.endl" />
				<text>return 0</text>
			</with-param>
		</call-template>
	</template>

	<template name="prg.sh.parser.optionSetPresenceFunctions">
		<param name="interpreter" />

		<call-template name="sh.functionDefinition">
			<with-param name="name" select="$prg.sh.parser.fName_setoptionpresence" />
			<with-param name="interpreter" select="$interpreter" />
			<with-param name="content">
				<call-template name="sh.incrementalFor">
					<with-param name="init" select="$prg.sh.parser.var_startindex" />
					<with-param name="limit">
						<text>$(expr </text>
						<value-of select="$prg.sh.parser.var_startindex" />
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
						<call-template name="sh.local">
							<with-param name="name" select="'idPart'" />
							<with-param name="interpreter" select="$interpreter" />
							<with-param name="value">
								<text>$(echo </text>
								<value-of select="$requiredVar" />
								<text> | cut -f 1 -d":" )</text>
							</with-param>
						</call-template>
						<value-of select="$sh.endl" />

						<call-template name="sh.if">
							<with-param name="condition">
								<text>[ </text>
								<call-template name="sh.var">
									<with-param name="name">
										<text>idPart</text>
									</with-param>
									<with-param name="quoted" select="true()" />
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
								<value-of select="$sh.endl" />
								<text>return 0</text>
							</with-param>
						</call-template>
					</with-param>
				</call-template>
				<value-of select="$sh.endl" />
				<text>return 1</text>
			</with-param>
		</call-template>

		<call-template name="sh.functionDefinition">
			<with-param name="name" select="$prg.sh.parser.fName_checkrequired" />
			<with-param name="interpreter" select="$interpreter" />
			<with-param name="content">
				<call-template name="sh.comment">
					<with-param name="content">
						<text>First round: set default values</text>
					</with-param>
				</call-template>
				<value-of select="$sh.endl" />

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

				<variable name="init" select="$prg.sh.parser.var_startindex" />
				<variable name="limit">
					<text>$(expr </text>
					<value-of select="$prg.sh.parser.var_startindex" />
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
						<call-template name="sh.local">
							<with-param name="name" select="'todoPart'" />
							<with-param name="interpreter" select="$interpreter" />
							<with-param name="value">
								<text>$(echo </text>
								<value-of select="$requiredVar" />
								<text> | cut -f 3 -d":" )"</text>
								<value-of select="$sh.endl" />
								<text>[ -z "${todoPart}" ] || eval "${todoPart}</text>
							</with-param>
						</call-template>
					</with-param>
				</call-template>
				<value-of select="$sh.endl" />

				<call-template name="sh.local">
					<with-param name="name" select="'c'" />
					<with-param name="interpreter" select="$interpreter" />
					<with-param name="value" select="0" />
					<with-param name="quoted" select="false()" />
				</call-template>

				<value-of select="$sh.endl" />
				<call-template name="sh.incrementalFor">
					<with-param name="init" select="$init" />
					<with-param name="limit" select="$limit" />
					<with-param name="do">
						<call-template name="sh.if">
							<with-param name="condition" select="$isNotEmpty" />
							<with-param name="then">
								<call-template name="sh.local">
									<with-param name="name" select="'displayPart'" />
									<with-param name="interpreter" select="$interpreter" />
									<with-param name="value">
										<text>$(echo </text>
										<value-of select="$requiredVar" />
										<text> | cut -f 2 -d":" )</text>
									</with-param>
								</call-template>
								<value-of select="$sh.endl" />
								<call-template name="sh.arrayAppend">
									<with-param name="name" select="$prg.sh.parser.vName_errors" />
									<with-param name="startIndex" select="$prg.sh.parser.var_startindex" />
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
								<value-of select="$sh.endl" />

								<call-template name="sh.varincrement">
									<with-param name="name">
										<text>c</text>
									</with-param>
								</call-template>
							</with-param>
						</call-template>
					</with-param>
				</call-template>
				<value-of select="$sh.endl" />
				<text>return </text>
				<call-template name="sh.var">
					<with-param name="name">
						<text>c</text>
					</with-param>
				</call-template>
			</with-param>
		</call-template>
	</template>

	<template name="prg.sh.parser.setDefaultArgumentsFunction">
		<param name="programNode" />
		<param name="interpreter" />

		<call-template name="sh.functionDefinition">
			<with-param name="name" select="$prg.sh.parser.fName_setdefaultarguments" />
			<with-param name="interpreter" select="$interpreter" />
			<with-param name="content">
				<call-template name="sh.local">
					<with-param name="name" select="$prg.sh.parser.vName_set_default" />
					<with-param name="interpreter" select="$interpreter" />
					<with-param name="value" select="'false'" />
					<with-param name="quoted" select="false()" />
				</call-template>
				<value-of select="$sh.endl" />

				<!-- Global options -->
				<call-template name="prg.sh.parser.setDefaultArguments">
					<with-param name="rootNode" select="$programNode" />
					<with-param name="interpreter" select="$interpreter" />
				</call-template>

				<!-- Subcommand options -->
				<if test="$programNode/prg:subcommands">
					<call-template name="sh.case">
						<with-param name="case">
							<call-template name="sh.var">
								<with-param name="name" select="$prg.sh.parser.vName_subcommand" />
							</call-template>
						</with-param>
						<with-param name="in">
							<for-each select="$programNode/prg:subcommands/*">
								<call-template name="sh.caseblock">
									<with-param name="case">
										<value-of select="./prg:name" />
										<for-each select="./prg:aliases/prg:alias">
											<text> | </text>
											<value-of select="." />
										</for-each>
									</with-param>
									<with-param name="content">
										<call-template name="prg.sh.parser.setDefaultArguments">
											<with-param name="rootNode" select="." />
											<with-param name="interpreter" select="$interpreter" />
										</call-template>
									</with-param>
								</call-template>
							</for-each>
						</with-param>
					</call-template>
				</if>
			</with-param>
		</call-template>
	</template>

	<template name="prg.sh.parser.minmaxCheckFunction">
		<param name="programNode" />
		<param name="interpreter" />

		<call-template name="sh.functionDefinition">
			<with-param name="name" select="$prg.sh.parser.fName_checkminmax" />
			<with-param name="interpreter" select="$interpreter" />
			<with-param name="content">
				<call-template name="sh.local">
					<with-param name="name" select="'errorCount'" />
					<with-param name="interpreter" select="$interpreter" />
					<with-param name="value" select="0" />
					<with-param name="quoted" select="false()" />
				</call-template>
				<value-of select="$sh.endl" />

				<call-template name="sh.comment">
					<with-param name="content">
						<text>Check min argument for multiargument</text>
					</with-param>
				</call-template>
				<value-of select="$sh.endl" />

				<for-each select="$programNode//prg:multiargument[@min &gt; 0]">
					<variable name="optionName">
						<call-template name="prg.sh.optionDisplayName">
							<with-param name="optionNode" select="." />
						</call-template>
					</variable>
					<if test="prg:databinding/prg:variable">
						<variable name="argCountVariable">
							<call-template name="sh.arrayLength">
								<with-param name="name">
									<apply-templates select="prg:databinding/prg:variable" />
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

								<value-of select="$sh.endl" />
								<call-template name="sh.varincrement">
									<with-param name="name">
										<text>errorCount</text>
									</with-param>
								</call-template>
							</with-param>
						</call-template>
					</if>
				</for-each>

				<value-of select="$sh.endl" />
				<text>return ${errorCount}</text>
			</with-param>
		</call-template>
	</template>

	<template name="prg.sh.parser.numberLesserEqualCheckFunction">
		<param name="interpreter" />
		
		<call-template name="sh.functionDefinition">
			<with-param name="name">
				<value-of select="$prg.sh.parser.fName_numberLesserEqualcheck" />
			</with-param>
			<with-param name="interpreter" select="$interpreter" />
			<with-param name="content">
				<call-template name="sh.local">
					<with-param name="name" select="'hasBC'" />
					<with-param name="quoted" select="false()" />
					<with-param name="value">
						<text>false</text>
					</with-param>
				</call-template>
				<text></text>
				<value-of select="$sh.endl" />
				<text>which bc </text>
				<call-template name="sh.chunk.nullRedirection" />
				<text> &amp;&amp; hasBC=true</text>
				<value-of select="$sh.endl" />
				
				<call-template name="sh.if">
					<with-param name="condition">
						<call-template name="sh.var">
							<with-param name="name" select="'hasBC'" />
						</call-template>
					</with-param>
					<with-param name="then">
						<text>[ "$(echo "${1} &lt;= ${2}" | bc)" = "0" ] &amp;&amp; return 1</text>
					</with-param>
					<with-param name="else">
						<!-- Split into integral & decimal part -->
						<call-template name="sh.local">
							<with-param name="interpreter" select="$interpreter" />
							<with-param name="name" select="'a_int'" />
							<with-param name="value">
								<text>$(echo "${1}" | cut -f 1 -d".")</text>
							</with-param>
						</call-template>
						<value-of select="$sh.endl" />
						<call-template name="sh.local">
							<with-param name="interpreter" select="$interpreter" />
							<with-param name="name" select="'a_dec'" />
							<with-param name="value">
								<text>$(echo "${1}" | cut -f 2 -d".")</text>
							</with-param>
						</call-template>
						<value-of select="$sh.endl" />
						<text>[ "${a_dec}" = "${1}" ] &amp;&amp; a_dec="0"</text>
						
						<value-of select="$sh.endl" />
						<call-template name="sh.local">
							<with-param name="interpreter" select="$interpreter" />
							<with-param name="name" select="'b_int'" />
							<with-param name="value">
								<text>$(echo "${2}" | cut -f 1 -d".")</text>
							</with-param>
						</call-template>
						<value-of select="$sh.endl" />
						<call-template name="sh.local">
							<with-param name="interpreter" select="$interpreter" />
							<with-param name="name" select="'b_dec'" />
							<with-param name="value">
								<text>$(echo "${2}" | cut -f 2 -d".")</text>
							</with-param>
						</call-template>
						<value-of select="$sh.endl" />
						<text>[ "${b_dec}" = "${2}" ] &amp;&amp; b_dec="0"</text>
						<value-of select="$sh.endl" />
						
						<text>[ ${a_int} -lt ${b_int} ] &amp;&amp; return 0</text>
						<value-of select="$sh.endl" />
						<text>[ ${a_int} -gt ${b_int} ] &amp;&amp; return 1</text>
						<value-of select="$sh.endl" />
						<text>([ ${a_int} -ge 0 ] &amp;&amp; [ ${a_dec} -gt ${b_dec} ]) &amp;&amp; return 1</text>
						<value-of select="$sh.endl" />
						<text>([ ${a_int} -lt 0 ] &amp;&amp; [ ${b_dec} -gt ${a_dec} ]) &amp;&amp; return 1</text>
					</with-param>
				</call-template>
			
				<text>return 0</text>
			</with-param>
		</call-template>
	</template>

	<template name="prg.sh.parser.enumCheckFunction">
		<param name="interpreter" />

		<call-template name="sh.functionDefinition">
			<with-param name="name">
				<value-of select="$prg.sh.parser.fName_enumcheck" />
			</with-param>
			<with-param name="interpreter" select="$interpreter" />
			<with-param name="content">
				<call-template name="sh.local">
					<with-param name="name" select="'ref'" />
					<with-param name="interpreter" select="$interpreter" />
					<with-param name="value">
						<call-template name="sh.var">
							<with-param name="name" select="1" />
						</call-template>
					</with-param>
				</call-template>
				<value-of select="$sh.endl" />

				<text>shift 1</text>
				<value-of select="$sh.endl" />

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
				<value-of select="$sh.endl" />
				<text>return 1</text>
			</with-param>
		</call-template>
	</template>

	<!-- Check and add anonymous value -->
	<template name="prg.sh.parser.addValueFunction">
		<param name="programNode" />
		<param name="interpreter" />

		<call-template name="sh.functionDefinition">
			<with-param name="name" select="$prg.sh.parser.fName_addvalue" />
			<with-param name="interpreter" select="$interpreter" />
			<with-param name="content">
				<call-template name="sh.local">
					<with-param name="name" select="'position'" />
					<with-param name="interpreter" select="$interpreter" />
					<with-param name="value">
						<call-template name="sh.arrayLength">
							<with-param name="name" select="$prg.sh.parser.vName_values" />
						</call-template>
					</with-param>
					<with-param name="quoted" select="false()" />
				</call-template>
				<value-of select="$sh.endl" />

				<call-template name="sh.local">
					<with-param name="name" select="'value'" />
					<with-param name="interpreter" select="$interpreter" />
				</call-template>
				<value-of select="$sh.endl" />

				<text>if [ $# -gt 0 ] &amp;&amp; [ ! -z "${1}" ]; then value="${1}"; else return </text>
				<value-of select="$prg.sh.parser.var_ERROR" />
				<text>; fi</text>
				<value-of select="$sh.endl" />
				<text>shift</text>
				<value-of select="$sh.endl" />

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
									<with-param name="interpreter" select="$interpreter" />
								</call-template>
							</when>
							<otherwise>
								<call-template name="prg.sh.parser.addGlobalError">
									<with-param name="value">
										<text>"Positional argument not allowed"</text>
									</with-param>
								</call-template>
								<value-of select="$sh.endl" />
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
													<value-of select="$sh.endl" />
													<text>return </text>
													<value-of select="$prg.sh.parser.var_ERROR" />
												</otherwise>
											</choose>
										</with-param>
									</call-template>
								</for-each>
								<call-template name="sh.caseblock">
									<with-param name="case">
										<text>*</text>
									</with-param>
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
					<with-param name="startIndex" select="$prg.sh.parser.var_startindex" />
					<with-param name="value">
						<call-template name="sh.var">
							<with-param name="name" select="'value'" />
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
		<param name="interpreter" />

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
			<with-param name="interpreter" select="$interpreter" />
			<with-param name="content">
				<call-template name="sh.local">
					<with-param name="name" select="$prg.sh.parser.vName_integer" />
					<with-param name="interpreter" select="$interpreter" />
				</call-template>
				<value-of select="$sh.endl" />
				<call-template name="sh.local">
					<with-param name="name" select="$prg.sh.parser.vName_decimal" />
					<with-param name="interpreter" select="$interpreter" />
				</call-template>
				<value-of select="$sh.endl" />
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
				<value-of select="$sh.endl" />

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
					<value-of select="$sh.endl" />
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
				<value-of select="$sh.endl" />

				<choose>
					<!-- There is at least one option in one subcommand -->
					<when test="$programNode/prg:subcommands/prg:subcommand[prg:options]">
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
														<with-param name="interpreter" select="$interpreter" />
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
														<with-param name="interpreter" select="$interpreter" />
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
						<value-of select="$sh.endl" />
						<text>return </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_SC_OK" />
						</call-template>
					</when>
					<otherwise>
						<text>return </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_SC_SKIP" />
						</call-template>
					</otherwise>
				</choose>
			</with-param>
		</call-template>
	</template>

	<!-- Main option parser function -->
	<template name="prg.sh.parser.optionParseFunction">
		<param name="programNode" select="." />
		<param name="interpreter" />

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
			<value-of select="$prg.sh.parser.fName_addfatalerror" />
			<text> "Unknown option \"</text>
			<call-template name="sh.var">
				<with-param name="name" select="$prg.sh.parser.vName_option" />
			</call-template>
			<text>\""</text>
			<value-of select="$sh.endl" />
			<text>return </text>
			<value-of select="$prg.sh.parser.var_ERROR" />
		</variable>

		<call-template name="sh.functionDefinition">
			<with-param name="name" select="$prg.sh.parser.fName_process_option" />
			<with-param name="interpreter" select="$interpreter" />
			<with-param name="content">
				<call-template name="sh.local">
					<with-param name="name" select="$prg.sh.parser.vName_integer" />
					<with-param name="interpreter" select="$interpreter" />
				</call-template>
				<value-of select="$sh.endl" />
				<call-template name="sh.local">
					<with-param name="name" select="$prg.sh.parser.vName_decimal" />
					<with-param name="interpreter" select="$interpreter" />
				</call-template>
				<value-of select="$sh.endl" />

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
							<value-of select="$sh.endl" />
						</if>

						<call-template name="sh.if">
							<with-param name="condition">
								<value-of select="$prg.sh.parser.fName_process_subcommand_option" />
							</with-param>
							<with-param name="then">
								<if test="$prg.debug">
									<value-of select="$prg.sh.parser.fName_debug" />
									<text> "Subcommand option parsing success"</text>
									<value-of select="$sh.endl" />
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
									<value-of select="$sh.endl" />
								</if>
								<text>return </text>
								<call-template name="sh.var">
									<with-param name="name" select="$prg.sh.parser.vName_OK" />
								</call-template>
							</with-param>
						</call-template>
					</with-param>
				</call-template>
				<value-of select="$sh.endl" />

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
				<value-of select="$sh.endl" />
				<value-of select="$sh.endl" />

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
				<value-of select="$sh.endl" />

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
					<value-of select="$sh.endl" />
				</if>

				<!-- End of options -->
				<text>if [ </text>
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_item" />
					<with-param name="quoted" select="true()" />
				</call-template>
				<text> = "--" ]</text>
				<value-of select="$sh.endl" />
				<text>then</text>
				<call-template name="code.block">
					<with-param name="content">
						<call-template name="prg.sh.parser.copyValues" />
						<value-of select="$sh.endl" />
						<text>return </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_OK" />
						</call-template>
					</with-param>
				</call-template>

				<!-- End of option values -->
				<text>elif [ </text>
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_item" />
					<with-param name="quoted" select="true()" />
				</call-template>
				<text> = "-" ]</text>
				<value-of select="$sh.endl" />
				<text>then</text>
				<call-template name="code.block">
					<with-param name="content">
						<text>return </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_OK" />
						</call-template>
					</with-param>
				</call-template>

				<!-- Protected value -->
				<text>elif [ </text>
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_item" />
					<with-param name="quoted" select="true()" />
					<with-param name="length" select="2" />
				</call-template>
				<text> = "\-" ]</text>
				<value-of select="$sh.endl" />
				<text>then</text>
				<call-template name="code.block">
					<with-param name="content">
						<value-of select="$prg.sh.parser.fName_addvalue" />
						<value-of select="' '" />
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_item" />
							<with-param name="quoted" select="true()" />
							<with-param name="start" select="1" />
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
						<with-param name="interpreter" select="$interpreter" />
					</call-template>
				</if>

				<!-- short option -->
				<if test="$optionsNode//prg:names/prg:short">
					<call-template name="prg.sh.parser.shortOptionNameElif">
						<with-param name="optionsNode" select="$programNode/prg:options" />
						<with-param name="onError" select="$onError" />
						<with-param name="onSuccess" select="$onSuccess" />
						<with-param name="onUnknownOption" select="$onUnknownOption" />
						<with-param name="interpreter" select="$interpreter" />
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
				<value-of select="$sh.endl" />
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
										<value-of select="' '" />
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
						<value-of select="' '" />
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_item" />
							<with-param name="quoted" select="true()" />
						</call-template>
					</with-param>
				</call-template>
				<text>fi</text>
				<value-of select="$sh.endl" />
				<text>return </text>
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_OK" />
				</call-template>
			</with-param>
		</call-template>
	</template>

	<template name="prg.sh.parser.parseFunction">
		<param name="programNode" select="." />
		<param name="interpreter" />

		<call-template name="sh.functionDefinition">
			<with-param name="name" select="$prg.sh.parser.fName_parse" />
			<with-param name="interpreter" select="$interpreter" />

			<with-param name="content">
				<value-of select="$prg.sh.parser.vName_aborted" />
				<text>=false</text>
				<value-of select="$sh.endl" />

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
						<text> ] &amp;&amp; ! </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_aborted" />
						</call-template>
					</with-param>
					<with-param name="do">
						<value-of select="$prg.sh.parser.fName_process_option" />
						<value-of select="$sh.endl" />

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
								<value-of select="$sh.endl" />
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
				<value-of select="$sh.endl" />
				<value-of select="$sh.endl" />

				<call-template name="sh.if">
					<with-param name="condition">
						<text>! </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_aborted" />
						</call-template>
					</with-param>
					<with-param name="then">
						<!-- Set group default options -->
						<for-each select="$programNode//prg:group[prg:default]">
							<variable name="groupNode" select="." />
							<variable name="optionIdRef" select="./prg:default/@id" />
							<variable name="optionNode" select="$groupNode/prg:options/*/@id[.=$optionIdRef]/.." />
							<variable name="groupNodeId">
								<call-template name="prg.optionId">
									<with-param name="optionNode" select="$groupNode" />
								</call-template>
							</variable>

							<if test="$groupNode/prg:databinding/prg:variable and $optionNode/prg:databinding/prg:variable">
								<text># Set default option for group </text>
								<value-of select="$groupNodeId" />
								<text> (if not already set)</text>
								<value-of select="$sh.endl" />
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
										<value-of select="$sh.endl" />
										<value-of select="$prg.sh.parser.fName_setoptionpresence" />
										<value-of select="' '" />
										<value-of select="$groupNodeId" />
									</with-param>
								</call-template>
								<value-of select="$sh.endl" />
							</if>
						</for-each>

						<!-- Set options with defaults value -->
						<value-of select="$prg.sh.parser.fName_setdefaultarguments" />
						<value-of select="$sh.endl" />

						<!-- Check required options -->
						<value-of select="$prg.sh.parser.fName_checkrequired" />
						<value-of select="$sh.endl" />

						<!-- Check multiargument min attribute -->
						<value-of select="$prg.sh.parser.fName_checkminmax" />
					</with-param>
				</call-template>
				<value-of select="$sh.endl" />
				<value-of select="$sh.endl" />

				<!-- Return error count -->
				<variable name="errorCount">
					<call-template name="prg.prefixedName">
						<with-param name="name">
							<value-of select="$prg.sh.parser.variableNamePrefix" />
							<text>errorcount</text>
						</with-param>
					</call-template>
				</variable>
				<value-of select="$sh.endl" />

				<call-template name="sh.local">
					<with-param name="name" select="$errorCount" />
					<with-param name="interpreter" select="$interpreter" />
					<with-param name="value">
						<call-template name="sh.arrayLength">
							<with-param name="name" select="$prg.sh.parser.vName_errors" />
						</call-template>
					</with-param>
					<with-param name="quoted" select="false()" />
				</call-template>
				<value-of select="$sh.endl" />

				<!-- ???
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
				 -->

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
		<param name="interpreter" />

		<call-template name="prg.sh.parser.initialize">
			<with-param name="programNode" select="$programNode" />
			<with-param name="interpreter" select="$interpreter" />
		</call-template>
		<call-template name="prg.sh.parser.messageFunctions">
			<with-param name="programNode" select="$programNode" />
			<with-param name="interpreter" select="$interpreter" />
		</call-template>
		<call-template name="prg.sh.parser.pathAccessCheckFunction">
			<with-param name="programNode" select="$programNode" />
			<with-param name="interpreter" select="$interpreter" />
		</call-template>
		<call-template name="prg.sh.parser.optionSetPresenceFunctions">
			<with-param name="programNode" select="$programNode" />
			<with-param name="interpreter" select="$interpreter" />
		</call-template>
		<call-template name="prg.sh.parser.setDefaultArgumentsFunction">
			<with-param name="programNode" select="$programNode" />
			<with-param name="interpreter" select="$interpreter" />
		</call-template>
		<call-template name="prg.sh.parser.minmaxCheckFunction">
			<with-param name="programNode" select="$programNode" />
			<with-param name="interpreter" select="$interpreter" />
		</call-template>
		<call-template name="prg.sh.parser.numberLesserEqualCheckFunction">
			<with-param name="programNode" select="$programNode" />
			<with-param name="interpreter" select="$interpreter" />
		</call-template>
		<call-template name="prg.sh.parser.enumCheckFunction">
			<with-param name="programNode" select="$programNode" />
			<with-param name="interpreter" select="$interpreter" />
		</call-template>
		<call-template name="prg.sh.parser.addValueFunction">
			<with-param name="programNode" select="$programNode" />
			<with-param name="interpreter" select="$interpreter" />
		</call-template>
		<call-template name="prg.sh.parser.subCommandOptionParseFunction">
			<with-param name="programNode" select="$programNode" />
			<with-param name="interpreter" select="$interpreter" />
		</call-template>
		<call-template name="prg.sh.parser.optionParseFunction">
			<with-param name="programNode" select="$programNode" />
			<with-param name="interpreter" select="$interpreter" />
		</call-template>
		<call-template name="prg.sh.parser.parseFunction">
			<with-param name="programNode" select="$programNode" />
			<with-param name="interpreter" select="$interpreter" />
		</call-template>
	</template>

</stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Shell parser function definitions -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">

	<xsl:import href="parser.base.xsl" />
	<xsl:import href="parser.variables.xsl" />

	<!-- Message functions -->
	<xsl:template name="prg.sh.parser.addMessageFunctionHelper">
		<xsl:param name="name" />
		<xsl:param name="table" select="$name" />
		<xsl:param name="onEnd" />
		<xsl:param name="interpreter" />

		<xsl:variable name="tableName">
			<xsl:value-of select="$prg.prefix" />
			<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
			<xsl:value-of select="$table" />
			<xsl:text>s</xsl:text>
		</xsl:variable>

		<xsl:call-template name="sh.functionDefinition">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.prefix" />
				<xsl:value-of select="$prg.sh.parser.functionNamePrefix" />
				<xsl:text>add</xsl:text>
				<xsl:value-of select="$name" />
			</xsl:with-param>
			<xsl:with-param name="interpreter" select="$interpreter" />
			<xsl:with-param name="content">
				<xsl:call-template name="sh.local">
					<xsl:with-param name="name" select="'message'" />
					<xsl:with-param name="interpreter" select="$interpreter" />
					<xsl:with-param name="value" select="'${1}'" />
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />
				<xsl:call-template name="sh.local">
					<xsl:with-param name="name" select="'m'" />
					<xsl:with-param name="interpreter" select="$interpreter" />
					<xsl:with-param name="value">
						<xsl:text>[</xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_option" />
						</xsl:call-template>
						<xsl:text>:</xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_index" />
						</xsl:call-template>
						<xsl:text>:</xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_subindex" />
						</xsl:call-template>
						<xsl:text>] </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name">
								<xsl:text>message</xsl:text>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />

				<xsl:call-template name="sh.local">
					<xsl:with-param name="name" select="'c'" />
					<xsl:with-param name="interpreter" select="$interpreter" />
					<xsl:with-param name="value">
						<xsl:call-template name="sh.arrayLength">
							<xsl:with-param name="name" select="$tableName" />
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="quoted" select="false()" />
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />

				<xsl:text>c=$(expr </xsl:text>
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name">
						<xsl:text>c</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:text> + </xsl:text>
				<xsl:value-of select="$prg.sh.parser.var_startindex" />
				<xsl:text>)</xsl:text>
				<xsl:value-of select="$sh.endl" />


				<xsl:value-of select="$tableName" />
				<xsl:text>[</xsl:text>
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name">
						<xsl:text>c</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:text>]="</xsl:text>
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name">
						<xsl:text>m</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:text>"</xsl:text>
				<xsl:if test="string-length($onEnd)">
					<xsl:value-of select="$sh.endl" />
					<xsl:value-of select="$onEnd" />
				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.sh.parser.displayErrorFunction">
		<xsl:param name="interpreter" />
		<xsl:call-template name="sh.functionDefinition">
			<xsl:with-param name="name" select="$prg.sh.parser.fName_displayerrors" />
			<xsl:with-param name="interpreter" select="$interpreter" />
			<xsl:with-param name="content">
				<xsl:call-template name="sh.incrementalFor">
					<xsl:with-param name="init" select="$prg.sh.parser.var_startindex" />
					<xsl:with-param name="operator">
						<xsl:text>&lt;</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="limit">
						<xsl:call-template name="sh.arrayLength">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_errors" />
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="do">
						<xsl:text>echo -e "\t- </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_errors" />
							<xsl:with-param name="index">
								<xsl:call-template name="sh.var">
									<xsl:with-param name="name">
										<xsl:text>i</xsl:text>
									</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
						<xsl:text>"</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.sh.parser.messageFunctions">
		<xsl:param name="interpreter" />

		<!-- addwarning -->
		<xsl:call-template name="prg.sh.parser.addMessageFunctionHelper">
			<xsl:with-param name="name">
				<xsl:text>warning</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="interpreter" select="$interpreter" />
		</xsl:call-template>

		<!-- adderror -->
		<xsl:call-template name="prg.sh.parser.addMessageFunctionHelper">
			<xsl:with-param name="name">
				<xsl:text>error</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="interpreter" select="$interpreter" />
		</xsl:call-template>

		<xsl:call-template name="prg.sh.parser.addMessageFunctionHelper">
			<xsl:with-param name="name" select="'fatalerror'" />
			<xsl:with-param name="table" select="'error'" />
			<xsl:with-param name="onEnd">
				<xsl:value-of select="$prg.sh.parser.vName_aborted" />
				<xsl:text>=true</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="interpreter" select="$interpreter" />
		</xsl:call-template>
		<xsl:value-of select="$sh.endl" />

		<!-- displayerror -->
		<xsl:call-template name="prg.sh.parser.displayErrorFunction">
			<xsl:with-param name="interpreter" select="$interpreter" />
		</xsl:call-template>
		<xsl:value-of select="$sh.endl" />

		<!-- parser_debug -->
		<xsl:if test="$prg.debug">
			<xsl:call-template name="sh.functionDefinition">
				<xsl:with-param name="name" select="$prg.sh.parser.fName_debug" />
				<xsl:with-param name="interpreter" select="$interpreter" />
				<xsl:with-param name="content">
					<xsl:text>echo "DEBUG: ${@}"</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:value-of select="$sh.endl" />

	</xsl:template>

	<!-- Value check functions -->

	<!-- File system item functions -->

	<xsl:template name="prg.sh.parser.pathAccessCheckFunction">
		<xsl:param name="interpreter" />

		<xsl:call-template name="sh.functionDefinition">
			<xsl:with-param name="name" select="$prg.sh.parser.fName_pathaccesscheck" />
			<xsl:with-param name="interpreter" select="$interpreter" />
			<xsl:with-param name="content">
				<xsl:call-template name="sh.local">
					<xsl:with-param name="name" select="'file'" />
					<xsl:with-param name="interpreter" select="$interpreter" />
					<xsl:with-param name="value">
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="1" />
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />

				<!-- We can't check access on non-existing file -->
				<xsl:call-template name="sh.if">
					<xsl:with-param name="condition">
						<xsl:text>[ ! -a "${file}" ]</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="then">
						<xsl:text>return 0</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />

				<xsl:call-template name="sh.local">
					<xsl:with-param name="name" select="'accessString'" />
					<xsl:with-param name="interpreter" select="$interpreter" />
					<xsl:with-param name="value">
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="2" />
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>

				<xsl:value-of select="$sh.endl" />
				<xsl:call-template name="sh.while">
					<xsl:with-param name="condition">
						<xsl:text>[ ! -z </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name">
								<xsl:text>accessString</xsl:text>
							</xsl:with-param>
							<xsl:with-param name="quoted" select="true()" />
						</xsl:call-template>
						<xsl:text> ]</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="do">
						<xsl:text>[ -</xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name">
								<xsl:text>accessString</xsl:text>
							</xsl:with-param>
							<xsl:with-param name="start" select="0" />
							<xsl:with-param name="length" select="1" />
						</xsl:call-template>
						<xsl:value-of select="' '" />
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name">
								<xsl:text>file</xsl:text>
							</xsl:with-param>
							<xsl:with-param name="quoted" />
						</xsl:call-template>
						<xsl:text> ] || return 1;</xsl:text>
						<xsl:value-of select="$sh.endl" />
						<xsl:text>accessString=</xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name">
								<xsl:text>accessString</xsl:text>
							</xsl:with-param>
							<xsl:with-param name="quoted" />
							<xsl:with-param name="start" select="1" />
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />
				<xsl:text>return 0</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.sh.parser.optionSetPresenceFunctions">
		<xsl:param name="interpreter" />

		<xsl:call-template name="sh.functionDefinition">
			<xsl:with-param name="name" select="$prg.sh.parser.fName_setoptionpresence" />
			<xsl:with-param name="interpreter" select="$interpreter" />
			<xsl:with-param name="content">
				<xsl:call-template name="sh.incrementalFor">
					<xsl:with-param name="init" select="$prg.sh.parser.var_startindex" />
					<xsl:with-param name="limit">
						<xsl:text>$(expr </xsl:text>
						<xsl:value-of select="$prg.sh.parser.var_startindex" />
						<xsl:text> + </xsl:text>
						<xsl:call-template name="sh.arrayLength">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_required" />
						</xsl:call-template>
						<xsl:text>)</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="do">
						<xsl:variable name="requiredVar">
							<xsl:call-template name="sh.var">
								<xsl:with-param name="name" select="$prg.sh.parser.vName_required" />
								<xsl:with-param name="quoted" select="true()" />
								<xsl:with-param name="index">
									<xsl:call-template name="sh.var">
										<xsl:with-param name="name">
											<xsl:text>i</xsl:text>
										</xsl:with-param>
									</xsl:call-template>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:variable>
						<xsl:call-template name="sh.local">
							<xsl:with-param name="name" select="'idPart'" />
							<xsl:with-param name="interpreter" select="$interpreter" />
							<xsl:with-param name="value">
								<xsl:text>$(echo </xsl:text>
								<xsl:value-of select="$requiredVar" />
								<xsl:text> | cut -f 1 -d":" )</xsl:text>
							</xsl:with-param>
						</xsl:call-template>
						<xsl:value-of select="$sh.endl" />

						<xsl:call-template name="sh.if">
							<xsl:with-param name="condition">
								<xsl:text>[ </xsl:text>
								<xsl:call-template name="sh.var">
									<xsl:with-param name="name">
										<xsl:text>idPart</xsl:text>
									</xsl:with-param>
									<xsl:with-param name="quoted" select="true()" />
								</xsl:call-template>
								<xsl:text> = </xsl:text>
								<xsl:call-template name="sh.var">
									<xsl:with-param name="name">
										<xsl:text>1</xsl:text>
									</xsl:with-param>
									<xsl:with-param name="quoted" select="true()" />
								</xsl:call-template>
								<xsl:text> ]</xsl:text>
							</xsl:with-param>
							<xsl:with-param name="then">
								<xsl:call-template name="sh.arraySetIndex">
									<xsl:with-param name="name" select="$prg.sh.parser.vName_required" />
									<xsl:with-param name="index">
										<xsl:call-template name="sh.var">
											<xsl:with-param name="name">
												<xsl:text>i</xsl:text>
											</xsl:with-param>
										</xsl:call-template>
									</xsl:with-param>
									<xsl:with-param name="value">
										<xsl:text>""</xsl:text>
									</xsl:with-param>
								</xsl:call-template>
								<xsl:value-of select="$sh.endl" />
								<xsl:text>return 0</xsl:text>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />
				<xsl:text>return 1</xsl:text>
			</xsl:with-param>
		</xsl:call-template>

		<xsl:call-template name="sh.functionDefinition">
			<xsl:with-param name="name" select="$prg.sh.parser.fName_checkrequired" />
			<xsl:with-param name="interpreter" select="$interpreter" />
			<xsl:with-param name="content">
				<xsl:call-template name="sh.comment">
					<xsl:with-param name="content">
						<xsl:text>First round: set default values</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />

				<xsl:variable name="requiredVar">
					<xsl:call-template name="sh.var">
						<xsl:with-param name="name" select="$prg.sh.parser.vName_required" />
						<xsl:with-param name="quoted" select="true()" />
						<xsl:with-param name="index">
							<xsl:call-template name="sh.var">
								<xsl:with-param name="name">
									<xsl:text>i</xsl:text>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>

				<xsl:variable name="init" select="$prg.sh.parser.var_startindex" />
				<xsl:variable name="limit">
					<xsl:text>$(expr </xsl:text>
					<xsl:value-of select="$prg.sh.parser.var_startindex" />
					<xsl:text> + </xsl:text>
					<xsl:call-template name="sh.arrayLength">
						<xsl:with-param name="name" select="$prg.sh.parser.vName_required" />
					</xsl:call-template>
					<xsl:text>)</xsl:text>
				</xsl:variable>

				<xsl:variable name="isNotEmpty">
					<xsl:text>[ ! -z </xsl:text>
					<xsl:value-of select="$requiredVar" />
					<xsl:text> ]</xsl:text>
				</xsl:variable>

				<xsl:call-template name="sh.incrementalFor">
					<xsl:with-param name="init" select="$init" />
					<xsl:with-param name="limit" select="$limit" />
					<xsl:with-param name="do">
						<xsl:call-template name="sh.local">
							<xsl:with-param name="name" select="'todoPart'" />
							<xsl:with-param name="interpreter" select="$interpreter" />
							<xsl:with-param name="value">
								<xsl:text>$(echo </xsl:text>
								<xsl:value-of select="$requiredVar" />
								<xsl:text> | cut -f 3 -d":" )"</xsl:text>
								<xsl:value-of select="$sh.endl" />
								<xsl:text>[ -z "${todoPart}" ] || eval "${todoPart}</xsl:text>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />

				<xsl:call-template name="sh.local">
					<xsl:with-param name="name" select="'c'" />
					<xsl:with-param name="interpreter" select="$interpreter" />
					<xsl:with-param name="value" select="0" />
					<xsl:with-param name="quoted" select="false()" />
				</xsl:call-template>

				<xsl:value-of select="$sh.endl" />
				<xsl:call-template name="sh.incrementalFor">
					<xsl:with-param name="init" select="$init" />
					<xsl:with-param name="limit" select="$limit" />
					<xsl:with-param name="do">
						<xsl:call-template name="sh.if">
							<xsl:with-param name="condition" select="$isNotEmpty" />
							<xsl:with-param name="then">
								<xsl:call-template name="sh.local">
									<xsl:with-param name="name" select="'displayPart'" />
									<xsl:with-param name="interpreter" select="$interpreter" />
									<xsl:with-param name="value">
										<xsl:text>$(echo </xsl:text>
										<xsl:value-of select="$requiredVar" />
										<xsl:text> | cut -f 2 -d":" )</xsl:text>
									</xsl:with-param>
								</xsl:call-template>
								<xsl:value-of select="$sh.endl" />
								<xsl:call-template name="sh.arrayAppend">
									<xsl:with-param name="name" select="$prg.sh.parser.vName_errors" />
									<xsl:with-param name="startIndex" select="$prg.sh.parser.var_startindex" />
									<xsl:with-param name="value">
										<xsl:text>"Missing required option </xsl:text>
										<xsl:call-template name="sh.var">
											<xsl:with-param name="name">
												<xsl:text>displayPart</xsl:text>
											</xsl:with-param>
										</xsl:call-template>
										<xsl:text>"</xsl:text>
									</xsl:with-param>
								</xsl:call-template>
								<xsl:value-of select="$sh.endl" />

								<xsl:call-template name="sh.varincrement">
									<xsl:with-param name="name">
										<xsl:text>c</xsl:text>
									</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />
				<xsl:text>return </xsl:text>
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name">
						<xsl:text>c</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.sh.parser.setDefaultArgumentsFunction">
		<xsl:param name="programNode" />
		<xsl:param name="interpreter" />

		<xsl:call-template name="sh.functionDefinition">
			<xsl:with-param name="name" select="$prg.sh.parser.fName_setdefaultarguments" />
			<xsl:with-param name="interpreter" select="$interpreter" />
			<xsl:with-param name="content">
				<xsl:call-template name="sh.local">
					<xsl:with-param name="name" select="$prg.sh.parser.vName_set_default" />
					<xsl:with-param name="interpreter" select="$interpreter" />
					<xsl:with-param name="value" select="'false'" />
					<xsl:with-param name="quoted" select="false()" />
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />

				<!-- Global options -->
				<xsl:call-template name="prg.sh.parser.setDefaultArguments">
					<xsl:with-param name="rootNode" select="$programNode" />
					<xsl:with-param name="interpreter" select="$interpreter" />
				</xsl:call-template>

				<!-- Subcommand options -->
				<xsl:if test="$programNode/prg:subcommands">
					<xsl:call-template name="sh.case">
						<xsl:with-param name="case">
							<xsl:call-template name="sh.var">
								<xsl:with-param name="name" select="$prg.sh.parser.vName_subcommand" />
							</xsl:call-template>
						</xsl:with-param>
						<xsl:with-param name="in">
							<xsl:for-each select="$programNode/prg:subcommands/*">
								<xsl:call-template name="sh.caseblock">
									<xsl:with-param name="case">
										<xsl:value-of select="./prg:name" />
										<xsl:for-each select="./prg:aliases/prg:alias">
											<xsl:text> | </xsl:text>
											<xsl:value-of select="." />
										</xsl:for-each>
									</xsl:with-param>
									<xsl:with-param name="content">
										<xsl:call-template name="prg.sh.parser.setDefaultArguments">
											<xsl:with-param name="rootNode" select="." />
											<xsl:with-param name="interpreter" select="$interpreter" />
										</xsl:call-template>
									</xsl:with-param>
								</xsl:call-template>
							</xsl:for-each>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.sh.parser.minmaxCheckFunction">
		<xsl:param name="programNode" />
		<xsl:param name="interpreter" />

		<xsl:call-template name="sh.functionDefinition">
			<xsl:with-param name="name" select="$prg.sh.parser.fName_checkminmax" />
			<xsl:with-param name="interpreter" select="$interpreter" />
			<xsl:with-param name="content">
				<xsl:call-template name="sh.local">
					<xsl:with-param name="name" select="'errorCount'" />
					<xsl:with-param name="interpreter" select="$interpreter" />
					<xsl:with-param name="value" select="0" />
					<xsl:with-param name="quoted" select="false()" />
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />

				<xsl:call-template name="sh.comment">
					<xsl:with-param name="content">
						<xsl:text>Check min argument for multiargument</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />

				<xsl:for-each select="$programNode//prg:multiargument[@min &gt; 0]">
					<xsl:variable name="optionName">
						<xsl:call-template name="prg.sh.optionDisplayName">
							<xsl:with-param name="optionNode" select="." />
						</xsl:call-template>
					</xsl:variable>
					<xsl:if test="prg:databinding/prg:variable">
						<xsl:variable name="argCountVariable">
							<xsl:call-template name="sh.arrayLength">
								<xsl:with-param name="name">
									<xsl:apply-templates select="prg:databinding/prg:variable" />
								</xsl:with-param>
							</xsl:call-template>
						</xsl:variable>
						<xsl:call-template name="sh.if">
							<xsl:with-param name="condition">
								<xsl:text>[ </xsl:text>
								<xsl:value-of select="$argCountVariable" />
								<xsl:text> -gt 0 ] &amp;&amp; [ </xsl:text>
								<xsl:value-of select="$argCountVariable" />
								<xsl:text> -lt </xsl:text>
								<xsl:value-of select="@min" />
								<xsl:text> ]</xsl:text>
							</xsl:with-param>
							<xsl:with-param name="then">
								<xsl:call-template name="prg.sh.parser.addGlobalError">
									<xsl:with-param name="value">
										<xsl:text>"Invalid argument count for option \"</xsl:text>
										<xsl:value-of select="$optionName" />
										<xsl:text>\". At least </xsl:text>
										<xsl:value-of select="@min" />
										<xsl:text> expected, </xsl:text>
										<xsl:value-of select="$argCountVariable" />
										<xsl:text> given"</xsl:text>
									</xsl:with-param>
								</xsl:call-template>

								<xsl:value-of select="$sh.endl" />
								<xsl:call-template name="sh.varincrement">
									<xsl:with-param name="name">
										<xsl:text>errorCount</xsl:text>
									</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:if>
				</xsl:for-each>

				<xsl:value-of select="$sh.endl" />
				<xsl:text>return ${errorCount}</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.sh.parser.numberLesserEqualCheckFunction">
		<xsl:param name="interpreter" />
		
		<xsl:call-template name="sh.functionDefinition">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.fName_numberLesserEqualcheck" />
			</xsl:with-param>
			<xsl:with-param name="interpreter" select="$interpreter" />
			<xsl:with-param name="content">
				<xsl:call-template name="sh.local">
					<xsl:with-param name="name" select="'hasBC'" />
					<xsl:with-param name="interpreter" select="$interpreter" />
					<xsl:with-param name="quoted" select="false()" />
					<xsl:with-param name="value">
						<xsl:text>false</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:text></xsl:text>
				<xsl:value-of select="$sh.endl" />
				<xsl:text>which bc </xsl:text>
				<xsl:call-template name="sh.chunk.nullRedirection" />
				<xsl:text> &amp;&amp; hasBC=true</xsl:text>
				<xsl:value-of select="$sh.endl" />
				
				<xsl:call-template name="sh.if">
					<xsl:with-param name="condition">
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="'hasBC'" />
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="then">
						<xsl:text>[ "$(echo "${1} &lt;= ${2}" | bc)" = "0" ] &amp;&amp; return 1</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="else">
						<!-- Split into integral & decimal part -->
						<xsl:call-template name="sh.local">
							<xsl:with-param name="interpreter" select="$interpreter" />
							<xsl:with-param name="name" select="'a_int'" />
							<xsl:with-param name="value">
								<xsl:text>$(echo "${1}" | cut -f 1 -d".")</xsl:text>
							</xsl:with-param>
						</xsl:call-template>
						<xsl:value-of select="$sh.endl" />
						<xsl:call-template name="sh.local">
							<xsl:with-param name="interpreter" select="$interpreter" />
							<xsl:with-param name="name" select="'a_dec'" />
							<xsl:with-param name="value">
								<xsl:text>$(echo "${1}" | cut -f 2 -d".")</xsl:text>
							</xsl:with-param>
						</xsl:call-template>
						<xsl:value-of select="$sh.endl" />
						<xsl:text>[ "${a_dec}" = "${1}" ] &amp;&amp; a_dec="0"</xsl:text>
						
						<xsl:value-of select="$sh.endl" />
						<xsl:call-template name="sh.local">
							<xsl:with-param name="interpreter" select="$interpreter" />
							<xsl:with-param name="name" select="'b_int'" />
							<xsl:with-param name="value">
								<xsl:text>$(echo "${2}" | cut -f 1 -d".")</xsl:text>
							</xsl:with-param>
						</xsl:call-template>
						<xsl:value-of select="$sh.endl" />
						<xsl:call-template name="sh.local">
							<xsl:with-param name="interpreter" select="$interpreter" />
							<xsl:with-param name="name" select="'b_dec'" />
							<xsl:with-param name="value">
								<xsl:text>$(echo "${2}" | cut -f 2 -d".")</xsl:text>
							</xsl:with-param>
						</xsl:call-template>
						<xsl:value-of select="$sh.endl" />
						<xsl:text>[ "${b_dec}" = "${2}" ] &amp;&amp; b_dec="0"</xsl:text>
						<xsl:value-of select="$sh.endl" />
						
						<xsl:text>[ ${a_int} -lt ${b_int} ] &amp;&amp; return 0</xsl:text>
						<xsl:value-of select="$sh.endl" />
						<xsl:text>[ ${a_int} -gt ${b_int} ] &amp;&amp; return 1</xsl:text>
						<xsl:value-of select="$sh.endl" />
						<xsl:text>([ ${a_int} -ge 0 ] &amp;&amp; [ ${a_dec} -gt ${b_dec} ]) &amp;&amp; return 1</xsl:text>
						<xsl:value-of select="$sh.endl" />
						<xsl:text>([ ${a_int} -lt 0 ] &amp;&amp; [ ${b_dec} -gt ${a_dec} ]) &amp;&amp; return 1</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			
				<xsl:text>return 0</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.sh.parser.enumCheckFunction">
		<xsl:param name="interpreter" />

		<xsl:call-template name="sh.functionDefinition">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.fName_enumcheck" />
			</xsl:with-param>
			<xsl:with-param name="interpreter" select="$interpreter" />
			<xsl:with-param name="content">
				<xsl:call-template name="sh.local">
					<xsl:with-param name="name" select="'ref'" />
					<xsl:with-param name="interpreter" select="$interpreter" />
					<xsl:with-param name="value">
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="1" />
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />

				<xsl:text>shift 1</xsl:text>
				<xsl:value-of select="$sh.endl" />

				<xsl:call-template name="sh.while">
					<xsl:with-param name="condition">
						<xsl:text>[ $# -gt 0 ]</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="do">
						<xsl:call-template name="sh.if">
							<xsl:with-param name="condition">
								<xsl:text>[ "${ref}" = "${1}" ]</xsl:text>
							</xsl:with-param>
							<xsl:with-param name="then">
								<xsl:text>return 0</xsl:text>
							</xsl:with-param>
						</xsl:call-template>
						<xsl:text>shift</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />
				<xsl:text>return 1</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- Check and add anonymous value -->
	<xsl:template name="prg.sh.parser.addValueFunction">
		<xsl:param name="programNode" />
		<xsl:param name="interpreter" />

		<xsl:call-template name="sh.functionDefinition">
			<xsl:with-param name="name" select="$prg.sh.parser.fName_addvalue" />
			<xsl:with-param name="interpreter" select="$interpreter" />
			<xsl:with-param name="content">
				<xsl:call-template name="sh.local">
					<xsl:with-param name="name" select="'position'" />
					<xsl:with-param name="interpreter" select="$interpreter" />
					<xsl:with-param name="value">
						<xsl:call-template name="sh.arrayLength">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_values" />
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="quoted" select="false()" />
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />

				<xsl:call-template name="sh.local">
					<xsl:with-param name="name" select="'value'" />
					<xsl:with-param name="interpreter" select="$interpreter" />
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />

				<xsl:text>if [ $# -gt 0 ] &amp;&amp; [ ! -z "${1}" ]; then value="${1}"; else return </xsl:text>
				<xsl:value-of select="$prg.sh.parser.var_ERROR" />
				<xsl:text>; fi</xsl:text>
				<xsl:value-of select="$sh.endl" />
				<xsl:text>shift</xsl:text>
				<xsl:value-of select="$sh.endl" />

				<xsl:call-template name="sh.if">
					<xsl:with-param name="condition">
						<xsl:text>[ -z </xsl:text>
						<xsl:value-of select="$prg.sh.parser.var_subcommand" />
						<xsl:text> ]</xsl:text>
					</xsl:with-param>

					<!-- Add global values -->
					<xsl:with-param name="then">
						<xsl:choose>
							<xsl:when test="count($programNode/prg:values/*)">
								<xsl:call-template name="prg.sh.parser.checkValue">
									<xsl:with-param name="valuesNode" select="$programNode/prg:values" />
									<xsl:with-param name="interpreter" select="$interpreter" />
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="prg.sh.parser.addGlobalError">
									<xsl:with-param name="value">
										<xsl:text>"Positional argument not allowed"</xsl:text>
									</xsl:with-param>
								</xsl:call-template>
								<xsl:value-of select="$sh.endl" />
								<xsl:text>return </xsl:text>
								<xsl:value-of select="$prg.sh.parser.var_ERROR" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>

					<!-- Subcommand values -->
					<xsl:with-param name="else">
						<xsl:call-template name="sh.case">
							<xsl:with-param name="case">
								<xsl:call-template name="sh.var">
									<xsl:with-param name="name" select="$prg.sh.parser.vName_subcommand" />
								</xsl:call-template>
							</xsl:with-param>
							<xsl:with-param name="in">
								<xsl:for-each select="$programNode/prg:subcommands/*">
									<xsl:call-template name="sh.caseblock">
										<xsl:with-param name="case" select="prg:name" />
										<xsl:with-param name="content">
											<xsl:choose>
												<xsl:when test="count(./prg:values/*)">
													<xsl:call-template name="prg.sh.parser.checkValue">
														<xsl:with-param name="valuesNode" select="./prg:values" />
													</xsl:call-template>
												</xsl:when>
												<xsl:otherwise>
													<xsl:call-template name="prg.sh.parser.addGlobalError">
														<xsl:with-param name="value">
															<xsl:text>"Positional argument not allowed in subcommand </xsl:text>
															<xsl:value-of select="./prg:name" />
															<xsl:text>"</xsl:text>
														</xsl:with-param>
													</xsl:call-template>
													<xsl:value-of select="$sh.endl" />
													<xsl:text>return </xsl:text>
													<xsl:value-of select="$prg.sh.parser.var_ERROR" />
												</xsl:otherwise>
											</xsl:choose>
										</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
								<xsl:call-template name="sh.caseblock">
									<xsl:with-param name="case">
										<xsl:text>*</xsl:text>
									</xsl:with-param>
									<xsl:with-param name="content">
										<xsl:text>return </xsl:text>
										<xsl:value-of select="$prg.sh.parser.var_ERROR" />
									</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>

				<xsl:call-template name="sh.arrayAppend">
					<xsl:with-param name="name" select="$prg.sh.parser.vName_values" />
					<xsl:with-param name="startIndex" select="$prg.sh.parser.var_startindex" />
					<xsl:with-param name="value">
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="'value'" />
							<xsl:with-param name="quoted" select="true()" />
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- Main function for subcommand -->
	<xsl:template name="prg.sh.parser.subCommandOptionParseFunction">
		<xsl:param name="programNode" select="." />
		<xsl:param name="interpreter" />

		<xsl:variable name="onError">
			<xsl:text>return </xsl:text>
			<xsl:call-template name="sh.var">
				<xsl:with-param name="name" select="$prg.sh.parser.vName_SC_ERROR" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="onSuccess">
			<xsl:text>return </xsl:text>
			<xsl:call-template name="sh.var">
				<xsl:with-param name="name" select="$prg.sh.parser.vName_SC_OK" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="onUnknownOption">
			<xsl:text>return </xsl:text>
			<xsl:call-template name="sh.var">
				<xsl:with-param name="name" select="$prg.sh.parser.vName_SC_SKIP" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:call-template name="sh.functionDefinition">
			<xsl:with-param name="name" select="$prg.sh.parser.fName_process_subcommand_option" />
			<xsl:with-param name="interpreter" select="$interpreter" />
			<xsl:with-param name="content">
				<xsl:value-of select="$prg.sh.parser.vName_item" />
				<xsl:text>=</xsl:text>
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name" select="$prg.sh.parser.vName_input" />
					<xsl:with-param name="index">
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_index" />
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="quoted" select="true()" />
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />

				<xsl:if test="$prg.debug">
					<xsl:value-of select="$prg.sh.parser.fName_debug" />
					<xsl:text> "Processing subcommand </xsl:text>
					<xsl:call-template name="sh.var">
						<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
					</xsl:call-template>
					<xsl:text> [subindex: </xsl:text>
					<xsl:call-template name="sh.var">
						<xsl:with-param name="name" select="$prg.sh.parser.vName_subindex" />
					</xsl:call-template>
					<xsl:text>] (</xsl:text>
					<xsl:call-template name="sh.var">
						<xsl:with-param name="name" select="$prg.sh.parser.vName_index" />
					</xsl:call-template>
					<xsl:text> of </xsl:text>
					<xsl:call-template name="sh.var">
						<xsl:with-param name="name" select="$prg.sh.parser.vName_itemcount" />
					</xsl:call-template>
					<xsl:text>)"</xsl:text>
					<xsl:value-of select="$sh.endl" />
				</xsl:if>

				<xsl:call-template name="sh.if">
					<xsl:with-param name="condition">
						<xsl:text>[ -z </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
							<xsl:with-param name="quoted" select="true()" />
						</xsl:call-template>
						<xsl:text> ] || [ </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
							<xsl:with-param name="quoted" select="true()" />
							<xsl:with-param name="length" select="1" />
						</xsl:call-template>
						<xsl:text> != "-" ] || [ </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
							<xsl:with-param name="quoted" select="true()" />
						</xsl:call-template>
						<xsl:text> = "--" ]</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="then">
						<xsl:text>return </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_SC_SKIP" />
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />

				<xsl:choose>
					<!-- There is at least one option in one subcommand -->
					<xsl:when test="$programNode/prg:subcommands/prg:subcommand[prg:options]">
						<xsl:call-template name="sh.case">
							<xsl:with-param name="case">
								<xsl:call-template name="sh.var">
									<xsl:with-param name="name" select="$prg.sh.parser.vName_subcommand" />
								</xsl:call-template>
							</xsl:with-param>
							<xsl:with-param name="in">
								<xsl:for-each select="$programNode/prg:subcommands/prg:subcommand">
									<xsl:if test="./prg:options//prg:names/prg:long or ./prg:options//prg:names/prg:short">
										<xsl:call-template name="sh.caseblock">
											<xsl:with-param name="case">
												<xsl:value-of select="./prg:name" />
											</xsl:with-param>
											<xsl:with-param name="content">
												<xsl:if test="./prg:options//prg:names/prg:long">
													<xsl:call-template name="prg.sh.parser.longOptionNameElif">
														<xsl:with-param name="optionsNode" select="./prg:options" />
														<xsl:with-param name="onError" select="$onError" />
														<xsl:with-param name="onSuccess" select="$onSuccess" />
														<xsl:with-param name="onUnknownOption" select="$onUnknownOption" />
														<xsl:with-param name="interpreter" select="$interpreter" />
														<xsl:with-param name="keyword">
															<xsl:text>if</xsl:text>
														</xsl:with-param>
													</xsl:call-template>
												</xsl:if>

											<!-- short option -->
												<xsl:if test="./prg:options//prg:names/prg:short">
													<xsl:call-template name="prg.sh.parser.shortOptionNameElif">
														<xsl:with-param name="optionsNode" select="./prg:options" />
														<xsl:with-param name="onError" select="$onError" />
														<xsl:with-param name="onSuccess" select="$onSuccess" />
														<xsl:with-param name="onUnknownOption" select="$onUnknownOption" />
														<xsl:with-param name="interpreter" select="$interpreter" />
														<xsl:with-param name="keyword">
															<xsl:choose>
																<xsl:when test="./prg:options//prg:names/prg:long">
																	<xsl:text>elif</xsl:text>
																</xsl:when>
																<xsl:otherwise>
																	<xsl:text>if</xsl:text>
																</xsl:otherwise>
															</xsl:choose>
														</xsl:with-param>
													</xsl:call-template>
												</xsl:if>
												<xsl:text>fi</xsl:text>
											</xsl:with-param>
										</xsl:call-template>
									</xsl:if>
								</xsl:for-each>
							</xsl:with-param>
						</xsl:call-template>
						<xsl:value-of select="$sh.endl" />
						<xsl:text>return </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_SC_OK" />
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>return </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_SC_SKIP" />
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- Main option parser function -->
	<xsl:template name="prg.sh.parser.optionParseFunction">
		<xsl:param name="programNode" select="." />
		<xsl:param name="interpreter" />

		<xsl:variable name="onError">
			<xsl:text>return </xsl:text>
			<xsl:value-of select="$prg.sh.parser.var_ERROR" />
		</xsl:variable>
		<xsl:variable name="onSuccess">
			<xsl:text>return </xsl:text>
			<xsl:call-template name="sh.var">
				<xsl:with-param name="name" select="$prg.sh.parser.vName_SC_OK" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="onUnknownOption">
			<xsl:value-of select="$prg.sh.parser.fName_addfatalerror" />
			<xsl:text> "Unknown option \"</xsl:text>
			<xsl:call-template name="sh.var">
				<xsl:with-param name="name" select="$prg.sh.parser.vName_option" />
			</xsl:call-template>
			<xsl:text>\""</xsl:text>
			<xsl:value-of select="$sh.endl" />
			<xsl:text>return </xsl:text>
			<xsl:value-of select="$prg.sh.parser.var_ERROR" />
		</xsl:variable>

		<xsl:call-template name="sh.functionDefinition">
			<xsl:with-param name="name" select="$prg.sh.parser.fName_process_option" />
			<xsl:with-param name="interpreter" select="$interpreter" />
			<xsl:with-param name="content">
				<xsl:call-template name="sh.if">
					<xsl:with-param name="condition">
						<xsl:text>[ ! -z </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_subcommand" />
							<xsl:with-param name="quoted" select="true()" />
						</xsl:call-template>
						<xsl:text> ] &amp;&amp; [ </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
							<xsl:with-param name="quoted" select="true()" />
						</xsl:call-template>
						<xsl:text> != "--" ]</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="then">
						<xsl:if test="$prg.debug">
							<xsl:value-of select="$prg.sh.parser.fName_debug" />
							<xsl:text> "Subcommand option check"</xsl:text>
							<xsl:value-of select="$sh.endl" />
						</xsl:if>

						<xsl:call-template name="sh.if">
							<xsl:with-param name="condition">
								<xsl:value-of select="$prg.sh.parser.fName_process_subcommand_option" />
							</xsl:with-param>
							<xsl:with-param name="then">
								<xsl:if test="$prg.debug">
									<xsl:value-of select="$prg.sh.parser.fName_debug" />
									<xsl:text> "Subcommand option parsing success"</xsl:text>
									<xsl:value-of select="$sh.endl" />
								</xsl:if>
								<xsl:text>return </xsl:text>
								<xsl:call-template name="sh.var">
									<xsl:with-param name="name" select="$prg.sh.parser.vName_OK" />
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>

						<xsl:call-template name="sh.if">
							<xsl:with-param name="condition">
								<xsl:text>[ </xsl:text>
								<xsl:call-template name="sh.var">
									<xsl:with-param name="name" select="$prg.sh.parser.vName_index" />
								</xsl:call-template>
								<xsl:text> -ge </xsl:text>
								<xsl:call-template name="sh.var">
									<xsl:with-param name="name" select="$prg.sh.parser.vName_itemcount" />
								</xsl:call-template>
								<xsl:text> ]</xsl:text>
							</xsl:with-param>
							<xsl:with-param name="then">
								<xsl:if test="$prg.debug">
									<xsl:value-of select="$prg.sh.parser.fName_debug" />
									<xsl:text> "End of items"</xsl:text>
									<xsl:value-of select="$sh.endl" />
								</xsl:if>
								<xsl:text>return </xsl:text>
								<xsl:call-template name="sh.var">
									<xsl:with-param name="name" select="$prg.sh.parser.vName_OK" />
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />

				<!-- get current item -->
				<xsl:value-of select="$prg.sh.parser.vName_item" />
				<xsl:text>=</xsl:text>
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name" select="$prg.sh.parser.vName_input" />
					<xsl:with-param name="quoted" select="true()" />
					<xsl:with-param name="index">
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_index" />
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />
				<xsl:value-of select="$sh.endl" />

				<xsl:call-template name="sh.if">
					<xsl:with-param name="condition">
						<xsl:text>[ -z </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
							<xsl:with-param name="quoted" select="true()" />
						</xsl:call-template>
						<xsl:text> ]</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="then">
						<xsl:text>return </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_OK" />
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />

				<xsl:if test="$prg.debug">
					<xsl:value-of select="$prg.sh.parser.fName_debug" />
					<xsl:text> "Processing </xsl:text>
					<xsl:call-template name="sh.var">
						<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
					</xsl:call-template>
					<xsl:text> [subindex: </xsl:text>
					<xsl:call-template name="sh.var">
						<xsl:with-param name="name" select="$prg.sh.parser.vName_subindex" />
					</xsl:call-template>
					<xsl:text>] (</xsl:text>
					<xsl:call-template name="sh.var">
						<xsl:with-param name="name" select="$prg.sh.parser.vName_index" />
					</xsl:call-template>
					<xsl:text> of </xsl:text>
					<xsl:call-template name="sh.var">
						<xsl:with-param name="name" select="$prg.sh.parser.vName_itemcount" />
					</xsl:call-template>
					<xsl:text>)"</xsl:text>
					<xsl:value-of select="$sh.endl" />
				</xsl:if>

				<!-- End of options -->
				<xsl:text>if [ </xsl:text>
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
					<xsl:with-param name="quoted" select="true()" />
				</xsl:call-template>
				<xsl:text> = "--" ]</xsl:text>
				<xsl:value-of select="$sh.endl" />
				<xsl:text>then</xsl:text>
				<xsl:call-template name="code.block">
					<xsl:with-param name="content">
						<xsl:call-template name="prg.sh.parser.copyValues" />
						<xsl:value-of select="$sh.endl" />
						<xsl:text>return </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_OK" />
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>

				<!-- End of option values -->
				<xsl:text>elif [ </xsl:text>
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
					<xsl:with-param name="quoted" select="true()" />
				</xsl:call-template>
				<xsl:text> = "-" ]</xsl:text>
				<xsl:value-of select="$sh.endl" />
				<xsl:text>then</xsl:text>
				<xsl:call-template name="code.block">
					<xsl:with-param name="content">
						<xsl:text>return </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_OK" />
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>

				<!-- Protected value -->
				<xsl:text>elif [ </xsl:text>
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
					<xsl:with-param name="quoted" select="true()" />
					<xsl:with-param name="length" select="2" />
				</xsl:call-template>
				<xsl:text> = "\-" ]</xsl:text>
				<xsl:value-of select="$sh.endl" />
				<xsl:text>then</xsl:text>
				<xsl:call-template name="code.block">
					<xsl:with-param name="content">
						<xsl:value-of select="$prg.sh.parser.fName_addvalue" />
						<xsl:value-of select="' '" />
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
							<xsl:with-param name="quoted" select="true()" />
							<xsl:with-param name="start" select="1" />
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>

				<xsl:variable name="optionsNode" select="$programNode/prg:options" />

				<!-- long option -->
				<xsl:if test="$optionsNode//prg:names/prg:long">
					<xsl:call-template name="prg.sh.parser.longOptionNameElif">
						<xsl:with-param name="optionsNode" select="$programNode/prg:options" />
						<xsl:with-param name="onError" select="$onError" />
						<xsl:with-param name="onSuccess" select="$onSuccess" />
						<xsl:with-param name="onUnknownOption" select="$onUnknownOption" />
						<xsl:with-param name="interpreter" select="$interpreter" />
					</xsl:call-template>
				</xsl:if>

				<!-- short option -->
				<xsl:if test="$optionsNode//prg:names/prg:short">
					<xsl:call-template name="prg.sh.parser.shortOptionNameElif">
						<xsl:with-param name="optionsNode" select="$programNode/prg:options" />
						<xsl:with-param name="onError" select="$onError" />
						<xsl:with-param name="onSuccess" select="$onSuccess" />
						<xsl:with-param name="onUnknownOption" select="$onUnknownOption" />
						<xsl:with-param name="interpreter" select="$interpreter" />
					</xsl:call-template>
				</xsl:if>

				<!-- subcommand -->
				<xsl:text>elif </xsl:text>
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name" select="$prg.sh.parser.vName_subcommand_expected" />
				</xsl:call-template>
				<xsl:text> &amp;&amp; [ -z </xsl:text>
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name" select="$prg.sh.parser.vName_subcommand" />
					<xsl:with-param name="quoted" select="true()" />
				</xsl:call-template>
				<xsl:text> ] &amp;&amp; [ </xsl:text>
				<xsl:call-template name="sh.arrayLength">
					<xsl:with-param name="name" select="$prg.sh.parser.vName_values" />
				</xsl:call-template>
				<xsl:text> -eq 0 ]</xsl:text>
				<xsl:value-of select="$sh.endl" />
				<xsl:text>then</xsl:text>
				<xsl:call-template name="code.block">
					<xsl:with-param name="content">
						<xsl:call-template name="sh.case">
							<xsl:with-param name="case">
								<xsl:call-template name="sh.var">
									<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
								</xsl:call-template>
							</xsl:with-param>
							<xsl:with-param name="in">
								<xsl:for-each select="$programNode/prg:subcommands/prg:subcommand">
									<xsl:call-template name="sh.caseblock">
										<xsl:with-param name="case">
											<xsl:value-of select="./prg:name" />
											<xsl:for-each select="./prg:aliases/prg:alias">
												<xsl:text> | </xsl:text>
												<xsl:value-of select="." />
											</xsl:for-each>
										</xsl:with-param>
										<xsl:with-param name="content">
											<xsl:value-of select="$prg.sh.parser.vName_subcommand" />
											<xsl:text>="</xsl:text>
											<xsl:value-of select="./prg:name" />
											<xsl:text>"</xsl:text>
											<xsl:call-template name="prg.sh.parser.optionAddRequired">
												<xsl:with-param name="optionsNode" select="./prg:options" />
											</xsl:call-template>
										</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
								<xsl:call-template name="sh.caseblock">
									<xsl:with-param name="case">
										<xsl:text>*</xsl:text>
									</xsl:with-param>
									<xsl:with-param name="content">
										<!-- It's the first value -->
										<xsl:value-of select="$prg.sh.parser.fName_addvalue" />
										<xsl:value-of select="' '" />
										<xsl:call-template name="sh.var">
											<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
											<xsl:with-param name="quoted" select="true()" />
										</xsl:call-template>
									</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>

				<!-- values -->
				<xsl:text>else</xsl:text>
				<xsl:call-template name="code.block">
					<xsl:with-param name="content">
						<xsl:value-of select="$prg.sh.parser.fName_addvalue" />
						<xsl:value-of select="' '" />
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
							<xsl:with-param name="quoted" select="true()" />
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:text>fi</xsl:text>
				<xsl:value-of select="$sh.endl" />
				<xsl:text>return </xsl:text>
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name" select="$prg.sh.parser.vName_OK" />
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.sh.parser.parseFunction">
		<xsl:param name="programNode" select="." />
		<xsl:param name="interpreter" />

		<xsl:call-template name="sh.functionDefinition">
			<xsl:with-param name="name" select="$prg.sh.parser.fName_parse" />
			<xsl:with-param name="interpreter" select="$interpreter" />

			<xsl:with-param name="content">
				<xsl:value-of select="$prg.sh.parser.vName_aborted" />
				<xsl:text>=false</xsl:text>
				<xsl:value-of select="$sh.endl" />

				<xsl:call-template name="sh.while">
					<xsl:with-param name="condition">
						<xsl:text>[ </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_index" />
						</xsl:call-template>
						<xsl:text> -lt </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_itemcount" />
						</xsl:call-template>
						<xsl:text> ] &amp;&amp; ! </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_aborted" />
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="do">
						<xsl:value-of select="$prg.sh.parser.fName_process_option" />
						<xsl:value-of select="$sh.endl" />

						<xsl:call-template name="sh.if">
							<xsl:with-param name="condition">
								<xsl:text>[ -z </xsl:text>
								<xsl:call-template name="sh.var">
									<xsl:with-param name="name" select="$prg.sh.parser.vName_optiontail" />
									<xsl:with-param name="quoted" select="true()" />
								</xsl:call-template>
								<xsl:text> ]</xsl:text>
							</xsl:with-param>
							<xsl:with-param name="then">
								<xsl:call-template name="prg.sh.parser.indexIncrement" />
								<xsl:value-of select="$sh.endl" />
								<xsl:value-of select="$prg.sh.parser.vName_subindex" />
								<xsl:text>=0</xsl:text>
							</xsl:with-param>
							<xsl:with-param name="else">
								<xsl:call-template name="sh.varincrement">
									<xsl:with-param name="name" select="$prg.sh.parser.vName_subindex" />
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />
				<xsl:value-of select="$sh.endl" />

				<xsl:call-template name="sh.if">
					<xsl:with-param name="condition">
						<xsl:text>! </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_aborted" />
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="then">
						<!-- Set group default options -->
						<xsl:for-each select="$programNode//prg:group[prg:default]">
							<xsl:variable name="groupNode" select="." />
							<xsl:variable name="optionIdRef" select="./prg:default/@id" />
							<xsl:variable name="optionNode" select="$groupNode/prg:options/*/@id[.=$optionIdRef]/.." />
							<xsl:variable name="groupNodeId">
								<xsl:call-template name="prg.optionId">
									<xsl:with-param name="optionNode" select="$groupNode" />
								</xsl:call-template>
							</xsl:variable>

							<xsl:if test="$groupNode/prg:databinding/prg:variable and $optionNode/prg:databinding/prg:variable">
								<xsl:text># Set default option for group </xsl:text>
								<xsl:value-of select="$groupNodeId" />
								<xsl:text> (if not already set)</xsl:text>
								<xsl:value-of select="$sh.endl" />
								<xsl:call-template name="sh.if">
									<xsl:with-param name="condition">
										<xsl:text>[ "${</xsl:text>
										<xsl:apply-templates select="$groupNode/prg:databinding/prg:variable" />
										<xsl:text>:0:1}" = "@" ]</xsl:text>
									</xsl:with-param>
									<xsl:with-param name="then">
										<xsl:apply-templates select="$groupNode/prg:databinding/prg:variable" />
										<xsl:text>="</xsl:text>
										<xsl:apply-templates select="$optionNode/prg:databinding/prg:variable" />
										<xsl:text>"</xsl:text>
										<xsl:value-of select="$sh.endl" />
										<xsl:value-of select="$prg.sh.parser.fName_setoptionpresence" />
										<xsl:value-of select="' '" />
										<xsl:value-of select="$groupNodeId" />
									</xsl:with-param>
								</xsl:call-template>
								<xsl:value-of select="$sh.endl" />
							</xsl:if>
						</xsl:for-each>

						<!-- Set options with defaults value -->
						<xsl:value-of select="$prg.sh.parser.fName_setdefaultarguments" />
						<xsl:value-of select="$sh.endl" />

						<!-- Check required options -->
						<xsl:value-of select="$prg.sh.parser.fName_checkrequired" />
						<xsl:value-of select="$sh.endl" />

						<!-- Check multiargument min attribute -->
						<xsl:value-of select="$prg.sh.parser.fName_checkminmax" />
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />
				<xsl:value-of select="$sh.endl" />

				<!-- Return error count -->
				<xsl:variable name="errorCount">
					<xsl:call-template name="prg.prefixedName">
						<xsl:with-param name="name">
							<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
							<xsl:text>errorcount</xsl:text>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="$sh.endl" />

				<xsl:call-template name="sh.local">
					<xsl:with-param name="name" select="$errorCount" />
					<xsl:with-param name="interpreter" select="$interpreter" />
					<xsl:with-param name="value">
						<xsl:call-template name="sh.arrayLength">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_errors" />
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="quoted" select="false()" />
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />

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

				<xsl:text>return </xsl:text>
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name" select="$errorCount" />
				</xsl:call-template>

			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- Main -->
	<xsl:template name="prg.sh.parser.main">
		<xsl:param name="programNode" select="." />
		<xsl:param name="interpreter" />

		<xsl:call-template name="prg.sh.parser.initialize">
			<xsl:with-param name="programNode" select="$programNode" />
			<xsl:with-param name="interpreter" select="$interpreter" />
		</xsl:call-template>
		<xsl:call-template name="prg.sh.parser.messageFunctions">
			<xsl:with-param name="programNode" select="$programNode" />
			<xsl:with-param name="interpreter" select="$interpreter" />
		</xsl:call-template>
		<xsl:call-template name="prg.sh.parser.pathAccessCheckFunction">
			<xsl:with-param name="programNode" select="$programNode" />
			<xsl:with-param name="interpreter" select="$interpreter" />
		</xsl:call-template>
		<xsl:call-template name="prg.sh.parser.optionSetPresenceFunctions">
			<xsl:with-param name="programNode" select="$programNode" />
			<xsl:with-param name="interpreter" select="$interpreter" />
		</xsl:call-template>
		<xsl:call-template name="prg.sh.parser.setDefaultArgumentsFunction">
			<xsl:with-param name="programNode" select="$programNode" />
			<xsl:with-param name="interpreter" select="$interpreter" />
		</xsl:call-template>
		<xsl:call-template name="prg.sh.parser.minmaxCheckFunction">
			<xsl:with-param name="programNode" select="$programNode" />
			<xsl:with-param name="interpreter" select="$interpreter" />
		</xsl:call-template>
		<xsl:call-template name="prg.sh.parser.numberLesserEqualCheckFunction">
			<xsl:with-param name="programNode" select="$programNode" />
			<xsl:with-param name="interpreter" select="$interpreter" />
		</xsl:call-template>
		<xsl:call-template name="prg.sh.parser.enumCheckFunction">
			<xsl:with-param name="programNode" select="$programNode" />
			<xsl:with-param name="interpreter" select="$interpreter" />
		</xsl:call-template>
		<xsl:call-template name="prg.sh.parser.addValueFunction">
			<xsl:with-param name="programNode" select="$programNode" />
			<xsl:with-param name="interpreter" select="$interpreter" />
		</xsl:call-template>
		<xsl:call-template name="prg.sh.parser.subCommandOptionParseFunction">
			<xsl:with-param name="programNode" select="$programNode" />
			<xsl:with-param name="interpreter" select="$interpreter" />
		</xsl:call-template>
		<xsl:call-template name="prg.sh.parser.optionParseFunction">
			<xsl:with-param name="programNode" select="$programNode" />
			<xsl:with-param name="interpreter" select="$interpreter" />
		</xsl:call-template>
		<xsl:call-template name="prg.sh.parser.parseFunction">
			<xsl:with-param name="programNode" select="$programNode" />
			<xsl:with-param name="interpreter" select="$interpreter" />
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>

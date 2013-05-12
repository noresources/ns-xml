<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Shell parser code chunks -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">

	<xsl:import href="base.xsl" />
	<xsl:import href="parser.variables.xsl" />

	<!-- "$parser_index++" -->
	<xsl:template name="prg.sh.parser.indexIncrement">
		<xsl:call-template name="sh.varincrement">
			<xsl:with-param name="name" select="$prg.sh.parser.vName_index" />
		</xsl:call-template>
	</xsl:template>

	<!-- parser_item=${parser_input[$parser_index]} -->
	<xsl:template name="prg.sh.parser.itemUpdate">
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
	</xsl:template>

	<!-- for each remaining input, append parser_input[] to parser_values[] -->
	<xsl:template name="prg.sh.parser.copyValues">
		<xsl:call-template name="sh.incrementalFor">
			<xsl:with-param name="variable">
				<xsl:text>a</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="init">
				<xsl:text>$(expr </xsl:text>
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name" select="$prg.sh.parser.vName_index" />
				</xsl:call-template>
				<xsl:text> + 1)</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="limit">
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name" select="$prg.sh.parser.vName_itemcount" />
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="do">
				<xsl:value-of select="$prg.sh.parser.fName_addvalue" />
				<xsl:value-of select="' '" />
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name" select="$prg.sh.parser.vName_input" />
					<xsl:with-param name="quoted" select="true()" />
					<xsl:with-param name="index">
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name">
								<xsl:text>a</xsl:text>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:value-of select="$sh.endl" />
		<xsl:value-of select="$prg.sh.parser.vName_index" />
		<xsl:text>=</xsl:text>
		<xsl:call-template name="sh.var">
			<xsl:with-param name="name" select="$prg.sh.parser.vName_itemcount" />
		</xsl:call-template>
	</xsl:template>

	<!-- call setoptionprecence if necessary -->
	<!-- @todo use unified id -->
	<xsl:template name="prg.sh.parser.optionSetPresence">
		<xsl:param name="optionNode" select="." />
		<xsl:param name="inline" select="true()" />

		<xsl:variable name="parentNode" select="$optionNode/../.." />

		<xsl:value-of select="$prg.sh.parser.fName_setoptionpresence" />
		<xsl:value-of select="' '" />
		<xsl:call-template name="prg.optionId">
			<xsl:with-param name="optionNode" select="$optionNode" />
		</xsl:call-template>

		<xsl:if test="$parentNode/self::prg:group">
			<xsl:choose>
				<xsl:when test="$inline">
					<xsl:text>;</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$sh.endl" />
				</xsl:otherwise>
			</xsl:choose>
			<xsl:call-template name="prg.sh.parser.optionSetPresence">
				<xsl:with-param name="optionNode" select="$parentNode" />
				<xsl:with-param name="inline" select="$inline" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- Set default values for all single arguments in a root item info
		(part of the setdefaultarguments function)
	-->
	<xsl:template name="prg.sh.parser.setDefaultArguments">
		<xsl:param name="rootNode" />
		<xsl:param name="interpreter" />

		<xsl:for-each select="$rootNode//prg:argument[prg:default and prg:databinding/prg:variable]">
			<xsl:call-template name="sh.comment">
				<xsl:with-param name="content">
					<xsl:apply-templates select="prg:databinding/prg:variable" />
				</xsl:with-param>
			</xsl:call-template>
			<xsl:value-of select="$sh.endl" />

			<xsl:call-template name="sh.if">
				<xsl:with-param name="condition">
					<xsl:text>[ -z "</xsl:text>
					<xsl:call-template name="sh.var">
						<xsl:with-param name="name">
							<xsl:apply-templates select="prg:databinding/prg:variable" />
						</xsl:with-param>
					</xsl:call-template>
					<xsl:text>" ]</xsl:text>
				</xsl:with-param>
				<xsl:with-param name="then">
					<xsl:value-of select="$prg.sh.parser.vName_set_default" />
					<xsl:text>=true</xsl:text>
					<xsl:value-of select="$sh.endl" />
					<xsl:if test="../../self::prg:group">
						<xsl:call-template name="prg.sh.parser.groupCheck">
							<xsl:with-param name="optionNode" select="." />
							<xsl:with-param name="comments" select="false()" />
							<xsl:with-param name="process" select="false()" />
							<xsl:with-param name="onError">
								<xsl:value-of select="$prg.sh.parser.vName_set_default" />
								<xsl:text>=false</xsl:text>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:if>
					<xsl:call-template name="sh.if">
						<xsl:with-param name="condition">
							<xsl:call-template name="sh.var">
								<xsl:with-param name="name" select="$prg.sh.parser.vName_set_default" />
							</xsl:call-template>
						</xsl:with-param>
						<xsl:with-param name="then">
							<xsl:apply-templates select="prg:databinding/prg:variable" />
							<xsl:text>="</xsl:text>
							<xsl:apply-templates select="prg:default" />
							<xsl:text>"</xsl:text>
							<xsl:value-of select="$sh.endl" />
							<xsl:call-template name="prg.sh.parser.groupSetVars">
								<xsl:with-param name="optionNode" select="." />
							</xsl:call-template>
							<xsl:call-template name="prg.sh.parser.optionSetPresence">
								<xsl:with-param name="optionNode" select="." />
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:value-of select="$sh.endl" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<!-- Remove \ protection if any -->
	<xsl:template name="prg.sh.parser.unescapeValue">
		<xsl:param name="variableName" select="$prg.sh.parser.vName_item" />
		<xsl:text>[ </xsl:text>
		<xsl:call-template name="sh.var">
			<xsl:with-param name="name" select="$variableName" />
			<xsl:with-param name="quoted" select="true()" />
			<xsl:with-param name="length" select="2" />
		</xsl:call-template>
		<xsl:text> = "\-" ] &amp;&amp; </xsl:text>
		<xsl:value-of select="$variableName" />
		<xsl:text>=</xsl:text>
		<xsl:call-template name="sh.var">
			<xsl:with-param name="name" select="$variableName" />
			<xsl:with-param name="quoted" select="true()" />
			<xsl:with-param name="start" select="1" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.sh.parser.argumentPreprocess">
		<xsl:param name="optionNode" select="." />
		<xsl:param name="onError" />

		<xsl:call-template name="sh.if">
			<xsl:with-param name="condition">
				<xsl:text>[ ! -z </xsl:text>
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name" select="$prg.sh.parser.vName_optiontail" />
					<xsl:with-param name="quoted" select="true()" />
				</xsl:call-template>
				<xsl:text> ]</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="then">
				<xsl:value-of select="$prg.sh.parser.vName_item" />
				<xsl:text>=</xsl:text>
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name" select="$prg.sh.parser.vName_optiontail" />
					<xsl:with-param name="quoted" select="true()" />
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="else">
				<xsl:call-template name="prg.sh.parser.indexIncrement" />
				<xsl:value-of select="$sh.endl" />

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
						<xsl:value-of select="$prg.sh.parser.fName_adderror" />
						<xsl:text> "End of input reached - Argument expected"</xsl:text>
						<xsl:if test="$onError">
							<xsl:value-of select="$sh.endl" />
							<xsl:value-of select="$onError" />
						</xsl:if>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />

				<xsl:call-template name="prg.sh.parser.itemUpdate" />
				<xsl:value-of select="$sh.endl" />

				<xsl:call-template name="sh.if">
					<xsl:with-param name="condition">
						<xsl:text>[ </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
							<xsl:with-param name="quoted" select="true()" />
						</xsl:call-template>
						<xsl:text> = "--" ]</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="then">
						<xsl:value-of select="$prg.sh.parser.fName_adderror" />
						<xsl:text> "End of option marker found - Argument expected"</xsl:text>
						<xsl:value-of select="$sh.endl" />
						<xsl:call-template name="sh.var.selfexpr">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_index" />
							<xsl:with-param name="operator">
								<xsl:text>-</xsl:text>
							</xsl:with-param>
						</xsl:call-template>
						<xsl:if test="$onError">
							<xsl:value-of select="$sh.endl" />
							<xsl:value-of select="$onError" />
						</xsl:if>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>

		<xsl:value-of select="$sh.endl" />
		<xsl:value-of select="$prg.sh.parser.vName_subindex" />
		<xsl:text>=0</xsl:text>
		<xsl:value-of select="$sh.endl" />
		<xsl:value-of select="$prg.sh.parser.vName_optiontail" />
		<xsl:text>=""</xsl:text>

		<xsl:value-of select="$sh.endl" />
		<xsl:call-template name="prg.sh.parser.unescapeValue" />
	</xsl:template>

	<xsl:template name="prg.sh.parser.multiargumentPreprocess">
		<xsl:param name="optionNode" select="." />
		<xsl:param name="onError" />

		<xsl:call-template name="sh.if">
			<xsl:with-param name="condition">
				<xsl:text>[ ! -z </xsl:text>
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name" select="$prg.sh.parser.vName_optiontail" />
					<xsl:with-param name="quoted" select="true()" />
				</xsl:call-template>
				<xsl:text> ]</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="then">
				<xsl:value-of select="$prg.sh.parser.vName_item" />
				<xsl:text>=</xsl:text>
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name" select="$prg.sh.parser.vName_optiontail" />
					<xsl:with-param name="quoted" select="true()" />
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>

		<xsl:value-of select="$sh.endl" />
		<xsl:value-of select="$prg.sh.parser.vName_subindex" />
		<xsl:text>=0</xsl:text>
		<xsl:value-of select="$sh.endl" />
		<xsl:value-of select="$prg.sh.parser.vName_optiontail" />
		<xsl:text>=""</xsl:text>

		<xsl:value-of select="$sh.endl" />
		<xsl:call-template name="prg.sh.parser.unescapeValue" />

	</xsl:template>

	<xsl:template name="prg.sh.parser.optionSetValue">
		<xsl:param name="optionNode" select="." />
		<xsl:param name="onError" />
		<xsl:param name="shortOption" select="false()" />

		<xsl:if test="$optionNode/prg:databinding/prg:variable">
			<xsl:choose>
				<xsl:when test="$optionNode/self::prg:switch">
					<!-- Check tail -->
					<xsl:if test="not ($shortOption)">
						<xsl:call-template name="sh.if">
							<xsl:with-param name="condition">
								<xsl:text>[ ! -z </xsl:text>
								<xsl:call-template name="sh.var">
									<xsl:with-param name="name" select="$prg.sh.parser.vName_optiontail" />
									<xsl:with-param name="quoted" select="true()" />
								</xsl:call-template>
								<xsl:text> ]</xsl:text>
							</xsl:with-param>
							<xsl:with-param name="then">
								<xsl:value-of select="$prg.sh.parser.fName_adderror" />
								<xsl:text> "Unexpected argument (ignored) for option \"</xsl:text>
								<xsl:call-template name="sh.var">
									<xsl:with-param name="name" select="$prg.sh.parser.vName_option" />
								</xsl:call-template>
								<xsl:text>\""</xsl:text>
								<xsl:value-of select="$sh.endl" />
								<xsl:value-of select="$prg.sh.parser.vName_optiontail" />
								<xsl:text>=""</xsl:text>
								<xsl:if test="$onError">
									<xsl:value-of select="$sh.endl" />
									<xsl:value-of select="$onError" />
								</xsl:if>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="$optionNode/@node = 'integer'">
							<xsl:call-template name="sh.varincrement">
								<xsl:with-param name="name">
									<xsl:apply-templates select="$optionNode/prg:databinding/prg:variable" />
								</xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="$optionNode/prg:databinding/prg:variable" />
							<xsl:text>=true</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$optionNode/self::prg:argument">
					<xsl:apply-templates select="$optionNode/prg:databinding/prg:variable" />
					<xsl:text>=</xsl:text>
					<xsl:call-template name="sh.var">
						<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
						<xsl:with-param name="quoted" select="true()" />
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- Set super group variables -->
	<xsl:template name="prg.sh.parser.groupSetVars">
		<xsl:param name="optionNode" select="." />
		<xsl:variable name="optionsNode" select="$optionNode/.." />
		<xsl:if test="$optionsNode/parent::prg:group">
			<xsl:variable name="groupOptionNode" select="$optionNode/../.." />

			<!-- Recursive set -->
			<xsl:call-template name="prg.sh.parser.groupSetVars">
				<xsl:with-param name="optionNode" select="$groupOptionNode" />
			</xsl:call-template>

			<!-- Set option variable -->
			<!-- except if group is not exclusive (meaningless in this case) -->
			<xsl:if test="$optionNode/prg:databinding/prg:variable and $groupOptionNode/prg:databinding/prg:variable and ($groupOptionNode/@type = 'exclusive')">
				<xsl:apply-templates select="$groupOptionNode/prg:databinding/prg:variable" />
				<xsl:text>="</xsl:text>
				<!-- don't add subcommand prefix in this case -->
				<xsl:call-template name="prg.sh.parser.boundVariableName">
					<xsl:with-param name="variableNode" select="$optionNode/prg:databinding/prg:variable" />
					<xsl:with-param name="usePrefix" select="false()" />
				</xsl:call-template>
				<!-- <apply-templates select="$optionNode/prg:databinding/prg:variable" /> -->
				<xsl:text>"</xsl:text>
				<xsl:value-of select="$sh.endl" />
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template name="prg.sh.parser.valueRestrictionCheck">
		<xsl:param name="optionNode" select="." />
		<xsl:param name="value">
			<xsl:call-template name="sh.var">
				<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="onError" />
		<xsl:param name="currentItem">
			<xsl:text>option \"</xsl:text>
			<xsl:call-template name="sh.var">
				<xsl:with-param name="name" select="$prg.sh.parser.vName_option" />
			</xsl:call-template>
			<xsl:text>\"</xsl:text>
		</xsl:param>

		<xsl:if test="$optionNode/prg:select/@restrict">
			<xsl:call-template name="sh.if">
				<xsl:with-param name="condition">
					<xsl:text>! (</xsl:text>
					<xsl:for-each select="$optionNode/prg:select/prg:option">
						<xsl:if test="position() != 1">
							<xsl:text> || </xsl:text>
						</xsl:if>
						<xsl:text>[ "</xsl:text>
						<xsl:value-of select="$value" />
						<xsl:text>" = "</xsl:text>
						<xsl:value-of select="." />
						<xsl:text>" ]</xsl:text>
					</xsl:for-each>
					<xsl:text>)</xsl:text>
				</xsl:with-param>
				<xsl:with-param name="then">
					<xsl:value-of select="$prg.sh.parser.fName_adderror" />
					<xsl:text> "Invalid value for </xsl:text>
					<xsl:value-of select="$currentItem" />
					<xsl:text>"</xsl:text>
					<!-- Todo: list values -->
					<xsl:value-of select="$sh.endl" />
					<xsl:if test="$onError">
						<xsl:value-of select="$sh.endl" />
						<xsl:value-of select="$onError" />
					</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- Chec if the option is part of a group and if it does not break mutual exclusion rule -->
	<xsl:template name="prg.sh.parser.groupCheck">
		<!-- Option to check -->
		<xsl:param name="optionNode" select="." />
		<!-- Additional things to do when checks fail -->
		<xsl:param name="onError" />
		<!-- Disable default processing -->
		<xsl:param name="process" select="true()" />
		<!-- Internal use -->
		<xsl:param name="comments" select="true()" />
		<!-- Internal use -->
		<xsl:param name="originalOptionNode" select="$optionNode" />

		<xsl:variable name="optionsNode" select="$optionNode/.." />

		<xsl:if test="$optionsNode/parent::prg:group">
			<xsl:variable name="groupOptionNode" select="$optionNode/../.." />
			<xsl:if test="$comments">
				<xsl:call-template name="sh.comment">
					<xsl:with-param name="content">
						<xsl:text>Group checks</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />
			</xsl:if>

			<!-- Recursive check -->
			<xsl:call-template name="prg.sh.parser.groupCheck">
				<xsl:with-param name="optionNode" select="$groupOptionNode" />
				<xsl:with-param name="process" select="$process" />
				<xsl:with-param name="onError" select="$onError" />
				<xsl:with-param name="originalOptionNode" select="$optionNode" />
				<xsl:with-param name="comments" select="false()" />
			</xsl:call-template>

			<!-- Exclusive clause -->
			<xsl:if test="$groupOptionNode[@type = 'exclusive'] 
						and $groupOptionNode/prg:databinding/prg:variable 
						and $optionNode/prg:databinding/prg:variable">
				<xsl:call-template name="sh.if">
					<xsl:with-param name="condition">
						<xsl:text>! ([ -z </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name">
								<xsl:apply-templates select="$groupOptionNode/prg:databinding/prg:variable" />
							</xsl:with-param>
							<xsl:with-param name="quoted" select="true()" />
						</xsl:call-template>
						<xsl:text> ] || [ </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name">
								<xsl:apply-templates select="$groupOptionNode/prg:databinding/prg:variable" />
							</xsl:with-param>
							<xsl:with-param name="quoted" select="true()" />
						</xsl:call-template>
						<xsl:text> = "</xsl:text>
						<!-- don't add subcommand prefix in this case -->
						<xsl:call-template name="prg.sh.parser.boundVariableName">
							<xsl:with-param name="variableNode" select="$optionNode/prg:databinding/prg:variable" />
							<xsl:with-param name="usePrefix" select="false()" />
						</xsl:call-template>
						<!-- <apply-templates select="$optionNode/prg:databinding/prg:variable" /> -->
						<xsl:text>" ] || [ </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name">
								<xsl:apply-templates select="$groupOptionNode/prg:databinding/prg:variable" />
							</xsl:with-param>
							<xsl:with-param name="quoted" select="true()" />
							<xsl:with-param name="length" select="1" />
						</xsl:call-template>
						<xsl:text> = "@" ])</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="then">

						<xsl:if test="$process">
							<xsl:value-of select="$prg.sh.parser.fName_adderror" />
							<xsl:text> "Another option of the group \"</xsl:text>
							<!-- don't add subcommand prefix in this case -->
							<xsl:call-template name="prg.sh.parser.boundVariableName">
								<xsl:with-param name="variableNode" select="$groupOptionNode/prg:databinding/prg:variable" />
								<xsl:with-param name="usePrefix" select="false()" />
							</xsl:call-template>
							<!-- <apply-templates select="$groupOptionNode/prg:databinding/prg:variable" /> -->
							<xsl:text>\" was previously set (</xsl:text>
							<xsl:call-template name="sh.var">
								<xsl:with-param name="name">
									<xsl:apply-templates select="$groupOptionNode/prg:databinding/prg:variable" />
								</xsl:with-param>
							</xsl:call-template>
							<xsl:text>)"</xsl:text>

							<!-- Skip option arg if required -->
							<xsl:choose>
								<xsl:when test="$originalOptionNode/self::prg:argument">
									<xsl:value-of select="$sh.endl" />
									<xsl:call-template name="prg.sh.parser.argumentPreprocess">
										<xsl:with-param name="onError" select="$onError" />
										<xsl:with-param name="optionNode" select="$originalOptionNode" />
									</xsl:call-template>
									<xsl:value-of select="$sh.endl" />
								</xsl:when>
								<xsl:when test="$originalOptionNode/self::prg:multiargument">
									<xsl:value-of select="$sh.endl" />
									<!-- Here, the prg.sh.parser.argumentPreprocess suits better than prg.sh.parser.multiargumentPreprocess -->
									<xsl:call-template name="prg.sh.parser.argumentPreprocess">
										<xsl:with-param name="onError" select="$onError" />
										<xsl:with-param name="optionNode" select="$originalOptionNode" />
									</xsl:call-template>
									<xsl:value-of select="$sh.endl" />
								</xsl:when>
							</xsl:choose>
						</xsl:if>

						<xsl:if test="$onError">
							<xsl:value-of select="$sh.endl" />
							<xsl:value-of select="$onError" />
						</xsl:if>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template name="prg.sh.parser.numberCheck">
		<xsl:param name="numberNode" />
		<xsl:param name="value">
			<xsl:call-template name="sh.var">
				<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
				<xsl:with-param name="quoted" select="true()" />
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="onError" />
		<xsl:param name="currentItem" />
		<xsl:param name="interpreter" />

		<xsl:variable name="errorCode">
			<xsl:value-of select="$prg.sh.parser.fName_adderror" />
			<xsl:text> "Invalid value \"</xsl:text>
			<xsl:value-of select="$value" />
			<xsl:text>\"</xsl:text>
			<xsl:text> for </xsl:text>
			<xsl:value-of select="$currentItem" />
			<xsl:text>. Number expected"</xsl:text>
			<xsl:if test="$onError">
				<xsl:value-of select="$sh.endl" />
				<xsl:value-of select="$onError" />
			</xsl:if>
		</xsl:variable>

		<xsl:call-template name="sh.if">
			<xsl:with-param name="condition">
				<xsl:text>! echo -n "</xsl:text>
				<xsl:value-of select="$value" />
				<xsl:text>" | grep -E "\-?[0-9]+(\.[0-9]+)*" </xsl:text>
				<xsl:call-template name="sh.chunk.nullRedirection" />
			</xsl:with-param>
			<xsl:with-param name="then">
				<xsl:value-of select="$errorCode" />
			</xsl:with-param>
			<xsl:with-param name="else">
				<xsl:if test="$numberNode[@min]">
					<xsl:call-template name="sh.if">
						<xsl:with-param name="condition">
							<xsl:text>! </xsl:text>
							<xsl:value-of select="$prg.sh.parser.fName_numberLesserEqualcheck" />
							<xsl:text> </xsl:text>
							<xsl:value-of select="$numberNode/@min" />
							<xsl:text> </xsl:text>
							<xsl:value-of select="$value" />
						</xsl:with-param>
						<xsl:with-param name="then">
							<xsl:value-of select="$errorCode" />
						</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="$numberNode[@max]">
					<xsl:call-template name="sh.if">
						<xsl:with-param name="condition">
							<xsl:text>! </xsl:text>
							<xsl:value-of select="$prg.sh.parser.fName_numberLesserEqualcheck" />
							<xsl:text> </xsl:text>
							<xsl:value-of select="$value" />
							<xsl:text> </xsl:text>
							<xsl:value-of select="$numberNode/@max" />
						</xsl:with-param>
						<xsl:with-param name="then">
							<xsl:value-of select="$errorCode" />
						</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
		
	</xsl:template>

	<xsl:template name="prg.sh.parser.existingCommandCheck">
		<xsl:param name="value">
			<xsl:call-template name="sh.var">
				<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
				<xsl:with-param name="quoted" select="true()" />
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="onError" />
		<xsl:param name="currentItem" />

		<xsl:call-template name="sh.if">
			<xsl:with-param name="condition">
				<xsl:text>! which "</xsl:text>
				<xsl:value-of select="$value" />
				<xsl:text>" </xsl:text>
				<xsl:call-template name="sh.chunk.nullRedirection" />
			</xsl:with-param>
			<xsl:with-param name="then">
				<xsl:value-of select="$prg.sh.parser.fName_adderror" />
				<xsl:text> "Invalid command \"</xsl:text>
				<xsl:value-of select="$value" />
				<xsl:text>\"</xsl:text>

				<xsl:text> for </xsl:text>
				<xsl:value-of select="$currentItem" />
				<xsl:text>"</xsl:text>

				<xsl:if test="$onError">
					<xsl:value-of select="$sh.endl" />
					<xsl:value-of select="$onError" />
				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.sh.parser.pathTypeAccessCheck">
		<xsl:param name="value">
			<xsl:call-template name="sh.var">
				<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="onError" />
		<xsl:param name="accessString" />
		<xsl:param name="currentItem" />

		<xsl:call-template name="sh.if">
			<xsl:with-param name="condition">
				<xsl:text>! </xsl:text>
				<xsl:value-of select="$prg.sh.parser.fName_pathaccesscheck" />
				<xsl:text> "</xsl:text>
				<xsl:value-of select="$value" />
				<xsl:text>" "</xsl:text>
				<xsl:value-of select="$accessString" />
				<xsl:text>"</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="then">
				<xsl:value-of select="$prg.sh.parser.fName_adderror" />
				<xsl:text> "Invalid path permissions for \"</xsl:text>
				<xsl:value-of select="$value" />
				<xsl:text>\", </xsl:text>
				<xsl:value-of select="$accessString" />
				<xsl:text> privilege(s) expected for </xsl:text>
				<xsl:value-of select="$currentItem" />
				<xsl:text>"</xsl:text>
				<xsl:if test="$onError">
					<xsl:value-of select="$sh.endl" />
					<xsl:value-of select="$onError" />
				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:value-of select="$sh.endl" />
	</xsl:template>

	<xsl:template name="prg.sh.parser.pathTypeKindsCheck">
		<xsl:param name="value">
			<xsl:call-template name="sh.var">
				<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="kindsNode" />
		<xsl:param name="onError" />
		<xsl:param name="currentItem" />

		<xsl:call-template name="sh.if">
			<xsl:with-param name="condition">
				<xsl:text>[ -a "</xsl:text>
				<xsl:value-of select="$value" />
				<xsl:text>" ]  &amp;&amp; ! (</xsl:text>
				<xsl:for-each select="$kindsNode/*">
					<xsl:if test="position() != 1">
						<xsl:text> || </xsl:text>
					</xsl:if>
					<xsl:text>[ -</xsl:text>
					<xsl:choose>
						<xsl:when test="self::prg:file">
							<xsl:text>f</xsl:text>
						</xsl:when>
						<xsl:when test="self::prg:folder">
							<xsl:text>d</xsl:text>
						</xsl:when>
						<xsl:when test="self::prg:symlink">
							<xsl:text>L</xsl:text>
						</xsl:when>
						<xsl:when test="self::prg:socket">
							<xsl:text>S</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>a</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text> "</xsl:text>
					<xsl:value-of select="$value" />
					<xsl:text>" ]</xsl:text>
				</xsl:for-each>
				<xsl:text>)</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="then">
				<xsl:value-of select="$prg.sh.parser.fName_adderror" />
				<xsl:text> "Invalid patn type for </xsl:text>
				<xsl:value-of select="$currentItem" />
				<xsl:text>"</xsl:text>
				<xsl:if test="$onError">
					<xsl:value-of select="$sh.endl" />
					<xsl:value-of select="$onError" />
				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:value-of select="$sh.endl" />
	</xsl:template>

	<xsl:template name="prg.sh.parser.pathTypePresenceCheck">
		<xsl:param name="value">
			<xsl:call-template name="sh.var">
				<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="onError" />
		<xsl:param name="currentItem" />

		<xsl:call-template name="sh.if">
			<xsl:with-param name="condition">
				<xsl:text>[ ! -e "</xsl:text>
				<xsl:value-of select="$value" />
				<xsl:text>" ]</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="then">
				<xsl:value-of select="$prg.sh.parser.fName_adderror" />
				<xsl:text> "Invalid path \"</xsl:text>
				<xsl:value-of select="$value" />
				<xsl:text>\" for </xsl:text>
				<xsl:value-of select="$currentItem" />
				<xsl:text>"</xsl:text>
				<xsl:if test="$onError">
					<xsl:value-of select="$sh.endl" />
					<xsl:value-of select="$onError" />
				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:value-of select="$sh.endl" />
	</xsl:template>

	<xsl:template name="prg.sh.parser.optionValueTypeCheck">
		<xsl:param name="node" select="." />
		<xsl:param name="value">
			<xsl:call-template name="sh.var">
				<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="onError" />
		<xsl:param name="interpreter" />
		<xsl:param name="currentItem">
			<xsl:text>option \"</xsl:text>
			<xsl:call-template name="sh.var">
				<xsl:with-param name="name" select="$prg.sh.parser.vName_option" />
			</xsl:call-template>
			<xsl:text>\"</xsl:text>
		</xsl:param>

		<!-- <call-template name="sh.comment">
			<with-param name="content">
				<text>Value type check</text>
			</with-param>
		</call-template>
		<value-of select="$sh.endl" /> -->

		<xsl:choose>
			<xsl:when test="$node/prg:type/prg:number">
				<xsl:call-template name="prg.sh.parser.numberCheck">
					<xsl:with-param name="numberNode" select="$node/prg:type/prg:number" />
					<xsl:with-param name="value" select="$value" />
					<xsl:with-param name="onError" select="$onError" />
					<xsl:with-param name="currentItem" select="$currentItem" />
					<xsl:with-param name="interpreter" select="$interpreter" />
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />
			</xsl:when>
			<xsl:when test="$node/prg:type/prg:path">
				<xsl:variable name="pathNode" select="$node/prg:type/prg:path" />

				<xsl:if test="$pathNode/@exist">
					<!-- check presence -->
					<xsl:call-template name="prg.sh.parser.pathTypePresenceCheck">
						<xsl:with-param name="value" select="$value" />
						<xsl:with-param name="onError" select="$onError" />
						<xsl:with-param name="currentItem" select="$currentItem" />
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="$pathNode/@access">
					<!-- check permissions (imply exist) -->
					<xsl:call-template name="prg.sh.parser.pathTypeAccessCheck">
						<xsl:with-param name="value" select="$value" />
						<xsl:with-param name="accessString" select="$pathNode/@access" />
						<xsl:with-param name="onError" select="$onError" />
						<xsl:with-param name="currentItem" select="$currentItem" />
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="$pathNode/prg:kinds and (($pathNode/@exist = 'true') or $pathNode/@access)">
					<xsl:call-template name="prg.sh.parser.pathTypeKindsCheck">
						<xsl:with-param name="value" select="$value" />
						<xsl:with-param name="kindsNode" select="$pathNode/prg:kinds" />
						<xsl:with-param name="onError" select="$onError" />
						<xsl:with-param name="currentItem" select="$currentItem" />
					</xsl:call-template>
				</xsl:if>
			</xsl:when>

			<xsl:when test="$node/prg:type/prg:existingcommand">
				<xsl:call-template name="prg.sh.parser.existingCommandCheck">
					<xsl:with-param name="value" select="$value" />
					<xsl:with-param name="onError" select="$onError" />
					<xsl:with-param name="currentItem" select="$currentItem" />
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />
			</xsl:when>
		</xsl:choose>

	</xsl:template>

	<!-- long option case -->
	<xsl:template name="prg.sh.parser.longOptionSwitch">
		<xsl:param name="optionsNode" />
		<xsl:param name="onError" />
		<xsl:param name="onUnknownOption" />
		<xsl:param name="interpreter" />

		<xsl:call-template name="sh.case">
			<xsl:with-param name="case">
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name" select="$prg.sh.parser.vName_option" />
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="in">
				<xsl:for-each select="$optionsNode/*/prg:names/prg:long/../..">
					<xsl:call-template name="prg.sh.parser.optionCase">
						<xsl:with-param name="optionNode" select="." />
						<xsl:with-param name="onError" select="$onError" />
						<xsl:with-param name="interpreter" select="$interpreter" />
					</xsl:call-template>
				</xsl:for-each>

				<xsl:for-each select="$optionsNode//prg:group/prg:options/*/prg:names/prg:long/../..">
					<xsl:call-template name="prg.sh.parser.optionCase">
						<xsl:with-param name="optionNode" select="." />
						<xsl:with-param name="onError" select="$onError" />
						<xsl:with-param name="interpreter" select="$interpreter" />
					</xsl:call-template>
				</xsl:for-each>

				<xsl:call-template name="sh.caseblock">
					<xsl:with-param name="case">
						<xsl:text>*</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="content">
						<xsl:value-of select="$onUnknownOption" />
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.sh.parser.checkMax">
		<xsl:param name="node" select="." />
		<xsl:param name="isOption" select="true()" />
		<xsl:param name="valueVariableName" />
		<xsl:param name="max" />
		<xsl:param name="onError" />

		<xsl:variable name="valueVariable">
			<xsl:call-template name="sh.var">
				<xsl:with-param name="name" select="$valueVariableName" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:if test="$max and ($max &gt; 0)">
			<xsl:call-template name="sh.if">
				<xsl:with-param name="condition">
					<xsl:text>[ </xsl:text>
					<xsl:value-of select="$valueVariable" />
					<xsl:text> -ge </xsl:text>
					<xsl:value-of select="$max" />
					<xsl:text> ]</xsl:text>
				</xsl:with-param>
				<xsl:with-param name="then">
					<xsl:value-of select="$prg.sh.parser.fName_adderror" />
					<xsl:text> "Maximum argument count reached for </xsl:text>
					<xsl:choose>
						<xsl:when test="$isOption">
							<xsl:text>option \"</xsl:text>
							<xsl:call-template name="sh.var">
								<xsl:with-param name="name" select="$prg.sh.parser.vName_option" />
							</xsl:call-template>
							<xsl:text>\"</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>value</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>"</xsl:text>
					<xsl:if test="$onError">
						<xsl:value-of select="$sh.endl" />
						<xsl:value-of select="$onError" />
					</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="prg.sh.parser.optionCase">
		<xsl:param name="optionNode" select="." />
		<xsl:param name="shortOption" select="false()" />
		<xsl:param name="onError" />
		<xsl:param name="interpreter" />

		<xsl:variable name="optionVariableName">
			<xsl:apply-templates select="$optionNode/prg:databinding/prg:variable" />
		</xsl:variable>

		<xsl:call-template name="sh.caseblock">
			<xsl:with-param name="case">
				<xsl:choose>
					<xsl:when test="$shortOption">
						<xsl:for-each select="$optionNode/prg:names/prg:short">
							<xsl:value-of select="." />
							<xsl:if test="position() != last()">
								<xsl:text> | </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="$optionNode/prg:names/prg:long">
							<xsl:value-of select="." />
							<xsl:if test="position() != last()">
								<xsl:text> | </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="content">

				<!-- Check group -->
				<xsl:call-template name="prg.sh.parser.groupCheck">
					<xsl:with-param name="optionNode" select="$optionNode" />
					<xsl:with-param name="onError" select="$onError" />
				</xsl:call-template>

				<xsl:choose>
					<xsl:when test="$optionNode/self::prg:argument">
						<xsl:call-template name="prg.sh.parser.argumentPreprocess">
							<xsl:with-param name="onError" select="$onError" />
						</xsl:call-template>
						<xsl:value-of select="$sh.endl" />
						<xsl:call-template name="prg.sh.parser.optionValueTypeCheck">
							<xsl:with-param name="node" select="$optionNode" />
							<xsl:with-param name="onError" select="$onError" />
							<xsl:with-param name="interpreter" select="$interpreter" />
						</xsl:call-template>
						<xsl:call-template name="prg.sh.parser.valueRestrictionCheck">
							<xsl:with-param name="optionNode" select="$optionNode" />
							<xsl:with-param name="onError" select="$onError" />
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$optionNode/self::prg:multiargument">
						<xsl:call-template name="prg.sh.parser.multiargumentPreprocess">
							<xsl:with-param name="onError" select="$onError" />
						</xsl:call-template>
						<xsl:value-of select="$sh.endl" />

						<xsl:call-template name="sh.local">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_ma_local_count" />
							<xsl:with-param name="interpreter" select="$interpreter" />
							<xsl:with-param name="value" select="0" />
						</xsl:call-template>
						<xsl:value-of select="$sh.endl" />
						<xsl:call-template name="sh.local">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_ma_total_count" />
							<xsl:with-param name="interpreter" select="$interpreter" />
							<xsl:with-param name="value">
								<xsl:call-template name="sh.arrayLength">
									<xsl:with-param name="name" select="$optionVariableName" />
								</xsl:call-template>
							</xsl:with-param>
							<xsl:with-param name="quoted" select="false()" />
						</xsl:call-template>
						<xsl:value-of select="$sh.endl" />

						<xsl:call-template name="prg.sh.parser.checkMax">
							<xsl:with-param name="node" select="$optionNode" />
							<xsl:with-param name="valueVariableName" select="$prg.sh.parser.vName_ma_total_count" />
							<xsl:with-param name="max" select="$optionNode/@max" />
							<xsl:with-param name="onError" select="$onError" />
						</xsl:call-template>

						<!-- First item -->
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
								<xsl:call-template name="prg.sh.parser.optionValueTypeCheck">
									<xsl:with-param name="node" select="$optionNode" />
									<xsl:with-param name="onError" select="$onError" />
									<xsl:with-param name="interpreter" select="$interpreter" />
								</xsl:call-template>
								<xsl:call-template name="prg.sh.parser.valueRestrictionCheck">
									<xsl:with-param name="optionNode" select="$optionNode" />
									<xsl:with-param name="onError" select="$onError" />
								</xsl:call-template>
								<xsl:call-template name="sh.arrayAppend">
									<xsl:with-param name="name" select="$optionVariableName" />
									<xsl:with-param name="startIndex" select="$prg.sh.parser.var_startindex" />
									<xsl:with-param name="value">
										<xsl:call-template name="sh.var">
											<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
											<xsl:with-param name="quoted" select="true()" />
										</xsl:call-template>
									</xsl:with-param>
								</xsl:call-template>
								<xsl:value-of select="$sh.endl" />
								<xsl:call-template name="sh.varincrement">
									<xsl:with-param name="name" select="$prg.sh.parser.vName_ma_total_count" />
								</xsl:call-template>
								<xsl:value-of select="$sh.endl" />
								<xsl:call-template name="sh.varincrement">
									<xsl:with-param name="name" select="$prg.sh.parser.vName_ma_local_count" />
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
						<xsl:value-of select="$sh.endl" />

						<!-- Others -->
						<xsl:variable name="nextitem">
							<xsl:call-template name="prg.prefixedName">
								<xsl:with-param name="name">
									<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
									<xsl:text>nextitem</xsl:text>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:variable>

						<xsl:call-template name="sh.local">
							<xsl:with-param name="name" select="$nextitem" />
							<xsl:with-param name="interpreter" select="$interpreter" />
							<xsl:with-param name="value">
								<xsl:call-template name="sh.var">
									<xsl:with-param name="name" select="$prg.sh.parser.vName_input" />
									<xsl:with-param name="quoted" select="false()" />
									<xsl:with-param name="index">
										<xsl:text>$(expr </xsl:text>
										<xsl:call-template name="sh.var">
											<xsl:with-param name="name" select="$prg.sh.parser.vName_index" />
										</xsl:call-template>
										<xsl:text> + 1)</xsl:text>
									</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
						<xsl:value-of select="$sh.endl" />

						<xsl:call-template name="sh.while">
							<xsl:with-param name="condition">
								<xsl:if test="$optionNode/@max and ($optionNode/@max &gt; 0)">
									<xsl:text>[ </xsl:text>
									<xsl:call-template name="sh.var">
										<xsl:with-param name="name" select="$prg.sh.parser.vName_ma_total_count" />
									</xsl:call-template>
									<xsl:text> -lt </xsl:text>
									<xsl:value-of select="$optionNode/@max" />
									<xsl:text> ] &amp;&amp; </xsl:text>
								</xsl:if>
								<xsl:text>[ ! -z </xsl:text>
								<xsl:call-template name="sh.var">
									<xsl:with-param name="name" select="$nextitem" />
									<xsl:with-param name="quoted" select="true()" />
								</xsl:call-template>
								<xsl:text> ] &amp;&amp; [ </xsl:text>
								<xsl:call-template name="sh.var">
									<xsl:with-param name="name" select="$nextitem" />
									<xsl:with-param name="quoted" select="true()" />
								</xsl:call-template>
								<xsl:text> != "--" ] &amp;&amp; [ </xsl:text>
								<xsl:call-template name="sh.var">
									<xsl:with-param name="name" select="$prg.sh.parser.vName_index" />
								</xsl:call-template>
								<xsl:text> -lt </xsl:text>
								<xsl:call-template name="sh.var">
									<xsl:with-param name="name" select="$prg.sh.parser.vName_itemcount" />
								</xsl:call-template>
								<xsl:text> ]</xsl:text>
							</xsl:with-param>
							<xsl:with-param name="do">
								<!-- Stop on '-[something]' if not first -->
								<xsl:call-template name="sh.if">
									<xsl:with-param name="condition">
										<xsl:text>[ </xsl:text>
										<xsl:call-template name="sh.var">
											<xsl:with-param name="name" select="$prg.sh.parser.vName_ma_local_count" />
										</xsl:call-template>
										<xsl:text> -gt 0</xsl:text>
										<xsl:text> ] &amp;&amp; [ </xsl:text>
										<xsl:call-template name="sh.var">
											<xsl:with-param name="name" select="$nextitem" />
											<xsl:with-param name="quoted" select="true()" />
											<xsl:with-param name="length" select="1" />
										</xsl:call-template>
										<xsl:text> = "-" ]</xsl:text>
									</xsl:with-param>
									<xsl:with-param name="then">
										<xsl:text>break</xsl:text>
									</xsl:with-param>
								</xsl:call-template>

								<xsl:value-of select="$sh.endl" />
								<xsl:call-template name="prg.sh.parser.indexIncrement" />
								<xsl:value-of select="$sh.endl" />
								<xsl:call-template name="prg.sh.parser.itemUpdate" />
								<xsl:value-of select="$sh.endl" />

								<!-- Checks -->
								<xsl:call-template name="prg.sh.parser.unescapeValue" />
								<xsl:value-of select="$sh.endl" />

								<xsl:call-template name="prg.sh.parser.optionValueTypeCheck">
									<xsl:with-param name="node" select="$optionNode" />
									<xsl:with-param name="onError" select="$onError" />
									<xsl:with-param name="interpreter" select="$interpreter" />
								</xsl:call-template>
								<xsl:call-template name="prg.sh.parser.valueRestrictionCheck">
									<xsl:with-param name="optionNode" select="$optionNode" />
									<xsl:with-param name="onError" select="$onError" />
								</xsl:call-template>

								<xsl:call-template name="sh.arrayAppend">
									<xsl:with-param name="name" select="$optionVariableName" />
									<xsl:with-param name="startIndex" select="$prg.sh.parser.var_startindex" />
									<xsl:with-param name="value">
										<xsl:call-template name="sh.var">
											<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
											<xsl:with-param name="quoted" select="true()" />
										</xsl:call-template>
									</xsl:with-param>
								</xsl:call-template>
								<xsl:value-of select="$sh.endl" />
								<xsl:call-template name="sh.varincrement">
									<xsl:with-param name="name" select="$prg.sh.parser.vName_ma_total_count" />
								</xsl:call-template>
								<xsl:value-of select="$sh.endl" />
								<xsl:call-template name="sh.varincrement">
									<xsl:with-param name="name" select="$prg.sh.parser.vName_ma_local_count" />
								</xsl:call-template>
								<xsl:value-of select="$sh.endl" />

								<xsl:value-of select="$nextitem" />
								<xsl:text>=</xsl:text>
								<xsl:call-template name="sh.var">
									<xsl:with-param name="name" select="$prg.sh.parser.vName_input" />
									<xsl:with-param name="quoted" select="true()" />
									<xsl:with-param name="index">
										<xsl:text>$(expr </xsl:text>
										<xsl:call-template name="sh.var">
											<xsl:with-param name="name" select="$prg.sh.parser.vName_index" />
										</xsl:call-template>
										<xsl:text> + 1)</xsl:text>
									</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
						<xsl:value-of select="$sh.endl" />
						<xsl:call-template name="sh.if">
							<xsl:with-param name="condition">
								<xsl:text>[ </xsl:text>
								<xsl:call-template name="sh.var">
									<xsl:with-param name="name" select="$prg.sh.parser.vName_ma_local_count" />
								</xsl:call-template>
								<xsl:text> -eq 0 ]</xsl:text>
							</xsl:with-param>
							<xsl:with-param name="then">
								<xsl:value-of select="$prg.sh.parser.fName_adderror" />
								<xsl:text> "At least one argument expected for option \"</xsl:text>
								<xsl:call-template name="sh.var">
									<xsl:with-param name="name" select="$prg.sh.parser.vName_option" />
								</xsl:call-template>
								<xsl:text>\""</xsl:text>
								<xsl:if test="$onError">
									<xsl:value-of select="$sh.endl" />
									<xsl:value-of select="$onError" />
								</xsl:if>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
				</xsl:choose>

				<!-- Finally -->

				<xsl:call-template name="prg.sh.parser.optionSetValue">
					<xsl:with-param name="optionNode" select="$optionNode" />
					<xsl:with-param name="onError" select="$onError" />
					<xsl:with-param name="shortOption" select="$shortOption" />
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />

				<xsl:call-template name="prg.sh.parser.groupSetVars">
					<xsl:with-param name="optionNode" select="$optionNode" />
				</xsl:call-template>
				<xsl:call-template name="prg.sh.parser.optionSetPresence">
					<xsl:with-param name="optionNode" select="$optionNode" />
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- short option case -->
	<xsl:template name="prg.sh.parser.shortOptionSwitch">
		<xsl:param name="optionsNode" />
		<xsl:param name="onError" />
		<xsl:param name="onUnknownOption" />
		<xsl:param name="interpreter" />

		<xsl:call-template name="sh.case">
			<xsl:with-param name="case">
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name" select="$prg.sh.parser.vName_option" />
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="in">
				<xsl:for-each select="$optionsNode/*/prg:names/prg:short/../..">
					<xsl:call-template name="prg.sh.parser.optionCase">
						<xsl:with-param name="optionNode" select="." />
						<xsl:with-param name="shortOption" select="true()" />
						<xsl:with-param name="onError" select="$onError" />
						<xsl:with-param name="interpreter" select="$interpreter" />
					</xsl:call-template>
				</xsl:for-each>

				<xsl:for-each select="$optionsNode//prg:group/prg:options/*/prg:names/prg:short/../..">
					<xsl:call-template name="prg.sh.parser.optionCase">
						<xsl:with-param name="optionNode" select="." />
						<xsl:with-param name="shortOption" select="true()" />
						<xsl:with-param name="onError" select="$onError" />
						<xsl:with-param name="interpreter" select="$interpreter" />
					</xsl:call-template>
				</xsl:for-each>

				<xsl:call-template name="sh.caseblock">
					<xsl:with-param name="case">
						<xsl:text>*</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="content">
						<xsl:value-of select="$onUnknownOption" />
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- Add required option ids to required options array -->
	<xsl:template name="prg.sh.parser.optionAddRequired">
		<xsl:param name="optionsNode" />
		<!-- @todo better xquery -->
		<xsl:for-each select="$optionsNode//@required">
			<xsl:variable name="optionNode" select=".." />
			<xsl:if test="../parent::prg:options">
				<xsl:value-of select="$sh.endl" />
				<xsl:call-template name="sh.arrayAppend">
					<xsl:with-param name="name" select="$prg.sh.parser.vName_required" />
					<xsl:with-param name="startIndex" select="$prg.sh.parser.var_startindex" />
					<xsl:with-param name="value">
						<xsl:text>"</xsl:text>
						<xsl:call-template name="prg.optionId">
							<xsl:with-param name="optionNode" select=".." />
						</xsl:call-template>
						<xsl:text>:</xsl:text>
						<xsl:choose>
							<!-- @todo -->
							<xsl:when test="$optionNode/self::prg:group">
								<xsl:for-each select="$optionNode/prg:options/*">
									<xsl:call-template name="prg.sh.optionDisplayName">
										<xsl:with-param name="recursive" select="true()" />
									</xsl:call-template>
									<xsl:if test="position() != last()">
										<xsl:choose>
											<xsl:when test="position() = (last() - 1)">
												<xsl:text> or </xsl:text>
											</xsl:when>
											<xsl:otherwise>
												<xsl:text>, </xsl:text>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:if>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="prg.sh.optionDisplayName">
									<xsl:with-param name="optionNode" select=".." />
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:if test="$optionNode/self::prg:group and $optionNode[@required = 'true']">
							<xsl:variable name="defaultOptionId" select="$optionNode/prg:default/@id" />
							<xsl:variable name="defaultOptionNode" select="$optionNode/prg:options/*[@id = $defaultOptionId]" />
							<xsl:variable name="groupVariable" select="$optionNode/prg:databinding/prg:variable" />
							<xsl:variable name="defaultOptionVariable" select="$defaultOptionNode/prg:databinding/prg:variable" />

							<xsl:if test="$groupVariable and $defaultOptionVariable">
								<xsl:text>:</xsl:text>
								<xsl:apply-templates select="$groupVariable" />
								<xsl:text>=</xsl:text>
								<xsl:apply-templates select="$defaultOptionVariable" />
								<xsl:if test="$defaultOptionNode/self::prg:switch">
									<xsl:text>;</xsl:text>
									<xsl:apply-templates select="$defaultOptionVariable" />
									<xsl:text>=true</xsl:text>
								</xsl:if>
								<!-- recursively set option presence -->
								<xsl:text>;</xsl:text>
								<xsl:call-template name="prg.sh.parser.optionSetPresence">
									<xsl:with-param name="optionNode" select="$defaultOptionNode" />
								</xsl:call-template>
							</xsl:if>
						</xsl:if>
						<xsl:text>"</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="prg.sh.parser.addGlobalError">
		<xsl:param name="value" />

		<xsl:call-template name="sh.arrayAppend">
			<xsl:with-param name="name" select="$prg.sh.parser.vName_errors" />
			<xsl:with-param name="startIndex" select="$prg.sh.parser.var_startindex" />
			<xsl:with-param name="value" select="$value" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.sh.parser.checkValue">
		<xsl:param name="valuesNode" />
		<xsl:param name="interpreter" />
		<xsl:param name="positionVar">
			<xsl:call-template name="sh.var">
				<xsl:with-param name="name" select="'position'" />
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="onError" />
		<!-- Even if a positional argument is invalid, the value is added to the global array -->
		<!--
			<text>return </text>
			<value-of select="$prg.sh.parser.var_ERROR" />
		-->
		<xsl:param name="value">
			<xsl:call-template name="sh.var">
				<xsl:with-param name="name">
					<xsl:text>value</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:param>

		<xsl:variable name="currentItem">
			<xsl:text>positional argument </xsl:text>
			<xsl:value-of select="$positionVar" />
		</xsl:variable>

		<xsl:call-template name="sh.case">
			<xsl:with-param name="case" select="$positionVar" />
			<xsl:with-param name="in">
				<xsl:for-each select="$valuesNode/prg:value">
					<xsl:call-template name="sh.caseblock">
						<xsl:with-param name="case" select="position() - 1" />
						<xsl:with-param name="content">
							<xsl:call-template name="prg.sh.parser.optionValueTypeCheck">
								<xsl:with-param name="node" select="." />
								<xsl:with-param name="value" select="$value" />
								<xsl:with-param name="onError" select="$onError" />
								<xsl:with-param name="interpreter" select="$interpreter" />
								<xsl:with-param name="currentItem" select="$currentItem" />
							</xsl:call-template>
							<xsl:call-template name="prg.sh.parser.valueRestrictionCheck">
								<xsl:with-param name="optionNode" select="." />
								<xsl:with-param name="value" select="$value" />
								<xsl:with-param name="onError" select="$onError" />
								<xsl:with-param name="currentItem" select="$currentItem" />
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
				<xsl:call-template name="sh.caseblock">
					<xsl:with-param name="case">
						<xsl:text>*</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="content">
						<xsl:if test="$valuesNode/prg:other">
							<xsl:call-template name="prg.sh.parser.optionValueTypeCheck">
								<xsl:with-param name="node" select="$valuesNode/prg:other" />
								<xsl:with-param name="value" select="$value" />
								<xsl:with-param name="onError" select="$onError" />
								<xsl:with-param name="interpreter" select="$interpreter" />
								<xsl:with-param name="currentItem" select="$currentItem" />
							</xsl:call-template>
							<xsl:call-template name="prg.sh.parser.valueRestrictionCheck">
								<xsl:with-param name="optionNode" select="$valuesNode/prg:other" />
								<xsl:with-param name="value" select="$value" />
								<xsl:with-param name="onError" select="$onError" />
								<xsl:with-param name="currentItem" select="$currentItem" />
							</xsl:call-template>
						</xsl:if>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- -->
	<xsl:template name="prg.sh.parser.longOptionNameElif">
		<xsl:param name="optionsNode" />
		<xsl:param name="onError" />
		<xsl:param name="onUnknownOption" />
		<xsl:param name="keyword">
			<xsl:text>elif</xsl:text>
		</xsl:param>
		<xsl:param name="interpreter" />

		<xsl:value-of select="$keyword" />
		<xsl:text> [ </xsl:text>
		<xsl:call-template name="sh.var">
			<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
			<xsl:with-param name="quoted" select="true()" />
			<xsl:with-param name="length" select="2" />
		</xsl:call-template>
		<xsl:text> = "--" ] </xsl:text>
		<xsl:value-of select="$sh.endl" />
		<xsl:text>then</xsl:text>
		<xsl:call-template name="code.block">
			<xsl:with-param name="content">
				<!-- Remove 2 minus signs -->
				<xsl:value-of select="$prg.sh.parser.vName_option" />
				<xsl:text>=</xsl:text>
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
					<xsl:with-param name="quoted" select="true()" />
					<xsl:with-param name="start" select="2" />
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />

				<!-- check option="value" form -->
				<xsl:call-template name="sh.if">
					<xsl:with-param name="condition">
						<xsl:text>echo </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_option" />
							<xsl:with-param name="quoted" select="true()" />
						</xsl:call-template>
						<xsl:text> | grep "=" </xsl:text>
						<xsl:call-template name="sh.chunk.nullRedirection" />
					</xsl:with-param>
					<xsl:with-param name="then">
						<!-- split item between "=" -->
						<xsl:value-of select="$prg.sh.parser.vName_optiontail" />
						<xsl:text>=</xsl:text>
						<xsl:text>"$(echo </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_option" />
							<xsl:with-param name="quoted" select="true()" />
						</xsl:call-template>
						<xsl:text> | cut -f 2- -d"=")"</xsl:text>
						<xsl:value-of select="$sh.endl" />

						<xsl:value-of select="$prg.sh.parser.vName_option" />
						<xsl:text>=</xsl:text>
						<xsl:text>"$(echo </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_option" />
							<xsl:with-param name="quoted" select="true()" />
						</xsl:call-template>
						<xsl:text> | cut -f 1 -d"=")"</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />

				<!-- option processing -->
				<xsl:call-template name="prg.sh.parser.longOptionSwitch">
					<xsl:with-param name="optionsNode" select="$optionsNode" />
					<xsl:with-param name="onError" select="$onError" />
					<xsl:with-param name="onUnknownOption" select="$onUnknownOption" />
					<xsl:with-param name="interpreter" select="$interpreter" />
				</xsl:call-template>

			</xsl:with-param>
		</xsl:call-template>

	</xsl:template>

	<xsl:template name="prg.sh.parser.shortOptionNameElif">
		<xsl:param name="optionsNode" />
		<xsl:param name="onError" />
		<xsl:param name="onSuccess" />
		<xsl:param name="onUnknownOption" />
		<xsl:param name="keyword">
			<xsl:text>elif</xsl:text>
		</xsl:param>
		<xsl:param name="interpreter" />

		<xsl:value-of select="$keyword" />
		<xsl:text> [ </xsl:text>
		<xsl:call-template name="sh.var">
			<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
			<xsl:with-param name="quoted" select="true()" />
			<xsl:with-param name="length" select="1" />
		</xsl:call-template>
		<xsl:text> = "-" ] &amp;&amp; [ </xsl:text>
		<xsl:call-template name="sh.varLength">
			<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
		</xsl:call-template>
		<xsl:text> -gt 1 ]</xsl:text>
		<xsl:value-of select="$sh.endl" />
		<xsl:text>then</xsl:text>
		<xsl:call-template name="code.block">
			<xsl:with-param name="content">
				<!-- Split item according current subindex -->
				<xsl:value-of select="$prg.sh.parser.vName_optiontail" />
				<xsl:text>=</xsl:text>
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
					<xsl:with-param name="quoted" select="true()" />
					<xsl:with-param name="start">
						<xsl:text>$(expr </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_subindex" />
						</xsl:call-template>
						<xsl:text> + 2)</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />

				<xsl:value-of select="$prg.sh.parser.vName_option" />
				<xsl:text>=</xsl:text>
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name" select="$prg.sh.parser.vName_item" />
					<xsl:with-param name="quoted" select="true()" />
					<xsl:with-param name="start">
						<xsl:text>$(expr </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_subindex" />
						</xsl:call-template>
						<xsl:text> + 1)</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="length" select="1" />
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />

				<xsl:call-template name="sh.if">
					<xsl:with-param name="condition">
						<xsl:text>[ -z </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$prg.sh.parser.vName_option" />
							<xsl:with-param name="quoted" select="true()" />
						</xsl:call-template>
						<xsl:text> ]</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="then">
						<xsl:value-of select="$prg.sh.parser.vName_subindex" />
						<xsl:text>=0</xsl:text>
						<xsl:value-of select="$sh.endl" />

						<xsl:value-of select="$onSuccess" />
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$sh.endl" />

				<!-- option processing -->
				<xsl:call-template name="prg.sh.parser.shortOptionSwitch">
					<xsl:with-param name="optionsNode" select="$optionsNode" />
					<xsl:with-param name="onError" select="$onError" />
					<xsl:with-param name="onUnknownOption" select="$onUnknownOption" />
					<xsl:with-param name="interpreter" select="$interpreter" />
				</xsl:call-template>

			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- Variable Initialization -->
	<xsl:template name="prg.sh.parser.initialize">
		<xsl:param name="programNode" select="." />

		<xsl:value-of select="$prg.sh.parser.vName_shell" />
		<xsl:text>="$(readlink /proc/$$/exe | sed "s/.*\/\([a-z]*\)[0-9]*/\1/g")"</xsl:text>
		<xsl:value-of select="$sh.endl" />
		<xsl:value-of select="$prg.sh.parser.vName_input" />
		<xsl:text>=("${@}")</xsl:text>
		<xsl:value-of select="$sh.endl" />
		<xsl:value-of select="$prg.sh.parser.vName_itemcount" />
		<xsl:text>=</xsl:text>
		<xsl:call-template name="sh.arrayLength">
			<xsl:with-param name="name" select="$prg.sh.parser.vName_input" />
		</xsl:call-template>
		<xsl:value-of select="$sh.endl" />
		<xsl:value-of select="$prg.sh.parser.vName_startindex" />
		<xsl:text>=0</xsl:text>
		<xsl:value-of select="$sh.endl" />
		<xsl:value-of select="$prg.sh.parser.vName_index" />
		<xsl:text>=0</xsl:text>
		<xsl:value-of select="$sh.endl" />
		<xsl:value-of select="$prg.sh.parser.vName_subindex" />
		<xsl:text>=0</xsl:text>
		<xsl:value-of select="$sh.endl" />
		<xsl:value-of select="$prg.sh.parser.vName_item" />
		<xsl:text>=""</xsl:text>
		<xsl:value-of select="$sh.endl" />
		<xsl:value-of select="$prg.sh.parser.vName_option" />
		<xsl:text>=""</xsl:text>
		<xsl:value-of select="$sh.endl" />
		<xsl:value-of select="$prg.sh.parser.vName_optiontail" />
		<xsl:text>=""</xsl:text>
		<xsl:value-of select="$sh.endl" />
		<xsl:value-of select="$prg.sh.parser.vName_subcommand" />
		<xsl:text>=""</xsl:text>
		<xsl:value-of select="$sh.endl" />
		<xsl:value-of select="$prg.sh.parser.vName_subcommand_expected" />
		<xsl:text>=</xsl:text>

		<xsl:choose>
			<xsl:when test="$programNode/prg:subcommands">
				<xsl:text>true</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>false</xsl:text>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:value-of select="$sh.endl" />
		<xsl:value-of select="$prg.sh.parser.vName_OK" />
		<xsl:text>=0</xsl:text>
		<xsl:value-of select="$sh.endl" />
		<xsl:value-of select="$prg.sh.parser.vName_ERROR" />
		<xsl:text>=1</xsl:text>
		<xsl:value-of select="$sh.endl" />
		<xsl:value-of select="$prg.sh.parser.vName_SC_OK" />
		<xsl:text>=0</xsl:text>
		<xsl:value-of select="$sh.endl" />
		<xsl:value-of select="$prg.sh.parser.vName_SC_ERROR" />
		<xsl:text>=1</xsl:text>
		<xsl:value-of select="$sh.endl" />
		<xsl:value-of select="$prg.sh.parser.vName_SC_UNKNOWN" />
		<xsl:text>=2</xsl:text>
		<xsl:value-of select="$sh.endl" />
		<xsl:value-of select="$prg.sh.parser.vName_SC_SKIP" />
		<xsl:text>=3</xsl:text>
		<xsl:value-of select="$sh.endl" />

		<xsl:call-template name="sh.comment">
			<xsl:with-param name="content">
				<xsl:text>Compatibility with shell which use "1" as start index</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:value-of select="$sh.endl" />
		<xsl:text>[ </xsl:text>
		<xsl:call-template name="sh.var">
			<xsl:with-param name="name" select="$prg.sh.parser.vName_shell" />
			<xsl:with-param name="quoted" select="true()" />
		</xsl:call-template>
		<xsl:text> = "zsh" ] &amp;&amp; </xsl:text>
		<xsl:value-of select="$prg.sh.parser.vName_startindex" />
		<xsl:text>=1</xsl:text>
		<xsl:value-of select="$sh.endl" />

		<xsl:value-of select="$prg.sh.parser.vName_itemcount" />
		<xsl:text>=$(expr </xsl:text>
		<xsl:value-of select="$prg.sh.parser.var_startindex" />
		<xsl:text> + </xsl:text>
		<xsl:call-template name="sh.var">
			<xsl:with-param name="name" select="$prg.sh.parser.vName_itemcount" />
		</xsl:call-template>
		<xsl:text>)</xsl:text>
		<xsl:value-of select="$sh.endl" />

		<xsl:value-of select="$prg.sh.parser.vName_index" />
		<xsl:text>=</xsl:text>
		<xsl:value-of select="$prg.sh.parser.var_startindex" />
		<xsl:value-of select="$sh.endl" />

		<xsl:value-of select="$sh.endl" />
		<xsl:call-template name="sh.comment">
			<xsl:with-param name="content">
				<xsl:text>Required global options</xsl:text>
				<xsl:value-of select="$sh.endl" />
				<xsl:text>(Subcommand required options will be added later)</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:value-of select="$sh.endl" />
		<xsl:call-template name="prg.sh.parser.optionAddRequired">
			<xsl:with-param name="optionsNode" select="$programNode/prg:options" />
		</xsl:call-template>
		<xsl:value-of select="$sh.endl" />

		<xsl:if test="//prg:switch/prg:databinding/prg:variable">
			<xsl:call-template name="sh.comment">
				<xsl:with-param name="content">
					<xsl:text>Switch options</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:value-of select="$sh.endl" />
			<xsl:for-each select="//prg:switch/prg:databinding/prg:variable">
				<xsl:apply-templates select="." />
				<xsl:choose>
					<xsl:when test="../@node = 'integer'">
						<xsl:text>=0</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>=false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="$sh.endl" />
			</xsl:for-each>
		</xsl:if>

		<xsl:if test="//prg:argument/prg:databinding/prg:variable">
			<xsl:call-template name="sh.comment">
				<xsl:with-param name="content">
					<xsl:text>Single argument options</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:value-of select="$sh.endl" />
			<xsl:for-each select="//prg:argument/prg:databinding/prg:variable">
				<xsl:apply-templates select="." />
				<xsl:text>=</xsl:text>
				<!-- default arguments are set later -->
				<!-- <if test="../../prg:default">
					<text>"</text>
					<value-of select="../../prg:default" />
					<text>"</text>
					</if> -->
				<xsl:value-of select="$sh.endl" />
			</xsl:for-each>
		</xsl:if>

		<xsl:if test="//prg:group/prg:default">
			<xsl:call-template name="sh.comment">
				<xsl:with-param name="content">
					<xsl:text>Group default options</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:for-each select="//prg:group[prg:default]">
				<xsl:variable name="defaultOptionId" select="prg:default/@id" />
				<xsl:variable name="defaultOptionNode" select="./prg:options/*[@id = $defaultOptionId]" />
				<xsl:if test="./prg:databinding/prg:variable and $defaultOptionNode/prg:databinding/prg:variable">
					<xsl:apply-templates select="prg:databinding/prg:variable" />
					<xsl:text>="@</xsl:text>
					<xsl:apply-templates select="$defaultOptionNode/prg:databinding/prg:variable" />
					<xsl:text>"</xsl:text>
					<xsl:value-of select="$sh.endl" />
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
		<xsl:value-of select="$sh.endl" />
	</xsl:template>

</xsl:stylesheet>

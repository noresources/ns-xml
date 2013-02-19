<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Shell parser code chunks -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">

	<import href="base.xsl" />
	<import href="parser.variables.xsl" />

	<!-- "$parser_index++" -->
	<template name="prg.sh.parser.indexIncrement">
		<call-template name="sh.varincrement">
			<with-param name="name" select="$prg.sh.parser.vName_index" />
		</call-template>
	</template>

	<!-- parser_item=${parser_input[$parser_index]} -->
	<template name="prg.sh.parser.itemUpdate">
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
	</template>

	<!-- for each remaining input, append parser_input[] to parser_values[] -->
	<template name="prg.sh.parser.copyValues">
		<call-template name="sh.incrementalFor">
			<with-param name="variable">
				<text>a</text>
			</with-param>
			<with-param name="init">
				<text>$(expr </text>
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_index" />
				</call-template>
				<text> + 1)</text>
			</with-param>
			<with-param name="limit">
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_itemcount" />
				</call-template>
			</with-param>
			<with-param name="do">
				<value-of select="$prg.sh.parser.fName_addvalue" />
				<value-of select="' '" />
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_input" />
					<with-param name="quoted" select="true()" />
					<with-param name="index">
						<call-template name="sh.var">
							<with-param name="name">
								<text>a</text>
							</with-param>
						</call-template>
					</with-param>
				</call-template>
			</with-param>
		</call-template>
		<value-of select="$sh.endl" />
		<value-of select="$prg.sh.parser.vName_index" />
		<text>=</text>
		<call-template name="sh.var">
			<with-param name="name" select="$prg.sh.parser.vName_itemcount" />
		</call-template>
	</template>

	<!-- call setoptionprecence if necessary -->
	<!-- @todo use unified id -->
	<template name="prg.sh.parser.optionSetPresence">
		<param name="optionNode" select="." />
		<param name="inline" select="true()" />

		<variable name="parentNode" select="$optionNode/../.." />

		<value-of select="$prg.sh.parser.fName_setoptionpresence" />
		<value-of select="' '" />
		<call-template name="prg.optionId">
			<with-param name="optionNode" select="$optionNode" />
		</call-template>

		<if test="$parentNode/self::prg:group">
			<choose>
				<when test="$inline">
					<text>;</text>
				</when>
				<otherwise>
					<value-of select="$sh.endl" />
				</otherwise>
			</choose>
			<call-template name="prg.sh.parser.optionSetPresence">
				<with-param name="optionNode" select="$parentNode" />
				<with-param name="inline" select="$inline" />
			</call-template>
		</if>
	</template>

	<!-- Set default values for all single arguments in a root item info
		(part of the setdefaultarguments function)
	-->
	<template name="prg.sh.parser.setDefaultArguments">
		<param name="rootNode" />
		<param name="interpreter" />

		<for-each select="$rootNode//prg:argument[prg:default and prg:databinding/prg:variable]">
			<call-template name="sh.comment">
				<with-param name="content">
					<apply-templates select="prg:databinding/prg:variable" />
				</with-param>
			</call-template>
			<value-of select="$sh.endl" />

			<call-template name="sh.if">
				<with-param name="condition">
					<text>[ -z "</text>
					<call-template name="sh.var">
						<with-param name="name">
							<apply-templates select="prg:databinding/prg:variable" />
						</with-param>
					</call-template>
					<text>" ]</text>
				</with-param>
				<with-param name="then">
					<value-of select="$prg.sh.parser.vName_set_default" />
					<text>=true</text>
					<value-of select="$sh.endl" />
					<if test="../../self::prg:group">
						<call-template name="prg.sh.parser.groupCheck">
							<with-param name="optionNode" select="." />
							<with-param name="comments" select="false()" />
							<with-param name="process" select="false()" />
							<with-param name="onError">
								<value-of select="$prg.sh.parser.vName_set_default" />
								<text>=false</text>
							</with-param>
						</call-template>
					</if>
					<call-template name="sh.if">
						<with-param name="condition">
							<call-template name="sh.var">
								<with-param name="name" select="$prg.sh.parser.vName_set_default" />
							</call-template>
						</with-param>
						<with-param name="then">
							<apply-templates select="prg:databinding/prg:variable" />
							<text>="</text>
							<apply-templates select="prg:default" />
							<text>"</text>
							<value-of select="$sh.endl" />
							<call-template name="prg.sh.parser.groupSetVars">
								<with-param name="optionNode" select="." />
							</call-template>
							<call-template name="prg.sh.parser.optionSetPresence">
								<with-param name="optionNode" select="." />
							</call-template>
						</with-param>
					</call-template>
					<value-of select="$sh.endl" />
				</with-param>
			</call-template>
		</for-each>
	</template>

	<!-- Remove \ protection if any -->
	<template name="prg.sh.parser.unescapeValue">
		<param name="variableName" select="$prg.sh.parser.vName_item" />
		<text>[ </text>
		<call-template name="sh.var">
			<with-param name="name" select="$variableName" />
			<with-param name="quoted" select="true()" />
			<with-param name="length" select="2" />
		</call-template>
		<text> = "\-" ] &amp;&amp; </text>
		<value-of select="$variableName" />
		<text>=</text>
		<call-template name="sh.var">
			<with-param name="name" select="$variableName" />
			<with-param name="quoted" select="true()" />
			<with-param name="start" select="1" />
		</call-template>
	</template>

	<template name="prg.sh.parser.argumentPreprocess">
		<param name="optionNode" select="." />
		<param name="onError" />

		<call-template name="sh.if">
			<with-param name="condition">
				<text>[ ! -z </text>
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_optiontail" />
					<with-param name="quoted" select="true()" />
				</call-template>
				<text> ]</text>
			</with-param>
			<with-param name="then">
				<value-of select="$prg.sh.parser.vName_item" />
				<text>=</text>
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_optiontail" />
					<with-param name="quoted" select="true()" />
				</call-template>
			</with-param>
			<with-param name="else">
				<call-template name="prg.sh.parser.indexIncrement" />
				<value-of select="$sh.endl" />

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
						<value-of select="$prg.sh.parser.fName_adderror" />
						<text> "End of input reached - Argument expected"</text>
						<if test="$onError">
							<value-of select="$sh.endl" />
							<value-of select="$onError" />
						</if>
					</with-param>
				</call-template>
				<value-of select="$sh.endl" />

				<call-template name="prg.sh.parser.itemUpdate" />
				<value-of select="$sh.endl" />

				<call-template name="sh.if">
					<with-param name="condition">
						<text>[ </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_item" />
							<with-param name="quoted" select="true()" />
						</call-template>
						<text> = "--" ]</text>
					</with-param>
					<with-param name="then">
						<value-of select="$prg.sh.parser.fName_adderror" />
						<text> "End of option marker found - Argument expected"</text>
						<value-of select="$sh.endl" />
						<call-template name="sh.var.selfexpr">
							<with-param name="name" select="$prg.sh.parser.vName_index" />
							<with-param name="operator">
								<text>-</text>
							</with-param>
						</call-template>
						<if test="$onError">
							<value-of select="$sh.endl" />
							<value-of select="$onError" />
						</if>
					</with-param>
				</call-template>
			</with-param>
		</call-template>

		<value-of select="$sh.endl" />
		<value-of select="$prg.sh.parser.vName_subindex" />
		<text>=0</text>
		<value-of select="$sh.endl" />
		<value-of select="$prg.sh.parser.vName_optiontail" />
		<text>=""</text>

		<value-of select="$sh.endl" />
		<call-template name="prg.sh.parser.unescapeValue" />
	</template>

	<template name="prg.sh.parser.multiargumentPreprocess">
		<param name="optionNode" select="." />
		<param name="onError" />

		<call-template name="sh.if">
			<with-param name="condition">
				<text>[ ! -z </text>
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_optiontail" />
					<with-param name="quoted" select="true()" />
				</call-template>
				<text> ]</text>
			</with-param>
			<with-param name="then">
				<value-of select="$prg.sh.parser.vName_item" />
				<text>=</text>
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_optiontail" />
					<with-param name="quoted" select="true()" />
				</call-template>
			</with-param>
		</call-template>

		<value-of select="$sh.endl" />
		<value-of select="$prg.sh.parser.vName_subindex" />
		<text>=0</text>
		<value-of select="$sh.endl" />
		<value-of select="$prg.sh.parser.vName_optiontail" />
		<text>=""</text>

		<value-of select="$sh.endl" />
		<call-template name="prg.sh.parser.unescapeValue" />

	</template>

	<template name="prg.sh.parser.optionSetValue">
		<param name="optionNode" select="." />
		<param name="onError" />
		<param name="shortOption" select="false()" />

		<if test="$optionNode/prg:databinding/prg:variable">
			<choose>
				<when test="$optionNode/self::prg:switch">
					<!-- Check tail -->
					<if test="not ($shortOption)">
						<call-template name="sh.if">
							<with-param name="condition">
								<text>[ ! -z </text>
								<call-template name="sh.var">
									<with-param name="name" select="$prg.sh.parser.vName_optiontail" />
									<with-param name="quoted" select="true()" />
								</call-template>
								<text> ]</text>
							</with-param>
							<with-param name="then">
								<value-of select="$prg.sh.parser.fName_adderror" />
								<text> "Unexpected argument (ignored) for option \"</text>
								<call-template name="sh.var">
									<with-param name="name" select="$prg.sh.parser.vName_option" />
								</call-template>
								<text>\""</text>
								<value-of select="$sh.endl" />
								<value-of select="$prg.sh.parser.vName_optiontail" />
								<text>=""</text>
								<if test="$onError">
									<value-of select="$sh.endl" />
									<value-of select="$onError" />
								</if>
							</with-param>
						</call-template>
					</if>
					<choose>
						<when test="$optionNode/@node = 'integer'">
							<call-template name="sh.varincrement">
								<with-param name="name">
									<apply-templates select="$optionNode/prg:databinding/prg:variable" />
								</with-param>
							</call-template>
						</when>
						<otherwise>
							<apply-templates select="$optionNode/prg:databinding/prg:variable" />
							<text>=true</text>
						</otherwise>
					</choose>
				</when>
				<when test="$optionNode/self::prg:argument">
					<apply-templates select="$optionNode/prg:databinding/prg:variable" />
					<text>=</text>
					<call-template name="sh.var">
						<with-param name="name" select="$prg.sh.parser.vName_item" />
						<with-param name="quoted" select="true()" />
					</call-template>
				</when>
			</choose>
		</if>
	</template>

	<!-- Set super group variables -->
	<template name="prg.sh.parser.groupSetVars">
		<param name="optionNode" select="." />
		<variable name="optionsNode" select="$optionNode/.." />
		<if test="$optionsNode/parent::prg:group">
			<variable name="groupOptionNode" select="$optionNode/../.." />

			<!-- Recursive set -->
			<call-template name="prg.sh.parser.groupSetVars">
				<with-param name="optionNode" select="$groupOptionNode" />
			</call-template>

			<!-- Set option variable -->
			<!-- except if group is not exclusive (meaningless in this case) -->
			<if test="$optionNode/prg:databinding/prg:variable and $groupOptionNode/prg:databinding/prg:variable and ($groupOptionNode/@type = 'exclusive')">
				<apply-templates select="$groupOptionNode/prg:databinding/prg:variable" />
				<text>="</text>
				<!-- don't add subcommand prefix in this case -->
				<call-template name="prg.sh.parser.boundVariableName">
					<with-param name="variableNode" select="$optionNode/prg:databinding/prg:variable" />
					<with-param name="usePrefix" select="false()" />
				</call-template>
				<!-- <apply-templates select="$optionNode/prg:databinding/prg:variable" /> -->
				<text>"</text>
				<value-of select="$sh.endl" />
			</if>
		</if>
	</template>

	<template name="prg.sh.parser.valueRestrictionCheck">
		<param name="optionNode" select="." />
		<param name="value">
			<call-template name="sh.var">
				<with-param name="name" select="$prg.sh.parser.vName_item" />
			</call-template>
		</param>
		<param name="onError" />
		<param name="currentItem">
			<text>option \"</text>
			<call-template name="sh.var">
				<with-param name="name" select="$prg.sh.parser.vName_option" />
			</call-template>
			<text>\"</text>
		</param>

		<if test="$optionNode/prg:select/@restrict">
			<call-template name="sh.if">
				<with-param name="condition">
					<text>! (</text>
					<for-each select="$optionNode/prg:select/prg:option">
						<if test="position() != 1">
							<text> || </text>
						</if>
						<text>[ "</text>
						<value-of select="$value" />
						<text>" = "</text>
						<value-of select="." />
						<text>" ]</text>
					</for-each>
					<text>)</text>
				</with-param>
				<with-param name="then">
					<value-of select="$prg.sh.parser.fName_adderror" />
					<text> "Invalid value for </text>
					<value-of select="$currentItem" />
					<text>"</text>
					<!-- Todo: list values -->
					<value-of select="$sh.endl" />
					<if test="$onError">
						<value-of select="$sh.endl" />
						<value-of select="$onError" />
					</if>
				</with-param>
			</call-template>
		</if>
	</template>

	<!-- Chec if the option is part of a group and if it does not break mutual exclusion rule -->
	<template name="prg.sh.parser.groupCheck">
		<!-- Option to check -->
		<param name="optionNode" select="." />
		<!-- Additional things to do when checks fail -->
		<param name="onError" />
		<!-- Disable default processing -->
		<param name="process" select="true()" />
		<!-- Internal use -->
		<param name="comments" select="true()" />
		<!-- Internal use -->
		<param name="originalOptionNode" select="$optionNode" />

		<variable name="optionsNode" select="$optionNode/.." />

		<if test="$optionsNode/parent::prg:group">
			<variable name="groupOptionNode" select="$optionNode/../.." />
			<if test="$comments">
				<call-template name="sh.comment">
					<with-param name="content">
						<text>Group checks</text>
					</with-param>
				</call-template>
				<value-of select="$sh.endl" />
			</if>

			<!-- Recursive check -->
			<call-template name="prg.sh.parser.groupCheck">
				<with-param name="optionNode" select="$groupOptionNode" />
				<with-param name="process" select="$process" />
				<with-param name="onError" select="$onError" />
				<with-param name="originalOptionNode" select="$optionNode" />
				<with-param name="comments" select="false()" />
			</call-template>

			<!-- Exclusive clause -->
			<if test="$groupOptionNode[@type = 'exclusive'] 
						and $groupOptionNode/prg:databinding/prg:variable 
						and $optionNode/prg:databinding/prg:variable">
				<call-template name="sh.if">
					<with-param name="condition">
						<text>! ([ -z </text>
						<call-template name="sh.var">
							<with-param name="name">
								<apply-templates select="$groupOptionNode/prg:databinding/prg:variable" />
							</with-param>
							<with-param name="quoted" select="true()" />
						</call-template>
						<text> ] || [ </text>
						<call-template name="sh.var">
							<with-param name="name">
								<apply-templates select="$groupOptionNode/prg:databinding/prg:variable" />
							</with-param>
							<with-param name="quoted" select="true()" />
						</call-template>
						<text> = "</text>
						<!-- don't add subcommand prefix in this case -->
						<call-template name="prg.sh.parser.boundVariableName">
							<with-param name="variableNode" select="$optionNode/prg:databinding/prg:variable" />
							<with-param name="usePrefix" select="false()" />
						</call-template>
						<!-- <apply-templates select="$optionNode/prg:databinding/prg:variable" /> -->
						<text>" ] || [ </text>
						<call-template name="sh.var">
							<with-param name="name">
								<apply-templates select="$groupOptionNode/prg:databinding/prg:variable" />
							</with-param>
							<with-param name="quoted" select="true()" />
							<with-param name="length" select="1" />
						</call-template>
						<text> = "@" ])</text>
					</with-param>
					<with-param name="then">

						<if test="$process">
							<value-of select="$prg.sh.parser.fName_adderror" />
							<text> "Another option of the group \"</text>
							<!-- don't add subcommand prefix in this case -->
							<call-template name="prg.sh.parser.boundVariableName">
								<with-param name="variableNode" select="$groupOptionNode/prg:databinding/prg:variable" />
								<with-param name="usePrefix" select="false()" />
							</call-template>
							<!-- <apply-templates select="$groupOptionNode/prg:databinding/prg:variable" /> -->
							<text>\" was previously set (</text>
							<call-template name="sh.var">
								<with-param name="name">
									<apply-templates select="$groupOptionNode/prg:databinding/prg:variable" />
								</with-param>
							</call-template>
							<text>)"</text>

							<!-- Skip option arg if required -->
							<choose>
								<when test="$originalOptionNode/self::prg:argument">
									<value-of select="$sh.endl" />
									<call-template name="prg.sh.parser.argumentPreprocess">
										<with-param name="onError" select="$onError" />
										<with-param name="optionNode" select="$originalOptionNode" />
									</call-template>
									<value-of select="$sh.endl" />
								</when>
								<when test="$originalOptionNode/self::prg:multiargument">
									<value-of select="$sh.endl" />
									<!-- Here, the prg.sh.parser.argumentPreprocess suits better than prg.sh.parser.multiargumentPreprocess -->
									<call-template name="prg.sh.parser.argumentPreprocess">
										<with-param name="onError" select="$onError" />
										<with-param name="optionNode" select="$originalOptionNode" />
									</call-template>
									<value-of select="$sh.endl" />
								</when>
							</choose>
						</if>

						<if test="$onError">
							<value-of select="$sh.endl" />
							<value-of select="$onError" />
						</if>
					</with-param>
				</call-template>
				<value-of select="$sh.endl" />
			</if>
		</if>
	</template>

	<template name="prg.sh.parser.existingCommandCheck">
		<param name="value">
			<call-template name="sh.var">
				<with-param name="name" select="$prg.sh.parser.vName_item" />
				<with-param name="quoted" select="true()" />
			</call-template>
		</param>
		<param name="onError" />
		<param name="currentItem" />

		<call-template name="sh.if">
			<with-param name="condition">
				<text>! which "</text>
				<value-of select="$value" />
				<text>" </text>
				<call-template name="sh.chunk.nullRedirection" />
			</with-param>
			<with-param name="then">
				<value-of select="$prg.sh.parser.fName_adderror" />
				<text> "Invalid command \"</text>
				<value-of select="$value" />
				<text>\"</text>

				<text> for </text>
				<value-of select="$currentItem" />
				<text>"</text>

				<if test="$onError">
					<value-of select="$sh.endl" />
					<value-of select="$onError" />
				</if>
			</with-param>
		</call-template>
	</template>

	<template name="prg.sh.parser.pathTypeAccessCheck">
		<param name="value">
			<call-template name="sh.var">
				<with-param name="name" select="$prg.sh.parser.vName_item" />
			</call-template>
		</param>
		<param name="onError" />
		<param name="accessString" />
		<param name="currentItem" />

		<call-template name="sh.if">
			<with-param name="condition">
				<text>! </text>
				<value-of select="$prg.sh.parser.fName_pathaccesscheck" />
				<text> "</text>
				<value-of select="$value" />
				<text>" "</text>
				<value-of select="$accessString" />
				<text>"</text>
			</with-param>
			<with-param name="then">
				<value-of select="$prg.sh.parser.fName_adderror" />
				<text> "Invalid path permissions for \"</text>
				<value-of select="$value" />
				<text>\", </text>
				<value-of select="$accessString" />
				<text> privilege(s) expected for </text>
				<value-of select="$currentItem" />
				<text>"</text>
				<if test="$onError">
					<value-of select="$sh.endl" />
					<value-of select="$onError" />
				</if>
			</with-param>
		</call-template>
		<value-of select="$sh.endl" />
	</template>

	<template name="prg.sh.parser.pathTypeKindsCheck">
		<param name="value">
			<call-template name="sh.var">
				<with-param name="name" select="$prg.sh.parser.vName_item" />
			</call-template>
		</param>
		<param name="kindsNode" />
		<param name="onError" />
		<param name="currentItem" />

		<call-template name="sh.if">
			<with-param name="condition">
				<text>[ -a "</text>
				<value-of select="$value" />
				<text>" ]  &amp;&amp; ! (</text>
				<for-each select="$kindsNode/*">
					<if test="position() != 1">
						<text> || </text>
					</if>
					<text>[ -</text>
					<choose>
						<when test="self::prg:file">
							<text>f</text>
						</when>
						<when test="self::prg:folder">
							<text>d</text>
						</when>
						<when test="self::prg:symlink">
							<text>L</text>
						</when>
						<when test="self::prg:socket">
							<text>S</text>
						</when>
						<otherwise>
							<text>a</text>
						</otherwise>
					</choose>
					<text> "</text>
					<value-of select="$value" />
					<text>" ]</text>
				</for-each>
				<text>)</text>
			</with-param>
			<with-param name="then">
				<value-of select="$prg.sh.parser.fName_adderror" />
				<text> "Invalid patn type for </text>
				<value-of select="$currentItem" />
				<text>"</text>
				<if test="$onError">
					<value-of select="$sh.endl" />
					<value-of select="$onError" />
				</if>
			</with-param>
		</call-template>
		<value-of select="$sh.endl" />
	</template>

	<template name="prg.sh.parser.pathTypePresenceCheck">
		<param name="value">
			<call-template name="sh.var">
				<with-param name="name" select="$prg.sh.parser.vName_item" />
			</call-template>
		</param>
		<param name="onError" />
		<param name="currentItem" />

		<call-template name="sh.if">
			<with-param name="condition">
				<text>[ ! -e "</text>
				<value-of select="$value" />
				<text>" ]</text>
			</with-param>
			<with-param name="then">
				<value-of select="$prg.sh.parser.fName_adderror" />
				<text> "Invalid path \"</text>
				<value-of select="$value" />
				<text>\" for </text>
				<value-of select="$currentItem" />
				<text>"</text>
				<if test="$onError">
					<value-of select="$sh.endl" />
					<value-of select="$onError" />
				</if>
			</with-param>
		</call-template>
		<value-of select="$sh.endl" />
	</template>

	<template name="prg.sh.parser.optionValueTypeCheck">
		<param name="node" select="." />
		<param name="value">
			<call-template name="sh.var">
				<with-param name="name" select="$prg.sh.parser.vName_item" />
			</call-template>
		</param>
		<param name="onError" />
		<param name="currentItem">
			<text>option \"</text>
			<call-template name="sh.var">
				<with-param name="name" select="$prg.sh.parser.vName_option" />
			</call-template>
			<text>\"</text>
		</param>

		<choose>
			<when test="$node/prg:type/prg:path">
				<variable name="pathNode" select="$node/prg:type/prg:path" />

				<if test="$pathNode/@exist">
					<!-- check presence -->
					<call-template name="prg.sh.parser.pathTypePresenceCheck">
						<with-param name="value" select="$value" />
						<with-param name="onError" select="$onError" />
						<with-param name="currentItem" select="$currentItem" />
					</call-template>
				</if>
				<if test="$pathNode/@access">
					<!-- check permissions (imply exist) -->
					<call-template name="prg.sh.parser.pathTypeAccessCheck">
						<with-param name="value" select="$value" />
						<with-param name="accessString" select="$pathNode/@access" />
						<with-param name="onError" select="$onError" />
						<with-param name="currentItem" select="$currentItem" />
					</call-template>
				</if>
				<if test="$pathNode/prg:kinds and (($pathNode/@exist = 'true') or $pathNode/@access)">
					<call-template name="prg.sh.parser.pathTypeKindsCheck">
						<with-param name="value" select="$value" />
						<with-param name="kindsNode" select="$pathNode/prg:kinds" />
						<with-param name="onError" select="$onError" />
						<with-param name="currentItem" select="$currentItem" />
					</call-template>
				</if>
			</when>

			<when test="$node/prg:type/prg:existingcommand">
				<call-template name="prg.sh.parser.existingCommandCheck">
					<with-param name="value" select="$value" />
					<with-param name="onError" select="$onError" />
					<with-param name="currentItem" select="$currentItem" />
				</call-template>
				<value-of select="$sh.endl" />
			</when>
		</choose>
	</template>

	<!-- long option case -->
	<template name="prg.sh.parser.longOptionSwitch">
		<param name="optionsNode" />
		<param name="onError" />
		<param name="onUnknownOption" />
		<param name="interpreter" />

		<call-template name="sh.case">
			<with-param name="case">
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_option" />
				</call-template>
			</with-param>
			<with-param name="in">
				<for-each select="$optionsNode/*/prg:names/prg:long/../..">
					<call-template name="prg.sh.parser.optionCase">
						<with-param name="optionNode" select="." />
						<with-param name="onError" select="$onError" />
						<with-param name="interpreter" select="$interpreter" />
					</call-template>
				</for-each>

				<for-each select="$optionsNode//prg:group/prg:options/*/prg:names/prg:long/../..">
					<call-template name="prg.sh.parser.optionCase">
						<with-param name="optionNode" select="." />
						<with-param name="onError" select="$onError" />
						<with-param name="interpreter" select="$interpreter" />
					</call-template>
				</for-each>

				<call-template name="sh.caseblock">
					<with-param name="case">
						<text>*</text>
					</with-param>
					<with-param name="content">
						<value-of select="$onUnknownOption" />
					</with-param>
				</call-template>
			</with-param>
		</call-template>
	</template>

	<template name="prg.sh.parser.checkMax">
		<param name="node" select="." />
		<param name="isOption" select="true()" />
		<param name="valueVariableName" />
		<param name="max" />
		<param name="onError" />

		<variable name="valueVariable">
			<call-template name="sh.var">
				<with-param name="name" select="$valueVariableName" />
			</call-template>
		</variable>

		<if test="$max and ($max &gt; 0)">
			<call-template name="sh.if">
				<with-param name="condition">
					<text>[ </text>
					<value-of select="$valueVariable" />
					<text> -ge </text>
					<value-of select="$max" />
					<text> ]</text>
				</with-param>
				<with-param name="then">
					<value-of select="$prg.sh.parser.fName_adderror" />
					<text> "Maximum argument count reached for </text>
					<choose>
						<when test="$isOption">
							<text>option \"</text>
							<call-template name="sh.var">
								<with-param name="name" select="$prg.sh.parser.vName_option" />
							</call-template>
							<text>\"</text>
						</when>
						<otherwise>
							<text>value</text>
						</otherwise>
					</choose>
					<text>"</text>
					<if test="$onError">
						<value-of select="$sh.endl" />
						<value-of select="$onError" />
					</if>
				</with-param>
			</call-template>
		</if>
	</template>

	<template name="prg.sh.parser.optionCase">
		<param name="optionNode" select="." />
		<param name="shortOption" select="false()" />
		<param name="onError" />
		<param name="interpreter" />

		<variable name="optionVariableName">
			<apply-templates select="$optionNode/prg:databinding/prg:variable" />
		</variable>

		<call-template name="sh.caseblock">
			<with-param name="case">
				<choose>
					<when test="$shortOption">
						<for-each select="$optionNode/prg:names/prg:short">
							<value-of select="." />
							<if test="position() != last()">
								<text> | </text>
							</if>
						</for-each>
					</when>
					<otherwise>
						<for-each select="$optionNode/prg:names/prg:long">
							<value-of select="." />
							<if test="position() != last()">
								<text> | </text>
							</if>
						</for-each>
					</otherwise>
				</choose>
			</with-param>
			<with-param name="content">

				<!-- Check group -->
				<call-template name="prg.sh.parser.groupCheck">
					<with-param name="optionNode" select="$optionNode" />
					<with-param name="onError" select="$onError" />
				</call-template>

				<choose>
					<when test="$optionNode/self::prg:argument">
						<call-template name="prg.sh.parser.argumentPreprocess">
							<with-param name="onError" select="$onError" />
						</call-template>
						<value-of select="$sh.endl" />
						<call-template name="prg.sh.parser.optionValueTypeCheck">
							<with-param name="node" select="$optionNode" />
							<with-param name="onError" select="$onError" />
						</call-template>
						<call-template name="prg.sh.parser.valueRestrictionCheck">
							<with-param name="optionNode" select="$optionNode" />
							<with-param name="onError" select="$onError" />
						</call-template>
					</when>
					<when test="$optionNode/self::prg:multiargument">
						<call-template name="prg.sh.parser.multiargumentPreprocess">
							<with-param name="onError" select="$onError" />
						</call-template>
						<value-of select="$sh.endl" />

						<call-template name="sh.local">
							<with-param name="name" select="$prg.sh.parser.vName_ma_local_count" />
							<with-param name="interpreter" select="$interpreter" />
							<with-param name="value" select="0" />
						</call-template>
						<value-of select="$sh.endl" />
						<call-template name="sh.local">
							<with-param name="name" select="$prg.sh.parser.vName_ma_total_count" />
							<with-param name="interpreter" select="$interpreter" />
							<with-param name="value">
								<call-template name="sh.arrayLength">
									<with-param name="name" select="$optionVariableName" />
								</call-template>
							</with-param>
							<with-param name="quoted" select="false()" />
						</call-template>
						<value-of select="$sh.endl" />

						<call-template name="prg.sh.parser.checkMax">
							<with-param name="node" select="$optionNode" />
							<with-param name="valueVariableName" select="$prg.sh.parser.vName_ma_total_count" />
							<with-param name="max" select="$optionNode/@max" />
							<with-param name="onError" select="$onError" />
						</call-template>

						<!-- First item -->
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
								<call-template name="prg.sh.parser.optionValueTypeCheck">
									<with-param name="node" select="$optionNode" />
									<with-param name="onError" select="$onError" />
								</call-template>
								<call-template name="prg.sh.parser.valueRestrictionCheck">
									<with-param name="optionNode" select="$optionNode" />
									<with-param name="onError" select="$onError" />
								</call-template>
								<call-template name="sh.arrayAppend">
									<with-param name="name" select="$optionVariableName" />
									<with-param name="startIndex" select="$prg.sh.parser.var_startindex" />
									<with-param name="value">
										<call-template name="sh.var">
											<with-param name="name" select="$prg.sh.parser.vName_item" />
											<with-param name="quoted" select="true()" />
										</call-template>
									</with-param>
								</call-template>
								<value-of select="$sh.endl" />
								<call-template name="sh.varincrement">
									<with-param name="name" select="$prg.sh.parser.vName_ma_total_count" />
								</call-template>
								<value-of select="$sh.endl" />
								<call-template name="sh.varincrement">
									<with-param name="name" select="$prg.sh.parser.vName_ma_local_count" />
								</call-template>
							</with-param>
						</call-template>
						<value-of select="$sh.endl" />

						<!-- Others -->
						<variable name="nextitem">
							<call-template name="prg.prefixedName">
								<with-param name="name">
									<value-of select="$prg.sh.parser.variableNamePrefix" />
									<text>nextitem</text>
								</with-param>
							</call-template>
						</variable>

						<call-template name="sh.local">
							<with-param name="name" select="$nextitem" />
							<with-param name="interpreter" select="$interpreter" />
							<with-param name="value">
								<call-template name="sh.var">
									<with-param name="name" select="$prg.sh.parser.vName_input" />
									<with-param name="quoted" select="false()" />
									<with-param name="index">
										<text>$(expr </text>
										<call-template name="sh.var">
											<with-param name="name" select="$prg.sh.parser.vName_index" />
										</call-template>
										<text> + 1)</text>
									</with-param>
								</call-template>
							</with-param>
						</call-template>
						<value-of select="$sh.endl" />

						<call-template name="sh.while">
							<with-param name="condition">
								<if test="$optionNode/@max and ($optionNode/@max &gt; 0)">
									<text>[ </text>
									<call-template name="sh.var">
										<with-param name="name" select="$prg.sh.parser.vName_ma_total_count" />
									</call-template>
									<text> -lt </text>
									<value-of select="$optionNode/@max" />
									<text> ] &amp;&amp; </text>
								</if>
								<text>[ ! -z </text>
								<call-template name="sh.var">
									<with-param name="name" select="$nextitem" />
									<with-param name="quoted" select="true()" />
								</call-template>
								<text> ] &amp;&amp; [ </text>
								<call-template name="sh.var">
									<with-param name="name" select="$nextitem" />
									<with-param name="quoted" select="true()" />
								</call-template>
								<text> != "--" ] &amp;&amp; [ </text>
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
								<!-- Stop on '-[something]' if not first -->
								<call-template name="sh.if">
									<with-param name="condition">
										<text>[ </text>
										<call-template name="sh.var">
											<with-param name="name" select="$prg.sh.parser.vName_ma_local_count" />
										</call-template>
										<text> -gt 0</text>
										<text> ] &amp;&amp; [ </text>
										<call-template name="sh.var">
											<with-param name="name" select="$nextitem" />
											<with-param name="quoted" select="true()" />
											<with-param name="length" select="1" />
										</call-template>
										<text> = "-" ]</text>
									</with-param>
									<with-param name="then">
										<text>break</text>
									</with-param>
								</call-template>

								<value-of select="$sh.endl" />
								<call-template name="prg.sh.parser.indexIncrement" />
								<value-of select="$sh.endl" />
								<call-template name="prg.sh.parser.itemUpdate" />
								<value-of select="$sh.endl" />

								<!-- Checks -->
								<call-template name="prg.sh.parser.unescapeValue" />
								<value-of select="$sh.endl" />

								<call-template name="prg.sh.parser.optionValueTypeCheck">
									<with-param name="node" select="$optionNode" />
									<with-param name="onError" select="$onError" />
								</call-template>
								<call-template name="prg.sh.parser.valueRestrictionCheck">
									<with-param name="optionNode" select="$optionNode" />
									<with-param name="onError" select="$onError" />
								</call-template>

								<call-template name="sh.arrayAppend">
									<with-param name="name" select="$optionVariableName" />
									<with-param name="startIndex" select="$prg.sh.parser.var_startindex" />
									<with-param name="value">
										<call-template name="sh.var">
											<with-param name="name" select="$prg.sh.parser.vName_item" />
											<with-param name="quoted" select="true()" />
										</call-template>
									</with-param>
								</call-template>
								<value-of select="$sh.endl" />
								<call-template name="sh.varincrement">
									<with-param name="name" select="$prg.sh.parser.vName_ma_total_count" />
								</call-template>
								<value-of select="$sh.endl" />
								<call-template name="sh.varincrement">
									<with-param name="name" select="$prg.sh.parser.vName_ma_local_count" />
								</call-template>
								<value-of select="$sh.endl" />

								<value-of select="$nextitem" />
								<text>=</text>
								<call-template name="sh.var">
									<with-param name="name" select="$prg.sh.parser.vName_input" />
									<with-param name="quoted" select="true()" />
									<with-param name="index">
										<text>$(expr </text>
										<call-template name="sh.var">
											<with-param name="name" select="$prg.sh.parser.vName_index" />
										</call-template>
										<text> + 1)</text>
									</with-param>
								</call-template>
							</with-param>
						</call-template>
						<value-of select="$sh.endl" />
						<call-template name="sh.if">
							<with-param name="condition">
								<text>[ </text>
								<call-template name="sh.var">
									<with-param name="name" select="$prg.sh.parser.vName_ma_local_count" />
								</call-template>
								<text> -eq 0 ]</text>
							</with-param>
							<with-param name="then">
								<value-of select="$prg.sh.parser.fName_adderror" />
								<text> "At least one argument expected for option \"</text>
								<call-template name="sh.var">
									<with-param name="name" select="$prg.sh.parser.vName_option" />
								</call-template>
								<text>\""</text>
								<if test="$onError">
									<value-of select="$sh.endl" />
									<value-of select="$onError" />
								</if>
							</with-param>
						</call-template>
					</when>
				</choose>

				<!-- Finally -->

				<call-template name="prg.sh.parser.optionSetValue">
					<with-param name="optionNode" select="$optionNode" />
					<with-param name="onError" select="$onError" />
					<with-param name="shortOption" select="$shortOption" />
				</call-template>
				<value-of select="$sh.endl" />

				<call-template name="prg.sh.parser.groupSetVars">
					<with-param name="optionNode" select="$optionNode" />
				</call-template>
				<call-template name="prg.sh.parser.optionSetPresence">
					<with-param name="optionNode" select="$optionNode" />
				</call-template>
			</with-param>
		</call-template>
	</template>

	<!-- short option case -->
	<template name="prg.sh.parser.shortOptionSwitch">
		<param name="optionsNode" />
		<param name="onError" />
		<param name="onUnknownOption" />
		<param name="interpreter" />

		<call-template name="sh.case">
			<with-param name="case">
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_option" />
				</call-template>
			</with-param>
			<with-param name="in">
				<for-each select="$optionsNode/*/prg:names/prg:short/../..">
					<call-template name="prg.sh.parser.optionCase">
						<with-param name="optionNode" select="." />
						<with-param name="shortOption" select="true()" />
						<with-param name="onError" select="$onError" />
						<with-param name="interpreter" select="$interpreter" />
					</call-template>
				</for-each>

				<for-each select="$optionsNode//prg:group/prg:options/*/prg:names/prg:short/../..">
					<call-template name="prg.sh.parser.optionCase">
						<with-param name="optionNode" select="." />
						<with-param name="shortOption" select="true()" />
						<with-param name="onError" select="$onError" />
						<with-param name="interpreter" select="$interpreter" />
					</call-template>
				</for-each>

				<call-template name="sh.caseblock">
					<with-param name="case">
						<text>*</text>
					</with-param>
					<with-param name="content">
						<value-of select="$onUnknownOption" />
					</with-param>
				</call-template>
			</with-param>
		</call-template>
	</template>

	<!-- Add required option ids to required options array -->
	<template name="prg.sh.parser.optionAddRequired">
		<param name="optionsNode" />
		<!-- @todo better xquery -->
		<for-each select="$optionsNode//@required">
			<variable name="optionNode" select=".." />
			<if test="../parent::prg:options">
				<value-of select="$sh.endl" />
				<call-template name="sh.arrayAppend">
					<with-param name="name" select="$prg.sh.parser.vName_required" />
					<with-param name="startIndex" select="$prg.sh.parser.var_startindex" />
					<with-param name="value">
						<text>"</text>
						<call-template name="prg.optionId">
							<with-param name="optionNode" select=".." />
						</call-template>
						<text>:</text>
						<choose>
							<!-- @todo -->
							<when test="$optionNode/self::prg:group">
								<for-each select="$optionNode/prg:options/*">
									<call-template name="prg.sh.optionDisplayName">
										<with-param name="recursive" select="true()" />
									</call-template>
									<if test="position() != last()">
										<choose>
											<when test="position() = (last() - 1)">
												<text> or </text>
											</when>
											<otherwise>
												<text>, </text>
											</otherwise>
										</choose>
									</if>
								</for-each>
							</when>
							<otherwise>
								<call-template name="prg.sh.optionDisplayName">
									<with-param name="optionNode" select=".." />
								</call-template>
							</otherwise>
						</choose>
						<if test="$optionNode/self::prg:group and $optionNode[@required = 'true']">
							<variable name="defaultOptionId" select="$optionNode/prg:default/@id" />
							<variable name="defaultOptionNode" select="$optionNode/prg:options/*[@id = $defaultOptionId]" />
							<variable name="groupVariable" select="$optionNode/prg:databinding/prg:variable" />
							<variable name="defaultOptionVariable" select="$defaultOptionNode/prg:databinding/prg:variable" />

							<if test="$groupVariable and $defaultOptionVariable">
								<text>:</text>
								<apply-templates select="$groupVariable" />
								<text>=</text>
								<apply-templates select="$defaultOptionVariable" />
								<if test="$defaultOptionNode/self::prg:switch">
									<text>;</text>
									<apply-templates select="$defaultOptionVariable" />
									<text>=true</text>
								</if>
								<!-- recursively set option presence -->
								<text>;</text>
								<call-template name="prg.sh.parser.optionSetPresence">
									<with-param name="optionNode" select="$defaultOptionNode" />
								</call-template>
							</if>
						</if>
						<text>"</text>
					</with-param>
				</call-template>
			</if>
		</for-each>
	</template>

	<template name="prg.sh.parser.addGlobalError">
		<param name="value" />

		<call-template name="sh.arrayAppend">
			<with-param name="name" select="$prg.sh.parser.vName_errors" />
			<with-param name="startIndex" select="$prg.sh.parser.var_startindex" />
			<with-param name="value" select="$value" />
		</call-template>
	</template>

	<template name="prg.sh.parser.checkValue">
		<param name="valuesNode" />
		<param name="positionVar">
			<call-template name="sh.var">
				<with-param name="name">
					position
				</with-param>
			</call-template>
		</param>
		<param name="onError" />
		<!-- Even if a positional argument is invalid, the value is added to the global array -->
		<!--
			<text>return </text>
			<value-of select="$prg.sh.parser.var_ERROR" />
		-->
		<param name="value">
			<call-template name="sh.var">
				<with-param name="name">
					<text>value</text>
				</with-param>
			</call-template>
		</param>

		<variable name="currentItem">
			<text>positional argument </text>
			<value-of select="$positionVar" />
		</variable>

		<call-template name="sh.case">
			<with-param name="case" select="$positionVar" />
			<with-param name="in">
				<for-each select="$valuesNode/prg:value">
					<call-template name="sh.caseblock">
						<with-param name="case" select="position() - 1" />
						<with-param name="content">
							<call-template name="prg.sh.parser.optionValueTypeCheck">
								<with-param name="node" select="." />
								<with-param name="value" select="$value" />
								<with-param name="onError" select="$onError" />
								<with-param name="currentItem" select="$currentItem" />
							</call-template>
							<call-template name="prg.sh.parser.valueRestrictionCheck">
								<with-param name="optionNode" select="." />
								<with-param name="value" select="$value" />
								<with-param name="onError" select="$onError" />
								<with-param name="currentItem" select="$currentItem" />
							</call-template>
						</with-param>
					</call-template>
				</for-each>
				<call-template name="sh.caseblock">
					<with-param name="case">
						<text>*</text>
					</with-param>
					<with-param name="content">
						<if test="$valuesNode/prg:other">
							<call-template name="prg.sh.parser.optionValueTypeCheck">
								<with-param name="node" select="$valuesNode/prg:other" />
								<with-param name="value" select="$value" />
								<with-param name="onError" select="$onError" />
								<with-param name="currentItem" select="$currentItem" />
							</call-template>
							<call-template name="prg.sh.parser.valueRestrictionCheck">
								<with-param name="optionNode" select="$valuesNode/prg:other" />
								<with-param name="value" select="$value" />
								<with-param name="onError" select="$onError" />
								<with-param name="currentItem" select="$currentItem" />
							</call-template>
						</if>
					</with-param>
				</call-template>
			</with-param>
		</call-template>
	</template>

	<!-- -->
	<template name="prg.sh.parser.longOptionNameElif">
		<param name="optionsNode" />
		<param name="onError" />
		<param name="onUnknownOption" />
		<param name="keyword">
			<text>elif</text>
		</param>
		<param name="interpreter" />

		<value-of select="$keyword" />
		<text> [ </text>
		<call-template name="sh.var">
			<with-param name="name" select="$prg.sh.parser.vName_item" />
			<with-param name="quoted" select="true()" />
			<with-param name="length" select="2" />
		</call-template>
		<text> = "--" ] </text>
		<value-of select="$sh.endl" />
		<text>then</text>
		<call-template name="code.block">
			<with-param name="content">
				<!-- Remove 2 minus signs -->
				<value-of select="$prg.sh.parser.vName_option" />
				<text>=</text>
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_item" />
					<with-param name="quoted" select="true()" />
					<with-param name="start" select="2" />
				</call-template>
				<value-of select="$sh.endl" />

				<!-- check option="value" form -->
				<call-template name="sh.if">
					<with-param name="condition">
						<text>echo </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_option" />
							<with-param name="quoted" select="true()" />
						</call-template>
						<text> | grep "=" </text>
						<call-template name="sh.chunk.nullRedirection" />
					</with-param>
					<with-param name="then">
						<!-- split item between "=" -->
						<value-of select="$prg.sh.parser.vName_optiontail" />
						<text>=</text>
						<text>"$(echo </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_option" />
							<with-param name="quoted" select="true()" />
						</call-template>
						<text> | cut -f 2- -d"=")"</text>
						<value-of select="$sh.endl" />

						<value-of select="$prg.sh.parser.vName_option" />
						<text>=</text>
						<text>"$(echo </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_option" />
							<with-param name="quoted" select="true()" />
						</call-template>
						<text> | cut -f 1 -d"=")"</text>
					</with-param>
				</call-template>
				<value-of select="$sh.endl" />

				<!-- option processing -->
				<call-template name="prg.sh.parser.longOptionSwitch">
					<with-param name="optionsNode" select="$optionsNode" />
					<with-param name="onError" select="$onError" />
					<with-param name="onUnknownOption" select="$onUnknownOption" />
					<with-param name="interpreter" select="$interpreter" />
				</call-template>

			</with-param>
		</call-template>

	</template>

	<template name="prg.sh.parser.shortOptionNameElif">
		<param name="optionsNode" />
		<param name="onError" />
		<param name="onSuccess" />
		<param name="onUnknownOption" />
		<param name="keyword">
			<text>elif</text>
		</param>
		<param name="interpreter" />

		<value-of select="$keyword" />
		<text> [ </text>
		<call-template name="sh.var">
			<with-param name="name" select="$prg.sh.parser.vName_item" />
			<with-param name="quoted" select="true()" />
			<with-param name="length" select="1" />
		</call-template>
		<text> = "-" ] &amp;&amp; [ </text>
		<call-template name="sh.varLength">
			<with-param name="name" select="$prg.sh.parser.vName_item" />
		</call-template>
		<text> -gt 1 ]</text>
		<value-of select="$sh.endl" />
		<text>then</text>
		<call-template name="code.block">
			<with-param name="content">
				<!-- Split item according current subindex -->
				<value-of select="$prg.sh.parser.vName_optiontail" />
				<text>=</text>
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_item" />
					<with-param name="quoted" select="true()" />
					<with-param name="start">
						<text>$(expr </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_subindex" />
						</call-template>
						<text> + 2)</text>
					</with-param>
				</call-template>
				<value-of select="$sh.endl" />

				<value-of select="$prg.sh.parser.vName_option" />
				<text>=</text>
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_item" />
					<with-param name="quoted" select="true()" />
					<with-param name="start">
						<text>$(expr </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_subindex" />
						</call-template>
						<text> + 1)</text>
					</with-param>
					<with-param name="length" select="1" />
				</call-template>
				<value-of select="$sh.endl" />

				<call-template name="sh.if">
					<with-param name="condition">
						<text>[ -z </text>
						<call-template name="sh.var">
							<with-param name="name" select="$prg.sh.parser.vName_option" />
							<with-param name="quoted" select="true()" />
						</call-template>
						<text> ]</text>
					</with-param>
					<with-param name="then">
						<value-of select="$prg.sh.parser.vName_subindex" />
						<text>=0</text>
						<value-of select="$sh.endl" />

						<value-of select="$onSuccess" />
					</with-param>
				</call-template>
				<value-of select="$sh.endl" />

				<!-- option processing -->
				<call-template name="prg.sh.parser.shortOptionSwitch">
					<with-param name="optionsNode" select="$optionsNode" />
					<with-param name="onError" select="$onError" />
					<with-param name="onUnknownOption" select="$onUnknownOption" />
					<with-param name="interpreter" select="$interpreter" />
				</call-template>

			</with-param>
		</call-template>
	</template>

	<!-- Variable Initialization -->
	<template name="prg.sh.parser.initialize">
		<param name="programNode" select="." />

		<value-of select="$prg.sh.parser.vName_shell" />
		<text>="$(readlink /proc/$$/exe | sed "s/.*\/\([a-z]*\)[0-9]*/\1/g")"</text>
		<value-of select="$sh.endl" />
		<value-of select="$prg.sh.parser.vName_input" />
		<text>=("${@}")</text>
		<value-of select="$sh.endl" />
		<value-of select="$prg.sh.parser.vName_itemcount" />
		<text>=</text>
		<call-template name="sh.arrayLength">
			<with-param name="name" select="$prg.sh.parser.vName_input" />
		</call-template>
		<value-of select="$sh.endl" />
		<value-of select="$prg.sh.parser.vName_startindex" />
		<text>=0</text>
		<value-of select="$sh.endl" />
		<value-of select="$prg.sh.parser.vName_index" />
		<text>=0</text>
		<value-of select="$sh.endl" />
		<value-of select="$prg.sh.parser.vName_subindex" />
		<text>=0</text>
		<value-of select="$sh.endl" />
		<value-of select="$prg.sh.parser.vName_item" />
		<text>=""</text>
		<value-of select="$sh.endl" />
		<value-of select="$prg.sh.parser.vName_option" />
		<text>=""</text>
		<value-of select="$sh.endl" />
		<value-of select="$prg.sh.parser.vName_optiontail" />
		<text>=""</text>
		<value-of select="$sh.endl" />
		<value-of select="$prg.sh.parser.vName_subcommand" />
		<text>=""</text>
		<value-of select="$sh.endl" />
		<value-of select="$prg.sh.parser.vName_subcommand_expected" />
		<text>=</text>

		<choose>
			<when test="$programNode/prg:subcommands">
				<text>true</text>
			</when>
			<otherwise>
				<text>false</text>
			</otherwise>
		</choose>

		<value-of select="$sh.endl" />
		<value-of select="$prg.sh.parser.vName_OK" />
		<text>=0</text>
		<value-of select="$sh.endl" />
		<value-of select="$prg.sh.parser.vName_ERROR" />
		<text>=1</text>
		<value-of select="$sh.endl" />
		<value-of select="$prg.sh.parser.vName_SC_OK" />
		<text>=0</text>
		<value-of select="$sh.endl" />
		<value-of select="$prg.sh.parser.vName_SC_ERROR" />
		<text>=1</text>
		<value-of select="$sh.endl" />
		<value-of select="$prg.sh.parser.vName_SC_UNKNOWN" />
		<text>=2</text>
		<value-of select="$sh.endl" />
		<value-of select="$prg.sh.parser.vName_SC_SKIP" />
		<text>=3</text>
		<value-of select="$sh.endl" />

		<call-template name="sh.comment">
			<with-param name="content">
				<text>Compatibility with shell which use "1" as start index</text>
			</with-param>
		</call-template>
		<value-of select="$sh.endl" />
		<text>[ </text>
		<call-template name="sh.var">
			<with-param name="name" select="$prg.sh.parser.vName_shell" />
			<with-param name="quoted" select="true()" />
		</call-template>
		<text> = "zsh" ] &amp;&amp; </text>
		<value-of select="$prg.sh.parser.vName_startindex" />
		<text>=1</text>
		<value-of select="$sh.endl" />

		<value-of select="$prg.sh.parser.vName_itemcount" />
		<text>=$(expr </text>
		<value-of select="$prg.sh.parser.var_startindex" />
		<text> + </text>
		<call-template name="sh.var">
			<with-param name="name" select="$prg.sh.parser.vName_itemcount" />
		</call-template>
		<text>)</text>
		<value-of select="$sh.endl" />

		<value-of select="$prg.sh.parser.vName_index" />
		<text>=</text>
		<value-of select="$prg.sh.parser.var_startindex" />
		<value-of select="$sh.endl" />

		<value-of select="$sh.endl" />
		<call-template name="sh.comment">
			<with-param name="content">
				<text>Required global options</text>
				<value-of select="$sh.endl" />
				<text>(Subcommand required options will be added later)</text>
			</with-param>
		</call-template>
		<value-of select="$sh.endl" />
		<call-template name="prg.sh.parser.optionAddRequired">
			<with-param name="optionsNode" select="$programNode/prg:options" />
		</call-template>
		<value-of select="$sh.endl" />

		<if test="//prg:switch/prg:databinding/prg:variable">
			<call-template name="sh.comment">
				<with-param name="content">
					<text>Switch options</text>
				</with-param>
			</call-template>
			<value-of select="$sh.endl" />
			<for-each select="//prg:switch/prg:databinding/prg:variable">
				<apply-templates select="." />
				<choose>
					<when test="../@node = 'integer'">
						<text>=0</text>
					</when>
					<otherwise>
						<text>=false</text>
					</otherwise>
				</choose>
				<value-of select="$sh.endl" />
			</for-each>
		</if>

		<if test="//prg:argument/prg:databinding/prg:variable">
			<call-template name="sh.comment">
				<with-param name="content">
					<text>Single argument options</text>
				</with-param>
			</call-template>
			<value-of select="$sh.endl" />
			<for-each select="//prg:argument/prg:databinding/prg:variable">
				<apply-templates select="." />
				<text>=</text>
				<!-- default arguments are set later -->
				<!-- <if test="../../prg:default">
					<text>"</text>
					<value-of select="../../prg:default" />
					<text>"</text>
					</if> -->
				<value-of select="$sh.endl" />
			</for-each>
		</if>

		<if test="//prg:group/prg:default">
			<call-template name="sh.comment">
				<with-param name="content">
					<text>Group default options</text>
				</with-param>
			</call-template>
			<for-each select="//prg:group[prg:default]">
				<variable name="defaultOptionId" select="prg:default/@id" />
				<variable name="defaultOptionNode" select="./prg:options/*[@id = $defaultOptionId]" />
				<if test="./prg:databinding/prg:variable and $defaultOptionNode/prg:databinding/prg:variable">
					<apply-templates select="prg:databinding/prg:variable" />
					<text>="@</text>
					<apply-templates select="$defaultOptionNode/prg:databinding/prg:variable" />
					<text>"</text>
					<value-of select="$sh.endl" />
				</if>
			</for-each>
		</if>
		<value-of select="$sh.endl" />
	</template>

</stylesheet>

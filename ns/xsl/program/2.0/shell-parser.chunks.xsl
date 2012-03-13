<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (c) 2011 by Renaud Guillard (dev@niao.fr) -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">

	<import href="base.xsl" />
	<import href="shell-base.xsl" />
	<import href="shell-parser.variables.xsl" />

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
				<text> </text>
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
		<call-template name="endl" />
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
		<text> </text>
		<call-template name="prg.optionId">
			<with-param name="optionNode" select="$optionNode" />
		</call-template>

		<if test="$parentNode/self::prg:group">
			<choose>
				<when test="$inline">
					<text>;</text>
				</when>
				<otherwise>
					<call-template name="endl" />
				</otherwise>
			</choose>
			<call-template name="prg.sh.parser.optionSetPresence">
				<with-param name="optionNode" select="$parentNode" />
				<with-param name="inline" select="$inline" />
			</call-template>
		</if>
	</template>

	<template name="prg.sh.parser.argumentPreprocess">
		<param name="optionNode" select="." />
		<param name="onError" />

		<if test="$optionNode/self::prg:argument">
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
					<call-template name="endl" />
					
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
								<call-template name="endl" />
								<value-of select="$onError" />
							</if>
						</with-param>
					</call-template>
					<call-template name="endl" />
					
					<call-template name="prg.sh.parser.itemUpdate" />
					<call-template name="endl" />
					
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
							<if test="$onError">
								<call-template name="endl" />
								<value-of select="$onError" />
							</if>
						</with-param>
					</call-template>
				</with-param>
			</call-template>

			<call-template name="endl" />
			<value-of select="$prg.sh.parser.vName_subindex" />
			<text>=0</text>
			<call-template name="endl" />
			<value-of select="$prg.sh.parser.vName_optiontail" />
			<text>=""</text>
		</if>
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

		<call-template name="endl" />
		<value-of select="$prg.sh.parser.vName_subindex" />
		<text>=0</text>
		<call-template name="endl" />
		<value-of select="$prg.sh.parser.vName_optiontail" />
		<text>=""</text>
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
								<call-template name="endl" />
								<value-of select="$prg.sh.parser.vName_optiontail" />
								<text>=""</text>
								<if test="$onError">
									<call-template name="endl" />
									<value-of select="$onError" />
								</if>
							</with-param>
						</call-template>
					</if>
					<choose>
						<when test="$optionNode/@node = 'integer'">
							<call-template name="sh.varincrement">
								<with-param name="name" select="$optionNode/prg:databinding/prg:variable" />
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
			<if test="$optionNode/prg:databinding/prg:variable and $groupOptionNode/prg:databinding/prg:variable">
				<apply-templates select="$groupOptionNode/prg:databinding/prg:variable" />
				<text>="</text>
				<apply-templates select="$optionNode/prg:databinding/prg:variable" />
				<text>"</text>
				<call-template name="endl" />
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
					<text> "Invalid value for option \"</text>
					<call-template name="sh.var">
						<with-param name="name" select="$prg.sh.parser.vName_item" />
					</call-template>
					<text>\""</text>
					<!-- Todo: list values -->
					<call-template name="endl" />
					<if test="$onError">
						<call-template name="endl" />
						<value-of select="$onError" />
					</if>
				</with-param>
			</call-template>
		</if>
	</template>

	<!-- Chec if the option is part of a group and if it does not break mutual exclusion rule -->
	<template name="prg.sh.parser.groupCheck">
		<param name="optionNode" select="." />
		<param name="onError" />
		<param name="comments" select="true()" />
		<variable name="optionsNode" select="$optionNode/.." />

		<if test="$optionsNode/parent::prg:group">
			<variable name="groupOptionNode" select="$optionNode/../.." />
			<if test="$comments">
				<call-template name="sh.comment">
					<with-param name="content">
						<text>Group checks</text>
					</with-param>
				</call-template>
				<call-template name="endl" />
			</if>

			<!-- Recursive check -->
			<call-template name="prg.sh.parser.groupCheck">
				<with-param name="optionNode" select="$groupOptionNode" />
				<with-param name="onError" select="$onError" />
				<with-param name="comments" select="false()" />
			</call-template>

			<!-- Exclusive clause -->
			<if test="$groupOptionNode[@type = 'exclusive'] 
						and $groupOptionNode/prg:databinding/prg:variable 
						and $optionNode/prg:databinding/prg:variable">
				<!-- if ! ([ -z "${configureOptionMode}" ] || [ "${configureOptionMode}" = "configureOptionString" ] || [ "${configureOptionMode:0:1}" = "@" ]) -->
				<call-template name="sh.if">
					<with-param name="condition">
						<text>! ([ -z </text>
						<call-template name="sh.var">
							<with-param name="name" select="$groupOptionNode/prg:databinding/prg:variable" />
							<with-param name="quoted" select="true()" />
						</call-template>
						<text> ] || [ </text>
						<call-template name="sh.var">
							<with-param name="name" select="$groupOptionNode/prg:databinding/prg:variable" />
							<with-param name="quoted" select="true()" />
						</call-template>
						<text> = </text>
						<call-template name="sh.var">
							<with-param name="name" select="normalize-space($optionNode/prg:databinding/prg:variable)" />
							<with-param name="quoted" select="true()" />
						</call-template>
						<text> ] || [ </text>
						<call-template name="sh.var">
							<with-param name="name" select="normalize-space($groupOptionNode/prg:databinding/prg:variable)" />
							<with-param name="quoted" select="true()" />
							<with-param name="length" select="1" />
						</call-template>
						<text> = "@" ])</text>
					</with-param>
					<with-param name="then">
						<value-of select="$prg.sh.parser.fName_adderror" />
						<text> "Another option of the group \"</text>
						<apply-templates select="$groupOptionNode/prg:databinding/prg:variable" />
						<text>\" was previously set (</text>
						<call-template name="sh.var">
							<with-param name="name" select="normalize-space($groupOptionNode/prg:databinding/prg:variable)" />
						</call-template>
						<text>)"</text>
						<if test="$onError">
							<call-template name="endl" />
							<value-of select="$onError" />
						</if>
					</with-param>
				</call-template>
				<call-template name="endl" />
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

				<text> for option \"</text>
				<call-template name="sh.var">
					<with-param name="name" select="$prg.sh.parser.vName_option" />
				</call-template>
				<text>\""</text>

				<if test="$onError">
					<call-template name="endl" />
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

		<variable name="option">
			<call-template name="sh.var">
				<with-param name="name" select="$prg.sh.parser.vName_option" />
			</call-template>
		</variable>

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
				<text> privileges expected for option </text>
				<value-of select="$option" />
				<text>"</text>
				<if test="$onError">
					<call-template name="endl" />
					<value-of select="$onError" />
				</if>
			</with-param>
		</call-template>
		<call-template name="endl" />
	</template>

	<template name="prg.sh.parser.pathTypeKindsCheck">
		<param name="value">
			<call-template name="sh.var">
				<with-param name="name" select="$prg.sh.parser.vName_item" />
			</call-template>
		</param>
		<param name="kindsNode" />
		<param name="onError" />

		<variable name="option">
			<call-template name="sh.var">
				<with-param name="name" select="$prg.sh.parser.vName_option" />
			</call-template>
		</variable>

		<call-template name="sh.if">
			<with-param name="condition">
				<text>! (</text>
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
				<text> "Invalid patn type for option </text>
				<value-of select="$option" />
				<text>"</text>
				<if test="$onError">
					<call-template name="endl" />
					<value-of select="$onError" />
				</if>
			</with-param>
		</call-template>
		<call-template name="endl" />
	</template>

	<template name="prg.sh.parser.pathTypePresenceCheck">
		<param name="value">
			<call-template name="sh.var">
				<with-param name="name" select="$prg.sh.parser.vName_item" />
			</call-template>
		</param>
		<param name="onError" />

		<variable name="option">
			<call-template name="sh.var">
				<with-param name="name" select="$prg.sh.parser.vName_option" />
			</call-template>
		</variable>

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
				<text>\" for option </text>
				<value-of select="$option" />
				<text>"</text>
				<if test="$onError">
					<call-template name="endl" />
					<value-of select="$onError" />
				</if>
			</with-param>
		</call-template>
		<call-template name="endl" />
	</template>

	<template name="prg.sh.parser.optionValueTypeCheck">
		<param name="optionNode" select="." />
		<param name="value">
			<call-template name="sh.var">
				<with-param name="name" select="$prg.sh.parser.vName_item" />
			</call-template>
		</param>
		<param name="onError" />

		<choose>
			<when test="$optionNode/prg:type/prg:path">
				<variable name="pathNode" select="$optionNode/prg:type/prg:path" />

				<if test="$pathNode/@exist">
					<!-- check presence -->
					<call-template name="prg.sh.parser.pathTypePresenceCheck">
						<with-param name="value" select="$value" />
						<with-param name="onError" select="$onError" />
					</call-template>
				</if>
				<if test="$pathNode/@access">
					<!-- check permissions (imply exist) -->
					<call-template name="prg.sh.parser.pathTypeAccessCheck">
						<with-param name="value" select="$value" />
						<with-param name="accessString" select="$pathNode/@access" />
						<with-param name="onError" select="$onError" />
					</call-template>
				</if>
				<if test="$pathNode/prg:kinds and ($pathNode/@exist or $pathNode/@access)">
					<call-template name="prg.sh.parser.pathTypeKindsCheck">
						<with-param name="value" select="$value" />
						<with-param name="kindsNode" select="$pathNode/prg:kinds" />
						<with-param name="onError" select="$onError" />
					</call-template>
				</if>
			</when>

			<when test="$optionNode/prg:type/prg:existingcommand">
				<call-template name="prg.sh.parser.existingCommandCheck">
					<with-param name="value" select="$value" />
					<with-param name="onError" select="$onError" />
				</call-template>
				<call-template name="endl" />
			</when>
		</choose>
	</template>

	<!-- long option case -->
	<template name="prg.sh.parser.longOptionSwitch">
		<param name="optionsNode" />
		<param name="onError" />
		<param name="onUnknownOption" />

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
					</call-template>
				</for-each>

				<for-each select="$optionsNode//prg:group/prg:options/*/prg:names/prg:long/../..">
					<call-template name="prg.sh.parser.optionCase">
						<with-param name="optionNode" select="." />
						<with-param name="onError" select="$onError" />
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

		<if test="$max and ($max > 0)">
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
						<call-template name="endl" />
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

		<variable name="optionVariableName" select="normalize-space($optionNode/prg:databinding/prg:variable)" />

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
						<call-template name="endl" />
						<call-template name="prg.sh.parser.optionValueTypeCheck">
							<with-param name="optionNode" select="$optionNode" />
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
						<call-template name="endl" />

						<text>local </text>
						<value-of select="$prg.sh.parser.vName_ma_local_count" />
						<text>=0</text>
						<call-template name="endl" />
						<text>local </text>
						<value-of select="$prg.sh.parser.vName_ma_total_count" />
						<text>=</text>
						<call-template name="sh.arrayLength">
							<with-param name="name" select="$optionVariableName" />
						</call-template>
						<call-template name="endl" />

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
									<with-param name="optionNode" select="$optionNode" />
									<with-param name="onError" select="$onError" />
								</call-template>
								<call-template name="prg.sh.parser.valueRestrictionCheck">
									<with-param name="optionNode" select="$optionNode" />
									<with-param name="onError" select="$onError" />
								</call-template>
								<call-template name="sh.arrayAppend">
									<with-param name="name" select="$optionVariableName" />
									<with-param name="value">
										<call-template name="sh.var">
											<with-param name="name" select="$prg.sh.parser.vName_item" />
											<with-param name="quoted" select="true()" />
										</call-template>
									</with-param>
								</call-template>
								<call-template name="endl" />
								<call-template name="sh.varincrement">
									<with-param name="name" select="$prg.sh.parser.vName_ma_total_count" />
								</call-template>
								<call-template name="endl" />
								<call-template name="sh.varincrement">
									<with-param name="name" select="$prg.sh.parser.vName_ma_local_count" />
								</call-template>
							</with-param>
						</call-template>
						<call-template name="endl" />

						<!-- Others -->
						<variable name="nextitem">
							<call-template name="prg.prefixedName">
								<with-param name="name">
									<value-of select="$prg.sh.parser.variableNamePrefix" />
									<text>nextitem</text>
								</with-param>
							</call-template>
						</variable>

						<text>local </text>
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
						<call-template name="endl" />

						<call-template name="sh.while">
							<with-param name="condition">
								<if test="$optionNode/@max and ($optionNode/@max > 0)">
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
										<text> == "-" ]</text>
									</with-param>
									<with-param name="then">
										<text>return </text>
										<call-template name="sh.var">
											<with-param name="name" select="$prg.sh.parser.vName_OK" />
										</call-template>
									</with-param>
								</call-template>
								<call-template name="endl" />
								<call-template name="prg.sh.parser.indexIncrement" />
								<call-template name="endl" />
								<call-template name="prg.sh.parser.itemUpdate" />
								<call-template name="endl" />

								<!-- Checks -->
								<call-template name="prg.sh.parser.optionValueTypeCheck">
									<with-param name="optionNode" select="$optionNode" />
									<with-param name="onError" select="$onError" />
								</call-template>
								<call-template name="prg.sh.parser.valueRestrictionCheck">
									<with-param name="optionNode" select="$optionNode" />
									<with-param name="onError" select="$onError" />
								</call-template>

								<call-template name="sh.arrayAppend">
									<with-param name="name" select="$optionVariableName" />
									<with-param name="value">
										<call-template name="sh.var">
											<with-param name="name" select="$prg.sh.parser.vName_item" />
											<with-param name="quoted" select="true()" />
										</call-template>
									</with-param>
								</call-template>
								<call-template name="endl" />
								<call-template name="sh.varincrement">
									<with-param name="name" select="$prg.sh.parser.vName_ma_total_count" />
								</call-template>
								<call-template name="endl" />
								<call-template name="sh.varincrement">
									<with-param name="name" select="$prg.sh.parser.vName_ma_local_count" />
								</call-template>
								<call-template name="endl" />

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
						<call-template name="endl" />
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
									<call-template name="endl" />
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
				<call-template name="endl" />

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
					</call-template>
				</for-each>

				<for-each select="$optionsNode//prg:group/prg:options/*/prg:names/prg:short/../..">
					<call-template name="prg.sh.parser.optionCase">
						<with-param name="optionNode" select="." />
						<with-param name="shortOption" select="true()" />
						<with-param name="onError" select="$onError" />
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
				<call-template name="endl" />
				<call-template name="sh.arrayAppend">
					<with-param name="name" select="$prg.sh.parser.vName_required" />
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
							<variable name="groupVariable" select="normalize-space($optionNode/prg:databinding/prg:variable)" />
							<variable name="defaultOptionVariable" select="normalize-space($defaultOptionNode/prg:databinding/prg:variable)" />

							<if test="$groupVariable and $defaultOptionVariable">
								<text>:</text>
								<value-of select="normalize-space($groupVariable)" />
								<text>=</text>
								<value-of select="normalize-space($defaultOptionVariable)" />
								<if test="$defaultOptionNode/self::prg:switch">
									<text>;</text>
									<value-of select="normalize-space($defaultOptionVariable)" />
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

	<!-- -->
	<template name="prg.sh.parser.longOptionNameElif">
		<param name="optionsNode" />
		<param name="onError" />
		<param name="onUnknownOption" />
		<param name="keyword">
			<text>elif</text>
		</param>

		<value-of select="$keyword" />
		<text> [ </text>
		<call-template name="sh.var">
			<with-param name="name" select="$prg.sh.parser.vName_item" />
			<with-param name="quoted" select="true()" />
			<with-param name="length" select="2" />
		</call-template>
		<text> = "--" ] </text>
		<call-template name="endl" />
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
				<call-template name="endl" />

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
						<call-template name="endl" />

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
				<call-template name="endl" />

				<!-- option processing -->
				<call-template name="prg.sh.parser.longOptionSwitch">
					<with-param name="optionsNode" select="$optionsNode" />
					<with-param name="onError" select="$onError" />
					<with-param name="onUnknownOption" select="$onUnknownOption" />
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
		<call-template name="endl" />
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
				<call-template name="endl" />

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
				<call-template name="endl" />

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
						<call-template name="endl" />

						<value-of select="$onSuccess" />
					</with-param>
				</call-template>
				<call-template name="endl" />

				<!-- option processing -->
				<call-template name="prg.sh.parser.shortOptionSwitch">
					<with-param name="optionsNode" select="$optionsNode" />
					<with-param name="onError" select="$onError" />
					<with-param name="onUnknownOption" select="$onUnknownOption" />
				</call-template>

			</with-param>
		</call-template>
	</template>

	<!-- Variable Initialization -->
	<template name="prg.sh.parser.initialize">
		<param name="programNode" select="." />

		<value-of select="$prg.sh.parser.vName_shell" />
		<text>="$(readlink /proc/$$/exe | sed "s/.*\/\([a-z]*\)[0-9]*/\1/g")"</text>
		<call-template name="endl" />
		<value-of select="$prg.sh.parser.vName_input" />
		<text>=("${@}")</text>
		<call-template name="endl" />
		<value-of select="$prg.sh.parser.vName_itemcount" />
		<text>=</text>
		<call-template name="sh.arrayLength">
			<with-param name="name" select="$prg.sh.parser.vName_input" />
		</call-template>
		<call-template name="endl" />
		<value-of select="$prg.sh.parser.vName_startindex" />
		<text>=0</text>
		<call-template name="endl" />
		<value-of select="$prg.sh.parser.vName_index" />
		<text>=0</text>
		<call-template name="endl" />
		<value-of select="$prg.sh.parser.vName_subindex" />
		<text>=0</text>
		<call-template name="endl" />
		<value-of select="$prg.sh.parser.vName_item" />
		<text>=""</text>
		<call-template name="endl" />
		<value-of select="$prg.sh.parser.vName_option" />
		<text>=""</text>
		<call-template name="endl" />
		<value-of select="$prg.sh.parser.vName_optiontail" />
		<text>=""</text>
		<call-template name="endl" />
		<value-of select="$prg.sh.parser.vName_subcommand" />
		<text>=""</text>
		<call-template name="endl" />
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

		<call-template name="endl" />
		<value-of select="$prg.sh.parser.vName_OK" />
		<text>=0</text>
		<call-template name="endl" />
		<value-of select="$prg.sh.parser.vName_ERROR" />
		<text>=1</text>
		<call-template name="endl" />
		<value-of select="$prg.sh.parser.vName_SC_OK" />
		<text>=0</text>
		<call-template name="endl" />
		<value-of select="$prg.sh.parser.vName_SC_ERROR" />
		<text>=1</text>
		<call-template name="endl" />
		<value-of select="$prg.sh.parser.vName_SC_UNKNOWN" />
		<text>=2</text>
		<call-template name="endl" />
		<value-of select="$prg.sh.parser.vName_SC_SKIP" />
		<text>=3</text>
		<call-template name="endl" />

		<call-template name="sh.comment">
			<with-param name="content">
				<text>Compatibility with shell which use "1" as start index</text>
			</with-param>
		</call-template>
		<text>[ </text>
		<call-template name="sh.var">
			<with-param name="name" select="$prg.sh.parser.vName_shell" />
			<with-param name="quoted" select="true()" />
		</call-template>
		<text> = "zsh" ] &amp;&amp; </text>
		<value-of select="$prg.sh.parser.vName_startindex" />
		<text>=1</text>
		<call-template name="endl" />

		<value-of select="$prg.sh.parser.vName_itemcount" />
		<text>=$(expr </text>
		<call-template name="sh.var">
			<with-param name="name" select="$prg.sh.parser.vName_startindex" />
		</call-template>
		<text> + </text>
		<call-template name="sh.var">
			<with-param name="name" select="$prg.sh.parser.vName_itemcount" />
		</call-template>
		<text>)</text>
		<call-template name="endl" />

		<value-of select="$prg.sh.parser.vName_index" />
		<text>=</text>
		<call-template name="sh.var">
			<with-param name="name" select="$prg.sh.parser.vName_startindex" />
		</call-template>
		<call-template name="endl" />

		<call-template name="endl" />
		<call-template name="sh.comment">
			<with-param name="content">
				<text>Required global options</text>
				<call-template name="endl" />
				<text>(Subcommand required options will be added later)</text>
			</with-param>
		</call-template>
		<call-template name="endl" />
		<call-template name="prg.sh.parser.optionAddRequired">
			<with-param name="optionsNode" select="$programNode/prg:options" />
		</call-template>
		<call-template name="endl" />

		<if test="//prg:switch/prg:databinding/prg:variable">
			<call-template name="sh.comment">
				<with-param name="content">
					<text>Switch options</text>
				</with-param>
			</call-template>
			<call-template name="endl" />
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
				<call-template name="endl" />
			</for-each>
		</if>

		<if test="//prg:argument/prg:databinding/prg:variable">
			<call-template name="sh.comment">
				<with-param name="content">
					<text>Single argument options</text>
				</with-param>
			</call-template>
			<call-template name="endl" />
			<for-each select="//prg:argument/prg:databinding/prg:variable">
				<apply-templates select="." />
				<text>=</text>
				<if test="../../prg:default">
					<text>"</text>
					<value-of select="../../prg:default" />
					<text>"</text>
				</if>
				<call-template name="endl" />
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
					<call-template name="endl" />
				</if>
			</for-each>
		</if>

		<call-template name="endl" />

	</template>

</stylesheet>

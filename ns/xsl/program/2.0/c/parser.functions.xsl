<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2012 by Renaud Guillard (dev@niao.fr) -->
<!-- Distributed under the terms of the BSD License, see LICENSE -->
<!-- Create C parser parser functions -->
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" version="1.0">
	<import href="parser.base.xsl"/>
	<import href="parser.results.xsl"/>
	<import href="parser.names.xsl"/>
	<param name="prg.c.parser.resultVariableName" select="'result'"/>
	<template name="prg.c.parser.parseFunctionSignature">
		<call-template name="c.functionSignature">
			<with-param name="returnType">
				<value-of select="$prg.c.parser.structName.program_result"/>
				<text> *</text>
			</with-param>
			<with-param name="name">
				<value-of select="$prg.c.parser.functionName.program_parse"/>
			</with-param>
			<with-param name="parameters">
				<value-of select="$prg.c.parser.structName.program_info"/>
				<text> *info, int argc, const char **argv, int start_index</text>
			</with-param>
		</call-template>
	</template>

	<template name="prg.c.parser.usageFunctionSignature">
		<call-template name="c.functionSignature">
			<with-param name="returnType">
				<text>void</text>
			</with-param>
			<with-param name="name">
				<value-of select="$prg.c.parser.functionName.program_usage"/>
			</with-param>
			<with-param name="parameters">
				<text>FILE *stream, </text>
				<value-of select="$prg.c.parser.structName.program_info"/>
				<text> *info, </text>
				<value-of select="$prg.c.parser.structName.program_result"/>
				<text> *result, int format, const </text>
				<value-of select="$prg.c.parser.structName.nsxml_util_text_wrap_options"/>
				<text> *wrap</text>
			</with-param>
		</call-template>
	</template>

	<template name="prg.c.parser.parseFunctionDeclaration">
		<call-template name="c.functionDeclaration">
			<with-param name="signature">
				<call-template name="prg.c.parser.parseFunctionSignature"/>
			</with-param>
		</call-template>
	</template>

	<template name="prg.c.parser.usageFunctionDeclaration">
		<call-template name="c.functionDeclaration">
			<with-param name="signature">
				<call-template name="prg.c.parser.usageFunctionSignature"/>
			</with-param>
		</call-template>
	</template>

	<template name="prg.c.parser.stateBindings">
		<param name="programNode"/>
		<param name="rootNode"/>
		<param name="stateVariableName"/>
		<param name="resultVariableName"/>
		<param name="bindingIndex" select="1"/>
		<for-each select="$rootNode/prg:options//prg:names/*">
			<variable name="optionNode" select="../.."/>
			<variable name="index" select="position() - 1"/>
			<variable name="level">
				<call-template name="prg.optionLevel">
					<with-param name="optionNode" select="$optionNode"/>
				</call-template>
			</variable>
			<variable name="nameIndex">
				<call-template name="prg.c.parser.itemIndex"/>
			</variable>
			<variable name="optionIndex">
				<call-template name="prg.c.parser.optionIndex">
					<with-param name="optionNode" select="$optionNode"/>
					<with-param name="rootNode" select="$rootNode"/>
				</call-template>
			</variable>
			<variable name="infoRef">
				<text>info-&gt;</text>
				<choose>
					<when test="$bindingIndex = 0">
						<text>rootitem_info.option_infos</text>
					</when>
					<otherwise>
						<text>subcommand_infos[</text>
						<value-of select="$bindingIndex - 1"/>
						<text>].rootitem_info.option_infos</text>
					</otherwise>
				</choose>
				<text>[</text>
				<value-of select="$optionIndex"/>
				<text>]</text>
			</variable>
			<call-template name="c.inlineComment">
				<with-param name="content">
					<call-template name="prg.cliOptionName"/>
				</with-param>
			</call-template>
			<call-template name="endl"/>
			<value-of select="$stateVariableName"/>
			<text>-&gt;option_name_bindings[</text>
			<value-of select="$bindingIndex"/>
			<text>][</text>
			<value-of select="$index"/>
			<text>].name_ref = </text>
			<text>nsxml_item_name_get(</text>
			<value-of select="$infoRef"/>
			<text>-&gt;names, </text>
			<value-of select="$nameIndex"/>
			<text>);</text>
			<call-template name="endl"/>
			<value-of select="$stateVariableName"/>
			<text>-&gt;option_name_bindings[</text>
			<value-of select="$bindingIndex"/>
			<text>][</text>
			<value-of select="$index"/>
			<text>].info_ref = </text>
			<value-of select="$infoRef"/>
			<text>;</text>
			<call-template name="endl"/>
			<text>dummy_ptr = </text>
			<choose>
				<when test="$optionNode/prg:databinding/prg:variable">
					<text>(&amp;</text>
					<value-of select="$prg.c.parser.resultVariableName"/>
					<text>-&gt;</text>
					<choose>
						<when test="$bindingIndex = 0">
							<text>options.</text>
						</when>
						<otherwise>
							<text>subcommands.</text>
							<apply-templates select="$rootNode/prg:name"/>
							<text>.</text>
						</otherwise>
					</choose>
					<apply-templates select="../../prg:databinding/prg:variable"/>
					<text>);</text>
				</when>
				<otherwise>
					<value-of select="$stateVariableName"/>
					<text>-&gt;anonymous_option_results[</text>
					<call-template name="prg.c.parser.anonymousOptionIndex">
						<with-param name="programNode" select="$programNode"/>
						<with-param name="optionNode" select="$optionNode"/>
					</call-template>
					<text>];</text>
				</otherwise>
			</choose>
			<call-template name="endl"/>
			<value-of select="$stateVariableName"/>
			<text>-&gt;option_name_bindings[</text>
			<value-of select="$bindingIndex"/>
			<text>][</text>
			<value-of select="$index"/>
			<text>].result_ref = (struct nsxml_option_result *)dummy_ptr;</text>
			<call-template name="endl"/>
			<!-- Level -->
			<value-of select="$stateVariableName"/>
			<text>-&gt;option_name_bindings[</text>
			<value-of select="$bindingIndex"/>
			<text>][</text>
			<value-of select="$index"/>
			<text>].level = </text>
			<value-of select="$level"/>
			<text>;</text>
			<call-template name="endl"/>
			<value-of select="$stateVariableName"/>
			<text>-&gt;option_name_bindings[</text>
			<value-of select="$bindingIndex"/>
			<text>][</text>
			<value-of select="$index"/>
			<text>].parent_tree_refs = </text>
			<choose>
				<when test="$level = 0">
					<text>NULL;</text>
				</when>
				<otherwise>
					<text>(struct nsxml_group_option_result **)malloc(sizeof(struct nsxml_group_option_result *) * </text>
					<value-of select="$level"/>
					<text>);</text>
					<call-template name="prg.c.parser.stateOptionBindingParentTreeAssign">
						<with-param name="programNode" select="$programNode"/>
						<with-param name="stateVariableName" select="$stateVariableName"/>
						<with-param name="parentOptionNode" select="$optionNode/../.."/>
						<with-param name="level" select="$level - 1"/>
						<with-param name="bindingIndex" select="$bindingIndex"/>
						<with-param name="variableBase">
							<call-template name="endl"/>
							<value-of select="$stateVariableName"/>
							<text>-&gt;option_name_bindings[</text>
							<value-of select="$bindingIndex"/>
							<text>][</text>
							<value-of select="$index"/>
							<text>].parent_tree_refs</text>
						</with-param>
					</call-template>
				</otherwise>
			</choose>
			<call-template name="endl"/>
		</for-each>
	</template>

	<!--  -->
	<template name="prg.c.parser.stateOptionBindingParentTreeAssign">
		<param name="programNode"/>
		<param name="stateVariableName"/>
		<param name="parentOptionNode"/>
		<param name="level"/>
		<param name="variableBase"/>
		<param name="bindingIndex"/>
		<call-template name="endl"/>
		<text>dummy_ptr = </text>
		<choose>
			<when test="$parentOptionNode/prg:databinding/prg:variable">
				<text>&amp;</text>
				<value-of select="$prg.c.parser.resultVariableName"/>
				<text>-&gt;</text>
				<choose>
					<when test="$bindingIndex = 0">
						<text>options.</text>
					</when>
					<otherwise>
						<text>subcommands.</text>
						<apply-templates select="$rootNode/prg:name"/>
						<text>.</text>
					</otherwise>
				</choose>
				<apply-templates select="$parentOptionNode/prg:databinding/prg:variable"/>
				<text>;</text>
			</when>
			<otherwise>
				<value-of select="$stateVariableName"/>
				<text>-&gt;anonymous_option_results[</text>
				<call-template name="prg.c.parser.anonymousOptionIndex">
					<with-param name="programNode" select="$programNode"/>
					<with-param name="optionNode" select="$parentOptionNode"/>
				</call-template>
				<text>];</text>
			</otherwise>
		</choose>
		<value-of select="$variableBase"/>
		<text>[</text>
		<value-of select="$level"/>
		<text>] = (struct nsxml_group_option_result *)dummy_ptr;</text>
		<if test="$level &gt; 0">
			<call-template name="prg.c.parser.stateOptionBindingParentTreeAssign">
				<with-param name="programNode" select="$programNode"/>
				<with-param name="stateVariableName" select="$stateVariableName"/>
				<with-param name="parentOptionNode" select="$parentOptionNode/../.."/>
				<with-param name="level" select="$level - 1"/>
				<with-param name="variableBase" select="$variableBase"/>
				<with-param name="bindingIndex" select="$bindingIndex"/>
			</call-template>
		</if>
	</template>

	<template name="prg.c.parser.stateSubcommandBinding">
		<param name="bindingBase"/>
		<param name="infoBase"/>
		<param name="subcommandIndex"/>
		<param name="position" select="0"/>
		<value-of select="$bindingBase"/>
		<text>name_ref = nsxml_item_name_get(</text>
		<value-of select="$infoBase"/>
		<text>.names, </text>
		<value-of select="$position"/>
		<text>);</text>
		<call-template name="endl"/>
		<value-of select="$bindingBase"/>
		<text>info_ref = &amp;</text>
		<value-of select="$infoBase"/>
		<text>;</text>
		<call-template name="endl"/>
		<value-of select="$bindingBase"/>
		<text>subcommand_index = </text>
		<value-of select="$subcommandIndex"/>
		<text>;</text>
		<call-template name="endl"/>
		<text>++binding_index;</text>
		<call-template name="endl"/>
	</template>

	<template name="prg.c.parser.option_resultFunctionCall">
		<param name="programNode" select="."/>
		<param name="functionName"/>
		<param name="perOptionType" select="false()"/>
		<param name="cast" select="true()"/>
		<variable name="typeCast">
			<if test="not($perOptionType) and $cast">
				<text>(struct nsxml_option_result *)</text>
			</if>
		</variable>
		<for-each select="$programNode/prg:options//*[prg:databinding/prg:variable]">
			<variable name="functionName">
				<choose>
					<when test="$perOptionType">
						<call-template name="prg.c.parser.itemTypeBasedName">
							<with-param name="itemNode" select="."/>
							<with-param name="name" select="$functionName"/>
						</call-template>
					</when>
					<otherwise>
						<value-of select="$functionName"/>
					</otherwise>
				</choose>
			</variable>
			<variable name="memberName">
				<apply-templates select="prg:databinding/prg:variable"/>
			</variable>
			<value-of select="$functionName"/>
			<text>(</text>
			<value-of select="$typeCast"/>
			<text>&amp;</text>
			<value-of select="$prg.c.parser.resultVariableName"/>
			<text>-&gt;options.</text>
			<value-of select="$memberName"/>
			<text>);</text>
			<call-template name="endl"/>
		</for-each>
		<for-each select="$programNode/prg:subcommands/prg:subcommand">
			<variable name="subcommandName">
				<apply-templates select="prg:name"/>
			</variable>
			<for-each select="prg:options//*[prg:databinding/prg:variable]">
				<variable name="functionName">
					<choose>
						<when test="$perOptionType">
							<call-template name="prg.c.parser.itemTypeBasedName">
								<with-param name="itemNode" select="."/>
								<with-param name="name" select="$functionName"/>
							</call-template>
						</when>
						<otherwise>
							<value-of select="$functionName"/>
						</otherwise>
					</choose>
				</variable>
				<variable name="memberName">
					<apply-templates select="prg:databinding/prg:variable"/>
				</variable>
				<value-of select="$functionName"/>
				<text>(</text>
				<value-of select="$typeCast"/>
				<text>&amp;</text>
				<value-of select="$prg.c.parser.resultVariableName"/>
				<text>-&gt;subcommands.</text>
				<value-of select="$subcommandName"/>
				<text>.</text>
				<value-of select="$memberName"/>
				<text>);</text>
				<call-template name="endl"/>
			</for-each>
		</for-each>
	</template>

	<template name="prg.c.parser.parseFunctionDefinition">
		<param name="programNode" select="."/>
		<call-template name="c.functionDefinition">
			<with-param name="signature">
				<call-template name="prg.c.parser.parseFunctionSignature">
					<with-param name="programNode" select="$programNode"/>
				</call-template>
			</with-param>
			<with-param name="content">
				<variable name="stateVariableName" select="'state'"/>
				<variable name="stateStructName" select="'nsxml_parser_state'"/>
				<variable name="stateStruct">
					<call-template name="c.identifierDefinition">
						<with-param name="name" select="$stateStructName"/>
						<with-param name="type" select="'struct'"/>
					</call-template>
				</variable>
				<variable name="resultVariableName" select="'result'"/>
				<variable name="resultStructName">
					<value-of select="$prg.c.parser.structName.program_result"/>
				</variable>
				<variable name="anonymousValueCount">
					<call-template name="prg.c.parser.anonymousOptionCount">
						<with-param name="programNode" select="$programNode"/>
					</call-template>
				</variable>
				<!-- Declarations -->
				<text>void *dummy_ptr = NULL;</text>
				<call-template name="endl"/>
				<call-template name="c.structVariableDeclaration">
					<with-param name="name" select="$stateStructName"/>
					<with-param name="pointer" select="true()"/>
					<with-param name="variableName" select="$stateVariableName"/>
					<with-param name="value">
						<text>nsxml_parser_state_new((const struct nsxml_program_info*)info, argc, argv, start_index)</text>
					</with-param>
				</call-template>
				<call-template name="endl"/>
				<call-template name="c.variableDeclaration">
					<with-param name="name" select="$prg.c.parser.resultVariableName"/>
					<with-param name="type" select="$resultStructName"/>
					<with-param name="pointer" select="true()"/>
					<with-param name="value">
						<text>(</text>
						<value-of select="$resultStructName"/>
						<text> *)</text>
						<text>malloc(sizeof(</text>
						<value-of select="$resultStructName"/>
						<text>))</text>
					</with-param>
				</call-template>
				<call-template name="endl"/>
				<variable name="programOptionBindingCount" select="count($programNode/prg:options//prg:names/*)"/>
				<variable name="programBindingCount" select="count($programNode/prg:subcommands/prg:subcommand) + 1"/>
				<text>size_t option_name_binding_counts[] = {</text>
				<value-of select="$programOptionBindingCount"/>
				<for-each select="$programNode/prg:subcommands/prg:subcommand">
					<text>, </text>
					<value-of select="count(./prg:options//prg:names/*)"/>
				</for-each>
				<text>};</text>
				<call-template name="endl"/>
				<text>void *result_ptr = </text>
				<value-of select="$resultVariableName"/>
				<text>;</text>
				<call-template name="endl"/>
				<call-template name="c.inlineComment">
					<with-param name="content" select="'Parser state'"/>
				</call-template>
				<call-template name="endl"/>
				<value-of select="$stateVariableName"/>
				<text>-&gt;anonymous_option_result_count = </text>
				<value-of select="$anonymousValueCount"/>
				<text>;</text>
				<call-template name="endl"/>
				<if test="$anonymousValueCount &gt; 0">
					<call-template name="c.inlineComment">
						<with-param name="content" select="'Anonymous options'"/>
					</call-template>
					<call-template name="c.block">
						<with-param name="content">
							<text>void *anonymous_result_ptr = NULL;</text>
							<call-template name="endl"/>
							<value-of select="$stateVariableName"/>
							<text>-&gt;anonymous_option_results = (struct nsxml_option_result **)malloc(sizeof(struct nsxml_option_result*) * </text>
							<value-of select="$anonymousValueCount"/>
							<text>);</text>
							<call-template name="endl"/>
							<for-each select="$programNode//prg:options/*[not(prg:databinding/prg:variable)]">
								<call-template name="c.inlineComment">
									<with-param name="content">
										<value-of select="name(.)"/>
										<text> </text>
										<apply-templates select="prg:documentation/prg:abstract"/>
										<text> </text>
										<apply-templates select="prg:names[prg:long|prg:short][1]"/>
									</with-param>
								</call-template>
								<call-template name="endl"/>
								<variable name="itemType">
									<call-template name="prg.c.parser.itemTypeName">
										<with-param name="itemNode" select="."/>
									</call-template>
									<text/>
								</variable>
								<variable name="var">
									<value-of select="$stateVariableName"/>
									<text>-&gt;anonymous_option_results[</text>
									<value-of select="position() - 1"/>
									<text>]</text>
								</variable>
								<text>anonymous_result_ptr = malloc(sizeof(struct nsxml_</text>
								<value-of select="$itemType"/>
								<text>_option_result));</text>
								<call-template name="endl"/>
								<value-of select="$var"/>
								<text> = (struct nsxml_option_result *)anonymous_result_ptr;</text>
								<call-template name="endl"/>
								<text>nsxml_</text>
								<value-of select="$itemType"/>
								<text>_option_result_init((struct nsxml_</text>
								<value-of select="$itemType"/>
								<text>_option_result *)anonymous_result_ptr);</text>
								<call-template name="endl"/>
							</for-each>
						</with-param>
					</call-template>
					<call-template name="endl"/>
				</if>
				<call-template name="c.inlineComment">
					<with-param name="content" select="'Parser result'"/>
				</call-template>
				<call-template name="endl"/>
				<text>nsxml_program_result_init(</text>
				<value-of select="$prg.c.parser.resultVariableName"/>
				<text>);</text>
				<call-template name="endl"/>
				<call-template name="prg.c.parser.option_resultFunctionCall">
					<with-param name="programNode" select="$programNode"/>
					<with-param name="perOptionType" select="true()"/>
					<with-param name="functionName" select="'nsxml_(itemType)_option_result_init'"/>
				</call-template>
				<call-template name="endl"/>
				<call-template name="c.inlineComment">
					<with-param name="content" select="'Link option names, info and result variable'"/>
				</call-template>
				<call-template name="endl"/>
				<text>nsxml_parser_state_allocate_name_bindings(</text>
				<value-of select="$stateVariableName"/>
				<text>, </text>
				<value-of select="$programBindingCount"/>
				<text>, option_name_binding_counts);</text>
				<call-template name="endl"/>
				<!-- Global option names -->
				<call-template name="prg.c.parser.stateBindings">
					<with-param name="programNode" select="$programNode"/>
					<with-param name="rootNode" select="$programNode"/>
					<with-param name="stateVariableName" select="$stateVariableName"/>
					<with-param name="resultVariableName" select="$prg.c.parser.resultVariableName"/>
					<with-param name="bindingIndex" select="0"/>
				</call-template>
				<call-template name="endl"/>
				<!-- Subcommand option names -->
				<for-each select="$programNode/prg:subcommands/prg:subcommand[prg:options]">
					<!-- options -->
					<call-template name="prg.c.parser.stateBindings">
						<with-param name="programNode" select="$programNode"/>
						<with-param name="rootNode" select="."/>
						<with-param name="stateVariableName" select="$stateVariableName"/>
						<with-param name="resultVariableName" select="$prg.c.parser.resultVariableName"/>
						<with-param name="bindingIndex" select="position()"/>
					</call-template>
					<call-template name="endl"/>
				</for-each>
				<!-- Initialize subcommand name bindings -->
				<variable name="subcommandNameCount" select="count($programNode/prg:subcommands/*/prg:name) + count($programNode/prg:subcommands/*/prg:aliases/prg:alias)"/>
				<text>state-&gt;subcommand_name_binding_count = </text>
				<value-of select="$subcommandNameCount"/>
				<text>;</text>
				<call-template name="endl"/>
				<text>state-&gt;subcommand_name_bindings = (struct nsxml_subcommand_name_binding *)malloc(sizeof(struct nsxml_subcommand_name_binding) * state-&gt;subcommand_name_binding_count);</text>
				<if test="$programNode/prg:subcommands/prg:subcommand">
					<call-template name="c.block">
						<with-param name="content">
							<text>int binding_index = 0;</text>
							<call-template name="endl"/>
							<for-each select="$programNode/prg:subcommands/prg:subcommand">
								<call-template name="c.inlineComment">
									<with-param name="content" select="./prg:name"/>
								</call-template>
								<call-template name="endl"/>
								<variable name="subcommandIndex" select="position()"/>
								<variable name="bindingBase" select="'state-&gt;subcommand_name_bindings[binding_index].'"/>
								<variable name="infoBase">
									<text>info-&gt;subcommand_infos[</text>
									<value-of select="position() - 1"/>
									<text>]</text>
								</variable>
								<!-- Firrt name -->
								<call-template name="prg.c.parser.stateSubcommandBinding">
									<with-param name="bindingBase" select="$bindingBase"/>
									<with-param name="infoBase" select="$infoBase"/>
									<with-param name="subcommandIndex" select="$subcommandIndex"/>
								</call-template>
								<!-- aliases -->
								<for-each select="prg:aliases/prg:alias">
									<call-template name="prg.c.parser.stateSubcommandBinding">
										<with-param name="bindingBase" select="$bindingBase"/>
										<with-param name="infoBase" select="$infoBase"/>
										<with-param name="subcommandIndex" select="$subcommandIndex"/>
										<with-param name="position" select="position()"/>
									</call-template>
								</for-each>
							</for-each>
						</with-param>
					</call-template>
					<call-template name="endl"/>
				</if>
				<!-- Call the generic parser -->
				<text>nsxml_parse_core(</text>
				<value-of select="$stateVariableName"/>
				<text>, (struct nsxml_program_result*)</text>
				<value-of select="$prg.c.parser.resultVariableName"/>
				<text>_ptr</text>
				<text>);</text>
				<call-template name="endl"/>
				<text>nsxml_parser_state_free(</text>
				<value-of select="$stateVariableName"/>
				<text>);</text>
				<call-template name="endl"/>
				<text>return </text>
				<value-of select="$prg.c.parser.resultVariableName"/>
				<text>;</text>
				<!-- end of parser function -->
			</with-param>
		</call-template>
	</template>

	<template name="prg.c.parser.usageFunctionDefinition">
		<param name="programNode" select="."/>
		<call-template name="c.functionDefinition">
			<with-param name="signature">
				<call-template name="prg.c.parser.usageFunctionSignature">
					<with-param name="programNode" select="$programNode"/>
				</call-template>
			</with-param>
			<with-param name="content">
				<text>void *</text>
				<value-of select="$prg.c.parser.resultVariableName"/>
				<text>_ptr = result;</text>
				<call-template name="endl"/>
				<text>const void *info_ptr = info;</text>
				<call-template name="endl"/>
				<text>nsxml_usage(stream, (const struct nsxml_program_info *)info_ptr, (struct nsxml_program_result *)result_ptr, format, wrap);</text>
			</with-param>
		</call-template>
	</template>

</stylesheet>

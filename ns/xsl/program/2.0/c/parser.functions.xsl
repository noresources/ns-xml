<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Create C parser parser functions -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	<xsl:import href="parser.base.xsl" />
	<xsl:import href="parser.results.xsl" />
	<xsl:import href="parser.names.xsl" />
	<xsl:param name="prg.c.parser.resultVariableName" select="'result'" />
	<xsl:template name="prg.c.parser.parseFunctionSignature">
		<xsl:call-template name="c.functionSignature">
			<xsl:with-param name="returnType">
				<xsl:value-of select="$prg.c.parser.structName.program_result" />
				<xsl:text> *</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.c.parser.functionName.program_parse" />
			</xsl:with-param>
			<xsl:with-param name="parameters">
				<xsl:value-of select="$prg.c.parser.structName.program_info" />
				<xsl:text> *info, int argc, const char **argv, int start_index</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.c.parser.usageFunctionSignature">
		<xsl:call-template name="c.functionSignature">
			<xsl:with-param name="returnType">
				<xsl:text>void</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.c.parser.functionName.program_usage" />
			</xsl:with-param>
			<xsl:with-param name="parameters">
				<xsl:text>FILE *stream, </xsl:text>
				<xsl:value-of select="$prg.c.parser.structName.program_info" />
				<xsl:text> *info, </xsl:text>
				<xsl:value-of select="$prg.c.parser.structName.program_result" />
				<xsl:text> *result, int format, const </xsl:text>
				<xsl:value-of select="$prg.c.parser.structName.nsxml_util_text_wrap_options" />
				<xsl:text> *wrap</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.c.parser.parseFunctionDeclaration">
		<xsl:call-template name="c.functionDeclaration">
			<xsl:with-param name="signature">
				<xsl:call-template name="prg.c.parser.parseFunctionSignature" />
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.c.parser.usageFunctionDeclaration">
		<xsl:call-template name="c.functionDeclaration">
			<xsl:with-param name="signature">
				<xsl:call-template name="prg.c.parser.usageFunctionSignature" />
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.c.parser.stateBindings">
		<xsl:param name="programNode" />
		<xsl:param name="rootNode" />
		<xsl:param name="stateVariableName" />
		<xsl:param name="resultVariableName" />
		<xsl:param name="bindingIndex" select="1" />
		<xsl:for-each select="$rootNode/prg:options//prg:names/*">
			<xsl:variable name="optionNode" select="../.." />
			<xsl:variable name="index" select="position() - 1" />
			<xsl:variable name="level">
				<xsl:call-template name="prg.optionLevel">
					<xsl:with-param name="optionNode" select="$optionNode" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="nameIndex">
				<xsl:call-template name="prg.c.parser.itemIndex" />
			</xsl:variable>
			<xsl:variable name="optionIndex">
				<xsl:call-template name="prg.c.parser.optionIndex">
					<xsl:with-param name="optionNode" select="$optionNode" />
					<xsl:with-param name="rootNode" select="$rootNode" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="infoRef">
				<xsl:text>info-&gt;</xsl:text>
				<xsl:choose>
					<xsl:when test="$bindingIndex = 0">
						<xsl:text>rootitem_info.option_infos</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>subcommand_infos[</xsl:text>
						<xsl:value-of select="$bindingIndex - 1" />
						<xsl:text>].rootitem_info.option_infos</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>[</xsl:text>
				<xsl:value-of select="$optionIndex" />
				<xsl:text>]</xsl:text>
			</xsl:variable>
			<xsl:call-template name="c.inlineComment">
				<xsl:with-param name="content">
					<xsl:call-template name="prg.cliOptionName" />
				</xsl:with-param>
			</xsl:call-template>
			<xsl:value-of select="$str.endl" />
			<xsl:value-of select="$stateVariableName" />
			<xsl:text>-&gt;option_name_bindings[</xsl:text>
			<xsl:value-of select="$bindingIndex" />
			<xsl:text>][</xsl:text>
			<xsl:value-of select="$index" />
			<xsl:text>].name_ref = </xsl:text>
			<xsl:text>nsxml_item_name_get(</xsl:text>
			<xsl:value-of select="$infoRef" />
			<xsl:text>-&gt;names, </xsl:text>
			<xsl:value-of select="$nameIndex" />
			<xsl:text>);</xsl:text>
			<xsl:value-of select="$str.endl" />
			<xsl:value-of select="$stateVariableName" />
			<xsl:text>-&gt;option_name_bindings[</xsl:text>
			<xsl:value-of select="$bindingIndex" />
			<xsl:text>][</xsl:text>
			<xsl:value-of select="$index" />
			<xsl:text>].info_ref = </xsl:text>
			<xsl:value-of select="$infoRef" />
			<xsl:text>;</xsl:text>
			<xsl:value-of select="$str.endl" />
			<xsl:text>dummy_ptr = </xsl:text>
			<xsl:choose>
				<xsl:when test="$optionNode/prg:databinding/prg:variable">
					<xsl:text>(&amp;</xsl:text>
					<xsl:value-of select="$prg.c.parser.resultVariableName" />
					<xsl:text>-&gt;</xsl:text>
					<xsl:choose>
						<xsl:when test="$bindingIndex = 0">
							<xsl:text>options.</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>subcommands.</xsl:text>
							<xsl:apply-templates select="$rootNode/prg:name" />
							<xsl:text>.</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:apply-templates select="../../prg:databinding/prg:variable" />
					<xsl:text>);</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$stateVariableName" />
					<xsl:text>-&gt;anonymous_option_results[</xsl:text>
					<xsl:call-template name="prg.c.parser.anonymousOptionIndex">
						<xsl:with-param name="programNode" select="$programNode" />
						<xsl:with-param name="optionNode" select="$optionNode" />
					</xsl:call-template>
					<xsl:text>];</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="$str.endl" />
			<xsl:value-of select="$stateVariableName" />
			<xsl:text>-&gt;option_name_bindings[</xsl:text>
			<xsl:value-of select="$bindingIndex" />
			<xsl:text>][</xsl:text>
			<xsl:value-of select="$index" />
			<xsl:text>].result_ref = (struct nsxml_option_result *)dummy_ptr;</xsl:text>
			<xsl:value-of select="$str.endl" />
			<!-- Level -->
			<xsl:value-of select="$stateVariableName" />
			<xsl:text>-&gt;option_name_bindings[</xsl:text>
			<xsl:value-of select="$bindingIndex" />
			<xsl:text>][</xsl:text>
			<xsl:value-of select="$index" />
			<xsl:text>].level = </xsl:text>
			<xsl:value-of select="$level" />
			<xsl:text>;</xsl:text>
			<xsl:value-of select="$str.endl" />
			<xsl:value-of select="$stateVariableName" />
			<xsl:text>-&gt;option_name_bindings[</xsl:text>
			<xsl:value-of select="$bindingIndex" />
			<xsl:text>][</xsl:text>
			<xsl:value-of select="$index" />
			<xsl:text>].parent_tree_refs = </xsl:text>
			<xsl:choose>
				<xsl:when test="$level = 0">
					<xsl:text>NULL;</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>(struct nsxml_group_option_result **)malloc(sizeof(struct nsxml_group_option_result *) * </xsl:text>
					<xsl:value-of select="$level" />
					<xsl:text>);</xsl:text>
					<xsl:call-template name="prg.c.parser.stateOptionBindingParentTreeAssign">
						<xsl:with-param name="programNode" select="$programNode" />
						<xsl:with-param name="stateVariableName" select="$stateVariableName" />
						<xsl:with-param name="parentOptionNode" select="$optionNode/../.." />
						<xsl:with-param name="levelCount" select="$level" />
						<xsl:with-param name="bindingIndex" select="$bindingIndex" />
						<xsl:with-param name="variableBase">
							<xsl:value-of select="$str.endl" />
							<xsl:value-of select="$stateVariableName" />
							<xsl:text>-&gt;option_name_bindings[</xsl:text>
							<xsl:value-of select="$bindingIndex" />
							<xsl:text>][</xsl:text>
							<xsl:value-of select="$index" />
							<xsl:text>].parent_tree_refs</xsl:text>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="$str.endl" />
		</xsl:for-each>
	</xsl:template>

	<!--  -->
	<xsl:template name="prg.c.parser.stateOptionBindingParentTreeAssign">
		<xsl:param name="programNode" />
		<xsl:param name="stateVariableName" />
		<xsl:param name="parentOptionNode" />
		<xsl:param name="level" select="0" />
		<xsl:param name="levelCount" />
		<xsl:param name="variableBase" />
		<xsl:param name="bindingIndex" />
		<xsl:value-of select="$str.endl" />
		<xsl:text>dummy_ptr = </xsl:text>
		<xsl:choose>
			<xsl:when test="$parentOptionNode/prg:databinding/prg:variable">
				<xsl:text>&amp;</xsl:text>
				<xsl:value-of select="$prg.c.parser.resultVariableName" />
				<xsl:text>-&gt;</xsl:text>
				<xsl:choose>
					<xsl:when test="$bindingIndex = 0">
						<xsl:text>options.</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>subcommands.</xsl:text>
						<xsl:apply-templates select="$rootNode/prg:name" />
						<xsl:text>.</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:apply-templates select="$parentOptionNode/prg:databinding/prg:variable" />
				<xsl:text>;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$stateVariableName" />
				<xsl:text>-&gt;anonymous_option_results[</xsl:text>
				<xsl:call-template name="prg.c.parser.anonymousOptionIndex">
					<xsl:with-param name="programNode" select="$programNode" />
					<xsl:with-param name="optionNode" select="$parentOptionNode" />
				</xsl:call-template>
				<xsl:text>];</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="$variableBase" />
		<xsl:text>[</xsl:text>
		<xsl:value-of select="$level" />
		<xsl:text>] = (struct nsxml_group_option_result *)dummy_ptr;</xsl:text>
		<xsl:if test="($level + 1) &lt; $levelCount">
			<xsl:call-template name="prg.c.parser.stateOptionBindingParentTreeAssign">
				<xsl:with-param name="programNode" select="$programNode" />
				<xsl:with-param name="stateVariableName" select="$stateVariableName" />
				<xsl:with-param name="parentOptionNode" select="$parentOptionNode/../.." />
				<xsl:with-param name="level" select="$level + 1" />
				<xsl:with-param name="levelCount" select="$levelCount" />
				<xsl:with-param name="variableBase" select="$variableBase" />
				<xsl:with-param name="bindingIndex" select="$bindingIndex" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="prg.c.parser.stateSubcommandBinding">
		<xsl:param name="bindingBase" />
		<xsl:param name="infoBase" />
		<xsl:param name="subcommandIndex" />
		<xsl:param name="position" select="0" />
		<xsl:value-of select="$bindingBase" />
		<xsl:text>name_ref = nsxml_item_name_get(</xsl:text>
		<xsl:value-of select="$infoBase" />
		<xsl:text>.names, </xsl:text>
		<xsl:value-of select="$position" />
		<xsl:text>);</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:value-of select="$bindingBase" />
		<xsl:text>info_ref = &amp;</xsl:text>
		<xsl:value-of select="$infoBase" />
		<xsl:text>;</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:value-of select="$bindingBase" />
		<xsl:text>subcommand_index = </xsl:text>
		<xsl:value-of select="$subcommandIndex" />
		<xsl:text>;</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:text>++binding_index;</xsl:text>
		<xsl:value-of select="$str.endl" />
	</xsl:template>

	<xsl:template name="prg.c.parser.option_resultFunctionCall">
		<xsl:param name="programNode" select="." />
		<xsl:param name="functionName" />
		<xsl:param name="perOptionType" select="false()" />
		<xsl:param name="cast" select="true()" />
		<xsl:variable name="typeCast">
			<xsl:if test="not($perOptionType) and $cast">
				<xsl:text>(struct nsxml_option_result *)</xsl:text>
			</xsl:if>
		</xsl:variable>
		<xsl:for-each select="$programNode/prg:options//*[prg:databinding/prg:variable]">
			<xsl:variable name="functionName">
				<xsl:choose>
					<xsl:when test="$perOptionType">
						<xsl:call-template name="prg.c.parser.itemTypeBasedName">
							<xsl:with-param name="itemNode" select="." />
							<xsl:with-param name="name" select="$functionName" />
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$functionName" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="memberName">
				<xsl:apply-templates select="prg:databinding/prg:variable" />
			</xsl:variable>
			<xsl:value-of select="$functionName" />
			<xsl:text>(</xsl:text>
			<xsl:value-of select="$typeCast" />
			<xsl:text>&amp;</xsl:text>
			<xsl:value-of select="$prg.c.parser.resultVariableName" />
			<xsl:text>-&gt;options.</xsl:text>
			<xsl:value-of select="$memberName" />
			<xsl:text>);</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:for-each>
		<xsl:for-each select="$programNode/prg:subcommands/prg:subcommand">
			<xsl:variable name="subcommandName">
				<xsl:apply-templates select="prg:name" />
			</xsl:variable>
			<xsl:for-each select="prg:options//*[prg:databinding/prg:variable]">
				<xsl:variable name="functionName">
					<xsl:choose>
						<xsl:when test="$perOptionType">
							<xsl:call-template name="prg.c.parser.itemTypeBasedName">
								<xsl:with-param name="itemNode" select="." />
								<xsl:with-param name="name" select="$functionName" />
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$functionName" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="memberName">
					<xsl:apply-templates select="prg:databinding/prg:variable" />
				</xsl:variable>
				<xsl:value-of select="$functionName" />
				<xsl:text>(</xsl:text>
				<xsl:value-of select="$typeCast" />
				<xsl:text>&amp;</xsl:text>
				<xsl:value-of select="$prg.c.parser.resultVariableName" />
				<xsl:text>-&gt;subcommands.</xsl:text>
				<xsl:value-of select="$subcommandName" />
				<xsl:text>.</xsl:text>
				<xsl:value-of select="$memberName" />
				<xsl:text>);</xsl:text>
				<xsl:value-of select="$str.endl" />
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="prg.c.parser.parseFunctionDefinition">
		<xsl:param name="programNode" select="." />
		<xsl:call-template name="c.functionDefinition">
			<xsl:with-param name="signature">
				<xsl:call-template name="prg.c.parser.parseFunctionSignature">
					<xsl:with-param name="programNode" select="$programNode" />
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="content">
				<xsl:variable name="stateVariableName" select="'state'" />
				<xsl:variable name="stateStructName" select="'nsxml_parser_state'" />
				<xsl:variable name="stateStruct">
					<xsl:call-template name="c.identifierDefinition">
						<xsl:with-param name="name" select="$stateStructName" />
						<xsl:with-param name="type" select="'struct'" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="resultVariableName" select="'result'" />
				<xsl:variable name="resultStructName">
					<xsl:value-of select="$prg.c.parser.structName.program_result" />
				</xsl:variable>
				<xsl:variable name="anonymousValueCount">
					<xsl:call-template name="prg.c.parser.anonymousOptionCount">
						<xsl:with-param name="programNode" select="$programNode" />
					</xsl:call-template>
				</xsl:variable>
				<!-- Declarations -->
				<xsl:if test="$programNode/prg:options">
					<xsl:text>void *dummy_ptr = NULL;</xsl:text>
					<xsl:value-of select="$str.endl" />
				</xsl:if>
				<xsl:call-template name="c.structVariableDeclaration">
					<xsl:with-param name="name" select="$stateStructName" />
					<xsl:with-param name="pointer" select="true()" />
					<xsl:with-param name="variableName" select="$stateVariableName" />
					<xsl:with-param name="value">
						<xsl:text>nsxml_parser_state_new((const struct nsxml_program_info*)info, argc, argv, start_index)</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$str.endl" />
				<xsl:call-template name="c.variableDeclaration">
					<xsl:with-param name="name" select="$prg.c.parser.resultVariableName" />
					<xsl:with-param name="type" select="$resultStructName" />
					<xsl:with-param name="pointer" select="true()" />
					<xsl:with-param name="value">
						<xsl:text>(</xsl:text>
						<xsl:value-of select="$resultStructName" />
						<xsl:text> *)</xsl:text>
						<xsl:text>malloc(sizeof(</xsl:text>
						<xsl:value-of select="$resultStructName" />
						<xsl:text>))</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$str.endl" />
				<xsl:variable name="programOptionBindingCount" select="count($programNode/prg:options//prg:names/*)" />
				<xsl:variable name="programBindingCount" select="count($programNode/prg:subcommands/prg:subcommand) + 1" />
				<xsl:text>size_t option_name_binding_counts[] = {</xsl:text>
				<xsl:value-of select="$programOptionBindingCount" />
				<xsl:for-each select="$programNode/prg:subcommands/prg:subcommand">
					<xsl:text>, </xsl:text>
					<xsl:value-of select="count(./prg:options//prg:names/*)" />
				</xsl:for-each>
				<xsl:text>};</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:text>void *result_ptr = </xsl:text>
				<xsl:value-of select="$resultVariableName" />
				<xsl:text>;</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:call-template name="c.inlineComment">
					<xsl:with-param name="content" select="'Parser state'" />
				</xsl:call-template>
				<xsl:value-of select="$str.endl" />
				<xsl:value-of select="$stateVariableName" />
				<xsl:text>-&gt;anonymous_option_result_count = </xsl:text>
				<xsl:value-of select="$anonymousValueCount" />
				<xsl:text>;</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:if test="$anonymousValueCount &gt; 0">
					<xsl:call-template name="c.inlineComment">
						<xsl:with-param name="content" select="'Anonymous options'" />
					</xsl:call-template>
					<xsl:call-template name="c.block">
						<xsl:with-param name="content">
							<xsl:text>void *anonymous_result_ptr = NULL;</xsl:text>
							<xsl:value-of select="$str.endl" />
							<xsl:value-of select="$stateVariableName" />
							<xsl:text>-&gt;anonymous_option_results = (struct nsxml_option_result **)malloc(sizeof(struct nsxml_option_result*) * </xsl:text>
							<xsl:value-of select="$anonymousValueCount" />
							<xsl:text>);</xsl:text>
							<xsl:value-of select="$str.endl" />
							<xsl:for-each select="$programNode//prg:options/*[not(prg:databinding/prg:variable)]">
								<xsl:call-template name="c.inlineComment">
									<xsl:with-param name="content">
										<xsl:value-of select="name(.)" />
										<xsl:text> </xsl:text>
										<xsl:apply-templates select="prg:documentation/prg:abstract" />
										<xsl:text> </xsl:text>
										<xsl:apply-templates select="prg:names[prg:long|prg:short][1]" />
									</xsl:with-param>
								</xsl:call-template>
								<xsl:value-of select="$str.endl" />
								<xsl:variable name="itemType">
									<xsl:call-template name="prg.c.parser.itemTypeName">
										<xsl:with-param name="itemNode" select="." />
									</xsl:call-template>
									<xsl:text />
								</xsl:variable>
								<xsl:variable name="var">
									<xsl:value-of select="$stateVariableName" />
									<xsl:text>-&gt;anonymous_option_results[</xsl:text>
									<xsl:value-of select="position() - 1" />
									<xsl:text>]</xsl:text>
								</xsl:variable>
								<xsl:text>anonymous_result_ptr = malloc(sizeof(struct nsxml_</xsl:text>
								<xsl:value-of select="$itemType" />
								<xsl:text>_option_result));</xsl:text>
								<xsl:value-of select="$str.endl" />
								<xsl:value-of select="$var" />
								<xsl:text> = (struct nsxml_option_result *)anonymous_result_ptr;</xsl:text>
								<xsl:value-of select="$str.endl" />
								<xsl:text>nsxml_</xsl:text>
								<xsl:value-of select="$itemType" />
								<xsl:text>_option_result_init((struct nsxml_</xsl:text>
								<xsl:value-of select="$itemType" />
								<xsl:text>_option_result *)anonymous_result_ptr);</xsl:text>
								<xsl:value-of select="$str.endl" />
							</xsl:for-each>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:value-of select="$str.endl" />
				</xsl:if>
				<xsl:call-template name="c.inlineComment">
					<xsl:with-param name="content" select="'Parser result'" />
				</xsl:call-template>
				<xsl:value-of select="$str.endl" />
				<xsl:text>nsxml_program_result_init(</xsl:text>
				<xsl:value-of select="$prg.c.parser.resultVariableName" />
				<xsl:text>);</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:call-template name="prg.c.parser.option_resultFunctionCall">
					<xsl:with-param name="programNode" select="$programNode" />
					<xsl:with-param name="perOptionType" select="true()" />
					<xsl:with-param name="functionName" select="'nsxml_(itemType)_option_result_init'" />
				</xsl:call-template>
				<xsl:value-of select="$str.endl" />
				<xsl:call-template name="c.inlineComment">
					<xsl:with-param name="content" select="'Link option names, info and result variable'" />
				</xsl:call-template>
				<xsl:value-of select="$str.endl" />
				<xsl:text>nsxml_parser_state_allocate_name_bindings(</xsl:text>
				<xsl:value-of select="$stateVariableName" />
				<xsl:text>, </xsl:text>
				<xsl:value-of select="$programBindingCount" />
				<xsl:text>, option_name_binding_counts);</xsl:text>
				<xsl:value-of select="$str.endl" />
				<!-- Global option names -->
				<xsl:call-template name="prg.c.parser.stateBindings">
					<xsl:with-param name="programNode" select="$programNode" />
					<xsl:with-param name="rootNode" select="$programNode" />
					<xsl:with-param name="stateVariableName" select="$stateVariableName" />
					<xsl:with-param name="resultVariableName" select="$prg.c.parser.resultVariableName" />
					<xsl:with-param name="bindingIndex" select="0" />
				</xsl:call-template>
				<xsl:value-of select="$str.endl" />
				<!-- Subcommand option names -->
				<xsl:for-each select="$programNode/prg:subcommands/prg:subcommand[prg:options]">
					<!-- options -->
					<xsl:call-template name="prg.c.parser.stateBindings">
						<xsl:with-param name="programNode" select="$programNode" />
						<xsl:with-param name="rootNode" select="." />
						<xsl:with-param name="stateVariableName" select="$stateVariableName" />
						<xsl:with-param name="resultVariableName" select="$prg.c.parser.resultVariableName" />
						<xsl:with-param name="bindingIndex" select="position()" />
					</xsl:call-template>
					<xsl:value-of select="$str.endl" />
				</xsl:for-each>
				<!-- Initialize subcommand name bindings -->
				<xsl:variable name="subcommandNameCount" select="count($programNode/prg:subcommands/*/prg:name) + count($programNode/prg:subcommands/*/prg:aliases/prg:alias)" />
				<xsl:text>state-&gt;subcommand_name_binding_count = </xsl:text>
				<xsl:value-of select="$subcommandNameCount" />
				<xsl:text>;</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:text>state-&gt;subcommand_name_bindings = (struct nsxml_subcommand_name_binding *)malloc(sizeof(struct nsxml_subcommand_name_binding) * state-&gt;subcommand_name_binding_count);</xsl:text>
				<xsl:if test="$programNode/prg:subcommands/prg:subcommand">
					<xsl:call-template name="c.block">
						<xsl:with-param name="content">
							<xsl:text>int binding_index = 0;</xsl:text>
							<xsl:value-of select="$str.endl" />
							<xsl:for-each select="$programNode/prg:subcommands/prg:subcommand">
								<xsl:call-template name="c.inlineComment">
									<xsl:with-param name="content" select="./prg:name" />
								</xsl:call-template>
								<xsl:value-of select="$str.endl" />
								<xsl:variable name="subcommandIndex" select="position()" />
								<xsl:variable name="bindingBase" select="'state-&gt;subcommand_name_bindings[binding_index].'" />
								<xsl:variable name="infoBase">
									<xsl:text>info-&gt;subcommand_infos[</xsl:text>
									<xsl:value-of select="position() - 1" />
									<xsl:text>]</xsl:text>
								</xsl:variable>
								<!-- Firrt name -->
								<xsl:call-template name="prg.c.parser.stateSubcommandBinding">
									<xsl:with-param name="bindingBase" select="$bindingBase" />
									<xsl:with-param name="infoBase" select="$infoBase" />
									<xsl:with-param name="subcommandIndex" select="$subcommandIndex" />
								</xsl:call-template>
								<!-- aliases -->
								<xsl:for-each select="prg:aliases/prg:alias">
									<xsl:call-template name="prg.c.parser.stateSubcommandBinding">
										<xsl:with-param name="bindingBase" select="$bindingBase" />
										<xsl:with-param name="infoBase" select="$infoBase" />
										<xsl:with-param name="subcommandIndex" select="$subcommandIndex" />
										<xsl:with-param name="position" select="position()" />
									</xsl:call-template>
								</xsl:for-each>
							</xsl:for-each>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:value-of select="$str.endl" />
				</xsl:if>
				<!-- Call the generic parser -->
				<xsl:text>nsxml_parse_core(</xsl:text>
				<xsl:value-of select="$stateVariableName" />
				<xsl:text>, (struct nsxml_program_result*)</xsl:text>
				<xsl:value-of select="$prg.c.parser.resultVariableName" />
				<xsl:text>_ptr</xsl:text>
				<xsl:text>);</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:text>nsxml_parser_state_free(</xsl:text>
				<xsl:value-of select="$stateVariableName" />
				<xsl:text>);</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:text>return </xsl:text>
				<xsl:value-of select="$prg.c.parser.resultVariableName" />
				<xsl:text>;</xsl:text>
				<!-- end of parser function -->
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.c.parser.usageFunctionDefinition">
		<xsl:param name="programNode" select="." />
		<xsl:call-template name="c.functionDefinition">
			<xsl:with-param name="signature">
				<xsl:call-template name="prg.c.parser.usageFunctionSignature">
					<xsl:with-param name="programNode" select="$programNode" />
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="content">
				<xsl:text>void *</xsl:text>
				<xsl:value-of select="$prg.c.parser.resultVariableName" />
				<xsl:text>_ptr = result;</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:text>const void *info_ptr = info;</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:text>nsxml_usage(stream, (const struct nsxml_program_info *)info_ptr, (struct nsxml_program_result *)result_ptr, format, wrap);</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>

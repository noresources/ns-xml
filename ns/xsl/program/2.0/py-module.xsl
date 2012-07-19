<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->

<!-- Create the Python module to manage the program options -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">

	<import href="../../languages/base.xsl" />
	<import href="base.xsl" />
	<import href="usage.chunks.xsl" />

	<output method="text" encoding="utf-8" />

	<template name="prg.py.module.tempVarName">
		<param name="node" select="." />
		<call-template name="str.replaceAll">
			<with-param name="text">
				<call-template name="prg.optionId">
					<with-param name="optionNode" select="$node" />
				</call-template>
			</with-param>
			<with-param name="replace">
				<text>-</text>
			</with-param>
			<with-param name="by">
				<text>_</text>
			</with-param>
		</call-template>
	</template>

	<template name="prg.py.module.nodeValueStringList">
		<param name="rootNode" />
		<text>[</text>
		<for-each select="$rootNode/*">
			<text>"</text>
			<value-of select="normalize-space(.)" />
			<text>"</text>
			<if test="position() != last()">
				<text>, </text>
			</if>
		</for-each>
		<text>]</text>
	</template>

	<template name="prg.py.module.nodeNameStringList">
		<param name="rootNode" />
		<text>[</text>
		<for-each select="$rootNode/*">
			<text>"</text>
			<value-of select="local-name(.)" />
			<text>"</text>
			<if test="position() != last()">
				<text>, </text>
			</if>
		</for-each>
		<text>]</text>
	</template>

	<template name="prg.py.module.usageStrings">
		<param name="pyVarName" />
		<param name="optionsNode" />
		<param name="indent" />

		<value-of select="$indent" />
		<value-of select="$pyVarName" />
		<text>.usage["inline"] = """</text>
		<call-template name="prg.usage.optionListInline">
			<with-param name="optionsNode" select="$optionsNode" />
			<with-param name="separator">
				<text> </text>
			</with-param>
		</call-template>
		<text>"""</text>
		<call-template name="endl" />

		<value-of select="$indent" />
		<value-of select="$pyVarName" />
		<text>.usage["abstract"] = """</text>
		<call-template name="prg.usage.optionListDescription">
			<with-param name="optionsNode" select="$optionsNode" />
			<with-param name="details" select="false()" />
		</call-template>
		<text>"""</text>
		<call-template name="endl" />

		<value-of select="$indent" />
		<value-of select="$pyVarName" />
		<text>.usage["details"] = """</text>
		<call-template name="prg.usage.optionListDescription">
			<with-param name="optionsNode" select="$optionsNode" />
			<with-param name="details" select="true()" />
		</call-template>
		<text>"""</text>
		<call-template name="endl" />
	</template>

	<template name="prg.py.module.option">
		<param name="parentVarName">
			<text>self.program</text>
		</param>
		<param name="indent" />
		<param name="optionNode" select="." />

		<variable name="variableName" select="normalize-space($optionNode/prg:databinding/prg:variable)" />
		<variable name="pyVarName">
			<call-template name="prg.py.module.tempVarName">
				<with-param name="node" select="$optionNode" />
			</call-template>
		</variable>
		<variable name="pyClassName">
			<choose>
				<when test="$optionNode/self::prg:switch">
					<text>SwitchOptionInfo</text>
				</when>
				<when test="$optionNode/self::prg:argument">
					<text>ArgumentOptionInfo</text>
				</when>
				<when test="$optionNode/self::prg:multiargument">
					<text>MultiArgumentOptionInfo</text>
				</when>
				<when test="$optionNode/self::prg:group">
					<text>GroupOptionInfo</text>
				</when>
			</choose>
		</variable>

		<value-of select="$indent" />
		<value-of select="$pyVarName" />
		<text> = </text>
		<value-of select="$pyClassName" />
		<text>("</text>
		<value-of select="$variableName" />
		<text>")</text>
		<call-template name="endl" />

		<if test="$optionNode/prg:names">
			<value-of select="$indent" />
			<value-of select="$pyVarName" />
			<text>.set_names(</text>
			<call-template name="prg.py.module.nodeValueStringList">
				<with-param name="rootNode" select="$optionNode/prg:names" />
			</call-template>
			<text>)</text>
			<call-template name="endl" />

			<value-of select="$indent" />
			<value-of select="$pyVarName" />
			<text>.documentation.option_names = "</text>
			<call-template name="prg.usage.allOptionNameDisplay">
				<with-param name="optionNode" select="$optionNode" />
			</call-template>
			<text>"</text>
			<call-template name="endl" />
		</if>

		<if test="$optionNode/self::prg:argument or $optionNode/self::prg:multiargument">
			<value-of select="$indent" />
			<value-of select="$pyVarName" />
			<text>.documentation.value_description = """</text>
			<call-template name="prg.usage.argumentValueDescription">
				<with-param name="optionNode" select="$optionNode" />
			</call-template>
			<text>"""</text>
			<call-template name="endl" />
		</if>

		<if test="$optionNode/prg:documentation/prg:abstract">
			<value-of select="$indent" />
			<value-of select="$pyVarName" />
			<text>.documentation.abstract = """</text>
			<call-template name="prg.usage.descriptionDisplay">
				<with-param name="textNode" select="$optionNode/prg:documentation/prg:abstract" />
			</call-template>
			<text>"""</text>
			<call-template name="endl" />
		</if>

		<if test="$optionNode/prg:documentation/prg:details">
			<value-of select="$indent" />
			<value-of select="$pyVarName" />
			<text>.documentation.details = """</text>
			<call-template name="prg.usage.descriptionDisplay">
				<with-param name="textNode" select="$optionNode/prg:documentation/prg:details" />
			</call-template>
			<text>"""</text>
			<call-template name="endl" />
		</if>

		<if test="$optionNode/@required = 'true'">
			<value-of select="$indent" />
			<value-of select="$pyVarName" />
			<text>.required = True</text>
			<call-template name="endl" />
		</if>
		
		<if test="$optionNode/prg:default">
			<choose>
				<when test="$optionNode/self::prg:argument">
					<value-of select="$indent" />
					<value-of select="$pyVarName" />
					<text>.default = "</text>
					<value-of select="$optionNode/prg:default" />
					<text>"</text>
					<call-template name="endl" />
				</when>
				<!-- @todo group default -->
			</choose>
		</if>
		
		<if test="$optionNode/prg:select[@restrict = 'true']">
			<value-of select="$indent" />
			<value-of select="$pyVarName" />
			<text>.validators.append(RestrictedValueValidator(</text>
			<call-template name="prg.py.module.nodeValueStringList">
				<with-param name="rootNode" select="$optionNode/prg:select" />
			</call-template>
			<text>))</text>
			<call-template name="endl" />
		</if>
		
		<if test="$optionNode/prg:type/prg:number">
			<variable name="numberNode" select="$optionNode/prg:type/prg:number" />
			<value-of select="$indent" />
			<value-of select="$pyVarName" />
			<text>.validators.append(NumberValidator(</text>
			<choose>
				<when test="$numberNode/@min">
					<value-of select="$numberNode/@min" />
				</when>
				<otherwise>
					<text>"NaN"</text>
				</otherwise>
			</choose>
			<text>, </text>
			<choose>
				<when test="$numberNode/@max">
					<value-of select="$numberNode/@max" />
				</when>
				<otherwise>
					<text>"NaN"</text>
				</otherwise>
			</choose>
			<text>))</text>
			<call-template name="endl" />
		</if>
		
		<if test="$optionNode/@min">
			<value-of select="$indent" />
			<value-of select="$pyVarName" />
			<text>.min = </text><value-of select="$optionNode/@min" />
			<call-template name="endl" />
		</if>
		
		<if test="$optionNode/@max">
			<value-of select="$indent" />
			<value-of select="$pyVarName" />
			<text>.max = </text><value-of select="$optionNode/@max" />
			<call-template name="endl" />
		</if>
		
		<if test="$optionNode/prg:type/prg:path[@exist = 'true']">
			<variable name="pathNode" select="$optionNode/prg:type/prg:path" />
			<value-of select="$indent" />
			<value-of select="$pyVarName" />
			<text>.validators.append(PathValidator(</text>
			<call-template name="prg.py.module.nodeNameStringList">
				<with-param name="rootNode" select="$pathNode/prg:kinds" />
			</call-template>
			<text>, "</text>
			<value-of select="$pathNode/@access" />
			<text>"</text>
			<text>))</text>
			<call-template name="endl" />
		</if>
		<if test="$optionNode[@type ='exclusive' ]">
			<value-of select="$indent" />
			<value-of select="$pyVarName" />
			<text>.type = GroupOptionType.Exclusive</text>
			<call-template name="endl" />
		</if>
		<if test="$optionNode/prg:options">
			<for-each select="$optionNode/prg:options/*">
				<!-- Note: only select accessible options -->
				<!-- <if test="./prg:databinding/prg:variable | ./prg:names"> -->
				<call-template name="prg.py.module.option">
					<with-param name="parentVarName" select="$pyVarName" />
					<with-param name="optionsNode" select="." />
					<with-param name="indent" select="$indent" />
				</call-template>
				<!-- </if> -->
			</for-each>
		</if>

		<value-of select="$indent" />
		<value-of select="$parentVarName" />
		<text>.add_option(</text>
		<value-of select="$pyVarName" />
		<text>)</text>
		<call-template name="endl" />
	</template>

	<template name="prg.py.module.subcommand">
		<param name="parentVarName">
			<text>self.program</text>
		</param>
		<param name="subcommandNode" select="." />
		<param name="indent" />

		<variable name="pyVarName">
			<text>_sc_</text>
			<value-of select="$subcommandNode/prg:name" />
		</variable>

		<value-of select="$indent" />
		<value-of select="$pyVarName" />
		<text> = SubcommandInfo("</text>
		<value-of select="$subcommandNode/prg:name" />
		<text>")</text>
		<call-template name="endl" />

		<if test="$subcommandNode/prg:documentation/prg:abstract">
			<value-of select="$indent" />
			<value-of select="$pyVarName" />
			<text>.documentation["abstract"] = """</text>
			<apply-templates select="$subcommandNode/prg:documentation/prg:abstract" />
			<text>"""</text>
			<call-template name="endl" />
		</if>

		<if test="$subcommandNode/prg:aliases">
			<value-of select="$indent" />
			<value-of select="$pyVarName" />
			<text>.aliases = </text>
			<call-template name="prg.py.module.nodeValueStringList">
				<with-param name="rootNode" select="$subcommandNode/prg:aliases" />
			</call-template>
			<call-template name="endl" />
		</if>

		<variable name="optionsNode" select="$subcommandNode/prg:options"></variable>

		<for-each select="$optionsNode/*">
			<call-template name="prg.py.module.option">
				<with-param name="optionNode" select="." />
				<with-param name="parentVarName" select="$pyVarName" />
				<with-param name="indent" select="$indent" />
			</call-template>
		</for-each>

		<call-template name="prg.py.module.usageStrings">
			<with-param name="pyVarName" select="$pyVarName" />
			<with-param name="optionsNode" select="$optionsNode" />
			<with-param name="indent" select="$indent" />
		</call-template>

		<value-of select="$indent" />
		<value-of select="$parentVarName" />
		<text>.add_subcommand(</text>
		<value-of select="$pyVarName" />
		<text>)</text>
		<call-template name="endl" />
	</template>

	<template name="prg.py.module.buildOptionInfo">
		<param name="parentVarName">
			<text>self.program</text>
		</param>
		<param name="optionsNode" select="." />
		<param name="indent" />

		<if test="$optionsNode">
			<for-each select="$optionsNode/*">
				<call-template name="prg.py.module.option">
					<with-param name="parentVarName" select="$parentVarName" />
					<with-param name="indent" select="$indent" />
				</call-template>
			</for-each>
		</if>
		<call-template name="prg.py.module.usageStrings">
			<with-param name="pyVarName" select="$parentVarName" />
			<with-param name="optionsNode" select="$optionsNode" />
			<with-param name="indent" select="$indent" />
		</call-template>
	</template>

	<template name="prg.py.module.buildSubcommandInfo">
		<param name="parentVarName">
			<text>self.program</text>
		</param>
		<param name="indent" />
		<param name="subcommandsNode" select="." />

		<for-each select="$subcommandsNode/*">
			<call-template name="prg.py.module.subcommand">
				<with-param name="parentVarName" select="$parentVarName" />
				<with-param name="subcommandNode" select="." />
				<with-param name="indent" select="$indent" />
			</call-template>
		</for-each>
	</template>

	<template match="//prg:program">
		<variable name="indent">
			<text>&#9;&#9;</text>
		</variable>

		<text>"""Auto generated module"""</text>
		<call-template name="endl" />
		<text>from Validators import *</text>
		<call-template name="endl" />
		<text>from Base import *</text>
		<call-template name="endl" />
		<text>from Info import *</text>
		<call-template name="endl" />
		<text>from Parser import *</text>
		<call-template name="endl" />
		<text>import textwrap</text>
		<![CDATA[
class Program:
	"""Program description"""		
	def __init__(self):
]]><value-of select="$indent" />
		<text>self.program = ProgramInfo("</text>
		<value-of select="./prg:name" />
		<text>")</text>
		<call-template name="endl" />

		<if test="./prg:documentation/prg:abstract">
			<value-of select="$indent" />
			<text>self.program.documentation["abstract"] = """</text>
			<apply-templates select="./prg:documentation/prg:abstract" />
			<text>"""</text>
			<call-template name="endl" />
		</if>

		<!-- Options -->
		<call-template name="endl" />
		<call-template name="prg.py.module.buildOptionInfo">
			<with-param name="optionsNode" select="./prg:options" />
			<with-param name="indent" select="$indent" />
		</call-template>

		<!-- Subcommands -->
		<call-template name="prg.py.module.buildSubcommandInfo">
			<with-param name="subcommandsNode" select="./prg:subcommands" />
			<with-param name="indent" select="$indent" />
		</call-template>

		<!-- Values -->

		<!-- parse and usage method --><![CDATA[
	def parse(self, argv):
		""" Parse the given command line arguments and return a ParserResult object"""
		parser = Parser()
		return parser.parse(self.program, argv)
		
	def usage(self, result = None, flags = Usage.AllInfos):
		""" Return the program usage string """
		return ParserResultUtil.usage(self.program, result, flags) 
	]]>
	</template>

</stylesheet>
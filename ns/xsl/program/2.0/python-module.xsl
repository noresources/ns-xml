<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->
<!-- Create the Python module to manage the program options -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">

	<import href="base.xsl" />
	<import href="../../languages/base.xsl" />

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

	<template name="prg.py.module.stringList">
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

	<template name="prg.py.module.option">
		<param name="parentVarName">
			<text>self.program</text>
		</param>
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

		<value-of select="$pyVarName" />
		<text> = </text>
		<value-of select="$pyClassName" />
		<text>("</text>
		<value-of select="$variableName" />
		<text>")</text>
		<call-template name="endl" />
		<if test="$optionNode/prg:names">
			<value-of select="$pyVarName" />
			<text>.set_names(</text>
			<call-template name="prg.py.module.stringList">
				<with-param name="rootNode" select="$optionNode/prg:names" />
			</call-template>
			<text>)</text>
			<call-template name="endl" />
		</if>
		<if test="$optionNode/prg:default">
			<choose>
				<when test="$optionNode/self::prg:argument">
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
			<value-of select="$pyVarName" />
			<text>.validators.append(RestrictedValueValidator(</text>
			<call-template name="prg.py.module.stringList">
				<with-param name="rootNode" select="$optionNode/prg:select" />
			</call-template>
			<text>))</text>
			<call-template name="endl" />
		</if>
		<if test="$optionNode[@type ='exclusive' ]">
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
				</call-template>
				<!-- </if> -->
			</for-each>
		</if>

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

		<variable name="pyVarName">
			<text>_sc_</text>
			<value-of select="$subcommandNode/prg:name" />
		</variable>

		<value-of select="$pyVarName" />
		<text> = SubcommandInfo("</text>
		<value-of select="$subcommandNode/prg:name" />
		<text>")</text>
		<call-template name="endl" />
		
		<if test="$subcommandNode/prg:aliases">
			<value-of select="$pyVarName" /><text>.aliases = </text>
			<call-template name="prg.py.module.stringList">
				<with-param name="rootNode" select="$subcommandNode/prg:aliases" />
			</call-template>
			<call-template name="endl" />
		</if>
		
		<for-each select="$subcommandNode/prg:options/*">
			<call-template name="prg.py.module.option">
				<with-param name="optionNode" select="." />
				<with-param name="parentVarName" select="$pyVarName" />
			</call-template>
		</for-each>
		<value-of select="$parentVarName" /><text>.add_subcommand(</text><value-of select="$pyVarName" /><text>)</text>
		<call-template name="endl" />
	</template>

	<template name="prg.py.module.buildOptionInfo">
		<param name="parentVarName">
			<text>self.program</text>
		</param>
		<param name="optionsNode" select="." />
		<call-template name="code.block">
			<with-param name="indentChar">
				<text>&#9;&#9;</text>
			</with-param>
			<with-param name="content">
				<for-each select="$optionsNode/*">
					<call-template name="prg.py.module.option">
						<with-param name="parentVarName" select="$parentVarName" />
					</call-template>
				</for-each>
			</with-param>
		</call-template>
	</template>

	<template name="prg.py.module.buildSubcommandInfo">
		<param name="parentVarName">
			<text>self.program</text>
		</param>
		<param name="subcommandsNode" select="." />
		
		<call-template name="code.block">
			<with-param name="indentChar">
				<text>&#9;&#9;</text>
			</with-param>
			<with-param name="content">
				<for-each select="$subcommandsNode/*">
					<call-template name="prg.py.module.subcommand">
						<with-param name="parentVarName" select="$parentVarName" />
						<with-param name="subcommandNode" select="." />
					</call-template>
				</for-each>
			</with-param>
		</call-template>
	</template>

	<template match="//prg:program">
		<text>"""Auto generated module"""</text>
		<call-template name="endl" />
		<text>from Validators import *</text>
		<call-template name="endl" />
		<text>from InfoBase import *</text>
		<call-template name="endl" />
		<text>from Parser import *</text>
		<call-template name="endl" /><![CDATA[
class Program:
	def __init__(self):
		self.program = ProgramInfo()]]>
		<!-- Options -->
		<call-template name="prg.py.module.buildOptionInfo">
			<with-param name="optionsNode" select="./prg:options" />
		</call-template>

		<!-- Subcommands -->
		<call-template name="prg.py.module.buildSubcommandInfo">
			<with-param name="subcommandsNode" select="./prg:subcommands" />
		</call-template>

		<!-- Values -->

		<!-- parse function --><![CDATA[
	def parse(self, argv):
		parser = Parser()
		return parser.parse(self.program, argv)
	]]>
	</template>

</stylesheet>
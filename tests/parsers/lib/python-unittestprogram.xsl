<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 - 2021 by Renaud Guillard (dev@nore.fr) -->
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" version="1.0">
	<output method="text" encoding="utf-8" />
	<param name="interpreter">
		<text>python</text>
	</param>
	<include href="../../../ns/xsl/languages/base.xsl" />
	<template match="prg:databinding/prg:variable">
		<value-of select="normalize-space(.)" />
	</template>

	<template match="/">
		<text>#!/usr/bin/env </text>
		<value-of select="$interpreter" />
		<text><![CDATA[
import sys
import Parser
import ProgramInfo

class UnittestUtil:
	def array_to_string(self, v, begin_str = "", end_str = "", separator_str = " "):
		first = True
		res = ""
		for i in v:
			if isinstance(i, tuple):
				i = i[1]
			if not first:
				res = res + separator_str
			else:
				first = False
			res = res + begin_str + str(i) + end_str
		return res
		
	def argument_to_string(self, v):
		if v == None:
			return ""
		else:
			return str(v)

u = UnittestUtil()

info = ProgramInfo.TestProgramInfo()
parser = Parser.Parser(info)
result = parser.parse(sys.argv, 1)
displayHelp = False

print ("CLI: " + u.array_to_string(sys.argv[1:len(sys.argv)], "\"", "\"", ", "))
print ("Value count: " + str(result.valueCount()))
print ("Values: " + u.array_to_string(result, "\"", "\"", ", "))
messages = result.getMessages(Parser.Message.ERROR)
errorCount = len(messages)
print ("Error count: " + str(errorCount))
if errorCount > 0:
	for index in range(len(sys.argv)):
		arg = sys.argv[index]
		if arg == "__msg__":
			print (u.array_to_string(messages, " - ", "", "\n"))
		if arg == "__help__":
			displayHelp = True
            
if result.subcommand:
	print ("Subcommand: " + result.subcommandName)
else:
	print ("Subcommand: ")
	
]]></text>
		<!-- Global args -->
		<if test="/prg:program/prg:options">
			<variable name="root" select="/prg:program/prg:options" />
			<apply-templates select="$root//prg:switch | $root//prg:argument | $root//prg:multiargument | .//prg:group" />
		</if>
		<for-each select="/prg:program/prg:subcommands/*">
			<if test="./prg:options">
				<text>if result.subcommand and result.subcommandName == "</text>
				<apply-templates select="prg:name" />
				<text>":</text>
				<call-template name="code.block">
					<with-param name="content">
						<apply-templates select=".//prg:switch | .//prg:argument | .//prg:multiargument | .//prg:group" />
					</with-param>
				</call-template>
			</if>
		</for-each><![CDATA[

if displayHelp:
	print ("Help")
	usg = Parser.UsageFormat()
	print (info.usage(usg))
]]></template>

	<template name="prg.unittest.python.variablePrefix">
		<param name="node" select="." />
		<choose>
			<when test="$node/self::prg:subcommand">
				<apply-templates select="$node/prg:name" />
				<text>_</text>
			</when>
			<when test="$node/..">
				<call-template name="prg.unittest.python.variablePrefix">
					<with-param name="node" select="$node/.." />
				</call-template>
			</when>
		</choose>
	</template>

	<template name="prg.python.unittest.variableNameTree">
		<param name="node" />
		<param name="leaf" select="true()" />

		<choose>
			<when test="$node/self::prg:subcommand">
				<text>result.subcommand.</text>
			</when>
			<when test="$node/self::prg:program">
				<text>result.</text>
			</when>
			<when test="$node/../..">
				<call-template name="prg.python.unittest.variableNameTree">
					<with-param name="node" select="$node/../.." />
					<with-param name="leaf" select="false()" />
				</call-template>
			</when>
		</choose>
		<if test="$leaf">
			<apply-templates select="$node/prg:databinding/prg:variable" />
			<text>()</text>
		</if>
	</template>

	<template match="//prg:switch">
		<if test="./prg:databinding/prg:variable">
			<text>print ("</text>
			<call-template name="prg.unittest.python.variablePrefix" />
			<apply-templates select="./prg:databinding/prg:variable" />
			<text>="</text>
			<text> + str(</text>
			<call-template name="prg.python.unittest.variableNameTree">
				<with-param name="node" select="." />
			</call-template>
			<text>))</text>
			<value-of select="'&#10;'" />
		</if>
	</template>

	<template match="//prg:argument">
		<if test="./prg:databinding/prg:variable">
			<text>print ("</text>
			<call-template name="prg.unittest.python.variablePrefix" />
			<apply-templates select="./prg:databinding/prg:variable" />
			<text>="</text>
			<text> + u.argument_to_string(</text>
			<call-template name="prg.python.unittest.variableNameTree">
				<with-param name="node" select="." />
			</call-template>
			<text>))</text>
			<value-of select="'&#10;'" />
		</if>
	</template>

	<template match="//prg:multiargument">
		<if test="./prg:databinding/prg:variable">
			<text>print ("</text>
			<call-template name="prg.unittest.python.variablePrefix" />
			<apply-templates select="./prg:databinding/prg:variable" />
			<text>="</text>
			<text> + u.array_to_string(</text>
			<call-template name="prg.python.unittest.variableNameTree">
				<with-param name="node" select="." />
			</call-template>
			<text>))</text>
			<value-of select="'&#10;'" />
		</if>
	</template>

	<template match="//prg:group">
		<if test="./prg:databinding/prg:variable">
			<text>print ("</text>
			<call-template name="prg.unittest.python.variablePrefix" />
			<apply-templates select="./prg:databinding/prg:variable" />
			<text>="</text>
			<if test="./@type = 'exclusive'">
				<text> + u.argument_to_string(</text>
				<call-template name="prg.python.unittest.variableNameTree">
					<with-param name="node" select="." />
				</call-template>
				<text>)</text>
			</if>
			<text>)</text>
			<value-of select="'&#10;'" />
		</if>
	</template>

</stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	<output method="text" encoding="utf-8" />
	
	<include href="../../ns/xsl/languages/base.xsl"/>
		
	<template match="prg:databinding/prg:variable">
		<value-of select="normalize-space(.)" />
	</template>
	
	<template match="/">
		<text><![CDATA[#!/usr/bin/python
import sys
import Program

class UnittestUtil:
	def array_to_string(self, v):
		first = True
		res = ""
		for i in v:	
			if not first:
				res = res + " "
			else:
				first = False
			res = res + str(i)
		return res
	def argument_to_string(self, v):
		if v == None:
			return ""
		else:
			return str(v)

u = UnittestUtil()

p = Program.Program()
r = p.parse(sys.argv[1:len(sys.argv)])

print "CLI: " + u.array_to_string(sys.argv[1:len(sys.argv)])
print "Value count: " + str(len(r.values))
print "Values: " + u.array_to_string(r.values)
print "Error count: " + str(len(r.issues["errors"]))
if r.subcommand:
	print "Subcommand: " + r.subcommand.name
else:
	print "Subcommand: "
]]></text>
		<!-- Global args -->
		<if test="/prg:program/prg:options">
			<variable name="root" select="/prg:program/prg:options" />
			<apply-templates select="$root//prg:switch | $root//prg:argument | $root//prg:multiargument" />
		</if>
		
		<for-each select="/prg:program/prg:subcommands/*">
			<if test="./prg:options">
				<text>if r.subcommand and r.subcommand.name == "</text>
				<apply-templates select="prg:name" />
				<text>":</text>
				<call-template name="code.block">
					<with-param name="content">
						<apply-templates select=".//prg:switch | .//prg:argument | .//prg:multiargument" />
					</with-param>	
				</call-template>
			</if>
		</for-each>
		
	</template>

	<template name="prg.unittest.py.variablePrefix">
		<param name="node" select="." />
		<choose>
			<when test="$node/self::prg:subcommand">
				<apply-templates select="$node/prg:name" />
				<text>_</text>
			</when>
			<when test="$node/..">
				<call-template name="prg.unittest.py.variablePrefix">
					<with-param name="node" select="$node/.." />
				</call-template>
			</when>
		</choose>
	</template>
	
	<template name="prg.py.unittest.variableNameTree">
		<param name="node" />
		<choose>
			<when test="$node/self::prg:subcommand">
				<text>r.subcommand.options.</text>
			</when>
			<when test="$node/self::prg:program">
				<text>r.options.</text>
			</when>
			<when test="$node/..">
				<call-template name="prg.py.unittest.variableNameTree">
					<with-param name="node" select="$node/.." />
				</call-template>
			</when>
		</choose>		
		<apply-templates select="$node/prg:databinding/prg:variable" />
	</template>

	<template match="//prg:switch">
		<if test="./prg:databinding/prg:variable">
			<text>print "</text>
			<call-template name="prg.unittest.py.variablePrefix" />
			<apply-templates select="./prg:databinding/prg:variable" />
			<text>="</text>
			<text> + str(</text>
			<call-template name="prg.py.unittest.variableNameTree">
				<with-param name="node" select="." />
			</call-template>
			<text>)&#10;</text>
		</if>
	</template>

	<template match="//prg:argument">
		<if test="./prg:databinding/prg:variable">
			<text>print "</text>
			<call-template name="prg.unittest.py.variablePrefix" />
			<apply-templates select="./prg:databinding/prg:variable" />
			<text>="</text>
			<text> + u.argument_to_string(</text>
			<call-template name="prg.py.unittest.variableNameTree">
				<with-param name="node" select="." />
			</call-template>
			<text>)&#10;</text>
		</if>
	</template>

	<template match="//prg:multiargument">
		<if test="./prg:databinding/prg:variable">
			<text>print "</text>
			<call-template name="prg.unittest.py.variablePrefix" />
			<apply-templates select="./prg:databinding/prg:variable" />
			<text>="</text>
			<text> + u.array_to_string(</text>
			<call-template name="prg.py.unittest.variableNameTree">
				<with-param name="node" select="." />
			</call-template>
			<text>)&#10;</text>
		</if>
	</template>
</stylesheet>

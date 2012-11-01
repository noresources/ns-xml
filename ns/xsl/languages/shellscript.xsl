<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the BSD License, see LICENSE -->

<!-- Shell script language elements -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform">

	<import href="base.xsl" />

	<variable name="sh.endl" select="'&#10;'" />

	<template name="sh.block">
		<param name="indent" select="true()" />
		<param name="content" />
		<param name="addFinalEndl" select="true()" />
		<choose>
			<when test="$content">
				<choose>
					<when test="$indent">
						<call-template name="code.block">
							<with-param name="content" select="$content" />
							<with-param name="addFinalEndl" select="$addFinalEndl" />
						</call-template>
					</when>
					<otherwise>
						<call-template name="unixEndl" />
						<call-template name="str.trim">
							<with-param name="text">
								<value-of select="$content" />
							</with-param>
						</call-template>
						<call-template name="unixEndl" />
					</otherwise>
				</choose>
			</when>
			<otherwise>
				<call-template name="unixEndl" />
			</otherwise>
		</choose>
	</template>

	<template name="sh.comment">
		<param name="content" select="." />
		<call-template name="code.comment">
			<with-param name="marker">
				<text># </text>
			</with-param>
			<with-param name="content" select="$content" />
		</call-template>
	</template>

	<!-- Shell variable call -->
	<template name="sh.var">
		<param name="name" />
		<param name="index" />
		<param name="start" />
		<param name="length" />
		<param name="quoted" select="false()" />
		<if test="$quoted">
			<text>"</text>
		</if>
		<text>${</text>
		<value-of select="normalize-space($name)" />
		<choose>
			<when test="$index">
				<text>[</text>
				<value-of select="normalize-space($index)" />
				<text>]</text>
			</when>
			<when test="$start or $length">
				<text>:</text>
				<choose>
					<when test="$start">
						<value-of select="normalize-space($start)" />
					</when>
					<otherwise>
						<text>0</text>
					</otherwise>
				</choose>
				<if test="$length">
					<text>:</text>
					<value-of select="normalize-space($length)" />
				</if>
			</when>
		</choose>
		<text>}</text>
		<if test="$quoted">
			<text>"</text>
		</if>
	</template>

	<template name="sh.varLength">
		<param name="name" />
		<param name="quoted" select="false()" />
		<call-template name="sh.var">
			<with-param name="name">
				<text>#</text>
				<value-of select="normalize-space($name)" />
			</with-param>
			<with-param name="quoted" select="$quoted" />
		</call-template>
	</template>

	<!-- Operations on itself -->
	<template name="sh.var.selfexpr">
		<!-- Variable name -->
		<param name="name" />
		<!-- Operator -->
		<param name="operator" select="'+'" />
		<!-- Second operand -->
		<param name="value" select="1" />

		<value-of select="normalize-space($name)" />
		<text>=$(expr </text>
		<call-template name="sh.var">
			<with-param name="name" select="$name" />
		</call-template>
		<text> </text>
		<value-of select="normalize-space($operator)" />
		<text> </text>
		<value-of select="normalize-space($value)" />
		<text>)</text>
	</template>

	<template name="sh.varincrement">
		<param name="name" />
		<param name="value" select="1" />
		<call-template name="sh.var.selfexpr">
			<with-param name="name" select="$name" />
			<with-param name="value" select="$value" />
			<with-param name="operator" select="'+'" />
		</call-template>
	</template>

	<template name="sh.arrayLength">
		<param name="name" />
		<text>${#</text>
		<value-of select="normalize-space($name)" />
		<text>[*]}</text>
	</template>

	<template name="sh.arraySetIndex">
		<param name="name" />
		<param name="index" />
		<param name="value" />
		<value-of select="normalize-space($name)" />
		<text>[</text>
		<value-of select="normalize-space($index)" />
		<text>]=</text>
		<value-of select="normalize-space($value)" />
	</template>

	<template name="sh.arrayAppend">
		<param name="name" />
		<param name="value" />
		<param name="startIndex" select="0" />
		
		<variable name="index">
			<choose>
				<when test="not(number($startIndex) = number($startIndex)) or ($startIndex &gt; 0)">
					<text>$(expr </text>
					<call-template name="sh.arrayLength">
						<with-param name="name" select="$name" />
					</call-template>
					<text> + </text>
					<value-of select="$startIndex" />
					<text>)</text>
				</when>
				<otherwise>
					<call-template name="sh.arrayLength">
						<with-param name="name" select="$name" />
					</call-template>
				</otherwise>
			</choose>
		</variable>
		
		<call-template name="sh.arraySetIndex">
			<with-param name="name" select="$name" />
			<with-param name="index" select="$index" />
			<with-param name="value" select="$value" />
		</call-template>
	</template>

	<template name="sh.arrayCopy">
		<param name="from" />
		<param name="to" />
		<param name="indexVariableName">
			<text>i</text>
		</param>
		<param name="append" select="true()" />

		<variable name="indexVariable">
			<call-template name="sh.var">
				<with-param name="name" select="$indexVariableName" />
			</call-template>
		</variable>

		<call-template name="sh.for">
			<with-param name="condition">
				<text>((</text>
				<value-of select="normalize-space($indexVariableName)" />
				<text>=0;</text>
				<value-of select="normalize-space($indexVariable)" />
				<text>&lt;</text>
				<call-template name="sh.arrayLength">
					<with-param name="name" select="$from" />
				</call-template>
				<text>;</text>
				<value-of select="normalize-space($indexVariableName)" />
				<text>++))</text>
			</with-param>
			<with-param name="do">
				<call-template name="sh.arraySetIndex">
					<with-param name="name" select="$to" />
					<with-param name="index">
						<choose>
							<when test="$append">
								<call-template name="sh.arrayLength">
									<with-param name="name" select="$to" />
								</call-template>
							</when>
							<otherwise>
								<value-of select="normalize-space($indexVariable)" />
							</otherwise>
						</choose>
					</with-param>
					<with-param name="value">
						<call-template name="sh.var">
							<with-param name="name" select="$from" />
							<with-param name="index" select="$indexVariable" />
							<with-param name="quoted" select="true()" />
						</call-template>
					</with-param>
				</call-template>
			</with-param>
		</call-template>
	</template>

	<template name="sh.arrayForEach">
		<param name="name" />
		<param name="indexVariableName">
			<text>i</text>
		</param>
		<param name="startIndex" select="0" />
		<param name="do" />

		<variable name="indexVariable">
			<call-template name="sh.var">
				<with-param name="name" select="$indexVariableName" />
			</call-template>
		</variable>

		<call-template name="sh.for">
			<with-param name="condition">
				<text>((</text>
				<value-of select="normalize-space($indexVariableName)" />
				<text>=0;</text>
				<value-of select="normalize-space($indexVariable)" />
				<text>&lt;</text>
				<call-template name="sh.arrayLength">
					<with-param name="name" select="$name" />
				</call-template>
				<text>;</text>
				<value-of select="normalize-space($indexVariableName)" />
				<text>++))</text>
			</with-param>
			<with-param name="do" select="$do" />
		</call-template>
	</template>

	<!-- Shell function definition -->
	<template name="sh.functionDefinition">
		<param name="name" />
		<param name="content" />
		<param name="indent" select="true()" />
		<value-of select="normalize-space($name)" />
		<text>()</text>
		<call-template name="unixEndl" />
		<text>{</text>
		<call-template name="sh.block">
			<with-param name="content" select="$content" />
			<with-param name="indent" select="$indent" />
		</call-template>
		<text>}</text>
		<call-template name="unixEndl" />
	</template>

	<template name="sh.while">
		<param name="condition" />
		<param name="do" />
		<param name="indent" select="true()" />

		<text>while </text>
		<value-of select="normalize-space($condition)" />
		<call-template name="unixEndl" />
		<text>do</text>
		<call-template name="sh.block">
			<with-param name="indent" select="$indent" />
			<with-param name="content">
				<value-of select="$do" />
			</with-param>
		</call-template>
		<text>done</text>
	</template>

	<template name="sh.for">
		<param name="condition" />
		<param name="do" />
		<param name="indent" select="true()" />

		<text>for </text>
		<value-of select="normalize-space($condition)" />
		<call-template name="unixEndl" />
		<text>do</text>
		<call-template name="sh.block">
			<with-param name="indent" select="$indent" />
			<with-param name="content">
				<value-of select="$do" />
			</with-param>
		</call-template>
		<text>done</text>
	</template>

	<template name="sh.incrementalFor">
		<param name="variable">
			<text>i</text>
		</param>
		<param name="init" select="0" />
		<param name="operator" select="'&lt;'" />
		<param name="limit" />
		<param name="increment" select="1" />
		<param name="do" />
		<param name="indent" select="true()" />

		<call-template name="sh.for">
			<with-param name="indent" select="$indent" />

			<with-param name="condition">
				<text>((</text>
				<value-of select="normalize-space($variable)" />
				<text>=</text>
				<value-of select="normalize-space($init)" />
				<text>;</text>
				<call-template name="sh.var">
					<with-param name="name" select="$variable" />
				</call-template>
				<value-of select="normalize-space($operator)" />
				<value-of select="normalize-space($limit)" />
				<text>;</text>
				<value-of select="normalize-space($variable)" />
				<choose>
					<when test="$increment = 1">
						<text>++</text>
					</when>
					<otherwise>
						<text>=$(expr </text>
						<call-template name="sh.var">
							<with-param name="name" select="$variable" />
						</call-template>
						<text> + </text>
						<value-of select="normalize-space($increment)" />
						<text>))</text>
					</otherwise>
				</choose>
				<text>))</text>
			</with-param>
			<with-param name="do" select="$do" />
		</call-template>
	</template>

	<template name="sh.if">
		<param name="condition" />
		<param name="then" />
		<param name="else" />
		<param name="indent" select="true()" />

		<variable name="ncond" select="normalize-space($condition)" />

		<if test="(string-length($ncond) + string-length($then)) &gt; 0">
			<text>if </text>
			<value-of select="$ncond" />
			<call-template name="unixEndl" />
			<text>then</text>
			<call-template name="sh.block">
				<with-param name="indent" select="$indent" />
				<with-param name="content" select="$then" />
			</call-template>
			<if test="$else and (string-length($else) &gt; 0)">
				<text>else</text>
				<call-template name="sh.block">
					<with-param name="indent" select="$indent" />
					<with-param name="content" select="$else" />
				</call-template>
			</if>
			<text>fi</text>
		</if>
		<call-template name="unixEndl" />
	</template>

	<template name="sh.case">
		<param name="case" />
		<param name="in" />
		<param name="indent" select="true()" />

		<text>case "</text>
		<value-of select="$case" />
		<text>" in</text>
		<call-template name="unixEndl" />
		<value-of select="$in" />
		<call-template name="unixEndl" />
		<text>esac</text>
	</template>

	<template name="sh.caseblock">
		<param name="case" />
		<param name="content" />
		<param name="indent" select="true()" />

		<value-of select="$case" />
		<text>)</text>
		<call-template name="sh.block">
			<with-param name="indent" select="$indent" />
			<with-param name="content">
				<value-of select="$content" />
				<call-template name="unixEndl" />
				<text>;;</text>
			</with-param>
		</call-template>
	</template>

	<!-- Code chunks -->

	<!-- 1>/dev/null 2>&1 -->
	<template name="sh.chunk.nullRedirection">
		<text>1&gt;/dev/null 2&gt;&amp;1</text>
	</template>

</stylesheet>
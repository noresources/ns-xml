<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Shell script language elements -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform">

	<import href="base.xsl" />

	<!-- End of line character for UNIX shell scripts -->
	<variable name="sh.endl" select="$str.unix.endl" />

	<!-- UNIX shell script code block (Indented code block) -->
	<template name="sh.block">
		<!-- Indent the content if true (the default) -->
		<param name="indent" select="true()" />
		<!-- Code snippet -->
		<param name="content" />
		<!-- Add a End-of-line at end of block -->
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
						<value-of select="$sh.endl" />
						<call-template name="str.trim">
							<with-param name="text">
								<value-of select="$content" />
							</with-param>
						</call-template>
						<value-of select="$sh.endl" />
					</otherwise>
				</choose>
			</when>
			<otherwise>
				<value-of select="$sh.endl" />
			</otherwise>
		</choose>
	</template>

	<!-- UNIX shell comment block -->
	<template name="sh.comment">
		<!-- Comment text -->
		<param name="content" select="." />
		<call-template name="code.comment">
			<with-param name="marker">
				<text># </text>
			</with-param>
			<with-param name="content" select="$content" />
		</call-template>
	</template>

	<!-- UNIX shell local variable definition -->
	<template name="sh.local">
		<!-- Variable name -->
		<param name="name" />
		<!-- Interpreter type -->
		<param name="interpreter" select="sh" />
		<!-- Variable initial value -->
		<param name="value" />
		<!-- Indicates if the value value have to be quoted -->
		<param name="quoted" select="'auto'" />

		<variable name="isNumber" select="(string(number($value)) != 'NaN')" />
		
		<variable name="quoteRequested">
			<choose>
				<when test="$quoted = 'auto'">
					<value-of select="not ($isNumber)" />
				</when>
				<otherwise>
					<value-of select="$quoted" />
				</otherwise>
			</choose>
		</variable>

		<choose>
			<when test="$interpreter = 'ksh'">
				<text>typeset var </text>
			</when>
			<otherwise>
				<text>local </text>
			</otherwise>
		</choose>

		<value-of select="$name" />
		
		<if test="($isNumber or (string-length($value) &gt; 0))">
			<text>=</text>
			<if test="$quoteRequested != 'false'">
				<text>"</text>
			</if>
			<value-of select="$value" />
			<if test="$quoteRequested != 'false'">
				<text>"</text>
			</if>
		</if>
	</template>

	<!-- UNIX shell variable call -->
	<template name="sh.var">
		<!-- Variable nmme -->
		<param name="name" />
		<!-- Treat the variable as an array and retrieve the $index element (not compatible with all shells) -->
		<param name="index" />
		<!-- Retrieve a substring of the variable content starting at offset $start (not compatible with all shells) -->
		<param name="start" />
		<!-- Retrieve a substring of $lenght character of the variable content (not compatible with all shells) -->
		<param name="length" />
		<!-- Add quotes around -->
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

	<!-- Create the expression to retrieve a variable value length (${#var}) -->
	<template name="sh.varLength">
		<!-- Variable name -->
		<param name="name" />
		<!-- Add quotes around -->
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

	<!-- Treat the variable as an integer value and increment its value -->
	<template name="sh.varincrement">
		<!-- Variable name -->
		<param name="name" />
		<!-- Increment value -->
		<param name="value" select="1" />
		<call-template name="sh.var.selfexpr">
			<with-param name="name" select="$name" />
			<with-param name="value" select="$value" />
			<with-param name="operator" select="'+'" />
		</call-template>
	</template>

	<!-- Create the expression to retrieve an array element count (not compatible with all shells) -->
	<template name="sh.arrayLength">
		<!-- Variable name -->
		<param name="name" />
		<text>${#</text>
		<value-of select="normalize-space($name)" />
		<text>[*]}</text>
	</template>

	<!-- Set an element of an array variable (not compatible with all shells) -->
	<template name="sh.arraySetIndex">
		<!-- Variable name -->
		<param name="name" />
		<!-- Array index -->
		<param name="index" />
		<!-- Element value -->
		<param name="value" />
		<value-of select="normalize-space($name)" />
		<text>[</text>
		<value-of select="normalize-space($index)" />
		<text>]=</text>
		<value-of select="normalize-space($value)" />
	</template>

	<!-- TODO replace startIndex by interpreter param -->
	<!-- Append a new element to an array variable -->
	<template name="sh.arrayAppend">
		<!-- Variable name -->
		<param name="name" />
		<!-- New element value -->
		<param name="value" />
		<!-- First element of the array (depends on interpreter type) -->
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

	<!-- Copy array elements to another variable (not compatible with all shells) -->
	<template name="sh.arrayCopy">
		<!-- Input variable name -->
		<param name="from" />
		<!-- Output variable name -->
		<param name="to" />
		<!-- Name of the index variable used in loop -->
		<param name="indexVariableName" select="'i'" />
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

	<!-- Iterate through array elements -->
	<template name="sh.arrayForEach">
		<!-- Array variable name -->
		<param name="name" />
		<!-- Internal loop index variable name -->
		<param name="indexVariableName" select="'i'" />
		<!-- First index to consider -->
		<param name="startIndex" select="0" />
		<!-- Code to execute for each element -->
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

	<!-- UNIX shell function definition (not compatible with all shells) -->
	<template name="sh.functionDefinition">
		<!-- Function name -->
		<param name="name" />
		<!-- Function body -->
		<param name="content" />
		<!-- Indicates if the function body have to be indented -->
		<param name="indent" select="true()" />
		<!-- UNIX shell interpreter type -->
		<param name="interpreter" select="'sh'" />

		<if test="$interpreter = 'ksh'">
			<text>function </text>
		</if>
		<value-of select="normalize-space($name)" />
		<if test="not($interpreter = 'ksh')">
			<text>()</text>
		</if>
		<value-of select="$sh.endl" />
		<text>{</text>
		<call-template name="sh.block">
			<with-param name="content" select="$content" />
			<with-param name="indent" select="$indent" />
		</call-template>
		<text>}</text>
		<value-of select="$sh.endl" />
	</template>

	<!-- While statement -->
	<template name="sh.while">
		<!-- Condition -->
		<param name="condition" />
		<!-- Loop code -->
		<param name="do" />
		<!-- -->
		<param name="indent" select="true()" />

		<text>while </text>
		<value-of select="normalize-space($condition)" />
		<value-of select="$sh.endl" />
		<text>do</text>
		<call-template name="sh.block">
			<with-param name="indent" select="$indent" />
			<with-param name="content">
				<value-of select="$do" />
			</with-param>
		</call-template>
		<text>done</text>
	</template>

	<!-- For statement -->
	<template name="sh.for">
		<!-- -->
		<param name="condition" />

		<param name="do" />
		<param name="indent" select="true()" />

		<text>for </text>
		<value-of select="normalize-space($condition)" />
		<value-of select="$sh.endl" />
		<text>do</text>
		<call-template name="sh.block">
			<with-param name="indent" select="$indent" />
			<with-param name="content">
				<value-of select="$do" />
			</with-param>
		</call-template>
		<text>done</text>
	</template>

	<!-- for in n .... m -->
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

	<!-- IF statement -->
	<template name="sh.if">
		<!-- Condition -->
		<param name="condition" />
		<!-- Code to execute if the condition is true -->
		<param name="then" />
		<!-- Code to execute if the condition is false -->
		<param name="else" />
		<param name="indent" select="true()" />

		<variable name="ncond" select="normalize-space($condition)" />

		<if test="(string-length($ncond) + string-length($then)) &gt; 0">
			<text>if </text>
			<value-of select="$ncond" />
			<value-of select="$sh.endl" />
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
		<value-of select="$sh.endl" />
	</template>

	<!-- CASE statement -->
	<template name="sh.case">
		<!-- Case variable name -->
		<param name="case" />
		<!-- Case body -->
		<param name="in" />
		<param name="indent" select="true()" />

		<text>case "</text>
		<value-of select="$case" />
		<text>" in</text>
		<value-of select="$sh.endl" />
		<value-of select="$in" />
		<value-of select="$sh.endl" />
		<text>esac</text>
	</template>

	<!-- -->
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
				<value-of select="$sh.endl" />
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
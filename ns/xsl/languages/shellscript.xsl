<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Shell script language elements -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:import href="base.xsl" />

	<!-- End of line character for UNIX shell scripts -->
	<xsl:variable name="sh.endl" select="$str.unix.endl" />

	<!-- UNIX shell script code block (Indented code block) -->
	<xsl:template name="sh.block">
		<!-- Indent the content if true (the default) -->
		<xsl:param name="indent" select="true()" />
		<!-- Code snippet -->
		<xsl:param name="content" />
		<!-- Add a End-of-line at end of block -->
		<xsl:param name="addFinalEndl" select="true()" />
		<xsl:choose>
			<xsl:when test="$content">
				<xsl:choose>
					<xsl:when test="$indent">
						<xsl:call-template name="code.block">
							<xsl:with-param name="content" select="$content" />
							<xsl:with-param name="addFinalEndl" select="$addFinalEndl" />
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$sh.endl" />
						<xsl:call-template name="str.trim">
							<xsl:with-param name="text">
								<xsl:value-of select="$content" />
							</xsl:with-param>
						</xsl:call-template>
						<xsl:value-of select="$sh.endl" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$sh.endl" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- UNIX shell comment block -->
	<xsl:template name="sh.comment">
		<!-- Comment text -->
		<xsl:param name="content" select="." />
		<xsl:call-template name="code.comment">
			<xsl:with-param name="marker">
				<xsl:text># </xsl:text>
			</xsl:with-param>
			<xsl:with-param name="content" select="$content" />
		</xsl:call-template>
	</xsl:template>

	<!-- UNIX shell local variable definition -->
	<xsl:template name="sh.local">
		<!-- Variable name -->
		<xsl:param name="name" />
		<!-- Interpreter type -->
		<xsl:param name="interpreter" select="sh" />
		<!-- Variable initial value -->
		<xsl:param name="value" />
		<!-- Indicates if the value value have to be quoted -->
		<xsl:param name="quoted" select="'auto'" />

		<xsl:variable name="isNumber" select="(string(number($value)) != 'NaN')" />

		<xsl:variable name="quoteRequested">
			<xsl:choose>
				<xsl:when test="$quoted = 'auto'">
					<xsl:value-of select="not ($isNumber)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$quoted" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$interpreter = 'ksh'">
				<xsl:text>typeset var </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>local </xsl:text>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:value-of select="$name" />

		<xsl:if test="($isNumber or (string-length($value) &gt; 0))">
			<xsl:text>=</xsl:text>
			<xsl:if test="$quoteRequested != 'false'">
				<xsl:text>"</xsl:text>
			</xsl:if>
			<xsl:value-of select="$value" />
			<xsl:if test="$quoteRequested != 'false'">
				<xsl:text>"</xsl:text>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<!-- Attempt to transform a string into a valid identifier name (variable,
		function) -->
	<xsl:template name="sh.validIdentifierName">
		<xsl:param name="name" />
		<xsl:call-template name="cede.validIdentifierName">
			<xsl:with-param name="name" select="$name" />
		</xsl:call-template>
	</xsl:template>

	<!-- UNIX shell variable call -->
	<xsl:template name="sh.var">
		<!-- Variable nmme -->
		<xsl:param name="name" />
		<!-- Treat the variable as an array and retrieve the $index element (not
			compatible with all shells) -->
		<xsl:param name="index" />
		<!-- Retrieve a substring of the variable content starting at offset $start
			(not compatible with all shells) -->
		<xsl:param name="start" />
		<!-- Retrieve a substring of $lenght character of the variable content
			(not compatible with all shells) -->
		<xsl:param name="length" />
		<!-- Add quotes around -->
		<xsl:param name="quoted" select="false()" />
		<xsl:if test="$quoted">
			<xsl:text>"</xsl:text>
		</xsl:if>
		<xsl:text>${</xsl:text>
		<xsl:value-of select="normalize-space($name)" />
		<xsl:choose>
			<xsl:when test="$index">
				<xsl:text>[</xsl:text>
				<xsl:value-of select="normalize-space($index)" />
				<xsl:text>]</xsl:text>
			</xsl:when>
			<xsl:when test="$start or $length">
				<xsl:text>:</xsl:text>
				<xsl:choose>
					<xsl:when test="$start">
						<xsl:value-of select="normalize-space($start)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>0</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="$length">
					<xsl:text>:</xsl:text>
					<xsl:value-of select="normalize-space($length)" />
				</xsl:if>
			</xsl:when>
		</xsl:choose>
		<xsl:text>}</xsl:text>
		<xsl:if test="$quoted">
			<xsl:text>"</xsl:text>
		</xsl:if>
	</xsl:template>

	<!-- Create the expression to retrieve a variable value length (${#var}) -->
	<xsl:template name="sh.varLength">
		<!-- Variable name -->
		<xsl:param name="name" />
		<!-- Add quotes around -->
		<xsl:param name="quoted" select="false()" />
		<xsl:call-template name="sh.var">
			<xsl:with-param name="name">
				<xsl:text>#</xsl:text>
				<xsl:value-of select="normalize-space($name)" />
			</xsl:with-param>
			<xsl:with-param name="quoted" select="$quoted" />
		</xsl:call-template>
	</xsl:template>

	<!-- Operations on itself -->
	<xsl:template name="sh.var.selfexpr">
		<!-- Variable name -->
		<xsl:param name="name" />
		<!-- Operator -->
		<xsl:param name="operator" select="'+'" />
		<!-- Second operand -->
		<xsl:param name="value" select="1" />

		<xsl:value-of select="normalize-space($name)" />
		<xsl:text>=$(expr </xsl:text>
		<xsl:call-template name="sh.var">
			<xsl:with-param name="name" select="$name" />
		</xsl:call-template>
		<xsl:text> </xsl:text>
		<xsl:value-of select="normalize-space($operator)" />
		<xsl:text> </xsl:text>
		<xsl:value-of select="normalize-space($value)" />
		<xsl:text>)</xsl:text>
	</xsl:template>

	<!-- Treat the variable as an integer value and increment its value -->
	<xsl:template name="sh.varincrement">
		<!-- Variable name -->
		<xsl:param name="name" />
		<!-- Increment value -->
		<xsl:param name="value" select="1" />
		<xsl:call-template name="sh.var.selfexpr">
			<xsl:with-param name="name" select="$name" />
			<xsl:with-param name="value" select="$value" />
			<xsl:with-param name="operator" select="'+'" />
		</xsl:call-template>
	</xsl:template>

	<!-- Create the expression to retrieve an array element count (not compatible
		with all shells) -->
	<xsl:template name="sh.arrayLength">
		<!-- Variable name -->
		<xsl:param name="name" />
		<xsl:text>${#</xsl:text>
		<xsl:value-of select="normalize-space($name)" />
		<xsl:text>[*]}</xsl:text>
	</xsl:template>

	<!-- Set an element of an array variable (not compatible with all shells) -->
	<xsl:template name="sh.arraySetIndex">
		<!-- Variable name -->
		<xsl:param name="name" />
		<!-- Array index -->
		<xsl:param name="index" />
		<!-- Element value -->
		<xsl:param name="value" />
		<xsl:value-of select="normalize-space($name)" />
		<xsl:text>[</xsl:text>
		<xsl:value-of select="normalize-space($index)" />
		<xsl:text>]=</xsl:text>
		<xsl:value-of select="normalize-space($value)" />
	</xsl:template>

	<!-- TODO replace startIndex by interpreter param -->
	<!-- Append a new element to an array variable -->
	<xsl:template name="sh.arrayAppend">
		<!-- Variable name -->
		<xsl:param name="name" />
		<!-- New element value -->
		<xsl:param name="value" />
		<!-- First element of the array (depends on interpreter type) -->
		<xsl:param name="startIndex" select="0" />

		<xsl:variable name="index">
			<xsl:choose>
				<xsl:when test="not(number($startIndex) = number($startIndex)) or ($startIndex &gt; 0)">
					<xsl:text>$(expr </xsl:text>
					<xsl:call-template name="sh.arrayLength">
						<xsl:with-param name="name" select="$name" />
					</xsl:call-template>
					<xsl:text> + </xsl:text>
					<xsl:value-of select="$startIndex" />
					<xsl:text>)</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="sh.arrayLength">
						<xsl:with-param name="name" select="$name" />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:call-template name="sh.arraySetIndex">
			<xsl:with-param name="name" select="$name" />
			<xsl:with-param name="index" select="$index" />
			<xsl:with-param name="value" select="$value" />
		</xsl:call-template>
	</xsl:template>

	<!-- Copy array elements to another variable (not compatible with all shells) -->
	<xsl:template name="sh.arrayCopy">
		<!-- Input variable name -->
		<xsl:param name="from" />
		<!-- Output variable name -->
		<xsl:param name="to" />
		<!-- Name of the index variable used in loop -->
		<xsl:param name="indexVariableName" select="'i'" />
		<xsl:param name="append" select="true()" />

		<xsl:variable name="indexVariable">
			<xsl:call-template name="sh.var">
				<xsl:with-param name="name" select="$indexVariableName" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:call-template name="sh.for">
			<xsl:with-param name="condition">
				<xsl:text>((</xsl:text>
				<xsl:value-of select="normalize-space($indexVariableName)" />
				<xsl:text>=0;</xsl:text>
				<xsl:value-of select="normalize-space($indexVariable)" />
				<xsl:text>&lt;</xsl:text>
				<xsl:call-template name="sh.arrayLength">
					<xsl:with-param name="name" select="$from" />
				</xsl:call-template>
				<xsl:text>;</xsl:text>
				<xsl:value-of select="normalize-space($indexVariableName)" />
				<xsl:text>++))</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="do">
				<xsl:call-template name="sh.arraySetIndex">
					<xsl:with-param name="name" select="$to" />
					<xsl:with-param name="index">
						<xsl:choose>
							<xsl:when test="$append">
								<xsl:call-template name="sh.arrayLength">
									<xsl:with-param name="name" select="$to" />
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="normalize-space($indexVariable)" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
					<xsl:with-param name="value">
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$from" />
							<xsl:with-param name="index" select="$indexVariable" />
							<xsl:with-param name="quoted" select="true()" />
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- Iterate through array elements -->
	<xsl:template name="sh.arrayForEach">
		<!-- Array variable name -->
		<xsl:param name="name" />
		<!-- Variable representing the current element -->
		<xsl:param name="elementVariableName" select="'i'" />
		<!-- UNIX shell interpreter type -->
		<xsl:param name="interpreter" select="'sh'" />
		<!-- Declare temporary variable as local variable -->
		<xsl:param name="declareLocal" select="false()" />
		<xsl:param name="do" />

		<xsl:if test="$declareLocal">
			<xsl:call-template name="sh.local">
				<xsl:with-param name="name" select="$elementVariableName" />
				<xsl:with-param name="interpreter" select="$interpreter" />
			</xsl:call-template>
			<xsl:value-of select="$sh.endl" />
		</xsl:if>
		<xsl:call-template name="sh.for">
			<xsl:with-param name="condition">
				<xsl:value-of select="normalize-space($elementVariableName)" />
				<xsl:text> in </xsl:text>
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name" select="$name" />
					<xsl:with-param name="index" select="'@'" />
					<xsl:with-param name="quoted" select="true()" />
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="do" select="$do" />
		</xsl:call-template>
	</xsl:template>

	<!-- UNIX shell function definition (not compatible with all shells) -->
	<xsl:template name="sh.functionDefinition">
		<!-- Function name -->
		<xsl:param name="name" />
		<!-- Function body -->
		<xsl:param name="content" />
		<!-- Indicates if the function body have to be indented -->
		<xsl:param name="indent" select="true()" />
		<!-- UNIX shell interpreter type -->
		<xsl:param name="interpreter" select="'sh'" />

		<xsl:if test="$interpreter = 'ksh'">
			<xsl:text>function </xsl:text>
		</xsl:if>
		<xsl:value-of select="normalize-space($name)" />
		<xsl:if test="not($interpreter = 'ksh')">
			<xsl:text>()</xsl:text>
		</xsl:if>
		<xsl:value-of select="$sh.endl" />
		<xsl:text>{</xsl:text>
		<xsl:call-template name="sh.block">
			<xsl:with-param name="content" select="$content" />
			<xsl:with-param name="indent" select="$indent" />
		</xsl:call-template>
		<xsl:text>}</xsl:text>
		<xsl:value-of select="$sh.endl" />
	</xsl:template>

	<!-- While statement -->
	<xsl:template name="sh.while">
		<!-- Condition -->
		<xsl:param name="condition" />
		<!-- Loop code -->
		<xsl:param name="do" />
		<!-- -->
		<xsl:param name="indent" select="true()" />

		<xsl:text>while </xsl:text>
		<xsl:value-of select="normalize-space($condition)" />
		<xsl:value-of select="$sh.endl" />
		<xsl:text>do</xsl:text>
		<xsl:call-template name="sh.block">
			<xsl:with-param name="indent" select="$indent" />
			<xsl:with-param name="content">
				<xsl:value-of select="$do" />
			</xsl:with-param>
		</xsl:call-template>
		<xsl:text>done</xsl:text>
	</xsl:template>

	<!-- For statement -->
	<xsl:template name="sh.for">
		<!-- -->
		<xsl:param name="condition" />

		<xsl:param name="do" />
		<xsl:param name="indent" select="true()" />

		<xsl:text>for </xsl:text>
		<xsl:value-of select="normalize-space($condition)" />
		<xsl:value-of select="$sh.endl" />
		<xsl:text>do</xsl:text>
		<xsl:call-template name="sh.block">
			<xsl:with-param name="indent" select="$indent" />
			<xsl:with-param name="content">
				<xsl:value-of select="$do" />
			</xsl:with-param>
		</xsl:call-template>
		<xsl:text>done</xsl:text>
	</xsl:template>

	<!-- for (i=start;i<stop;i++) -->
	<xsl:template name="sh.incrementalFor">
		<xsl:param name="variable">
			<xsl:text>i</xsl:text>
		</xsl:param>
		<xsl:param name="init" select="0" />
		<xsl:param name="operator" select="'&lt;'" />
		<xsl:param name="limit" />
		<xsl:param name="increment" select="1" />
		<xsl:param name="do" />
		<xsl:param name="indent" select="true()" />

		<xsl:call-template name="sh.for">
			<xsl:with-param name="indent" select="$indent" />

			<xsl:with-param name="condition">
				<xsl:text>((</xsl:text>
				<xsl:value-of select="normalize-space($variable)" />
				<xsl:text>=</xsl:text>
				<xsl:value-of select="normalize-space($init)" />
				<xsl:text>;</xsl:text>
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name" select="$variable" />
				</xsl:call-template>
				<xsl:value-of select="normalize-space($operator)" />
				<xsl:value-of select="normalize-space($limit)" />
				<xsl:text>;</xsl:text>
				<xsl:value-of select="normalize-space($variable)" />
				<xsl:choose>
					<xsl:when test="$increment = 1">
						<xsl:text>++</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>=$(expr </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$variable" />
						</xsl:call-template>
						<xsl:text> + </xsl:text>
						<xsl:value-of select="normalize-space($increment)" />
						<xsl:text>))</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>))</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="do" select="$do" />
		</xsl:call-template>
	</xsl:template>

	<!-- IF statement -->
	<xsl:template name="sh.if">
		<!-- Condition -->
		<xsl:param name="condition" />
		<!-- Code to execute if the condition is true -->
		<xsl:param name="then" />
		<!-- Code to execute if the condition is false -->
		<xsl:param name="else" />
		<!-- Indent 'then' and 'else' blocks -->
		<xsl:param name="indent" select="true()" />
		<!-- When possible, use the short form [ {condition} ] && {then} -->
		<xsl:param name="shortForm" select="true()" />

		<xsl:variable name="ncond" select="normalize-space($condition)" />
		<xsl:variable name="thenLength" select="string-length($then)" />
		<xsl:variable name="elseLength" select="string-length($else)" />

		<xsl:if test="string-length($ncond) &gt; 0">
			<xsl:variable name="simpleCondition" select="not (contains($ncond, $sh.endl) or contains($ncond, '&amp;&amp;') or contains($ncond, '||'))" />
			<xsl:choose>
				<xsl:when test="$thenLength &gt; 0">
					<xsl:variable name="hasElse" select="$else and ($elseLength &gt; 0)" />
					<xsl:variable name="simpleThen" select="not (contains($then, $sh.endl) or contains($then, '&amp;&amp;') or contains($then, '||'))" />
					<xsl:choose>
						<xsl:when test="$shortForm and not($hasElse) and $simpleThen and $simpleCondition">
							<xsl:value-of select="$ncond" />
							<xsl:text> &amp;&amp; </xsl:text>
							<xsl:value-of select="$then" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>if </xsl:text>
							<xsl:value-of select="$ncond" />
							<xsl:value-of select="$sh.endl" />
							<xsl:text>then</xsl:text>
							<xsl:call-template name="sh.block">
								<xsl:with-param name="indent" select="$indent" />
								<xsl:with-param name="content" select="$then" />
							</xsl:call-template>
							<xsl:if test="$hasElse">
								<xsl:text>else</xsl:text>
								<xsl:call-template name="sh.block">
									<xsl:with-param name="indent" select="$indent" />
									<xsl:with-param name="content" select="$else" />
								</xsl:call-template>
							</xsl:if>
							<xsl:text>fi</xsl:text>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:when>
				<xsl:when test="$elseLength &gt; 0">
					<xsl:variable name="simpleElse" select="not (contains($else, $sh.endl) or contains($else, '&amp;&amp;') or contains($else, '||'))" />

					<xsl:choose>
						<xsl:when test="$shortForm and $simpleElse and $simpleCondition">
							<xsl:value-of select="$ncond" />
							<xsl:text> || </xsl:text>
							<xsl:value-of select="$else" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>if </xsl:text>
							<xsl:text>! (</xsl:text>
							<xsl:value-of select="$ncond" />
							<xsl:text>)</xsl:text>
							<xsl:value-of select="$sh.endl" />
							<xsl:text>then</xsl:text>
							<xsl:call-template name="sh.block">
								<xsl:with-param name="indent" select="$indent" />
								<xsl:with-param name="content" select="$else" />
							</xsl:call-template>
							<xsl:text>fi</xsl:text>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:when>
			</xsl:choose>
			<xsl:value-of select="$sh.endl" />
		</xsl:if>
	</xsl:template>

	<!-- CASE statement -->
	<xsl:template name="sh.case">
		<!-- Case variable name -->
		<xsl:param name="case" />
		<!-- Case body -->
		<xsl:param name="in" />
		<xsl:param name="indent" select="true()" />

		<xsl:text>case "</xsl:text>
		<xsl:value-of select="$case" />
		<xsl:text>" in</xsl:text>
		<xsl:value-of select="$sh.endl" />
		<xsl:value-of select="$in" />
		<xsl:value-of select="$sh.endl" />
		<xsl:text>esac</xsl:text>
	</xsl:template>

	<!-- -->
	<xsl:template name="sh.caseblock">
		<xsl:param name="case" />
		<xsl:param name="content" />
		<xsl:param name="indent" select="true()" />

		<xsl:value-of select="$case" />
		<xsl:text>)</xsl:text>
		<xsl:call-template name="sh.block">
			<xsl:with-param name="indent" select="$indent" />
			<xsl:with-param name="content">
				<xsl:value-of select="$content" />
				<xsl:value-of select="$sh.endl" />
				<xsl:text>;;</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- Escape a string literal -->
	<xsl:template name="sh.escapeLiteral">
		<xsl:param name="value" />
		<!-- Value to escape. Assumes the given parameter does not already contains any escaped character -->
		<xsl:param name="quoteChar" select='"&apos;"' />
		<!-- Enclosing quotes character -->
		<xsl:param name="evaluate" select="false()" />
		<!-- When the quote character is the double quote, the '$' character will be evaluated.
			This parameter allow to disable this behavior -->

		<xsl:choose>
			<xsl:when test="$quoteChar = '&quot;'">
				<!-- Backslash and '"' have to be escaped -->
				<xsl:choose>
					<xsl:when test="not($evaluate)">
						<!-- '$' have to be escaped -->
						<xsl:call-template name="str.replaceAll">
							<xsl:with-param name="replace" select="'$'" />
							<xsl:with-param name="by" select="'\$'" />
							<xsl:with-param name="text">
								<xsl:call-template name="str.replaceAll">
									<xsl:with-param name="replace" select='$quoteChar' />
									<xsl:with-param name="by" select="concat('\', $quoteChar)" />
									<xsl:with-param name="text">
										<xsl:call-template name="str.replaceAll">
											<xsl:with-param name="replace" select="'\'" />
											<xsl:with-param name="by" select="'\\'" />
											<xsl:with-param name="text" select="$value" />
										</xsl:call-template>
									</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<!-- Don't escape '$' -->
						<xsl:call-template name="str.replaceAll">
							<xsl:with-param name="replace" select='$quoteChar' />
							<xsl:with-param name="by" select="concat('\', $quoteChar)" />
							<xsl:with-param name="text">
								<xsl:call-template name="str.replaceAll">
									<xsl:with-param name="replace" select="'\'" />
									<xsl:with-param name="by" select="'\\'" />
									<xsl:with-param name="text" select="$value" />
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test='$quoteChar = "&apos;"'>
				<!-- Escape "'" using quotation switching -->
				<xsl:call-template name="str.replaceAll">
					<xsl:with-param name="replace" select='$quoteChar' />
					<xsl:with-param name="by">
						<xsl:value-of select='"&apos;"' />
						<xsl:value-of select="'&quot;'" />
						<xsl:value-of select='"&apos;"' />
						<xsl:value-of select="'&quot;'" />
						<xsl:value-of select='"&apos;"' />
					</xsl:with-param>
					<xsl:with-param name="text" select="$value" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$value" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Code chunks -->

	<!-- 1>/dev/null 2>&1 -->
	<xsl:template name="sh.chunk.nullRedirection">
		<xsl:text>1&gt;/dev/null 2&gt;&amp;1</xsl:text>
	</xsl:template>

	<!-- Check if a value exists in array elements. -->
	<xsl:template name="sh.chunk.arrayValueExists">
		<!-- Array variable name -->
		<xsl:param name="name" />
		<!-- Value to check -->
		<xsl:param name="value" />
		<!-- UNIX shell interpreter type -->
		<xsl:param name="interpreter" select="'sh'" />
		<!-- Declare temporary variable as local variable -->
		<xsl:param name="declareLocal" select='false()' />
		<!-- What to do if value exists -->
		<xsl:param name="onExists" select="'return 0'" />
		<!-- What to do if value does not exists -->
		<xsl:param name="otherwise" select="'return 1'" />

		<xsl:variable name="elementVariableName" select="'_e'" />

		<xsl:call-template name="sh.arrayForEach">
			<xsl:with-param name="name" select="$name" />
			<xsl:with-param name="elementVariableName" select="$elementVariableName" />
			<xsl:with-param name="interpreter" select="$interpreter" />
			<xsl:with-param name="declareLocal" select="$declareLocal" />
			<xsl:with-param name="do">
				<xsl:call-template name="sh.if">
					<xsl:with-param name="condition">
						<xsl:text>[ </xsl:text>
						<xsl:call-template name="sh.var">
							<xsl:with-param name="name" select="$elementVariableName" />
							<xsl:with-param name="quoted" select="true()" />
						</xsl:call-template>
						<xsl:text> = </xsl:text>
						<xsl:value-of select="$value" />
						<xsl:text> ]</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="then" select="$onExists" />
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:if test="string-length($otherwise) &gt; 0">
			<xsl:value-of select="$sh.endl" />
			<xsl:value-of select="$otherwise" />
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2018 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- PHP language elements -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:import href="base.xsl" />
	<xsl:import href="../strings.xsl" />

	<xsl:variable name="php.open" select="'&lt;?php'" />
	<xsl:variable name="php.close" select="'?&gt;'" />

	<!-- PHP comment blcck -->
	<xsl:template name="php.comment">
		<xsl:param name="content" select="." />
		<xsl:call-template name="code.comment">
			<xsl:with-param name="marker">
				<xsl:text>// </xsl:text>
			</xsl:with-param>
			<xsl:with-param name="content" select="$content" />
		</xsl:call-template>
	</xsl:template>

	<!-- Escape a string literal -->
	<xsl:template name="php.escapeLiteral">
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
				<!-- Escape "'" -->
				<xsl:call-template name="str.replaceAll">
					<xsl:with-param name="replace" select='$quoteChar' />
					<xsl:with-param name="by" select="concat('\', $quoteChar)" />
					<xsl:with-param name="text" select="$value" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$value" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- PHP code block -->
	<xsl:template name="php.block">
		<xsl:param name="indent" select="true()" />
		<xsl:param name="content" />
		<xsl:choose>
			<xsl:when test="$content">
				<xsl:choose>
					<xsl:when test="$indent">
						<xsl:call-template name="code.block">
							<xsl:with-param name="content" select="$content" />
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$str.endl" />
						<xsl:value-of select="$content" />
						<xsl:value-of select="$str.endl" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$str.endl" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="php.callblock">
		<xsl:param name="name" />
		<xsl:param name="context" />
		<xsl:param name="content" />
		<xsl:param name="indent" select="true()" />

		<xsl:if test="$name">
			<xsl:value-of select="normalize-space($name)" />
		</xsl:if>
		<xsl:text>(</xsl:text>
		<xsl:value-of select="$context" />
		<xsl:text>)</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:if test="$content">
			<xsl:text>{</xsl:text>
			<xsl:call-template name="php.block">
				<xsl:with-param name="content" select="$content" />
				<xsl:with-param name="indent" select="$indent" />
			</xsl:call-template>
			<xsl:text>}</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>
	</xsl:template>

	<!-- PHP function definition -->
	<xsl:template name="php.function">
		<xsl:param name="name" />
		<xsl:param name="args" />
		<xsl:param name="content" />
		<xsl:param name="indent" select="true()" />

		<xsl:text>function </xsl:text>
		<xsl:call-template name="php.callblock">
			<xsl:with-param name="name" select="$name" />
			<xsl:with-param name="context" select="normalize-space($args)" />
			<xsl:with-param name="content" select="$content" />
			<xsl:with-param name="indent" select="$indent" />
		</xsl:call-template>
	</xsl:template>

	<!-- PHP class method definition -->
	<xsl:template name="php.method">
		<xsl:param name="name" />
		<xsl:param name="args" />
		<!-- Method visibility ('public', 'protected' or 'private') -->
		<xsl:param name="visibility" select="'public'" />
		<!-- Method type ('abstract', 'interface' or nothing).
			If 'abstract' or 'interface' is set, the method in declared without body.
		-->
		<xsl:param name="type" />
		<xsl:param name="static" select="false()" />
		<xsl:param name="content" />
		<xsl:param name="indent" select="true()" />

		<xsl:if test="$type != 'interface'">
			<xsl:value-of select="normalize-space($visibility)" />
			<xsl:text> </xsl:text>
		</xsl:if>

		<xsl:if test="$type = 'abstract'">
			<xsl:text>abstract </xsl:text>
		</xsl:if>

		<xsl:if test="$static">
			<xsl:text>static </xsl:text>
		</xsl:if>

		<xsl:choose>
			<xsl:when test="($type = 'abstract') or ($type = 'interface')">
				<xsl:text>function(</xsl:text>
				<xsl:value-of select="$args" />
				<xsl:text>);</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>function </xsl:text>
				<xsl:call-template name="php.callblock">
					<xsl:with-param name="name" select="$name" />
					<xsl:with-param name="context" select="normalize-space($args)" />
					<xsl:with-param name="content" select="$content" />
					<xsl:with-param name="indent" select="$indent" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- PHP Interface and class definition -->
	<xsl:template name="php.class">
		<xsl:param name="name" />
		<!-- Class type ('class', 'abstract' or 'interface') -->
		<xsl:param name="type" select="'class'" />
		<xsl:param name="extends" />
		<xsl:param name="implements" />
		<xsl:param name="content" />
		<xsl:param name="indent" select="true()" />

		<xsl:choose>
			<xsl:when test="$type = 'interface'">
				<xsl:text>interface </xsl:text>
			</xsl:when>
			<xsl:when test="$type = 'abstract'">
				<xsl:text>abstract class </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>class </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="normalize-space($name)" />
		<xsl:if test="$extends">
			<xsl:text> extends </xsl:text>
			<xsl:value-of select="normalize-space($extends)" />
		</xsl:if>
		<xsl:if test="$implements">
			<xsl:text> implements </xsl:text>
			<xsl:value-of select="normalize-space($implements)" />
		</xsl:if>

		<xsl:value-of select="$str.endl" />
		<xsl:text>{</xsl:text>
		<xsl:call-template name="php.block">
			<xsl:with-param name="content" select="$content" />
			<xsl:with-param name="indent" select="$indent" />
		</xsl:call-template>
		<xsl:text>}</xsl:text>
		<xsl:value-of select="$str.endl" />
	</xsl:template>

	<!-- PHP namespace -->
	<xsl:template name="php.namespace">
		<!-- Namespace name. If empty, this template has no effect -->
		<xsl:param name="name" />
		<!-- Namespace code -->
		<xsl:param name="content" />
		<!-- Use curly brackets syntax or ';' -->
		<xsl:param name="brackets" select="true()" />
		<!-- Force declaration even if namespace name is empty -->
		<xsl:param name="forceDeclaration" select="false()" />
		<xsl:param name="indent" select="false()" />

		<xsl:variable name="nsname">
			<xsl:choose>
				<xsl:when test="normalize-space($name) = '\'" />
				<xsl:otherwise>
					<xsl:value-of select="normalize-space($name)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$forceDeclaration or (string-length($nsname) &gt; 0)">
				<xsl:text>namespace </xsl:text>
				<xsl:value-of select="$nsname" />
				<xsl:choose>
					<xsl:when test="not($brackets)">
						<text>;</text>
						<xsl:value-of select="$str.endl" />
						<xsl:value-of select="$content" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$str.endl" />
						<xsl:text>{</xsl:text>
						<xsl:call-template name="php.block">
							<xsl:with-param name="content" select="$content" />
							<xsl:with-param name="indent" select="$indent" />
						</xsl:call-template>
						<xsl:text>}</xsl:text>
						<xsl:call-template name="php.comment">
							<xsl:with-param name="content" select="concat('namespace ', normalize-space($name))" />
						</xsl:call-template>
						<xsl:value-of select="$str.endl" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$content" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
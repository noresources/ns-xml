<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Python language elements -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:import href="base.xsl" />

	<!-- Python comment -->
	<xsl:template name="python.comment">
		<!-- Comment content -->
		<xsl:param name="content" />
		<!-- Indicates if the comment should be displayed on one line -->
		<xsl:param name="inline" select="false()" />

		<xsl:choose>
			<xsl:when test="$inline = true()">
				<xsl:text>"""</xsl:text>
				<xsl:value-of select="translate(normalize-space($content),'&#10;&#13;', '  ')" />
				<xsl:text>"""</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="code.comment">
					<xsl:with-param name="beginMarker" select="'&quot;&quot;&quot;'" />
					<xsl:with-param name="endMarker" select="'&quot;&quot;&quot;'" />
					<xsl:with-param name="marker" select="''" />
					<xsl:with-param name="content" select="$content" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Python code block -->
	<xsl:template name="python.block">
		<!-- Block content -->
		<xsl:param name="content" />
		<!-- Add a linebreak before the block -->
		<xsl:param name="addInitialEndl" select="true()" />
		<!-- Add a linebreak after the block -->
		<xsl:param name="addFinalEndl" select="false()" />

		<xsl:variable name="statements">
			<xsl:choose>
				<xsl:when test="string-length($content) &gt; 0">
					<xsl:value-of select="$content" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>pass</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:call-template name="code.block">
			<xsl:with-param name="content" select="$statements" />
			<xsl:with-param name="indent" select="true()" />
			<xsl:with-param name="addInitialEndl" select="true()" />
			<xsl:with-param name="addFinalEndl" select="true()" />
		</xsl:call-template>

		<xsl:if test="$addFinalEndl">
			<xsl:value-of select="$str.endl" />
		</xsl:if>
	</xsl:template>

	<xsl:template name="python.validIdentifierName">
		<xsl:param name="name" />

		<xsl:variable name="tname">
			<xsl:call-template name="cede.validIdentifierName">
				<xsl:with-param name="name" select="$name" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<!-- @todo other Python keywords -->
			<xsl:when test="($tname = 'def') or ($tname = 'class') or ($tname = 'while') or ($tname = 'if') or ($tname = 'else') or ($tname = 'elif')">
				<xsl:text>_</xsl:text>
				<xsl:value-of select="$tname" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$tname" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Declare a Python method -->
	<xsl:template name="python.method">
		<!-- Class name -->
		<xsl:param name="name" />

		<!-- Method args (without the first 'self' argueent) -->
		<xsl:param name="args" />

		<xsl:param name="classMethod" select="false()" />

		<!-- Class statements -->
		<xsl:param name="content" />

		<xsl:if test="$classMethod">
			<xsl:text>@classmethod</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>

		<xsl:text>def </xsl:text>
		<xsl:value-of select="normalize-space($name)" />
		<xsl:text>(</xsl:text>
		<xsl:choose>
			<xsl:when test="$classMethod">
				<xsl:text>cls</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>self</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>)</xsl:text>
		<xsl:text>:</xsl:text>
		<xsl:call-template name="python.block">
			<xsl:with-param name="content" select="$content" />
		</xsl:call-template>
	</xsl:template>

	<!-- Declare a Python class -->
	<xsl:template name="python.class">
		<!-- Class name -->
		<xsl:param name="name" />
		<!-- Class parent(s) -->
		<xsl:param name="parents" select="'object'" />
		<!-- Class statements -->
		<xsl:param name="content" />

		<xsl:variable name="inherits" select="normalize-space($parents)" />

		<xsl:text>class </xsl:text>
		<xsl:value-of select="normalize-space($name)" />
		<xsl:if test="string-length($inherits) &gt; 0">
			<xsl:text>(</xsl:text>
			<xsl:value-of select="$inherits" />
			<xsl:text>)</xsl:text>
		</xsl:if>
		<xsl:text>:</xsl:text>
		<xsl:call-template name="python.block">
			<xsl:with-param name="content" select="$content" />
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>

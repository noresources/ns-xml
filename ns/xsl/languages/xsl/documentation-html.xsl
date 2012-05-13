<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->

<!-- Generate HTML documentation for a given XSLT style sheet -->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:import href="../../strings.xsl" />

	<xsl:output method="html" indent="yes" encoding="utf-8" />

	<xsl:param name="xsl.doc.html.fileName" />
	<xsl:param name="xsl.doc.html.stylesheetPath" />

	<xsl:param name="xsl.doc.string.details">
		<text>Details</text>
	</xsl:param>

	<xsl:param name="xsl.doc.string.default">
		<text>Default value</text>
	</xsl:param>

	<xsl:template name="xsl.doc.elementId">
		<xsl:param name="node" select="." />
		<xsl:choose>
			<xsl:when test="$node/self::xsl:template">
				<xsl:value-of select="$node/@name" />
			</xsl:when>
			<xsl:when test="$node/self::xsl:param">
				<xsl:call-template name="xsl.doc.elementId">
					<xsl:with-param name="node" select="$node/.." />
				</xsl:call-template>
				<xsl:text>_</xsl:text>
				<xsl:value-of select="normalize-space($node/@name)" />
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="xsl.doc.html.activePathLink">
		<xsl:param name="path" />
		<xsl:param name="level" select="1" />
		
		<xsl:element name="a">
			<xsl:attribute name="href">
				<xsl:text>./</xsl:text>
				<xsl:call-template name="str.repeat">
					<xsl:with-param name="text" select="'../'" />
					<xsl:with-param name="iterations" select="$level - 1" />
				</xsl:call-template>
			</xsl:attribute>
			<xsl:value-of select="$path" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="xsl.doc.html.activePath">
		<xsl:param name="path" />
		<xsl:param name="level" select="1" />
		
		<xsl:choose>
			<xsl:when test="contains($path, '/')">
				<xsl:call-template name="xsl.doc.html.activePath">
					<xsl:with-param name="path">
						<xsl:call-template name="str.substringBeforeLast">
							<xsl:with-param name="text" select="$path" />
							<xsl:with-param name="delimiter" select="'/'" />
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="level" select="$level + 1" />
				</xsl:call-template>
				
				<xsl:call-template name="xsl.doc.html.activePathLink">
					<xsl:with-param name="path">
						<xsl:call-template name="str.substringAfterLast">
							<xsl:with-param name="text" select="$path" />
							<xsl:with-param name="delimiter" select="'/'" />
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="level" select="$level" />
				</xsl:call-template>						
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="xsl.doc.html.activePathLink">
					<xsl:with-param name="path" select="$path" />
					<xsl:with-param name="level" select="$level" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		
		<xsl:text> / </xsl:text>
	</xsl:template>
	
	<xsl:template name="xsl.doc.html.activeTitle">
		<xsl:param name="title" />
		
		<xsl:variable name="depth">
			<xsl:call-template name="str.count">
				<xsl:with-param name="text" select="$title" />
				<xsl:with-param name="substring" select="'/'" />
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:call-template name="xsl.doc.html.activePathLink">
			<xsl:with-param name="path" select="'&lt;'" />
			<xsl:with-param name="level" select="$depth + 1" />
		</xsl:call-template>
		<xsl:text> / </xsl:text>
				
		<xsl:call-template name="xsl.doc.html.activePath">
			<xsl:with-param name="path">
				<xsl:call-template name="str.substringBeforeLast">
					<xsl:with-param name="text" select="$title" />
					<xsl:with-param name="delimiter" select="'/'" />
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>				
		
		<xsl:call-template name="str.substringAfterLast">
			<xsl:with-param name="text" select="$title" />
			<xsl:with-param name="delimiter" select="'/'" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="xsl.doc.html.comment">
		<xsl:param name="node" select="." />
		<xsl:param name="class" />

		<xsl:variable name="comment">
			<xsl:if test="$node/preceding-sibling::comment()">
				<xsl:value-of select="normalize-space($node/preceding-sibling::comment()[position() = 1])" />
			</xsl:if>
		</xsl:variable>

		<xsl:if test="string-length($comment)">
			<xsl:choose>
				<xsl:when test="$class">
					<xsl:element name="span">
						<xsl:attribute name="class">
					<xsl:value-of select="normalize-space($class)" />
				</xsl:attribute>
						<xsl:value-of select="$comment" />
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$comment" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template name="xsl.doc.html.templateParamDeclaration">
		<xsl:param name="node" select="." />
		<xsl:element name="span">
			<xsl:attribute name="class">xsl-templateparam-name</xsl:attribute>
			<xsl:element name="a">
				<xsl:attribute name="href">
					<xsl:text>#</xsl:text>
					<xsl:call-template name="xsl.doc.elementId" />
				</xsl:attribute>
				<xsl:value-of select="normalize-space($node/@name)" />
			</xsl:element>
		</xsl:element>
		<xsl:if test="$node/@select">
			<xsl:text>="</xsl:text>
			<xsl:element name="span">
				<xsl:attribute name="class">xsl-templateparam-default</xsl:attribute>
				<xsl:value-of select="$node/@select" />
			</xsl:element>
			<xsl:text>"</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template name="xsl.doc.html.templateDeclaration">
		<xsl:param name="node" select="." />
		<xsl:element name="div">
			<xsl:attribute name="class">xsl-template-decl</xsl:attribute>
			<xsl:element name="a">
				<xsl:attribute name="class">
					<xsl:text>xsl-template-name</xsl:text>
				</xsl:attribute>
				<xsl:attribute name="href">
					<xsl:text>#</xsl:text>
					<xsl:call-template name="xsl.doc.elementId" />
				</xsl:attribute>
				<xsl:value-of select="normalize-space($node/@name)" />
			</xsl:element>

			<xsl:text>(</xsl:text>
			<xsl:for-each select="./xsl:param">
				<xsl:call-template name="xsl.doc.html.templateParamDeclaration" />
				<xsl:if test="position() != last()">
					<xsl:text>, </xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:text>)</xsl:text>
		</xsl:element>
	</xsl:template>

	<xsl:template name="xsl.doc.html.templateParamDetails">
		<xsl:param name="node" select="." />
		<xsl:element name="span">
			<xsl:attribute name="class">xsl-templateparam-name</xsl:attribute>
			<xsl:element name="a">
				<xsl:attribute name="name">
					<xsl:call-template name="xsl.doc.elementId" />
				</xsl:attribute>
				<xsl:value-of select="$node/@name" />
			</xsl:element>
		</xsl:element>
		<xsl:variable name="comment">
			<xsl:call-template name="xsl.doc.html.comment">
				<xsl:with-param name="class">
					xsl-templateparam-comment
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="default" select="$node/@select" />

		<xsl:if test="(string-length($comment) + string-length($default)) > 0">
			<xsl:element name="blockquote">
				<xsl:if test="string-length($comment)">
					<xsl:value-of select="$comment" />
					<xsl:element name="br" />
				</xsl:if>
				<xsl:if test="string-length($default)">
					<xsl:value-of select="normalize-space($xsl.doc.string.default)" />
					<xsl:text>: </xsl:text>
					<xsl:element name="span">
						<xsl:attribute name="class">xsl-templateparam-default</xsl:attribute>
						<xsl:value-of select="$node/@select" />
					</xsl:element>
				</xsl:if>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template name="xsl.doc.html.templateDetails">
		<xsl:param name="node" select="." />

		<xsl:variable name="comment">
			<xsl:call-template name="xsl.doc.html.comment">
				<xsl:with-param name="class">
					<xsl:text>xsl-template-subtitle</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:element name="div">
			<xsl:attribute name="class">xsl-template-def</xsl:attribute>
			<xsl:element name="div">
				<xsl:attribute name="class">xsl-template-def-title</xsl:attribute>	
				<xsl:element name="a">
					<xsl:attribute name="name">
						<xsl:call-template name="xsl.doc.elementId" />
					</xsl:attribute>
				</xsl:element>
				<xsl:call-template name="xsl.doc.html.templateDeclaration" />
			</xsl:element>
			
			<xsl:element name="div">
				<xsl:attribute name="class">xsl-template-def-details</xsl:attribute>
				<xsl:if test="string-length($comment)">
					<xsl:element name="br" />
					<xsl:value-of select="$comment" />
				</xsl:if>
				<xsl:if test="count(./xsl:param)">
					<xsl:element name="ol">
						<xsl:for-each select="./xsl:param">
							<xsl:element name="li">
								<xsl:call-template name="xsl.doc.html.templateParamDetails" />
							</xsl:element>
						</xsl:for-each>
					</xsl:element>
				</xsl:if>
			</xsl:element>

		</xsl:element>
	</xsl:template>

	<!-- Stylesheet -->
	<xsl:template match="/xsl:stylesheet">
		<xsl:element name="h1">
			<xsl:call-template name="xsl.doc.html.activeTitle">
				<xsl:with-param name="title" select="$xsl.doc.html.fileName" />
			</xsl:call-template>
			<xsl:call-template name="xsl.doc.html.comment">
				<xsl:with-param name="class">
					<xsl:text>xsl-stylesheet-subtitle</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:element>

		<!-- TOC -->
		<xsl:element name="ul">
			<xsl:for-each select="./xsl:template[@name]">
				<xsl:element name="li">
					<xsl:call-template name="xsl.doc.html.templateDeclaration" />
				</xsl:element>
			</xsl:for-each>
		</xsl:element>

		<xsl:element name="hr" />

		<xsl:element name="div">
			<xsl:attribute name="class">xsl-templates-details</xsl:attribute>
			<xsl:value-of select="$xsl.doc.string.details" />
		</xsl:element>

		<!-- Detailed documentation -->
		<xsl:for-each select="./xsl:template[@name]">
			<xsl:call-template name="xsl.doc.html.templateDetails" />
		</xsl:for-each>

	</xsl:template>

	<!-- Root -->
	<xsl:template match="/">
		<xsl:variable name="comment">
			<xsl:call-template name="xsl.doc.html.comment">
				<xsl:with-param name="node" select="./xsl:stylesheet" />
			</xsl:call-template>
		</xsl:variable>
					
		<xsl:element name="html">
			<xsl:element name="head">
				<xsl:element name="title">
					<xsl:if test="$xsl.doc.html.fileName">
						<xsl:value-of select="$xsl.doc.html.fileName" />
						<xsl:if test="string-length($comment)">
							<xsl:text> - </xsl:text>
						</xsl:if>
					</xsl:if>
					<xsl:if test="string-length($comment)">
						<xsl:value-of select="$comment" />
					</xsl:if>
				</xsl:element>
				<xsl:if test="$xsl.doc.html.stylesheetPath">
					<xsl:element name="link">
						<xsl:attribute name="type">
						<xsl:text>text/css</xsl:text>
					</xsl:attribute>
						<xsl:attribute name="rel">
						<xsl:text>stylesheet</xsl:text>
					</xsl:attribute>
						<xsl:attribute name="href">
						<xsl:value-of select="normalize-space($xsl.doc.html.stylesheetPath)" />
					</xsl:attribute>
					</xsl:element>
				</xsl:if>
			</xsl:element>
			<xsl:element name="body">
				<xsl:apply-templates />
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
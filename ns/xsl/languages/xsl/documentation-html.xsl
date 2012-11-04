<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the BSD License, see LICENSE -->

<!-- Generate HTML documentation for a given XSLT style sheet -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:import href="../../strings.xsl"/>
	<xsl:output method="html" indent="yes" encoding="utf-8"/>
	<!-- Directory index path type ('per-folder', 'root', 'none', 'auto') -->
	<xsl:param name="xsl.doc.html.directoryIndexPathMode" select="'none'"/>
	<!-- Path of the directory index page -->
	<xsl:param name="xsl.doc.html.directoryIndexPath"/>
	<!-- A file path relative to documentation root. Used to create automatic directory index links.
	This parameters has no meaning when $xsl.doc.html.directoryIndexPath is set to 'none' -->
	<xsl:param name="xsl.doc.html.fileName"/>
	<!-- If true, generates a full HTML page with html tag containing head and body. 
	Otherwise, the documentation will be wrapped in a div -->
	<xsl:param name="xsl.doc.html.fullHtmlPage" select="true()"/>
	<!-- Indicates if the stylesheet abstract have to be displayed -->
	<xsl:param name="xsl.doc.html.stylesheetAbstract" select="false()"/>
	<!-- Relative path to the CSS style sheet to include. 
	Require $xsl.doc.html.fullHtmlPage to be true() -->
	<xsl:param name="xsl.doc.html.cssPath"/>
	<!-- Parameter list title -->
	<xsl:param name="xsl.doc.string.parameters">
		<xsl:text>Parameters</xsl:text>
	</xsl:param>
	<!-- Variable list title -->
	<xsl:param name="xsl.doc.string.variables">
		<xsl:text>Variables</xsl:text>
	</xsl:param>
	<!-- Named templates list title -->
	<xsl:param name="xsl.doc.string.templates">
		<xsl:text>Templates</xsl:text>
	</xsl:param>
	<!-- Details section title -->
	<xsl:param name="xsl.doc.string.details">
		<xsl:text>Details</xsl:text>
	</xsl:param>
	<!-- Abstract section title (table of contnet) -->
	<xsl:param name="xsl.doc.string.abstract">
		<xsl:text>Table of content</xsl:text>
	</xsl:param>
	<xsl:param name="xsl.doc.string.default">
		<text>Default value</text>
	</xsl:param>
	<!-- Generate a unique id for HTML anchor -->
	<xsl:template name="xsl.doc.elementId">
		<xsl:param name="node" select="."/>
		<xsl:choose>
			<xsl:when test="$node/self::xsl:template">
				<xsl:text>tpl_</xsl:text>
				<xsl:value-of select="$node/@name"/>
			</xsl:when>
			<xsl:when test="($node/self::xsl:param or $node/self::xsl:variable) and $node/../self::xsl:stylesheet">
				<xsl:text>prm_</xsl:text>
				<xsl:value-of select="normalize-space($node/@name)"/>
			</xsl:when>
			<xsl:when test="$node/self::xsl:param and $node/../self::xsl:template">
				<xsl:call-template name="xsl.doc.elementId">
					<xsl:with-param name="node" select="$node/.."/>
				</xsl:call-template>
				<xsl:text>_</xsl:text>
				<xsl:value-of select="normalize-space($node/@name)"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="xsl.doc.html.activePathLink">
		<xsl:param name="path"/>
		<xsl:param name="basePath"/>
		<xsl:param name="label" select="$path"/>
		<xsl:param name="level" select="1"/>
		<xsl:param name="depth" select="$level"/>
		<xsl:element name="a">
			<xsl:attribute name="rel">
				<xsl:text>l=</xsl:text>
				<xsl:value-of select="$level"/>
				<xsl:text> d=</xsl:text>
				<xsl:value-of select="$depth"/>
				<xsl:text> p=</xsl:text>
				<xsl:value-of select="$path"/>
				<xsl:text> b=</xsl:text>
				<xsl:value-of select="$basePath"/>
			</xsl:attribute>
			<xsl:attribute name="href">
				<xsl:choose>
					<xsl:when test="($xsl.doc.html.directoryIndexPathMode = 'root')">
						<xsl:call-template name="str.repeat">
							<xsl:with-param name="text" select="'../'"/>
							<xsl:with-param name="iterations" select="$depth"/>
						</xsl:call-template>
						<xsl:value-of select="$xsl.doc.html.directoryIndexPath"/>
						<xsl:text>?path=</xsl:text>
						<xsl:call-template name="str.asciiToHex">
							<xsl:with-param name="text">
								<xsl:choose>
									<xsl:when test="$path = '.'">
										<xsl:value-of select="$path"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$basePath"/>
										<xsl:text>/</xsl:text>
										<xsl:value-of select="$path"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
							<xsl:with-param name="prefix" select="'%'"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="($xsl.doc.html.directoryIndexPathMode = 'auto') or ($xsl.doc.html.directoryIndexPathMode = 'per-folder')">
						<xsl:text>./</xsl:text>
						<xsl:call-template name="str.repeat">
							<xsl:with-param name="text" select="'../'"/>
							<xsl:with-param name="iterations" select="$level - 1"/>
						</xsl:call-template>
						<xsl:if test="$xsl.doc.html.directoryIndexPathMode = 'per-folder'">
							<xsl:value-of select="$xsl.doc.html.directoryIndexPath"/>
						</xsl:if>
					</xsl:when>
				</xsl:choose>
			</xsl:attribute>
			<xsl:value-of select="$label"/>
		</xsl:element>
	</xsl:template>

	<xsl:template name="xsl.doc.html.activePath">
		<xsl:param name="path"/>
		<xsl:param name="level" select="1"/>
		<xsl:param name="depth" select="$level"/>
		<xsl:choose>
			<xsl:when test="contains($path, '/')">
				<!-- Recurisvely display (parent folder display) -->
				<xsl:variable name="basePath">
					<xsl:call-template name="str.substringBeforeLast">
						<xsl:with-param name="text" select="$path"/>
						<xsl:with-param name="delimiter" select="'/'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:call-template name="xsl.doc.html.activePath">
					<xsl:with-param name="path" select="$basePath"/>
					<xsl:with-param name="level" select="$level + 1"/>
					<xsl:with-param name="depth" select="$depth"/>
				</xsl:call-template>
				<xsl:call-template name="xsl.doc.html.activePathLink">
					<xsl:with-param name="basePath" select="$basePath"/>
					<xsl:with-param name="path">
						<xsl:call-template name="str.substringAfterLast">
							<xsl:with-param name="text" select="$path"/>
							<xsl:with-param name="delimiter" select="'/'"/>
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="level" select="$level"/>
					<xsl:with-param name="depth" select="$depth"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="xsl.doc.html.activePathLink">
					<xsl:with-param name="basePath" select="'.'"/>
					<xsl:with-param name="path" select="$path"/>
					<xsl:with-param name="level" select="$level"/>
					<xsl:with-param name="depth" select="$depth"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="string-length($path)">
			<xsl:text> / </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template name="xsl.doc.html.activeTitle">
		<xsl:param name="title"/>
		<xsl:variable name="depth">
			<xsl:call-template name="str.count">
				<xsl:with-param name="text" select="$title"/>
				<xsl:with-param name="substring" select="'/'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:call-template name="xsl.doc.html.activePathLink">
			<xsl:with-param name="path" select="'.'"/>
			<xsl:with-param name="basePath" select="'.'"/>
			<xsl:with-param name="label" select="'&lt;'"/>
			<xsl:with-param name="depth" select="$depth"/>
			<xsl:with-param name="level" select="($depth + 1)"/>
		</xsl:call-template>
		<xsl:text />
		<xsl:call-template name="xsl.doc.html.activePath">
			<xsl:with-param name="path">
				<xsl:call-template name="str.substringBeforeLast">
					<xsl:with-param name="text" select="$title"/>
					<xsl:with-param name="delimiter" select="'/'"/>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="level" select="1"/>
			<xsl:with-param name="depth" select="$depth"/>
		</xsl:call-template>
		<xsl:call-template name="str.substringAfterLast">
			<xsl:with-param name="text" select="$title"/>
			<xsl:with-param name="delimiter" select="'/'"/>
		</xsl:call-template>
	</xsl:template>

	<!-- Find the node documentation -->
	<xsl:template name="xsl.doc.html.comment">
		<xsl:param name="node" select="."/>
		<xsl:param name="class"/>
		<xsl:variable name="comment">
			<xsl:call-template name="str.trim">
				<xsl:with-param name="text" select="$node/preceding-sibling::node()[self::*|self::comment()][1][self::comment()]"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="string-length($comment)">
			<xsl:choose>
				<xsl:when test="$class">
					<xsl:element name="span">
						<xsl:attribute name="class">
							<xsl:value-of select="normalize-space($class)"/>
						</xsl:attribute>
						<xsl:value-of select="$comment"/>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$comment"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template name="xsl.doc.html.templateParamDeclaration">
		<xsl:param name="node" select="."/>
		<xsl:element name="span">
			<xsl:attribute name="class">xsl-templateparam-name</xsl:attribute>
			<xsl:element name="a">
				<xsl:attribute name="href">
					<xsl:text>#</xsl:text>
					<xsl:call-template name="xsl.doc.elementId"/>
				</xsl:attribute>
				<xsl:value-of select="normalize-space($node/@name)"/>
			</xsl:element>
		</xsl:element>
		<xsl:variable name="default">
			<xsl:choose>
				<xsl:when test="$node/@select">
					<xsl:value-of select="$node/@select"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space($node)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="string-length($default) &gt; 0">
			<xsl:text>="</xsl:text>
			<xsl:element name="span">
				<xsl:attribute name="class">xsl-templateparam-default</xsl:attribute>
				<xsl:value-of select="$default"/>
			</xsl:element>
			<xsl:text>"</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template name="xsl.doc.html.templateDeclaration">
		<xsl:param name="node" select="."/>
		<xsl:element name="div">
			<xsl:attribute name="class">xsl-template-decl</xsl:attribute>
			<xsl:element name="a">
				<xsl:attribute name="class">
					<xsl:text>xsl-template-name</xsl:text>
				</xsl:attribute>
				<xsl:attribute name="href">
					<xsl:text>#</xsl:text>
					<xsl:call-template name="xsl.doc.elementId"/>
				</xsl:attribute>
				<xsl:value-of select="normalize-space($node/@name)"/>
			</xsl:element>
			<xsl:text>(</xsl:text>
			<xsl:for-each select="./xsl:param">
				<xsl:call-template name="xsl.doc.html.templateParamDeclaration"/>
				<xsl:if test="position() != last()">
					<xsl:text>, </xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:text>)</xsl:text>
		</xsl:element>
	</xsl:template>

	<!-- Display a inline declaration of a stylesheet parameter -->
	<xsl:template name="xsl.doc.html.paramDeclaration">
		<!-- param node -->
		<xsl:param name="node" select="."/>
		<xsl:element name="div">
			<xsl:attribute name="class">xsl-param-decl</xsl:attribute>
			<xsl:element name="a">
				<xsl:attribute name="class">xsl-param-name</xsl:attribute>
				<xsl:attribute name="href">
					<xsl:text>#</xsl:text>
					<xsl:call-template name="xsl.doc.elementId">
						<xsl:with-param name="node" select="$node"/>
					</xsl:call-template>
				</xsl:attribute>
				<xsl:value-of select="$node/@name"/>
			</xsl:element>
			<xsl:variable name="default">
				<xsl:choose>
					<xsl:when test="$node/@select">
						<xsl:value-of select="$node/@select"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="normalize-space($node)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="string-length($default) &gt; 0">
				<xsl:text>="</xsl:text>
				<xsl:value-of select="$default"/>
				<xsl:text>"</xsl:text>
			</xsl:if>
		</xsl:element>
	</xsl:template>

	<xsl:template name="xsl.doc.html.templateParamDetails">
		<xsl:param name="node" select="."/>
		<xsl:element name="span">
			<xsl:attribute name="class">xsl-templateparam-name</xsl:attribute>
			<xsl:element name="a">
				<xsl:attribute name="name">
					<xsl:call-template name="xsl.doc.elementId"/>
				</xsl:attribute>
				<xsl:value-of select="$node/@name"/>
			</xsl:element>
		</xsl:element>
		<xsl:variable name="comment">
			<xsl:call-template name="xsl.doc.html.comment">
				<xsl:with-param name="class">
					xsl-templateparam-comment
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="default">
			<xsl:choose>
				<xsl:when test="$node/@select">
					<xsl:value-of select="$node/@select"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space($node)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="(string-length($comment) + string-length($default)) &gt; 0">
			<xsl:element name="blockquote">
				<xsl:if test="string-length($comment)">
					<xsl:value-of select="$comment"/>
					<xsl:element name="br"/>
				</xsl:if>
				<xsl:if test="string-length($default)">
					<xsl:value-of select="normalize-space($xsl.doc.string.default)"/>
					<xsl:text>: </xsl:text>
					<xsl:element name="span">
						<xsl:attribute name="class">xsl-templateparam-default</xsl:attribute>
						<xsl:value-of select="$default"/>
					</xsl:element>
				</xsl:if>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template name="xsl.doc.html.templateDetails">
		<xsl:param name="node" select="."/>
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
						<xsl:call-template name="xsl.doc.elementId"/>
					</xsl:attribute>
				</xsl:element>
				<xsl:call-template name="xsl.doc.html.templateDeclaration"/>
			</xsl:element>
			<xsl:element name="div">
				<xsl:attribute name="class">xsl-template-def-details</xsl:attribute>
				<xsl:if test="string-length($comment)">
					<xsl:element name="br"/>
					<xsl:value-of select="$comment"/>
				</xsl:if>
				<xsl:if test="count(./xsl:param)">
					<xsl:element name="ol">
						<xsl:for-each select="./xsl:param">
							<xsl:element name="li">
								<xsl:call-template name="xsl.doc.html.templateParamDetails"/>
							</xsl:element>
						</xsl:for-each>
					</xsl:element>
				</xsl:if>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template name="xsl.doc.html.paramDetails">
		<xsl:param name="node" select="."/>
		<xsl:variable name="comment">
			<xsl:call-template name="xsl.doc.html.comment">
				<xsl:with-param name="class">
					<xsl:text>xsl-param-subtitle</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:element name="div">
			<xsl:attribute name="class">xsl-param-def</xsl:attribute>
			<xsl:element name="div">
				<xsl:attribute name="class">xsl-param-def-title</xsl:attribute>
				<xsl:element name="a">
					<xsl:attribute name="name">
						<xsl:call-template name="xsl.doc.elementId"/>
					</xsl:attribute>
				</xsl:element>
				<xsl:call-template name="xsl.doc.html.paramDeclaration"/>
			</xsl:element>
			<xsl:element name="div">
				<xsl:attribute name="class">xsl-param-def-details</xsl:attribute>
				<xsl:if test="string-length($comment)">
					<xsl:element name="blockquote">
						<xsl:value-of select="$comment"/>
					</xsl:element>
				</xsl:if>
			</xsl:element>
			<xsl:variable name="default">
				<xsl:choose>
					<xsl:when test="$node/@select">
						<xsl:value-of select="$node/@select"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="normalize-space($node)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="string-length($default)">
				<xsl:element name="br"/>
				<xsl:value-of select="normalize-space($xsl.doc.string.default)"/>
				<xsl:text>: </xsl:text>
				<xsl:element name="span">
					<xsl:attribute name="class">xsl-param-default</xsl:attribute>
					<xsl:value-of select="$default"/>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>

	<!-- Stylesheet -->
	<xsl:template match="/xsl:stylesheet">
		<xsl:element name="h1">
			<xsl:if test="$xsl.doc.html.directoryIndexPathMode != 'none'">
				<xsl:call-template name="xsl.doc.html.activeTitle">
					<xsl:with-param name="title" select="$xsl.doc.html.fileName"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="$xsl.doc.html.stylesheetAbstract">
				<xsl:call-template name="xsl.doc.html.comment">
					<xsl:with-param name="class">
						<xsl:text>xsl-stylesheet-subtitle</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
		</xsl:element>
		<!-- TOC -->
		<xsl:variable name="hasContent" select="./xsl:template[@name] or ./xsl:param or ./xsl:variable"/>
		<xsl:if test="$hasContent">
			<xsl:element name="h2">
				<xsl:value-of select="$xsl.doc.string.abstract"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="./xsl:param">
			<xsl:element name="h3">
				<xsl:value-of select="normalize-space($xsl.doc.string.parameters)"/>
			</xsl:element>
			<xsl:element name="ul">
				<xsl:for-each select="./xsl:param">
					<xsl:element name="li">
						<xsl:call-template name="xsl.doc.html.paramDeclaration"/>
					</xsl:element>
				</xsl:for-each>
			</xsl:element>
		</xsl:if>
		<xsl:if test="./xsl:variable">
			<xsl:element name="h3">
				<xsl:value-of select="normalize-space($xsl.doc.string.variables)"/>
			</xsl:element>
			<xsl:element name="ul">
				<xsl:for-each select="./xsl:variable">
					<xsl:element name="li">
						<xsl:call-template name="xsl.doc.html.paramDeclaration"/>
					</xsl:element>
				</xsl:for-each>
			</xsl:element>
		</xsl:if>
		<xsl:if test="./xsl:template[@name]">
			<xsl:element name="h3">
				<xsl:value-of select="normalize-space($xsl.doc.string.templates)"/>
			</xsl:element>
			<xsl:element name="ul">
				<xsl:for-each select="./xsl:template[@name]">
					<xsl:element name="li">
						<xsl:call-template name="xsl.doc.html.templateDeclaration"/>
					</xsl:element>
				</xsl:for-each>
			</xsl:element>
		</xsl:if>
		<xsl:if test="$hasContent">
			<xsl:element name="hr"/>
			<xsl:element name="h2">
				<xsl:attribute name="class">xsl-templates-details</xsl:attribute>
				<xsl:value-of select="normalize-space($xsl.doc.string.details)"/>
			</xsl:element>
			<!-- Parameters -->
			<xsl:if test="./xsl:param">
				<xsl:element name="h3">
					<xsl:value-of select="normalize-space($xsl.doc.string.parameters)"/>
				</xsl:element>
				<xsl:for-each select="./xsl:param">
					<xsl:call-template name="xsl.doc.html.paramDetails"/>
				</xsl:for-each>
			</xsl:if>
			<!-- Variables -->
			<xsl:if test="./xsl:variable">
				<xsl:element name="h3">
					<xsl:value-of select="normalize-space($xsl.doc.string.variables)"/>
				</xsl:element>
				<xsl:for-each select="./xsl:variable">
					<xsl:call-template name="xsl.doc.html.paramDetails"/>
				</xsl:for-each>
			</xsl:if>
			<!-- Detailed documentation -->
			<xsl:if test="./xsl:template[@name]">
				<xsl:element name="h3">
					<xsl:value-of select="normalize-space($xsl.doc.string.templates)"/>
				</xsl:element>
				<xsl:for-each select="./xsl:template[@name]">
					<xsl:call-template name="xsl.doc.html.templateDetails"/>
				</xsl:for-each>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<!-- Root -->
	<xsl:template match="/">
		<xsl:comment>
			<xsl:text>xsl.doc.html.fileName: </xsl:text>
			<xsl:value-of select="$xsl.doc.html.fileName"/>
			<xsl:call-template name="endl"/>
			<xsl:text>xsl.doc.html.cssPath: </xsl:text>
			<xsl:value-of select="$xsl.doc.html.cssPath"/>
			<xsl:call-template name="endl"/>
			<xsl:text>xsl.doc.html.directoryIndexPath: </xsl:text>
			<xsl:value-of select="$xsl.doc.html.directoryIndexPath"/>
			<xsl:call-template name="endl"/>
			<xsl:text>xsl.doc.html.directoryIndexPathMode: </xsl:text>
			<xsl:value-of select="$xsl.doc.html.directoryIndexPathMode"/>
			<xsl:call-template name="endl"/>
			<xsl:text>xsl.doc.html.fullHtmlPage: </xsl:text>
			<xsl:value-of select="$xsl.doc.html.fullHtmlPage"/>
			<xsl:call-template name="endl"/>
			<xsl:text>xsl.doc.html.stylesheetAbstract: </xsl:text>
			<xsl:value-of select="$xsl.doc.html.stylesheetAbstract"/>
			<xsl:call-template name="endl"/>
		</xsl:comment>
		<xsl:call-template name="endl"/>
		<xsl:variable name="abstract">
			<xsl:call-template name="xsl.doc.html.comment">
				<xsl:with-param name="node" select="./xsl:stylesheet"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="displayAbstract" select="(($xsl.doc.html.stylesheetAbstract = true()) and (string-length($abstract) &gt; 0))"/>
		<xsl:choose>
			<xsl:when test="$xsl.doc.html.fullHtmlPage">
				<xsl:element name="html">
					<xsl:element name="head">
						<xsl:element name="title">
							<xsl:if test="$xsl.doc.html.fileName">
								<xsl:value-of select="$xsl.doc.html.fileName"/>
								<xsl:if test="$displayAbstract">
									<xsl:text> - </xsl:text>
								</xsl:if>
							</xsl:if>
							<xsl:if test="$displayAbstract">
								<xsl:value-of select="$abstract"/>
							</xsl:if>
						</xsl:element>
						<xsl:if test="$xsl.doc.html.cssPath">
							<xsl:element name="link">
								<xsl:attribute name="type">
									<xsl:text>text/css</xsl:text>
								</xsl:attribute>
								<xsl:attribute name="rel">
									<xsl:text>stylesheet</xsl:text>
								</xsl:attribute>
								<xsl:attribute name="href">
									<xsl:value-of select="normalize-space($xsl.doc.html.cssPath)"/>
								</xsl:attribute>
							</xsl:element>
						</xsl:if>
					</xsl:element>
					<xsl:element name="body">
						<xsl:apply-templates />
					</xsl:element>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="div">
					<xsl:apply-templates />
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Transform documents based on the xsh XML schema (http://xsd.nore.fr/xsh) to UNIX shell script code -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsh="http://xsd.nore.fr/xsh" xmlns:bash="http://xsd.nore.fr/bash">

	<xsl:output method="text" encoding="utf-8" />

	<xsl:include href="shellscript.xsl" />

	<!-- Interpreter type to use if none is set in the xsh:program node. Should be one of the name defined by the interpreterNameType in the xsh XML schema -->
	<xsl:param name="xsh.defaultInterpreterType" />
	
	<xsl:param name="xsh.defaultInterpreterCommand">
		<xsl:if test="$xsh.defaultInterpreterType and string-length($xsh.defaultInterpreterType) &gt; 0">
			<xsl:value-of select="concat('/usr/bin/env ', $xsh.defaultInterpreterType)" />
		</xsl:if>
	</xsl:param>

	<!-- Retrieve interpreter name from $xsh.defaultInterpreterType, program node @intrepreterType attribute
		or program node @interpreterCommand attribute. If none of these options are available, use 'sh' -->
	<xsl:template name="xsh.getInterpreter">
		<!-- xsh:program node -->
		<xsl:param name="programNode" select="//xsh:program" />

		<xsl:choose>
			<xsl:when test="$programNode/self::xsh:program and $programNode/@interpreterType and (string-length($programNode/@interpreterType) &gt; 0)">
				<xsl:value-of select="$programNode/@interpreterType" />
			</xsl:when>
			<!-- attempt to guess type from invocation command -->
			<xsl:when test="$programNode/self::xsh:program and $programNode/@interpreterCommand and string-length($programNode/@interpreterCommand) &gt; 0">
				<xsl:choose>
					<xsl:when test="contains($programNode/@interpreterCommand, '/ksh') or contains($programNode/@interpreterCommand, ' ksh')">
						<xsl:text>ksh</xsl:text>
					</xsl:when>
					<xsl:when test="contains($programNode/@interpreterCommand, '/bash') or contains($programNode/@interpreterCommand, ' bash')">
						<xsl:text>bash</xsl:text>
					</xsl:when>
					<xsl:when test="contains($programNode/@interpreterCommand, '/zsh') or contains($programNode/@interpreterCommand, ' zsh')">
						<xsl:text>zsh</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="string-length($xsh.defaultInterpreterType) &gt; 0">
								<xsl:value-of select="$xsh.defaultInterpreterType" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>sh</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="string-length($xsh.defaultInterpreterType) &gt; 0">
				<xsl:value-of select="$xsh.defaultInterpreterType" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>sh</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Retrieve interpreter invocation command -->
	<xsl:template name="xsh.getInterpreterCommand">
		<!-- xsh:program node -->
		<xsl:param name="programNode" select="//xsh:program" />
		<xsl:param name="interpreter" />

		<xsl:variable name="name">
			<xsl:call-template name="xsh.getInterpreter">
				<xsl:with-param name="programNode" select="$programNode" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$programNode/self::xsh:program and $programNode/@interpreterCommand and string-length($programNode/@interpreterCommand) &gt; 0">
				<xsl:value-of select="$programNode/@interpreterCommand" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>/usr/bin/env </xsl:text>
				<xsl:value-of select="$name" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Indicate if the given interpreter supports function definition -->
	<xsl:template name="xsh.defaultInterpreterTypeFunctionSupport">
		<!-- Interpreter command name -->
		<xsl:param name="interpreter" />

		<xsl:variable name="endsWithCsh">
			<xsl:call-template name="str.endsWith">
				<xsl:with-param name="text" select="$interpreter" />
				<xsl:with-param name="needle" select="'csh'" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$endsWithCsh">
				<xsl:value-of select="false()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="true()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Definition of a function local variable -->
	<xsl:template name="xsh.functionLocalVariableDefinition">
		<!-- Function parameter node -->
		<xsl:param name="variableNode" select="." />
		<!-- Interpreter command name -->
		<xsl:param name="interpreter" />

		<xsl:variable name="quoted" select="not($variableNode/@type) or ($variableNode/@type = 'string')" />

		<xsl:variable name="value">
			<xsl:apply-templates select="$variableNode/text()" />
		</xsl:variable>

		<xsl:call-template name="sh.local">
			<xsl:with-param name="name">
				<xsl:apply-templates select="$variableNode/@name" />
			</xsl:with-param>
			<xsl:with-param name="value" select="$value" />
			<xsl:with-param name="quoted" select="$quoted" />
			<xsl:with-param name="interpreter" select="$interpreter" />
		</xsl:call-template>
		<xsl:value-of select="$str.unix.endl" />
	</xsl:template>

	<!-- Definition of a function parameter variable -->
	<xsl:template name="xsh.functionParameterDefinition">
		<!-- Function parameter node -->
		<xsl:param name="parameterNode" select="." />
		<!-- Interpreter command name -->
		<xsl:param name="interpreter" />

		<xsl:variable name="default">
			<xsl:apply-templates select="$parameterNode" />
		</xsl:variable>
		<xsl:variable name="quoted" select="not($parameterNode/@type) or ($parameterNode/@type = 'string')" />

		<xsl:call-template name="sh.local">
			<xsl:with-param name="name">
				<xsl:apply-templates select="$parameterNode/@name" />
			</xsl:with-param>
			<xsl:with-param name="interpreter" select="$interpreter" />
		</xsl:call-template>
		<xsl:value-of select="$str.unix.endl" />

		<xsl:call-template name="sh.if">
			<xsl:with-param name="condition">
				<xsl:text>[ $# -gt 0 ]</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="then">
				<xsl:apply-templates select="$parameterNode/@name" />
				<xsl:text>=</xsl:text>
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name" select="1" />
					<xsl:with-param name="quoted" select="$quoted" />
				</xsl:call-template>
				<xsl:value-of select="$str.unix.endl" />
				<text>shift</text>
			</xsl:with-param>
			<xsl:with-param name="else">
				<xsl:if test="string-length($default) > 0">
					<xsl:apply-templates select="$parameterNode/@name" />
					<xsl:text>=</xsl:text>
					<xsl:if test="$quoted">
						<text>"</text>
					</xsl:if>
					<xsl:value-of select="$default" />
					<xsl:if test="$quoted">
						<text>"</text>
					</xsl:if>
				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="xsh:body">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="xsh:body/xsh:local">
		<xsl:call-template name="xsh.functionLocalVariableDefinition">
			<xsl:with-param name="interpreter">
				<xsl:call-template name="xsh.getInterpreter">
					<xsl:with-param name="programNode" select="../../../.." />
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:if test="following-sibling::*[1][text()]">
			<xsl:value-of select="$str.unix.endl" />
		</xsl:if>
	</xsl:template>

	<xsl:template match="xsh:program/xsh:code/text()">
		<xsl:call-template name="str.trim">
			<xsl:with-param name="text" select="." />
		</xsl:call-template>
		<xsl:value-of select="$str.unix.endl" />
	</xsl:template>
	
	<xsl:template match="xsh:body/text()">
		<xsl:variable name="content">
			<xsl:call-template name="str.trim">
				<xsl:with-param name="text" select="." />
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="string-length($content) &gt; 0">
			<xsl:value-of select="$content" />
			<xsl:value-of select="$str.unix.endl" />
		</xsl:if>
	</xsl:template>

	<xsl:template match="xsh:function/@name">
		<!-- TODO use indentifierNamingStyle ? -->
		<xsl:value-of select="normalize-space(.)" />
	</xsl:template>

	<xsl:template match="xsh:parameter/@name|xsh:local/@name">
		<!-- TODO use indentifierNamingStyle ? -->
		<xsl:value-of select="normalize-space(.)" />
	</xsl:template>

	<xsl:template match="xsh:parameter/text()|xsh:local/text()">
		<xsl:value-of select="normalize-space(.)" />
	</xsl:template>

	<!-- Output a function definition using the given UNIX shell interpreter syntax -->
	<xsl:template match="xsh:function">
		<xsl:param name="interpreter" />

		<xsl:variable name="interpreter">
			<xsl:choose>
				<xsl:when test="$interpreter">
					<xsl:value-of select="$interpreter" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="xsh.getInterpreter">
						<xsl:with-param name="programNode" select="./../.." />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="functionSupported">
			<xsl:call-template name="xsh.defaultInterpreterTypeFunctionSupport">
				<xsl:with-param name="interpreter" select="$interpreter" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:if test="$functionSupported">
			<xsl:if test="$interpreter = 'ksh'">
				<xsl:text>function </xsl:text>
			</xsl:if>
			<xsl:apply-templates select="./@name" />
			<xsl:if test="$interpreter != 'ksh'">
				<text>()</text>
			</xsl:if>
			<xsl:value-of select="$str.unix.endl" />
			<xsl:text>{</xsl:text>

			<!-- parameters -->
			<xsl:if test="xsh:parameter">
				<xsl:call-template name="sh.block">
					<xsl:with-param name="addFinalEndl" select="false()" />
					<xsl:with-param name="addInitialEndl" select="false()" />
					<xsl:with-param name="endl" select="$str.unix.endl" />
					<xsl:with-param name="content">
						<xsl:for-each select="xsh:parameter">
							<xsl:call-template name="xsh.functionParameterDefinition">
								<xsl:with-param name="interpreter" select="$interpreter" />
							</xsl:call-template>
						</xsl:for-each>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- body -->
			<xsl:choose>
				<xsl:when test="xsh:body">
					<xsl:for-each select="xsh:body">
						<xsl:choose>
							<xsl:when test="@indent = 'no'">
								<xsl:if test="position() = 1">
									<xsl:value-of select="$str.unix.endl" />
								</xsl:if>
								<xsl:apply-templates select="." />
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="sh.block">
									<xsl:with-param name="addFinalEndl" select="false()" />
									<xsl:with-param name="content">
										<xsl:apply-templates select="." />
									</xsl:with-param>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:value-of select="$str.unix.endl" />
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$str.unix.endl" />
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>}</xsl:text>
			<xsl:value-of select="$str.unix.endl" />
		</xsl:if>
	</xsl:template>

	<xsl:template match="xsh:functions">
		<!-- Interpreter. Should be one of the name defined by the interpreterNameType in the xsh XML schema -->
		<xsl:param name="interpreter" />

		<xsl:variable name="vInterpreter">
			<xsl:choose>
				<xsl:when test="$interpreter">
					<xsl:value-of select="$interpreter" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="xsh.getInterpreter">
						<xsl:with-param name="programNode" select="./.." />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:apply-templates select="xsh:function|bash:function">
			<xsl:with-param name="interpreter" select="$vInterpreter" />
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="xsh:program">
		<xsl:variable name="interpreterCommand">
			<xsl:call-template name="xsh.getInterpreterCommand">
				<xsl:with-param name="programNode" select="." />
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="interpreter">
			<xsl:call-template name="xsh.getInterpreter">
				<xsl:with-param name="programNode" select="." />
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:text>#!</xsl:text>
		<xsl:value-of select="$interpreterCommand" />
								
		<xsl:apply-templates select="xsh:functions">
			<xsl:with-param name="interpreter" select="$interpreter" />
		</xsl:apply-templates>
		<xsl:apply-templates select="xsh:code">
			<xsl:with-param name="interpreter" select="$interpreter" />
		</xsl:apply-templates>
	</xsl:template>

</xsl:stylesheet>
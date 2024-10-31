<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2015 - 2021 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sh="http://xsd.nore.fr/xsh">
	<xsl:import href="../../ns/xsl/languages/xsh.xsl" />

	<xsl:variable name="testsuiteFunctionPrefix" select="'ns_testsuite_'" />
	<xsl:param name="out" select="'/dev/null'" />
	<xsl:param name="err" select="'/dev/null'" />

	<xsl:template match="/">
		<xsl:variable name="outRedirection">
			<xsl:if test="string-length($out) &gt; 0">
				<xsl:text>1>></xsl:text>
				<xsl:value-of select="$out"></xsl:value-of>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="errRedirection">
			<xsl:if test="string-length($err) &gt; 0">
				<xsl:text>2>></xsl:text>
				<xsl:value-of select="$err"></xsl:value-of>
			</xsl:if>
		</xsl:variable>

		<xsl:call-template name="sh.comment">
			<xsl:with-param name="content">
				<xsl:text>Function declarations</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:value-of select="$sh.endl" />

		<xsl:apply-templates />

		<xsl:call-template name="sh.comment">
			<xsl:with-param name="content">
				<xsl:text>Run tests</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:value-of select="$sh.endl" />
		<xsl:text>NORMAL_COLOR="$(tput -Txterm-basic sgr0)"</xsl:text>
		<xsl:value-of select="$sh.endl" />
		<xsl:text>ERROR_COLOR="$(tput -Txterm-basic setaf 1)"</xsl:text>
		<xsl:value-of select="$sh.endl" />
		<xsl:text>SUCCESS_COLOR="$(tput -Txterm-basic setaf 2)"</xsl:text>
		<xsl:value-of select="$sh.endl" />
		<xsl:text>testResultFormat="%-40.40s | %-8s\n"</xsl:text>
		<xsl:value-of select="$sh.endl" />

		<xsl:text>xsh_test_program_result=0</xsl:text>
		<xsl:value-of select="$sh.endl" />
		<xsl:text>xsh_test_program_result_string=0</xsl:text>
		<xsl:value-of select="$sh.endl" />

		<xsl:for-each select="//sh:function[substring(@name, 1, string-length($testsuiteFunctionPrefix)) = $testsuiteFunctionPrefix]">
			<xsl:variable name="testName" select="substring(@name, string-length($testsuiteFunctionPrefix) + 1)" />
			<xsl:call-template name="sh.if">
				<xsl:with-param name="condition">
					<xsl:value-of select="@name" />
					<xsl:text> </xsl:text>
					<xsl:value-of select="$outRedirection" />
					<xsl:text> </xsl:text>
					<xsl:value-of select="$errRedirection" />
				</xsl:with-param>
				<xsl:with-param name="then">
					<xsl:text>xsh_test_program_result_string="${SUCCESS_COLOR}passed${NORMAL_COLOR}"</xsl:text>
				</xsl:with-param>
				<xsl:with-param name="else">
					<xsl:text>xsh_test_program_result_string="${ERROR_COLOR}failed${NORMAL_COLOR}"</xsl:text>
					<xsl:value-of select="$sh.endl" />
					<xsl:text>xsh_test_program_result=$(expr ${xsh_test_program_result} + 1)</xsl:text>
					<xsl:value-of select="$sh.endl" />
				</xsl:with-param>
			</xsl:call-template>

			<xsl:text>printf "${testResultFormat}" "</xsl:text>
			<xsl:value-of select="$testName" />
			<xsl:text>" "${xsh_test_program_result_string}"</xsl:text>
			
			<xsl:value-of select="$sh.endl" />
		</xsl:for-each>
		<xsl:text>exit ${xsh_test_program_result}</xsl:text>
		<xsl:value-of select="$sh.endl" />
	</xsl:template>

</xsl:stylesheet>
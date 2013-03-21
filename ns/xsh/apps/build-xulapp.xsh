<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->
<xsh:program interpreterType="bash" xmlns:prg="http://xsd.nore.fr/program" xmlns:xsh="http://xsd.nore.fr/xsh" xmlns:xi="http://www.w3.org/2001/XInclude">
	<xsh:info>
		<xi:include href="build-xulapp.xml" />
	</xsh:info>
	<xsh:functions>
		<xi:include href="../lib/filesystem/filesystem.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function[@name = 'ns_realpath'])" />
		<xi:include href="../lib/filesystem/filesystem.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function[@name = 'ns_mktemp'])" />
		<xsh:function name="log">
			<xsh:body>echo "${@}" &gt;&gt; "${logFile}"</xsh:body>
		</xsh:function>
		<xsh:function name="info">
			<xsh:body><![CDATA[
echo "${@}"
${isDebug} && log "${@}"
		]]></xsh:body>
		</xsh:function>
		<xsh:function name="error">
			<xsh:body><![CDATA[
echo "${@}"
${isDebug} && log "${@}"
exit 1
		]]></xsh:body>
		</xsh:function>
		
		<xsh:function name="build_php">
			<xsh:body indent="no">
				<!-- Transfer prefixed global variables -->
				<xsh:local name="xmlShellFileDescriptionPath">${php_xmlShellFileDescriptionPath}</xsh:local>
				<xsh:local name="programInfoClassname">${php_programInfoClassname}</xsh:local>
				<xsh:local name="parserNamespace">${php_parserNamespace}</xsh:local>
				<xsh:local name="programNamespace">${php_programNamespace}</xsh:local>
				<!-- build-php Forced parameters -->
				<xsh:local name="outputScriptFilePath">${commandLauncherFile}</xsh:local>
				<xsh:local name="generationMode">generateMerge</xsh:local>
				<xsh:local name="generateBase">false</xsh:local>
				<xsh:local name="generateInfo">false</xsh:local>
				<xsh:local name="generateMerge">${php_scriptPath}</xsh:local>
				<![CDATA[
info " - Generate PHP file"
]]>	<xi:include href="build-php.body.process.sh" parse="text" /><![CDATA[
return 0]]></xsh:body>
		</xsh:function>
		<xsh:function name="build_xsh">
			<xsh:body>
				<!-- Transfer prefixed global variables -->
				<xsh:local name="prefixSubcommandBoundVariableName">${xsh_prefixSubcommandBoundVariableName}</xsh:local>
				<xsh:local name="xmlShellFileDescriptionPath">${xsh_xmlShellFileDescriptionPath}</xsh:local>
				<xsh:local name="defaultInterpreterCommand">${xsh_defaultInterpreterCommand}</xsh:local>
				<xsh:local name="defaultInterpreterType">${xsh_defaultInterpreterType}</xsh:local>
				<xsh:local name="xshXslTemplatePath" />
				<!-- Forced parameters -->
				<xsh:local name="outputScriptFilePath">${commandLauncherFile}</xsh:local>
				<![CDATA[info " - Generate shell file"]]>
				<!-- Copy/Paste is evil ^^ -->
				<xi:include href="build-shellscript.body.process.sh" parse="text" />
				<![CDATA[return 0]]></xsh:body>
		</xsh:function>
		
		<!-- New python parser -->
		<xsh:function name="build_python">
			<xsh:body indent="no">
				<!-- Transfer prefixed global variables -->
				<xsh:local name="xmlShellFileDescriptionPath">${python_xmlShellFileDescriptionPath}</xsh:local>
				<xsh:local name="programInfoClassname">${python_programInfoClassname}</xsh:local>
				<!-- build-python Forced parameters -->
				<xsh:local name="outputScriptFilePath">${commandLauncherFile}</xsh:local>
				<xsh:local name="generationMode">generateMerge</xsh:local>
				<xsh:local name="generateBase">false</xsh:local>
				<xsh:local name="generateInfo"></xsh:local>
				<xsh:local name="generateMerge">${python_scriptPath}</xsh:local>
				<![CDATA[
info " - Generate Python file"
]]>	<xi:include href="build-python.body.process.sh" parse="text" /><![CDATA[
return 0]]></xsh:body>
		</xsh:function>		
		
		<xsh:function name="build_command">
			<xsh:body><![CDATA[
info " - Generate command launcher"
echo -ne "#!/bin/bash\n${command_existingCommandPath} \${@}" > "${commandLauncherFile}"
			]]></xsh:body>
		</xsh:function>
		<xi:include href="functions.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function[@name = 'xml_validate'])" />
	</xsh:functions>
	<xsh:code>
		<xi:include href="build-xulapp.body.sh" parse="text" />
	</xsh:code>
</xsh:program>

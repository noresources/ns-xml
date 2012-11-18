<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the BSD License, see LICENSE -->
<xsh:program interpreterType="bash" xmlns:prg="http://xsd.nore.fr/program" xmlns:xsh="http://xsd.nore.fr/xsh" xmlns:xi="http://www.w3.org/2001/XInclude">
	<xsh:info>
		<xi:include href="build-xulapp.xml" />
	</xsh:info>
	<xsh:functions>
		<xi:include href="../lib/filesystem/filesystem.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function[@name = 'ns_realpath'])" />
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
		<xsh:function name="build_xsh">
			<xsh:body>
				<!-- Transfer prefixed global variables -->
				<xsh:local name="prefixSubcommandBoundVariableName">${xsh_prefixSubcommandBoundVariableName}</xsh:local>
				<xsh:local name="xmlShellFileDescriptionPath">${xsh_xmlShellFileDescriptionPath}</xsh:local>
				<xsh:local name="defaultInterpreterCommand">${xsh_defaultInterpreterCommand}</xsh:local>
				<xsh:local name="defaultInterpreterType">${xsh_defaultInterpreterType}</xsh:local>
				<!-- Forced parameters -->
				<xsh:local name="outputScriptFilePath">${commandLauncherFile}</xsh:local>
				<![CDATA[info " - Generate shell file"]]>
				<!-- Copy/Paste is evil ^^ -->
				<xi:include href="build-shellscript.body.process.sh" parse="text" />
				<![CDATA[return 0]]></xsh:body>
		</xsh:function>
		<xsh:function name="build_python">
			<xsh:body><![CDATA[
baseModules=(__init__ Base Info Parser Validators)
pythonModulePath="${xulScriptBasePath}/${python_moduleName}"
nsPythonPath="${nsPath}/python/program/${programVersion}"

cp -p "${python_pythonScriptPath}" "${commandLauncherFile}"
[ -d "${pythonModulePath}" ] && ! ${update} && error "${pythonModulePath} already exists - set --update to overwrite"
mkdir -p "${pythonModulePath}" || error "Failed to create Python module path ${pythonModulePath}"
for m in ${baseModules[*]}
do
	nsPythonFile="${nsPythonPath}/${m}.py"	
	[ -f "${nsPythonFile}" ] || error "Base python module not found (${nsPythonFile})"
	cp -fp "${nsPythonFile}" "${pythonModulePath}"
done 

# Create the Program module
xslStyleSheetPath="${nsPath}/xsl/program/${programVersion}"
if ! xsltproc --xinclude -o "${pythonModulePath}/Program.py" "${xslStyleSheetPath}/py/module.xsl" "${xmlProgramDescriptionPath}"
then
	error 4 "Failed to create Program module"
fi

return 0
			]]></xsh:body>
		</xsh:function>
		<xsh:function name="build_command">
			<xsh:body><![CDATA[
info " - Generate command launcher"
echo -ne "#!/bin/bash\n${command_existingCommandPath} \${@}" > "${commandLauncherFile}"
			]]></xsh:body>
		</xsh:function>
		<xi:include href="functions.xml" xpointer="xmlns(sh=http://xsd.nore.fr/bash)xpointer(//sh:function[@name = 'xml_validate'])" />
	</xsh:functions>
	<xsh:code>
		<xi:include href="build-xulapp.body.sh" parse="text" />
	</xsh:code>
</xsh:program>

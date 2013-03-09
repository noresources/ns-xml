<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->
<xsh:program interpreterType="bash" xmlns:prg="http://xsd.nore.fr/program" xmlns:xsh="http://xsd.nore.fr/xsh" xmlns:xi="http://www.w3.org/2001/XInclude">
	<xsh:info>
		<xi:include href="build-pyscript.xml"/>
	</xsh:info>
	<xsh:functions>
		<xi:include href="../../lib/filesystem/filesystem.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh) xpointer(//xsh:function[@name = 'ns_realpath'])"/>
		<xi:include href="../functions.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh) xpointer(//xsh:function)"/>
	</xsh:functions>
	<xsh:code><![CDATA[
# Global variables
scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
scriptName="$(basename "${scriptFilePath}")"
resourcesPath="$(ns_realpath "${scriptPath}/../../..")/resources"
nsPath="$(ns_realpath "${scriptPath}/../../..")/ns"
programVersion="2.0"
baseModules=(__init__ Base Info Parser Validators)
 
# Check required programs
for x in xmllint xsltproc
do
	if ! which $x 1>/dev/null 2>&1
	then
		echo "${x} program not found"
		exit 1
	fi
done

if ! parse "${@}"
then
	if ${displayHelp}
	then
		usage
		exit 0
	fi
	
	parse_displayerrors
	exit 1
fi

if ${displayHelp}
then
	usage
	exit 0
fi

chunk_check_nsxml_ns_path || error "Invalid ns-xml ns folder (${nsPath})"
programVersion="$(get_program_version "${xmlProgramDescriptionPath}")"

pythonScriptPathBase="$(dirname "${pythonScriptPath}")"
pythonModulePath="${pythonScriptPathBase}/${moduleName}"

[ -d "${pythonModulePath}" ] && ! ${update} && error "${pythonModulePath} already exists - set --update to overwrite"

nsPythonPath="${resourcesPath}/legacy/python/program/${programVersion}"
for m in ${baseModules[*]}
do
	nsPythonFile="${nsPythonPath}/${m}.py"	
	[ -f "${nsPythonFile}" ] || error 2 "Base python module not found (${nsPythonFile})"
done

mkdir -p "${pythonModulePath}" || error 3 "Unable to create Module folder ${pythonModulePath}"
for m in "${baseModules[@]}"
do
	nsPythonFile="${nsPythonPath}/${m}.py"
	cp -fp "${nsPythonFile}" "${pythonModulePath}"  
done

# Create the Program module
xslStyleSheetPath="${nsPath}/xsl/legacy/program/${programVersion}"
if ! xsltproc --xinclude -o "${pythonModulePath}/Program.py" "${xslStyleSheetPath}/py/module.xsl" "${xmlProgramDescriptionPath}"
then
	error 4 "Failed to create Program module"
fi

]]></xsh:code>
</xsh:program>

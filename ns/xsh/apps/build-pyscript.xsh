<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->
<sh:program xmlns:prg="http://xsd.nore.fr/program" 
xmlns:sh="http://xsd.nore.fr/bash" 
xmlns:xi="http://www.w3.org/2001/XInclude">
<sh:info>
	<xi:include href="build-pyscript.xml" />
</sh:info>
<sh:functions>
	<xi:include href="../lib/filesystem/filesystem.xml" xpointer="xmlns(sh=http://xsd.nore.fr/bash)xpointer(//sh:function[@name = 'ns_realpath'])" />
	<xi:include href="functions.xml" xpointer="xmlns(sh=http://xsd.nore.fr/bash)xpointer(//sh:function)" />
</sh:functions>
<sh:code><![CDATA[
# Global variables
scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
scriptName="$(basename "${scriptFilePath}")"
nsPath="$(ns_realpath "${scriptPath}/../..")/ns"
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

nsPythonPath="${nsPath}/python/program/${programVersion}"
for m in ${baseModules[*]}
do
	nsPythonFile="${nsPythonPath}/${m}.py"	
	[ -f "${nsPythonFile}" ] || error 2 "Base python module not found (${nsPythonFile})"
done

mkdir -p "${pythonModulePath}" || error 3 "Unable to create Module folder ${pythonModulePath}"
for m in ${baseModules[*]}
do
	nsPythonFile="${nsPythonPath}/${m}.py"
	cp -fp "${nsPythonFile}" "${pythonModulePath}"  
done

# Create the Program module
xslStyleSheetPath="${nsPath}/xsl/program/${programVersion}"
if ! xsltproc --xinclude -o "${pythonModulePath}/Program.py" "${xslStyleSheetPath}/py-module.xsl" "${xmlProgramDescriptionPath}"
then
	error 4 "Failed to create Program module"
fi

]]></sh:code>
</sh:program>

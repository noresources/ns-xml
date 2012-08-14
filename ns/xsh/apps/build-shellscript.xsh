<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->
<sh:program interpreter="/usr/bin/env bash" xmlns:prg="http://xsd.nore.fr/program" 
xmlns:sh="http://xsd.nore.fr/bash" 
xmlns:xi="http://www.w3.org/2001/XInclude">
<sh:info>
	<xi:include href="build-shellscript.xml" />
</sh:info>
<sh:functions>
	<xi:include href="../lib/filesystem/filesystem.xml" xpointer="xmlns(sh=http://xsd.nore.fr/bash)xpointer(//sh:function[@name = 'ns_realpath'])" />
	<xi:include href="functions.xml" xpointer="xmlns(sh=http://xsd.nore.fr/bash)xpointer(//sh:function)" />
</sh:functions>
<sh:code><![CDATA[
# Global variables
scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
nsPath="$(ns_realpath "${scriptPath}/../..")/ns"
rootPath="$(ns_realpath "${scriptPath}/../..")"
programVersion="2.0"
 
# Check required programs
for x in xmllint xsltproc egrep cut expr head tail
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

chunk_check_nsxml_ns_path || error 1 "Invalid ns-xml ns folder (${nsPath})"

# Check required XSLT files
xshXslTemplatePath="${nsPath}/xsl/program/${programVersion}/xsh.xsl"
if [ ! -f "${xshXslTemplatePath}" ]
then
	echo "Missing XSLT stylesheet file \"${xshXslTemplatePath}\""
	exit 2
fi

# Validate xml program description (if given)
if [ -f "${xmlProgramDescriptionPath}" ]
then
	# Finding schema version
	programVersion="$(xsltproc --xinclude "${nsPath}/xsl/program/get-version.xsl" "${xmlProgramDescriptionPath}")"
	#echo "Program schema version ${programVersion}"
	
	if [ ! -f "${nsPath}/xsd/program/${programVersion}/program.xsd" ]
	then
		echo "Invalid program interface definition schema version"
		exit 3
	fi

	if ! ${skipValidation} && ! xml_validate "${nsPath}/xsd/program/${programVersion}/program.xsd" "${xmlProgramDescriptionPath}"
	then
		echo "program interface definition schema error - abort"
		exit 4
	fi
fi

# Validate against bash schema
if ! ${skipValidation}
then
	if ! xml_validate "${nsPath}/xsd/bash.xsd" "${xmlShellFileDescriptionPath}"
	then
		echo "bash schema error - abort"
		exit 5
	fi
fi

# Process xsh file
xsltprocArgs=(--xinclude)
debugParam=""
if ${debugMode}
then
	xsltprocArgs[${#xsltprocArgs[*]}]="--param"
	xsltprocArgs[${#xsltprocArgs[*]}]="prg.debug"
	xsltprocArgs[${#xsltprocArgs[*]}]="true()"
	debugParam="--stringparam prg.debug \"true()\""
fi

prefixParam=""
if ${prefixSubcommandBoundVariableName}
then
	xsltprocArgs[${#xsltprocArgs[*]}]="--stringparam"
	xsltprocArgs[${#xsltprocArgs[*]}]="prg.sh.parser.prefixSubcommandOptionVariable"
	xsltprocArgs[${#xsltprocArgs[*]}]="yes"
	prefixParam="--stringparam prg.sh.parser.prefixSubcommandOptionVariable yes"
fi

if [ ! -z "${defaultInterpreter}" ]
then
	xsltprocArgs[${#xsltprocArgs[*]}]="--stringparam"
	xsltprocArgs[${#xsltprocArgs[*]}]="prg.xsh.defaultInterpreter"
	xsltprocArgs[${#xsltprocArgs[*]}]="${defaultInterpreter}"
fi

#if ! xsltproc --xinclude -o "${outputScriptFilePath}" ${prefixParam} ${debugParam} "${xshXslTemplatePath}" "${xmlShellFileDescriptionPath}"
if ! xsltproc "${xsltprocArgs[@]}" -o "${outputScriptFilePath}" "${xshXslTemplatePath}" "${xmlShellFileDescriptionPath}"
then
	echo "Fail to process xsh file \"${xmlShellFileDescriptionPath}\""
	exit 6
fi

chmod 755 "${outputScriptFilePath}"
]]></sh:code>
</sh:program>

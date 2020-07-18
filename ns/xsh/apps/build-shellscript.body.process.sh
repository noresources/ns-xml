# Check required XSLT files
xshXslTemplatePath="${nsPath}/xsl/program/${programSchemaVersion}/xsh.xsl"
if [ ! -f "${xshXslTemplatePath}" ]
then
    echo "Missing XSLT stylesheet file \"${xshXslTemplatePath}\""
    exit 2
fi

# Validate against bash or xsh schema
if ! ${skipValidation}
then
	shSchema="$(xsltproc --xinclude "${nsPath}/xsl/program/${programSchemaVersion}/xsh-getschemapath.xsl" "${xmlShellFileDescriptionPath}")"
	if ! xml_validate "${nsPath}/xsd/${shSchema}" "${xmlShellFileDescriptionPath}" 
	then
		echo "bash schema error - abort"
		exit 5
	fi
fi

# Process xsh file
xsltprocArgs=(--xinclude)
if ${debugTrace}
then
	xsltprocArgs[${#xsltprocArgs[*]}]="--param"
	xsltprocArgs[${#xsltprocArgs[*]}]="prg.debug"
	xsltprocArgs[${#xsltprocArgs[*]}]="true()"
fi

if ${prefixSubcommandBoundVariableName}
then
	xsltprocArgs[${#xsltprocArgs[*]}]="--stringparam"
	xsltprocArgs[${#xsltprocArgs[*]}]="prg.sh.parser.prefixSubcommandOptionVariable"
	xsltprocArgs[${#xsltprocArgs[*]}]="yes"
fi

if ${debugComments}
then
	xsltprocArgs[${#xsltprocArgs[*]}]="--stringparam"
	xsltprocArgs[${#xsltprocArgs[*]}]="prg.sh.parser.debug.comments"
	xsltprocArgs[${#xsltprocArgs[*]}]="yes"
fi

if [ ! -z "${defaultInterpreterCommand}" ]
then
	# See ns/xsl/program/*/xsh.xsl
	xsltprocArgs[${#xsltprocArgs[*]}]="--stringparam"
	xsltprocArgs[${#xsltprocArgs[*]}]="xsh.defaultInterpreterCommand"
	xsltprocArgs[${#xsltprocArgs[*]}]="${defaultInterpreterCommand}"
elif [ ! -z "${defaultInterpreterType}" ]
then
	# See ns/xsl/languages/xsh.xsl
	xsltprocArgs[${#xsltprocArgs[*]}]="--stringparam"
	xsltprocArgs[${#xsltprocArgs[*]}]="xsh.defaultInterpreterType"
	xsltprocArgs[${#xsltprocArgs[*]}]="${defaultInterpreterType}"
fi

if ${forceInterpreter} && ([ ! -z "${defaultInterpreterCommand}" ] || [ ! -z "${defaultInterpreterType}" ])
then
	xsltprocArgs[${#xsltprocArgs[*]}]="--stringparam"
	xsltprocArgs[${#xsltprocArgs[*]}]="xsh.forceInterpreter"
	xsltprocArgs[${#xsltprocArgs[*]}]="yes"
fi 

if ! xsltproc "${xsltprocArgs[@]}" -o "${outputScriptFilePath}" "${xshXslTemplatePath}" "${xmlShellFileDescriptionPath}"
then
	echo "Fail to process xsh file \"${xmlShellFileDescriptionPath}\""
	exit 6
fi

chmod 755 "${outputScriptFilePath}"

scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
scriptName="$(basename "${scriptFilePath}")"
nsPath="$(ns_realpath "$(nsxml_installpath "${scriptPath}/..")")"
programSchemaVersion="2.0"

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

chunk_check_nsxml_ns_path || ns_error 1 "Invalid ns-xml ns folder (${nsPath})"

buildcXsltPath="${nsPath}/xsl/program/${programSchemaVersion}/c"
buildcXsltprocParams=''
outputPath="$(ns_realpath "${outputPath}")"

# Modes
if ${generateBaseOnly}
then
	buildcGenerateBase
else
	programSchemaVersion="$(get_program_version "${xmlProgramDescriptionPath}")"
	if ! ${skipValidation} && ! xml_validate "${nsPath}/xsd/program/${programSchemaVersion}/program.xsd" "${xmlProgramDescriptionPath}"
	then
		ns_error 1 "program interface definition schema error - abort"
	fi

	buildcGenerate
fi

exit 0
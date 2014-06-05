# Global variables
scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
nsPath="$(ns_realpath "$(nsxml_installpath "${scriptPath}/..")")"
programSchemaVersion="2.0"
 
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

# Validate XML program description (if given)
if [ -f "${xmlProgramDescriptionPath}" ]
then
	# Finding schema version
	programSchemaVersion="$(xsltproc --xinclude "${nsPath}/xsl/program/get-version.xsl" "${xmlProgramDescriptionPath}")"
	#echo "Program schema version ${programSchemaVersion}"
	
	if [ ! -f "${nsPath}/xsd/program/${programSchemaVersion}/program.xsd" ]
	then
		echo "Invalid program interface definition schema version"
		exit 3
	fi

	if ! ${skipValidation} && ! xml_validate "${nsPath}/xsd/program/${programSchemaVersion}/program.xsd" "${xmlProgramDescriptionPath}"
	then
		echo "program interface definition schema error - abort"
		exit 4
	fi
fi

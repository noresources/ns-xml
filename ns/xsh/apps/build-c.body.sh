function buildcPopulateXsltprocParams()
{
	# Shared xsltproc options
	buildcXsltprocParams=(--xinclude)
	
	# Prefix
	if [ ! -z "${prefix}" ]
	then
		buildcXsltprocParams=("${buildcXsltprocParams[@]}" \
			--stringparam "prg.c.parser.prefix" "${prefix}")
	fi
	
	if [ "${structNameStyle}" != "none" ]
	then
		buildcXsltprocParams=("${buildcXsltprocParams[@]}" \
			"--stringparam" "prg.c.parser.structNamingStyle" "${structNameStyle}")
	fi
	
	if [ "${functionNameStyle}" != "none" ]
	then
		buildcXsltprocParams=("${buildcXsltprocParams[@]}" \
			"--stringparam" "prg.c.parser.functionNamingStyle" "${functionNameStyle}")
	fi
	
	if [ "${variableNameStyle}" != "none" ]
	then
		buildcXsltprocParams=("${buildcXsltprocParams[@]}" \
		"--stringparam" "prg.c.parser.variableNamingStyle" "${variableNameStyle}")
	fi
}

function buildcGenerateBase()
{
	# Check required templates
	for x in parser.generic-header parser.generic-source
	do
		local tpl="${buildcXsltPath}/${x}.xsl"
		[ -r "${tpl}" ] || error 2 "Missing XSLT template $(basename "${tpl}")" 
	done
	
	local fileBase="${outputFileBase}"
	if [ "${fileBase}" = "<auto>" ]
	then
		fileBase="cmdline-base"
	fi
		
	local outputFileBasePath="${outputPath}/${fileBase}"
	if ! ${outputOverwrite}
	then
		# Check existing files
		for e in h c
		do
			[ -f "${outputFileBasePath}.${e}" ] && error 2 "${fileBase}.${e} already exists. Use --overwrite"
		done
	fi
	
	buildcPopulateXsltprocParams
	
	# Header
	if ! xsltproc "${buildcXsltprocParams[@]}" \
			--output "${outputFileBasePath}.h" \
			"${buildcXsltPath}/parser.generic-header.xsl" \
			"${xmlProgramDescriptionPath}"
	then
		error 2 "Failed to generate header file ${outputFileBasePath}.h" 
	fi
	
	if ! xsltproc "${buildcXsltprocParams[@]}" \
			--output "${outputFileBasePath}.c" \
			"${buildcXsltPath}/parser.generic-source.xsl" \
			"${xmlProgramDescriptionPath}"
	then
		error 2 "Failed to generate source file ${outputFileBasePath}.c" 
	fi
}

function buildcGenerate()
{
	# Check required templates
	for x in parser.header parser.source
	do
		local tpl="${buildcXsltPath}/${x}.xsl"
		[ -r "${tpl}" ] || error 2 "Missing XSLT template $(basename "${tpl}")" 
	done
	
	local fileBase="${outputFileBase}"
	if [ "${fileBase}" = "<auto>" ]
	then
		fileBase="cmdline"
	fi
		
	local outputFileBasePath="${outputPath}/${fileBase}"
	if ! ${outputOverwrite}
	then
		# Check existing files
		for e in h c
		do
			[ -f "${outputFileBasePath}.${e}" ] && error 2 "${fileBase}.${e} already exists. Use --overwrite"
		done
	fi
	
	buildcPopulateXsltprocParams
	if ! ${generateEmbeded}
	then
		buildcXsltprocParams=("${buildcXsltprocParams[@]}" \
		"--stringparam"	"prg.c.parser.nsxmlHeaderPath" "${generateInclude}")
	fi
	
	# Header
	if ! xsltproc "${buildcXsltprocParams[@]}" \
			--output "${outputFileBasePath}.h" \
			"${buildcXsltPath}/parser.header.xsl" \
			"${xmlProgramDescriptionPath}"
	then
		error 2 "Failed to generate header file ${outputFileBasePath}.h" 
	fi
	
	if ! xsltproc "${buildcXsltprocParams[@]}" \
			--output "${outputFileBasePath}.c" \
			--stringparam "prg.c.parser.header.filePath" "${fileBase}.h" \
			"${buildcXsltPath}/parser.source.xsl" \
			"${xmlProgramDescriptionPath}"
	then
		error 2 "Failed to generate source file ${outputFileBasePath}.c" 
	fi
}

scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
scriptName="$(basename "${scriptFilePath}")"
nsPath="$(ns_realpath "${scriptPath}/../..")/ns"
programVersion="2.0"

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

chunk_check_nsxml_ns_path || error 1 "Invalid ns-xml ns folder (${nsPath})"

if ! ${skipValidation} && ! xml_validate "${nsPath}/xsd/program/${programVersion}/program.xsd" "${xmlProgramDescriptionPath}"
then
	error 1 "program interface definition schema error - abort"
fi

programVersion="$(get_program_version "${xmlProgramDescriptionPath}")"
buildcXsltPath="${nsPath}/xsl/program/${programVersion}/c"
buildcXsltprocParams=""
outputPath="$(ns_realpath "${outputPath}")"

# Modes
if ${generateBaseOnly}
then
	buildcGenerateBase
else
	buildcGenerate
fi

exit 0
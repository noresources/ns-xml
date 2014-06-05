scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
nsPath="$(ns_realpath "$(nsxml_installpath "${scriptPath}/..")")"
programSchemaVersion="2.0"

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

chunk_check_nsxml_ns_path || ns_error "Invalid ns-xml ns folder (${nsPath})"
programSchemaVersion="$(get_program_version "${xmlProgramDescriptionPath}")"

xslFile="${nsPath}/xsl/program/${programSchemaVersion}/${xslName}.xsl"

[ -f "${xslFile}" ] || ns_error 2 "Unable to find \"${xslFile}\""

xsltprocCommand[${parser_startindex}]="xsltproc"
xsltprocCommand[${#xsltprocCommand[*]}]="--xinclude"
if [ ! -z "${output}" ]
then
	xsltprocCommand[${#xsltprocCommand[*]}]="--output"
	xsltprocCommand[${#xsltprocCommand[*]}]="${output}"
fi

count=${#stringParameters[*]}
mc=$(expr ${count} % 2)
[ ${mc} -eq 1 ] && ns_error 2 "Invalid number of arguments for --stringparam. Even value expected, got ${count}"
limit=$(expr ${parser_startindex} + ${count})
for ((i=${parser_startindex};${i}<${limit};i+=2))
do
	p="${stringParameters[${i}]}"
	v="${stringParameters[$(expr ${i} + 1)]}"
	xsltprocCommand[${#xsltprocCommand[*]}]="--stringparam"
	xsltprocCommand[${#xsltprocCommand[*]}]="${p}"
	xsltprocCommand[${#xsltprocCommand[*]}]="${v}"
done

count=${#parameters[*]}
mc=$(expr ${count} % 2)
[ ${mc} -eq 1 ] && ns_error 2 "Invalid number of arguments for --stringparam. Even value expected, got ${count}"
limit=$(expr ${parser_startindex} + ${count})
for ((i=${parser_startindex};${i}<${limit};i+=2))
do
	p="${parameters[${i}]}"
	v="${parameters[$(expr ${i} + 1)]}"
	xsltprocCommand[${#xsltprocCommand[*]}]="--param"
	xsltprocCommand[${#xsltprocCommand[*]}]="${p}"
	xsltprocCommand[${#xsltprocCommand[*]}]="${v}"
done

xsltprocCommand[${#xsltprocCommand[*]}]="${xslFile}"
xsltprocCommand[${#xsltprocCommand[*]}]="${xmlProgramDescriptionPath}"
 
"${xsltprocCommand[@]}"

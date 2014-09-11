# Global variables
scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
scriptName="$(basename "${scriptFilePath}")"
nsPath="$(ns_realpath "${scriptPath}/../..")/ns"
programSchemaVersion="2.0"

tmpPath="/tmp"
[ ! -z "${TMPDIR}" ] && [ -d "${TMPDIR}" ] && tmpPath="${TMPDIR%/}/"
author=""
if [ ! -z "${USER}" ]; then author="${USER}"
elif [ ! -z "${LOGNAME}" ]; then author="${LOGNAME}"
fi
 
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

#chunk_check_nsxml_ns_path || error "Invalid ns-xml ns folder (${nsPath})"
#programSchemaVersion="$(get_program_version "${xmlProgramDescriptionPath}")"

xshFile="${outputPath}/${xshName}.xsh"
xmlFile="${outputPath}/${xshName}.xml"
shFile="${outputPath}/${xshName}.body.sh"
tmpFile="${tmpPath}/${xshName}.tmp"

for f in "${xshFile}" "${xmlFile}" "${shFile}"
do
	[ -f "${f}" ] && error 1 "${f} already exists"
done

cat > "${tmpFile}" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<sh:program interpreterType="bash" xmlns:prg="http://xsd.nore.fr/program" xmlns:sh="http://xsd.nore.fr/xsh" xmlns:xi="http://www.w3.org/2001/XInclude">
	<sh:info>
		<xi:include href="${xshName}.xml" />
	</sh:info>
$(
if ${addSamples}
then
cat << INNEREOF
	<sh:functions>
	<!-- An equivalent of realpath -->
	<sh:function name="ns_realpath" >
		<sh:parameter name="path" />
		<sh:body><sh:local name="cwd">\$(pwd)</sh:local><![CDATA[
[ -d "\${path}" ] && cd "\${path}" && path="."
while [ -h "\${path}" ] ; do path="\$(readlink "\${path}")"; done

if [ -d "\${path}" ]
then
	path="\$( cd -P "\$( dirname "\${path}" )" && pwd )"
else
	path="\$( cd -P "\$( dirname "\${path}" )" && pwd )/\$(basename "\${path}")"
fi

cd "\${cwd}" 1>/dev/null 2>&1
echo "\${path}"
		]]></sh:body>
	</sh:function>
		<!-- A function to write an error message and exit with a given code -->
		<sh:function name="error">
			<sh:parameter name="errno" type="numeric">1</sh:parameter>
			<sh:body><![CDATA[
local message="\${@}"
if [ -z "\${errno##*[!0-9]*}" ]
then 
	message="\${errno} \${message}"
	errno=1
fi
echo "\${message}"
exit \${errno}
]]></sh:body>
		</sh:function>
	</sh:functions>
INNEREOF
fi
)
	<sh:code>
		<!-- Include shell script code -->
		<xi:include href="${xshName}.body.sh" parse="text" />
	</sh:code>
</sh:program>
EOF

xmllint --output "${xshFile}" "${tmpFile}"

# XML file
cat > "${tmpFile}" << EOF
<?xml version="1.0" encoding="utf-8"?>
<!-- {} -->
<prg:program xmlns:prg="http://xsd.nore.fr/program" version="2.0" xmlns:xi="http://www.w3.org/2001/XInclude">
	<prg:name>${xshName}</prg:name>
	<prg:author>${author}</prg:author>
	<prg:version>1.0</prg:version>
	<prg:copyright>Copyright © $(date +%Y) by ${author}</prg:copyright>
	<prg:documentation>
		<prg:abstract>${xshName} short description</prg:abstract>
	</prg:documentation>
$(if ${addSamples}
then
cat << INNEREOF
	<prg:options>
		<prg:switch>
			<prg:databinding>
				<prg:variable>displayHelp</prg:variable>
			</prg:databinding>
			<prg:documentation>
				<prg:abstract>Display program usage</prg:abstract>
			</prg:documentation>
			<prg:names>
				<prg:long>help</prg:long>
			</prg:names>
			<prg:ui mode="disabled" />
		</prg:switch>
	</prg:options>
INNEREOF
fi
)
</prg:program>
EOF

xmllint --output "${xmlFile}" "${tmpFile}"

# Body

touch "${shFile}"

if ${addSamples}
then
	cat > "${shFile}" << EOF
# Global variables
scriptFilePath="\$(ns_realpath "\${0}")"
scriptPath="\$(dirname "\${scriptFilePath}")"
scriptName="\$(basename "\${scriptFilePath}")"

# Option parsing
if ! parse "\${@}"
then
	if \${displayHelp}
	then
		usage "\${parser_subcommand}"
		exit 0
	fi
	
	parse_displayerrors
	exit 1
fi

if \${displayHelp}
then
	usage "\${parser_subcommand}"
	exit 0
fi

# Main code

EOF
fi

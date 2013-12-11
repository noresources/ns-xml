# Global variables
scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
scriptName="$(basename "${scriptFilePath}")"
defaultRelativePath="$(pwd)"

# Option parsing
if ! parse "${@}"
then
	if ${displayHelp}
	then
		usage ""
		exit 0
	fi
	
	parse_displayerrors
	exit 1
fi

if ${displayHelp}
then
	usage ""
	exit 0
fi

trap on_exit EXIT

[ -z "${relativePath}" ] && relativePath="${defaultRelativePath}"

# Main code
temporaryXsltPath=$(ns_mktemp "${scriptName}")
cat > "${temporaryXsltPath}" << EOXSLT
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" encoding="utf-8" />
	<xsl:template match="/">
		<xsl:for-each select="//xsl:import|//xsl:include">
			<xsl:value-of select="@href" />
			<xsl:text>&#10;</xsl:text>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
EOXSLT

xmllint --noout "${temporaryXsltPath}" 1>/dev/null || ns_error "Failed to create XSLT" 

for f in "${parser_values[@]}"
do
	f="$(ns_realpath "${f}")"
	d="$(dirname "${f}")"
	if ns_array_contains "${f}" "${dependencies[@]}"
	then
		continue
	fi
	
	# Initialize
	unset newDependencies
	while read dep
	do
		[ -z "${dep}" ] && continue
		dep="$(ns_realpath "${d}/${dep}")"
		if ns_array_contains "${dep}" "${dependencies[@]}" \
			|| ns_array_contains "${dep}" "${newDependencies[@]}"
		then
			continue
		fi
		
		debug "dep of $(basename "${f}"): ${dep}"		
		newDependencies=("${newDependencies[@]}" "${dep}")
		
	done << EOF
$(xsltproc --xinclude "${temporaryXsltPath}" "${f}")
EOF

	# Cycle
	while [ ${#newDependencies[@]} -gt 0 ]
	do
		# Pop last
		len=${#newDependencies[@]}
		index=$(expr ${len} - 1)
		index=$(expr ${index} + ${parser_startindex})
		dep="${newDependencies[${index}]}"
		dependencies=("${dependencies[@]}" "${dep}")
		unset newDependencies[${index}]
		
		depd="$(dirname "${dep}")"
		debug Process ${dep}
		while read subDependency
		do
			[ -z "${subDependency}" ] && continue
			subDependency="$(ns_realpath "${depd}/${subDependency}")"
			if ns_array_contains "${subDependency}" "${dependencies[@]}" \
				|| ns_array_contains "${subDependency}" "${newDependencies[@]}"
			then
				continue
			fi
			
			debug "dep of $(basename "${dep}"): ${subDependency}"		
			newDependencies=("${newDependencies[@]}" "${subDependency}")
		done << EOF
$(xsltproc --xinclude "${temporaryXsltPath}" "${dep}")
EOF

	done
done

if ${addInputFiles}
then
	for f in "${parser_values[@]}"
	do
		dependencies=("${dependencies[@]}" "$(ns_realpath "${f}")")	
	done
fi

for dep in "${dependencies[@]}"
do
	${absolutePath} || dep="$(ns_relativepath "${dep}" "${relativePath}")"
	echo "${dep}"
done
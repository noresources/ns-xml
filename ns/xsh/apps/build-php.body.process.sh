buildphpXsltPath="${nsPath}/xsl/program/${programSchemaVersion}/php"

# Check required templates
for x in parser programinfo embed
do
	tpl="${buildphpXsltPath}/${x}.xsl"
	[ -r "${tpl}" ] || ns_error 2 "Missing XSLT template $(basename "${tpl}")" 
done

if ${generateBase}
then
	buildphpXsltStylesheet="parser.xsl"
elif ${generateInfo}
then
	buildphpXsltStylesheet="programinfo.xsl"
else
	# embed or merge
	buildphpXsltStylesheet="embed.xsl"
fi

buildphpXsltprocOptions=(--xinclude)
[ -z "${parserNamespace}" ] || buildphpXsltprocOptions=("${buildphpXsltprocOptions[@]}" --stringparam prg.php.parser.namespace "${parserNamespace}")   
[ -z "${programNamespace}" ] || buildphpXsltprocOptions=("${buildphpXsltprocOptions[@]}" --stringparam prg.php.programinfo.namespace "${programNamespace}")
[ -z "${programInfoClassname}" ] || buildphpXsltprocOptions=("${buildphpXsltprocOptions[@]}" --stringparam prg.php.programinfo.classname "${programInfoClassname}")

buildphpTemporaryOutput="${outputScriptFilePath}"
[ "${generationMode}" = "generateMerge" ] && buildphpTemporaryOutput="$(ns_mktemp build-php-lib)"

buildphpXsltprocOptions=("${buildphpXsltprocOptions[@]}" \
	-o \
	"${buildphpTemporaryOutput}" \
	"${buildphpXsltPath}/${buildphpXsltStylesheet}" \
	"${xmlProgramDescriptionPath}")  

xsltproc "${buildphpXsltprocOptions[@]}" || ns_error 2 "Failed to generate php classes file"

if [ "${generationMode}" = "generateMerge" ]
then
	firstLine=$(head -n 1 "${generateMerge}")
	if [ "${firstLine:0:2}" = "#!" ]
	then
		(echo "${firstLine}" > "${outputScriptFilePath}" \
		&& cat "${buildphpTemporaryOutput}" >> "${outputScriptFilePath}" \
		&& sed 1d "${generateMerge}"  >> "${outputScriptFilePath}") \
		|| ns_error 3 "Failed to merge PHP class file and PHP program file"
	else
		(echo "#!/usr/bin/env php" > "${outputScriptFilePath}" \
		&& cat "${buildphpTemporaryOutput}" >> "${outputScriptFilePath}" \
		&& cat "${generateMerge}"  >> "${outputScriptFilePath}") \
		|| ns_error 3 "Failed to merge PHP class file and PHP program file"
	fi
	
	chmod 755 "${outputScriptFilePath}" || ns_error 4 "Failed to set exeutable flag on ${outputScriptFilePath}" 
fi

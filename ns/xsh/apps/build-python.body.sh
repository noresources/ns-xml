buildpythonXsltPath="${nsPath}/xsl/program/${programSchemaVersion}/python"

# Check required templates
for x in parser programinfo embed
do
	tpl="${buildpythonXsltPath}/${x}.xsl"
	[ -r "${tpl}" ] || ns_error 2 "Missing XSLT template $(basename "${tpl}")" 
done

buildpythonXsltprocOptions=(--xinclude \
	--stringparam \
	"prg.python.generationMode" \
	"${generationMode}" \
)

if [ "${generationMode}" = "generateBase" ]
then
	buildpythonXsltStylesheet="parser.xsl"
elif [ "${generationMode}" = "generateInfo" ]
then
	buildpythonXsltStylesheet="programinfo.xsl"
	buildpythonXsltprocOptions=("${buildpythonXsltprocOptions[@]}" \
		--stringparam \
		prg.python.parser.modulename \
		"${generateInfo}"
	)
else
	# embed or merge
	buildpythonXsltStylesheet="embed.xsl"
fi

[ -z "${programInfoClassname}" ] || buildpythonXsltprocOptions=("${buildpythonXsltprocOptions[@]}" --stringparam prg.python.programinfo.classname "${programInfoClassname}")

buildpythonTemporaryOutput="${outputScriptFilePath}"
[ "${generationMode}" = "generateMerge" ] && buildpythonTemporaryOutput="$(ns_mktemp build-python-module)"

buildpythonXsltprocOptions=("${buildpythonXsltprocOptions[@]}" \
	--output \
	"${buildpythonTemporaryOutput}" \
	"${buildpythonXsltPath}/${buildpythonXsltStylesheet}" \
	"${xmlProgramDescriptionPath}")  

xsltproc "${xsltprocArgs[@]}" "${buildpythonXsltprocOptions[@]}" || ns_error 2 "Failed to generate python module file"

if [ "${generationMode}" = "generateMerge" ]
then
	firstLine=$(head -n 1 "${generateMerge}")
	if [ "${firstLine:0:2}" = "#!" ]
	then
		(echo "${firstLine}" > "${outputScriptFilePath}" \
		&& cat "${buildpythonTemporaryOutput}" >> "${outputScriptFilePath}" \
		&& sed 1d "${generateMerge}"  >> "${outputScriptFilePath}") \
		|| ns_error 3 "Failed to merge Python module file and Python program file"
	else
		(echo "#!/usr/bin/env python" > "${outputScriptFilePath}" \
		&& cat "${buildpythonTemporaryOutput}" >> "${outputScriptFilePath}" \
		&& cat "${generateMerge}"  >> "${outputScriptFilePath}") \
		|| ns_error 3 "Failed to merge Python module file and Python script file"
	fi
	
	chmod 755 "${outputScriptFilePath}" || ns_error 4 "Failed to set exeutable flag on ${outputScriptFilePath}" 
fi

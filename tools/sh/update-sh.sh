#!/usr/bin/env bash
# Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr)
################################################################################
# Update ns/sh scripts and completion files
################################################################################

relativePathToRoot="../.."

scriptPath="$(dirname "${0}")"
projectPath="${scriptPath}/${relativePathToRoot}"
bashCompletionOutputPath="${projectPath}/resources/bash_completion.d"
bashCompletionStylesheetBasePath="${projectPath}/ns/xsl/program"
bashCompletionStylesheetFileName="bashcompletion.xsl"
cwd="$(pwd)"

cd "${projectPath}"
projectPath="$(pwd)"
cd "${cwd}"

# Rebuild build-shellscript.sh
${projectPath}/tools/sh/refresh-build-shellscript.sh
buildshellscript="${projectPath}/ns/sh/build-shellscript.sh"
xulBuilder="${projectPath}/ns/sh/build-xulapp.sh"

[ -x "${buildshellscript}" ] || (echo "${buildshellscript} not executable" && exit 1)

buildXul=false
singleBuild=""
for ((i=1;${i}<=${#};i++))
do
	if [ "${!i}" == "xul" ]
	then
		buildXul=true
	else
		singleBuild="${!i}"
	fi
done

completionCommands=

appsBasePath="${projectPath}/ns/xsh/apps"
outBasePath="${projectPath}/ns/sh"
while read f
do
	fn="${f%.xsh}"
	b="$(basename "${f}")"
	d="$(dirname "${f}")"
	bn="${b%.xsh}"
	
	[ "${d}" = '.AppleDouble' ] && continue
	
	if [ ! -f "${fn}.xml" ]
	then
		continue
	fi
	
	subPath="${d#${appsBasePath}}"
	
	shOut="${outBasePath}${subPath}/${bn}.sh"
	mkdir -p "$(dirname "${shOut}")"
	
	if [ "${bn}" != "build-shellscript" ]
	then
		if [ ! -z "${singleBuild}" ] && [ "${bn}" != "${singleBuild}" ]
		then
			continue
		fi
		
		echo "Update ${b}"
		if ! ${buildshellscript} -p -x ${fn}.xml -s ${f} -o ${shOut}
		then
			echo "Failed to update ${f}"
			exit 1
		fi
	fi
	
	if [ ! -z "${singleBuild}" ] && [ "${bn}" != "${singleBuild}" ]
	then
		continue
	fi
	
	programSchemaVersion="$(xsltproc --xinclude "${projectPath}/ns/xsl/program/get-version.xsl" "${fn}.xml")"
	#echo "Program schema version ${programSchemaVersion}"
	
	echo "Update bash completion for ${bn}.sh (${bashCompletionOutputPath}/${bn}.sh)"		
	xsltproc --xinclude --stringparam prg.bash.completion.programFileExtension ".sh" "${bashCompletionStylesheetBasePath}/${programSchemaVersion}/${bashCompletionStylesheetFileName}" "${fn}.xml" > "${bashCompletionOutputPath}/${bn}.sh"
		
	if ${buildXul}
	then
		xulOutputPath="${projectPath}/xul"
		xulOptions=(xsh \
			-u \
			-x "${f%xsh}xml" \
			-s "${f}"
		)
		[ -f "${f%xsh}js" ] && xulOptions=("${xulOptions[@]}" -j "${f%xsh}js")
		
		for t in linux osx
		do
			echo "Build XUL application for ${t}"
			mkdir -p "${xulOutputPath}/${t}"
			if ! ${xulBuilder} \
				"${xulOptions[@]}" \
				-t ${t} \
				-o "${xulOutputPath}/${t}" \
				-n 
			then
				echo "Failed to build XUL UI for ${f%xsh} (${t})"
				exit 1
			fi
		done
	fi
done << EOF
$(find "${appsBasePath}" -mindepth 1 -maxdepth 2 -name "*.xsh")
EOF

echo "Update tools"
for f in "${projectPath}/resources/xsh/"*.xsh
do
	o="$(basename "${f}")"
	bn="${o%.xsh}"
	
	o="${o%xsh}sh"
	x="${f%xsh}xml"
	if [ ! -z "${singleBuild}" ] && [ "${bn}" != "${singleBuild}" ]
	then
		continue
	fi

	echo "${o}"
	if [ -f "${x}" ]
	then
		${buildshellscript} -p -x "${x}" -s "${f}" -o "${projectPath}/tools/sh/${o}"
	else
		xsltproc --xinclude -o "${projectPath}/tools/sh/${o}" "${projectPath}/ns/xsl/program/2.0/xsh.xsl" "${f}"
	fi
done

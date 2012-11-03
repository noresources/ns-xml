#!/bin/bash
# Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr)
################################################################################
# Update ns/sh scripts and completion files
################################################################################

relativePathToRoot="../.."

scriptPath="$(dirname "${0}")"
projectPath="${scriptPath}/${relativePathToRoot}"
bashCompletionOutputPath="${projectPath}/resources/bash_completion.d"
bashCompletionInstallPath="${HOME}/.bash_completion.d"
bashCompletionFile="${HOME}/.bash_completion"
bashCompletionStylesheetBasePath="${projectPath}/ns/xsl/program"
bashCompletionStylesheetFileName="bashcompletion.xsl"
cwd="$(pwd)"

cd "${projectPath}"
projectPath="$(pwd)"
cd "${cwd}"

mkdir -p "${bashCompletionInstallPath}"

if [ ! -f "${bashCompletionFile}" ]
then
	touch "${bashCompletionFile}"
fi  

if [ -f "${bashCompletionFile}" ]
then
	cmd="ns_xml_compl()\n{\n\tfor f in \"${bashCompletionInstallPath}\"/*; do . \"\${f}\"; done\n}\nns_xml_compl"
	grepCmd="ns_xml_compl()"
	if ! grep "${grepCmd}" "${bashCompletionFile}" 1>/dev/null 2>&1 
	then
		echo -e "Adding\n---------------------\n${cmd}\n---------------------\nto ${bashCompletionFile}"
		echo -e "${cmd}" >> "${bashCompletionFile}"
	fi 	
fi

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

for f in "${projectPath}/ns/xsh/apps/"*.xsh
do
	fn="${f%.xsh}"
	b="$(basename "${f}")"
	bn="${b%.xsh}"
	shOut="${projectPath}/ns/sh/${bn}.sh"
	if [ "${bn}" != "build-shellscript" ]
	then
		if [ ! -z "${singleBuild}" ] && [ "${bn}" != "${singleBuild}" ]
		then
			#echo "Skip ${bn}"
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
	
	programVersion="$(xsltproc --xinclude "${projectPath}/ns/xsl/program/get-version.xsl" "${fn}.xml")"
	#echo "Program schema version ${programVersion}"
	
	echo "Update bash completion for ${bn}.sh (${bashCompletionOutputPath}/${bn}.sh)"		
	if xsltproc --xinclude --stringparam prg.bash.completion.programFileExtension ".sh" "${bashCompletionStylesheetBasePath}/${programVersion}/${bashCompletionStylesheetFileName}" "${fn}.xml" > "${bashCompletionOutputPath}/${bn}.sh"
	then
		rsync -lprt "${bashCompletionOutputPath}/${bn}.sh" "${bashCompletionInstallPath}"
		completionCommands[${#completionCommands[*]}]=". \"${bashCompletionInstallPath}/${bn}.sh\""
	else
		echo "Error while updating bash completion for ${b}"
		exit 1 
	fi
	
	if ${buildXul}
	then
		xulOutputPath="${projectPath}/xul"
		xulOptions=(xsh \
			-u \
			-x "${f%xsh}xml" \
			-s "${f}" \
			-d
		)
		[ -f "${f%xsh}js" ] && xulOptions=("${xulOptions[@]}" -j "${f%xsh}js")
		
		for t in linux macosx
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
done

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

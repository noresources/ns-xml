#!/bin/bash
# Copyright (c) 2011 by Renaud Guillard (dev@niao.fr)
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

[ -x "${buildshellscript}" ] || (echo "${buildshellscript} not executable" && exit 1)

completionCommands=

for f in  "${projectPath}/ns/xsh/apps/"*.xsh
do
	fn="${f%.xsh}"
	b="$(basename "${f}")"
	bn="${b%.xsh}"
	shOut="${projectPath}/ns/sh/${bn}.sh"
	if [ "${bn}" != "build-shellscript" ]
	then
		echo "Update ${b}"
		if ! ${buildshellscript} -p -x ${fn}.xml -s ${f} -o ${shOut}
		then
			echo "Failed to update ${f}"
			exit 1
		fi
	fi
	
	programVersion="$(xsltproc "${projectPath}/ns/xsl/program/get-version.xsl" "${fn}.xml")"
	echo "Program schema version ${programVersion}"
	
	echo "Update bash completion for ${bn}.sh (${bashCompletionOutputPath}/${bn}.sh)"		
	if xsltproc --xinclude --stringparam prg.bash.completion.programFileExtension ".sh" "${bashCompletionStylesheetBasePath}/${programVersion}/${bashCompletionStylesheetFileName}" "${fn}.xml" > "${bashCompletionOutputPath}/${bn}.sh"
	then
		rsync -lprt "${bashCompletionOutputPath}/${bn}.sh" "${bashCompletionInstallPath}"
		completionCommands[${#completionCommands[*]}]=". \"${bashCompletionInstallPath}/${bn}.sh\""
	else
		echo "Error while updating bash completion for ${b}"
		exit 1 
	fi
done

echo "To update bash completion immediatelly, run:"
for ((i=0;$i<${#completionCommands[*]};i++))
do
	echo "${completionCommands[$i]}"
done
echo

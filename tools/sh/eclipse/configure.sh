#!/bin/sh
# Copyright © 2011-2018 by Renaud Guillard (dev@nore.fr)

ns_realpath2()
{
    local path="${1}"
    local cwd="$(pwd)"
    [ -d "${path}" ] && cd "${path}" && path="."
   
    # -h : exists and is symlink
    while [ -h "${path}" ] ; do path="$(readlink "${path}")"; done
   
    if [ -d "${path}" ]
    then
        path="$( cd -P "$( dirname "${path}" )" && pwd )"
    else
        path="$( cd -P "$( dirname "${path}" )" && pwd )/$(basename "${path}")"
    fi

    cd "${cwd}" 1>/dev/null 2>&1
    echo "${path}"
}

if ! which realpath 1>/dev/null 2>&1
then
realpath()
{
    ns_realpath2 "${@}"
}
fi

scriptPath="$(realpath "$(dirname "${0}")")"
projectPath="$(realpath "${scriptPath}/../../..")"
eclipseProjectRootPath="scripts/eclipse"
eclipseProjectPath="$(realpath "${projectPath}/${eclipseProjectRootPath}")"
projectRelativePath="../.."
resourcePath="$(realpath "${projectPath}/resources/eclipse")"
cwd="$(pwd)"

if ! cd "${eclipseProjectPath}"
then
	exit 1
fi

hgIgnoreFile="${projectPath}/resources/hg/ignores/eclipse"

cat "${resourcePath}/references" | while read line
do
	echo Processing $line
	path="$(echo "${line}" | cut -f 1 -d";")"
	ref="$(echo "${line}" | cut -f 2 -d";")"

	if [ ! -z "${path}" ]
	then
		if [ -L "${ref}" ]
		then
			echo "Remove previous link \"${ref}\""
			rm -f "${ref}"
		fi

		refbase="$(dirname "${path}")"
		if echo "${ref}" | grep "/" 1>/dev/null
		then
			echo "create parent folder(s) ${refbase}"
			mkdir -p "${refbase}"
			#TODO move to refBase
			#TODO change relative path
		fi

		ln -s "${projectRelativePath}/${path}" "${ref}"
		
		# Ignore file in vcs systems
		ignore="${eclipseProjectRootPath}/${ref}"
		# Mercurial
		
		if [ -d "${projectPath}/.hg" ]
		then
			hgIgnoreRule="regexp:^${ignore}$"
			if ! grep -E "${ignore}" "${hgIgnoreFile}" 1>/dev/null 2>&1
			then
				echo "${hgIgnoreRule}" >> "${hgIgnoreFile}"
			fi
		fi
	fi
done

exit 0

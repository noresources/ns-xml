#!/usr/bin/env bash

packageName="ns-xml"
interactive=true
user=""
scriptFilePath="${0}"
scriptDirectoryPath="$(dirname "${scriptFilePath}")"
nsPath="${scriptDirectoryPath}"

for a in "${@}"
do
	[ "${a}" = "-y" ] && interactive=false
done

# Check required programs
for x in uname grep head cut sed rsync find
do
	if ! which ${x} 1>/dev/null 2>&1
	then
		echo "${x} command not found. This command is required to setup ns-xml automatically" 1>&2
		exit 1
	fi
done

prefixDirectoryPath="${HOME}/.local"
profileFilePath="${HOME}/.profile"
completionDirectoryPath="${HOME}/.bash_completion.d/ns"
osxApplicationBundlePath="${HOME}/Applications/ns"

for v in USER USERNAME LOGNAME
do
	if [ ! -z "${!v}" ]
	then
		user="${!v}"
		break
	fi
done

platform="$(uname -s 2>&1)"
isOSX=false
isLinux=false
[ "${platform}" = "Darwin" ] && isOSX=true
[ "${platform}" = "Linux" ] && isLinux=true 

if [ "${user}" = "root" ]
then
	prefixDirectoryPath="/usr/local"
	profileFilePath="${HOME}/.profile"
	completionDirectoryPath="/etc/bash_completion.d/ns"
	osxApplicationBundlePath="/Applications/ns"
fi

if ${interactive}
then
	echo -n "Installation prefix path (default: ${prefixDirectoryPath}):"
	read a
	[ -z "${a}" ] || prefixDirectoryPath="${a}"
	
	echo -n "Bash completion files (default: ${completionDirectoryPath}):"
	read a
	[ -z "${a}" ] || completionDirectoryPath="${a}"
	
	echo -n "Profile file (default: ${profileFilePath}):"
	read a
	[ -z "${a}" ] || profileFilePath="${a}"
	
	if ${isOSX}
	then
		echo -n "Application bundle path (default: ${osxApplicationBundlePath}):"
		read a
		[ -z "${a}" ] || osxApplicationBundlePath="${a}"
	fi
fi

for f in "${profileFilePath}" "${profileFilePath}.tmp"
do
	if [ ! -f "${f}" ]
	then
		touch "${f}"
	fi

	if [ ! -w "${f}" ]
	then
		echo "Unable to write to '${f}'" 1>&2
		exit 1 
	fi
done

for d in "${completionDirectoryPath}" \
		"${prefixDirectoryPath}/share/ns" \
		"${prefixDirectoryPath}/bin/ns"
do
	if ! mkdir -p "${d}"
	then
		echo "Unable to create '${d}'" 1>&2
		exit 1
	fi
	
	if [ ! -w "${d}" ]
	then
		echo "Unable to write to '${d}'" 1>&2
		exit 1		
	fi
done

echo " - Copy files"
echo "  - library files to '${prefixDirectoryPath}/share/ns'"
rsync -lprt "${nsPath}/share/" "${prefixDirectoryPath}/share/ns/"
echo "  - binaries to '${prefixDirectoryPath}/bin/ns'"
rsync -lprt "${nsPath}/bin/" "${prefixDirectoryPath}/bin/ns/"
echo "  - bash completion files to '${completionDirectoryPath}'"
rsync -lprt "${nsPath}/bash_completion.d/" "${completionDirectoryPath}/"

if ${isOSX}
then
	echo "  - Application bundles to '${osxApplicationBundlePath}'"
	rsync -lprt "${nsPath}/Applications/" "${osxApplicationBundlePath}/"
elif ${isLinux}
then
	cwd="$(pwd)"
	while read f
	do
		d="$(dirname "${f}")"
		cd "${d}"
		d="$(pwd)"
		cd "${cwd}"
		appName="$(basename "${d}")"
		executablePath="${prefixDirectoryPath}/bin/ns/${appName}/${appName}"
		shortcut="${prefixDirectoryPath}/share/applications/${appName}.desktop"
		echo "  - Create shortcut for ${appName}"
		cat > "${shortcut}" << EOD
[Desktop Entry]
Name=$(grep -e "^Name=" "${f}" | head -n 1 | cut -f 2- -d"=")
Exec=${executablePath}
Terminal=false
Type=Application
Encoding=UTF-8
Categories=Application;
EOD
	done << EOF
	$(find "${nsPath}/bin/" -name "application.ini")
EOF
fi

echo " - Edit profile"
if grep -q "\[ns-xml:autoconfig" "${profileFilePath}" \
	&& grep -q "\]ns-xml:autoconfig" "${profileFilePath}"
then
	echo "  - Previous configuration found"
	begin=$(grep -n "\[ns-xml:autoconfig" "${profileFilePath}" | head -n 1 | cut -f 1 -d":")
	end=$(grep -n "\]ns-xml:autoconfig" "${profileFilePath}" | head -n 1 | cut -f 1 -d":")
	
	if [ ${begin} -lt ${end} ]
	then
		echo "  - Remove existing configuration"
		sed "${begin},${end}d" "${profileFilePath}" > "${profileFilePath}.tmp"
		mv "${profileFilePath}.tmp" "${profileFilePath}"		
	fi
fi

echo "  - Add new configuration"
cat >> "${profileFilePath}" << EOF
### [ns-xml:autoconfig $(date +%FT%T)
# ns-xml prefix path
export NSXML_PATH="${prefixDirectoryPath}"
# Executable path
export PATH="\${NSXML_PATH}/bin/ns:\${PATH}"
# Bash completion
shell="\$(readlink /proc/\$\$/exe | sed "s/.*\/\([a-z]*\)[0-9]*/\1/g")"
[ "\${shell}" = "bash" ] && for f in "${completionDirectoryPath}"/*; do . "\${f}"; done
### ]ns-xml:autoconfig $(date +%FT%T)
EOF

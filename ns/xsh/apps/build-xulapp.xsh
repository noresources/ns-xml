<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->
<sh:program xmlns:prg="http://xsd.nore.fr/program" xmlns:sh="http://xsd.nore.fr/bash" xmlns:xi="http://www.w3.org/2001/XInclude">
	<sh:info>
		<xi:include href="build-xulapp.xml" />
	</sh:info>
	<sh:functions>
		<xi:include href="../lib/filesystem/filesystem.xml" xpointer="xmlns(sh=http://xsd.nore.fr/bash)xpointer(//sh:function[@name = 'ns_realpath'])" />
		<sh:function name="log">
			<sh:body>echo "${@}" >> "${logFile}"</sh:body>
		</sh:function>
		<sh:function name="info">
			<sh:body><![CDATA[
echo "${@}"
${isDebug} && log "${@}"
		]]></sh:body>
		</sh:function>
		<sh:function name="error">
			<sh:body><![CDATA[
echo "${@}"
${isDebug} && log "${@}"
exit 1
		]]></sh:body>
		</sh:function>
		<xi:include href="functions.xml" xpointer="xmlns(sh=http://xsd.nore.fr/bash)xpointer(//sh:function[@name = 'xml_validate'])" />
	</sh:functions>
	<sh:code><![CDATA[
logFile="/tmp/$(basename "${0}").log"
${isDebug} && echo "$(date): ${0} ${@}" > "${logFile}"

scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
nsPath="$(ns_realpath "${scriptPath}/../..")/ns"
programVersion="2.0"

hostPlatform="linux"
macOSXVersion=""
macOSXFrameworkName="XUL.framework"
macOSXFrameworkPath="/Library/Frameworks/${macOSXFrameworkName}"
firefoxPath="/Applications/Firefox.app"
macOSXMajorVersion=""
macOSXMinorVersion=""
macOSXPatchVersion=""
macOSXArchitecture=""

# Check (common) required programs
for x in xmllint xsltproc egrep cut expr head tail uuidgen 
do
	if ! which $x 1>/dev/null 2>&1
	then
		error "${x} program not found"
	fi
done

if [ "$(uname)" == "Darwin" ]
then
	hostPlatform="macosx"
	macOSXVersion="$(sw_vers -productVersion)"
	macOSXMajorVersion="$(echo "${macOSXVersion}" | cut -f 1 -d".")"
	macOSXMinorVersion="$(echo "${macOSXVersion}" | cut -f 2 -d".")"
	macOSXPatchVersion="$(echo "${macOSXVersion}" | cut -f 3 -d".")"
	macOSXArchitecture="$(uname -m)"
fi

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

if [ "${targetPlatform}" == "host" ]
then
	targetPlatform="${hostPlatform}"
fi

# Guess ns-xml path
if [ ! -z "${nsxmlPath}" ]
then
	if ${nsxmlPathRelative}
	then
		nsPath="${scriptPath}/${nsxmlPath}"
	else
		nsPath="${nsxmlPath}"
	fi
	
	if [ ! -d "${nsPath}" ]
	then
		error "Invalid ns path \"${nsPath}\""
	fi
	
	nsPath="$(ns_realpath "${nsPath}")"
fi

# finding schema version
programVersion="$(xsltproc "${nsPath}/xsl/program/get-version.xsl" "${xmlProgramDescriptionPath}")"
info "Program schema version ${programVersion}"

if [ ! -f "${nsPath}/xsd/program/${programVersion}/program.xsd" ]
then
	error "Invalid program schema version"
fi  

requiredTemplates="xul-ui-mainwindow xul-js-mainwindow xul-js-application get-programinfo"
if [ "${targetPlatform}" == "macosx" ]
then
	requiredTemplates="${requiredTemplates} macosx-plist xul-ui-hiddenwindow"
fi

for template in ${requiredTemplates}
do
	stylesheet="${nsPath}/xsl/program/${programVersion}/${template}.xsl"
	if [ ! -f "${stylesheet}" ]
	then
		error "Missing XSLT stylesheet file \"${stylesheet}\""
	fi
done

# Validate program scheam
if ! ${skipValidation} && ! xml_validate "${nsPath}/xsd/program/${programVersion}/program.xsd" "${xmlProgramDescriptionPath}"
then
	error "program ${programVersion} XML schema error - abort"
fi

programStylesheetPath="${nsPath}/xsl/program/${programVersion}"
programInfoStylesheetPath="${programStylesheetPath}/get-programinfo.xsl"

appName="$(xsltproc --stringparam name name "${programInfoStylesheetPath}" "${xmlProgramDescriptionPath}")"
appDisplayName="$(xsltproc --stringparam name label "${programInfoStylesheetPath}" "${xmlProgramDescriptionPath}")"
xulAppName="$(echo "${appName}" | sed "s/[^a-zA-Z0-9]//g")"
appAuthor="$(xsltproc --stringparam name author "${programInfoStylesheetPath}" "${xmlProgramDescriptionPath}")"
appVersion="$(xsltproc --stringparam name version "${programInfoStylesheetPath}" "${xmlProgramDescriptionPath}")"
appUUID="$(uuidgen)"
appBuildID="$(date +%Y%m%d-%s)"

# Append application name to output path (auto)
outputPathBase="$(basename "${outputPath}")"

[ "${outputPathBase}" != "${appName}" ] && [ "${outputPathBase}" != "${appDisplayName}" ] && outputPath="${outputPath}/${appDisplayName}"
appRootPath="${outputPath}"

if [ "${targetPlatform}" == "macosx" ]
then
	outputPath="${outputPath}.app"
	appRootPath="${outputPath}/Contents/Resources"

	info "Mac OS X version: ${macOSXVersion}"
	info "Mac OS X architecture: ${macOSXArchitecture}"
fi

# Check output folder
preexistantOutputPath=false
if [ -d "${appRootPath}" ] 
then
	(! ${update}) && error " - Folder \"${appRootPath}\" already exists. Set option --update to force update"
	(${update} && [ ! -f "${appRootPath}/application.ini" ]) && error " - Folder \"${appRootPath}\" exists - update option is set, but the folder doesn't seems to be a valid xul application folder"
	preexistantOutputPath=true
else
	mkdir -p "${outputPath}" || error "Unable to create output path \"${outputPath}\""
	mkdir -p "${appRootPath}" || error "Unable to create application root path \"${appRootPath}\""
	outputPath="$(ns_realpath "${outputPath}")"
	appRootPath="$(ns_realpath "${appRootPath}")"
fi

appIniFile="${appRootPath}/application.ini"
appPrefFile="${appRootPath}/defaults/preferences/pref.js"
appCssFile="${appRootPath}/chrome/content/${xulAppName}.css"
appMainXulFile="${appRootPath}/chrome/content/${xulAppName}.xul"
appOverlayXulFile="${appRootPath}/chrome/content/${xulAppName}-overlay.xul"
appHiddenWindowXulFile="${appRootPath}/chrome/content/${xulAppName}-hiddenwindow.xul"
rebuildScriptFile="${appRootPath}/sh/_rebuild.sh"
commandLauncherFile="${appRootPath}/sh/${xulAppName}.sh"

info "XUL application will be built in \"${outputPath}\""
	  
if ${preexistantOutputPath} && ${update}
then
	info " - Application will be updated"
	if egrep "ID=\{[a-fA-F0-9-]*\}" "${appIniFile}" 1>/dev/null 2>&1
	then
		egrep "ID=\{[a-fA-F0-9-]*\}" "${appIniFile}" | sed "s/\([a-fA-F0-9-]*\)/\1/g" 1>/dev/null 2>&1
		appUUID="$(egrep "ID=\{[a-fA-F0-9-]*\}" "${appIniFile}" | cut -f 2 -d"{" | cut -f 1 -d"}")"
		info " - Keep application UUID ${appUUID}"
	fi
fi

if ! mkdir -p "${appRootPath}/sh"
then
	error "Unable to create shell sub directory"
fi
commandLauncherFile="$(ns_realpath "${commandLauncherFile}")"

if [ "${launcherMode}" == "launcherModeXsh" ]
then
	info " - Generate shell file"
	debugParam=""
	if ${debugMode}
	then
		debugParam="--stringparam prg.debug \"true()\""
	fi
	
	prefixParam=""
	if ${prefixSubcommandBoundVariableName}
	then
		prefixParam="--stringparam prg.sh.parser.prefixSubcommandOptionVariable \"true()\""
	fi

	# Validate bash scheam
	if ! ${skipValidation} && ! xml_validate "${nsPath}/xsd/bash.xsd" "${xmlShellFileDescriptionPath}"
	then
		error "bash XML schema error - abort"
	fi
		
	xshXslTemplatePath="${nsPath}/xsl/program/${programVersion}/xsh.xsl"
	xmlShellFileDescriptionPath="$(ns_realpath "${xmlShellFileDescriptionPath}")"
	if ! xsltproc --xinclude -o "${commandLauncherFile}" ${prefixParam} ${debugParam} "${xshXslTemplatePath}" "${xmlShellFileDescriptionPath}"
	then
		echo "Fail to process xsh file \"${xmlShellFileDescriptionPath}\""
		exit 5
	fi
		
elif [ "${launcherMode}" == "launcherModeExistingCommand" ]
then 
	info " - Generate command launcher"
	echo -ne "#!/bin/bash\n${launcherModeExistingCommand} \${@}" > "${commandLauncherFile}"
fi
chmod 755 "${commandLauncherFile}"

info " - Creating XUL application structure"
for d in "chrome/ns" "chrome/content" "defaults/preferences" "extensions"
do
	mkdir -p "${appRootPath}/${d}" || error "Unable to create \"${d}\""
done

info " - Copy ns-xml required files"
for d in xbl jsm xpcom
do
	rsync -Lprt "${nsPath}/${d}" "${appRootPath}/chrome/ns/"
done

if [ ${#nsxmlAdditionalSources[*]} -gt 0 ]
then
	info " - Copy ns-xml additianal files"
	for ((i=0;${i}<${#nsxmlAdditionalSources[*]};i++))
	do
		d="${nsxmlAdditionalSources[${i}]}"
		info " -- ${d} -> ${appRootPath}/chrome/ns"
		rsync -Lprt "${nsPath}/${d}" "${appRootPath}/chrome/ns/"
	done
fi

info " - Generating manifest"
echo "content ${xulAppName} file:chrome/content/" > "${appRootPath}/chrome.manifest"
echo "resource ns file:chrome/ns/" >> "${appRootPath}/chrome.manifest"
# components
for c in value-autocomplete
do
	f="${nsPath}/xpcom/${c}.js"
	cid="$(cat "${f}" | egrep -h "CLASS_ID[ \t]=" | sed "s/.*('\(.*\)').*/\1/g")"
	contract="$(cat "${f}" | egrep -h "CONTRACT_ID[ \t]=" | sed "s/.*'\(.*\)'.*/\1/g")"
	echo "component {${cid}} chrome/ns/xpcom/${c}.js" >> "${appRootPath}/chrome.manifest"
	echo "contract ${contract} {${cid}}" >> "${appRootPath}/chrome.manifest"  
done 

echo "[App]
Version=${appVersion}
Vender=${appAuthor}
Name=${appDisplayName}
BuildID=${appBuildID}
ID={${appUUID}}
[Gecko]
MinVersion=2.0
MaxVersion=99.0.0" > "${appIniFile}"

echo "pref(\"toolkit.defaultChromeURI\", \"chrome://${xulAppName}/content/${xulAppName}.xul\");" > "${appPrefFile}"

if [ "${targetPlatform}" == "macosx" ]
then
	echo "pref(\"browser.hiddenWindowChromeURL\", \"chrome://${xulAppName}/content/$(basename "${appHiddenWindowXulFile}")\");" >> "${appPrefFile}" 
fi

if ${debugMode}
then
	echo "pref(\"browser.dom.window.dump.enabled\", true);
pref(\"javascript.options.showInConsole\", true);
pref(\"javascript.options.strict\", true);
pref(\"nglayout.debug.disable_xul_cache\", true);
pref(\"nglayout.debug.disable_xul_fastload\", true);" >> "${appPrefFile}"

	# Adding 'rebuild command script"
	# TODO need update for new args
	mkdir -p "$(dirname "${rebuildScriptFile}")"
	echo "#!/bin/bash" > "${rebuildScriptFile}"
	echo -en "$(ns_realpath "${0}") --update --debug --xml-description \"$(ns_realpath "${xmlProgramDescriptionPath}")\"" >> "${rebuildScriptFile}"
	echo -en " --output \"$(ns_realpath "${outputPath}")\"" >> "${rebuildScriptFile}"
	if [ "${launcherMode}" == "launcherModeXsh" ]
	then
		echo -en " --shell \"$(ns_realpath "${xmlShellFileDescriptionPath}")\"" >> "${rebuildScriptFile}"
		
	elif [ "${launcherMode}" == "launcherModeExistingCommand" ]
	then
		echo -en " --command" >> "${rebuildScriptFile}"
	fi
	
	echo "" >> "${rebuildScriptFile}"
	
	chmod 755  "${rebuildScriptFile}"
fi

info " - Building UI layout"
#The xul for the main window
xsltOption="--stringparam prg.xul.appName ${xulAppName}"
[ -z "${windowWidth}" ] || xsltOption="${xsltOption} --param prg.xul.windowWidth ${windowWidth}"
[ -z "${windowHeight}" ] || xsltOption="${xsltOption} --param prg.xul.windowHeight ${windowHeight}"
 
xsltOption="${xsltOption} --stringparam prg.xul.platform ${targetPlatform}"
 
if ${debugMode}
then
	xsltOption="${xsltOption} --param prg.debug \"true()\""
fi

info " -- Main window"
if ! xsltproc ${xsltOption} "${programStylesheetPath}/xul-ui-mainwindow.xsl" "${xmlProgramDescriptionPath}" > "${appMainXulFile}"  
then
	error "Error while building XUL main window layout (${appMainXulFile} - ${xsltOption})"
fi

info " -- Overlay"
if ! xsltproc ${xsltOption} "${programStylesheetPath}/xul-ui-overlay.xsl" "${xmlProgramDescriptionPath}" > "${appOverlayXulFile}"  
then
	error "Error while building XUL overlay layout (${appOverlayXulFile} - ${xsltOption})"
fi

if [ "${targetPlatform}" == "macosx" ]
then
	info " -- Mac OS X hidden window"
	if ! xsltproc -o "${appHiddenWindowXulFile}" ${xsltOption} "${programStylesheetPath}/xul-ui-hiddenwindow.xsl" "${xmlProgramDescriptionPath}" 
	then
		error "Error while building XUL hidden window layout (${appHiddenWindowXulFile} - ${xsltOption})"
	fi 
fi

info " - Building CSS stylesheet"
rm -f "${appCssFile}"
for d in "${nsPath}/xbl" "${nsPath}/xbl/program/${programVersion}"
do
	find "${d}" -maxdepth 1 -mindepth 1 -name "*.xbl" | while read f
	do
		b="${f#${nsPath}/xbl/}"
		cssXsltOptions="--param resourceURI \"resource://ns/xbl/${b}\""
		if [ ! -f "${appCssFile}" ]
		then
			cssXsltOptions="${cssXsltOptions} --param xbl.css.displayHeader \"true()\""
		fi
		
		info " -- Adding ${f}"
		if ! xsltproc ${cssXsltOptions} "${nsPath}/xsl/languages/xbl-css.xsl" "${f}" >> "${appCssFile}"
		then
			error "Failed to add CSS binding rules for XBL \"${f}\" (${cssXsltOptions})"
		fi
	done 
done

info " - Building Javascript code"
if ! xsltproc ${xsltOption} "${programStylesheetPath}/xul-js-application.xsl" "${xmlProgramDescriptionPath}" > "${appRootPath}/chrome/content/${xulAppName}.jsm"  
then
	error "Error while building XUL application code"
fi

if ! xsltproc ${xsltOption} "${programStylesheetPath}/xul-js-mainwindow.xsl" "${xmlProgramDescriptionPath}" > "${appRootPath}/chrome/content/${xulAppName}.js"  
then
	error "Error while building XUL main window code"
fi

userInitializationScriptOutputPath="${appRootPath}/chrome/content/${xulAppName}-user.js"
if [ ! -z "${userInitializationScript}" ]
then
	info " - Add user-defined initialization script"
	rsync -Lprt "${userInitializationScript}" "${userInitializationScriptOutputPath}"
	chmod 644 "${userInitializationScriptOutputPath}"
else
	# Remove if any previous script
	[ -r "${userInitializationScriptOutputPath}" ] && rm -f "${userInitializationScriptOutputPath}" 
fi

if [ "${targetPlatform}" == "macosx" ]
then
	info " - Create/Update Mac OS X application bundle structure"
	# Create structure
	mkdir -p "${outputPath}/Contents/MacOS"
	mkdir -p "${outputPath}/Contents/Resources"
	
	info " - Create/Update Mac OS X application property list"
	if ! xsltproc ${xsltOption} --stringparam prg.xul.buildID "${appBuildID}" "${programStylesheetPath}/macosx-plist.xsl" "${xmlProgramDescriptionPath}" > "${outputPath}/Contents/Info.plist"  
	then
		error "Error while building XUL main window code"
	fi
fi

info " - Create/Update application launcher"
launcherPath=""
if [ "${targetPlatform}" == "macosx" ]
then
	launcherPath="${outputPath}/Contents/MacOS/xulrunner"
else
	launcherPath="${outputPath}/${appName}"
fi

cat > "${launcherPath}" << EOF
#!/bin/bash
ns_realpath()
{
	local path="\${1}"
	local cwd="\$(pwd)"
	[ -d "\${path}" ] && cd "\${path}" && path="."
	
	# -h : exists and is symlink
	while [ -h "\${path}" ] ; do path="\$(readlink "\${path}")"; done
	
	if [ -d "\${path}" ]
	then
		path="\$(cd -P "\$(dirname "\${path}")" && pwd)"
	else
		path="\$(cd -P "\$(dirname "\${path}")" && pwd)/\$(basename "\${path}")"
	fi
	
	cd "\${cwd}" 1>/dev/null 2>&1
	echo "\${path}"
}
buildPlatform="${targetPlatform}"
debug=${debugMode}
platform="linux"
if [ "\$(uname)" == "Darwin" ]
then
	platform="macosx"
fi

scriptPath="\$(ns_realpath "\$(dirname "\${0}")")"
appIniPath="\$(ns_realpath "\${scriptPath}/application.ini")"
logFile="/tmp/\$(basename "\${0}").log"
if [ "\${buildPlatform}" == "macosx" ]
then
	appIniPath="\$(ns_realpath "\${scriptPath}/../Resources/application.ini")"
fi
if [ "\${platform}" == "macosx" ]
then
	macOSXArchitecture="\$(uname -m)"
	cmdPrefix=""
	if [ "\${macOSXArchitecture}" = "i386" ]
	then
		cmdPrefix="arch -i386"
	fi
fi

debug()
{
	echo "\${@}"
	[ \${debugMode} ] && echo "\${@}" >> "\${logFile}"
}

[ \${debugMode} ] && echo "\$(date)" > "\${logFile}"
debug "Args: \${@}"

# Trying Xul.framework (Mac OS X)
use_framework()
{	
	debug use_framwork
	
	minXulFrameworkVersion=4
	for xul in "/Library/Frameworks/XUL.framework" "\${HOME}/Library/Frameworks/XUL.framework"
	do
		debug "Check \${xul}"
		if [ -x "\${xul}/xulrunner-bin" ]
		then
			xulFrameworkVersion="\$(readlink "\${xul}/Versions/Current" | cut -f 1 -d.)"
			debug " Version: \${xulFrameworkVersion}"
			if [ \${xulFrameworkVersion} -ge \${minXulFrameworkVersion} ] 
			then
				debug " Using \${xul}"
				xul="\$(ns_realpath "\${xul}/Versions/Current")"
				PATH="\${xul}:\${PATH}"
				debug " PATH: \${PATH}"
				echo \${cmdPrefix} "\${xul}/xulrunner" -app "\${appIniPath}"
				\${cmdPrefix} "\${xul}/xulrunner" -app "\${appIniPath}"
				exit 0
			fi
		fi
	done
	
	return 1
}

# Trying firefox (assumes a version >= 4)
use_firefox()
{
	debug use_firefox
	if [ "\${platform}" == "macosx" ]
	then
		for ff in "/Applications/Firefox.app/Contents/MacOS/firefox-bin" "\${HOME}/Applications/Firefox.app/Contents/MacOS/firefox-bin"
		do
			debug "Check \${ff}" 
			if [ -x "\${ff}" ]
			then
				debug " Using \${ff}" 
				\${cmdPrefix} \${ff} -app "\${appIniPath}"
				exit 0
			fi
		done
	else
		if which firefox 1>/dev/null 2>&1
		then
			firefox -app "\${appIniPath}"
			return 0
		fi
	fi
	
	return 1
}

use_xulrunner()
{
	for x in xulrunner xulrunner-2.0
	do
		if which "\${x}" 1>/dev/null 2>&1
		then
			v="\$(\${x} --gre-version | cut -f 1 -d".")"
			if [ ! -z "\${v}" ] && [ \${v} -ge 2 ]
			then
				"\${x}" "\${appIniPath}"
				return 0
			fi
		fi
	done
	return 1
}

debug "Build platform: \${buildPlatform}"
debug "Platform: \${platform}"
debug "Application: \${appIniPath}"
if [ "\${platform}" == "macosx" ]
then
	use_framework || use_xulrunner || use_firefox
else 
	use_xulrunner || use_firefox
fi
EOF
chmod 755 "${launcherPath}"
]]></sh:code>
</sh:program>

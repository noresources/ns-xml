scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
nsPath="$(ns_realpath "$(nsxml_installpath "${scriptPath}/..")")"
programSchemaVersion="2.0"
hostPlatform="linux"
macOSXVersion=""
macOSXFrameworkName="XUL.framework"
macOSXFrameworkPath="/Library/Frameworks/${macOSXFrameworkName}"
firefoxPath="/Applications/Firefox.app"
macOSXMajorVersion=""
macOSXMinorVersion=""
macOSXPatchVersion=""
macOSXArchitecture=""

logFile="/tmp/$(basename "${0}").log"
${isDebug} && echo "$(date): ${0} ${@}" > "${logFile}"

# Check (common) required programs
for x in xmllint xsltproc egrep cut expr head tail uuidgen 
do
	if ! which $x 1>/dev/null 2>&1
	then
		ns_error "${x} program not found"
	fi
done

if [ "$(uname)" == "Darwin" ]
then
	hostPlatform="osx"
	macOSXVersion="$(sw_vers -productVersion)"
	macOSXMajorVersion="$(echo "${macOSXVersion}" | cut -f 1 -d".")"
	macOSXMinorVersion="$(echo "${macOSXVersion}" | cut -f 2 -d".")"
	macOSXPatchVersion="$(echo "${macOSXVersion}" | cut -f 3 -d".")"
	macOSXArchitecture="$(uname -m)"
fi

# Default values for windowWidth & windowHeight options
defaultWindowWidth=1024
defaultWindowHeight=768

if ! parse "${@}"
then
	if ${displayHelp}
	then
		usage ${parser_subcommand}
		exit 0
	fi
	
	parse_displayerrors
	exit 1
fi

if ${displayHelp}
then
	usage ${parser_subcommand}
	exit 0
fi

builderFunction="$(echo -n "build_${parser_subcommand}" | sed "s,-,_,g")"
if [ "$(type -t ${builderFunction})" != "function" ]
then
	ns_error "Missing subcommand name"
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
		ns_error "Invalid ns path \"${nsPath}\""
	fi
	
	nsPath="$(ns_realpath "${nsPath}")"
fi

# find schema version
programSchemaVersion="$(xsltproc \
	--xinclude \
	--stringparam namespacePrefix 'http://xsd.nore.fr/program' \
	--stringparam defaultVersion 2.0 \
	"${nsPath}/xsl/schema-version.xsl" \
	"${xmlProgramDescriptionPath}"
)"
info "Program schema version ${programSchemaVersion}"

if [ ! -f "${nsPath}/xsd/program/${programSchemaVersion}/program.xsd" ]
then
	ns_error "Invalid program interface definition schema version"
fi  

# Check required templates
requiredTemplates="ui-mainwindow js-mainwindow js-application ../get-programinfo"
if [ "${targetPlatform}" == "osx" ]
then
	requiredTemplates="${requiredTemplates} osx-plist ui-hiddenwindow"
fi

for template in ${requiredTemplates}
do
	stylesheet="${nsPath}/xsl/program/${programSchemaVersion}/xul/${template}.xsl"
	if [ ! -f "${stylesheet}" ]
	then
		ns_error "Missing XSLT stylesheet file \"${stylesheet}\""
	fi
done

# Validate program scheam
if ! ${skipValidation} && ! xml_validate "${nsPath}/xsd/program/${programSchemaVersion}/program.xsd" "${xmlProgramDescriptionPath}"
then
	ns_error "program ${programSchemaVersion} XML schema error - abort"
fi

programStylesheetPath="${nsPath}/xsl/program/${programSchemaVersion}"
programInfoStylesheetPath="${programStylesheetPath}/get-programinfo.xsl"

appName="$(xsltproc --xinclude --stringparam name name "${programInfoStylesheetPath}" "${xmlProgramDescriptionPath}")"
appDisplayName="$(xsltproc --xinclude --stringparam name label "${programInfoStylesheetPath}" "${xmlProgramDescriptionPath}")"
xulAppName="$(echo "${appName}" | sed "s/[^a-zA-Z0-9]//g")"
appAuthor="$(xsltproc --xinclude --stringparam name author "${programInfoStylesheetPath}" "${xmlProgramDescriptionPath}")"
appVersion="$(xsltproc --xinclude --stringparam name version "${programInfoStylesheetPath}" "${xmlProgramDescriptionPath}")"
appUUID="$(uuidgen)"
appBuildID="$(date +%Y%m%d-%s)"

# Append application name to output path (auto)
outputPathBase="$(basename "${outputPath}")"

if [ "${outputPathBase}" != "${appName}" ] && [ "${outputPathBase}" != "${appDisplayName}" ]
then
	if [ "${targetPlatform}" == "osx" ]
	then
		outputPath="${outputPath}/${appDisplayName}"
	else
		outputPath="${outputPath}/${appName}"
	fi
fi
appRootPath="${outputPath}"

if [ "${targetPlatform}" == "osx" ]
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
	(! ${update}) && ns_error " - Folder \"${appRootPath}\" already exists. Set option --update to force update"
	(${update} && [ ! -f "${appRootPath}/application.ini" ]) && ns_error " - Folder \"${appRootPath}\" exists - update option is set, but the folder doesn't seems to be a valid xul application folder"
	preexistantOutputPath=true
else
	mkdir -p "${outputPath}" || ns_error "Unable to create output path \"${outputPath}\""
	mkdir -p "${appRootPath}" || ns_error "Unable to create application root path \"${appRootPath}\""
fi

outputPath="$(ns_realpath "${outputPath}")"
appRootPath="$(ns_realpath "${appRootPath}")"

appIniFile="${appRootPath}/application.ini"
appPrefFile="${appRootPath}/defaults/preferences/pref.js"
appCssFile="${appRootPath}/chrome/content/${xulAppName}.css"
appMainXulFile="${appRootPath}/chrome/content/${xulAppName}.xul"
appOverlayXulFile="${appRootPath}/chrome/content/${xulAppName}-overlay.xul"
appHiddenWindowXulFile="${appRootPath}/chrome/content/${xulAppName}-hiddenwindow.xul"
xulScriptBasePath="${appRootPath}/sh"

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

mkdir -p "${xulScriptBasePath}" || ns_error "Unable to create shell sub directory"

xulScriptBasePath="$(ns_realpath "${xulScriptBasePath}")"
rebuildScriptFile="${xulScriptBasePath}/_rebuild.sh"
commandLauncherFile="${xulScriptBasePath}/${xulAppName}"
commandLauncherFile="$(ns_realpath "${commandLauncherFile}")"

${builderFunction} || ns_error "Failed to build ${commandLauncherFile}"
chmod 755 "${commandLauncherFile}"

info " - Creating XUL application structure"
for d in "chrome/ns" "chrome/content" "defaults/preferences" "extensions"
do
	mkdir -p "${appRootPath}/${d}" || ns_error "Unable to create \"${d}\""
done

info " - Copy ns-xml required files"
for d in xbl jsm xpcom
do
	rsync -Lprt "${nsPath}/${d}" "${appRootPath}/chrome/ns/"
done

if ${addNsXml}
then
	info " - Copy ns-xml optional files"
	for d in sh xsl 
	do
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

if [ "${targetPlatform}" == "osx" ]
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
	echo -en "$(ns_realpath "${0}") ${parser_subcommand} --update --debug --xml-description \"$(ns_realpath "${xmlProgramDescriptionPath}")\"" >> "${rebuildScriptFile}"
	echo -en " --output \"$(ns_realpath "${outputPath}")\"" >> "${rebuildScriptFile}"
	# TODO 
	if [ "${parser_subcommand}" == "xsh" ]
	then
		echo -en " --shell \"$(ns_realpath "${xsh_xmlShellFileDescriptionPath}")\"" >> "${rebuildScriptFile}"
	elif [ "${parser_subcommand}" == "python" ]
	then
		echo -en " --python \"$(ns_realpath "${python_pythonScriptPath}")\" --module-name ${python_moduleName}" >> "${rebuildScriptFile}"
	elif [ "${parser_subcommand}" == "command" ]
	then
		echo -en " --command \"$(ns_realpath "${existingCommandPath}")\"" >> "${rebuildScriptFile}"
	fi
	
	echo "" >> "${rebuildScriptFile}"
	chmod 755 "${rebuildScriptFile}"
fi

info " - Building UI layout"
#The xul for the main window
xsltOptions="--xinclude --stringparam prg.xul.appName ${xulAppName}"
# Do not force width and height if it was not set by the user
# The XUL XSLT stylesheets are made to use the same default values as build-xulapp 
[ -z "${windowWidth}" ] || [ "${defaultWindowWidth}" = "${windowWidth}" ] || xsltOptions="${xsltOptions} --param prg.xul.windowWidth ${windowWidth}"
[ -z "${windowHeight}" ] || [ "${defaultWindowHeight}" = "${windowHeight}" ] || xsltOptions="${xsltOptions} --param prg.xul.windowHeight ${windowHeight}"
 
xsltOptions="${xsltOptions} --stringparam prg.xul.platform ${targetPlatform}"
 
if ${debugMode}
then
	xsltOptions="${xsltOptions} --param prg.debug \"true()\""
fi

info " -- Main window"
if ! xsltproc ${xsltOptions} -o "${appMainXulFile}" "${programStylesheetPath}/xul/ui-mainwindow.xsl" "${xmlProgramDescriptionPath}"  
then
	ns_error "Error while building XUL main window layout (${appMainXulFile} - ${xsltOptions})"
fi

info " -- Overlay"
if ! xsltproc ${xsltOptions} -o "${appOverlayXulFile}" "${programStylesheetPath}/xul/ui-overlay.xsl" "${xmlProgramDescriptionPath}"  
then
	ns_error "Error while building XUL overlay layout (${appOverlayXulFile} - ${xsltOptions})"
fi

if [ "${targetPlatform}" == "osx" ]
then
	info " -- Mac OS X hidden window"
	if ! xsltproc ${xsltOptions} -o "${appHiddenWindowXulFile}" "${programStylesheetPath}/xul/ui-hiddenwindow.xsl" "${xmlProgramDescriptionPath}" 
	then
		ns_error "Error while building XUL hidden window layout (${appHiddenWindowXulFile} - ${xsltOptions})"
	fi 
fi

info " - Building CSS stylesheet"
rm -f "${appCssFile}"
for d in "${nsPath}/xbl" "${nsPath}/xbl/program/${programSchemaVersion}"
do
	find "${d}" -maxdepth 1 -mindepth 1 -name "*.xbl" | while read f
	do
		b="${f#${nsPath}/xbl/}"
		cssXsltOptions="--xinclude --param resourceURI \"resource://ns/xbl/${b}\""
		if [ ! -f "${appCssFile}" ]
		then
			cssXsltOptions="${cssXsltOptions} --param xbl.css.displayHeader \"true()\""
		fi
		
		info " -- Adding ${f}"
		if ! xsltproc ${cssXsltOptions} "${nsPath}/xsl/languages/xbl-css.xsl" "${f}" >> "${appCssFile}"
		then
			ns_error "Failed to add CSS binding rules for XBL \"${f}\" (${cssXsltOptions})"
		fi
	done 
done

info " - Building Javascript code"
if ! xsltproc ${xsltOptions} -o "${appRootPath}/chrome/content/${xulAppName}.jsm" "${programStylesheetPath}/xul/js-application.xsl" "${xmlProgramDescriptionPath}"  
then
	ns_error "Error while building XUL application code"
fi

if ! xsltproc ${xsltOptions} -o "${appRootPath}/chrome/content/${xulAppName}.js" "${programStylesheetPath}/xul/js-mainwindow.xsl" "${xmlProgramDescriptionPath}"  
then
	ns_error "Error while building XUL main window code"
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

if [ "${targetPlatform}" == "osx" ]
then
	info " - Create/Update Mac OS X application bundle structure"
	# Create structure
	mkdir -p "${outputPath}/Contents/MacOS"
	mkdir -p "${outputPath}/Contents/Resources"
	
	info " - Create/Update Mac OS X application property list"
	if ! xsltproc ${xsltOptions} --stringparam prg.xul.buildID "${appBuildID}" -o "${outputPath}/Contents/Info.plist" "${programStylesheetPath}/xul/osx-plist.xsl" "${xmlProgramDescriptionPath}"  
	then
		ns_error "Error while building XUL main window code"
	fi
fi

info " - Create/Update application launcher"
launcherPath=""
if [ "${targetPlatform}" == "osx" ]
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
#This variable indicates from which platform this app have been built
buildPlatform="${targetPlatform}"
debug=${debugMode}
platform="linux"
if [ "\$(uname)" == "Darwin" ]
then
	platform="osx"
fi

scriptPath="\$(ns_realpath "\$(dirname "\${0}")")"
appIniPath="\$(ns_realpath "\${scriptPath}/application.ini")"
logFile="/tmp/${xulAppName}.log"
if [ "\${platform}" == "osx" ]
then
	appIniPath="\$(ns_realpath "\${scriptPath}/../Resources/application.ini")"
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
	local frameworkName="XUL.framework"
	local bundledFrameworkPath="\$(ns_realpath "\${scriptPath}/../Frameworks/\${frameworkName}")"
	local systemFrameworkPathBase="Library/Frameworks/\${frameworkName}"
	minXulFrameworkVersion=4
	for xul in "\${bundledFrameworkPath}" "/\${systemFrameworkPathBase}" "/\${HOME}/\${systemFrameworkPathBase}"
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
	if [ "\${platform}" == "osx" ]
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
if [ "\${platform}" == "osx" ]
then
	use_framework || use_xulrunner || use_firefox
else
	use_firefox || use_xulrunner
fi
EOF
chmod 755 "${launcherPath}"

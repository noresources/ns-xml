<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->
<sh:program xmlns:prg="http://xsd.nore.fr/program" xmlns:sh="http://xsd.nore.fr/bash" xmlns:xi="http://www.w3.org/2001/XInclude">
	<sh:info>
		<xi:include href="update-doc.xml" />
	</sh:info>
	<sh:functions>
		<xi:include href="../../ns/xsh/lib/filesystem/filesystem.xml" xpointer="xmlns(sh=http://xsd.nore.fr/bash)xpointer(//sh:function[@name = 'ns_realpath'])" />
		<xi:include href="../../ns/xsh/lib/filesystem/filesystem.xml" xpointer="xmlns(sh=http://xsd.nore.fr/bash)xpointer(//sh:function[@name = 'ns_relativepath'])" />
		<xi:include href="../../ns/xsh/lib/text/sed.xml" xpointer="xmlns(sh=http://xsd.nore.fr/bash)xpointer(//sh:function)" />
		<sh:function name="filesystempath_to_nmepath">
			<sh:parameter name="sourceBasePath" />
			<sh:parameter name="outputBasePath" />
			<sh:parameter name="path" />
			<sh:body><![CDATA[
local output="$(echo "${path#${sourceBasePath}}" | tr -d "/" | tr " " "_")"
output="${outputBasePath}/${output}"
echo "${output}"
			]]></sh:body>
		</sh:function>
	</sh:functions>
	<sh:code><![CDATA[
scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
rootPath="$(ns_realpath "${scriptPath}/../..")"
creolePath="${rootPath}/doc/wiki/creole"
xslPath="${rootPath}/ns/xsl"
cwd="$(pwd)"

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

update_item()
{
	local name="${1}"
	local n=${#parser_values[*]}
	[ ${n} -eq 0 ] && return 0
	for ((i=0;${i}<${n};i++))
	do
		[ "${parser_values[${i}]}" == "${name}" ] && return 0
	done
	
	return 1
}

for tool in nme find xsltproc
do
	which ${tool} 1>/dev/null 2>&1 || (echo "${tool} not found" && exit 1)
done

if update_item creole
then
	appXshPath="${rootPath}/ns/xsh/apps"
	outputPath="${creolePath}/apps"

	# TODO get program version 
	creoleXslStylesheet="${xslPath}/program/2.0/wikicreole-usage.xsl"

	find "${appXshPath}" -name "*.xml" | while read f
	do
		b="$(basename "${f}")"
		xsltproc --xinclude -o "${outputPath}/${b%xml}wiki" "${creoleXslStylesheet}" "${f}" 
	done
fi

if update_item html && which nme 1>/dev/null 2>&1
then
	htmlArticlePath="${rootPath}/doc/html/articles"
	
	for e in wiki jpg png gif
	do
		find "${creolePath}" -name "*.${e}" | while read f
		do
			#output="${htmlArticlePath}${f#${creolePath}}"
			
			#output="$(echo "${f#${creolePath}}" | tr -d "/")"
			#output="${htmlArticlePath}/${output}"
			
			output="$(filesystempath_to_nmepath "${creolePath}" "${htmlArticlePath}" "${f}")"
			
			[ "${e}" == "wiki" ] && output="${output%wiki}html"
			echo "${output}"
			mkdir -p "$(dirname "${output}")"
			if [ "${e}" == "wiki" ]
			then
				nme --easylink "$.html" < "${f}" > "${output}"
				ns_sed_inplace "s/\.\(png\|jpg\|gif\)\.html/.\1/g" "${output}"
			else
				rsync -lprt "${f}" "${output}"
			fi
		done
	done
fi

xslStylesheet="${xslPath}/languages/xsl/documentation-html.xsl"
defaultCssFile="${rootPath}/resources/css/xsl.doc.html.css"

if update_item xsl
then
	[ -z "${xsltDocOutputPath}" ] && xsltDocOutputPath="${rootPath}/doc/html/xsl"
	[ -z "${xsltDocCssFile}" ] && xsltDocCssFile="${defaultCssFile}"
	xsltDocCssFile="$(ns_realpath "${xsltDocCssFile}")"
	[ "${indexMode}" = "indexModeFile" ] && ${indexCopyInFolders} && indexFile="$(ns_realpath "${indexFile}")" 
	
	xsltDocOutputPath="$(ns_realpath "${xsltDocOutputPath}")"
	xslDirectoryIndexMode="auto"
		
	if [ "${indexMode}" = "indexModeFile" ]
	then
		if ${indexCopyInFolders}
		then
			xslDirectoryIndexMode="per-folder"
		else
			xslDirectoryIndexMode="root"
		fi
		
		outputIndexPath="${xsltDocOutputPath}/${indexFileOutputName}"
		
		echo "Create index (${xslDirectoryIndexMode}) from \"${indexFile}\"" 	
				
		if [ "${indexFile}" != "${outputIndexPath}" ]
		then
			rsync -lprt "${indexFile}" "${outputIndexPath}"
		fi
	fi
		
	find "${xslPath}" -name "*.xsl" | while read f
	do
		output="${f#${xslPath}}"
		output="${xsltDocOutputPath}${output}"
		output="${output%xsl}html"
		outputFolder="$(dirname "${output}")"
		mkdir -p "${outputFolder}"
		cssPath="$(ns_relativepath "${xsltDocCssFile}" "${outputFolder}")"
		title="${output#${xsltDocOutputPath}/}"
		title="${title%.html}"
		 
		
		if [ "${indexMode}" = "indexModeUrl" ]
		then
			echo -n ""
		elif [ "${indexMode}" = "indexModeFile" ]
		then
			outputIndexPath="${outputFolder}/${indexFileOutputName}"
			if ${indexCopyInFolders} && [ "${indexFile}" != "${outputIndexPath}" ]
			then
				cp -pf "${indexFile}" "${outputIndexPath}"
			fi
		fi
		
		xsltproc --xinclude -o "${output}" \
			--stringparam "xsl.doc.html.fileName" "${title}" \
			--stringparam "xsl.doc.html.stylesheetPath" "${cssPath}" \
			--stringparam "xsl.doc.html.directoryIndexPathMode" "${xslDirectoryIndexMode}" \
			--stringparam "xsl.doc.html.directoryIndexPath" "${indexFileOutputName}" \
			"${xslStylesheet}" "${f}"

	done
fi
]]></sh:code>
</sh:program>

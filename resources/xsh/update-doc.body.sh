scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
scriptName="$(basename "${scriptFilePath}")"
projectPath="$(ns_realpath "${scriptPath}/../..")"
creolePath="${projectPath}/doc/wiki/creole"
xslPath="${projectPath}/ns/xsl"
resourceXslPath="${projectPath}/resources/xsl"
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

# Set defaults if nothing selected by user
[ ${#parser_values[*]} -eq 0 ] && parser_values=(creole html xsl)

if update_item creole
then
	appXshPath="${projectPath}/ns/xsh/apps"
	outputPath="${creolePath}/apps"

	# TODO get program version
	
	find "${appXshPath}" -name "*.xml" | while read f
	do
		programVersion="$(get_program_version "${f}")" 
		creoleXslStylesheet="${xslPath}/program/${programVersion}/wikicreole-usage.xsl"
		[ -f "${creoleXslStylesheet}" ] || continue
		b="$(basename "${f}")"
		xsltproc --xinclude -o "${outputPath}/${b%xml}wiki" "${creoleXslStylesheet}" "${f}" 
	done
	
	# Spreadsheets to creole pages
	specComplianceSource="${projectPath}/doc/documents/program/SpecificationCompliance.ods"
	specComplianceTempPath="$(mktemp -d --suffix "${scriptName}")"
	specComplianceOutput="${creolePath}/program/SpecificationCompliance.wiki"
	#specComplianceXslt="${xslPath}/documents/opendocument/ods2wikicreole.xsl"
	specComplianceXslt="${resourceXslPath}/ods2wikicreole.speccompliance.xsl"
	
	cd "${specComplianceTempPath}"
	if unzip -o "${specComplianceSource}" "content.xml" 1>/dev/null 2>&1
	then	
		cat "${specComplianceOutput}.1" > "${specComplianceOutput}"
		echo "" >> "${specComplianceOutput}"
	
		xsltproc --param odf.spreadsheet2wikicreole.tableIndex 2 "${specComplianceXslt}" content.xml >> "${specComplianceOutput}"
		echo "" >> "${specComplianceOutput}"
		
		cat "${specComplianceOutput}.2" >> "${specComplianceOutput}"
		echo "" >> "${specComplianceOutput}"
		
		xsltproc --param odf.spreadsheet2wikicreole.tableIndex 1 "${specComplianceXslt}" content.xml >> "${specComplianceOutput}"
		echo "" >> "${specComplianceOutput}"
		
		cat "${specComplianceOutput}.3" >> "${specComplianceOutput}"
		echo "" >> "${specComplianceOutput}"
		
		rm -f content.xml
	else
		error 2 Failed to unzip doc
	fi
	 
fi

if update_item html && which nme 1>/dev/null 2>&1
then
	htmlArticlePath="${projectPath}/doc/html/articles"
	
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
defaultCssFile="${projectPath}/resources/css/xsl.doc.html.css"

if update_item xsl
then
	[ -z "${xsltDocOutputPath}" ] && xsltDocOutputPath="${projectPath}/doc/html/xsl"
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

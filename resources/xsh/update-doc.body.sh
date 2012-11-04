scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
scriptName="$(basename "${scriptFilePath}")"
projectPath="$(ns_realpath "${scriptPath}/../..")"
creolePath="${projectPath}/doc/wiki/creole"
xslPath="${projectPath}/ns/xsl"
resourceXslPath="${projectPath}/resources/xsl"
cwd="$(pwd)"

# Override default path for htmlOutputPath
htmlOutputPath="${projectPath}/doc/html/articles"

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

xsltdoc()
{
	local f="${1}"
	local output="${f#${xslPath}}"
	output="${xsltDocOutputPath}${output}"
	output="${output%xsl}html"
	local outputFolder="$(dirname "${output}")"
	mkdir -p "${outputFolder}" || error 2 "Failed to create ${outputFolder}"
	local cssPath="$(ns_relativepath "${xsltDocCssFile}" "${outputFolder}")"
	local title="${output#${xsltDocOutputPath}/}"
	title="${title%.html}"
	
	if [ "${indexMode}" = "indexModeUrl" ]
	then
		echo -n ""
	elif [ "${indexMode}" = "indexModeFile" ]
	then
		local outputIndexPath="${outputFolder}/${indexFileOutputName}"
		if ${indexCopyInFolders} && [ "${indexFile}" != "${outputIndexPath}" ]
		then
			cp -pf "${indexFile}" "${outputIndexPath}"
		fi
	fi
	
	testXsltOptions=(--xinclude)
	if ${xsltAbstract}
	then
		testXsltOptions=("${testXsltOptions[@]}" "--param" "xsl.doc.html.stylesheetAbstract" "true()")
	fi
	
	available="$(xsltproc "${testXsltOptions[@]}" "${xslTestStylesheet}" "${f}")"
	
	if [ ${available} = "yes" ]
	then
		xsltproc "${xsltprocOptions[@]}" -o "${output}" \
			--stringparam "xsl.doc.html.fileName" "${title}" \
			--stringparam "xsl.doc.html.cssPath" "${cssPath}" \
			"${xslStylesheet}" "${f}"
	fi
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
	specComplianceTempPath="$(ns_mktempdir "${scriptName}")"
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
	nmeOptions=(--easylink "${nmeEasyLink}")
	if ${htmlBodyOnly}
	then
		nmeOptions=("${nmeOptions[@]}" --body)	
	fi
	
	for e in wiki jpg png gif
	do
		find "${creolePath}" -name "*.${e}" | while read f
		do
			#output="${htmlOutputPath}${f#${creolePath}}"
			
			#output="$(echo "${f#${creolePath}}" | tr -d "/")"
			#output="${htmlOutputPath}/${output}"
			
			output="$(filesystempath_to_nmepath "${creolePath}" "${htmlOutputPath}" "${f}")"
			
			[ "${e}" == "wiki" ] && output="${output%wiki}html"
			echo "${output}"
			mkdir -p "$(dirname "${output}")"
			if [ "${e}" == "wiki" ]
			then
				nme "${nmeOptions[@]}" < "${f}" > "${output}"
				ns_sed_inplace "s/\.\(png\|jpg\|gif\)\.html/.\1/g" "${output}"
			else
				rsync -lprt "${f}" "${output}"
			fi
		done
	done
fi

xslStylesheet="${xslPath}/languages/xsl/documentation-html.xsl"
xslTestStylesheet="${xslPath}/languages/xsl/documentation-html-available.xsl"
defaultCssFile="${projectPath}/resources/css/xsl.doc.html.css"

if update_item xsl
then
	[ -z "${xsltDocOutputPath}" ] && xsltDocOutputPath="${projectPath}/doc/html/xsl"
	mkdir -p "${xsltDocOutputPath}" || error 2 "Failed to create XSLT output folder ${xsltDocOutputPath}" 
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
	elif [ "${indexMode}" = "indexModeNone" ]
	then
		xslDirectoryIndexMode="none"
	fi
	
	xsltprocOptions=(--xinclude \
		--stringparam "xsl.doc.html.directoryIndexPathMode" "${xslDirectoryIndexMode}" \
		--stringparam "xsl.doc.html.directoryIndexPath" "${indexFileOutputName}" \
		)
	
	if ${htmlBodyOnly}
	then
		xsltprocOptions=("${xsltprocOptions[@]}" "--param" "xsl.doc.html.fullHtmlPage" "false()")
	fi
	
	if ${xsltAbstract}
	then
		xsltprocOptions=("${xsltprocOptions[@]}" "--param" "xsl.doc.html.stylesheetAbstract" "true()")
	fi

	if ${xsltHgOnly}
	then
		cd "${projectPath}"
		while read f
		do
			xsltdoc "${projectPath}/${f}"
		done << EOF
		$(hg st -macn  --include "glob:${xslPath}/**.xsl")
EOF
		cd "${cwd}"		
	else
		while read f
		do
			xsltdoc "${f}"
		done << EOF
		$(find "${xslPath}" -name "*.xsl")
EOF
	fi
fi

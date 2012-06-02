<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->
<sh:program xmlns:prg="http://xsd.nore.fr/program" xmlns:sh="http://xsd.nore.fr/bash" xmlns:xi="http://www.w3.org/2001/XInclude">
	<sh:info>
		<xi:include href="update-doc.xml" />
	</sh:info>
	<sh:functions>
		<xi:include href="../../ns/xsh/lib/filesystem/filesystem.xml" xpointer="xmlns(sh=http://xsd.nore.fr/bash)xpointer(//sh:function[@name = 'ns_realpath'])" />
		<xi:include href="../../ns/xsh/lib/filesystem/filesystem.xml" xpointer="xmlns(sh=http://xsd.nore.fr/bash)xpointer(//sh:function[@name = 'ns_relativepath'])" />
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
		xsltproc -o "${outputPath}/${b%xml}wiki" "${creoleXslStylesheet}" "${f}" 
	done
fi

if update_item html
then
	htmlArticlePath="${rootPath}/doc/html/articles"
	
	find "${creolePath}" -name "*.wiki" | while read f
	do
		output="${htmlArticlePath}${f#${creolePath}}"
		output="${output%wiki}html"
		echo "${output}"
		mkdir -p "$(dirname "${output}")"
		nme --easylink "$.html" < "${f}" > "${output}"
	done
fi

xslStylesheet="${xslPath}/languages/xsl/documentation-html.xsl"
defaultCssFile="${rootPath}/resources/css/xsl.doc.html.css"

[ -z "${xsltDocOutputPath}" ] && xsltDocOutputPath="${rootPath}/doc/html/xsl"
[ -z "${xsltDocCssFile}" ] && xsltDocCssFile="${defaultCssFile}"

if update_item xsl
then
	find "${xslPath}" -name "*.xsl" | while read f
	do
		output="${xsltDocOutputPath}${f#${xslPath}}"
		output="${output%xsl}html"
		echo "${output}"
		cssPath="$(ns_relativepath "${xsltDocCssFile}" "${output}")"
		title="${output#${xsltDocOutputPath}/}"
		title="${title%.html}"
		mkdir -p "$(dirname "${output}")"
		xsltproc --xinclude -o "${output}" \
			--stringparam xsl.doc.html.fileName "${title}"\
			--stringparam xsl.doc.html.stylesheetPath "${cssPath}"\
			"${xslStylesheet}" "${f}"
	done
fi
]]></sh:code>
</sh:program>

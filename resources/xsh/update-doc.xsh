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

for tool in nme find xsltproc
do
	which ${tool} 1>/dev/null 2>&1 || (echo "${tool} not found" && exit 1)
done

creolePath="${rootPath}/doc/wiki/creole"
htmlArticlePath="${rootPath}/doc/html/articles"

if true
then
	find "${creolePath}" -name "*.wiki" | while read f
	do
		output="${htmlArticlePath}${f#${creolePath}}"
		output="${output%wiki}html"
		echo "${output}"
		mkdir -p "$(dirname "${output}")"
		nme --easylink "$.html" < "${f}" > "${output}"
	done
fi

xslPath="${rootPath}/ns/xsl"
xslStylesheet="${xslPath}/languages/xsl/documentation-html.xsl"
defaultCssFile="${rootPath}/resources/css/xsl.doc.html.css"

[ -z "${xsltDocOutputPath}" ] && xsltDocOutputPath="${rootPath}/doc/html/xsl"
[ -z "${xsltDocCssFile}" ] && xsltDocCssFile="${defaultCssFile}"

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
]]></sh:code>
</sh:program>

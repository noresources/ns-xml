#!/bin/bash
ns_realpath()
{
	local path="${1}"
	shift
	local cwd="$(pwd)"
	[ -d "${path}" ] && cd "${path}" && path="."
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
ns_relativepath()
{
	local from="${1}"
	shift
	local base="${1}"
	[ -z "${base}" ] && base="."
	shift
	[ -r "${from}" ] || return 1
	[ -r "${base}" ] || return 2
	[ ! -d "${base}" ] && base="$(dirname "${base}")"  
	[ -d "${base}" ] || return 3
	from="$(ns_realpath "${from}")"
	base="$(ns_realpath "${base}")"
	#echo from: $from
	#echo base: $base
	c=0
	sub="${base}"
	newsub=""
	while [ "${from:0:${#sub}}" != "${sub}" ]
	do
		newsub="$(dirname "${sub}")"
		[ "${newsub}" == "${sub}" ] && return 4
		sub="${newsub}"
		c="$(expr ${c} + 1)"
	done
	#echo c: ${c}
	#echo sub: ${sub}
	res="."
	for ((i=0;${i}<${c};i++))
	do
		res="${res}/.."
	done
	res="${res}${from#${sub}}"
	res="${res#./}"
	echo "${res}"
}

scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
rootPath="$(ns_realpath "${scriptPath}/../..")"
cwd="$(pwd)"

for tool in nme find xsltproc
do
	which ${tool} 1>/dev/null 2>&1 || (echo "${tool} not found" && exit 1)
done

creolePath="${rootPath}/doc/wiki/creole"
htmlArticlePath="${rootPath}/doc/html/articles"

if ! true
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
htmlXslApiPath="${rootPath}/doc/html/xsl"
defaultCssFile="${rootPath}/resources/css/xsl.doc.html.css"

css="${defaultCssFile}"

find "${xslPath}" -name "*.xsl" | while read f
do
	output="${htmlXslApiPath}${f#${xslPath}}"
	output="${output%xsl}html"
	echo "${output}"
	cssPath="$(ns_relativepath "${defaultCssFile}" "${output}")"
	title="${output#${htmlXslApiPath}/}"
	title="${title%.html}"
	mkdir -p "$(dirname "${output}")"
	xsltproc --xinclude -o "${output}" \
		--stringparam xsl.doc.html.fileName "${title}"\
		--stringparam xsl.doc.html.stylesheetPath "${cssPath}"\
		"${xslStylesheet}" "${f}"
done

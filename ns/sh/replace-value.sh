#!/bin/bash
if ! which realpath 1>/dev/null 2>&1
then
realpath()
{
	local p="${1}"
	local cwd="$(pwd)"
	if cd "${p}" 1>/dev/null 2>&1
	then
		p="$(pwd)"
		cd "${cwd}"
	fi
	echo "${p}"
}
fi

get_template()
{
	local xpath="$(echo -n "${1}" | sed "s/\//\\\\\//g")"
	local replacement="$(echo -n "${2}" | sed "s/\//\\\\\//g")"
	
	echo -n "<xsl:template match=\"${xpath}\">"\
				"<xsl:variable name=\"name\">"\
					"<xsl:value-of select=\"name()\"\/>"\
				"<\/xsl:variable>"\
				"<xsl:element name=\"{\$name}\">${replacement}<\/xsl:element>"\
				"<\/xsl:template>"
}

scriptFilePath="$(realpath "${0}")"
scriptName="$(basename "${scriptFilePath}")"
scriptPath="$(dirname "${scriptFilePath}")"
rootPath="$(realpath "${scriptPath}/../..")"
xslFilePath="${rootPath}/ns/xsl/clean.xsl"
xslTemporaryPath="/tmp"
xslTemporaryFilePath="${xslTemporaryPath}/${scriptName}.xsl"
xslMarker="<!--\[rules\]-->"

cp "${xslFilePath}" "${xslTemporaryFilePath}"

xmlSourcePath="${1}"
shift

patternCount=0
while [ $# -ge 2 ]
do
	xpaths[${patternCount}]="${1}"
	replacements[${patternCount}]="${2}"
	patternCount=$(expr ${patternCount} + 1)
	shift 2
done

for ((i=0;i<${patternCount};i++))
do
	#sed -e "s/<!--\[rules\]-->/piapia/g" "${xslTemporaryFilePath}"
	#get_template "${xpaths[$i]}" "${replacements[$i]}"
	sed -i "" -e "s/\(${xslMarker}\)/$(get_template "${xpaths[$i]}" "${replacements[$i]}")\1/g" "${xslTemporaryFilePath}"
done

xsltproc "${xslTemporaryFilePath}" "${xmlSourcePath}" 


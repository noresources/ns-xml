#!/bin/bash
# ####################################
# Copyright © 2012 by Renaud Guillard (dev@nore.fr)
# Distributed under the terms of the MIT License, see LICENSE
# ####################################
# Regenerate build-shellscript 'by hand'
# ####################################

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

scriptFilePath="$(realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
rootPath="$(realpath "${scriptPath}/../..")"
programSchemaVersion=2.0
# Check required programs
for x in xmllint xsltproc egrep cut expr head tail
do
	if ! which $x 1>/dev/null 2>&1
	then
		echo "${x} program not found"
		exit 1
	fi
done

out="${rootPath}/ns/sh/build-shellscript.sh"
xsh="${rootPath}/ns/xsh/apps/build-shellscript.xsh"
xml="${rootPath}/ns/xsh/apps/build-shellscript.xml"
xsl="${rootPath}/ns/xsl/program/${programSchemaVersion}/xsh.xsl"

xsltproc --xinclude -o "${out}" "${xsl}" "${xsh}"
chmod 755 "${out}"
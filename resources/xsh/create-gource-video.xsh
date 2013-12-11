<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->
<xsh:program interpreterType="ksh" xmlns:prg="http://xsd.nore.fr/program" xmlns:xsh="http://xsd.nore.fr/xsh" xmlns:xi="http://www.w3.org/2001/XInclude">
	<xsh:info>
		<xi:include href="create-gource-video.xml" />
	</xsh:info>
	<xsh:functions>
		<xi:include href="../../ns/xsh/lib/filesystem/filesystem.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function[@name = 'ns_realpath'])" />
		<xi:include href="../../ns/xsh/lib/filesystem/filesystem.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function[@name = 'ns_relativepath'])" />
		<xsh:function name="filesystempath_to_nmepath">
			<xsh:parameter name="sourceBasePath" />
			<xsh:parameter name="outputBasePath" />
			<xsh:parameter name="path" />
			<xsh:body><![CDATA[
local output="$(echo "${path#${sourceBasePath}}" | tr -d "/" | tr " " "_")"
output="${outputBasePath}/${output}"
echo "${output}"
			]]></xsh:body>
		</xsh:function>
	</xsh:functions>
	<xsh:code><![CDATA[
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

for x in gource ffmpeg
do
	if ! which ${x} 1>/dev/null 2>&1
	then
		echo "${x} not found"
		exit 1
	fi
done

outputFile="${parser_values[0]}"
[ -z "${outputFile}" ] && outputFile="gource-$(date +%F).mp4"
gource --load-config "${configurationFile}" --output-framerate 30 --output-ppm-stream - | ffmpeg -y -r 60 -f image2pipe -vcodec ppm -i - -vcodec libx264 -preset ultrafast -crf 1 -threads 0 -bf 0 "${outputFile}"
]]></xsh:code>
</xsh:program>

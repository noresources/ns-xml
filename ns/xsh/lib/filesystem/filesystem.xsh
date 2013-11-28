<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2013 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->
<xsh:functions xmlns:xsh="http://xsd.nore.fr/xsh">
	<xsh:function name="ns_isdir">
		<xsh:parameter name="inputPath" />
		<xsh:body><![CDATA[
[ ! -z "${inputPath}" ] && [ -d "${inputPath}" ]
		]]></xsh:body>
	</xsh:function>
	<xsh:function name="ns_issymlink">
		<xsh:parameter name="inputPath" />
		<xsh:body><![CDATA[
[ ! -z "${inputPath}" ] && [ -L "${inputPath}" ]
		]]></xsh:body>
	</xsh:function>
	<xsh:function name="ns_realpath">
		<xsh:parameter name="inputPath" />
		<xsh:body>
		<xsh:local name="cwd">$(pwd)</xsh:local>
		<![CDATA[
[ -d "${inputPath}" ] && cd "${inputPath}" && inputPath="."
while [ -h "${inputPath}" ] ; do inputPath="$(readlink "${inputPath}")"; done

if [ -d "${inputPath}" ]
then
	inputPath="$(cd -P "$(dirname "${inputPath}")" && pwd)"
else
	inputPath="$(cd -P "$(dirname "${inputPath}")" && pwd)/$(basename "${inputPath}")"
fi

cd "${cwd}" 1>/dev/null 2>&1
echo "${inputPath}"
		]]></xsh:body>
	</xsh:function>
	<xsh:function name="ns_relativepath">
		<xsh:parameter name="from" />
		<xsh:parameter name="base"><![CDATA[.]]></xsh:parameter>
		<xsh:body><![CDATA[
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
res="."
for ((i=0;${i}<${c};i++))
do
	res="${res}/.."
done
res="${res}${from#${sub}}"
res="${res#./}"
echo "${res}"
		]]></xsh:body>
	</xsh:function>
	<xsh:function name="ns_mktemp">
		<xsh:parameter name="key">
			$(date +%s)
		</xsh:parameter>
		<xsh:body><![CDATA[
if [ "$(uname -s)" == "Darwin" ]
then
	#Use key as a prefix
	mktemp -t "${key}"
else
	#Use key as a suffix
	mktemp --suffix "${key}"
fi
]]></xsh:body>
	</xsh:function>
	<xsh:function name="ns_mktempdir">
		<xsh:parameter name="key">
			$(date +%s)
		</xsh:parameter>
		<xsh:body><![CDATA[
if [ "$(uname -s)" == "Darwin" ]
then
	#Use key as a prefix
	mktemp -d -t "${key}"
else
	#Use key as a suffix
	mktemp -d --suffix "${key}"
fi
]]></xsh:body>
	</xsh:function>
	<!-- Support for -s option on Liux -->
	<xsh:function name="ns_which">
		<xsh:body><![CDATA[
if [ "$(uname -s)" == "Darwin" ]
then
	which "${@}"
else
]]><xsh:local name="silent">false</xsh:local>
<xsh:local name="args" /><![CDATA[
	while [ ${#} -gt 0 ]
	do
		if [ "${1}" = "-s" ]
		then 
			silent=true
		else
			args=("${args[@]}" "${1}")
		fi
		shift
	done
	
	if ${silent}
	then
		which "${args[@]}" 1>/dev/null 2>&1
	else
		which "${args[@]}"
	fi
fi
]]></xsh:body>
	</xsh:function>
</xsh:functions>

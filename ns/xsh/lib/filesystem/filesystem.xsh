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
		<xsh:parameter name="__ns_realpath_in" />
		<xsh:body>
			<xsh:local name="__ns_realpath_rl"></xsh:local>
			<xsh:local name="__ns_realpath_cwd">$(pwd)</xsh:local>
		<![CDATA[
[ -d "${__ns_realpath_in}" ] && cd "${__ns_realpath_in}" && __ns_realpath_in="."
while [ -h "${__ns_realpath_in}" ]
do
	__ns_realpath_rl="$(readlink "${__ns_realpath_in}")"
	if [ "${__ns_realpath_rl#/}" = "${__ns_realpath_rl}" ]
	then
		__ns_realpath_in="$(dirname "${__ns_realpath_in}")/${__ns_realpath_rl}"
	else
		__ns_realpath_in="${__ns_realpath_rl}"
	fi
done

if [ -d "${__ns_realpath_in}" ]
then
	__ns_realpath_in="$(cd -P "$(dirname "${__ns_realpath_in}")" && pwd)"
else
	__ns_realpath_in="$(cd -P "$(dirname "${__ns_realpath_in}")" && pwd)/$(basename "${__ns_realpath_in}")"
fi

cd "${__ns_realpath_cwd}" 1>/dev/null 2>&1
echo "${__ns_realpath_in}"
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
		<xsh:parameter name="__ns_mktemp_template"><![CDATA[$(date +%s)-XXXX]]></xsh:parameter>
		<xsh:body>
			<xsh:local name="__ns_mktemp_xcount" />
		<![CDATA[
if which 'mktemp' 1>/dev/null 2>&1
then
	# Auto-fix template
	__ns_mktemp_xcount=0
	which 'grep' 1>/dev/null 2>&1 \
	&& which 'wc' 1>/dev/null 2>&1 \
	&& __ns_mktemp_xcount=$(grep -o X <<< "${__ns_mktemp_template}" | wc -c)
	while [ ${__ns_mktemp_xcount} -lt 3 ]
	do
		__ns_mktemp_template="${__ns_mktemp_template}X"
		__ns_mktemp_xcount=$(expr ${__ns_mktemp_xcount} + 1)
	done
	mktemp -t "${__ns_mktemp_template}" 2>/dev/null
else]]><xsh:local name='__ns_mktemp_root' /><![CDATA[
	# Fallback to a manual solution
	for __ns_mktemp_root in "${TMPDIR}" "${TMP}" '/var/tmp' '/tmp'
	do
		[ -d "${__ns_mktemp_root}" ] && break
	done
	[ -d "${__ns_mktemp_root}" ] || return 1]]>
	<xsh:local name="__ns_mktemp">/${__ns_mktemp_root}/${__ns_mktemp_template}.$(date +%s)-${RANDOM}</xsh:local><![CDATA[
	touch "${__ns_mktemp}" 1>/dev/null 2>&1 && echo "${__ns_mktemp}"
fi
]]></xsh:body>
	</xsh:function>
	<xsh:function name="ns_mktempdir">
		<xsh:parameter name="__ns_mktemp_template"><![CDATA[$(date +%s)-XXXX]]></xsh:parameter>
		<xsh:body>
			<xsh:local name="__ns_mktemp_xcount" />
		<![CDATA[
if which 'mktemp' 1>/dev/null 2>&1
then
	# Auto-fix template
	__ns_mktemp_xcount=0
	which 'grep' 1>/dev/null 2>&1 \
	&& which 'wc' 1>/dev/null 2>&1 \
	&& __ns_mktemp_xcount=$(grep -o X <<< "${__ns_mktemp_template}" | wc -c)
	
	while [ ${__ns_mktemp_xcount} -lt 3 ]
	do
		__ns_mktemp_template="${__ns_mktemp_template}X"
		__ns_mktemp_xcount=$(expr ${__ns_mktemp_xcount} + 1)
	done
	mktemp -d -t "${__ns_mktemp_template}" 2>/dev/null
else]]><xsh:local name='__ns_mktemp_root' /><![CDATA[
	# Fallback to a manual solution
	for __ns_mktemp_root in "${TMPDIR}" "${TMP}" '/var/tmp' '/tmp'
	do
		[ -d "${__ns_mktemp_root}" ] && break
	done
	[ -d "${__ns_mktemp_root}" ] || return 1
	]]><xsh:local name='__ns_mktempdir'>/${__ns_mktemp_root}/${__ns_mktemp_template}.$(date +%s)-${RANDOM}</xsh:local><![CDATA[
	mkdir -p "${__ns_mktempdir}" 1>/dev/null 2>&1 && echo "${__ns_mktempdir}"
fi
]]></xsh:body>
	</xsh:function>
	<!-- Support for -s option on Linux -->
	<xsh:function name="ns_which">
		<xsh:body>
			<xsh:local name="result" type="numeric">1</xsh:local>
		<![CDATA[
if [ "$(uname -s)" = 'Darwin' ]
then
	which "${@}" && result=0
else
]]><xsh:local name="silent">false</xsh:local>
			<xsh:local name="args" /><![CDATA[
	while [ ${#} -gt 0 ]
	do
		if [ "${1}" = '-s' ]
		then 
			silent=true
		else
			[ -z "${args}" ] \
				&& args="${1}" \
				|| args=("${args[@]}" "${1}")
		fi
		shift
	done
	
	if ${silent}
	then
		which "${args[@]}" 1>/dev/null 2>&1 && result=0
	else
		which "${args[@]}" && result=0
	fi
fi
return ${result}
]]></xsh:body>
	</xsh:function>
</xsh:functions>

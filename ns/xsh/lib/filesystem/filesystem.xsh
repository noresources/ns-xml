<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the BSD License, see LICENSE -->
<xsh:functions xmlns:xsh="http://xsd.nore.fr/xsh">
	<xsh:function name="ns_isdir">
		<xsh:parameter name="path" />
		<xsh:body><![CDATA[
[ ! -z "${path}" ] && [ -d "${path}" ]
		]]></xsh:body>
	</xsh:function>
	<xsh:function name="ns_issymlink">
		<xsh:parameter name="path" />
		<xsh:body><![CDATA[
[ ! -z "${path}" ] && [ -L "${path}" ]
		]]></xsh:body>
	</xsh:function>
	<xsh:function name="ns_realpath">
		<xsh:parameter name="path" />
		<xsh:body>
		<xsh:local name="cwd">$(pwd)</xsh:local>
		<![CDATA[
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
</xsh:functions>

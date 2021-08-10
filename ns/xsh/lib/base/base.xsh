<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 - 2021 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->
<xsh:functions xmlns:xsh="http://xsd.nore.fr/xsh">

	<xsh:function name="ns_print_error">
		<!-- Print error message to stderr -->
		<xsh:body>
			<xsh:local name="shell">$(readlink /proc/$$/exe | sed "s/.*\/\([a-z]*\)[0-9]*/\1/g")</xsh:local>
			<xsh:local name="errorColor">${NSXML_ERROR_COLOR}</xsh:local>
			<xsh:local name="useColor" type="boolean">false</xsh:local><![CDATA[
for s in bash zsh ash
do
	if [ "${shell}" = "${s}" ]
	then
		useColor=true
		break
	fi
done
if ${useColor} 
then
	[ -z "${errorColor}" ] && errorColor="31" 
	echo -e "\e[${errorColor}m${@}\e[0m"  1>&2
else
	echo "${@}" 1>&2
fi]]></xsh:body>
	</xsh:function>
	
	<xsh:function name="ns_error">
		<!-- Print error message and exit -->
		<!-- requires: ns_print_error -->
		<xsh:parameter name="errno" type="numeric">1</xsh:parameter>
		<!-- Error code to return on exit -->
		<xsh:body>
			<xsh:local name="message">${@}</xsh:local><![CDATA[
if [ -z "${errno##*[!0-9]*}" ]
then
	message="${errno} ${message}"
	errno=1
fi
ns_print_error "${message}"
exit ${errno}
		]]></xsh:body>
	</xsh:function>
	<xsh:function name="nsxml_installpath">
		<!-- Find ns-xml resources installation path -->
		<!-- User-defined paths can be specified -->
		<!-- requires: ns_print_error -->
		<xsh:body>
			<xsh:local name="subpath">share/ns</xsh:local><![CDATA[
for prefix in \
	"${@}" \
	"${NSXML_PATH}" \
	"${HOME}/.local/${subpath}" \
	"${HOME}/${subpath}" \
	/usr/${subpath} \
	/usr/loca/${subpath}l \
	/opt/${subpath} \
	/opt/local/${subpath}
do
	if [ ! -z "${prefix}" ] \
		&& [ -d "${prefix}" ] \
		&& [ -r "${prefix}/ns-xml.plist" ]
	then
		echo -n "${prefix}"
		return 0
	fi
done

ns_print_error "nsxml_installpath: Path not found"
return 1
]]></xsh:body>
	</xsh:function>
</xsh:functions>

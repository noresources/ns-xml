<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 - 2021 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->
<xsh:functions xmlns:xsh="http://xsd.nore.fr/xsh">

	<xsh:function name="ns_print_colored_message">
		<!-- Print error message to stderr -->
		<xsh:parameter name="_ns_message_color">${NSXML_ERROR_COLOR}</xsh:parameter>
		<xsh:body>
			<xsh:local name="shell">$(readlink /proc/$$/exe | sed "s/.*\/\([a-z]*\)[0-9]*/\1/g")</xsh:local>
			<xsh:local name="useColor" type="boolean">false</xsh:local><![CDATA[
for s in bash zsh ash
do
	if [ "${shell}" = "${s}" ]
	then
		useColor=true
		break
	fi
done
[ ! -z "${NO_COLOR}" ] && [ "${NO_COLOR}" != '0' ] && useColor=false
[ ! -z "${NO_ANSI}" ] && [ "${NO_ANSI}" != '0' ] && useColor=false
if ${useColor} 
then
	[ -z "${_ns_message_color}" ] && _ns_message_color="31" 
	echo -e "\e[${_ns_message_color}m${@}\e[0m" 
else
	echo "${@}"
fi
return 0]]></xsh:body>
	</xsh:function>

	<xsh:function name="ns_print_error">
		<xsh:body><![CDATA[ns_print_colored_message "${NSXML_ERROR_COLOR}" "${@}" 1>&2]]></xsh:body>
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

	<!-- Print warning message on standard error stream -->
	<xsh:function name="ns_warn">
		<xsh:body>
		<xsh:local name="_ns_warn_color">${NSXML_WARNING_COLOR}</xsh:local>
		<![CDATA[
		[ -z "${_ns_warn_color}" ] && _ns_warn_color=33
		ns_print_colored_message "${_ns_warn_color}" "${@}" 1>&2; return 0]]></xsh:body>
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

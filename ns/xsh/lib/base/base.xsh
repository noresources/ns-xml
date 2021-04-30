<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 - 2021 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->
<sh:functions xmlns:sh="http://xsd.nore.fr/xsh">

	<sh:function name="ns_print_error">
		<!-- Print error message to stderr -->
		<sh:body>
			<sh:local name="shell">$(readlink /proc/$$/exe | sed "s/.*\/\([a-z]*\)[0-9]*/\1/g")</sh:local>
			<sh:local name="errorColor">${NSXML_ERROR_COLOR}</sh:local>
			<sh:local name="useColor" type="boolean">false</sh:local><![CDATA[
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
fi]]></sh:body>
	</sh:function>
	
	<sh:function name="ns_error">
		<!-- Print error message and exit -->
		<!-- requires: ns_print_error -->
		<sh:parameter name="errno" type="numeric">1</sh:parameter>
		<!-- Error code to return on exit -->
		<sh:body>
			<sh:local name="message">${@}</sh:local><![CDATA[
if [ -z "${errno##*[!0-9]*}" ]
then
	message="${errno} ${message}"
	errno=1
fi
ns_print_error "${message}"
exit ${errno}
		]]></sh:body>
	</sh:function>
	<sh:function name="nsxml_installpath">
		<!-- Find ns-xml resources installation path -->
		<!-- User-defined paths can be specified -->
		<!-- requires: ns_print_error -->
		<sh:body>
			<sh:local name="subpath">share/ns</sh:local><![CDATA[
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
]]></sh:body>
	</sh:function>
</sh:functions>

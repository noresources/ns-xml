<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2016 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->
<sh:functions xmlns:sh="http://xsd.nore.fr/xsh">
	<sh:function name="ns_semver_mumber_to_string">
		<sh:parameter name="_ns_semver_input" />
		<sh:body>
			<sh:local name="_ns_semver_major" type="numeric">0</sh:local>
			<sh:local name="_ns_semver_minor" type="numeric">0</sh:local>
			<sh:local name="_ns_semver_patch" type="numeric">0</sh:local>
		<![CDATA[
if [ -z "${_ns_semver_input##*[!0-9]*}" ]
then
	echo "${_ns_semver_input} is not a valid numerical version number" 1>&2
	return 1
fi

_ns_semver_major=$(expr ${_ns_semver_input} / 10000)
_ns_semver_minor=$(expr $(expr ${_ns_semver_input} % 10000) / 100)
_ns_semver_patch=$(expr ${_ns_semver_input} % 100)
echo "${_ns_semver_major}.${_ns_semver_minor}.${_ns_semver_patch}"
return 0
]]></sh:body>
	</sh:function>

	<sh:function name="ns_semver_string_to_number">
		<sh:parameter name="_ns_semver_input" />
		<sh:body>
			<sh:local name="_ns_semver_major" type="numeric">0</sh:local>
			<sh:local name="_ns_semver_minor" type="numeric">0</sh:local>
			<sh:local name="_ns_semver_patch" type="numeric">0</sh:local>
		<![CDATA[
_ns_semver_input="$(echo "${_ns_semver_input}" | cut -f 1 -d'-' | cut -f 1 -d'+')"

_ns_semver_major="$(echo "${_ns_semver_input}" | cut -sf 1 -d'.')"
_ns_semver_minor="$(echo "${_ns_semver_input}" | cut -sf 2 -d'.')"
_ns_semver_patch="$(echo "${_ns_semver_input}" | cut -sf 3 -d'.')"

if [ -z "${_ns_semver_major}" ]
then
	_ns_semver_major=${_ns_semver_input}
	_ns_semver_minor=0
	_ns_semver_patch=0
elif [ -z "${_ns_semver_minor}" ]
then
	_ns_semver_minor=${_ns_semver_input}
	_ns_semver_patch=0
elif [ -z "${_ns_semver_patch}" ]
then
	_ns_semver_patch=0
fi

_ns_semver_major=${_ns_semver_major##*[!0-9]*}
[ -z "${_ns_semver_major}" ] && return 1
_ns_semver_minor=${_ns_semver_minor##*[!0-9]*}
[ -z "${_ns_semver_minor}" ] && return 2
_ns_semver_patch=${_ns_semver_patch##*[!0-9]*}
[ -z "${_ns_semver_patch}" ] && return 3

expr "${_ns_semver_patch}" '+' "$(expr "$(expr "${_ns_semver_minor}" '*' 100)" '+' "$(expr "${_ns_semver_major}" '*' 10000)")"
return 0
]]></sh:body>
	</sh:function>
	<sh:function name="ns_semver_get">
		<sh:parameter name="_ns_semver_component" />
		<sh:parameter name="_ns_semver_input" />
		<sh:body>
			<sh:local name="_ns_semver_tmp" />
			<sh:local name="_ns_semver_index" type="numeric">1</sh:local>
		<![CDATA[
case "${_ns_semver_component}" in
	major|minor|patch)
		_ns_semver_index=1
		[ "${_ns_semver_component}" = 'minor' ] && _ns_semver_index=2
		[ "${_ns_semver_component}" = 'patch' ] && _ns_semver_index=3
		_ns_semver_tmp="$(echo "${_ns_semver_input}" | cut -f 1 -d'-' | cut -f 1 -d'+')"
		_ns_semver_tmp="$(echo "${_ns_semver_tmp}" | cut -sf ${_ns_semver_index} -d'.')"
		[ -z "${_ns_semver_tmp}" ] && _ns_semver_tmp=0
		echo "${_ns_semver_tmp}"
		;;
	label)
		echo "${_ns_semver_input}" | cut -sf 2 -d'-' | cut -f 1 -d'+'
		;;
	metadata)
		echo "${_ns_semver_input}" | cut -sf 2 -d'+'
		;;
	*)
		echo "Unknown component ${_ns_semver_component}" 1>&2
		return 1
		;;
esac
]]></sh:body>
	</sh:function>
</sh:functions>

<?xml version="1.0" encoding="UTF-8"?>
<!-- Function declarations -->
<sh:functions xmlns:sh="http://xsd.nore.fr/xsh" xmlns:xi="http://www.w3.org/2001/XInclude">
	<xi:include href="../../ns/xsh/lib/base/base.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function)" />
	<xi:include href="../../ns/xsh/lib/filesystem/filesystem.xsh" 
			xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function)" />
	
	<sh:function name="ns_testsuite_ns_relativepath">
		<sh:body>
		<sh:local name="ns_testsuite_relativepath_root">$(ns_mktempdir "ns_testsuite_relativepath_root")</sh:local>
		<sh:local name="cwd">$(pwd)</sh:local>
		<sh:local name="t" />
		<sh:local name="target"/>
		<sh:local name="source" />
		<sh:local name="actual" />
		<sh:local name="expected" />
		<![CDATA[
###################################################

if [ -z "${ns_testsuite_relativepath_root}" ] \
	|| [ ! -d "${ns_testsuite_relativepath_root}" ]
then
	echo "Unable to create ns_testsuite_relativepath_root" 1>&2
	return 1
fi

for t in \
	'foo:bar:../foo' \
	'foo:foo:.' \
	'foo:foo/bar:..' \
	'foo/bar:huey/dewey/louie:../../../foo/bar' \
	'/bin/echo:/etc/hosts:../bin/echo'
do
		target="$(cut -f 1 -d':' <<< "${t}")"
		source="$(cut -f 2 -d':' <<< "${t}")"
		expected="$(cut -f 3 -d':' <<< "${t}")"
		
		if which realpath 1>/dev/null 2>/dev/null
		then
			absoluteSource="$(realpath "$[source]")"
			[ "${absoluteSource}" = "${source}" ] || continue
		fi
		
		if [ "${target:0:1}" != '/' ]
		then
			mkdir -p "${ns_testsuite_relativepath_root}/${target}" \
				|| return 1
			target="$(ns_realpath "${ns_testsuite_relativepath_root}/${target}")"
			[ -d "${target}" ] || return 1
		elif [ ! -r "${target}" ]
		then
			echo 'warning: ' "${target} does not exists" 1>&2
			continue
		elif [ "${target}" != "$(ns_realpath "${target}")" ]
		then
			echo "warning: Could not use symbolic link ${target} as target" 1>&2
			continue
		fi
		
		if [ "${source:0:1}" != '/' ]
		then
			mkdir -p "${ns_testsuite_relativepath_root}/${source}" \
				|| return 1
			source="$(ns_realpath "${ns_testsuite_relativepath_root}/${source}")"
			[ -d "${source}" ] || return 1
		elif [ ! -r ${source} ]
		then
			echo 'warning: ' "${source} does not exists" 1>&2
			continue
		fi
		
		actual="$(ns_relativepath "${target}" "${source}")"
		if [ "${actual}" != "${expected}" ]
		then
			printf "%-10.10s: %s\n" Source "${source#${ns_testsuite_relativepath_root}/}"
			printf "%-10.10s: %s\n" Target "${target#${ns_testsuite_relativepath_root}/}"
			printf "%-10.10s: %s\n" "Expected" "${expected}"
			printf "%-10.10s: %s\n" Actual "${actual}"
			return 1
		fi
		
done

###################################################
return 0
]]></sh:body>
	</sh:function>
</sh:functions>

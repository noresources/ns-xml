<?xml version="1.0" encoding="UTF-8"?>
<!-- Function declarations -->
<sh:functions xmlns:sh="http://xsd.nore.fr/xsh" xmlns:xi="http://www.w3.org/2001/XInclude">
	<xi:include href="../../ns/xsh/lib/base/base.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function)" />
	<xi:include href="../../ns/xsh/lib/filesystem/filesystem.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function)" />

	<sh:function name="ns_testsuite_ns_mktemp">
		<sh:body>
			<sh:local name="validTemplate">helloXXXXX</sh:local>
			<sh:local name="invalidTemplate">pia</sh:local>
			<sh:local name="cwd">$(pwd)</sh:local>
			<sh:local name="resultA" />
			<sh:local name="resultB" />
			<sh:local name="resultC" />
		<![CDATA[
resultA="$(ns_mktemp)"
resultB="$(ns_mktemp ${validTemplate})"
resultC="$(ns_mktemp ${invalidTemplate})"
echo "Default call    : ${resultA}"
echo "valid template  : ${resultB}"
echo "invalid template: ${resultC}"
for d in . "${HOME}"
do
	cd "${d}"
	for result in "${resultA}" "${resultB}" "${resultC}"
	do
		if [ ! -f "${result}" ]
		then
			echo "${result}" is not a file in "${d}" 1>&2
			return 1
		fi 
	done
	cd "${cwd}"
done

return 0
]]></sh:body>
	</sh:function>
	
	<sh:function name="ns_testsuite_ns_mktempdir">
		<sh:body>
			<sh:local name="validTemplate">directoryXXXXX</sh:local>
			<sh:local name="invalidTemplate">foo</sh:local>
			<sh:local name="cwd">$(pwd)</sh:local>
			<sh:local name="resultA" />
			<sh:local name="resultB" />
			<sh:local name="resultC" />
		<![CDATA[
resultA="$(ns_mktempdir)"
resultB="$(ns_mktempdir "${validTemplate}")"
resultC="$(ns_mktempdir "${invalidTemplate}")"
echo 'ns_mktempdir'
echo "Default call    : ${resultA}"
echo "valid template (${validTemplate}) : ${resultB}"
echo "invalid template (${invalidTemplate}): ${resultC}"
for d in . "${HOME}"
do
	cd "${d}"
	for result in "${resultA}" "${resultB}" "${resultC}"
	do
		if [ ! -d "${result}" ]
		then
			echo "${result}" is not a directory in "${d}" 1>&2
			return 1
		fi 
	done
	cd "${cwd}"
done

return 0
]]></sh:body>
	</sh:function>
</sh:functions>

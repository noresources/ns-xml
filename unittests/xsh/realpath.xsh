<?xml version="1.0" encoding="UTF-8"?>
<!-- Function declarations -->
<sh:functions xmlns:sh="http://xsd.nore.fr/xsh" xmlns:xi="http://www.w3.org/2001/XInclude">
	<xi:include href="../../ns/xsh/lib/base/base.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function)" />
	<xi:include href="../../ns/xsh/lib/filesystem/filesystem.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function)" />
	
	<sh:function name="ns_testsuite_ns_realpath">
		<sh:body>
		<sh:local name="rootDirectory">$(dirname "${0}")/ns_testsuite_ns_realpath_dir</sh:local>
		<sh:local name="rootFile">${rootDirectory}/source-file</sh:local>
		<sh:local name="relative" />
		<sh:local name="absolute" />		
		<![CDATA[
echo "${rootDirectory}" > ns_testsuite_ns_realpath.log
mkdir -p "${rootDirectory}" 2>>ns_testsuite_ns_realpath.log
touch "${rootFile}" 2>>ns_testsuite_ns_realpath.log

# Create symbolic links
# Absolute
ln -sf "${rootDirectory}/source-file" "${rootDirectory}/absolute-symlic"
# Relative
ln -sf "source-file" "${rootDirectory}/relative-symlic"

relative="$(ns_realpath "${rootDirectory}/relative-symlic")"
absolute="$(ns_realpath "${rootDirectory}/absolute-symlic")"

echo "Expected: ${rootFile}"
echo "Relative: ${relative}"
echo "Absolute: ${absolute}"

[ "${relative}" = "${rootFile}" ] || return 1
[ "${absolute}" = "${rootFile}" ] || return 1
]]></sh:body>
	</sh:function>
</sh:functions>

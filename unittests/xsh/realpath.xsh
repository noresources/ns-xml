<?xml version="1.0" encoding="UTF-8"?>
<!-- Function declarations -->
<sh:functions xmlns:sh="http://xsd.nore.fr/xsh" xmlns:xi="http://www.w3.org/2001/XInclude">
	<xi:include href="../../ns/xsh/lib/base/base.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function)" />
	<xi:include href="../../ns/xsh/lib/filesystem/filesystem.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function)" />
	
	<sh:function name="ns_testsuite_ns_realpath">
		<sh:body>
		<sh:local name="rootDirectory">$(dirname "${0}")/ns_testsuite_ns_realpath_dir</sh:local>
		<sh:local name="rootFile"/>
		<sh:local name="cwd">$(pwd)</sh:local>
		<sh:local name="relative" />
		<sh:local name="absolute" />	
		<sh:local name="logFile">ns_testsuite_ns_realpath.log</sh:local>
		<![CDATA[
rm -f "${logFile}"
mkdir -p "${rootDirectory}" 2>>"${logFile}" || return 1


# Attempt to get absolute path of rootDirectory using native tools
if which perl 1>/dev/null 2>&1
then
	echo 'Use perl to resolve rootDirectory' 1>>"${logFile}"
	rootDirectory="$(perl -e 'use Cwd "abs_path"; print abs_path(@ARGV[0])' -- "${rootDirectory}")"
elif which realpath 1>/dev/null 2>&1
then
	echo 'Use realpath command to resolve rootDirectory' 1>>"${logFile}"
	rootDirectory="$(realpath "${rootDirectory}")"
elif which grealpath 1>/dev/null 2>&1
then
	echo 'Use grealpath command to resolve rootDirectory' 1>>"${logFile}"
	rootDirectory="$(grealpath "${rootDirectory}")"
else
	echo 'Use "cd" to partially resolve rootDirectory' 1>>"${logFile}"
	# This will not resolve potential symlinks
	cd "${rootDirectory}" 2>>"${logFile}" || return 1
	rootDirectory="$(pwd)" 2>>"${logFile}" || return 1
	cd "${cwd}" 2>>"${logFile}" || return 1
fi

printf "rootDirectory = ${rootDirectory}" 1>> "${logFile}"
rootFile="${rootDirectory}/source-file"
touch "${rootFile}" 2>>"${logFile}" || return 1
echo "rootFile = ${rootFile}" 1>> "${logFile}" 

# Create symbolic links
# Absolute
ln -sf "${rootDirectory}/source-file" "${rootDirectory}/absolute-symlic" 2>>"${logFile}"
# Relative
ln -sf "source-file" "${rootDirectory}/relative-symlic"

relative="$(ns_realpath "${rootDirectory}/relative-symlic")"
absolute="$(ns_realpath "${rootDirectory}/absolute-symlic")"

echo "Expected: ${rootFile}" 1>> "${logFile}"
echo "Relative: ${relative}" 1>> "${logFile}"
echo "Absolute: ${absolute}" 1>> "${logFile}"

[ "${relative}" = "${rootFile}" ] || return 1
[ "${absolute}" = "${rootFile}" ] || return 1

rm -fr "${rootDirectory}"
rm -f "${logFile}"

return 0
]]></sh:body>
	</sh:function>
</sh:functions>

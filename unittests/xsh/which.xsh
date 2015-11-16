<?xml version="1.0" encoding="UTF-8"?>
<!-- Function declarations -->
<sh:functions xmlns:sh="http://xsd.nore.fr/xsh" xmlns:xi="http://www.w3.org/2001/XInclude">
	<xi:include href="../../ns/xsh/lib/base/base.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function)" />
	<xi:include href="../../ns/xsh/lib/filesystem/filesystem.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function)" />
	
	<sh:function name="ns_testsuite_ns_which">
		<sh:body>
		<sh:local name="self">$(ns_realpath "${0}")</sh:local> 
		<sh:local name="selfName">$(basename "${self}")</sh:local>
		<sh:local name="selfDirectory">$(dirname "${self}")</sh:local>
		<sh:local name="envPath">${PATH}</sh:local>
		<sh:local name="result" type="numeric">2</sh:local>
		<![CDATA[
export PATH="${selfDirectory}:${PATH}"
echo "Self: ${selfName}"
echo "Directory: ${selfDirectory}"
echo "Modified PATH: ${PATH}"

ns_which "${selfName}" \
	&& ns_which -s "${selfName}" \
	&& result=0
export PATH="${envPATH}"
return ${result}
]]></sh:body>
	</sh:function>
</sh:functions>

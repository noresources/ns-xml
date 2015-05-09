<?xml version="1.0" encoding="UTF-8"?>
<!-- Function declarations -->
<sh:functions xmlns:sh="http://xsd.nore.fr/xsh" xmlns:xi="http://www.w3.org/2001/XInclude">
	<xi:include href="../../ns/xsh/lib/base/base.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function)" />
	<xi:include href="../../ns/xsh/lib/text/sed.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function)" />

	<sh:function name="ns_testsuite_ns_sed_inplace">
		<sh:body>
			<sh:local name="testFile">${0}.test</sh:local>
			<sh:local name="originalContent">This is the original text</sh:local>
			<sh:local name="modifiedContent">This is the modified text</sh:local>
			<sh:local name="result" type="numeric">2</sh:local>
		<![CDATA[
echo -n "${originalContent}" > "${testFile}"
ns_sed_inplace 's,original,modified,g' "${testFile}" \
&& [ "$(cat "${testFile}" | head -n 1)" = "${modifiedContent}" ] \
&& result=0
rm -f "${testFile}"
return ${result}
]]></sh:body>
	</sh:function>

	<sh:function name="ns_testsuite_ns_sed_inplace_inplaceOptionForm">
		<sh:body><![CDATA[
[ -z "${__ns_sed_inplace_inplaceOptionForm}" ] \
&& return 1 \
|| return 0
]]></sh:body>
	</sh:function>
</sh:functions>

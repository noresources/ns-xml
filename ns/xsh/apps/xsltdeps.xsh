<?xml version="1.0" encoding="UTF-8"?>
<sh:program xmlns:prg="http://xsd.nore.fr/program" xmlns:sh="http://xsd.nore.fr/xsh" xmlns:xi="http://www.w3.org/2001/XInclude" interpreterType="bash">
	<sh:info>
		<xi:include href="xsltdeps.xml" />
	</sh:info>
	<sh:functions>
		<xi:include href="../lib/base/base.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function)" />
		<xi:include href="../lib/base/array.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function)" />
		<xi:include href="../lib/filesystem/filesystem.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh) xpointer(//xsh:function[@name = 'ns_realpath'])" />
		<xi:include href="../lib/filesystem/filesystem.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh) xpointer(//xsh:function[@name = 'ns_relativepath'])" />
		<xi:include href="../lib/filesystem/filesystem.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh) xpointer(//xsh:function[@name = 'ns_mktemp'])" />
		<sh:function name="on_exit">
			<sh:body><![CDATA[
debug Exit
rm -f "${temporaryXsltPath}"
]]></sh:body>
		</sh:function>
		<sh:function name="debug">
			<sh:body>${debugMode} &amp;&amp; echo "${@}"</sh:body>
		</sh:function>
	</sh:functions>
	<sh:code>
		<!-- Include shell script code -->
		<xi:include href="xsltdeps.body.sh" parse="text" />
	</sh:code>
</sh:program>

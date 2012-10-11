<?xml version="1.0" encoding="UTF-8"?>
<!-- {} -->
<sh:program xmlns:prg="http://xsd.nore.fr/program" xmlns:sh="http://xsd.nore.fr/bash" xmlns:xi="http://www.w3.org/2001/XInclude">
	<sh:info>
		<xi:include href="update-doc.xml"/>
	</sh:info>
	<sh:functions>
		<xi:include href="../../ns/xsh/apps/functions.xml" xpointer="xmlns(sh=http://xsd.nore.fr/bash)xpointer(//sh:function)"/>
		<xi:include href="../../ns/xsh/lib/filesystem/filesystem.xml" xpointer="xmlns(sh=http://xsd.nore.fr/bash)xpointer(//sh:function[@name = 'ns_realpath'])"/>
		<xi:include href="../../ns/xsh/lib/filesystem/filesystem.xml" xpointer="xmlns(sh=http://xsd.nore.fr/bash)xpointer(//sh:function[@name = 'ns_relativepath'])"/>
		<xi:include href="../../ns/xsh/lib/text/sed.xml" xpointer="xmlns(sh=http://xsd.nore.fr/bash)xpointer(//sh:function)"/>
		<sh:function name="filesystempath_to_nmepath">
			<sh:parameter name="sourceBasePath"/>
			<sh:parameter name="outputBasePath"/>
			<sh:parameter name="path"/>
			<sh:body><![CDATA[
local output="$(echo "${path#${sourceBasePath}}" | tr -d "/" | tr " " "_")"
output="${outputBasePath}/${output}"
echo "${output}"
			]]></sh:body>
		</sh:function>
	</sh:functions>
	<sh:code>
		<!-- Include shell script code -->
		<xi:include href="update-doc.body.sh" parse="text"/>
	</sh:code>
</sh:program>

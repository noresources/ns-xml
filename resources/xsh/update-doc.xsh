<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the BSD License, see LICENSE -->
<xsh:program interpreterType="bash" xmlns:prg="http://xsd.nore.fr/program" xmlns:xsh="http://xsd.nore.fr/xsh" xmlns:xi="http://www.w3.org/2001/XInclude">
	<xsh:info>
		<xi:include href="update-doc.xml"/>
	</xsh:info>
	<xsh:functions>
		<xi:include href="../../ns/xsh/apps/functions.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function)"/>
		<xi:include href="../../ns/xsh/lib/filesystem/filesystem.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function)"/>
		<xi:include href="../../ns/xsh/lib/text/sed.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function)"/>
		<xsh:function name="filesystempath_to_nmepath">
			<xsh:parameter name="sourceBasePath" />
			<xsh:parameter name="outputBasePath" />
			<xsh:parameter name="path" />
			<xsh:body><![CDATA[
local output="$(echo "${path#${sourceBasePath}}" | tr -d "/" | tr " " "_")"
output="${outputBasePath}/${output}"
echo "${output}"
			]]></xsh:body>
		</xsh:function>
	</xsh:functions>
	<xsh:code>
		<!-- Include shell script code -->
		<xi:include href="update-doc.body.sh" parse="text"/>
	</xsh:code>
</xsh:program>

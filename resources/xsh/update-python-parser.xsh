<?xml version="1.0" encoding="UTF-8"?>
<!-- {} -->
<xsh:program interpreterType="bash" xmlns:prg="http://xsd.nore.fr/program" xmlns:xsh="http://xsd.nore.fr/xsh" xmlns:xi="http://www.w3.org/2001/XInclude">
	<xsh:info>
		<xi:include href="update-python-parser.xml"/>
	</xsh:info>
	<xsh:functions>
		<xi:include href="../../ns/xsh/lib/base/base.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function[@name = 'ns_error'])"/>
		<xi:include href="../../ns/xsh/lib/filesystem/filesystem.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh) xpointer(//xsh:function)"/>
		<xi:include href="../../ns/xsh/lib/text/sed.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh) xpointer(//xsh:function)"/>
	</xsh:functions>
	<xsh:code>
		<!-- Include shell script code -->
		<xi:include href="update-python-parser.body.sh" parse="text"/>
	</xsh:code>
</xsh:program>

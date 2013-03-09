<?xml version="1.0" encoding="UTF-8"?>
<!-- {} -->
<sh:program interpreterType="bash" xmlns:prg="http://xsd.nore.fr/program" xmlns:sh="http://xsd.nore.fr/xsh" xmlns:xi="http://www.w3.org/2001/XInclude">
	<sh:info>
		<xi:include href="build-python.xml"/>
	</sh:info>
	<sh:functions>
		<xi:include href="../lib/filesystem/filesystem.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function[@name = 'ns_realpath'])"/>
		<xi:include href="../lib/filesystem/filesystem.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function[@name = 'ns_mktemp'])"/>
		<xi:include href="../lib/filesystem/filesystem.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function[@name = 'ns_mktempdir'])"/>
		<xi:include href="functions.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function)"/>
	</sh:functions>
	<sh:code>
		<!-- Include shell script code -->
		<xi:include href="build-xxx.body.init.sh" parse="text"/>
		<xi:include href="build-python.body.process.sh" parse="text"/>
	</sh:code>
</sh:program>

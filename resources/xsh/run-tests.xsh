<?xml version="1.0" encoding="UTF-8"?>
<!-- {} -->
<sh:program xmlns:prg="http://xsd.nore.fr/program" xmlns:sh="http://xsd.nore.fr/bash" xmlns:xi="http://www.w3.org/2001/XInclude">
	<sh:info>
		<xi:include href="run-tests.xml"/>
	</sh:info>
	<sh:functions>
		<xi:include href="../../ns/xsh/lib/filesystem/filesystem.xml" xpointer="xmlns(sh=http://xsd.nore.fr/bash)xpointer(//sh:function)"/>
	</sh:functions>
	<sh:code>
		<!-- Include shell script code -->
		<xi:include href="run-tests.body.sh" parse="text"/>
	</sh:code>
</sh:program>

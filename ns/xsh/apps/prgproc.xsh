<?xml version="1.0" encoding="UTF-8"?>
<!-- {} -->
<sh:program xmlns:prg="http://xsd.nore.fr/program" xmlns:sh="http://xsd.nore.fr/bash" xmlns:xi="http://www.w3.org/2001/XInclude">
	<sh:info>
		<xi:include href="prgproc.xml" />
	</sh:info>
	<sh:functions>
		<!-- ns_realpath -->
		<xi:include href="../lib/filesystem/filesystem.xml" xpointer="xmlns(sh=http://xsd.nore.fr/bash)xpointer(//sh:function[@name = 'ns_realpath'])" />
		<!-- ns-xml standard function library -->
		<xi:include href="functions.xml" xpointer="xmlns(sh=http://xsd.nore.fr/bash)xpointer(//sh:function)" />
	</sh:functions>
	<sh:code>
		<!-- Include shell script code -->
		<xi:include href="prgproc.body.sh" parse="text" />
	</sh:code>
</sh:program>

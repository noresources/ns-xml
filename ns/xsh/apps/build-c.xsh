<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2012 by Renaud Guillard (dev@niao.fr) -->
<!-- Distributed under the terms of the BSD License, see LICENSE -->
<!-- {} -->
<sh:program xmlns:prg="http://xsd.nore.fr/program" xmlns:sh="http://xsd.nore.fr/bash" xmlns:xi="http://www.w3.org/2001/XInclude">
	<sh:info>
		<xi:include href="build-c.xml"/>
	</sh:info>
	<sh:functions>
		<xi:include href="../lib/filesystem/filesystem.xml" xpointer="xmlns(sh=http://xsd.nore.fr/bash)xpointer(//sh:function[@name = 'ns_realpath'])"/>
		<xi:include href="functions.xml" xpointer="xmlns(sh=http://xsd.nore.fr/bash)xpointer(//sh:function)"/>
	</sh:functions>
	<sh:code>
		<!-- Include shell script code -->
		<xi:include href="build-c.body.sh" parse="text"/>
	</sh:code>
</sh:program>

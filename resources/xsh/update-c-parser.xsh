<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the BSD License, see LICENSE -->
<sh:program xmlns:prg="http://xsd.nore.fr/program" xmlns:sh="http://xsd.nore.fr/bash" xmlns:xi="http://www.w3.org/2001/XInclude">
	<sh:info>
		<xi:include href="update-c-parser.xml"/>
	</sh:info>
	<sh:functions>
		<xi:include href="../../ns/xsh/apps/functions.xml" xpointer="xmlns(sh=http://xsd.nore.fr/bash)xpointer(//sh:function[@name = 'error'])"/>
		<xi:include href="../../ns/xsh/lib/filesystem/filesystem.xml" xpointer="xmlns(sh=http://xsd.nore.fr/bash)xpointer(//sh:function)"/>
		<xi:include href="../../ns/xsh/lib/text/sed.xml" xpointer="xmlns(sh=http://xsd.nore.fr/bash)xpointer(//sh:function)"/>
	</sh:functions>
	<sh:code>
		<!-- Include shell script code -->
		<xi:include href="update-c-parser.body.sh" parse="text"/>
	</sh:code>
</sh:program>

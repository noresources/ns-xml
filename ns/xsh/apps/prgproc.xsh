<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2018 - 2021 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->
<xsh:program interpreterType="bash" xmlns:prg="http://xsd.nore.fr/program" xmlns:xsh="http://xsd.nore.fr/xsh" xmlns:xi="http://www.w3.org/2001/XInclude">
	<xsh:info>
		<xi:include href="prgproc.xml"/>
	</xsh:info>
	<xsh:functions>
		<!-- base -->
		<xi:include href="../lib/base/base.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function)"/>
		<!-- ns_realpath -->
		<xi:include href="../lib/filesystem/filesystem.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh) xpointer(//xsh:function[@name = 'ns_realpath'])"/>
		<!-- ns-xml standard function library -->
		<xi:include href="functions.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh) xpointer(//xsh:function)"/>
	</xsh:functions>
	<xsh:code>
		<!-- Include shell script code -->
		<xi:include href="prgproc.body.sh" parse="text"/>
	</xsh:code>
</xsh:program>

<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2018 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->
<xsh:program interpreterType="bash" xmlns:prg="http://xsd.nore.fr/program" xmlns:xsh="http://xsd.nore.fr/xsh" xmlns:xi="http://www.w3.org/2001/XInclude">
	<xsh:info>
		<xi:include href="build-shellscript.xml" />
	</xsh:info>
	<xsh:functions>
		<xi:include href="../lib/base/base.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function)"/>
		<xi:include href="../lib/filesystem/filesystem.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh) xpointer(//xsh:function[@name = 'ns_realpath'])" />
		<xi:include href="functions.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh) xpointer(//xsh:function)" />
	</xsh:functions>
	<xsh:code>
		<xi:include href="build-xxx.body.init.sh" parse="text"/>
		<xi:include href="build-shellscript.body.process.sh" parse="text"/>
	</xsh:code>
</xsh:program>

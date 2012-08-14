<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->
<sh:program interpreter="/usr/bin/env bash" xmlns:prg="http://xsd.nore.fr/program" 
xmlns:sh="http://xsd.nore.fr/bash" 
xmlns:xi="http://www.w3.org/2001/XInclude">
<sh:info>
	<xi:include href="sampleapp.xml" />
</sh:info>
<sh:functions>
	<sh:function name="dummy_function">
		<sh:parameter name="dummyParam"/>
		<sh:body>
echo "Dummy message  with   spaces"   

		
echo "And blank lines"
	
		
		</sh:body>
	</sh:function>
	<xi:include href="../lib/filesystem/filesystem.xml" xpointer="xmlns(sh=http://xsd.nore.fr/bash)xpointer(//sh:function[@name = 'ns_issymlink'])" />
</sh:functions>
<sh:code>
<xi:include href="./sampleapp.body.sh" parse="text" />
</sh:code>
</sh:program>

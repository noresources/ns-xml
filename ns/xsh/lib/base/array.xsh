<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2018 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->
<xsh:functions xmlns:xsh="http://xsd.nore.fr/xsh">
	<!-- Array relative functions -->
	<xsh:function name="ns_array_contains">
		<!-- Indicate if a given value is present in a list -->
		<xsh:parameter name="needle" />
		<!-- Value to test -->
		<xsh:body><![CDATA[
for e in "${@}"
do
	[ "${e}" = "${needle}" ] && return 0
done
return 1
]]></xsh:body>
	</xsh:function>
</xsh:functions>

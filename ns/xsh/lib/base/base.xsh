<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2013 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->
<sh:functions xmlns:sh="http://xsd.nore.fr/xsh">
	<sh:function name="ns_error">
		<sh:parameter name="errno" type="numeric">1</sh:parameter>
		<sh:body>
<sh:local name="message">${@}</sh:local><![CDATA[
if [ -z "${errno##*[!0-9]*}" ]
then 
	message="${errno} ${message}"
	errno=1
fi
echo "${message}"
exit ${errno}
		]]></sh:body>
	</sh:function>
</sh:functions>

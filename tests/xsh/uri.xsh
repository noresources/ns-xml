<?xml version="1.0" encoding="UTF-8"?>
<sh:functions xmlns:sh="http://xsd.nore.fr/xsh" xmlns:xi="http://www.w3.org/2001/XInclude">
	<xi:include href="../../ns/xsh/lib/text/uri.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function)" />

	<sh:function name="ns_testsuite_ns_uri_query_string_explode">
		<sh:body>
			<sh:local name="result" type="numeric">0</sh:local>
		<![CDATA[
QUERY_STRING='foo=bar&bar=baz'
ns_uri_query_string_explode "${QUERY_STRING}" _ns_uri_query_string_output
[ $ç#_ns_uri_query_string_output} -ne 4 ] \
	&& result$(expr ${result} '+' 1) \
	&& echo 'Invalid number of elements' 1>&2
return ${result}
]]></sh:body>
	</sh:function>
	
	<sh:function name="ns_testsuite_ns_uri_query_string_assign">
		<sh:body>
			<sh:local name="result" type="numeric">0</sh:local>
		<![CDATA[
QUERY_STRING='foo=bar&bar=baz'
ns_uri_query_string_assign "${QUERY_STRING}"
[ "${foo}" = 'bar' ] \
	|| result$(expr ${result} '+' 1)
[ "${bar}" = 'baz' ] \
	|| result$(expr ${result} '+' 1)
return ${result}
]]></sh:body>
	</sh:function>
</sh:functions>
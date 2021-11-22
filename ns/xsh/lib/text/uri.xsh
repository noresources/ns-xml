<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 - 2021 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->
<xsh:functions xmlns:xsh="http://xsd.nore.fr/xsh">
	<!-- Transform URI query string to array where even indexes are keys and odd indexes are values

		/!\ This function use "eval" and may be dangerous.
	-->
	<xsh:function name="ns_uri_query_string_explode">
		<!-- Query string -->
		<xsh:parameter name="_ns_uri_query_string_input" />
		<!-- Array variable name to fill -->
		<xsh:parameter name="_ns_uri_query_string_output" />
		<xsh:body>
			<xsh:local name="_ns_uri_query_string_ifs">$IFS</xsh:local>
		<![CDATA[
unset ${_ns_uri_query_string_output}
IFS='&='
eval "${_ns_uri_query_string_output}=(${_ns_uri_query_string_input})"
IFS="${_ns_uri_query_string_ifs}"
]]></xsh:body>
	</xsh:function>

	<!-- Map each query string parameter to a variable of the same name

		/!\ This function use "eval" and may be dangerous.
	-->
	<xsh:function name="ns_uri_query_string_assign">
		<!-- Query string -->
		<xsh:parameter name="_ns_uri_query_string_input" />
		<xsh:body>
			<xsh:local name="_ns_uri_query_string_ifs">$IFS</xsh:local>
			<xsh:local name="_ns_uri_query_string_output" />
			<xsh:local name="_ns_uri_query_string_e" />
			<xsh:local name="_ns_uri_query_string_key" />
		<![CDATA[
unset ${_ns_uri_query_string_output}
IFS='&='
eval "${_ns_uri_query_string_output}=(${_ns_uri_query_string_input})"
IFS="${_ns_uri_query_string_ifs}"
_ns_uri_query_string_key=''
for _ns_uri_query_string_e in "${_ns_uri_query_string_output[@]}"
do
	if [ -z "${_ns_uri_query_string_key}" ]
	then
		_ns_uri_query_string_key="${_ns_uri_query_string_e}"
	else
		eval "${_ns_uri_query_string_key}='${_ns_uri_query_string_e}'"
		_ns_uri_query_string_key=''
	fi
done 
]]></xsh:body>
	</xsh:function>
</xsh:functions>

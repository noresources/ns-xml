<?xml version="1.0" encoding="UTF-8"?>
<!-- Function declarations -->
<sh:functions xmlns:sh="http://xsd.nore.fr/xsh" xmlns:xi="http://www.w3.org/2001/XInclude">
	<xi:include href="../../ns/xsh/lib/text/semver.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function)" />

	<sh:function name="ns_testsuite_ns_semver_number_to_string">
		<sh:body>
			<sh:local name="result" type="numeric">0</sh:local>
		<![CDATA[
[ "$(ns_semver_number_to_string 1)" = "0.0.1" ] || result="$(expr ${result} + 1)"
[ "$(ns_semver_number_to_string 20301)" = "2.3.1" ] || result="$(expr ${result} + 1)"
[ "$(ns_semver_number_to_string abc)" = "" ] || result="$(expr ${result} + 1)"
return ${result}
]]></sh:body>
	</sh:function>

	<sh:function name="ns_testsuite_ns_semver_string_to_number">
		<sh:body>
			<sh:local name="result" type="numeric">0</sh:local>
		<![CDATA[
[ "$(ns_semver_string_to_number 1)" = '10000' ] || result="$(expr ${result} + 1)"
[ "$(ns_semver_string_to_number 5.4)" = '50400' ] || result="$(expr ${result} + 1)"
[ "$(ns_semver_string_to_number 3.14.2)" = '31402' ] || result="$(expr ${result} + 1)"
[ "$(ns_semver_string_to_number 3.zz.2)" = '' ] || result="$(expr ${result} + 1)"
return ${result}
]]></sh:body>
	</sh:function>
	
	<sh:function name="ns_testsuite_ns_semver_get">
		<sh:body>
			<sh:local name="result" type="numeric">0</sh:local>
		<![CDATA[
[ "$(ns_semver_get major '1.0.2-alpha+b2')" = '1' ] || result="$(expr ${result} + 1)"
[ "$(ns_semver_get label '1.0.2-alpha+b2')" = 'alpha' ] || result="$(expr ${result} + 1)"
[ "$(ns_semver_get patch '1.0.2-alpha+b2')" = '2' ] || result="$(expr ${result} + 1)"
[ "$(ns_semver_get metadata '1.0.2-alpha+b2')" = 'b2' ] || result="$(expr ${result} + 1)"
[ "$(ns_semver_get metadata '1.0.2-alpha')" = '' ] || result="$(expr ${result} + 1)"
[ "$(ns_semver_get metadata '1.0+meta')" = 'meta' ] || result="$(expr ${result} + 1)"
return ${result}
]]></sh:body>
	</sh:function>
</sh:functions>

<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 - 2021 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->
<xsh:functions xmlns:xsh="http://xsd.nore.fr/xsh">
	<xsh:function name="ns_text_boolean_to_text">
		<xsh:parameter name="v" />
		<xsh:parameter name="t">true</xsh:parameter>
		<xsh:parameter name="f">false</xsh:parameter>
		<xsh:body><![CDATA[
if type ${v} 1>/dev/null 2>&1
then
	if ${v}
	then
		echo ${t}
	else
		echo ${f}
	fi
else
	if [ "${v}" == "0" ]
	then
		echo ${t}
	else
		echo ${f}
	fi
fi
]]></xsh:body>
	</xsh:function>
	
	<xsh:function name="ns_text_yesno">
		<xsh:parameter name="v" />
		<xsh:body><![CDATA[
ns_text_boolean_to_text ${1} yes no
]]></xsh:body>
	</xsh:function>
	
	<xsh:function name="ns_text_truefalse">
		<xsh:parameter name="v" />
		<xsh:body><![CDATA[
ns_text_boolean_to_text ${v} yes no
]]></xsh:body>
	</xsh:function>
	
	<xsh:function name="ns_text_charcount">
		<xsh:parameter name="string" />
		<xsh:parameter name="char" />
		<xsh:body><![CDATA[
count="$(expr $(echo "${string}" | sed "s/[^${char}]//g" | wc -c) - 1)"
echo ${count}
]]></xsh:body>
	</xsh:function>
	
	<xsh:function name="ns_text_tolower">
		<xsh:parameter name="string" />
		<xsh:body><![CDATA[
if which tr 1>/dev/null 2>&1
then
	echo "${string}" | tr '[:upper:]' '[:lower:]'
	return
fi

echo "${string}"
]]></xsh:body>
	</xsh:function>
	
	<xsh:function name="ns_text_toupper">
		<xsh:parameter name="string" />
		<xsh:body><![CDATA[
if which tr 1>/dev/null 2>&1
then
	echo "${string}" | tr '[:lower:]' '[:upper:]'
	return
fi

echo "${string}"
]]></xsh:body>
	</xsh:function>
	
	<xsh:function name="ns_text_contains">
		<xsh:parameter name="source" />
		<xsh:parameter name="pattern" />
		<xsh:body><![CDATA[
if echo "${source}" | grep "${pattern}" 1>/dev/null 2>&1
then
	return 0
fi
return 1
]]></xsh:body>
	</xsh:function>
	
	<xsh:function name="ns_text_trim_cr"><xsh:body><![CDATA[
# Try tr (the best)
if which tr 1>/dev/null 2>&1
then
	echo "${@}" | tr -d "\r"
# Try awk (quite good too)
elif which awk 1>/dev/null 2>&1
then
	echo "${@}" | awk '{sub(/\r/,"")};1'
# Try perl (heavyier but safer than sed)
elif which perl 1>/dev/null 2>&1
then
	echo "${@}" | perl -0pe "s/\r//g"
# Sed - no real standard way to do it
# this command shoud not work
elif which sed 1>/dev/null 2>&1
then
	echo "${@}" | sed 's/\r//g'
# No luck
else
	echo "${@}"
fi
		]]></xsh:body>
	</xsh:function>
	
	<!-- Concatenate array elements into a single string -->
	<xsh:function name="ns_text_implode">
		<xsh:parameter name="glue" />
		<xsh:parameter name="before" />
		<xsh:parameter name="after" />
		<xsh:body>
		<xsh:local name="stringResult" />
		<xsh:local name="stringElement" />
		<![CDATA[
for stringElement in "${@}"
do
	[ -z "${stringResult}" ] || stringResult="${stringResult}${glue}"
	stringResult="${stringResult}${before}${stringElement}${after}"
done
echo "${stringResult}"
]]></xsh:body>
	</xsh:function>
</xsh:functions>

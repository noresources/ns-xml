<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2018 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->
<sh:functions xmlns:sh="http://xsd.nore.fr/xsh">
	<sh:function name="ns_text_boolean_to_text">
		<sh:parameter name="v" />
		<sh:parameter name="t">true</sh:parameter>
		<sh:parameter name="f">false</sh:parameter>
		<sh:body><![CDATA[
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
]]></sh:body>
	</sh:function>
	
	<sh:function name="ns_text_yesno">
		<sh:parameter name="v" />
		<sh:body><![CDATA[
ns_text_boolean_to_text ${1} yes no
]]></sh:body>
	</sh:function>
	
	<sh:function name="ns_text_truefalse">
		<sh:parameter name="v" />
		<sh:body><![CDATA[
ns_text_boolean_to_text ${v} yes no
]]></sh:body>
	</sh:function>
	
	<sh:function name="ns_text_charcount">
		<sh:parameter name="string" />
		<sh:parameter name="char" />
		<sh:body><![CDATA[
count="$(expr $(echo "${string}" | sed "s/[^${char}]//g" | wc -c) - 1)"
echo ${count}
]]></sh:body>
	</sh:function>
	
	<sh:function name="ns_text_tolower">
		<sh:parameter name="string" />
		<sh:body><![CDATA[
if which tr 1>/dev/null 2>&1
then
	echo "${string}" | tr '[:upper:]' '[:lower:]'
	return
fi

echo "${string}"
]]></sh:body>
	</sh:function>
	
	<sh:function name="ns_text_toupper">
		<sh:parameter name="string" />
		<sh:body><![CDATA[
if which tr 1>/dev/null 2>&1
then
	echo "${string}" | tr '[:lower:]' '[:upper:]'
	return
fi

echo "${string}"
]]></sh:body>
	</sh:function>
	
	<sh:function name="ns_text_contains">
		<sh:parameter name="source" />
		<sh:parameter name="pattern" />
		<sh:body><![CDATA[
if echo "${source}" | grep "${pattern}" 1>/dev/null 2>&1
then
	return 0
fi
return 1
]]></sh:body>
	</sh:function>
	
	<sh:function name="ns_text_trim_cr"><sh:body><![CDATA[
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
		]]></sh:body>
	</sh:function>
	
	<!-- Concatenate array elements into a single string -->
	<sh:function name="ns_text_implode">
		<sh:parameter name="glue" />
		<sh:parameter name="before" />
		<sh:parameter name="after" />
		<sh:body>
		<sh:local name="stringResult" />
		<sh:local name="stringElement" />
		<![CDATA[
for stringElement in "${@}"
do
	[ -z "${stringResult}" ] || stringResult="${stringResult}${glue}"
	stringResult="${stringResult}${before}${stringElement}${after}"
done
echo "${stringResult}"
]]></sh:body>
	</sh:function>
</sh:functions>

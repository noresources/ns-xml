<?xml version="1.0" encoding="UTF-8"?>
<sh:program xmlns:prg="http://xsd.nore.fr/program" 
xmlns:sh="http://xsd.nore.fr/bash" 
xmlns:xi="http://www.w3.org/2001/XInclude">
<sh:info>
	<xi:include href="sampleapp.xml" />
</sh:info>
<sh:functions>
	<sh:function name="dummy_function">
		<sh:parameter name="dummyParam"/>
		<sh:body>echo Dummy</sh:body>
	</sh:function>
	<xi:include href="../lib/filesystem/filesystem.xml" xpointer="xmlns(sh=http://xsd.nore.fr/bash)xpointer(//sh:function[@name = 'ns_issymlink'])" />
</sh:functions>
<sh:code><![CDATA[
if ! parse "${@}"
then
	parse_displayerrors
	exit 1
fi

echo "Sample application called with ${#} argument(s): ${@}"
i=1
while [ ${i} -le $# ]
do
	echo $i:${!i}
	i=$(expr $i + 1)
done
echo "Sub command: ${parser_subcommand}"
echo "Values (${#parser_values[*]})"
for ((i=0;${i}<${#parser_values[*]};i++))
do
	echo " - ${parser_values[${i}]}"
done

${displayHelp} && usage
if [ "${parser_subcommand}" == "help" ] 
then
	([ ${#parser_values[*]} -gt 0 ] && usage "${parser_values[0]}") || usage
fi

exit 0 
]]></sh:code>
</sh:program>

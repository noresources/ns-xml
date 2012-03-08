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
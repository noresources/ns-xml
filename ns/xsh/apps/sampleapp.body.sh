#echo "Wait a moment (just for fun!)"
#sleep 2

arg_value()
{
	local a="${1}"
	echo "${a}=${!a}"
}

marg_value()
{
	local a="${1}"
	local i=0
	echo -n "${a}=("
	eval "for ((i=0;\$i<\${#${a}[*]};i++)); do [ \${i} -gt 0 ] && echo -n \", \"; echo -n \"\${i}=\${${a}[\${i}]}\"; done"
	echo ")"
}

echo "Sample application called with ${#} argument(s): ${@}"
i=1
while [ ${i} -le $# ]
do
	echo $i:${!i}
	i=$(expr $i + 1)
done

if ! parse "${@}"
then
	if [ ${displayHelp} ]
	then
		usage
		exit 0
	fi
	parse_displayerrors
	exit 1
fi
if [ ${displayHelp} ]
then
	usage
	exit 0
fi

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

# Display values
arg_value standardArg
marg_value gma 

exit 0

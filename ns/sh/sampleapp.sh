#!/bin/bash
# ####################################
# Author: Renaud Guillard
# Version: 1.0
# 
# Sample application
#
# Program help
usage()
{
if [ ! -z "${1}" ]
then
case "${1}" in
sub)
cat << EOFSCUSAGE
sub: A sub-command (sub)
Usage: sampleapp sub [--switch] [--sc-existing-file-argument <path>] [--sc-strict-enum <...>]
With:
  --switch, --sc-switch: Switch of the sub command
  	The bound variable name can be the same as another subcommand variable or 
  	one of the global option. In this case, you have to set the prg.sh.parser.
  	prefixSubcommandOptionVariable xslt parameter to 'yes'
  --sc-existing-file-argument: Sub command file argument
  --sc-strict-enum: Sub command argument (strict set)	
  	The argument value have to be one of the following:	
  		OptionA, ValueB or ItemC
EOFSCUSAGE
;;
help | hep | sos)
cat << EOFSCUSAGE
help: Help about other sub commands
Usage: sampleapp help
EOFSCUSAGE
;;
version)
cat << EOFSCUSAGE
version: 
Usage: sampleapp version
EOFSCUSAGE
;;

esac
return 0
fi
cat << EOFUSAGE
sampleapp: Sample application
Usage: 
  sampleapp <subcommand [subcommand option(s)]> [-vs] [--help] [--ui-only <...>] [--standard-arg <...>] [--switch-alone-in-group] [(--tlxg1 <...> | --tlxg2 <...>)] [(--basic-argument <...> --string-argument <string> | --argument-with-default <...> | (--numeric-argument <number> | --float-argument <number>))] [--existing-file-argument <path>] [--rw-folder-argument <path>] [--mixed-fskind-argument <path>] [--multi-argument <...  [ ... ]> --multi-select-argument <...  [ ... ]> --multi-xml <path [ ... ]>] [-H <...>] [-P <path>] [-E <...>] [-e <...>]
  With subcommand:
    sub: A sub-command (sub)
      options: [--switch] [--sc-existing-file-argument <path>] [--sc-strict-enum <...>]
    help, hep, sos: Help about other sub commands
    version:
  With global options:
    --help: 
    --verbose, --bleeeeh, -v: More text!
    --ui-only: A single argument option automatically set in the UI
    --standard-arg: Basic argument option
    	This option will accept any kind of argument
    -s, --simpleswitch: Simple switch
    	A simple switch option (true/false)
    A useless group option
    	--switch-alone-in-group: Another switch
    		This swith is in a group with only one option. So, the group is hidden and 
    		the option appears at the same level
    
    Exclusive option group
    	--tlxg1: ArgGA
    	--tlxg2: ArgG2
    
    Exclusive option group
    	Nested group (basic type arguments)
    		--basic-argument: Basic argument
    		--string-argument: String argument
    			This argument expect a string, which is roughly the same thing as 
    	accepting 
    			any kind of content
    	
    	--argument-with-default: Argument (with default value)
    		A default value is proposed. If the user does not change it, the option 
    	will 
    		not appear in the command line	
    		Default value: Default value
    	Nested exclusive group
    		--numeric-argument: Numeric argument
    			Only numberrs are accepted as argument value. A numeric argument appears 
    	as 
    			a spin box in the UI
    		--float-argument: Float argument
    			Numeric argument with decimals. A minimum (1.0) and maximum (10) values 
    	are 
    			also defined
    	
    
    --existing-file-argument: File argument
    	An existing file argument
    --rw-folder-argument: Folder argument
    	Expect a folder with Read/Write access
    --mixed-fskind-argument: File, folder etc.
    	Accept most of file system object types. On some UI and platforms, you can't 
    	select a folder in the file box if files are also accepted.
    Multi argument options
    	--multi-argument: Multi argument
    		A basic multi argument options	
    		Minimal argument count: 2
    		Maximal argument count: 3
    	--multi-select-argument: Multi select argument
    		Accept only a fixed set of values	
    		The argument value have to be one of the following:	
    			FirstOption, Second option or Third option
    	--multi-xml: Xml files
    		Expect a file. XML files are welcome but others are accepted
    
    --hostname, -H: Hostname
    	Accept a host name. In console mode, the autocompletion will propose hosts 
    	defined in /etc/hosts.
    --simple-pattern-sh, -P: 
    --strict-enum, -E: Strict enumeration	
    	The argument value have to be one of the following:	
    		Option A, Value B, Item C or ItemD with space
    	Default value: Value B
    --non-strict-enum, -e: Non-restrictive enumeration
    	Non restricive enumeration will only propose some values in autocompletion 
    	but will accept any other values	
    	The argument can be:	
    		nOptionA, nValueB, nItemC or nItemD with space

  This application demonstrates most of the possibilities offered by the program schema to define and display command line options
EOFUSAGE
}

# Program parameter parsing
parser_shell="$(readlink /proc/$$/exe | sed "s/.*\/\([a-z]*\)[0-9]*/\1/g")"
parser_input=("${@}")
parser_itemcount=${#parser_input[*]}
parser_startindex=0
parser_index=0
parser_subindex=0
parser_item=""
parser_option=""
parser_optiontail=""
parser_subcommand=""
parser_subcommand_expected=true
PARSER_OK=0
PARSER_ERROR=1
PARSER_SC_OK=0
PARSER_SC_ERROR=1
PARSER_SC_UNKNOWN=2
PARSER_SC_SKIP=3
# Compatibility with shell which use "1" as start index
[ "${parser_shell}" = "zsh" ] && parser_startindex=1
parser_itemcount=$(expr ${parser_startindex} + ${parser_itemcount})
parser_index=${parser_startindex}

# Required global options
# (Subcommand required options will be added later)


# Switch options

displayHelp=false
verboseProgram=false
switch=false
grpSwitch=false
sub_switch=false
# Single argument options

uiArg=
standardArg=
tlxg1=
tlxg2=
garg=
gsarg=
dgarg="Default value"
gnarg=
gn2arg=
gfarg=
gFarg=
gmfarg=
strictEnum="Value B"
nonStrictEnum=
sub_subFile=
sub_subEnum=
# Group default options
globalArgumentsGroup="@dgarg"

parse_addwarning()
{
	local message="${1}"
	local m="[${parser_option}:${parser_index}:${parser_subindex}] ${message}"
	local c=${#parser_warnings[*]}
	c=$(expr ${c} + ${parser_startindex})
	parser_warnings[${c}]="${m}"
}
parse_adderror()
{
	local message="${1}"
	local m="[${parser_option}:${parser_index}:${parser_subindex}] ${message}"
	local c=${#parser_errors[*]}
	c=$(expr ${c} + ${parser_startindex})
	parser_errors[${c}]="${m}"
}
parse_addfatalerror()
{
	local message="${1}"
	local m="[${parser_option}:${parser_index}:${parser_subindex}] ${message}"
	local c=${#parser_fatalerrors[*]}
	c=$(expr ${c} + ${parser_startindex})
	parser_fatalerrors[${c}]="${m}"
}

parse_displayerrors()
{
	for ((i=${parser_startindex};${i}<${#parser_errors[*]};i++))
	do
		echo -e "\t- ${parser_errors[${i}]}"
	done
}


parse_pathaccesscheck()
{
	local file="${1}"
	local accessString="${2}"
	while [ ! -z "${accessString}" ]
	do
		[ -${accessString:0:1} ${file} ] || return 1;
		accessString=${accessString:1}
	done
	return 0
}
parse_setoptionpresence()
{
	for ((i=${parser_startindex};${i}<$(expr ${parser_startindex} + ${#parser_required[*]});i++))
	do
		local idPart="$(echo "${parser_required[${i}]}" | cut -f 1 -d":" )"
		if [ "${idPart}" = "${1}" ]
		then
			parser_required[${i}]=""
			return 0
		fi
	done
	return 1
}
parse_checkrequired()
{
	# First round: set default values
	
	for ((i=${parser_startindex};${i}<$(expr ${parser_startindex} + ${#parser_required[*]});i++))
	do
		local todoPart="$(echo "${parser_required[${i}]}" | cut -f 3 -d":" )"
		[ -z "${todoPart}" ] || eval "${todoPart}"
	done
	local c=0
	for ((i=${parser_startindex};${i}<$(expr ${parser_startindex} + ${#parser_required[*]});i++))
	do
		if [ ! -z "${parser_required[${i}]}" ]
		then
			local displayPart="$(echo "${parser_required[${i}]}" | cut -f 2 -d":" )"
			parser_errors[${#parser_errors[*]}]="Missing required option ${displayPart}"
			c=$(expr ${c} + 1)
		fi
	done
	return ${c}
}
parse_checkminmax()
{
	local errorCount=0
	# Check min argument for multiargument
	if [ ${#gma[*]} -gt 0 ] && [ ${#gma[*]} -lt 2 ]
	then
		parser_errors[${#parser_errors[*]}]="Invalid argument count for option \"--multi-argument\". At least 2 expected, ${#gma[*]} given"
		errorCount=$(expr ${errorCount} + 1)
	fi
	
	return ${errorCount}
}
parse_enumcheck()
{
	local ref="${1}"
	shift 1
	while [ $# -gt 0 ]
	do
		if [ "${ref}" = "${1}" ]
		then
			return 0
		fi
		shift
	done
	return 1
}
parse_addvalue()
{
	local position=${#parser_values[*]}
	local value="${1}"
	if [ -z "${parser_subcommand}" ]
	then
		case "${position}" in
		0)
			;;
		1)
			if ! parse_pathaccesscheck "${value}" "rw"
			then
				parse_adderror "Invalid path permissions for \"${value}\", rw privilege(s) expected for positional argument ${position}"
			fi
			
			
			;;
		2)
			;;
		*)
			;;
		
		esac
	else
		case "${parser_subcommand}" in
		sub)
			case "${position}" in
			*)
				;;
			
			esac
			;;
		help)
			case "${position}" in
			0)
				if ! ([ "${value}" = "sub" ] || [ "${value}" = "help" ])
				then
					parse_adderror "Invalid value for positional argument ${position}"
				fi
				
				;;
			*)
				;;
			
			esac
			;;
		version)
			parser_errors[${#parser_errors[*]}]="Positional argument not allowed in subcommand version"
			return ${PARSER_ERROR}
			;;
		*)
			return ${PARSER_ERROR}
			;;
		
		esac
	fi
	parser_values[${#parser_values[*]}]="${1}"
}
parse_process_subcommand_option()
{
	parser_item="${parser_input[${parser_index}]}"
	if [ -z "${parser_item}" ] || [ "${parser_item:0:1}" != "-" ] || [ "${parser_item}" = "--" ]
	then
		return ${PARSER_SC_SKIP}
	fi
	
	case "${parser_subcommand}" in
	sub)
		if [ "${parser_item:0:2}" = "--" ] 
		then
			parser_option="${parser_item:2}"
			if echo "${parser_option}" | grep "=" 1>/dev/null 2>&1
			then
				parser_optiontail="$(echo "${parser_option}" | cut -f 2- -d"=")"
				parser_option="$(echo "${parser_option}" | cut -f 1 -d"=")"
			fi
			
			case "${parser_option}" in
			switch | sc-switch)
				if [ ! -z "${parser_optiontail}" ]
				then
					parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
					parser_optiontail=""
					return ${PARSER_SC_ERROR}
				fi
				sub_switch=true
				parse_setoptionpresence SC_1_sub_1_switch
				;;
			sc-existing-file-argument)
				if [ ! -z "${parser_optiontail}" ]
				then
					parser_item="${parser_optiontail}"
				else
					parser_index=$(expr ${parser_index} + 1)
					if [ ${parser_index} -ge ${parser_itemcount} ]
					then
						parse_adderror "End of input reached - Argument expected"
						return ${PARSER_SC_ERROR}
					fi
					
					parser_item="${parser_input[${parser_index}]}"
					if [ "${parser_item}" = "--" ]
					then
						parse_adderror "End of option marker found - Argument expected"
						parser_index=$(expr ${parser_index} - 1)
						return ${PARSER_SC_ERROR}
					fi
				fi
				
				parser_subindex=0
				parser_optiontail=""
				[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
				if [ ! -e "${parser_item}" ]
				then
					parse_adderror "Invalid path \"${parser_item}\" for option \"${parser_option}\""
					return ${PARSER_SC_ERROR}
				fi
				
				sub_subFile="${parser_item}"
				parse_setoptionpresence SC_1_sub_2_sc-existing-file-argument
				;;
			sc-strict-enum)
				if [ ! -z "${parser_optiontail}" ]
				then
					parser_item="${parser_optiontail}"
				else
					parser_index=$(expr ${parser_index} + 1)
					if [ ${parser_index} -ge ${parser_itemcount} ]
					then
						parse_adderror "End of input reached - Argument expected"
						return ${PARSER_SC_ERROR}
					fi
					
					parser_item="${parser_input[${parser_index}]}"
					if [ "${parser_item}" = "--" ]
					then
						parse_adderror "End of option marker found - Argument expected"
						parser_index=$(expr ${parser_index} - 1)
						return ${PARSER_SC_ERROR}
					fi
				fi
				
				parser_subindex=0
				parser_optiontail=""
				[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
				if ! ([ "${parser_item}" = "OptionA" ] || [ "${parser_item}" = "ValueB" ] || [ "${parser_item}" = "ItemC" ])
				then
					parse_adderror "Invalid value for option \"${parser_option}\""
					
					return ${PARSER_SC_ERROR}
				fi
				sub_subEnum="${parser_item}"
				parse_setoptionpresence SC_1_sub_3_sc-strict-enum
				;;
			*)
				return ${PARSER_SC_SKIP}
				;;
			
			esac
		fi
		;;
	
	esac
	return ${PARSER_SC_OK}
}
parse_process_option()
{
	if [ ! -z "${parser_subcommand}" ] && [ "${parser_item}" != "--" ]
	then
		if parse_process_subcommand_option "${@}"
		then
			return ${PARSER_OK}
		fi
		if [ ${parser_index} -ge ${parser_itemcount} ]
		then
			return ${PARSER_OK}
		fi
	fi
	
	parser_item="${parser_input[${parser_index}]}"
	
	if [ -z "${parser_item}" ]
	then
		return ${PARSER_OK}
	fi
	
	if [ "${parser_item}" = "--" ]
	then
		for ((a=$(expr ${parser_index} + 1);${a}<${parser_itemcount};a++))
		do
			parse_addvalue "${parser_input[${a}]}"
		done
		parser_index=${parser_itemcount}
		return ${PARSER_OK}
	elif [ "${parser_item}" = "-" ]
	then
		return ${PARSER_OK}
	elif [ "${parser_item:0:2}" = "\-" ]
	then
		parse_addvalue "${parser_item:1}"
	elif [ "${parser_item:0:2}" = "--" ] 
	then
		parser_option="${parser_item:2}"
		if echo "${parser_option}" | grep "=" 1>/dev/null 2>&1
		then
			parser_optiontail="$(echo "${parser_option}" | cut -f 2- -d"=")"
			parser_option="$(echo "${parser_option}" | cut -f 1 -d"=")"
		fi
		
		case "${parser_option}" in
		help)
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_ERROR}
			fi
			displayHelp=true
			parse_setoptionpresence G_1_help
			;;
		verbose | bleeeeh)
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_ERROR}
			fi
			verboseProgram=true
			parse_setoptionpresence G_2_verbose
			;;
		ui-only)
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = "--" ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			uiArg="${parser_item}"
			parse_setoptionpresence G_3_ui-only
			;;
		standard-arg)
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = "--" ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			standardArg="${parser_item}"
			parse_setoptionpresence G_4_standard-arg
			;;
		simpleswitch)
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_ERROR}
			fi
			switch=true
			parse_setoptionpresence G_5_simpleswitch
			;;
		existing-file-argument)
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = "--" ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			if [ ! -e "${parser_item}" ]
			then
				parse_adderror "Invalid path \"${parser_item}\" for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			gfarg="${parser_item}"
			parse_setoptionpresence G_9_existing-file-argument
			;;
		rw-folder-argument)
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = "--" ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			if [ ! -e "${parser_item}" ]
			then
				parse_adderror "Invalid path \"${parser_item}\" for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			if ! parse_pathaccesscheck "${parser_item}" "rw"
			then
				parse_adderror "Invalid path permissions for \"${parser_item}\", rw privilege(s) expected for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			if ! ([ -d "${parser_item}" ])
			then
				parse_adderror "Invalid patn type for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			gFarg="${parser_item}"
			parse_setoptionpresence G_10_rw-folder-argument
			;;
		mixed-fskind-argument)
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = "--" ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			if ! parse_pathaccesscheck "${parser_item}" "rw"
			then
				parse_adderror "Invalid path permissions for \"${parser_item}\", rw privilege(s) expected for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			if ! ([ -f "${parser_item}" ] || [ -S "${parser_item}" ] || [ -d "${parser_item}" ] || [ -L "${parser_item}" ])
			then
				parse_adderror "Invalid patn type for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			gmfarg="${parser_item}"
			parse_setoptionpresence G_11_mixed-fskind-argument
			;;
		hostname)
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = "--" ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			
			parse_setoptionpresence G_13_hostname
			;;
		simple-pattern-sh)
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = "--" ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			if ! parse_pathaccesscheck "${parser_item}" "x"
			then
				parse_adderror "Invalid path permissions for \"${parser_item}\", x privilege(s) expected for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			
			parse_setoptionpresence G_14_simple-pattern-sh
			;;
		strict-enum)
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = "--" ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			if ! ([ "${parser_item}" = "Option A" ] || [ "${parser_item}" = "Value B" ] || [ "${parser_item}" = "Item C" ] || [ "${parser_item}" = "ItemD with space" ])
			then
				parse_adderror "Invalid value for option \"${parser_option}\""
				
				return ${PARSER_ERROR}
			fi
			strictEnum="${parser_item}"
			parse_setoptionpresence G_15_strict-enum
			;;
		non-strict-enum)
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = "--" ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			nonStrictEnum="${parser_item}"
			parse_setoptionpresence G_16_non-strict-enum
			;;
		switch-alone-in-group)
			# Group checks
			
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_ERROR}
			fi
			grpSwitch=true
			parse_setoptionpresence G_6_g_1_switch-alone-in-group;parse_setoptionpresence G_6_g
			;;
		tlxg1)
			# Group checks
			
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = "--" ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			tlxg1="${parser_item}"
			parse_setoptionpresence G_7_g_1_tlxg1;parse_setoptionpresence G_7_g
			;;
		tlxg2)
			# Group checks
			
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = "--" ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			tlxg2="${parser_item}"
			parse_setoptionpresence G_7_g_2_tlxg2;parse_setoptionpresence G_7_g
			;;
		basic-argument)
			# Group checks
			
			if ! ([ -z "${globalArgumentsGroup}" ] || [ "${globalArgumentsGroup}" = "nestedGroup" ] || [ "${globalArgumentsGroup:0:1}" = "@" ])
			then
				parse_adderror "Another option of the group \"globalArgumentsGroup\" was previously set (${globalArgumentsGroup})"
				return ${PARSER_ERROR}
			fi
			
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = "--" ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			garg="${parser_item}"
			globalArgumentsGroup="nestedGroup"
			nestedGroup="garg"
			parse_setoptionpresence G_8_g_1_g_1_basic-argument;parse_setoptionpresence G_8_g_1_g;parse_setoptionpresence G_8_g
			;;
		string-argument)
			# Group checks
			
			if ! ([ -z "${globalArgumentsGroup}" ] || [ "${globalArgumentsGroup}" = "nestedGroup" ] || [ "${globalArgumentsGroup:0:1}" = "@" ])
			then
				parse_adderror "Another option of the group \"globalArgumentsGroup\" was previously set (${globalArgumentsGroup})"
				return ${PARSER_ERROR}
			fi
			
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = "--" ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			gsarg="${parser_item}"
			globalArgumentsGroup="nestedGroup"
			nestedGroup="gsarg"
			parse_setoptionpresence G_8_g_1_g_2_string-argument;parse_setoptionpresence G_8_g_1_g;parse_setoptionpresence G_8_g
			;;
		argument-with-default)
			# Group checks
			
			if ! ([ -z "${globalArgumentsGroup}" ] || [ "${globalArgumentsGroup}" = "dgarg" ] || [ "${globalArgumentsGroup:0:1}" = "@" ])
			then
				parse_adderror "Another option of the group \"globalArgumentsGroup\" was previously set (${globalArgumentsGroup})"
				return ${PARSER_ERROR}
			fi
			
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = "--" ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			dgarg="${parser_item}"
			globalArgumentsGroup="dgarg"
			parse_setoptionpresence G_8_g_2_argument-with-default;parse_setoptionpresence G_8_g
			;;
		numeric-argument)
			# Group checks
			
			if ! ([ -z "${globalArgumentsGroup}" ] || [ "${globalArgumentsGroup}" = "nestedExclusiveGroup" ] || [ "${globalArgumentsGroup:0:1}" = "@" ])
			then
				parse_adderror "Another option of the group \"globalArgumentsGroup\" was previously set (${globalArgumentsGroup})"
				return ${PARSER_ERROR}
			fi
			
			if ! ([ -z "${nestedExclusiveGroup}" ] || [ "${nestedExclusiveGroup}" = "gnarg" ] || [ "${nestedExclusiveGroup:0:1}" = "@" ])
			then
				parse_adderror "Another option of the group \"nestedExclusiveGroup\" was previously set (${nestedExclusiveGroup})"
				return ${PARSER_ERROR}
			fi
			
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = "--" ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			gnarg="${parser_item}"
			globalArgumentsGroup="nestedExclusiveGroup"
			nestedExclusiveGroup="gnarg"
			parse_setoptionpresence G_8_g_3_g_1_numeric-argument;parse_setoptionpresence G_8_g_3_g;parse_setoptionpresence G_8_g
			;;
		float-argument)
			# Group checks
			
			if ! ([ -z "${globalArgumentsGroup}" ] || [ "${globalArgumentsGroup}" = "nestedExclusiveGroup" ] || [ "${globalArgumentsGroup:0:1}" = "@" ])
			then
				parse_adderror "Another option of the group \"globalArgumentsGroup\" was previously set (${globalArgumentsGroup})"
				return ${PARSER_ERROR}
			fi
			
			if ! ([ -z "${nestedExclusiveGroup}" ] || [ "${nestedExclusiveGroup}" = "gn2arg" ] || [ "${nestedExclusiveGroup:0:1}" = "@" ])
			then
				parse_adderror "Another option of the group \"nestedExclusiveGroup\" was previously set (${nestedExclusiveGroup})"
				return ${PARSER_ERROR}
			fi
			
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = "--" ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			gn2arg="${parser_item}"
			globalArgumentsGroup="nestedExclusiveGroup"
			nestedExclusiveGroup="gn2arg"
			parse_setoptionpresence G_8_g_3_g_2_float-argument;parse_setoptionpresence G_8_g_3_g;parse_setoptionpresence G_8_g
			;;
		multi-argument)
			# Group checks
			
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			local parser_ma_local_count=0
			local parser_ma_total_count=${#gma[*]}
			if [ ${parser_ma_total_count} -ge 3 ]
			then
				parse_adderror "Maximum argument count reached for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			if [ -z "${parser_item}" ]
			then
				gma[${#gma[*]}]="${parser_item}"
				parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
				parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
			fi
			
			local parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
			while [ ${parser_ma_total_count} -lt 3 ] && [ ! -z "${parser_nextitem}" ] && [ "${parser_nextitem}" != "--" ] && [ ${parser_index} -lt ${parser_itemcount} ]
			do
				if [ ${parser_ma_local_count} -gt 0 ] && [ "${parser_nextitem:0:1}" == "-" ]
				then
					break
				fi
				
				parser_index=$(expr ${parser_index} + 1)
				parser_item="${parser_input[${parser_index}]}"
				[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
				gma[${#gma[*]}]="${parser_item}"
				parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
				parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
				parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
			done
			if [ ${parser_ma_local_count} -eq 0 ]
			then
				parse_adderror "At least one argument expected for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			parse_setoptionpresence G_12_g_1_multi-argument;parse_setoptionpresence G_12_g
			;;
		multi-select-argument)
			# Group checks
			
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			local parser_ma_local_count=0
			local parser_ma_total_count=${#gmsa[*]}
			if [ -z "${parser_item}" ]
			then
				if ! ([ "${parser_item}" = "FirstOption " ] || [ "${parser_item}" = "Second option" ] || [ "${parser_item}" = "Third option" ])
				then
					parse_adderror "Invalid value for option \"${parser_option}\""
					
					return ${PARSER_ERROR}
				fi
				gmsa[${#gmsa[*]}]="${parser_item}"
				parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
				parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
			fi
			
			local parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
			while [ ! -z "${parser_nextitem}" ] && [ "${parser_nextitem}" != "--" ] && [ ${parser_index} -lt ${parser_itemcount} ]
			do
				if [ ${parser_ma_local_count} -gt 0 ] && [ "${parser_nextitem:0:1}" == "-" ]
				then
					break
				fi
				
				parser_index=$(expr ${parser_index} + 1)
				parser_item="${parser_input[${parser_index}]}"
				[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
				if ! ([ "${parser_item}" = "FirstOption " ] || [ "${parser_item}" = "Second option" ] || [ "${parser_item}" = "Third option" ])
				then
					parse_adderror "Invalid value for option \"${parser_option}\""
					
					return ${PARSER_ERROR}
				fi
				gmsa[${#gmsa[*]}]="${parser_item}"
				parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
				parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
				parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
			done
			if [ ${parser_ma_local_count} -eq 0 ]
			then
				parse_adderror "At least one argument expected for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			parse_setoptionpresence G_12_g_2_multi-select-argument;parse_setoptionpresence G_12_g
			;;
		multi-xml)
			# Group checks
			
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			local parser_ma_local_count=0
			local parser_ma_total_count=${#gmaxml[*]}
			if [ -z "${parser_item}" ]
			then
				gmaxml[${#gmaxml[*]}]="${parser_item}"
				parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
				parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
			fi
			
			local parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
			while [ ! -z "${parser_nextitem}" ] && [ "${parser_nextitem}" != "--" ] && [ ${parser_index} -lt ${parser_itemcount} ]
			do
				if [ ${parser_ma_local_count} -gt 0 ] && [ "${parser_nextitem:0:1}" == "-" ]
				then
					break
				fi
				
				parser_index=$(expr ${parser_index} + 1)
				parser_item="${parser_input[${parser_index}]}"
				[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
				gmaxml[${#gmaxml[*]}]="${parser_item}"
				parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
				parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
				parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
			done
			if [ ${parser_ma_local_count} -eq 0 ]
			then
				parse_adderror "At least one argument expected for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			parse_setoptionpresence G_12_g_3_multi-xml;parse_setoptionpresence G_12_g
			;;
		*)
			parse_adderror "Unknown option \"${parser_option}\""
			return ${PARSER_ERROR}
			;;
		
		esac
	elif [ "${parser_item:0:1}" = "-" ] && [ ${#parser_item} -gt 1 ]
	then
		parser_optiontail="${parser_item:$(expr ${parser_subindex} + 2)}"
		parser_option="${parser_item:$(expr ${parser_subindex} + 1):1}"
		if [ -z "${parser_option}" ]
		then
			parser_subindex=0
			return ${PARSER_SC_OK}
		fi
		
		case "${parser_option}" in
		v)
			verboseProgram=true
			parse_setoptionpresence G_2_verbose
			;;
		s)
			switch=true
			parse_setoptionpresence G_5_simpleswitch
			;;
		H)
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = "--" ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			
			parse_setoptionpresence G_13_hostname
			;;
		P)
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = "--" ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			if ! parse_pathaccesscheck "${parser_item}" "x"
			then
				parse_adderror "Invalid path permissions for \"${parser_item}\", x privilege(s) expected for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			
			parse_setoptionpresence G_14_simple-pattern-sh
			;;
		E)
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = "--" ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			if ! ([ "${parser_item}" = "Option A" ] || [ "${parser_item}" = "Value B" ] || [ "${parser_item}" = "Item C" ] || [ "${parser_item}" = "ItemD with space" ])
			then
				parse_adderror "Invalid value for option \"${parser_option}\""
				
				return ${PARSER_ERROR}
			fi
			strictEnum="${parser_item}"
			parse_setoptionpresence G_15_strict-enum
			;;
		e)
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = "--" ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			nonStrictEnum="${parser_item}"
			parse_setoptionpresence G_16_non-strict-enum
			;;
		*)
			parse_adderror "Unknown option \"${parser_option}\""
			return ${PARSER_ERROR}
			;;
		
		esac
	elif ${parser_subcommand_expected} && [ -z "${parser_subcommand}" ] && [ ${#parser_values[*]} -eq 0 ]
	then
		case "${parser_item}" in
		sub)
			parser_subcommand="sub"
			;;
		help | hep | sos)
			parser_subcommand="help"
			;;
		version)
			parser_subcommand="version"
			;;
		*)
			parse_addvalue "${parser_item}"
			;;
		
		esac
	else
		parse_addvalue "${parser_item}"
	fi
	return ${PARSER_OK}
}
parse()
{
	while [ ${parser_index} -lt ${parser_itemcount} ]
	do
		parse_process_option "${0}"
		if [ -z "${parser_optiontail}" ]
		then
			parser_index=$(expr ${parser_index} + 1)
			parser_subindex=0
		else
			parser_subindex=$(expr ${parser_subindex} + 1)
		fi
	done
	
	# Set default option for group G_8_g (if not already set)
	if [ "${globalArgumentsGroup:0:1}" = "@" ]
	then
		globalArgumentsGroup="dgarg"
		parse_setoptionpresence G_8_g
	fi
	
	parse_checkrequired
	parse_checkminmax
	
	local parser_errorcount=${#parser_errors[*]}
	if [ ${parser_errorcount} -eq 1 ] && [ -z "${parser_errors}" ]
	then
		parser_errorcount=0
	fi
	return ${parser_errorcount}
}

dummy_function()
{
	local dummyParam="${1}"
	shift
	echo "Dummy message  with   spaces"   
	
			
	echo "And blank lines"
}
ns_issymlink()
{
	local path="${1}"
	shift
	[ ! -z "${path}" ] && [ -L "${path}" ]
}

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
	parse_displayerrors
	exit 1
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

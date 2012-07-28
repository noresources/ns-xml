#!/bin/bash
# ####################################
# Copyright © 2012 by Renaud GUillard (dev@niao.fr)
# Author: renaud
# Version: 1.0
# 
# Process a program interface XML definition with one of the available XSLT stylesheets
#
# Program help
usage()
{
cat << EOFUSAGE
prgproc: Process a program interface XML definition with one of the available XSLT stylesheets
Usage: 
  prgproc [-x <path>] -t <...> [-o <path>] [-p <...  [ ... ]>] [-s <...  [ ... ]>] [--ns-xml-path <path> --ns-xml-path-relative] [--help]
  With:
    -x, --xml-description: Program description file
    	If the program description file is provided, the xml file will be validated 
    	before any XSLT processing
    --xslt, --xsl, -t: XSL transformation to apply	
    	The argument value have to be one of the following:	
    		bashcompletion, c-gengetopt, docbook-usage or wikicreole-usage
    --output, -o: Output file
    	If no output file is provided, the transformation result will be sent to the 
    	standard output.
    --param, --params, -p: pass a (parameter,value) pair	
    	Minimal argument count: 2
    --stringparam, --stringparams, -s: pass a (parameter, UTF8 string value) pair	
    	Minimal argument count: 2
    ns-xml source path options
    	--ns-xml-path: ns-xml source path
    		Location of the ns folder of ns-xml package
    	--ns-xml-path-relative: ns source path is relative this program path
    
    --help: Display program usage

  This tool automatically select the good version of the XSLT stylesheet according to the @version attribute of the given XML file.
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
parser_subcommand_expected=false
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


parser_required[${#parser_required[*]}]="G_2_xslt:--xslt"
# Switch options

nsxmlPathRelative=false
displayHelp=false
# Single argument options

xmlProgramDescriptionPath=
xslName=
output=
nsxmlPath=

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
	if [ ! -a "${file}" ]
	then
		return 0
	fi
	
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
	if [ ${#parameters[*]} -gt 0 ] && [ ${#parameters[*]} -lt 2 ]
	then
		parser_errors[${#parser_errors[*]}]="Invalid argument count for option \"--param\". At least 2 expected, ${#parameters[*]} given"
		errorCount=$(expr ${errorCount} + 1)
	fi
	if [ ${#stringParameters[*]} -gt 0 ] && [ ${#stringParameters[*]} -lt 2 ]
	then
		parser_errors[${#parser_errors[*]}]="Invalid argument count for option \"--stringparam\". At least 2 expected, ${#stringParameters[*]} given"
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
		parser_errors[${#parser_errors[*]}]="Positional argument not allowed"
		return ${PARSER_ERROR}
	else
		case "${parser_subcommand}" in
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
		xml-description)
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
			
			if [ -a "${parser_item}" ] && ! ([ -f "${parser_item}" ])
			then
				parse_adderror "Invalid patn type for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			xmlProgramDescriptionPath="${parser_item}"
			parse_setoptionpresence G_1_xml-description
			;;
		xslt | xsl)
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
			if ! ([ "${parser_item}" = "bashcompletion" ] || [ "${parser_item}" = "c-gengetopt" ] || [ "${parser_item}" = "docbook-usage" ] || [ "${parser_item}" = "wikicreole-usage" ])
			then
				parse_adderror "Invalid value for option \"${parser_option}\""
				
				return ${PARSER_ERROR}
			fi
			xslName="${parser_item}"
			parse_setoptionpresence G_2_xslt
			;;
		output)
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
			if ! parse_pathaccesscheck "${parser_item}" "w"
			then
				parse_adderror "Invalid path permissions for \"${parser_item}\", w privilege(s) expected for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			if [ -a "${parser_item}" ] && ! ([ -f "${parser_item}" ])
			then
				parse_adderror "Invalid patn type for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			output="${parser_item}"
			parse_setoptionpresence G_3_output
			;;
		param | params)
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			local parser_ma_local_count=0
			local parser_ma_total_count=${#parameters[*]}
			if [ -z "${parser_item}" ]
			then
				parameters[${#parameters[*]}]="${parser_item}"
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
				parameters[${#parameters[*]}]="${parser_item}"
				parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
				parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
				parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
			done
			if [ ${parser_ma_local_count} -eq 0 ]
			then
				parse_adderror "At least one argument expected for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			parse_setoptionpresence G_4_param
			;;
		stringparam | stringparams)
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			local parser_ma_local_count=0
			local parser_ma_total_count=${#stringParameters[*]}
			if [ -z "${parser_item}" ]
			then
				stringParameters[${#stringParameters[*]}]="${parser_item}"
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
				stringParameters[${#stringParameters[*]}]="${parser_item}"
				parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
				parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
				parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
			done
			if [ ${parser_ma_local_count} -eq 0 ]
			then
				parse_adderror "At least one argument expected for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			parse_setoptionpresence G_5_stringparam
			;;
		help)
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_ERROR}
			fi
			displayHelp=true
			parse_setoptionpresence G_7_help
			;;
		ns-xml-path)
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
			nsxmlPath="${parser_item}"
			parse_setoptionpresence G_6_g_1_ns-xml-path;parse_setoptionpresence G_6_g
			;;
		ns-xml-path-relative)
			# Group checks
			
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_ERROR}
			fi
			nsxmlPathRelative=true
			parse_setoptionpresence G_6_g_2_ns-xml-path-relative;parse_setoptionpresence G_6_g
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
		x)
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
			
			if [ -a "${parser_item}" ] && ! ([ -f "${parser_item}" ])
			then
				parse_adderror "Invalid patn type for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			xmlProgramDescriptionPath="${parser_item}"
			parse_setoptionpresence G_1_xml-description
			;;
		t)
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
			if ! ([ "${parser_item}" = "bashcompletion" ] || [ "${parser_item}" = "c-gengetopt" ] || [ "${parser_item}" = "docbook-usage" ] || [ "${parser_item}" = "wikicreole-usage" ])
			then
				parse_adderror "Invalid value for option \"${parser_option}\""
				
				return ${PARSER_ERROR}
			fi
			xslName="${parser_item}"
			parse_setoptionpresence G_2_xslt
			;;
		o)
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
			if ! parse_pathaccesscheck "${parser_item}" "w"
			then
				parse_adderror "Invalid path permissions for \"${parser_item}\", w privilege(s) expected for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			if [ -a "${parser_item}" ] && ! ([ -f "${parser_item}" ])
			then
				parse_adderror "Invalid patn type for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			output="${parser_item}"
			parse_setoptionpresence G_3_output
			;;
		p)
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			local parser_ma_local_count=0
			local parser_ma_total_count=${#parameters[*]}
			if [ -z "${parser_item}" ]
			then
				parameters[${#parameters[*]}]="${parser_item}"
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
				parameters[${#parameters[*]}]="${parser_item}"
				parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
				parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
				parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
			done
			if [ ${parser_ma_local_count} -eq 0 ]
			then
				parse_adderror "At least one argument expected for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			parse_setoptionpresence G_4_param
			;;
		s)
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			local parser_ma_local_count=0
			local parser_ma_total_count=${#stringParameters[*]}
			if [ -z "${parser_item}" ]
			then
				stringParameters[${#stringParameters[*]}]="${parser_item}"
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
				stringParameters[${#stringParameters[*]}]="${parser_item}"
				parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
				parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
				parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
			done
			if [ ${parser_ma_local_count} -eq 0 ]
			then
				parse_adderror "At least one argument expected for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			parse_setoptionpresence G_5_stringparam
			;;
		*)
			parse_adderror "Unknown option \"${parser_option}\""
			return ${PARSER_ERROR}
			;;
		
		esac
	elif ${parser_subcommand_expected} && [ -z "${parser_subcommand}" ] && [ ${#parser_values[*]} -eq 0 ]
	then
		case "${parser_item}" in
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
	
	parse_checkrequired
	parse_checkminmax
	
	local parser_errorcount=${#parser_errors[*]}
	if [ ${parser_errorcount} -eq 1 ] && [ -z "${parser_errors}" ]
	then
		parser_errorcount=0
	fi
	return ${parser_errorcount}
}

ns_realpath()
{
	local path="${1}"
	shift
	local cwd="$(pwd)"
	[ -d "${path}" ] && cd "${path}" && path="."
	while [ -h "${path}" ] ; do path="$(readlink "${path}")"; done
	
	if [ -d "${path}" ]
	then
		path="$( cd -P "$( dirname "${path}" )" && pwd )"
	else
		path="$( cd -P "$( dirname "${path}" )" && pwd )/$(basename "${path}")"
	fi
	
	cd "${cwd}" 1>/dev/null 2>&1
	echo "${path}"
}
error()
{
	local errno=${1}
	[ -z "${errno}" ] && errno=1
	shift
	local message="${@}"
	if [ -z "${errno##*[!0-9]*}" ]
	then 
		message="${errno} ${message}"
		errno=1
	fi
	echo "${message}"
	exit ${errno}
}
chunk_check_nsxml_ns_path()
{
	if [ ! -z "${nsxmlPath}" ]
	then
		if ${nsxmlPathRelative}
		then
			nsPath="${scriptPath}/${nsxmlPath}"
		else
			nsPath="${nsxmlPath}"
		fi
		
		[ -d "${nsPath}" ] || return 1
		
		nsPath="$(ns_realpath "${nsPath}")"
	fi
	[ -d "${nsPath}" ]
}
get_program_version()
{
	local file="${1}"
	shift
	local tmpXslFile="/tmp/get_program_version.xsl"
	cat > "${tmpXslFile}" << GETPROGRAMVERSIONXSLEOF
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	<xsl:output method="text" encoding="utf-8" />
	<xsl:template match="//prg:program">
		<xsl:value-of select="@version" />
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
</xsl:stylesheet>
GETPROGRAMVERSIONXSLEOF

	local result="$(xsltproc --xinclude "${tmpXslFile}" "${file}")"
	rm -f "${tmpXslFile}"
	if [ ! -z "${result##*[!0-9.]*}" ]
	then
		echo "${result}"
		return 0
	else
		return 1
	fi

	
}
xml_validate()
{
	local schema="${1}"
	shift
	local xml="${1}"
	shift
	local tmpOut="/tmp/xml_validate.tmp"
	if ! xmllint --xinclude --noout --schema "${schema}" "${xml}" 1>"${tmpOut}" 2>&1
	then
		cat "${tmpOut}"
		echo "Schema: ${scheam}"
		echo "File: ${xml}"
		return 1
	fi
	
	return 0
}
scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
nsPath="$(ns_realpath "${scriptPath}/..")"
programVersion="2.0"


if ! parse "${@}"
then
	if ${displayHelp}
	then
		usage
		exit 0
	fi
	
	parse_displayerrors
	exit 1
fi

if ${displayHelp}
then
	usage
	exit 0
fi

chunk_check_nsxml_ns_path || error "Invalid ns-xml ns folder (${nsPath})"
programVersion="$(get_program_version "${xmlProgramDescriptionPath}")"

xslFile="${nsPath}/xsl/program/${programVersion}/${xslName}.xsl"

[ -f "${xslFile}" ] || error 2 "Unable to find \"${xslFile}\""

xsltprocCommand[${parser_startindex}]="xsltproc"
xsltprocCommand[${#xsltprocCommand[*]}]="--xinclude"
if [ ! -z "${output}" ]
then
	xsltprocCommand[${#xsltprocCommand[*]}]="--output"
	xsltprocCommand[${#xsltprocCommand[*]}]="${output}"
fi

count=${#stringParameters[*]}
mc=$(expr ${count} % 2)
[ ${mc} -eq 1 ] && error 2 "Invalid number of arguments for --stringparam. Even value expected, got ${count}"
limit=$(expr ${parser_startindex} + ${count})
for ((i=${parser_startindex};${i}<${limit};i+=2))
do
	p="${stringParameters[${i}]}"
	v="${stringParameters[$(expr ${i} + 1)]}"
	xsltprocCommand[${#xsltprocCommand[*]}]="--stringparam"
	xsltprocCommand[${#xsltprocCommand[*]}]="${p}"
	xsltprocCommand[${#xsltprocCommand[*]}]="${v}"
done

count=${#parameters[*]}
mc=$(expr ${count} % 2)
[ ${mc} -eq 1 ] && error 2 "Invalid number of arguments for --stringparam. Even value expected, got ${count}"
limit=$(expr ${parser_startindex} + ${count})
for ((i=${parser_startindex};${i}<${limit};i+=2))
do
	p="${parameters[${i}]}"
	v="${parameters[$(expr ${i} + 1)]}"
	xsltprocCommand[${#xsltprocCommand[*]}]="--param"
	xsltprocCommand[${#xsltprocCommand[*]}]="${p}"
	xsltprocCommand[${#xsltprocCommand[*]}]="${v}"
done

xsltprocCommand[${#xsltprocCommand[*]}]="${xslFile}"
xsltprocCommand[${#xsltprocCommand[*]}]="${xmlProgramDescriptionPath}"
 
"${xsltprocCommand[@]}"

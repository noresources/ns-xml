#!/usr/bin/env bash
# ####################################
# Copyright © 2011 - 2021 by Renaud Guillard (dev@nore.fr)
# Distributed under the terms of the MIT License, see
# 		LICENSE
# 	
# Author: Renaud Guillard
# Version: 2.1.0
# 
# Shell script builder which use program interface XML definition file to automatically generate command line processing and help messages
#
# Program help
usage()
{
cat << 'EOFUSAGE'
build-shellscript: Shell script builder which use program interface XML definition file to automatically generate command line processing and help messages

Usage: 
  build-shellscript [-Sp] -s <path> [-x <path>] [(-i <...> | -I <...>)] [--force-interpreter] -o <path> [--ns-xml-path <path> --ns-xml-path-relative] [--debug-comments] [--debug-trace] [--help]
  
  Options:
    -s, --shell: XML shell file
      A XML file following the XML shell script (XSH) schema
      The file may include a program interface XML definition
    -x, --xml-description: Program description file
      If the program description file is provided, the xml file will be 
      validated before any XSLT processing
    -S, --skip-validation, --no-validation: Skip XML Schema validations
      The default behavior of the program is to validate the given xml-based 
      file(s) against its/their xml schema (http://xsd.nore.fr/program etc.). 
      This option will disable schema validations
    Default interpreter
      -i, --interpreter: Default shell interpreter type
        The interpreter family to use if the XSH file does not define one.  
        The argument can be one of the following :  
          bash, zsh or ksh
      -I, --interpreter-cmd: Default shell interpreter invocation directive
        This value if used if the XSH file does not define one  
        The argument can be one of the following :  
          /usr/bin/env bash, /bin/bash, /usr/bin/env zsh or /bin/zsh
    
    --force-interpreter: 
      Force to use the interpreter defined by --interpreter or --interpreter-cmd
      This option has no meaning if none of --interpreter or --interpreter-cmd 
      is set
    -p, --prefix-sc-variables: Prefix subcommand options bound variable names
      This will prefix all subcommand options bound variable name by the 
      subcommand name (sc_varianbleNmae). This avoid variable name aliasing.
    -o, --output: Output file path
    ns-xml source path options
      --ns-xml-path: ns-xml source path
        Location of the ns folder of ns-xml package
      --ns-xml-path-relative: ns source path is relative this program path
    
    --debug-comments: Add debug comments in code
    --debug-trace: Parse will print debug informations
    --help: Display program usage
EOFUSAGE
}

# Program parameter parsing
parser_program_author="Renaud Guillard"
parser_program_version="2.1.0"
if [ -r /proc/$$/exe ]
then
	parser_shell="$(readlink /proc/$$/exe | sed "s/.*\/\([a-z]*\)[0-9]*/\1/g")"
else
	parser_shell="$(basename "$(ps -p $$ -o command= | cut -f 1 -d' ')")"
fi

parser_input=("${@}")
parser_itemcount=${#parser_input[*]}
parser_startindex=0
parser_index=0
parser_subindex=0
parser_item=''
parser_option=''
parser_optiontail=''
parser_subcommand=''
parser_subcommand_expected=false
parser_subcommand_names=()
PARSER_OK=0
PARSER_ERROR=1
PARSER_SC_OK=0
PARSER_SC_ERROR=1
PARSER_SC_UNKNOWN=2
PARSER_SC_SKIP=3
[ "${parser_shell}" = 'zsh' ] && parser_startindex=1
parser_itemcount=$(expr ${parser_startindex} + ${parser_itemcount})
parser_index=${parser_startindex}


parser_required[$(expr ${#parser_required[*]} + ${parser_startindex})]="G_1_shell:--shell:"
parser_required[$(expr ${#parser_required[*]} + ${parser_startindex})]="G_7_output:--output:"

skipValidation=false
forceInterpreter=false
prefixSubcommandBoundVariableName=false
nsxmlPathRelative=false
debugComments=false
debugTrace=false
displayHelp=false
xmlShellFileDescriptionPath=
xmlProgramDescriptionPath=
defaultInterpreterType=
defaultInterpreterCommand=
outputScriptFilePath=
nsxmlPath=

parse_addwarning()
{
	local message="${1}"
	local m="[${parser_option}:${parser_index}:${parser_subindex}] ${message}"
	parser_warnings[$(expr ${#parser_warnings[*]} + ${parser_startindex})]="${m}"
}
parse_adderror()
{
	local message="${1}"
	local m="[${parser_option}:${parser_index}:${parser_subindex}] ${message}"
	parser_errors[$(expr ${#parser_errors[*]} + ${parser_startindex})]="${m}"
}
parse_addfatalerror()
{
	local message="${1}"
	local m="[${parser_option}:${parser_index}:${parser_subindex}] ${message}"
	parser_errors[$(expr ${#parser_errors[*]} + ${parser_startindex})]="${m}"
	parser_aborted=true
}

parse_displayerrors()
{
	for error in "${parser_errors[@]}"
	do
		echo -e "\t- ${error}"
	done
}


parse_pathaccesscheck()
{
	local file="${1}"
	[ ! -a "${file}" ] && return 0
	
	local accessString="${2}"
	while [ ! -z "${accessString}" ]
	do
		[ -${accessString:0:1} ${file} ] || return 1;
		accessString=${accessString:1}
	done
	return 0
}
parse_addrequiredoption()
{
	local id="${1}"
	local tail="${2}"
	local o=
	for o in "${parser_required[@]}"
	do
		local idPart="$(echo "${o}" | cut -f 1 -d":")"
		[ "${id}" = "${idPart}" ] && return 0
	done
	parser_required[$(expr ${#parser_required[*]} + ${parser_startindex})]="${id}:${tail}"
}
parse_setoptionpresence()
{
	parse_isoptionpresent "${1}" && return 0
	
	case "${1}" in
	G_4_g_1_interpreter)
		if ! ([ -z "${defaultInterpreter}" ] || [ "${defaultInterpreter:0:1}" = '@' ] || [ "${defaultInterpreter}" = "defaultInterpreterType" ])
		then
			parse_adderror "Another option of the group \"defaultInterpreter\" was previously set (${defaultInterpreter}"
			return ${PARSER_ERROR}
		fi
		
		
		;;
	G_4_g_2_interpreter_cmd)
		if ! ([ -z "${defaultInterpreter}" ] || [ "${defaultInterpreter:0:1}" = '@' ] || [ "${defaultInterpreter}" = "defaultInterpreterCommand" ])
		then
			parse_adderror "Another option of the group \"defaultInterpreter\" was previously set (${defaultInterpreter}"
			return ${PARSER_ERROR}
		fi
		
		
		;;
	G_8_g_1_ns_xml_path)
		;;
	G_8_g_2_ns_xml_path_relative)
		;;
	
	esac
	case "${1}" in
	G_8_g)
		;;
	
	esac
	parser_present[$(expr ${#parser_present[*]} + ${parser_startindex})]="${1}"
	return 0
}
parse_isoptionpresent()
{
	local _e_found=false
	local _e=
	for _e in "${parser_present[@]}"
	do
		if [ "${_e}" = "${1}" ]
		then
			_e_found=true; break
		fi
	done
	if ${_e_found}
	then
		return 0
	else
		return 1
	fi
}
parse_checkrequired()
{
	[ ${#parser_required[*]} -eq 0 ] && return 0
	local c=0
	for o in "${parser_required[@]}"
	do
		local idPart="$(echo "${o}" | cut -f 1 -d":")"
		local _e_found=false
		local _e=
		for _e in "${parser_present[@]}"
		do
			if [ "${_e}" = "${idPart}" ]
			then
				_e_found=true; break
			fi
		done
		if ! (${_e_found})
		then
			local displayPart="$(echo "${o}" | cut -f 2 -d":")"
			parser_errors[$(expr ${#parser_errors[*]} + ${parser_startindex})]="Missing required option ${displayPart}"
			c=$(expr ${c} + 1)
		fi
	done
	return ${c}
}
parse_setdefaultoptions()
{
	local parser_set_default=false
}
parse_checkminmax()
{
	local errorCount=0
	return ${errorCount}
}
parse_numberlesserequalcheck()
{
	local hasBC=false
	which bc 1>/dev/null 2>&1 && hasBC=true
	if ${hasBC}
	then
		[ "$(echo "${1} <= ${2}" | bc)" = "0" ] && return 1
	else
		local a_int="$(echo "${1}" | cut -f 1 -d".")"
		local a_dec="$(echo "${1}" | cut -f 2 -d".")"
		[ "${a_dec}" = "${1}" ] && a_dec="0"
		local b_int="$(echo "${2}" | cut -f 1 -d".")"
		local b_dec="$(echo "${2}" | cut -f 2 -d".")"
		[ "${b_dec}" = "${2}" ] && b_dec="0"
		[ ${a_int} -lt ${b_int} ] && return 0
		[ ${a_int} -gt ${b_int} ] && return 1
		([ ${a_int} -ge 0 ] && [ ${a_dec} -gt ${b_dec} ]) && return 1
		([ ${a_int} -lt 0 ] && [ ${b_dec} -gt ${a_dec} ]) && return 1
	fi
	return 0
}
parse_enumcheck()
{
	local ref="${1}"
	shift 1
	while [ $# -gt 0 ]
	do
		[ "${ref}" = "${1}" ] && return 0
		shift
	done
	return 1
}
parse_addvalue()
{
	local position=${#parser_values[*]}
	local value=
	if [ $# -gt 0 ] && [ ! -z "${1}" ]; then value="${1}"; else return ${PARSER_ERROR}; fi
	shift
	if [ -z "${parser_subcommand}" ]
	then
		${parser_isfirstpositionalargument} && parser_errors[$(expr ${#parser_errors[*]} + ${parser_startindex})]='Program does not accept positional arguments'
		
		parser_isfirstpositionalargument=false
		return ${PARSER_ERROR}
	else
		case "${parser_subcommand}" in
		*)
			return ${PARSER_ERROR}
			;;
		
		esac
	fi
	parser_values[$(expr ${#parser_values[*]} + ${parser_startindex})]="${value}"
}
parse_process_subcommand_option()
{
	parser_item="${parser_input[${parser_index}]}"
	if [ -z "${parser_item}" ] || [ "${parser_item:0:1}" != "-" ] || [ "${parser_item}" = '--' ]
	then
		return ${PARSER_SC_SKIP}
	fi
	
	return ${PARSER_SC_SKIP}
}
parse_process_option()
{
	if [ ! -z "${parser_subcommand}" ] && [ "${parser_item}" != '--' ]
	then
		parse_process_subcommand_option && return ${PARSER_OK}
		[ ${parser_index} -ge ${parser_itemcount} ] && return ${PARSER_OK}
	fi
	
	parser_item="${parser_input[${parser_index}]}"
	
	[ -z "${parser_item}" ] && return ${PARSER_OK}
	
	if [ "${parser_item}" = '--' ]
	then
		for ((a=$(expr ${parser_index} + 1);${a}<=$(expr ${parser_itemcount} - 1);a++))
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
	elif [ "${parser_item:0:2}" = '--' ] 
	then
		parser_option="${parser_item:2}"
		parser_optionhastail=false
		if echo "${parser_option}" | grep '=' 1>/dev/null 2>&1
		then
			parser_optionhastail=true
			parser_optiontail="$(echo "${parser_option}" | cut -f 2- -d"=")"
			parser_option="$(echo "${parser_option}" | cut -f 1 -d"=")"
		fi
		
		case "${parser_option}" in
		shell)
			if ${parser_optionhastail}
			then
				parser_item=${parser_optiontail}
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = '--' ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=''
			parser_optionhastail=false
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
			
			! parse_setoptionpresence G_1_shell && return ${PARSER_ERROR}
			
			xmlShellFileDescriptionPath="${parser_item}"
			
			;;
		xml-description)
			if ${parser_optionhastail}
			then
				parser_item=${parser_optiontail}
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = '--' ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=''
			parser_optionhastail=false
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
			
			! parse_setoptionpresence G_2_xml_description && return ${PARSER_ERROR}
			
			xmlProgramDescriptionPath="${parser_item}"
			
			;;
		skip-validation | no-validation)
			! parse_setoptionpresence G_3_skip_validation && return ${PARSER_ERROR}
			
			if ${parser_optionhastail} && [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Option --${parser_option} does not allow an argument"
				parser_optiontail=''
				return ${PARSER_ERROR}
			fi
			skipValidation=true
			
			;;
		force-interpreter)
			! parse_setoptionpresence G_5_force_interpreter && return ${PARSER_ERROR}
			
			if ${parser_optionhastail} && [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Option --${parser_option} does not allow an argument"
				parser_optiontail=''
				return ${PARSER_ERROR}
			fi
			forceInterpreter=true
			
			;;
		prefix-sc-variables)
			! parse_setoptionpresence G_6_prefix_sc_variables && return ${PARSER_ERROR}
			
			if ${parser_optionhastail} && [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Option --${parser_option} does not allow an argument"
				parser_optiontail=''
				return ${PARSER_ERROR}
			fi
			prefixSubcommandBoundVariableName=true
			
			;;
		output)
			if ${parser_optionhastail}
			then
				parser_item=${parser_optiontail}
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = '--' ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=''
			parser_optionhastail=false
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			! parse_setoptionpresence G_7_output && return ${PARSER_ERROR}
			
			outputScriptFilePath="${parser_item}"
			
			;;
		debug-comments)
			! parse_setoptionpresence G_9_debug_comments && return ${PARSER_ERROR}
			
			if ${parser_optionhastail} && [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Option --${parser_option} does not allow an argument"
				parser_optiontail=''
				return ${PARSER_ERROR}
			fi
			debugComments=true
			
			;;
		debug-trace)
			! parse_setoptionpresence G_10_debug_trace && return ${PARSER_ERROR}
			
			if ${parser_optionhastail} && [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Option --${parser_option} does not allow an argument"
				parser_optiontail=''
				return ${PARSER_ERROR}
			fi
			debugTrace=true
			
			;;
		help)
			! parse_setoptionpresence G_11_help && return ${PARSER_ERROR}
			
			if ${parser_optionhastail} && [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Option --${parser_option} does not allow an argument"
				parser_optiontail=''
				return ${PARSER_ERROR}
			fi
			displayHelp=true
			
			;;
		interpreter)
			if ${parser_optionhastail}
			then
				parser_item=${parser_optiontail}
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = '--' ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=''
			parser_optionhastail=false
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			! parse_setoptionpresence G_4_g_1_interpreter && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_4_g && return ${PARSER_ERROR}
			
			defaultInterpreterType="${parser_item}"
			defaultInterpreter='defaultInterpreterType'
			
			;;
		interpreter-cmd)
			if ${parser_optionhastail}
			then
				parser_item=${parser_optiontail}
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = '--' ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=''
			parser_optionhastail=false
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			! parse_setoptionpresence G_4_g_2_interpreter_cmd && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_4_g && return ${PARSER_ERROR}
			
			defaultInterpreterCommand="${parser_item}"
			defaultInterpreter='defaultInterpreterCommand'
			
			;;
		ns-xml-path)
			if ${parser_optionhastail}
			then
				parser_item=${parser_optiontail}
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = '--' ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=''
			parser_optionhastail=false
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			! parse_setoptionpresence G_8_g_1_ns_xml_path && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_8_g && return ${PARSER_ERROR}
			
			nsxmlPath="${parser_item}"
			
			;;
		ns-xml-path-relative)
			! parse_setoptionpresence G_8_g_2_ns_xml_path_relative && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_8_g && return ${PARSER_ERROR}
			
			if ${parser_optionhastail} && [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Option --${parser_option} does not allow an argument"
				parser_optiontail=''
				return ${PARSER_ERROR}
			fi
			nsxmlPathRelative=true
			
			;;
		*)
			parse_addfatalerror "Unknown option \"${parser_option}\""
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
		's')
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item=${parser_optiontail}
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = '--' ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=''
			parser_optionhastail=false
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
			
			! parse_setoptionpresence G_1_shell && return ${PARSER_ERROR}
			
			xmlShellFileDescriptionPath="${parser_item}"
			
			;;
		'x')
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item=${parser_optiontail}
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = '--' ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=''
			parser_optionhastail=false
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
			
			! parse_setoptionpresence G_2_xml_description && return ${PARSER_ERROR}
			
			xmlProgramDescriptionPath="${parser_item}"
			
			;;
		'S')
			! parse_setoptionpresence G_3_skip_validation && return ${PARSER_ERROR}
			
			skipValidation=true
			
			;;
		'p')
			! parse_setoptionpresence G_6_prefix_sc_variables && return ${PARSER_ERROR}
			
			prefixSubcommandBoundVariableName=true
			
			;;
		'o')
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item=${parser_optiontail}
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = '--' ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=''
			parser_optionhastail=false
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			! parse_setoptionpresence G_7_output && return ${PARSER_ERROR}
			
			outputScriptFilePath="${parser_item}"
			
			;;
		'i')
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item=${parser_optiontail}
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = '--' ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=''
			parser_optionhastail=false
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			! parse_setoptionpresence G_4_g_1_interpreter && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_4_g && return ${PARSER_ERROR}
			
			defaultInterpreterType="${parser_item}"
			defaultInterpreter='defaultInterpreterType'
			
			;;
		'I')
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item=${parser_optiontail}
			else
				parser_index=$(expr ${parser_index} + 1)
				if [ ${parser_index} -ge ${parser_itemcount} ]
				then
					parse_adderror "End of input reached - Argument expected"
					return ${PARSER_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
				if [ "${parser_item}" = '--' ]
				then
					parse_adderror "End of option marker found - Argument expected"
					parser_index=$(expr ${parser_index} - 1)
					return ${PARSER_ERROR}
				fi
			fi
			
			parser_subindex=0
			parser_optiontail=''
			parser_optionhastail=false
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			! parse_setoptionpresence G_4_g_2_interpreter_cmd && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_4_g && return ${PARSER_ERROR}
			
			defaultInterpreterCommand="${parser_item}"
			defaultInterpreter='defaultInterpreterCommand'
			
			;;
		*)
			parse_addfatalerror "Unknown option \"${parser_option}\""
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
	parser_aborted=false
	parser_isfirstpositionalargument=true
	while [ ${parser_index} -lt ${parser_itemcount} ] && ! ${parser_aborted}
	do
		parse_process_option
		if [ -z "${parser_optiontail}" ]
		then
			parser_index=$(expr ${parser_index} + 1)
			parser_subindex=0
		else
			parser_subindex=$(expr ${parser_subindex} + 1)
		fi
	done
	
	if ! ${parser_aborted}
	then
		parse_setdefaultoptions
		parse_checkrequired
		parse_checkminmax
	fi
	
	
	[ "${defaultInterpreter:0:1}" = '@' ] && defaultInterpreter=''
	[ "${defaultInterpreter:0:1}" = '~' ] && defaultInterpreter=''
	[ "${parser_option_G_8_g:0:1}" = '@' ] && parser_option_G_8_g=''
	parser_option_G_8_g=''
	
	
	
	local parser_errorcount=${#parser_errors[*]}
	return ${parser_errorcount}
}

ns_print_colored_message()
{
	local _ns_message_color=
	if [ $# -gt 0 ]
	then
		_ns_message_color="${1}"
		shift
	else
		_ns_message_color="${NSXML_ERROR_COLOR}"
	fi
	local shell="$(readlink /proc/$$/exe | sed "s/.*\/\([a-z]*\)[0-9]*/\1/g")"
	local useColor=false
	for s in bash zsh ash
	do
		if [ "${shell}" = "${s}" ]
		then
			useColor=true
			break
		fi
	done
	[ ! -z "${NO_COLOR}" ] && [ "${NO_COLOR}" != '0' ] && useColor=false
	[ ! -z "${NO_ANSI}" ] && [ "${NO_ANSI}" != '0' ] && useColor=false
	if ${useColor} 
	then
		[ -z "${_ns_message_color}" ] && _ns_message_color="31" 
		echo -e "\e[${_ns_message_color}m${@}\e[0m" 
	else
		echo "${@}"
	fi
	return 0
}
ns_print_error()
{
	ns_print_colored_message "${NSXML_ERROR_COLOR}" "${@}" 1>&2
}
ns_error()
{
	local errno=
	if [ $# -gt 0 ]
	then
		errno=${1}
		shift
	else
		errno=1
	fi
	local message="${@}"
	if [ -z "${errno##*[!0-9]*}" ]
	then
		message="${errno} ${message}"
		errno=1
	fi
	ns_print_error "${message}"
	exit ${errno}
}
ns_warn()
{
	local _ns_warn_color="${NSXML_WARNING_COLOR}"
	[ -z "${_ns_warn_color}" ] && _ns_warn_color=33
			ns_print_colored_message "${_ns_warn_color}" "${@}" 1>&2; return 0
}
nsxml_installpath()
{
	local subpath="share/ns"
	for prefix in \
		"${@}" \
		"${NSXML_PATH}" \
		"${HOME}/.local/${subpath}" \
		"${HOME}/${subpath}" \
		/usr/${subpath} \
		/usr/loca/${subpath}l \
		/opt/${subpath} \
		/opt/local/${subpath}
	do
		if [ ! -z "${prefix}" ] \
			&& [ -d "${prefix}" ] \
			&& [ -r "${prefix}/ns-xml.plist" ]
		then
			echo -n "${prefix}"
			return 0
		fi
	done
	
	ns_print_error "nsxml_installpath: Path not found"
	return 1
}
ns_realpath()
{
	local __ns_realpath_in=
	if [ $# -gt 0 ]
	then
		__ns_realpath_in="${1}"
		shift
	fi
	local __ns_realpath_rl=
	local __ns_realpath_cwd="$(pwd)"
	[ -d "${__ns_realpath_in}" ] && cd "${__ns_realpath_in}" && __ns_realpath_in="."
	while [ -h "${__ns_realpath_in}" ]
	do
		__ns_realpath_rl="$(readlink "${__ns_realpath_in}")"
		if [ "${__ns_realpath_rl#/}" = "${__ns_realpath_rl}" ]
		then
			__ns_realpath_in="$(dirname "${__ns_realpath_in}")/${__ns_realpath_rl}"
		else
			__ns_realpath_in="${__ns_realpath_rl}"
		fi
	done
	
	if [ -d "${__ns_realpath_in}" ]
	then
		__ns_realpath_in="$(cd -P "$(dirname "${__ns_realpath_in}")" && pwd)"
	else
		__ns_realpath_in="$(cd -P "$(dirname "${__ns_realpath_in}")" && pwd)/$(basename "${__ns_realpath_in}")"
	fi
	
	cd "${__ns_realpath_cwd}" 1>/dev/null 2>&1
	echo "${__ns_realpath_in}"
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
	local file=
	if [ $# -gt 0 ]
	then
		file="${1}"
		shift
	fi
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
	local schema=
	if [ $# -gt 0 ]
	then
		schema="${1}"
		shift
	fi
	local xml=
	if [ $# -gt 0 ]
	then
		xml="${1}"
		shift
	fi
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
# Global variables
scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
nsPath="$(ns_realpath "$(nsxml_installpath "${scriptPath}/..")")"
programSchemaVersion="2.0"
 
# Check required programs
for x in xmllint xsltproc egrep cut expr head tail
do
	if ! which $x 1>/dev/null 2>&1
	then
		echo "${x} program not found"
		exit 1
	fi
done

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

chunk_check_nsxml_ns_path || error 1 "Invalid ns-xml ns folder (${nsPath})"

# Validate XML program description (if given)
if [ -f "${xmlProgramDescriptionPath}" ]
then
	# Finding schema version
	programSchemaVersion="$(xsltproc \
		--xinclude \
		--stringparam namespacePrefix 'http://xsd.nore.fr/program'  \
		--stringparam defaultVersion 2.0 \
		"${nsPath}/xsl/schema-version.xsl" \
		"${xmlProgramDescriptionPath}"
	)"
	#echo "Program schema version ${programSchemaVersion}"
	
	if [ ! -f "${nsPath}/xsd/program/${programSchemaVersion}/program.xsd" ]
	then
		echo "Invalid program interface definition schema version"
		exit 3
	fi

	if ! ${skipValidation} && ! xml_validate "${nsPath}/xsd/program/${programSchemaVersion}/program.xsd" "${xmlProgramDescriptionPath}"
	then
		echo "program interface definition schema error - abort"
		exit 4
	fi
fi


# Process xsh file
xsltprocArgs=(--xinclude)
for option in maxdepth maxvars maxparserdepth
do
	variable=NSXML_XSLTPROC_$(tr '[a-z]' '[A-Z]' <<< "${option}")
	[ -z "${!variable}" ] && continue
	xsltprocArgs=("${xsltprocArgs[@]}" --${option} "${!variable}")
done

# Check required XSLT files
xshXslTemplatePath="${nsPath}/xsl/program/${programSchemaVersion}/xsh.xsl"
if [ ! -f "${xshXslTemplatePath}" ]
then
    echo "Missing XSLT stylesheet file \"${xshXslTemplatePath}\""
    exit 2
fi

# Validate against bash or xsh schema
if ! ${skipValidation}
then
	shSchema="$(xsltproc --xinclude "${nsPath}/xsl/program/${programSchemaVersion}/xsh-getschemapath.xsl" "${xmlShellFileDescriptionPath}")"
	if ! xml_validate "${nsPath}/xsd/${shSchema}" "${xmlShellFileDescriptionPath}" 
	then
		echo "bash schema error - abort"
		exit 5
	fi
fi

if ${debugTrace}
then
	xsltprocArgs[${#xsltprocArgs[*]}]="--param"
	xsltprocArgs[${#xsltprocArgs[*]}]="prg.debug"
	xsltprocArgs[${#xsltprocArgs[*]}]="true()"
fi

if ${prefixSubcommandBoundVariableName}
then
	xsltprocArgs[${#xsltprocArgs[*]}]="--stringparam"
	xsltprocArgs[${#xsltprocArgs[*]}]="prg.sh.parser.prefixSubcommandOptionVariable"
	xsltprocArgs[${#xsltprocArgs[*]}]="yes"
fi

if ${debugComments}
then
	xsltprocArgs[${#xsltprocArgs[*]}]="--stringparam"
	xsltprocArgs[${#xsltprocArgs[*]}]="prg.sh.parser.debug.comments"
	xsltprocArgs[${#xsltprocArgs[*]}]="yes"
fi

if [ ! -z "${defaultInterpreterCommand}" ]
then
	# See ns/xsl/program/*/xsh.xsl
	xsltprocArgs[${#xsltprocArgs[*]}]="--stringparam"
	xsltprocArgs[${#xsltprocArgs[*]}]="xsh.defaultInterpreterCommand"
	xsltprocArgs[${#xsltprocArgs[*]}]="${defaultInterpreterCommand}"
elif [ ! -z "${defaultInterpreterType}" ]
then
	# See ns/xsl/languages/xsh.xsl
	xsltprocArgs[${#xsltprocArgs[*]}]="--stringparam"
	xsltprocArgs[${#xsltprocArgs[*]}]="xsh.defaultInterpreterType"
	xsltprocArgs[${#xsltprocArgs[*]}]="${defaultInterpreterType}"
fi

if ${forceInterpreter} && ([ ! -z "${defaultInterpreterCommand}" ] || [ ! -z "${defaultInterpreterType}" ])
then
	xsltprocArgs[${#xsltprocArgs[*]}]="--stringparam"
	xsltprocArgs[${#xsltprocArgs[*]}]="xsh.forceInterpreter"
	xsltprocArgs[${#xsltprocArgs[*]}]="yes"
fi 

if ! xsltproc "${xsltprocArgs[@]}" -o "${outputScriptFilePath}" "${xshXslTemplatePath}" "${xmlShellFileDescriptionPath}"
then
	echo "Fail to process xsh file \"${xmlShellFileDescriptionPath}\""
	exit 6
fi

chmod 755 "${outputScriptFilePath}"

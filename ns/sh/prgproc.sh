#!/usr/bin/env bash
# ####################################
# Copyright © 2012 by Renaud GUillard (dev@nore.fr)
# Distributed under the terms of the MIT License, see LICENSE
# Author: renaud
# Version: 1.0
# 
# Process a program interface XML definition with one of the available XSLT stylesheets
#
# Program help
usage()
{
cat << 'EOFUSAGE'
prgproc: Process a program interface XML definition with one of the available XSLT stylesheets
Usage: 
  prgproc [-x <path>] -t <...> [-o <path>] [-p <...  [ ... ]>] [-s <...  [ ... ]>] [--ns-xml-path <path> --ns-xml-path-relative] [--help]
  Options:
    -x, --xml-description: Program description file
      If the program description file is provided, the xml file will be 
      validated before any XSLT processing
    -t, --xslt, --xsl: XSL transformation to apply  
      The argument have to be one of the following:  
        bashcompletion, c-gengetopt, docbook-usage or wikicreole-usage
    -o, --output: Output file
      If no output file is provided, the transformation result will be sent to 
      the standard output.
    -p, --param, --params: pass a (parameter,value) pair  
      Minimal argument count: 2
    -s, --stringparam, --stringparams: pass a (parameter, UTF8 string value) pair  
      Minimal argument count: 2
    ns-xml source path options
      --ns-xml-path: ns-xml source path
        Location of the ns folder of ns-xml package
      --ns-xml-path-relative: ns source path is relative this program path
    
    --help: Display program usage
  This tool automatically select the good version of the XSLT stylesheet 
  according to the @version attribute of the given XML file.
EOFUSAGE
}

# Program parameter parsing
parser_program_author="renaud"
parser_program_version="1.0"
parser_shell="$(readlink /proc/$$/exe | sed "s/.*\/\([a-z]*\)[0-9]*/\1/g")"
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
parser_required[$(expr ${#parser_required[*]} + ${parser_startindex})]="G_2_xslt:--xslt:"

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
	local c=${#parser_errors[*]}
	c=$(expr ${c} + ${parser_startindex})
	parser_errors[${c}]="${m}"
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
		return
	else
		parser_present[$(expr ${#parser_present[*]} + ${parser_startindex})]="${1}"
		case "${1}" in
		G_6_g)
			;;
		
		esac
	fi
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
	# First round: set default values
	local o=
	for o in "${parser_required[@]}"
	do
		local todoPart="$(echo "${o}" | cut -f 3 -d":")"
		[ -z "${todoPart}" ] || eval "${todoPart}"
	done
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
parse_setdefaultarguments()
{
	local parser_set_default=false
}
parse_checkminmax()
{
	local errorCount=0
	# Check min argument for multiargument
	if [ ${#parameters[*]} -gt 0 ] && [ ${#parameters[*]} -lt 2 ]
	then
		parser_errors[$(expr ${#parser_errors[*]} + ${parser_startindex})]="Invalid argument count for option \"--param\". At least 2 expected, ${#parameters[*]} given"
		errorCount=$(expr ${errorCount} + 1)
	fi
	if [ ${#stringParameters[*]} -gt 0 ] && [ ${#stringParameters[*]} -lt 2 ]
	then
		parser_errors[$(expr ${#parser_errors[*]} + ${parser_startindex})]="Invalid argument count for option \"--stringparam\". At least 2 expected, ${#stringParameters[*]} given"
		errorCount=$(expr ${errorCount} + 1)
	fi
	
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
			
			xmlProgramDescriptionPath="${parser_item}"
			parse_setoptionpresence G_1_xml_description
			;;
		xslt | xsl)
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
			if ! ([ "${parser_item}" = 'bashcompletion' ] || [ "${parser_item}" = 'c-gengetopt' ] || [ "${parser_item}" = 'docbook-usage' ] || [ "${parser_item}" = 'wikicreole-usage' ])
			then
				parse_adderror "Invalid value for option \"${parser_option}\""
				
				return ${PARSER_ERROR}
			fi
			xslName="${parser_item}"
			parse_setoptionpresence G_2_xslt
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
			parser_item=''
			${parser_optionhastail} && parser_item=${parser_optiontail}
			
			parser_subindex=0
			parser_optiontail=''
			parser_optionhastail=false
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			local parser_ma_local_count=0
			local parser_ma_total_count=${#parameters[*]}
			if [ ! -z "${parser_item}" ]
			then
				parameters[$(expr ${#parameters[*]} + ${parser_startindex})]="${parser_item}"
				parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
				parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
			fi
			
			local parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
			while [ ! -z "${parser_nextitem}" ] && [ "${parser_nextitem}" != '--' ] && [ ${parser_index} -lt ${parser_itemcount} ]
			do
				if [ ${parser_ma_local_count} -gt 0 ] && [ "${parser_nextitem:0:1}" = "-" ]
				then
					break
				fi
				
				parser_index=$(expr ${parser_index} + 1)
				parser_item="${parser_input[${parser_index}]}"
				[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
				parameters[$(expr ${#parameters[*]} + ${parser_startindex})]="${parser_item}"
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
			parser_item=''
			${parser_optionhastail} && parser_item=${parser_optiontail}
			
			parser_subindex=0
			parser_optiontail=''
			parser_optionhastail=false
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			local parser_ma_local_count=0
			local parser_ma_total_count=${#stringParameters[*]}
			if [ ! -z "${parser_item}" ]
			then
				stringParameters[$(expr ${#stringParameters[*]} + ${parser_startindex})]="${parser_item}"
				parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
				parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
			fi
			
			local parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
			while [ ! -z "${parser_nextitem}" ] && [ "${parser_nextitem}" != '--' ] && [ ${parser_index} -lt ${parser_itemcount} ]
			do
				if [ ${parser_ma_local_count} -gt 0 ] && [ "${parser_nextitem:0:1}" = "-" ]
				then
					break
				fi
				
				parser_index=$(expr ${parser_index} + 1)
				parser_item="${parser_input[${parser_index}]}"
				[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
				stringParameters[$(expr ${#stringParameters[*]} + ${parser_startindex})]="${parser_item}"
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
			if ${parser_optionhastail} && [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Option --${parser_option} does not allow an argument"
				parser_optiontail=''
				return ${PARSER_ERROR}
			fi
			displayHelp=true
			parse_setoptionpresence G_7_help
			;;
		ns-xml-path)
			# Group checks
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
			nsxmlPath="${parser_item}"
			parse_setoptionpresence G_6_g_1_ns_xml_path;parse_setoptionpresence G_6_g
			;;
		ns-xml-path-relative)
			# Group checks
			if ${parser_optionhastail} && [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Option --${parser_option} does not allow an argument"
				parser_optiontail=''
				return ${PARSER_ERROR}
			fi
			nsxmlPathRelative=true
			parse_setoptionpresence G_6_g_2_ns_xml_path_relative;parse_setoptionpresence G_6_g
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
		x)
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
			
			xmlProgramDescriptionPath="${parser_item}"
			parse_setoptionpresence G_1_xml_description
			;;
		t)
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
			if ! ([ "${parser_item}" = 'bashcompletion' ] || [ "${parser_item}" = 'c-gengetopt' ] || [ "${parser_item}" = 'docbook-usage' ] || [ "${parser_item}" = 'wikicreole-usage' ])
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
			parser_item=''
			${parser_optionhastail} && parser_item=${parser_optiontail}
			
			parser_subindex=0
			parser_optiontail=''
			parser_optionhastail=false
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			local parser_ma_local_count=0
			local parser_ma_total_count=${#parameters[*]}
			if [ ! -z "${parser_item}" ]
			then
				parameters[$(expr ${#parameters[*]} + ${parser_startindex})]="${parser_item}"
				parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
				parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
			fi
			
			local parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
			while [ ! -z "${parser_nextitem}" ] && [ "${parser_nextitem}" != '--' ] && [ ${parser_index} -lt ${parser_itemcount} ]
			do
				if [ ${parser_ma_local_count} -gt 0 ] && [ "${parser_nextitem:0:1}" = "-" ]
				then
					break
				fi
				
				parser_index=$(expr ${parser_index} + 1)
				parser_item="${parser_input[${parser_index}]}"
				[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
				parameters[$(expr ${#parameters[*]} + ${parser_startindex})]="${parser_item}"
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
			parser_item=''
			${parser_optionhastail} && parser_item=${parser_optiontail}
			
			parser_subindex=0
			parser_optiontail=''
			parser_optionhastail=false
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			local parser_ma_local_count=0
			local parser_ma_total_count=${#stringParameters[*]}
			if [ ! -z "${parser_item}" ]
			then
				stringParameters[$(expr ${#stringParameters[*]} + ${parser_startindex})]="${parser_item}"
				parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
				parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
			fi
			
			local parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
			while [ ! -z "${parser_nextitem}" ] && [ "${parser_nextitem}" != '--' ] && [ ${parser_index} -lt ${parser_itemcount} ]
			do
				if [ ${parser_ma_local_count} -gt 0 ] && [ "${parser_nextitem:0:1}" = "-" ]
				then
					break
				fi
				
				parser_index=$(expr ${parser_index} + 1)
				parser_item="${parser_input[${parser_index}]}"
				[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
				stringParameters[$(expr ${#stringParameters[*]} + ${parser_startindex})]="${parser_item}"
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
		if [ -z ${parser_optiontail} ]
		then
			parser_index=$(expr ${parser_index} + 1)
			parser_subindex=0
		else
			parser_subindex=$(expr ${parser_subindex} + 1)
		fi
	done
	
	if ! ${parser_aborted}
	then
		parse_setdefaultarguments
		parse_checkrequired
		parse_checkminmax
	fi
	
	
	
	local parser_errorcount=${#parser_errors[*]}
	return ${parser_errorcount}
}

ns_print_error()
{
	local shell="$(readlink /proc/$$/exe | sed "s/.*\/\([a-z]*\)[0-9]*/\1/g")"
	local errorColor="${NSXML_ERROR_COLOR}"
	local useColor=false
	for s in bash zsh ash
	do
		if [ "${shell}" = "${s}" ]
		then
			useColor=true
			break
		fi
	done
	if ${useColor} 
	then
		[ -z "${errorColor}" ] && errorColor="31" 
		echo -e "\e[${errorColor}m${@}\e[0m"  1>&2
	else
		echo "${@}" 1>&2
	fi
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
scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
nsPath="$(ns_realpath "$(nsxml_installpath "${scriptPath}/..")")"
programSchemaVersion="2.0"

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

chunk_check_nsxml_ns_path || ns_error "Invalid ns-xml ns folder (${nsPath})"
programSchemaVersion="$(get_program_version "${xmlProgramDescriptionPath}")"

xslFile="${nsPath}/xsl/program/${programSchemaVersion}/${xslName}.xsl"

[ -f "${xslFile}" ] || ns_error 2 "Unable to find \"${xslFile}\""

xsltprocCommand[${parser_startindex}]="xsltproc"
xsltprocCommand[${#xsltprocCommand[*]}]="--xinclude"
if [ ! -z "${output}" ]
then
	xsltprocCommand[${#xsltprocCommand[*]}]="--output"
	xsltprocCommand[${#xsltprocCommand[*]}]="${output}"
fi

count=${#stringParameters[*]}
mc=$(expr ${count} % 2)
[ ${mc} -eq 1 ] && ns_error 2 "Invalid number of arguments for --stringparam. Even value expected, got ${count}"
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
[ ${mc} -eq 1 ] && ns_error 2 "Invalid number of arguments for --stringparam. Even value expected, got ${count}"
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

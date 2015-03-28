#!/usr/bin/env bash
# ####################################
# Copyright © 2012 by renaud
# Author: renaud
# Version: 1.0
# 
# Run ns-xml unittests
#
# Program help
usage()
{
if [ ! -z "${1}" ]
then
case "${1}" in
xsh)
cat << EOFSCUSAGE
xsh: XSH function library tests
Usage: run-tests xsh
EOFSCUSAGE
;;
parsers)
cat << EOFSCUSAGE
parsers: Parsers tests
Usage: run-tests parsers [-T] [-p <...  [ ... ]>] [-a <...  [ ... ]>] [-t <...  [ ... ]>]
With:
  -p, --parsers: Parser to test  
    The argument have to be one of the following:  
      c, php, python or sh
  -a, --apps: Test groups to run
  -t, --tests: Test id(s) to run
  -T, --temp: Keep temporary files
    Don't remove temporary files even if test passed
EOFSCUSAGE
;;

esac
return 0
fi
cat << 'EOFUSAGE'
run-tests: Run ns-xml unittests
Usage: 
  run-tests <subcommand [subcommand option(s)]> [--help]
  With subcommand:
    xsh: XSH function library tests
    parsers: Parsers tests
      options: [-T] [-p <...  [ ... ]>] [-a <...  [ ... ]>] [-t <...  [ ... ]>]
  With global options:
    --help: Display program usage
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
parsers_keepTemporaryFiles=false
displayHelp=false

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
	case "${parser_subcommand}" in
	xsh)
		;;
	parsers)
		;;
	
	esac
}
parse_checkminmax()
{
	local errorCount=0
	# Check min argument for multiargument
	
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
		xsh)
			${parser_isfirstpositionalargument} && parser_errors[$(expr ${#parser_errors[*]} + ${parser_startindex})]='Subcommand xsh does not accept positional arguments'
			
			parser_isfirstpositionalargument=false
			return ${PARSER_ERROR}
			;;
		parsers)
			${parser_isfirstpositionalargument} && parser_errors[$(expr ${#parser_errors[*]} + ${parser_startindex})]='Subcommand parsers does not accept positional arguments'
			
			parser_isfirstpositionalargument=false
			return ${PARSER_ERROR}
			;;
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
	
	case "${parser_subcommand}" in
	parsers)
		if [ "${parser_item:0:2}" = '--' ] 
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
			parsers)
				parser_item=''
				${parser_optionhastail} && parser_item=${parser_optiontail}
				
				parser_subindex=0
				parser_optiontail=''
				parser_optionhastail=false
				[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
				local parser_ma_local_count=0
				local parser_ma_total_count=${#parsers_parsers[*]}
				if [ ! -z "${parser_item}" ]
				then
					if ! ([ "${parser_item}" = 'c' ] || [ "${parser_item}" = 'php' ] || [ "${parser_item}" = 'python' ] || [ "${parser_item}" = 'sh' ])
					then
						parse_adderror "Invalid value for option \"${parser_option}\""
						
						return ${PARSER_SC_ERROR}
					fi
					parsers_parsers[$(expr ${#parsers_parsers[*]} + ${parser_startindex})]="${parser_item}"
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
					if ! ([ "${parser_item}" = 'c' ] || [ "${parser_item}" = 'php' ] || [ "${parser_item}" = 'python' ] || [ "${parser_item}" = 'sh' ])
					then
						parse_adderror "Invalid value for option \"${parser_option}\""
						
						return ${PARSER_SC_ERROR}
					fi
					parsers_parsers[$(expr ${#parsers_parsers[*]} + ${parser_startindex})]="${parser_item}"
					parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
					parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
					parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
				done
				if [ ${parser_ma_local_count} -eq 0 ]
				then
					parse_adderror "At least one argument expected for option \"${parser_option}\""
					return ${PARSER_SC_ERROR}
				fi
				
				parse_setoptionpresence SC_2_parsers_1_parsers
				;;
			apps)
				parser_item=''
				${parser_optionhastail} && parser_item=${parser_optiontail}
				
				parser_subindex=0
				parser_optiontail=''
				parser_optionhastail=false
				[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
				local parser_ma_local_count=0
				local parser_ma_total_count=${#parsers_apps[*]}
				if [ ! -z "${parser_item}" ]
				then
					parsers_apps[$(expr ${#parsers_apps[*]} + ${parser_startindex})]="${parser_item}"
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
					parsers_apps[$(expr ${#parsers_apps[*]} + ${parser_startindex})]="${parser_item}"
					parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
					parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
					parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
				done
				if [ ${parser_ma_local_count} -eq 0 ]
				then
					parse_adderror "At least one argument expected for option \"${parser_option}\""
					return ${PARSER_SC_ERROR}
				fi
				
				parse_setoptionpresence SC_2_parsers_2_apps
				;;
			tests)
				parser_item=''
				${parser_optionhastail} && parser_item=${parser_optiontail}
				
				parser_subindex=0
				parser_optiontail=''
				parser_optionhastail=false
				[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
				local parser_ma_local_count=0
				local parser_ma_total_count=${#parsers_tests[*]}
				if [ ! -z "${parser_item}" ]
				then
					parsers_tests[$(expr ${#parsers_tests[*]} + ${parser_startindex})]="${parser_item}"
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
					parsers_tests[$(expr ${#parsers_tests[*]} + ${parser_startindex})]="${parser_item}"
					parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
					parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
					parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
				done
				if [ ${parser_ma_local_count} -eq 0 ]
				then
					parse_adderror "At least one argument expected for option \"${parser_option}\""
					return ${PARSER_SC_ERROR}
				fi
				
				parse_setoptionpresence SC_2_parsers_3_tests
				;;
			temp)
				if ${parser_optionhastail} && [ ! -z "${parser_optiontail}" ]
				then
					parse_adderror "Option --${parser_option} does not allow an argument"
					parser_optiontail=''
					return ${PARSER_SC_ERROR}
				fi
				parsers_keepTemporaryFiles=true
				parse_setoptionpresence SC_2_parsers_4_temp
				;;
			*)
				return ${PARSER_SC_SKIP}
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
			p)
				parser_item=''
				${parser_optionhastail} && parser_item=${parser_optiontail}
				
				parser_subindex=0
				parser_optiontail=''
				parser_optionhastail=false
				[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
				local parser_ma_local_count=0
				local parser_ma_total_count=${#parsers_parsers[*]}
				if [ ! -z "${parser_item}" ]
				then
					if ! ([ "${parser_item}" = 'c' ] || [ "${parser_item}" = 'php' ] || [ "${parser_item}" = 'python' ] || [ "${parser_item}" = 'sh' ])
					then
						parse_adderror "Invalid value for option \"${parser_option}\""
						
						return ${PARSER_SC_ERROR}
					fi
					parsers_parsers[$(expr ${#parsers_parsers[*]} + ${parser_startindex})]="${parser_item}"
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
					if ! ([ "${parser_item}" = 'c' ] || [ "${parser_item}" = 'php' ] || [ "${parser_item}" = 'python' ] || [ "${parser_item}" = 'sh' ])
					then
						parse_adderror "Invalid value for option \"${parser_option}\""
						
						return ${PARSER_SC_ERROR}
					fi
					parsers_parsers[$(expr ${#parsers_parsers[*]} + ${parser_startindex})]="${parser_item}"
					parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
					parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
					parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
				done
				if [ ${parser_ma_local_count} -eq 0 ]
				then
					parse_adderror "At least one argument expected for option \"${parser_option}\""
					return ${PARSER_SC_ERROR}
				fi
				
				parse_setoptionpresence SC_2_parsers_1_parsers
				;;
			a)
				parser_item=''
				${parser_optionhastail} && parser_item=${parser_optiontail}
				
				parser_subindex=0
				parser_optiontail=''
				parser_optionhastail=false
				[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
				local parser_ma_local_count=0
				local parser_ma_total_count=${#parsers_apps[*]}
				if [ ! -z "${parser_item}" ]
				then
					parsers_apps[$(expr ${#parsers_apps[*]} + ${parser_startindex})]="${parser_item}"
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
					parsers_apps[$(expr ${#parsers_apps[*]} + ${parser_startindex})]="${parser_item}"
					parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
					parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
					parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
				done
				if [ ${parser_ma_local_count} -eq 0 ]
				then
					parse_adderror "At least one argument expected for option \"${parser_option}\""
					return ${PARSER_SC_ERROR}
				fi
				
				parse_setoptionpresence SC_2_parsers_2_apps
				;;
			t)
				parser_item=''
				${parser_optionhastail} && parser_item=${parser_optiontail}
				
				parser_subindex=0
				parser_optiontail=''
				parser_optionhastail=false
				[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
				local parser_ma_local_count=0
				local parser_ma_total_count=${#parsers_tests[*]}
				if [ ! -z "${parser_item}" ]
				then
					parsers_tests[$(expr ${#parsers_tests[*]} + ${parser_startindex})]="${parser_item}"
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
					parsers_tests[$(expr ${#parsers_tests[*]} + ${parser_startindex})]="${parser_item}"
					parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
					parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
					parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
				done
				if [ ${parser_ma_local_count} -eq 0 ]
				then
					parse_adderror "At least one argument expected for option \"${parser_option}\""
					return ${PARSER_SC_ERROR}
				fi
				
				parse_setoptionpresence SC_2_parsers_3_tests
				;;
			T)
				parsers_keepTemporaryFiles=true
				parse_setoptionpresence SC_2_parsers_4_temp
				;;
			*)
				return ${PARSER_SC_SKIP}
				;;
			
			esac
		fi
		;;
	*)
		return ${PARSER_SC_SKIP}
		;;
	
	esac
	return ${PARSER_SC_OK}
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
		help)
			if ${parser_optionhastail} && [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Option --${parser_option} does not allow an argument"
				parser_optiontail=''
				return ${PARSER_ERROR}
			fi
			displayHelp=true
			parse_setoptionpresence G_1_help
			;;
		*)
			parse_addfatalerror "Unknown option \"${parser_option}\""
			return ${PARSER_ERROR}
			;;
		
		esac
	elif ${parser_subcommand_expected} && [ -z "${parser_subcommand}" ] && [ ${#parser_values[*]} -eq 0 ]
	then
		case "${parser_item}" in
		xsh)
			parser_subcommand="xsh"
			
			;;
		parsers)
			parser_subcommand="parsers"
			
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
ns_isdir()
{
	local inputPath=
	if [ $# -gt 0 ]
	then
		inputPath="${1}"
		shift
	fi
	[ ! -z "${inputPath}" ] && [ -d "${inputPath}" ]
}
ns_issymlink()
{
	local inputPath=
	if [ $# -gt 0 ]
	then
		inputPath="${1}"
		shift
	fi
	[ ! -z "${inputPath}" ] && [ -L "${inputPath}" ]
}
ns_realpath()
{
	local inputPath=
	if [ $# -gt 0 ]
	then
		inputPath="${1}"
		shift
	fi
	local cwd="$(pwd)"
	[ -d "${inputPath}" ] && cd "${inputPath}" && inputPath="."
	while [ -h "${inputPath}" ] ; do inputPath="$(readlink "${inputPath}")"; done
	
	if [ -d "${inputPath}" ]
	then
		inputPath="$(cd -P "$(dirname "${inputPath}")" && pwd)"
	else
		inputPath="$(cd -P "$(dirname "${inputPath}")" && pwd)/$(basename "${inputPath}")"
	fi
	
	cd "${cwd}" 1>/dev/null 2>&1
	echo "${inputPath}"
}
ns_relativepath()
{
	local from=
	if [ $# -gt 0 ]
	then
		from="${1}"
		shift
	fi
	local base=
	if [ $# -gt 0 ]
	then
		base="${1}"
		shift
	else
		base="."
	fi
	[ -r "${from}" ] || return 1
	[ -r "${base}" ] || return 2
	[ ! -d "${base}" ] && base="$(dirname "${base}")"  
	[ -d "${base}" ] || return 3
	from="$(ns_realpath "${from}")"
	base="$(ns_realpath "${base}")"
	#echo from: $from
	#echo base: $base
	c=0
	sub="${base}"
	newsub=""
	while [ "${from:0:${#sub}}" != "${sub}" ]
	do
		newsub="$(dirname "${sub}")"
		[ "${newsub}" == "${sub}" ] && return 4
		sub="${newsub}"
		c="$(expr ${c} + 1)"
	done
	res="."
	for ((i=0;${i}<${c};i++))
	do
		res="${res}/.."
	done
	res="${res}${from#${sub}}"
	res="${res#./}"
	echo "${res}"
}
ns_mktemp()
{
	local key=
	if [ $# -gt 0 ]
	then
		key="${1}"
		shift
	else
		key="$(date +%s)"
	fi
	if [ "$(uname -s)" == "Darwin" ]
	then
		#Use key as a prefix
		mktemp -t "${key}"
	else
		#Use key as a suffix
		mktemp --suffix "${key}"
	fi
}
ns_mktempdir()
{
	local key=
	if [ $# -gt 0 ]
	then
		key="${1}"
		shift
	else
		key="$(date +%s)"
	fi
	if [ "$(uname -s)" == "Darwin" ]
	then
		#Use key as a prefix
		mktemp -d -t "${key}"
	else
		#Use key as a suffix
		mktemp -d --suffix "${key}"
	fi
}
ns_which()
{
	local result=1
	if [ "$(uname -s)" = 'Darwin' ]
	then
		which "${@}" && result=0
	else
	local silent="false"
	local args=
	while [ ${#} -gt 0 ]
		do
			if [ "${1}" = '-s' ]
			then 
				silent=true
			else
				[ -z "${args}" ] \
					&& args="${1}" \
					|| args=("${args[@]}" "${1}")
			fi
			shift
		done
		
		if ${silent}
		then
			which "${args[@]}" 1>/dev/null 2>&1 && result=0
		else
			which "${args[@]}" && result=0
		fi
	fi
	return ${result}
}
scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
scriptName="$(basename "${scriptFilePath}")"
rootPath="$(ns_realpath "${scriptPath}/../..")"
cwd="$(pwd)"

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


projectPath="$(ns_realpath "${scriptPath}/../..")"
logFile="${projectPath}/${scriptName}.log"
rm -f "${logFile}"

#http://stackoverflow.com/questions/4332478/read-the-current-text-color-in-a-xterm/4332530#4332530
NORMAL_COLOR="$(tput sgr0)"
ERROR_COLOR="$(tput setaf 1)"
SUCCESS_COLOR="$(tput setaf 2)"

log()
{
	echo "${@}" >> "${logFile}"
}

check_zsh()
{
	zshVersion="$(zsh --version | cut -f 2 -d" ")"
	zshM="$(echo "${zshVersion}" | cut -f 1 -d.)"
	zshm="$(echo "${zshVersion}" | cut -f 2 -d.)"
	zshp="$(echo "${zshVersion}" | cut -f 3 -d.)"
	[ ${zshM} -lt 4 ] && return 1;
	[ ${zshM} -eq 4 ] && [ ${zshm} -lt 3 ] && return 1;
	[ ${zshM} -eq 4 ] && [ ${zshm} -eq 3 ] && [ ${zshp} -lt 13 ] && return 1;
	
	return 0
}

if [ "${parser_subcommand}" = 'parsers' ]
then
	parsers=("${parsers_parsers[@]}")
	apps=("${parsers_apps[@]}")
	tests=("${parsers_tests[@]}")
	keepTemporaryFiles=${parsers_keepTemporaryFiles}
		
	parserTestsPathBase="${projectPath}/unittests/parsers"
	tmpShellStylesheet="$(ns_mktemp "shell-xsl")"
	programSchemaVersion="2.0"
	xshStylesheet="${projectPath}/ns/xsl/program/${programSchemaVersion}/xsh.xsl"
	
	# Supported Python interpreters
	# Assumes all are installed in the same directory
	pythonPath=""
	if which python 1>/dev/null 2>&1
	then
		pythonPath="$(dirname "$(which python)")"
	else
		for major in 2 3
		do
			for minor in 0 1 2 3 4 5 6 7 8 9
			do
				if which python${major}.${minor} 1>/dev/null 2>&1
				then
					pythonPath="$(dirname "$(which python${major}.${minor})")"
					break
				fi
			done
			[ ! -z "${pythonPath}" ] && break
		done
	fi
	
	echo ${pythonPath}
	if [ ! -z "${pythonPath}" ]
	then
		pythonInterpreterRegex="^python[0-9]+(\.[0-9]+)$"
		while read f
		do
			if [ -x "${f}" ] && echo "$(basename "${f}")" | egrep "${pythonInterpreterRegex}" 1>/dev/null 2>&1
			then
				pythonInterpreters[${#pythonInterpreters[@]}]="$(basename "${f}")"
			fi
		done << EOF
	$(find "${pythonPath}" -name "python*")
EOF
	fi
	
	# Supported shells
	shells=(bash zsh ksh)
	for s in ${shells[@]}
	do
		if which ${s} 1>/dev/null 2>&1
		then
			check_func="check_${s}"
			if [ "$(type -t "${check_func}")" != "function" ] || ${check_func}
			then
				available_shells[${#available_shells[@]}]=${s}
			fi
		fi
	done
	
	# C compilers
	if [ -z "${CC}" ] || ! which "${CC}" 1>/dev/null
	then
		for c in gcc clang
		do
			if which ${c} 1>/dev/null 2>&1
			then
				cc=${c}
				break
			fi
		done
	else
		cc=${CC}
	fi
	
	if [ -z "${CFLAGS}" ]
	then
		cflags="-Wall -pedantic -g -O0"
	else
		cflags="${CFLAGS}"
	fi
	
	# Test groups
	if [ ${#apps[@]} -eq 0 ]
	then
		while read d
		do
			selectedApps[${#selectedApps[@]}]="$(basename "${d}")"
		done << EOF
		$(find "${parserTestsPathBase}/apps" -mindepth 1 -maxdepth 1 -type d | sort)
EOF
	else
		for ((a=0;${a}<${#apps[@]};a++))
		do
			d="${parserTestsPathBase}/apps/${apps[${a}]}"
			if [ -d "${d}" ]
			then
				selectedApps[${#selectedApps[@]}]="$(basename "${d}")"
			fi
		done
	fi
	
	# Parsers to test
	testSh=false
	testPython=false
	testC=false
	testValgrind=false
	testPHP=false
	
	if [ ${#parsers[@]} -eq 0 ]
	then
		# Autodetect available parsers
		if [ ${#available_shells[@]} -gt 0 ]
		then
			parsers=("${parsers[@]}" sh)
			testSh=true
		fi
		
		if [ "${#pythonInterpreters[@]}" -gt 0 ]
		then
			parsers=("${parsers[@]}" python)
			testPython=true
		fi
		
		if which ${cc} 1>/dev/null 2>&1
		then
			parsers=("${parsers[@]}" c)
			testC=true
			if which valgrind 1>/dev/null 2>&1
			then
				testValgrind=true
			fi
		fi
		
		if which php 1>/dev/null 2>&1
		then
			parsers=("${parsers[@]}" php)
			testPHP=true
		fi
	else
		for ((i=0;${i}<${#parsers[@]};i++))
		do
			if [ "${parsers[${i}]}" = "sh" ] && [ ${#available_shells[@]} -gt 0 ]
			then
				testSh=true
			elif [ "${parsers[${i}]}" = "python" ] && [ ${#pythonInterpreters[@]} -gt 0 ]
			then
				testPython=true
			elif [ "${parsers[${i}]}" = "c" ] && which ${cc} 1>/dev/null 2>&1
			then
				testC=true
				if which valgrind 1>/dev/null 2>&1
				then
					testValgrind=true
				fi
			elif [ "${parsers[${i}]}" = "php" ] && which php 1>/dev/null 2>&1
			then
				testPHP=true
			fi
		done 
	fi
	
	resultLineFormat="%20.20s |"
	if ${testSh}
	then
		parserNames=("${parserNames[@]}" "${available_shells[@]}")
		
		for s in ${available_shells[@]}
		do
			resultLineFormat="${resultLineFormat} %-7s |"	
		done
	fi
	
	if ${testPython}
	then
		#parserNames=("${parserNames[@]}" "Python")	
		#resultLineFormat="${resultLineFormat} %-7s |"
		
		for p in "${pythonInterpreters[@]}"
		do
			pyVersion="$(echo "${p}" | sed -E "s,python(.*),\\1,g")"
			parserNames=("${parserNames[@]}" "py ${pyVersion}")
			resultLineFormat="${resultLineFormat} %-7s |"
		done
		
		log "Update Python parser XSLT" 
		"${scriptPath}/update-python-parser.sh"
	fi
	
	if ${testC}
	then
		parserNames=("${parserNames[@]}" "C/${cc}")
		if ${testValgrind}
		then
			parserNames=("${parserNames[@]}" "C/Valgrind")
		fi
			
		log "Update C parser XSLT "
		"${scriptPath}/update-c-parser.sh"
		resultLineFormat="${resultLineFormat} %-7s |"
		
		# Valgrind
		if ${testValgrind}
		then
			resultLineFormat="${resultLineFormat} %-10s |"
		
			testValgrind=true
			valgrindArgs=("--tool=memcheck" "--leak-check=full" "--undef-value-errors=yes" "--xml=yes")
			if [ "$(uname -s)" = "Darwin" ]
			then
				valgrindArgs=("${valgrindArgs[@]}" \
					"--dsymutil=yes" \
					"--suppressions=\"${rootPath}/resources/valgrind/Darwin.supp\""
					)
			fi
			
			valgrindOutputXslFile="$(ns_mktemp "valgrind-xsl")"
			cat > "${valgrindOutputXslFile}" << EOF
	<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	<output method="text" encoding="utf-8" />
	    <template match="/">
	    	<value-of select="count(//error)" />
	    </template>
	</stylesheet>
EOF
		fi
	fi
	
	if ${testPHP}
	then
		parserNames=("${parserNames[@]}" "PHP")
			
		log "Update PHP parser XSLT"
		"${scriptPath}/update-php-parser.sh"
		resultLineFormat="${resultLineFormat} %-7s |"
	fi
	
	# Result column
	resultLineFormat="${resultLineFormat} %7s\n"
	
	echo "Apps: ${selectedApps[@]}"
	echo "Parsers: ${parserNames[@]}"
	
	
	# Testing ...
	for ((ai=0;${ai}<${#selectedApps[@]};ai++))
	do
		app="${selectedApps[${ai}]}"
		d="${parserTestsPathBase}/apps/${app}"
		
		groupTestBasePath="${d}/tests"
		
		unset groupTests
		
		# Populate group tests
		if [ ${#tests[@]} -eq 0 ]
		then
			while read t
			do
				[ -z "${t}" ] && continue
				groupTests[${#groupTests[@]}]="$(basename "${t}")"
			done << EOF
			$(find "${groupTestBasePath}" -mindepth 1 -maxdepth 1 -type f -name "*.cli" | sort)
EOF
		else
			for ((t=0;${t}<${#tests[@]};t++))
			do
				#tn="${groupTestBasePath}/$(printf "%03d.cli" ${tests[${t}]})"
				tn="${groupTestBasePath}/${tests[${t}]}.cli"
				if [ -f "${tn}" ]
				then 
					groupTests[${#groupTests[@]}]="$(basename "${tn}")"
				fi
			done
		fi
		
		if [ ${#groupTests[@]} -eq 0 ]
		then
			continue
		fi
			
		echo "${selectedApps[${ai}]} (${#groupTests[@]} tests)"
		printf "${resultLineFormat}" "Test" "${parserNames[@]}" "RESULT"
		
		# Per group initializations
		xmlDescription="${d}/xml/program.xml"
		tmpScriptBasename="${d}/program"
		
		if ${testSh}
		then
			xshFile="${tmpScriptBasename}-xsh.xsh"
			xshBodyFile="${tmpScriptBasename}-xsh.body.sh"
			log "Generate ${app} XSH file (${xshBodyFile} => ${xshFile})"
			cat > "${xshFile}" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<xsh:program xmlns:prg="http://xsd.nore.fr/program" xmlns:xsh="http://xsd.nore.fr/xsh" xmlns:xi="http://www.w3.org/2001/XInclude">
<xsh:info>
	<xi:include href="xml/program.xml" />
</xsh:info>
<xsh:functions>
	<xi:include href="../../lib/functions.xsh" xpointer="xmlns(xsh=http://xsd.nore.fr/xsh)xpointer(//xsh:function)" />
</xsh:functions>
<xsh:code>
<xi:include href="./$(basename "${xshBodyFile}")" parse="text" />
</xsh:code>
</xsh:program>
EOF
			xsltproc --xinclude -o "${xshBodyFile}" "${parserTestsPathBase}/lib/sh-unittestprogram.xsl" "${xmlDescription}" || ns_error "Failed to create ${xshBodyFile}"  
			
			for s in ${available_shells[@]}
			do
				shScript="${tmpScriptBasename}.${s}"
				shScripts[${#shScripts[@]}]="${shScript}"
				buildShScriptArgs=(\
					-i ${s} \
					-p \
					-x "${xmlDescription}" \
					-s "${xshFile}" \
					-o "${shScript}"\
				)
				log "Generating ${app} ${s} program (${buildShScriptArgs[@]})"
				"${projectPath}/ns/sh/build-shellscript.sh" "${buildShScriptArgs[@]}" || ns_error "Failed to create ${shScript}" 
				chmod 755 "${shScript}"
			done
			
			${keepTemporaryFiles} || rm -f "${xshBodyFile}"
		fi
		
		if ${testPython}
		then
			# Create python module
			pyParser="${d}/Parser.py"
			pyInfo="${d}/ProgramInfo.py"
			pyProgramBase="${tmpScriptBasename}-exe-"
			
			log "Create Python parser module"
			"${projectPath}/ns/sh/build-python.sh" -b \
				-x "${xmlDescription}" \
				-c "TestProgramInfo" \
				-o "${pyParser}" || ns_error "Failed to generated python module"
				
			log "Create Python program info module"
			"${projectPath}/ns/sh/build-python.sh" \
				-i "Parser" \
				-x "${xmlDescription}" \
				-c "TestProgramInfo" \
				-o "${pyInfo}" || ns_error "Failed to generated Python program info module"
				
			log "Generate python scripts"
			unset pyPrograms
			for p in "${pythonInterpreters[@]}"
			do
				pyProgram="${pyProgramBase}${p}.py"
				pyPrograms=("${pyPrograms[@]}" "${pyProgram}")
				xsltproc --xinclude -o "${pyProgram}" --stringparam interpreter ${p} "${parserTestsPathBase}/lib/python-unittestprogram.xsl" "${xmlDescription}" || ns_error "Failed to create ${pyProgram}"
				chmod 755 "${pyProgram}"
			done
		fi
		
		if ${testC}
		then
			cParserBase="${tmpScriptBasename}-parser"
			cProgram="${tmpScriptBasename}-exe"
			xsltproc --xinclude -o "${cProgram}.c" \
				"${parserTestsPathBase}/lib/c-unittestprogram.xsl" \
				"${xmlDescription}" || ns_error "Failed to create ${cProgram} source"
			
			log "Create C files"
			"${projectPath}/ns/sh/build-c.sh" -eu \
				-x "${xmlDescription}" \
				-o "$(dirname "${tmpScriptBasename}")" \
				-f "$(basename "${cParserBase}")" \
				-p "app" || ns_error "Failed to generated C parser"
				
			log "Build C program"
			gcc -Wall -pedantic -g -O0 \
			-o "${cProgram}" \
			"${cProgram}.c" "${cParserBase}.c" || ns_error "Failed to build C program"   
		fi
		
		if ${testPHP}
		then
			phpLibrary="${tmpScriptBasename}-lib.php"
			phpProgram="${tmpScriptBasename}-exe.php"
			log "Create PHP program info"
			"${projectPath}/ns/sh/build-php.sh" -e \
				-x "${xmlDescription}" \
				-c "TestProgramInfo" \
				-o "${phpLibrary}" || ns_error "Failed to generated PHP module"
				
			log "Create program"
			xsltproc --xinclude -o "${phpProgram}" \
				"${parserTestsPathBase}/lib/php-unittestprogram.xsl" \
				"${xmlDescription}" || ns_error "Failed to create ${phpProgram}"
			chmod 755 "${phpProgram}"
		fi
			
		log "Run test(s)"
		for ((ti=0;${ti}<${#groupTests[@]};ti++))
		do
			t="${groupTestBasePath}/${groupTests[${ti}]}"
			base="${t%.cli}"
			testnumber="$(basename "${base}")"
			result="${base}.result"
			expected="${base}.expected"
			# Create a temporary script
			tmpShellScript="${tmpScriptBasename}-test-${app}-${testnumber}.sh"
			cat > "${tmpShellScript}" << EOFSH
	#!/usr/bin/env bash
EOFSH
			cli="$(cat "${t}")"
			if ${testSh} && [ ! -f "${base}.no-sh" ]
			then
				cat >> "${tmpShellScript}" << EOFSH
	$(
	shi=0
	for s in ${available_shells[@]}
	do
		shScript="${shScripts[${shi}]}"
		echo "\"${shScript}\" "${cli[@]}" > \"${result}-${s}\" 2>>\"${logFile}\""
		shi=$(expr ${shi} + 1)
	done)
EOFSH
			fi
			if ${testPython} && [ ! -f "${base}.no-py" ]
			then
				pi=0
				for p in "${pythonInterpreters[@]}"
				do
					pyProgram="${pyPrograms[${pi}]}"
					cat >> "${tmpShellScript}" << EOFSH
	"${pyProgram}" ${cli} > "${result}-${p}"  2>>"${logFile}"
EOFSH
					pi=$(expr "${pi}" + 1)
				done
			fi
			
			if ${testC} && [ ! -f "${base}.no-c" ]
			then
				cat >> "${tmpShellScript}" << EOFSH
	"${cProgram}" ${cli} > "${result}-c"  2>>"${logFile}"
EOFSH
				if ${testValgrind}
				then
					valgrindXmlFile="${base}.result-valgrind.xml"
					cat >> "${tmpShellScript}" << EOSH
	valgrind ${valgrindArgs[@]} --xml-file="${valgrindXmlFile}" "${cProgram}" ${cli} 1>/dev/null 2>&1
EOSH
									
				fi
			fi
			
			if ${testPHP} && [ ! -f "${base}.no-php" ]
			then
				cat >> "${tmpShellScript}" << EOFSH
	"${phpProgram}" ${cli} > "${result}-php"  2>>"${logFile}"
EOFSH
			fi
			
			log " ---- ${app}/${testnumber} ---- "
			
			# Run parsers
			chmod 755 "${tmpShellScript}"	
			"${tmpShellScript}" 2>> "${logFile}"
			
			# Analyze results
			
			resultLine=
			resultLine[0]="    ${testnumber}"
			
			passed=true
			if [ -f "${expected}" ]
			then
				i=0
				if ${testSh}
				then
					if [ -f "${base}.no-sh" ]
					then
						for s in ${available_shells[@]}
						do
							resultLine[${#resultLine[@]}]="skipped"
						done
					else
						for s in ${available_shells[@]}
						do
							if [ ! -f "${result}-${s}" ] || ! diff "${expected}" "${result}-${s}" >> "${logFile}"
							then
								passed=false
								resultLine[${#resultLine[@]}]="FAILED"
							else
								resultLine[${#resultLine[@]}]="passed"
								${keepTemporaryFiles} || rm -f "${result}-${s}"
							fi
							i=$(expr ${i} + 1)
						done
					fi
				fi
				
				if ${testPython}
				then
					if [ -f "${base}.no-py" ]
					then
						for p in "${pythonInterpreters[@]}"
						do
							resultLine[${#resultLine[@]}]="skipped"
						done
					else
						for p in "${pythonInterpreters[@]}"
						do
							if [ ! -f "${result}-${p}" ] || ! diff "${expected}" "${result}-${p}" >> "${logFile}"
							then
								passed=false
								resultLine[${#resultLine[@]}]="FAILED"
							else
								resultLine[${#resultLine[@]}]="passed"
								${keepTemporaryFiles} || rm -f "${result}-${p}"
							fi
						done
					fi
				fi
				
				if ${testC}
				then
					if [ -f "${base}.no-c" ]
					then
						resultLine[${#resultLine[@]}]="skipped"
						${testValgrind} && resultLine[${#resultLine[@]}]="skipped"
					else
						if [ ! -f "${result}-c" ] || ! diff "${expected}" "${result}-c" >> "${logFile}"
						then
							passed=false
							resultLine[${#resultLine[@]}]="FAILED"
							${testValgrind} && resultLine[${#resultLine[@]}]="skipped"
						else
							resultLine[${#resultLine[@]}]="passed"
							${keepTemporaryFiles} || rm -f "${result}-c"
						
							# Valgrind
							if ${testValgrind}
							then
								if [ -f "${valgrindXmlFile}" ] 
								then
									res=$(xsltproc "${valgrindOutputXslFile}" "${valgrindXmlFile}")
									if [ ! -z "${res}" ] && [ ${res} -eq 0 ]
									then
										resultLine[${#resultLine[@]}]="passed"
										${keepTemporaryFiles} || rm -f "${valgrindXmlFile}"
										${keepTemporaryFiles} || rm -f "${valgrindShellFile}"
									else
										passed=false
										resultLine[${#resultLine[@]}]="LEAK"
									fi
								else
									passed=false
									resultLine[${#resultLine[@]}]="CALLERROR"
								fi
							fi
						fi
					fi
				fi
				
				if ${testPHP}
				then
					if [ -f "${base}.no-php" ]
					then
						resultLine[${#resultLine[@]}]="skipped"
					else
						if [ ! -f "${result}-php" ] || ! diff "${expected}" "${result}-php" >> "${logFile}"
						then
							passed=false
							resultLine[${#resultLine[@]}]="FAILED"
						else
							resultLine[${#resultLine[@]}]="passed"
							${keepTemporaryFiles} || rm -f "${result}-php"
						fi
					fi
				fi
			else
				# Test does not have a 'expected' result yet
				passed=true
				
				if ${testSh}
				then
					for s in ${available_shells[@]}
					do
						resultLine[${#resultLine[@]}]="IGNORED"
					done
				fi
				
				${testPython} && resultLine[${#resultLine[@]}]="IGNORED"
				${testC} && resultLine[${#resultLine[@]}]="IGNORED"
				${testValgrind} && resultLine[${#resultLine[@]}]="IGNORED"
				${testPHP} && resultLine[${#resultLine[@]}]="IGNORED"
				
				# Copy one of the result as the 'expected' file
				if ${testC}
				then
					cp "${result}-c" "${expected}"
				elif ${testPython}
				then
					for p in "${pythonInterpreters[@]}"
					do
						[ -f "${result}-${p}" ] && cp "${result}-${p}" "${expected}" && break
					done
				elif ${testPHP}
				then
					cp "${result}-php" "${expected}"
				elif ${testSb}
				then
					for s in ${available_shells[@]}
					do
						[ -f "${result}-${s}" ] && cp "${result}-${s}" "${expected}" && break	
					done
				fi
			fi
					
			if ${passed}
			then
				resultLine[${#resultLine[@]}]="passed"
				${keepTemporaryFiles} || rm -f "${tmpShellScript}"
			else
				resultLine[${#resultLine[@]}]="FAILED"
			fi
			
			# NB: printf doesn't like tput. So we do a post transformation
			printf "${resultLineFormat}" "${resultLine[@]}" \
				| sed "s,passed,${SUCCESS_COLOR}passed${NORMAL_COLOR},g" \
				| sed "s,FAILED,${ERROR_COLOR}FAILED${NORMAL_COLOR},g"
			unset resultLine
		done
		
		# Remove per-group temporary files if no error
		
		if ${testSh}
		then
			si=0
			hasErrors=false
			for s in ${available_shells[@]}
			do
				if [ $(find "${d}/tests" -name "*.result-${s}" | wc -l) -eq 0 ]
				then
					${keepTemporaryFiles} || rm -f "${shScripts[${si}]}"
				else
					hasErrors=true
				fi
				si=$(expr ${si} + 1)
			done
			if ! ${hasErrors}
			then
				${keepTemporaryFiles} || rm -f "${xshFile}"
			fi
			unset shScripts
		fi
		
		if ${testPython}
		then
			pi=${parser_startindex}
			hasErrors=false
			for p in "${pythonInterpreters[@]}"
			do
				if [ $(find "${d}/tests" -name "*.result-${p}" | wc -l) -eq 0 ]
				then
					${keepTemporaryFiles} || rm -f "${pyPrograms[${pi}]}"
				else
					hasErrors=true
				fi
				
				# Python cache files are always removed
				rm -f "${pyPrograms[${pi}]}c"
				rm -fr "${d}/__pycache__"
				
				pi=$(expr ${pi} + 1)
			done
			
			if ! ${hasErrors}
			then
				${keepTemporaryFiles} || rm -f "${pyInfo}"
				${keepTemporaryFiles} || rm -f "${pyParser}"
			fi
			
			rm -f "${pyInfo}c"
			rm -f "${pyParser}c"
					
			unset pyPrograms
		fi
		
		if ${testC}
		then
			if [ $(find "${d}/tests" -name "*.result-c" | wc -l) -eq 0 ]
			then
				${keepTemporaryFiles} || rm -f "${cProgram}"
				${keepTemporaryFiles} || rm -f "${cProgram}.c"
				${keepTemporaryFiles} || rm -f "${cParserBase}.h"
				${keepTemporaryFiles} || rm -f "${cParserBase}.c"
				# Mac OS X
				${keepTemporaryFiles} || rm -fr "${cProgram}.dSYM"
			fi
		fi
		
		if ${testPHP}
		then
			if [ $(find "${d}/tests" -name "*.result-php" | wc -l) -eq 0 ]
			then
				${keepTemporaryFiles} || rm -f "${phpProgram}"
				${keepTemporaryFiles} || rm -f "${phpLibrary}"
			fi
		fi
	done
	
	${testC} && ${testValgrind} && (${keepTemporaryFiles} || rm -f "${valgrindOutputXslFile}")
	
	find "${parserTestsPathBase}" -name "*.result-*" | wc -l
	exit $(find "${parserTestsPathBase}" -name "*.result-*" | wc -l)
elif [ "${parser_subcommand}" = 'xsh' ]
then
	xshTestsPathBase="${projectPath}/unittests/xsh"
	xshTestProgramStylesheet="${xshTestsPathBase}/testprogram.xsl"
	xshTestProgram="$(ns_mktemp xsh-test-program)"
	xshTestResult=0
	while read test
	do
		echo $test
		xsltproc --output "${xshTestProgram}" --xinclude "${xshTestProgramStylesheet}" "${test}" \
		&& chmod 755 "${xshTestProgram}" \
		&& "${xshTestProgram}"
		  
	done << EOF
	$(find "${xshTestsPathBase}" -name '*.xsh') 
EOF
	rm -f "${xshTestProgram}" 
	exit ${xshTestResult}
fi
	
exit 0

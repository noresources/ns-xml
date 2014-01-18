#!/usr/bin/env bash
# ####################################
# Copyright © 2012 by Renaud Guillard (dev@nore.fr)
# Distributed under the terms of the MIT License, see LICENSE
# Author: Renaud Guillard
# Version: 2.0
# 
# Documentation builder
#
# Program help
usage()
{
cat << EOFUSAGE
update-doc: Documentation builder
Usage: 
  update-doc [--vcs <...> --xsl-output <path> --xsl-css <path> --stylesheet-abstract (--no-index | --index-url <...> --relative-index-url | --index <path> --index-name <...> --copy-anywhere)] [--html-output <path> --nme-easylink <...>] [--html-body-only] [--help] [Things to update ...]
  With:
    XSLT documentation
      --vcs: Generate documentation for versionned XSLT files  
        The argument value have to be one of the following:  
          hg or git
      --xsl-output: XSLT output path
      --xsl-css: XSLT CSS file
      --stylesheet-abstract, --abstract: Display XSLT stylesheet abstract
        Consider the comment above the 'stylesheet' root node as the file 
        abstract and display it as a HTML heading
      Directory index settings
        --no-index: Do not generate index nor navigation links
        URL
          --index-url: Index URL
          --relative-index-url: Index URL is relative to root
        
        File
          --index: Index page source file path
          --index-name: Index page output file name  
            Default value: index.php
          --copy-anywhere: Copy index file in all directories
        
      
    
    HTML documentation options
      --html-output: HTML output path
      --nme-easylink, --easylink: NME Easy link format  
        Default value: $.html
    
    Shared settings
      --html-body-only: Do not generate HTML header etc.
    
    --help: Display program usage
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

# Switch options
xsltAbstract=false
indexModeNone=false
indexUrlRelativeToRoot=false
indexCopyInFolders=false
htmlBodyOnly=false
displayHelp=false
# Single argument options
xsltVersionControlSystem=
xsltDocOutputPath=
xsltDocCssFile=
indexUrl=
indexFile=
indexFileOutputName=
htmlOutputPath=
nmeEasyLink=

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
	for ((i=${parser_startindex};${i}<${#parser_errors[*]};i++))
	do
		echo -e "\t- ${parser_errors[${i}]}"
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
			parser_errors[$(expr ${#parser_errors[*]} + ${parser_startindex})]="Missing required option ${displayPart}"
			c=$(expr ${c} + 1)
		fi
	done
	return ${c}
}
parse_setdefaultarguments()
{
	local parser_set_default=false
	# indexFileOutputName
	if [ -z "${indexFileOutputName}" ]
	then
		parser_set_default=true
		if ! ([ -z "${indexMode}" ] || [ "${indexMode}" = "indexModeFile" ] || [ "${indexMode:0:1}" = "@" ])
		then
			parser_set_default=false
		fi
		
		if ${parser_set_default}
		then
			indexFileOutputName="index.php"
			indexMode="indexModeFile"
			parse_setoptionpresence G_1_g_5_g_3_g_2_index_name;parse_setoptionpresence G_1_g_5_g_3_g;parse_setoptionpresence G_1_g_5_g;parse_setoptionpresence G_1_g
		fi
	fi
	# nmeEasyLink
	if [ -z "${nmeEasyLink}" ]
	then
		parser_set_default=true
		if ${parser_set_default}
		then
			nmeEasyLink="$.html"
			parse_setoptionpresence G_2_g_2_nme_easylink;parse_setoptionpresence G_2_g
		fi
	fi
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
	local value
	if [ $# -gt 0 ] && [ ! -z "${1}" ]; then value="${1}"; else return ${PARSER_ERROR}; fi
	shift
	if [ -z "${parser_subcommand}" ]
	then
		case "${position}" in
		*)
			;;
		
		esac
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
	if [ -z "${parser_item}" ] || [ "${parser_item:0:1}" != "-" ] || [ "${parser_item}" = "--" ]
	then
		return ${PARSER_SC_SKIP}
	fi
	
	return ${PARSER_SC_SKIP}
}
parse_process_option()
{
	if [ ! -z "${parser_subcommand}" ] && [ "${parser_item}" != "--" ]
	then
		parse_process_subcommand_option && return ${PARSER_OK}
		[ ${parser_index} -ge ${parser_itemcount} ] && return ${PARSER_OK}
	fi
	
	parser_item="${parser_input[${parser_index}]}"
	
	[ -z "${parser_item}" ] && return ${PARSER_OK}
	
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
			parse_setoptionpresence G_4_help
			;;
		vcs)
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
			if ! ([ "${parser_item}" = "hg" ] || [ "${parser_item}" = "git" ])
			then
				parse_adderror "Invalid value for option \"${parser_option}\""
				
				return ${PARSER_ERROR}
			fi
			xsltVersionControlSystem="${parser_item}"
			parse_setoptionpresence G_1_g_1_vcs;parse_setoptionpresence G_1_g
			;;
		xsl-output)
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
			if [ ! -e "${parser_item}" ]
			then
				parse_adderror "Invalid path \"${parser_item}\" for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			if [ -a "${parser_item}" ] && ! ([ -d "${parser_item}" ])
			then
				parse_adderror "Invalid patn type for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			xsltDocOutputPath="${parser_item}"
			parse_setoptionpresence G_1_g_2_xsl_output;parse_setoptionpresence G_1_g
			;;
		xsl-css)
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
			
			xsltDocCssFile="${parser_item}"
			parse_setoptionpresence G_1_g_3_xsl_css;parse_setoptionpresence G_1_g
			;;
		stylesheet-abstract | abstract)
			# Group checks
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_ERROR}
			fi
			xsltAbstract=true
			parse_setoptionpresence G_1_g_4_stylesheet_abstract;parse_setoptionpresence G_1_g
			;;
		no-index)
			# Group checks
			if ! ([ -z "${indexMode}" ] || [ "${indexMode}" = "indexModeNone" ] || [ "${indexMode:0:1}" = "@" ])
			then
				parse_adderror "Another option of the group \"indexMode\" was previously set (${indexMode})"
				return ${PARSER_ERROR}
			fi
			
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_ERROR}
			fi
			indexModeNone=true
			indexMode="indexModeNone"
			parse_setoptionpresence G_1_g_5_g_1_no_index;parse_setoptionpresence G_1_g_5_g;parse_setoptionpresence G_1_g
			;;
		index-url)
			# Group checks
			if ! ([ -z "${indexMode}" ] || [ "${indexMode}" = "indexModeUrl" ] || [ "${indexMode:0:1}" = "@" ])
			then
				parse_adderror "Another option of the group \"indexMode\" was previously set (${indexMode})"
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
			indexUrl="${parser_item}"
			indexMode="indexModeUrl"
			parse_setoptionpresence G_1_g_5_g_2_g_1_index_url;parse_setoptionpresence G_1_g_5_g_2_g;parse_setoptionpresence G_1_g_5_g;parse_setoptionpresence G_1_g
			;;
		relative-index-url)
			# Group checks
			if ! ([ -z "${indexMode}" ] || [ "${indexMode}" = "indexModeUrl" ] || [ "${indexMode:0:1}" = "@" ])
			then
				parse_adderror "Another option of the group \"indexMode\" was previously set (${indexMode})"
				return ${PARSER_ERROR}
			fi
			
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_ERROR}
			fi
			indexUrlRelativeToRoot=true
			indexMode="indexModeUrl"
			parse_setoptionpresence G_1_g_5_g_2_g_2_relative_index_url;parse_setoptionpresence G_1_g_5_g_2_g;parse_setoptionpresence G_1_g_5_g;parse_setoptionpresence G_1_g
			;;
		index)
			# Group checks
			if ! ([ -z "${indexMode}" ] || [ "${indexMode}" = "indexModeFile" ] || [ "${indexMode:0:1}" = "@" ])
			then
				parse_adderror "Another option of the group \"indexMode\" was previously set (${indexMode})"
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
			if [ ! -e "${parser_item}" ]
			then
				parse_adderror "Invalid path \"${parser_item}\" for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			if ! parse_pathaccesscheck "${parser_item}" "r"
			then
				parse_adderror "Invalid path permissions for \"${parser_item}\", r privilege(s) expected for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			if [ -a "${parser_item}" ] && ! ([ -f "${parser_item}" ])
			then
				parse_adderror "Invalid patn type for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			indexFile="${parser_item}"
			indexMode="indexModeFile"
			parse_setoptionpresence G_1_g_5_g_3_g_1_index;parse_setoptionpresence G_1_g_5_g_3_g;parse_setoptionpresence G_1_g_5_g;parse_setoptionpresence G_1_g
			;;
		index-name)
			# Group checks
			if ! ([ -z "${indexMode}" ] || [ "${indexMode}" = "indexModeFile" ] || [ "${indexMode:0:1}" = "@" ])
			then
				parse_adderror "Another option of the group \"indexMode\" was previously set (${indexMode})"
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
			indexFileOutputName="${parser_item}"
			indexMode="indexModeFile"
			parse_setoptionpresence G_1_g_5_g_3_g_2_index_name;parse_setoptionpresence G_1_g_5_g_3_g;parse_setoptionpresence G_1_g_5_g;parse_setoptionpresence G_1_g
			;;
		copy-anywhere)
			# Group checks
			if ! ([ -z "${indexMode}" ] || [ "${indexMode}" = "indexModeFile" ] || [ "${indexMode:0:1}" = "@" ])
			then
				parse_adderror "Another option of the group \"indexMode\" was previously set (${indexMode})"
				return ${PARSER_ERROR}
			fi
			
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_ERROR}
			fi
			indexCopyInFolders=true
			indexMode="indexModeFile"
			parse_setoptionpresence G_1_g_5_g_3_g_3_copy_anywhere;parse_setoptionpresence G_1_g_5_g_3_g;parse_setoptionpresence G_1_g_5_g;parse_setoptionpresence G_1_g
			;;
		html-output)
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
			if ! parse_pathaccesscheck "${parser_item}" "w"
			then
				parse_adderror "Invalid path permissions for \"${parser_item}\", w privilege(s) expected for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			if [ -a "${parser_item}" ] && ! ([ -d "${parser_item}" ])
			then
				parse_adderror "Invalid patn type for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			htmlOutputPath="${parser_item}"
			parse_setoptionpresence G_2_g_1_html_output;parse_setoptionpresence G_2_g
			;;
		nme-easylink | easylink)
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
			nmeEasyLink="${parser_item}"
			parse_setoptionpresence G_2_g_2_nme_easylink;parse_setoptionpresence G_2_g
			;;
		html-body-only)
			# Group checks
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_ERROR}
			fi
			htmlBodyOnly=true
			parse_setoptionpresence G_3_g_1_html_body_only;parse_setoptionpresence G_3_g
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
		parse_setdefaultarguments
		parse_checkrequired
		parse_checkminmax
	fi
	
	
	
	local parser_errorcount=${#parser_errors[*]}
	return ${parser_errorcount}
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
	local file
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
	local schema
	if [ $# -gt 0 ]
	then
		schema="${1}"
		shift
	fi
	local xml
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
ns_isdir()
{
	local inputPath
	if [ $# -gt 0 ]
	then
		inputPath="${1}"
		shift
	fi
	[ ! -z "${inputPath}" ] && [ -d "${inputPath}" ]
}
ns_issymlink()
{
	local inputPath
	if [ $# -gt 0 ]
	then
		inputPath="${1}"
		shift
	fi
	[ ! -z "${inputPath}" ] && [ -L "${inputPath}" ]
}
ns_realpath()
{
	local inputPath
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
	local from
	if [ $# -gt 0 ]
	then
		from="${1}"
		shift
	fi
	local base
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
	local key
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
	local key
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
	if [ "$(uname -s)" == "Darwin" ]
	then
		which "${@}"
	else
	local silent="false"
	local args
	while [ ${#} -gt 0 ]
		do
			if [ "${1}" = "-s" ]
			then 
				silent=true
			else
				args=("${args[@]}" "${1}")
			fi
			shift
		done
		
		if ${silent}
		then
			which "${args[@]}" 1>/dev/null 2>&1
		else
			which "${args[@]}"
		fi
	fi
}
ns_sed_inplace()
{
	# sedForm
	# 1: modern linux => (g)sed --in-place
	# 2: Mac OS X 10.5-10.8 - => sed -i ""
	# TODO test Mac OS X < 10.5
	local sedForm=1
	# Use gsed if available
	local sedBin="$(which "gsed")"
	[ -z "${sedBin}" ] && sedBin="$(which "sed")"
	[ -z "${sedBin}" ] && return 1
	
	if [ "$(uname -s)" == "Darwin" ] && [ "${sedBin}" = "/usr/bin/sed" ]
	then
	local macOSXVersion="$(sw_vers -productVersion)"
	if [ ! -z "${macOSXVersion}" ]
		then
	local macOSXMajorVersion="$(echo "${macOSXVersion}" | cut -f 1 -d".")"
	local macOSXMinorVersion="$(echo "${macOSXVersion}" | cut -f 2 -d".")"
	if [ ${macOSXMajorVersion} -eq 10 ] && [ ${macOSXMinorVersion} -ge 5 ]
			then
				sedForm=2
			fi
		fi	
	fi
	
	if [ ${sedForm} -eq 1 ]
	then
		"${sedBin}" --in-place "${@}"
	elif [ ${sedForm} -eq 2 ]
	then
		"${sedBin}" -i ""  "${@}"
	fi
}
filesystempath_to_nmepath()
{
	local sourceBasePath
	if [ $# -gt 0 ]
	then
		sourceBasePath="${1}"
		shift
	fi
	local outputBasePath
	if [ $# -gt 0 ]
	then
		outputBasePath="${1}"
		shift
	fi
	local path
	if [ $# -gt 0 ]
	then
		path="${1}"
		shift
	fi
	local output="$(echo "${path#${sourceBasePath}}" | tr -d "/" | tr " " "_")"
	output="${outputBasePath}/${output}"
	echo "${output}"
}
scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
scriptName="$(basename "${scriptFilePath}")"
projectPath="$(ns_realpath "${scriptPath}/../..")"
creolePath="${projectPath}/doc/wiki/bitbucket"
xslPath="${projectPath}/ns/xsl"
resourceXslPath="${projectPath}/resources/xsl"
cwd="$(pwd)"

# Override default path for htmlOutputPath
htmlOutputPath="${projectPath}/doc/html/articles"

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

update_item()
{
	local name="${1}"
	local n=${#parser_values[*]}
	[ ${n} -eq 0 ] && return 0
	for ((i=0;${i}<${n};i++))
	do
		[ "${parser_values[${i}]}" == "${name}" ] && return 0
	done
	
	return 1
}

xsltdoc()
{
	local f="${1}"
	local output="${f#${xslPath}}"
	output="${xsltDocOutputPath}${output}"
	output="${output%xsl}html"
	local outputFolder="$(dirname "${output}")"
	mkdir -p "${outputFolder}" || ns_error 2 "Failed to create ${outputFolder}"
	local cssPath="$(ns_relativepath "${xsltDocCssFile}" "${outputFolder}")"
	local title="${output#${xsltDocOutputPath}/}"
	title="${title%.html}"
	
	if [ "${indexMode}" = "indexModeUrl" ]
	then
		echo -n ""
	elif [ "${indexMode}" = "indexModeFile" ]
	then
		local outputIndexPath="${outputFolder}/${indexFileOutputName}"
		if ${indexCopyInFolders} && [ "${indexFile}" != "${outputIndexPath}" ]
		then
			cp -pf "${indexFile}" "${outputIndexPath}"
		fi
	fi
	
	testXsltOptions=(--xinclude)
	if ${xsltAbstract}
	then
		testXsltOptions=("${testXsltOptions[@]}" "--param" "xsl.doc.html.stylesheetAbstract" "true()")
	fi
	
	available="$(xsltproc "${testXsltOptions[@]}" "${xslTestStylesheet}" "${f}")"
	
	if [ ${available} = "yes" ]
	then
		xsltproc "${xsltprocOptions[@]}" -o "${output}" \
			--stringparam "xsl.doc.html.fileName" "${title}" \
			--stringparam "xsl.doc.html.cssPath" "${cssPath}" \
			"${xslStylesheet}" "${f}"
	fi
}

for tool in nme find xsltproc
do
	which ${tool} 1>/dev/null 2>&1 || (echo "${tool} not found" && exit 1)
done

# Set defaults if nothing selected by user
[ ${#parser_values[*]} -eq 0 ] && parser_values=(creole html xsl)

if update_item creole
then
	appXshPath="${projectPath}/ns/xsh/apps"
	outputPath="${creolePath}/apps"

	# TODO get program version
	
	find "${appXshPath}" -name "*.xml" | while read f
	do
		programVersion="$(get_program_version "${f}")" 
		creoleXslStylesheet="${xslPath}/program/${programVersion}/wikicreole-usage.xsl"
		[ -f "${creoleXslStylesheet}" ] || continue
		b="$(basename "${f}")"
		xsltproc --xinclude -o "${outputPath}/${b%xml}wiki" "${creoleXslStylesheet}" "${f}" 
	done
	
	# Spreadsheets to creole pages
	specComplianceSource="${projectPath}/doc/documents/program/SpecificationCompliance.ods"
	specComplianceTempPath="$(ns_mktempdir "${scriptName}")"
	specComplianceOutput="${creolePath}/program/SpecificationCompliance.wiki"
	specComplianceXslt="${resourceXslPath}/ods2wikicreole.speccompliance.xsl"
	
	cd "${specComplianceTempPath}"
	if unzip -o "${specComplianceSource}" "content.xml" 1>/dev/null 2>&1
	then
		# General feature support
		cat "${specComplianceOutput}.1" > "${specComplianceOutput}"
		echo "" >> "${specComplianceOutput}"
	
		xsltproc --param odf.spreadsheet2wikicreole.tableIndex 2 "${specComplianceXslt}" content.xml >> "${specComplianceOutput}"
		echo "" >> "${specComplianceOutput}"
		
		# Behaviors
		cat "${specComplianceOutput}.2" >> "${specComplianceOutput}"
		echo "" >> "${specComplianceOutput}"
		
		xsltproc --param odf.spreadsheet2wikicreole.tableIndex 3 "${specComplianceXslt}" content.xml >> "${specComplianceOutput}"
		echo "" >> "${specComplianceOutput}"
				
		# Messages
		cat "${specComplianceOutput}.3" >> "${specComplianceOutput}"
		echo "" >> "${specComplianceOutput}"
		
		xsltproc --param odf.spreadsheet2wikicreole.tableIndex 1 "${specComplianceXslt}" content.xml >> "${specComplianceOutput}"
		echo "" >> "${specComplianceOutput}"
		
		# Footer
		cat "${specComplianceOutput}.4" >> "${specComplianceOutput}"
		echo "" >> "${specComplianceOutput}"
		
		rm -f content.xml
	else
		ns_error 2 Failed to unzip doc
	fi
	
	# Parser pseudo code
	parserPseudocodeOutput="${creolePath}/program/ParserPseudocode.wiki"
	i=1
	found=true
	rm -f "${parserPseudocodeOutput}"
	while ${found}
	do
		isCode=false
		part="${parserPseudocodeOutput}.${i}"
		if [ ! -f "${part}" ]
		then
			isCode=true
			part="${parserPseudocodeOutput}.${i}.code"
		fi
		
		[ -f "${part}" ] || break
		
		#echo -n "${part}"
		#(${isCode} && echo " (code)") || echo ""
				
		if ${isCode}
		then
			# add bold to keyword
			# Transform tab into {{{2 spaces}}
			# Add \\ at end of lines
			cat "${part}" \
			| sed -E 's,(^[ 	]*)(procedure|if|then|else|else if|while|for|break|end if|end while|end for|do|return)( |$),\1**\2**\3,g' \
			| sed -E 's,(^|	| )(and|or|not)( |$),\1**\2**\3,g' \
			| sed -E 's,(false|true|null),**\1**,g' \
			| sed -E 's,[	],{{{  }}},g' \
			| sed 's,[ ]*$,\\\\,g' >> "${parserPseudocodeOutput}"  
		else
			cat "${part}" >> "${parserPseudocodeOutput}"
		fi
		
		i=$(expr ${i} + 1)
	done
fi

if update_item html && which nme 1>/dev/null 2>&1
then
	nmeOptions=(--easylink "${nmeEasyLink}")
	if ${htmlBodyOnly}
	then
		nmeOptions=("${nmeOptions[@]}" --body)	
	fi
	
	for e in wiki jpg png gif
	do
		find "${creolePath}" -name "*.${e}" | while read f
		do
			#output="${htmlOutputPath}${f#${creolePath}}"
			
			#output="$(echo "${f#${creolePath}}" | tr -d "/")"
			#output="${htmlOutputPath}/${output}"
			
			output="$(filesystempath_to_nmepath "${creolePath}" "${htmlOutputPath}" "${f}")"
			
			[ "${e}" == "wiki" ] && output="${output%wiki}html"
			echo "${output}"
			mkdir -p "$(dirname "${output}")"
			if [ "${e}" == "wiki" ]
			then
				nme "${nmeOptions[@]}" < "${f}" > "${output}"
				ns_sed_inplace "s/\.\(png\|jpg\|gif\)\.html/.\1/g" "${output}"
			else
				rsync -lprt "${f}" "${output}"
			fi
		done
	done
fi

xslStylesheet="${xslPath}/languages/xsl/documentation-html.xsl"
xslTestStylesheet="${xslPath}/languages/xsl/documentation-html-available.xsl"
defaultCssFile="${projectPath}/resources/css/xsl.doc.html.css"

if update_item xsl
then
	[ -z "${xsltDocOutputPath}" ] && xsltDocOutputPath="${projectPath}/doc/html/xsl"
	mkdir -p "${xsltDocOutputPath}" || ns_error 2 "Failed to create XSLT output folder ${xsltDocOutputPath}" 
	[ -z "${xsltDocCssFile}" ] && xsltDocCssFile="${defaultCssFile}"
	xsltDocCssFile="$(ns_realpath "${xsltDocCssFile}")"
	[ "${indexMode}" = "indexModeFile" ] && ${indexCopyInFolders} && indexFile="$(ns_realpath "${indexFile}")" 
	
	xsltDocOutputPath="$(ns_realpath "${xsltDocOutputPath}")"
	xslDirectoryIndexMode="auto"
		
	if [ "${indexMode}" = "indexModeFile" ]
	then
		if ${indexCopyInFolders}
		then
			xslDirectoryIndexMode="per-folder"
		else
			xslDirectoryIndexMode="root"
		fi
		
		outputIndexPath="${xsltDocOutputPath}/${indexFileOutputName}"
		
		echo "Create index (${xslDirectoryIndexMode}) from \"${indexFile}\"" 	
				
		if [ "${indexFile}" != "${outputIndexPath}" ]
		then
			rsync -lprt "${indexFile}" "${outputIndexPath}"
		fi
	elif [ "${indexMode}" = "indexModeNone" ]
	then
		xslDirectoryIndexMode="none"
	fi
	
	xsltprocOptions=(--xinclude \
		--stringparam "xsl.doc.html.directoryIndexPathMode" "${xslDirectoryIndexMode}" \
		--stringparam "xsl.doc.html.directoryIndexPath" "${indexFileOutputName}" \
		)
	
	if ${htmlBodyOnly}
	then
		xsltprocOptions=("${xsltprocOptions[@]}" "--param" "xsl.doc.html.fullHtmlPage" "false()")
	fi
	
	if ${xsltAbstract}
	then
		xsltprocOptions=("${xsltprocOptions[@]}" "--param" "xsl.doc.html.stylesheetAbstract" "true()")
	fi

	if [ "${xsltVersionControlSystem}" = "git" ] && [ -d "${projectPath}/.git" ] 
	then
		cd "${projectPath}/ns/xsl"
		while read f
		do
			xsltdoc "${projectPath}/${f}"
		done << EOF
$(git ls-files --full-name | grep -e ".*\.xsl$")
EOF
		cd "${cwd}"

	elif [ "${xsltVersionControlSystem}" = "hg" ] && [ -d "${projectPath}/.hg" ]
	then 
		cd "${projectPath}"
		while read f
		do
			xsltdoc "${projectPath}${f}"
		done << EOF
$(hg st -macn  --include "glob:${xslPath}/**.xsl")
EOF
		cd "${cwd}"
	else
		while read f
		do
			xsltdoc "${f}"
		done << EOF
		$(find "${xslPath}" -name "*.xsl")
EOF
	fi
fi

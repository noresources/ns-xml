#!/usr/bin/env bash
# ####################################
# Copyright © 2018 - 2021 by Renaud Guillard
# Distributed under the terms of the MIT License, see LICENSE
# Author: Renaud Guillard
# Version: 1.0
# 
# Create a customized Command line argument parser in C
#
# Program help
usage()
{
cat << 'EOFUSAGE'
build-c: Create a customized Command line argument parser in C
Usage: 
  build-c [([-b] --schema-version <...> | [-S] -x <path> ([-e] -i <path>)) -p <...> --struct-style <...> --function-style <...> --variable-style <...>] [[-u] -o <path> -f <...>] [--ns-xml-path <path> --ns-xml-path-relative] [--help]
  Options:
    Generation options
      Generation mode
        Select what to generate
      
        Generic code
          -b, --base: Generate ns-xml utility and parser core
            The generated code is independent from any program interface 
            definition
          --schema-version: Program interface definition schema version  
            The argument have to be one of the following:  
              2.0
            Default value: 2.0
      
        Program specific code
          -x, --xml-description: Program description file
            If the program description file is provided, the xml file will be 
            validated before any XSLT processing
          -S, --skip-validation, --no-validation: Skip XML Schema validations
            The default behavior of the program is to validate the given 
            xml-based file(s) against its/their xml schema 
            (http://xsd.nore.fr/program etc.). This option will disable schema 
            validations
          File structure scheme
            -e, --embed: Generate program parser and embed generic utility and 
            parser core
            -i, --include: Generate program parser and include a pre-genrated 
            utility and parser core
              The namimg styles for variables, structs and functions of the 
              program parser pre-generated files must match
      
      
      
      -p, --prefix: Program struct & function names prefixes
        The default behavior use the program name described in the XML program 
        interface definition file
      Naming styles
        Define the coding style of the public structs, functions and variables.
        The default coding style of the ns-xml utilities and parser core is 
        'underscore'. Which means fully lower case names where words are 
        separated with underscores.
          struct nsxml_struct_name;
        Private functions and internal struct members of the ns-xml parser core 
        are not modified
      
        --struct-style, --struct: Structs naming convention
          Generate struct names according the given naming convention  
          The argument have to be one of the following:  
            underscore, camelCase, CamelCase or none
          Default value: none
        --function-style, --function, --func: Functions naming convention
          Generate function names according the given naming convention  
          The argument have to be one of the following:  
            underscore, camelCase, CamelCase or none
          Default value: none
        --variable-style, --variable, --var: Variables naming convention
          Generate variable and enum names according the given naming 
          convention  
          The argument have to be one of the following:  
            underscore, camelCase, CamelCase or none
          Default value: none
      
    
    Output location
      -o, --output: Output folder path for the generated files  
        Default value: .
      -f, --file-base, --file: Output file base name
        C Header file extension (.h) and C Source code extension (.c) are 
        automatically appended to the name  
        Default value: <auto>
      -u, --overwrite, --force: Overwrite existing files
    
    ns-xml source path options
      --ns-xml-path: ns-xml source path
        Location of the ns folder of ns-xml package
      --ns-xml-path-relative: ns source path is relative this program path
    
    --help: Display program usage
EOFUSAGE
}

# Program parameter parsing
parser_program_author="Renaud Guillard"
parser_program_version="1.0"
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
PARSER_OK=0
PARSER_ERROR=1
PARSER_SC_OK=0
PARSER_SC_ERROR=1
PARSER_SC_UNKNOWN=2
PARSER_SC_SKIP=3
[ "${parser_shell}" = 'zsh' ] && parser_startindex=1
parser_itemcount=$(expr ${parser_startindex} + ${parser_itemcount})
parser_index=${parser_startindex}


parser_required[$(expr ${#parser_required[*]} + ${parser_startindex})]="G_1_g_1_g:(--base, --schema-version) or (--xml-description, --skip-validation, (--embed, --include)):"
parser_required[$(expr ${#parser_required[*]} + ${parser_startindex})]="G_2_g_1_output:--output:"

generateBaseOnly=false
skipValidation=false
generateEmbedded=false
outputOverwrite=false
nsxmlPathRelative=false
displayHelp=false
programSchemaVersion=
xmlProgramDescriptionPath=
generateInclude=
prefix=
structNameStyle=
functionNameStyle=
variableNameStyle=
outputPath=
outputFileBase=
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
	G_1_g_1_g)
		;;
	G_1_g_1_g_1_g)
		if ! ([ -z "${generationMode}" ] || [ "${generationMode:0:1}" = '@' ] || [ "${generationMode}" = "generateProgramIndependent" ])
		then
			parse_adderror "Another option of the group \"generationMode\" was previously set (${generationMode}"
			return ${PARSER_ERROR}
		fi
		
		
		;;
	G_1_g_1_g_1_g_1_base)
		if ! ([ -z "${generationMode}" ] || [ "${generationMode:0:1}" = '@' ] || [ "${generationMode}" = "generateProgramIndependent" ])
		then
			parse_adderror "Another option of the group \"generateProgramIndependent\" was previously set (${generateProgramIndependent}"
			return ${PARSER_ERROR}
		fi
		
		
		;;
	G_1_g_1_g_1_g_2_schema_version)
		if ! ([ -z "${generationMode}" ] || [ "${generationMode:0:1}" = '@' ] || [ "${generationMode}" = "generateProgramIndependent" ])
		then
			parse_adderror "Another option of the group \"generateProgramIndependent\" was previously set (${generateProgramIndependent}"
			return ${PARSER_ERROR}
		fi
		
		
		;;
	G_1_g_1_g_2_g)
		if ! ([ -z "${generationMode}" ] || [ "${generationMode:0:1}" = '@' ] || [ "${generationMode}" = "generateProgramDependant" ])
		then
			parse_adderror "Another option of the group \"generationMode\" was previously set (${generationMode}"
			return ${PARSER_ERROR}
		fi
		
		
		;;
	G_1_g_1_g_2_g_1_xml_description)
		if ! ([ -z "${generationMode}" ] || [ "${generationMode:0:1}" = '@' ] || [ "${generationMode}" = "generateProgramDependant" ])
		then
			parse_adderror "Another option of the group \"generateProgramDependant\" was previously set (${generateProgramDependant}"
			return ${PARSER_ERROR}
		fi
		
		
		;;
	G_1_g_1_g_2_g_2_skip_validation)
		if ! ([ -z "${generationMode}" ] || [ "${generationMode:0:1}" = '@' ] || [ "${generationMode}" = "generateProgramDependant" ])
		then
			parse_adderror "Another option of the group \"generateProgramDependant\" was previously set (${generateProgramDependant}"
			return ${PARSER_ERROR}
		fi
		
		
		;;
	G_1_g_1_g_2_g_3_g)
		if ! ([ -z "${generationMode}" ] || [ "${generationMode:0:1}" = '@' ] || [ "${generationMode}" = "generateProgramDependant" ])
		then
			parse_adderror "Another option of the group \"generateProgramDependant\" was previously set (${generateProgramDependant}"
			return ${PARSER_ERROR}
		fi
		
		
		;;
	G_1_g_1_g_2_g_3_g_1_embed)
		if ! ([ -z "${generationMode}" ] || [ "${generationMode:0:1}" = '@' ] || [ "${generationMode}" = "generateProgramDependant" ])
		then
			parse_adderror "Another option of the group \"generateProgramDependantMode\" was previously set (${generateProgramDependantMode}"
			return ${PARSER_ERROR}
		fi
		
		if ! ([ -z "${generateProgramDependantMode}" ] || [ "${generateProgramDependantMode:0:1}" = '@' ] || [ "${generateProgramDependantMode}" = "generateEmbedded" ])
		then
			parse_adderror "Another option of the group \"generateProgramDependantMode\" was previously set (${generateProgramDependantMode}"
			return ${PARSER_ERROR}
		fi
		
		
		;;
	G_1_g_1_g_2_g_3_g_2_include)
		if ! ([ -z "${generationMode}" ] || [ "${generationMode:0:1}" = '@' ] || [ "${generationMode}" = "generateProgramDependant" ])
		then
			parse_adderror "Another option of the group \"generateProgramDependantMode\" was previously set (${generateProgramDependantMode}"
			return ${PARSER_ERROR}
		fi
		
		if ! ([ -z "${generateProgramDependantMode}" ] || [ "${generateProgramDependantMode:0:1}" = '@' ] || [ "${generateProgramDependantMode}" = "generateInclude" ])
		then
			parse_adderror "Another option of the group \"generateProgramDependantMode\" was previously set (${generateProgramDependantMode}"
			return ${PARSER_ERROR}
		fi
		
		
		;;
	G_1_g_2_prefix)
		;;
	G_1_g_3_g)
		;;
	G_1_g_3_g_1_struct_style)
		;;
	G_1_g_3_g_2_function_style)
		;;
	G_1_g_3_g_3_variable_style)
		;;
	G_2_g_1_output)
		;;
	G_2_g_2_file_base)
		;;
	G_2_g_3_overwrite)
		;;
	G_3_g_1_ns_xml_path)
		;;
	G_3_g_2_ns_xml_path_relative)
		;;
	
	esac
	case "${1}" in
	G_1_g)
		parse_addrequiredoption G_1_g_1_g '(--base, --schema-version) or (--xml-description, --skip-validation, (--embed, --include)):'
		
		;;
	G_1_g_1_g_1_g)
		;;
	G_1_g_1_g_2_g)
		parse_addrequiredoption G_1_g_1_g_2_g_1_xml_description '--xml-description:'
		parse_addrequiredoption G_1_g_1_g_2_g_3_g '--embed or --include:'
		
		;;
	G_1_g_3_g)
		;;
	G_2_g)
		parse_addrequiredoption G_2_g_1_output '--output:'
		
		;;
	G_3_g)
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
	
	parser_set_default=true
	parse_isoptionpresent G_1_g_1_g_1_g_2_schema_version && parser_set_default=false
	if ! ([ -z "${generationMode}" ] || [ "${generationMode:0:1}" = '@' ] || [ "${generationMode}" = "generateProgramIndependent" ])
	then
		parser_set_default=false
	fi
	
	if ${parser_set_default}
	then
		programSchemaVersion='2.0'
		generationMode='generateProgramIndependent'
		parse_setoptionpresence G_1_g_1_g_1_g_2_schema_version
		parse_setoptionpresence G_1_g_1_g_1_g
		parse_setoptionpresence G_1_g_1_g
		parse_setoptionpresence G_1_g
	fi
	
	
	parser_set_default=true
	parse_isoptionpresent G_1_g_3_g_1_struct_style && parser_set_default=false
	if ${parser_set_default}
	then
		structNameStyle='none'
		parse_setoptionpresence G_1_g_3_g_1_struct_style
		parse_setoptionpresence G_1_g_3_g
		parse_setoptionpresence G_1_g
	fi
	
	
	parser_set_default=true
	parse_isoptionpresent G_1_g_3_g_2_function_style && parser_set_default=false
	if ${parser_set_default}
	then
		functionNameStyle='none'
		parse_setoptionpresence G_1_g_3_g_2_function_style
		parse_setoptionpresence G_1_g_3_g
		parse_setoptionpresence G_1_g
	fi
	
	
	parser_set_default=true
	parse_isoptionpresent G_1_g_3_g_3_variable_style && parser_set_default=false
	if ${parser_set_default}
	then
		variableNameStyle='none'
		parse_setoptionpresence G_1_g_3_g_3_variable_style
		parse_setoptionpresence G_1_g_3_g
		parse_setoptionpresence G_1_g
	fi
	
	
	parser_set_default=true
	parse_isoptionpresent G_2_g_1_output && parser_set_default=false
	if ${parser_set_default}
	then
		outputPath='.'
		parse_setoptionpresence G_2_g_1_output
		parse_setoptionpresence G_2_g
	fi
	
	
	parser_set_default=true
	parse_isoptionpresent G_2_g_2_file_base && parser_set_default=false
	if ${parser_set_default}
	then
		outputFileBase='<auto>'
		parse_setoptionpresence G_2_g_2_file_base
		parse_setoptionpresence G_2_g
	fi
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
		help)
			! parse_setoptionpresence G_4_help && return ${PARSER_ERROR}
			
			if ${parser_optionhastail} && [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Option --${parser_option} does not allow an argument"
				parser_optiontail=''
				return ${PARSER_ERROR}
			fi
			displayHelp=true
			
			;;
		base)
			! parse_setoptionpresence G_1_g_1_g_1_g_1_base && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_1_g_1_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_1_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g && return ${PARSER_ERROR}
			
			if ${parser_optionhastail} && [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Option --${parser_option} does not allow an argument"
				parser_optiontail=''
				return ${PARSER_ERROR}
			fi
			generateBaseOnly=true
			generationMode='generateProgramIndependent'
			
			;;
		schema-version)
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
			if ! ([ "${parser_item}" = '2.0' ])
			then
				parse_adderror "Invalid value for option \"${parser_option}\""
				
				return ${PARSER_ERROR}
			fi
			! parse_setoptionpresence G_1_g_1_g_1_g_2_schema_version && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_1_g_1_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_1_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g && return ${PARSER_ERROR}
			
			programSchemaVersion="${parser_item}"
			generationMode='generateProgramIndependent'
			
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
			
			! parse_setoptionpresence G_1_g_1_g_2_g_1_xml_description && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_1_g_2_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_1_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g && return ${PARSER_ERROR}
			
			xmlProgramDescriptionPath="${parser_item}"
			generationMode='generateProgramDependant'
			
			;;
		skip-validation | no-validation)
			! parse_setoptionpresence G_1_g_1_g_2_g_2_skip_validation && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_1_g_2_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_1_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g && return ${PARSER_ERROR}
			
			if ${parser_optionhastail} && [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Option --${parser_option} does not allow an argument"
				parser_optiontail=''
				return ${PARSER_ERROR}
			fi
			skipValidation=true
			generationMode='generateProgramDependant'
			
			;;
		embed)
			! parse_setoptionpresence G_1_g_1_g_2_g_3_g_1_embed && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_1_g_2_g_3_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_1_g_2_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_1_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g && return ${PARSER_ERROR}
			
			if ${parser_optionhastail} && [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Option --${parser_option} does not allow an argument"
				parser_optiontail=''
				return ${PARSER_ERROR}
			fi
			generateEmbedded=true
			generationMode='generateProgramDependant'
			generateProgramDependantMode='generateEmbedded'
			
			;;
		include)
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
			
			! parse_setoptionpresence G_1_g_1_g_2_g_3_g_2_include && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_1_g_2_g_3_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_1_g_2_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_1_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g && return ${PARSER_ERROR}
			
			generateInclude="${parser_item}"
			generationMode='generateProgramDependant'
			generateProgramDependantMode='generateInclude'
			
			;;
		prefix)
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
			! parse_setoptionpresence G_1_g_2_prefix && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g && return ${PARSER_ERROR}
			
			prefix="${parser_item}"
			
			;;
		struct-style | struct)
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
			if ! ([ "${parser_item}" = 'underscore' ] || [ "${parser_item}" = 'camelCase' ] || [ "${parser_item}" = 'CamelCase' ] || [ "${parser_item}" = 'none' ])
			then
				parse_adderror "Invalid value for option \"${parser_option}\""
				
				return ${PARSER_ERROR}
			fi
			! parse_setoptionpresence G_1_g_3_g_1_struct_style && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_3_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g && return ${PARSER_ERROR}
			
			structNameStyle="${parser_item}"
			
			;;
		function-style | function | func)
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
			if ! ([ "${parser_item}" = 'underscore' ] || [ "${parser_item}" = 'camelCase' ] || [ "${parser_item}" = 'CamelCase' ] || [ "${parser_item}" = 'none' ])
			then
				parse_adderror "Invalid value for option \"${parser_option}\""
				
				return ${PARSER_ERROR}
			fi
			! parse_setoptionpresence G_1_g_3_g_2_function_style && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_3_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g && return ${PARSER_ERROR}
			
			functionNameStyle="${parser_item}"
			
			;;
		variable-style | variable | var)
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
			if ! ([ "${parser_item}" = 'underscore' ] || [ "${parser_item}" = 'camelCase' ] || [ "${parser_item}" = 'CamelCase' ] || [ "${parser_item}" = 'none' ])
			then
				parse_adderror "Invalid value for option \"${parser_option}\""
				
				return ${PARSER_ERROR}
			fi
			! parse_setoptionpresence G_1_g_3_g_3_variable_style && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_3_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g && return ${PARSER_ERROR}
			
			variableNameStyle="${parser_item}"
			
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
			
			! parse_setoptionpresence G_2_g_1_output && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_2_g && return ${PARSER_ERROR}
			
			outputPath="${parser_item}"
			
			;;
		file-base | file)
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
			! parse_setoptionpresence G_2_g_2_file_base && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_2_g && return ${PARSER_ERROR}
			
			outputFileBase="${parser_item}"
			
			;;
		overwrite | force)
			! parse_setoptionpresence G_2_g_3_overwrite && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_2_g && return ${PARSER_ERROR}
			
			if ${parser_optionhastail} && [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Option --${parser_option} does not allow an argument"
				parser_optiontail=''
				return ${PARSER_ERROR}
			fi
			outputOverwrite=true
			
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
			! parse_setoptionpresence G_3_g_1_ns_xml_path && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_3_g && return ${PARSER_ERROR}
			
			nsxmlPath="${parser_item}"
			
			;;
		ns-xml-path-relative)
			! parse_setoptionpresence G_3_g_2_ns_xml_path_relative && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_3_g && return ${PARSER_ERROR}
			
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
		'b')
			! parse_setoptionpresence G_1_g_1_g_1_g_1_base && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_1_g_1_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_1_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g && return ${PARSER_ERROR}
			
			generateBaseOnly=true
			generationMode='generateProgramIndependent'
			
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
			
			! parse_setoptionpresence G_1_g_1_g_2_g_1_xml_description && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_1_g_2_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_1_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g && return ${PARSER_ERROR}
			
			xmlProgramDescriptionPath="${parser_item}"
			generationMode='generateProgramDependant'
			
			;;
		'S')
			! parse_setoptionpresence G_1_g_1_g_2_g_2_skip_validation && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_1_g_2_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_1_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g && return ${PARSER_ERROR}
			
			skipValidation=true
			generationMode='generateProgramDependant'
			
			;;
		'e')
			! parse_setoptionpresence G_1_g_1_g_2_g_3_g_1_embed && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_1_g_2_g_3_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_1_g_2_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_1_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g && return ${PARSER_ERROR}
			
			generateEmbedded=true
			generationMode='generateProgramDependant'
			generateProgramDependantMode='generateEmbedded'
			
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
			
			! parse_setoptionpresence G_1_g_1_g_2_g_3_g_2_include && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_1_g_2_g_3_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_1_g_2_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g_1_g && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g && return ${PARSER_ERROR}
			
			generateInclude="${parser_item}"
			generationMode='generateProgramDependant'
			generateProgramDependantMode='generateInclude'
			
			;;
		'p')
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
			! parse_setoptionpresence G_1_g_2_prefix && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_1_g && return ${PARSER_ERROR}
			
			prefix="${parser_item}"
			
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
			
			! parse_setoptionpresence G_2_g_1_output && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_2_g && return ${PARSER_ERROR}
			
			outputPath="${parser_item}"
			
			;;
		'f')
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
			! parse_setoptionpresence G_2_g_2_file_base && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_2_g && return ${PARSER_ERROR}
			
			outputFileBase="${parser_item}"
			
			;;
		'u')
			! parse_setoptionpresence G_2_g_3_overwrite && return ${PARSER_ERROR}
			
			! parse_setoptionpresence G_2_g && return ${PARSER_ERROR}
			
			outputOverwrite=true
			
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
	
	
	[ "${parser_option_G_1_g:0:1}" = '@' ] && parser_option_G_1_g=''
	parser_option_G_1_g=''
	[ "${generationMode:0:1}" = '@' ] && generationMode=''
	[ "${generationMode:0:1}" = '~' ] && generationMode=''
	[ "${generateProgramIndependent:0:1}" = '@' ] && generateProgramIndependent=''
	generateProgramIndependent=''
	[ "${generateProgramDependant:0:1}" = '@' ] && generateProgramDependant=''
	generateProgramDependant=''
	[ "${generateProgramDependantMode:0:1}" = '@' ] && generateProgramDependantMode=''
	[ "${generateProgramDependantMode:0:1}" = '~' ] && generateProgramDependantMode=''
	[ "${parser_option_G_1_g_3_g:0:1}" = '@' ] && parser_option_G_1_g_3_g=''
	parser_option_G_1_g_3_g=''
	[ "${parser_option_G_2_g:0:1}" = '@' ] && parser_option_G_2_g=''
	parser_option_G_2_g=''
	[ "${parser_option_G_3_g:0:1}" = '@' ] && parser_option_G_3_g=''
	parser_option_G_3_g=''
	
	
	
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
ns_mktemp()
{
	local __ns_mktemp_template=
	if [ $# -gt 0 ]
	then
		__ns_mktemp_template="${1}"
		shift
	else
		__ns_mktemp_template="$(date +%s)-XXXX"
	fi
	local __ns_mktemp_xcount=
	if which 'mktemp' 1>/dev/null 2>&1
	then
		# Auto-fix template
		__ns_mktemp_xcount=0
		which 'grep' 1>/dev/null 2>&1 \
		&& which 'wc' 1>/dev/null 2>&1 \
		&& __ns_mktemp_xcount=$(grep -o X <<< "${__ns_mktemp_template}" | wc -c)
		while [ ${__ns_mktemp_xcount} -lt 3 ]
		do
			__ns_mktemp_template="${__ns_mktemp_template}X"
			__ns_mktemp_xcount=$(expr ${__ns_mktemp_xcount} + 1)
		done
		mktemp -t "${__ns_mktemp_template}" 2>/dev/null
	else
	local __ns_mktemp_root=
	# Fallback to a manual solution
		for __ns_mktemp_root in "${TMPDIR}" "${TMP}" '/var/tmp' '/tmp'
		do
			[ -d "${__ns_mktemp_root}" ] && break
		done
		[ -d "${__ns_mktemp_root}" ] || return 1
	local __ns_mktemp="/${__ns_mktemp_root}/${__ns_mktemp_template}.$(date +%s)-${RANDOM}"
	touch "${__ns_mktemp}" 1>/dev/null 2>&1 && echo "${__ns_mktemp}"
	fi
}
ns_mktempdir()
{
	local __ns_mktemp_template=
	if [ $# -gt 0 ]
	then
		__ns_mktemp_template="${1}"
		shift
	else
		__ns_mktemp_template="$(date +%s)-XXXX"
	fi
	local __ns_mktemp_xcount=
	if which 'mktemp' 1>/dev/null 2>&1
	then
		# Auto-fix template
		__ns_mktemp_xcount=0
		which 'grep' 1>/dev/null 2>&1 \
		&& which 'wc' 1>/dev/null 2>&1 \
		&& __ns_mktemp_xcount=$(grep -o X <<< "${__ns_mktemp_template}" | wc -c)
		
		while [ ${__ns_mktemp_xcount} -lt 3 ]
		do
			__ns_mktemp_template="${__ns_mktemp_template}X"
			__ns_mktemp_xcount=$(expr ${__ns_mktemp_xcount} + 1)
		done
		mktemp -d -t "${__ns_mktemp_template}" 2>/dev/null
	else
	local __ns_mktemp_root=
	# Fallback to a manual solution
		for __ns_mktemp_root in "${TMPDIR}" "${TMP}" '/var/tmp' '/tmp'
		do
			[ -d "${__ns_mktemp_root}" ] && break
		done
		[ -d "${__ns_mktemp_root}" ] || return 1
	local __ns_mktempdir="/${__ns_mktemp_root}/${__ns_mktemp_template}.$(date +%s)-${RANDOM}"
	mkdir -p "${__ns_mktempdir}" 1>/dev/null 2>&1 && echo "${__ns_mktempdir}"
	fi
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
buildcPopulateXsltprocParams()
{
	# Shared xsltproc options
	buildcXsltprocParams=(--xinclude)
	
	# Prefix
	if [ ! -z "${prefix}" ]
	then
		buildcXsltprocParams=("${buildcXsltprocParams[@]}" \
			--stringparam "prg.c.parser.prefix" "${prefix}")
	fi
	
	if [ "${structNameStyle}" != "none" ]
	then
		buildcXsltprocParams=("${buildcXsltprocParams[@]}" \
			"--stringparam" "prg.c.parser.structNamingStyle" "${structNameStyle}")
	fi
	
	if [ "${functionNameStyle}" != "none" ]
	then
		buildcXsltprocParams=("${buildcXsltprocParams[@]}" \
			"--stringparam" "prg.c.parser.functionNamingStyle" "${functionNameStyle}")
	fi
	
	if [ "${variableNameStyle}" != "none" ]
	then
		buildcXsltprocParams=("${buildcXsltprocParams[@]}" \
		"--stringparam" "prg.c.parser.variableNamingStyle" "${variableNameStyle}")
	fi
}
buildcGenerateBase()
{
	local fileBase="${outputFileBase}"
	local tpl=
	# Check required templates
	for x in parser.generic-header parser.generic-source
	do
		tpl="${buildcXsltPath}/${x}.xsl"
		[ -r "${tpl}" ] || ns_error 2 "Missing XSLT template $(basename "${tpl}")" 
	done
	
	[ "${fileBase}" = '<auto>' ] && fileBase='cmdline-base'
	local outputFileBasePath="${outputPath}/${fileBase}"
	if ! ${outputOverwrite}
	then
		# Check existing files
		for e in h c
		do
			[ -f "${outputFileBasePath}.${e}" ] && ns_error 2 "${fileBase}.${e} already exists. Use --overwrite"
		done
	fi
	
	buildcPopulateXsltprocParams
	
	dummyProgramDefinitionFile="$(ns_mktemp "$(basename "${0}")")"
	
	cat > "${dummyProgramDefinitionFile}" << EOF
<?xml version="1.0" encoding="utf-8"?>
<prg:program xmlns:prg="http://xsd.nore.fr/program" xmlns:xi="http://www.w3.org/2001/XInclude" version="'${programSchemaVersion}'">
	<prg:name>generic</prg:name>
</prg:program>
EOF


	# Header
	xsltproc "${buildcXsltprocParams[@]}" \
		--output "${outputFileBasePath}.h" \
		"${buildcXsltPath}/parser.generic-header.xsl" \
		"${dummyProgramDefinitionFile}" \
	|| ns_error 2 "Failed to generate header file ${outputFileBasePath}.h" 
	
	# Source
	xsltproc "${buildcXsltprocParams[@]}" \
		--output "${outputFileBasePath}.c" \
		--stringparam "prg.c.parser.header.filePath" "${fileBase}.h" \
		"${buildcXsltPath}/parser.generic-source.xsl" \
		"${dummyProgramDefinitionFile}" \
	|| ns_error 2 "Failed to generate source file ${outputFileBasePath}.c"
}
buildcGenerate()
{
	local tpl=
	local fileBase="${outputFileBase}"
	# Check required templates
	for x in parser.header parser.source
	do
		tpl="${buildcXsltPath}/${x}.xsl"
		[ -r "${tpl}" ] || ns_error 2 "Missing XSLT template $(basename "${tpl}")" 
	done
	
	[ "${fileBase}" = '<auto>' ] && fileBase='cmdline'
	local outputFileBasePath="${outputPath}/${fileBase}"
	if ! ${outputOverwrite}
	then
		# Check existing files
		for e in h c
		do
			[ -f "${outputFileBasePath}.${e}" ] && ns_error 2 "${fileBase}.${e} already exists. Use --overwrite"
		done
	fi
	
	buildcPopulateXsltprocParams
	if ! ${generateEmbedded}
	then
		# generateInclude
		buildcXsltprocParams=("${buildcXsltprocParams[@]}" \
		"--stringparam"	"prg.c.parser.nsxmlHeaderPath" "${generateInclude}")
	fi
	
	# Header
	xsltproc "${buildcXsltprocParams[@]}" \
		--output "${outputFileBasePath}.h" \
		"${buildcXsltPath}/parser.header.xsl" \
		"${xmlProgramDescriptionPath}" \
	|| ns_error 2 "Failed to generate header file ${outputFileBasePath}.h" 
	
	xsltproc "${buildcXsltprocParams[@]}" \
		--output "${outputFileBasePath}.c" \
		--stringparam "prg.c.parser.header.filePath" "${fileBase}.h" \
		"${buildcXsltPath}/parser.source.xsl" \
		"${xmlProgramDescriptionPath}" \
	|| ns_error 2 "Failed to generate source file ${outputFileBasePath}.c"
}
scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
scriptName="$(basename "${scriptFilePath}")"
nsPath="$(ns_realpath "$(nsxml_installpath "${scriptPath}/..")")"
programSchemaVersion="2.0"

# Check required programs
for x in xmllint xsltproc
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

chunk_check_nsxml_ns_path || ns_error 1 "Invalid ns-xml ns folder (${nsPath})"

buildcXsltPath="${nsPath}/xsl/program/${programSchemaVersion}/c"
buildcXsltprocParams=''
outputPath="$(ns_realpath "${outputPath}")"

# Modes
if ${generateBaseOnly}
then
	buildcGenerateBase
else
	programSchemaVersion="$(get_program_version "${xmlProgramDescriptionPath}")"
	if ! ${skipValidation} && ! xml_validate "${nsPath}/xsd/program/${programSchemaVersion}/program.xsd" "${xmlProgramDescriptionPath}"
	then
		ns_error 1 "program interface definition schema error - abort"
	fi

	buildcGenerate
fi

exit 0

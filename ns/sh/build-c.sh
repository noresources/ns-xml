#!/usr/bin/env bash
# ####################################
# Copyright © 2012 by Renaud Guillard
#  Distributed under the terms of the BSD License, see LICENSE
# Author: Renaud Guillard
# Version: 1.0
# 
# Create a customized Command line argument parser in C
#
# Program help
usage()
{
cat << EOFUSAGE
build-c: Create a customized Command line argument parser in C
Usage: 
  build-c [[-S] -x <path>] [([-be] -i <path>) -p <...> --struct-style <...> --function-style <...> --variable-style <...>] [[-u] -o <path> -f <...>] [--ns-xml-path <path> --ns-xml-path-relative] [--help]
  With:
    Input
      -x, --xml-description: Program description file
        If the program description file is provided, the xml file will be 
        validated before any XSLT processing
      -S, --skip-validation, --no-validation: Skip XML Schema validations
        The default behavior of the program is to validate the given xml-based 
        file(s) against its/their xml schema (http://xsd.nore.fr/program etc.). 
        This option will disable schema validations
    
    Generation options
      Generation mode
        Select what to generate
        
        -b, --base: Generate ns-xml utility and parser core
        -e, --embed: Generate program parser and embed generic utility and 
        parser core
        -i, --include: Generate program parser and include a pre-genrated 
        utility and parser core
          The namimg styles for variables, structs and functions of the program 
          parser pre-generated files must match
      
      -p, --prefix: Program struct & function names prefix
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
        
        --struct-style, --struct: struct naming convention
          Generate struct names according the given naming convention  
          The argument can be:  
            underscore, camelCase, CamelCase or none
          Default value: none
        --function-style, --function, --func: struct naming convention
          Generate function names according the given naming convention  
          The argument can be:  
            underscore, camelCase, CamelCase or none
          Default value: none
        --variable-style, --variable, --var: Variable naming convention
          Generate variable and enum names according the given naming 
        convention  
          The argument can be:  
            underscore, camelCase, CamelCase or none
          Default value: none
      
    
    Output location
      -o, --output: Output folder path for the generated files
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


parser_required[$(expr ${#parser_required[*]} + ${parser_startindex})]="G_1_g_1_xml-description:--xml-description"
parser_required[$(expr ${#parser_required[*]} + ${parser_startindex})]="G_2_g_1_g:--base, --embed or --include"
parser_required[$(expr ${#parser_required[*]} + ${parser_startindex})]="G_3_g_1_output:--output"
# Switch options

skipValidation=false
generateBaseOnly=false
generateEmbeded=false
outputOverwrite=false
nsxmlPathRelative=false
displayHelp=false
# Single argument options

xmlProgramDescriptionPath=
generateInclude=
prefix=
structNameStyle="none"
functionNameStyle="none"
variableNameStyle="none"
outputPath=
outputFileBase="<auto>"
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
			parser_errors[$(expr ${#parser_errors[*]} + ${parser_startindex})]="Missing required option ${displayPart}"
			c=$(expr ${c} + 1)
		fi
	done
	return ${c}
}
parse_checkminmax()
{
	local errorCount=0
	# Check min argument for multiargument
	
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
	local value
	if [ $# -gt 0 ] && [ ! -z "${1}" ]; then value="${1}"; else return ${PARSER_ERROR}; fi
	shift
	if [ -z "${parser_subcommand}" ]
	then
		parser_errors[$(expr ${#parser_errors[*]} + ${parser_startindex})]="Positional argument not allowed"
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
	if [ -z "${parser_item}" ] || [ "${parser_item:0:1}" != "-" ] || [ "${parser_item}" = "--" ]
	then
		return ${PARSER_SC_SKIP}
	fi
	
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
			parse_setoptionpresence G_5_help
			;;
		xml-description)
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
			
			xmlProgramDescriptionPath="${parser_item}"
			parse_setoptionpresence G_1_g_1_xml-description;parse_setoptionpresence G_1_g
			;;
		skip-validation | no-validation)
			# Group checks
			
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_ERROR}
			fi
			skipValidation=true
			parse_setoptionpresence G_1_g_2_skip-validation;parse_setoptionpresence G_1_g
			;;
		base)
			# Group checks
			
			if ! ([ -z "${generationMode}" ] || [ "${generationMode}" = "generateBaseOnly" ] || [ "${generationMode:0:1}" = "@" ])
			then
				parse_adderror "Another option of the group \"generationMode\" was previously set (${generationMode})"
				return ${PARSER_ERROR}
			fi
			
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_ERROR}
			fi
			generateBaseOnly=true
			generationMode="generateBaseOnly"
			parse_setoptionpresence G_2_g_1_g_1_base;parse_setoptionpresence G_2_g_1_g;parse_setoptionpresence G_2_g
			;;
		embed)
			# Group checks
			
			if ! ([ -z "${generationMode}" ] || [ "${generationMode}" = "generateEmbeded" ] || [ "${generationMode:0:1}" = "@" ])
			then
				parse_adderror "Another option of the group \"generationMode\" was previously set (${generationMode})"
				return ${PARSER_ERROR}
			fi
			
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_ERROR}
			fi
			generateEmbeded=true
			generationMode="generateEmbeded"
			parse_setoptionpresence G_2_g_1_g_2_embed;parse_setoptionpresence G_2_g_1_g;parse_setoptionpresence G_2_g
			;;
		include)
			# Group checks
			
			if ! ([ -z "${generationMode}" ] || [ "${generationMode}" = "generateInclude" ] || [ "${generationMode:0:1}" = "@" ])
			then
				parse_adderror "Another option of the group \"generationMode\" was previously set (${generationMode})"
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
			
			if [ -a "${parser_item}" ] && ! ([ -f "${parser_item}" ])
			then
				parse_adderror "Invalid patn type for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			generateInclude="${parser_item}"
			generationMode="generateInclude"
			parse_setoptionpresence G_2_g_1_g_3_include;parse_setoptionpresence G_2_g_1_g;parse_setoptionpresence G_2_g
			;;
		prefix)
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
			prefix="${parser_item}"
			parse_setoptionpresence G_2_g_2_prefix;parse_setoptionpresence G_2_g
			;;
		struct-style | struct)
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
			structNameStyle="${parser_item}"
			parse_setoptionpresence G_2_g_3_g_1_struct-style;parse_setoptionpresence G_2_g_3_g;parse_setoptionpresence G_2_g
			;;
		function-style | function | func)
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
			functionNameStyle="${parser_item}"
			parse_setoptionpresence G_2_g_3_g_2_function-style;parse_setoptionpresence G_2_g_3_g;parse_setoptionpresence G_2_g
			;;
		variable-style | variable | var)
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
			variableNameStyle="${parser_item}"
			parse_setoptionpresence G_2_g_3_g_3_variable-style;parse_setoptionpresence G_2_g_3_g;parse_setoptionpresence G_2_g
			;;
		output)
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
			
			outputPath="${parser_item}"
			parse_setoptionpresence G_3_g_1_output;parse_setoptionpresence G_3_g
			;;
		file-base | file)
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
			outputFileBase="${parser_item}"
			parse_setoptionpresence G_3_g_2_file-base;parse_setoptionpresence G_3_g
			;;
		overwrite | force)
			# Group checks
			
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_ERROR}
			fi
			outputOverwrite=true
			parse_setoptionpresence G_3_g_3_overwrite;parse_setoptionpresence G_3_g
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
			parse_setoptionpresence G_4_g_1_ns-xml-path;parse_setoptionpresence G_4_g
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
			parse_setoptionpresence G_4_g_2_ns-xml-path-relative;parse_setoptionpresence G_4_g
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
			
			xmlProgramDescriptionPath="${parser_item}"
			parse_setoptionpresence G_1_g_1_xml-description;parse_setoptionpresence G_1_g
			;;
		S)
			# Group checks
			
			skipValidation=true
			parse_setoptionpresence G_1_g_2_skip-validation;parse_setoptionpresence G_1_g
			;;
		b)
			# Group checks
			
			if ! ([ -z "${generationMode}" ] || [ "${generationMode}" = "generateBaseOnly" ] || [ "${generationMode:0:1}" = "@" ])
			then
				parse_adderror "Another option of the group \"generationMode\" was previously set (${generationMode})"
				return ${PARSER_ERROR}
			fi
			
			generateBaseOnly=true
			generationMode="generateBaseOnly"
			parse_setoptionpresence G_2_g_1_g_1_base;parse_setoptionpresence G_2_g_1_g;parse_setoptionpresence G_2_g
			;;
		e)
			# Group checks
			
			if ! ([ -z "${generationMode}" ] || [ "${generationMode}" = "generateEmbeded" ] || [ "${generationMode:0:1}" = "@" ])
			then
				parse_adderror "Another option of the group \"generationMode\" was previously set (${generationMode})"
				return ${PARSER_ERROR}
			fi
			
			generateEmbeded=true
			generationMode="generateEmbeded"
			parse_setoptionpresence G_2_g_1_g_2_embed;parse_setoptionpresence G_2_g_1_g;parse_setoptionpresence G_2_g
			;;
		i)
			# Group checks
			
			if ! ([ -z "${generationMode}" ] || [ "${generationMode}" = "generateInclude" ] || [ "${generationMode:0:1}" = "@" ])
			then
				parse_adderror "Another option of the group \"generationMode\" was previously set (${generationMode})"
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
			
			if [ -a "${parser_item}" ] && ! ([ -f "${parser_item}" ])
			then
				parse_adderror "Invalid patn type for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			generateInclude="${parser_item}"
			generationMode="generateInclude"
			parse_setoptionpresence G_2_g_1_g_3_include;parse_setoptionpresence G_2_g_1_g;parse_setoptionpresence G_2_g
			;;
		p)
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
			prefix="${parser_item}"
			parse_setoptionpresence G_2_g_2_prefix;parse_setoptionpresence G_2_g
			;;
		o)
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
			
			outputPath="${parser_item}"
			parse_setoptionpresence G_3_g_1_output;parse_setoptionpresence G_3_g
			;;
		f)
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
			outputFileBase="${parser_item}"
			parse_setoptionpresence G_3_g_2_file-base;parse_setoptionpresence G_3_g
			;;
		u)
			# Group checks
			
			outputOverwrite=true
			parse_setoptionpresence G_3_g_3_overwrite;parse_setoptionpresence G_3_g
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
	local path
	if [ $# -gt 0 ]
	then
		path="${1}"
		shift
	fi
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
ns_mktemp()
{
	local key
	if [ $# -gt 0 ]
	then
		key="${1}"
		shift
	else
		key="
		$(date +%s)
		        "
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
		key="
		$(date +%s)
		        "
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
error()
{
	local errno
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
function buildcPopulateXsltprocParams()
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

function buildcGenerateBase()
{
	# Check required templates
	for x in parser.generic-header parser.generic-source
	do
		local tpl="${buildcXsltPath}/${x}.xsl"
		[ -r "${tpl}" ] || error 2 "Missing XSLT template $(basename "${tpl}")" 
	done
	
	local fileBase="${outputFileBase}"
	if [ "${fileBase}" = "<auto>" ]
	then
		fileBase="cmdline-base"
	fi
		
	local outputFileBasePath="${outputPath}/${fileBase}"
	if ! ${outputOverwrite}
	then
		# Check existing files
		for e in h c
		do
			[ -f "${outputFileBasePath}.${e}" ] && error 2 "${fileBase}.${e} already exists. Use --overwrite"
		done
	fi
	
	buildcPopulateXsltprocParams
	
	# Header
	if ! xsltproc "${buildcXsltprocParams[@]}" \
			--output "${outputFileBasePath}.h" \
			"${buildcXsltPath}/parser.generic-header.xsl" \
			"${xmlProgramDescriptionPath}"
	then
		error 2 "Failed to generate header file ${outputFileBasePath}.h" 
	fi
	
	if ! xsltproc "${buildcXsltprocParams[@]}" \
			--output "${outputFileBasePath}.c" \
			"${buildcXsltPath}/parser.generic-source.xsl" \
			"${xmlProgramDescriptionPath}"
	then
		error 2 "Failed to generate source file ${outputFileBasePath}.c" 
	fi
}

function buildcGenerate()
{
	# Check required templates
	for x in parser.header parser.source
	do
		local tpl="${buildcXsltPath}/${x}.xsl"
		[ -r "${tpl}" ] || error 2 "Missing XSLT template $(basename "${tpl}")" 
	done
	
	local fileBase="${outputFileBase}"
	if [ "${fileBase}" = "<auto>" ]
	then
		fileBase="cmdline"
	fi
		
	local outputFileBasePath="${outputPath}/${fileBase}"
	if ! ${outputOverwrite}
	then
		# Check existing files
		for e in h c
		do
			[ -f "${outputFileBasePath}.${e}" ] && error 2 "${fileBase}.${e} already exists. Use --overwrite"
		done
	fi
	
	buildcPopulateXsltprocParams
	if ! ${generateEmbeded}
	then
		buildcXsltprocParams=("${buildcXsltprocParams[@]}" \
		"--stringparam"	"prg.c.parser.nsxmlHeaderPath" "${generateInclude}")
	fi
	
	# Header
	if ! xsltproc "${buildcXsltprocParams[@]}" \
			--output "${outputFileBasePath}.h" \
			"${buildcXsltPath}/parser.header.xsl" \
			"${xmlProgramDescriptionPath}"
	then
		error 2 "Failed to generate header file ${outputFileBasePath}.h" 
	fi
	
	if ! xsltproc "${buildcXsltprocParams[@]}" \
			--output "${outputFileBasePath}.c" \
			--stringparam "prg.c.parser.header.filePath" "${fileBase}.h" \
			"${buildcXsltPath}/parser.source.xsl" \
			"${xmlProgramDescriptionPath}"
	then
		error 2 "Failed to generate source file ${outputFileBasePath}.c" 
	fi
}

scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
scriptName="$(basename "${scriptFilePath}")"
nsPath="$(ns_realpath "${scriptPath}/../..")/ns"
programVersion="2.0"

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

chunk_check_nsxml_ns_path || error 1 "Invalid ns-xml ns folder (${nsPath})"

if ! ${skipValidation} && ! xml_validate "${nsPath}/xsd/program/${programVersion}/program.xsd" "${xmlProgramDescriptionPath}"
then
	error 1 "program interface definition schema error - abort"
fi

programVersion="$(get_program_version "${xmlProgramDescriptionPath}")"
buildcXsltPath="${nsPath}/xsl/program/${programVersion}/c"
buildcXsltprocParams=""
outputPath="$(ns_realpath "${outputPath}")"

# Modes
if ${generateBaseOnly}
then
	buildcGenerateBase
else
	buildcGenerate
fi

exit 0
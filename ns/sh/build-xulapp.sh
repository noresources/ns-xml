#!/usr/bin/env bash
# ####################################
# Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr)
# Distributed under the terms of the MIT License, see LICENSE
# Author: Renaud Guillard
# Version: 2.0
# 
# Build (or update) a XUL application launcher
#
# Program help
usage()
{
if [ ! -z "${1}" ]
then
case "${1}" in
php)
cat << EOFSCUSAGE
php: Build a Command line interface PHP script and its XUL application
Usage: build-xulapp php [-s <path>] [--parser-namespace <...>] [--program-namespace <...>] [-c <...>]
With:
  -s, --script: Script to build
  --parser-namespace, --parser-ns: PHP parser namespace
    Namespace of all elements of the ns-xml PHP parser
  --program-namespace, --program-ns, --prg-ns: PHP program namespace
  -c, --classname: Program info class name
EOFSCUSAGE
;;
xsh | sh | shell)
cat << EOFSCUSAGE
xsh: Build a XUL application which will run a Shell script defined through the bash XML schema
Usage: build-xulapp xsh [-p] -s <path> [(-i <...> | -I <...>)]
With:
  -s, --shell: XML shell file
    A XML file following the bash XML schema
    The file may include a program interface XML definition
  -p, --prefix-sc-variables: Prefix subcommand options bound variable names
    This will prefix all subcommand options bound variable name by the 
    subcommand name (sc_varianbleNmae). This avoid variable name aliasing.
  Default interpreter
    -i, --interpreter: Default shell interpreter type
      The interpreter family to use if the XSH file does not define one.
        Attention: This parameter is only available for XSH file using the 
        XSH XML schema (http://xsd.nore.fr/xsh). The old 
        http://xsd.nore.fr/bash XSD schema is not supported.  
      The argument can be:  
        bash, zsh or ksh
    -I, --interpreter-cmd: Default shell interpreter invocation directive
      This value if used if the XSH file does not define one  
      The argument can be:  
        /usr/bin/env bash, /bin/bash, /usr/bin/env zsh or /bin/zsh
EOFSCUSAGE
;;
python | py)
cat << EOFSCUSAGE
python: Build a XUL application which will run a python script built with the program XML schema
Usage: build-xulapp python -p <path> [-m <...>]
With:
  -p, --python: Python script path
    Location of the Python script body. The parser module will be created at 
    the same place
  -m, --module-name, --module: Python module name
    Set the name of the command line parser python module  
    Default value: Program
EOFSCUSAGE
;;
command | cmd)
cat << EOFSCUSAGE
command: Build a XUL application which will run an existing command
Usage: build-xulapp command -c <...>
With:
  -c, --command, --cmd: Launch the given existing command
EOFSCUSAGE
;;

esac
return 0
fi
cat << EOFUSAGE
build-xulapp: Build (or update) a XUL application launcher
Usage: 
  build-xulapp <subcommand [subcommand option(s)]> [-uS] [--help] -o <path> [-x <path>] [-t <...>] [[-d] -W <number> -H <number>] [-j <path> --resources <path [ ... ]>] [[-n] --ns-xml-path <path> --ns-xml-path-relative]
  With subcommand:
    php: Build a Command line interface PHP script and its XUL application
      options: [-s <path>] [--parser-namespace <...>] [--program-namespace <...>] [-c <...>]
    xsh, sh, shell: Build a XUL application which will run a Shell script defined through the bash XML schema
      options: [-p] -s <path> [(-i <...> | -I <...>)]
    python, py: Build a XUL application which will run a python script built with the program XML schema
      options: -p <path> [-m <...>]
    command, cmd: Build a XUL application which will run an existing command
      options: -c <...>
  With global options:
    --help: Display program usage
    -o, --output: Output folder path for the XUL application structure
    -x, --xml-description: Program interface definition file
      Location of the XML program description file. Expect a valid XML file 
      following the http://xsd.nore.fr/program schema
    -t, --target-platform, --target: Target platform  
      The argument value have to be one of the following:  
        host, linux or macosx
      Default value: host
    -u, --update: Update application if folder already exists
    -S, --skip-validation, --no-validation: Skip XML Schema validations
      The default behavior of the program is to validate the given xml-based 
      file(s) against its/their xml schema (http://xsd.nore.fr/program etc.). 
      This option will disable schema validations
    User interface
      -W, --window-width: Window width
        Force the application main window witdh  
        Default value: 1024
      -H, --window-height: Window height
        Force the application main window height  
        Default value: 768
      -d, --debug: Add debug console and options into the built interface
    
    User data
      -j, --init-script: User-defined post-initialization script
        A Javascript file loaded after the main ui object initialization stage
        If a onInitialize() function is available, it will be called with the 
        main ui object as the first argument
        The script is copied in the chrome/content directory and is available 
        through the following url
          chrome://<xulAppName>/content/<xulAppName>-user.js
      --resources: Additional resources
        A list of path or file to add in the application bundle.
        These items are copied in the chrome/userdata folder of the application 
        bundle and a new resource url is avalailable (resource://userdata/...)
    
    ns-xml options
      --ns-xml-path: ns-xml source path
        Location of the ns folder of ns-xml package
      --ns-xml-path-relative: ns source path is relative this program path
      -n, --ns, --ns-xml-add: Add ns-xml sources into application resources
        Include the ns-xml library files (python, sh, xsl and xsd folders) in 
        the XUL application bundle.
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

parser_required[$(expr ${#parser_required[*]} + ${parser_startindex})]="G_2_output:--output"
# Switch options
xsh_prefixSubcommandBoundVariableName=false
displayHelp=false
update=false
skipValidation=false
debugMode=false
nsxmlPathRelative=false
addNsXml=false
# Single argument options
php_scriptPath=
php_parserNamespace=
php_programNamespace=
php_programInfoClassname=
xsh_xmlShellFileDescriptionPath=
xsh_defaultInterpreterType=
xsh_defaultInterpreterCommand=
python_pythonScriptPath=
python_moduleName=
command_existingCommandPath=
outputPath=
xmlProgramDescriptionPath=
targetPlatform=
windowWidth=
windowHeight=
userInitializationScript=
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
parse_setdefaultarguments()
{
	local parser_set_default=false
	# python_moduleName
	if [ -z "${python_moduleName}" ]
	then
		parser_set_default=true
		if ${parser_set_default}
		then
			python_moduleName="Program"
			parse_setoptionpresence SC_3_python_2_module-name
		fi
	fi
	# targetPlatform
	if [ -z "${targetPlatform}" ]
	then
		parser_set_default=true
		if ${parser_set_default}
		then
			targetPlatform="host"
			parse_setoptionpresence G_4_target-platform
		fi
	fi
	# windowWidth
	if [ -z "${windowWidth}" ]
	then
		parser_set_default=true
		if ${parser_set_default}
		then
			windowWidth="1024"
			parse_setoptionpresence G_7_g_1_window-width;parse_setoptionpresence G_7_g
		fi
	fi
	# windowHeight
	if [ -z "${windowHeight}" ]
	then
		parser_set_default=true
		if ${parser_set_default}
		then
			windowHeight="768"
			parse_setoptionpresence G_7_g_2_window-height;parse_setoptionpresence G_7_g
		fi
	fi
	case "${parser_subcommand}" in
	php)
		;;
	xsh | sh | shell)
		;;
	python | py)
		# python_moduleName
		if [ -z "${python_moduleName}" ]
		then
			parser_set_default=true
			if ${parser_set_default}
			then
				python_moduleName="Program"
				parse_setoptionpresence SC_3_python_2_module-name
			fi
		fi
		
		;;
	command | cmd)
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
		php)
			parser_errors[$(expr ${#parser_errors[*]} + ${parser_startindex})]="Positional argument not allowed in subcommand php"
			return ${PARSER_ERROR}
			;;
		xsh)
			parser_errors[$(expr ${#parser_errors[*]} + ${parser_startindex})]="Positional argument not allowed in subcommand xsh"
			return ${PARSER_ERROR}
			;;
		python)
			parser_errors[$(expr ${#parser_errors[*]} + ${parser_startindex})]="Positional argument not allowed in subcommand python"
			return ${PARSER_ERROR}
			;;
		command)
			parser_errors[$(expr ${#parser_errors[*]} + ${parser_startindex})]="Positional argument not allowed in subcommand command"
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
	local parser_integer
	local parser_decimal
	parser_item="${parser_input[${parser_index}]}"
	if [ -z "${parser_item}" ] || [ "${parser_item:0:1}" != "-" ] || [ "${parser_item}" = "--" ]
	then
		return ${PARSER_SC_SKIP}
	fi
	
	case "${parser_subcommand}" in
	php)
		if [ "${parser_item:0:2}" = "--" ] 
		then
			parser_option="${parser_item:2}"
			if echo "${parser_option}" | grep "=" 1>/dev/null 2>&1
			then
				parser_optiontail="$(echo "${parser_option}" | cut -f 2- -d"=")"
				parser_option="$(echo "${parser_option}" | cut -f 1 -d"=")"
			fi
			
			case "${parser_option}" in
			script)
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
				
				if ! parse_pathaccesscheck "${parser_item}" "r"
				then
					parse_adderror "Invalid path permissions for \"${parser_item}\", r privilege(s) expected for option \"${parser_option}\""
					return ${PARSER_SC_ERROR}
				fi
				
				if [ -a "${parser_item}" ] && ! ([ -f "${parser_item}" ])
				then
					parse_adderror "Invalid patn type for option \"${parser_option}\""
					return ${PARSER_SC_ERROR}
				fi
				
				php_scriptPath="${parser_item}"
				parse_setoptionpresence SC_1_php_1_script
				;;
			parser-namespace | parser-ns)
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
				php_parserNamespace="${parser_item}"
				parse_setoptionpresence SC_1_php_2_parser-namespace
				;;
			program-namespace | program-ns | prg-ns)
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
				php_programNamespace="${parser_item}"
				parse_setoptionpresence SC_1_php_3_program-namespace
				;;
			classname)
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
				php_programInfoClassname="${parser_item}"
				parse_setoptionpresence SC_1_php_4_classname
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
			s)
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
				
				if ! parse_pathaccesscheck "${parser_item}" "r"
				then
					parse_adderror "Invalid path permissions for \"${parser_item}\", r privilege(s) expected for option \"${parser_option}\""
					return ${PARSER_SC_ERROR}
				fi
				
				if [ -a "${parser_item}" ] && ! ([ -f "${parser_item}" ])
				then
					parse_adderror "Invalid patn type for option \"${parser_option}\""
					return ${PARSER_SC_ERROR}
				fi
				
				php_scriptPath="${parser_item}"
				parse_setoptionpresence SC_1_php_1_script
				;;
			c)
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
				php_programInfoClassname="${parser_item}"
				parse_setoptionpresence SC_1_php_4_classname
				;;
			*)
				return ${PARSER_SC_SKIP}
				;;
			
			esac
		fi
		;;
	xsh)
		if [ "${parser_item:0:2}" = "--" ] 
		then
			parser_option="${parser_item:2}"
			if echo "${parser_option}" | grep "=" 1>/dev/null 2>&1
			then
				parser_optiontail="$(echo "${parser_option}" | cut -f 2- -d"=")"
				parser_option="$(echo "${parser_option}" | cut -f 1 -d"=")"
			fi
			
			case "${parser_option}" in
			shell)
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
				
				if [ -a "${parser_item}" ] && ! ([ -f "${parser_item}" ])
				then
					parse_adderror "Invalid patn type for option \"${parser_option}\""
					return ${PARSER_SC_ERROR}
				fi
				
				xsh_xmlShellFileDescriptionPath="${parser_item}"
				parse_setoptionpresence SC_2_xsh_1_shell
				;;
			prefix-sc-variables)
				if [ ! -z "${parser_optiontail}" ]
				then
					parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
					parser_optiontail=""
					return ${PARSER_SC_ERROR}
				fi
				xsh_prefixSubcommandBoundVariableName=true
				parse_setoptionpresence SC_2_xsh_2_prefix-sc-variables
				;;
			interpreter)
				# Group checks
				if ! ([ -z "${xsh_defaultInterpreter}" ] || [ "${xsh_defaultInterpreter}" = "defaultInterpreterType" ] || [ "${xsh_defaultInterpreter:0:1}" = "@" ])
				then
					parse_adderror "Another option of the group \"defaultInterpreter\" was previously set (${xsh_defaultInterpreter})"
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
					
					return ${PARSER_SC_ERROR}
				fi
				
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
				xsh_defaultInterpreterType="${parser_item}"
				xsh_defaultInterpreter="defaultInterpreterType"
				parse_setoptionpresence SC_2_xsh_3_g_1_interpreter;parse_setoptionpresence SC_2_xsh_3_g
				;;
			interpreter-cmd)
				# Group checks
				if ! ([ -z "${xsh_defaultInterpreter}" ] || [ "${xsh_defaultInterpreter}" = "defaultInterpreterCommand" ] || [ "${xsh_defaultInterpreter:0:1}" = "@" ])
				then
					parse_adderror "Another option of the group \"defaultInterpreter\" was previously set (${xsh_defaultInterpreter})"
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
					
					return ${PARSER_SC_ERROR}
				fi
				
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
				xsh_defaultInterpreterCommand="${parser_item}"
				xsh_defaultInterpreter="defaultInterpreterCommand"
				parse_setoptionpresence SC_2_xsh_3_g_2_interpreter-cmd;parse_setoptionpresence SC_2_xsh_3_g
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
			s)
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
				
				if [ -a "${parser_item}" ] && ! ([ -f "${parser_item}" ])
				then
					parse_adderror "Invalid patn type for option \"${parser_option}\""
					return ${PARSER_SC_ERROR}
				fi
				
				xsh_xmlShellFileDescriptionPath="${parser_item}"
				parse_setoptionpresence SC_2_xsh_1_shell
				;;
			p)
				xsh_prefixSubcommandBoundVariableName=true
				parse_setoptionpresence SC_2_xsh_2_prefix-sc-variables
				;;
			i)
				# Group checks
				if ! ([ -z "${xsh_defaultInterpreter}" ] || [ "${xsh_defaultInterpreter}" = "defaultInterpreterType" ] || [ "${xsh_defaultInterpreter:0:1}" = "@" ])
				then
					parse_adderror "Another option of the group \"defaultInterpreter\" was previously set (${xsh_defaultInterpreter})"
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
					
					return ${PARSER_SC_ERROR}
				fi
				
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
				xsh_defaultInterpreterType="${parser_item}"
				xsh_defaultInterpreter="defaultInterpreterType"
				parse_setoptionpresence SC_2_xsh_3_g_1_interpreter;parse_setoptionpresence SC_2_xsh_3_g
				;;
			I)
				# Group checks
				if ! ([ -z "${xsh_defaultInterpreter}" ] || [ "${xsh_defaultInterpreter}" = "defaultInterpreterCommand" ] || [ "${xsh_defaultInterpreter:0:1}" = "@" ])
				then
					parse_adderror "Another option of the group \"defaultInterpreter\" was previously set (${xsh_defaultInterpreter})"
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
					
					return ${PARSER_SC_ERROR}
				fi
				
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
				xsh_defaultInterpreterCommand="${parser_item}"
				xsh_defaultInterpreter="defaultInterpreterCommand"
				parse_setoptionpresence SC_2_xsh_3_g_2_interpreter-cmd;parse_setoptionpresence SC_2_xsh_3_g
				;;
			*)
				return ${PARSER_SC_SKIP}
				;;
			
			esac
		fi
		;;
	python)
		if [ "${parser_item:0:2}" = "--" ] 
		then
			parser_option="${parser_item:2}"
			if echo "${parser_option}" | grep "=" 1>/dev/null 2>&1
			then
				parser_optiontail="$(echo "${parser_option}" | cut -f 2- -d"=")"
				parser_option="$(echo "${parser_option}" | cut -f 1 -d"=")"
			fi
			
			case "${parser_option}" in
			python)
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
				
				if [ -a "${parser_item}" ] && ! ([ -f "${parser_item}" ])
				then
					parse_adderror "Invalid patn type for option \"${parser_option}\""
					return ${PARSER_SC_ERROR}
				fi
				
				python_pythonScriptPath="${parser_item}"
				parse_setoptionpresence SC_3_python_1_python
				;;
			module-name | module)
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
				python_moduleName="${parser_item}"
				parse_setoptionpresence SC_3_python_2_module-name
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
				
				if [ -a "${parser_item}" ] && ! ([ -f "${parser_item}" ])
				then
					parse_adderror "Invalid patn type for option \"${parser_option}\""
					return ${PARSER_SC_ERROR}
				fi
				
				python_pythonScriptPath="${parser_item}"
				parse_setoptionpresence SC_3_python_1_python
				;;
			m)
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
				python_moduleName="${parser_item}"
				parse_setoptionpresence SC_3_python_2_module-name
				;;
			*)
				return ${PARSER_SC_SKIP}
				;;
			
			esac
		fi
		;;
	command)
		if [ "${parser_item:0:2}" = "--" ] 
		then
			parser_option="${parser_item:2}"
			if echo "${parser_option}" | grep "=" 1>/dev/null 2>&1
			then
				parser_optiontail="$(echo "${parser_option}" | cut -f 2- -d"=")"
				parser_option="$(echo "${parser_option}" | cut -f 1 -d"=")"
			fi
			
			case "${parser_option}" in
			command | cmd)
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
				command_existingCommandPath="${parser_item}"
				parse_setoptionpresence SC_4_command_1_command
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
			c)
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
				command_existingCommandPath="${parser_item}"
				parse_setoptionpresence SC_4_command_1_command
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
	local parser_integer
	local parser_decimal
	if [ ! -z "${parser_subcommand}" ] && [ "${parser_item}" != "--" ]
	then
		if parse_process_subcommand_option
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
			parse_setoptionpresence G_2_output
			;;
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
			parse_setoptionpresence G_3_xml-description
			;;
		target-platform | target)
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
			if ! ([ "${parser_item}" = "host" ] || [ "${parser_item}" = "linux" ] || [ "${parser_item}" = "macosx" ])
			then
				parse_adderror "Invalid value for option \"${parser_option}\""
				
				return ${PARSER_ERROR}
			fi
			targetPlatform="${parser_item}"
			parse_setoptionpresence G_4_target-platform
			;;
		update)
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_ERROR}
			fi
			update=true
			parse_setoptionpresence G_5_update
			;;
		skip-validation | no-validation)
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_ERROR}
			fi
			skipValidation=true
			parse_setoptionpresence G_6_skip-validation
			;;
		window-width)
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
			if ! echo -n "${parser_item}" | grep -E "\-?[0-9]+(\.[0-9]+)*" 1>/dev/null 2>&1
			then
				parse_adderror "Invalid value \"${parser_item}\" for option \"${parser_option}\". Number expected"
				return ${PARSER_ERROR}
			else
				if ! parse_numberlesserequalcheck 50 ${parser_item}
				then
					parse_adderror "Invalid value \"${parser_item}\" for option \"${parser_option}\". Number expected"
					return ${PARSER_ERROR}
				fi
				if ! parse_numberlesserequalcheck ${parser_item} 2048
				then
					parse_adderror "Invalid value \"${parser_item}\" for option \"${parser_option}\". Number expected"
					return ${PARSER_ERROR}
				fi
			fi
			
			windowWidth="${parser_item}"
			parse_setoptionpresence G_7_g_1_window-width;parse_setoptionpresence G_7_g
			;;
		window-height)
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
			if ! echo -n "${parser_item}" | grep -E "\-?[0-9]+(\.[0-9]+)*" 1>/dev/null 2>&1
			then
				parse_adderror "Invalid value \"${parser_item}\" for option \"${parser_option}\". Number expected"
				return ${PARSER_ERROR}
			else
				if ! parse_numberlesserequalcheck 50 ${parser_item}
				then
					parse_adderror "Invalid value \"${parser_item}\" for option \"${parser_option}\". Number expected"
					return ${PARSER_ERROR}
				fi
				if ! parse_numberlesserequalcheck ${parser_item} 2048
				then
					parse_adderror "Invalid value \"${parser_item}\" for option \"${parser_option}\". Number expected"
					return ${PARSER_ERROR}
				fi
			fi
			
			windowHeight="${parser_item}"
			parse_setoptionpresence G_7_g_2_window-height;parse_setoptionpresence G_7_g
			;;
		debug)
			# Group checks
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_ERROR}
			fi
			debugMode=true
			parse_setoptionpresence G_7_g_3_debug;parse_setoptionpresence G_7_g
			;;
		init-script)
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
			
			userInitializationScript="${parser_item}"
			parse_setoptionpresence G_8_g_1_init-script;parse_setoptionpresence G_8_g
			;;
		resources)
			# Group checks
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			local parser_ma_local_count=0
			local parser_ma_total_count=${#userDataPaths[*]}
			if [ -z "${parser_item}" ]
			then
				if [ ! -e "${parser_item}" ]
				then
					parse_adderror "Invalid path \"${parser_item}\" for option \"${parser_option}\""
					return ${PARSER_ERROR}
				fi
				
				if [ -a "${parser_item}" ] && ! ([ -f "${parser_item}" ] || [ -d "${parser_item}" ])
				then
					parse_adderror "Invalid patn type for option \"${parser_option}\""
					return ${PARSER_ERROR}
				fi
				
				userDataPaths[$(expr ${#userDataPaths[*]} + ${parser_startindex})]="${parser_item}"
				parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
				parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
			fi
			
			local parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
			while [ ! -z "${parser_nextitem}" ] && [ "${parser_nextitem}" != "--" ] && [ ${parser_index} -lt ${parser_itemcount} ]
			do
				if [ ${parser_ma_local_count} -gt 0 ] && [ "${parser_nextitem:0:1}" = "-" ]
				then
					break
				fi
				
				parser_index=$(expr ${parser_index} + 1)
				parser_item="${parser_input[${parser_index}]}"
				[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
				if [ ! -e "${parser_item}" ]
				then
					parse_adderror "Invalid path \"${parser_item}\" for option \"${parser_option}\""
					return ${PARSER_ERROR}
				fi
				
				if [ -a "${parser_item}" ] && ! ([ -f "${parser_item}" ] || [ -d "${parser_item}" ])
				then
					parse_adderror "Invalid patn type for option \"${parser_option}\""
					return ${PARSER_ERROR}
				fi
				
				userDataPaths[$(expr ${#userDataPaths[*]} + ${parser_startindex})]="${parser_item}"
				parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
				parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
				parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
			done
			if [ ${parser_ma_local_count} -eq 0 ]
			then
				parse_adderror "At least one argument expected for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			parse_setoptionpresence G_8_g_2_resources;parse_setoptionpresence G_8_g
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
			parse_setoptionpresence G_9_g_1_ns-xml-path;parse_setoptionpresence G_9_g
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
			parse_setoptionpresence G_9_g_2_ns-xml-path-relative;parse_setoptionpresence G_9_g
			;;
		ns | ns-xml-add)
			# Group checks
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_ERROR}
			fi
			addNsXml=true
			parse_setoptionpresence G_9_g_3_ns;parse_setoptionpresence G_9_g
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
			parse_setoptionpresence G_2_output
			;;
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
			parse_setoptionpresence G_3_xml-description
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
			if ! ([ "${parser_item}" = "host" ] || [ "${parser_item}" = "linux" ] || [ "${parser_item}" = "macosx" ])
			then
				parse_adderror "Invalid value for option \"${parser_option}\""
				
				return ${PARSER_ERROR}
			fi
			targetPlatform="${parser_item}"
			parse_setoptionpresence G_4_target-platform
			;;
		u)
			update=true
			parse_setoptionpresence G_5_update
			;;
		S)
			skipValidation=true
			parse_setoptionpresence G_6_skip-validation
			;;
		W)
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
			if ! echo -n "${parser_item}" | grep -E "\-?[0-9]+(\.[0-9]+)*" 1>/dev/null 2>&1
			then
				parse_adderror "Invalid value \"${parser_item}\" for option \"${parser_option}\". Number expected"
				return ${PARSER_ERROR}
			else
				if ! parse_numberlesserequalcheck 50 ${parser_item}
				then
					parse_adderror "Invalid value \"${parser_item}\" for option \"${parser_option}\". Number expected"
					return ${PARSER_ERROR}
				fi
				if ! parse_numberlesserequalcheck ${parser_item} 2048
				then
					parse_adderror "Invalid value \"${parser_item}\" for option \"${parser_option}\". Number expected"
					return ${PARSER_ERROR}
				fi
			fi
			
			windowWidth="${parser_item}"
			parse_setoptionpresence G_7_g_1_window-width;parse_setoptionpresence G_7_g
			;;
		H)
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
			if ! echo -n "${parser_item}" | grep -E "\-?[0-9]+(\.[0-9]+)*" 1>/dev/null 2>&1
			then
				parse_adderror "Invalid value \"${parser_item}\" for option \"${parser_option}\". Number expected"
				return ${PARSER_ERROR}
			else
				if ! parse_numberlesserequalcheck 50 ${parser_item}
				then
					parse_adderror "Invalid value \"${parser_item}\" for option \"${parser_option}\". Number expected"
					return ${PARSER_ERROR}
				fi
				if ! parse_numberlesserequalcheck ${parser_item} 2048
				then
					parse_adderror "Invalid value \"${parser_item}\" for option \"${parser_option}\". Number expected"
					return ${PARSER_ERROR}
				fi
			fi
			
			windowHeight="${parser_item}"
			parse_setoptionpresence G_7_g_2_window-height;parse_setoptionpresence G_7_g
			;;
		d)
			# Group checks
			debugMode=true
			parse_setoptionpresence G_7_g_3_debug;parse_setoptionpresence G_7_g
			;;
		j)
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
			
			userInitializationScript="${parser_item}"
			parse_setoptionpresence G_8_g_1_init-script;parse_setoptionpresence G_8_g
			;;
		n)
			# Group checks
			addNsXml=true
			parse_setoptionpresence G_9_g_3_ns;parse_setoptionpresence G_9_g
			;;
		*)
			parse_addfatalerror "Unknown option \"${parser_option}\""
			return ${PARSER_ERROR}
			;;
		
		esac
	elif ${parser_subcommand_expected} && [ -z "${parser_subcommand}" ] && [ ${#parser_values[*]} -eq 0 ]
	then
		case "${parser_item}" in
		php)
			parser_subcommand="php"
			;;
		xsh | sh | shell)
			parser_subcommand="xsh"
			parser_required[$(expr ${#parser_required[*]} + ${parser_startindex})]="SC_2_xsh_1_shell:--shell"
			;;
		python | py)
			parser_subcommand="python"
			parser_required[$(expr ${#parser_required[*]} + ${parser_startindex})]="SC_3_python_1_python:--python"
			;;
		command | cmd)
			parser_subcommand="command"
			parser_required[$(expr ${#parser_required[*]} + ${parser_startindex})]="SC_4_command_1_command:--command"
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
log()
{
	echo "${@}" >> "${logFile}"
}
info()
{
	echo "${@}"
	${isDebug} && log "${@}"
}
error()
{
	echo "${@}"
	${isDebug} && log "${@}"
	exit 1
}
build_php()
{
local xmlShellFileDescriptionPath="${php_xmlShellFileDescriptionPath}"

local parserNamespace="${php_parserNamespace}"

local programNamespace="${php_programNamespace}"

local outputScriptFilePath="${commandLauncherFile}"

local generationMode="generateMerge"

local generateBase="false"

local generateInfo="false"

local generateMerge="${php_scriptPath}"
info " - Generate PHP file"
buildphpXsltPath="${nsPath}/xsl/program/${programVersion}/php"

# Check required templates
for x in parser programinfo embed
do
	tpl="${buildphpXsltPath}/${x}.xsl"
	[ -r "${tpl}" ] || error 2 "Missing XSLT template $(basename "${tpl}")" 
done

if ${generateBase}
then
	buildphpXsltStylesheet="parser.xsl"
elif ${generateInfo}
then
	buildphpXsltStylesheet="programinfo.xsl"
else
	# embed or merge
	buildphpXsltStylesheet="embed.xsl"
fi

buildphpXsltprocOptions=(--xinclude)
[ -z "${parserNamespace}" ] || buildphpXsltprocOptions=("${buildphpXsltprocOptions[@]}" --stringparam prg.php.parser.namespace "${parserNamespace}")   
[ -z "${programNamespace}" ] || buildphpXsltprocOptions=("${buildphpXsltprocOptions[@]}" --stringparam prg.php.programinfo.namespace "${programNamespace}")
[ -z "${programInfoClassname}" ] || buildphpXsltprocOptions=("${buildphpXsltprocOptions[@]}" --stringparam prg.php.programinfo.classname "${programInfoClassname}")

buildphpTemporaryOutput="${outputScriptFilePath}"
[ "${generationMode}" = "generateMerge" ] && buildphpTemporaryOutput="$(ns_mktemp build-php-lib)"

buildphpXsltprocOptions=("${buildphpXsltprocOptions[@]}" \
	-o \
	"${buildphpTemporaryOutput}" \
	"${buildphpXsltPath}/${buildphpXsltStylesheet}" \
	"${xmlProgramDescriptionPath}")  

xsltproc "${buildphpXsltprocOptions[@]}" || error 2 "Failed to generate php classes file"

if [ "${generationMode}" = "generateMerge" ]
then
	firstLine=$(head -n 1 "${generateMerge}")
	if [ "${firstLine:0:2}" = "#!" ]
	then
		(echo "${firstLine}" > "${outputScriptFilePath}" \
		&& cat "${buildphpTemporaryOutput}" >> "${outputScriptFilePath}" \
		&& sed 1d "${generateMerge}"  >> "${outputScriptFilePath}") \
		|| error 3 "Failed to merge PHP class file and PHP program file"
	else
		(echo "#!/usr/bin/env php" > "${outputScriptFilePath}" \
		&& cat "${buildphpTemporaryOutput}" >> "${outputScriptFilePath}" \
		&& cat "${generateMerge}"  >> "${outputScriptFilePath}") \
		|| error 3 "Failed to merge PHP class file and PHP program file"
	fi
	
	chmod 755 "${outputScriptFilePath}" || error 4 "Failed to set exeutable flag on ${outputScriptFilePath}" 
fi
return 0

}
build_xsh()
{
	local prefixSubcommandBoundVariableName="${xsh_prefixSubcommandBoundVariableName}"
	
	local xmlShellFileDescriptionPath="${xsh_xmlShellFileDescriptionPath}"
	
	local defaultInterpreterCommand="${xsh_defaultInterpreterCommand}"
	
	local defaultInterpreterType="${xsh_defaultInterpreterType}"
	local xshXslTemplatePath
	
	local outputScriptFilePath="${commandLauncherFile}"
	info " - Generate shell file"
	# Check required XSLT files
	xshXslTemplatePath="${nsPath}/xsl/program/${programVersion}/xsh.xsl"
	if [ ! -f "${xshXslTemplatePath}" ]
	then
	    echo "Missing XSLT stylesheet file \"${xshXslTemplatePath}\""
	    exit 2
	fi
	
	# Validate against bash or xsh schema
	if ! ${skipValidation}
	then
		shSchema="$(xsltproc --xinclude "${nsPath}/xsl/program/${programVersion}/xsh-getschemapath.xsl" "${xmlShellFileDescriptionPath}")"
		if ! xml_validate "${nsPath}/xsd/${shSchema}" "${xmlShellFileDescriptionPath}" 
		then
			echo "bash schema error - abort"
			exit 5
		fi
	fi
	
	# Process xsh file
	xsltprocArgs=(--xinclude)
	if ${debugMode}
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
	
	if [ ! -z "${defaultInterpreterCommand}" ]
	then
		# See ns/xsl/program/*/xsh.xsl
		xsltprocArgs[${#xsltprocArgs[*]}]="--stringparam"
		xsltprocArgs[${#xsltprocArgs[*]}]="prg.xsh.defaultInterpreterCommand"
		xsltprocArgs[${#xsltprocArgs[*]}]="${defaultInterpreterCommand}"
	elif [ ! -z "${defaultInterpreterType}" ]
	then
		# See ns/xsl/languages/xsh.xsl
		xsltprocArgs[${#xsltprocArgs[*]}]="--stringparam"
		xsltprocArgs[${#xsltprocArgs[*]}]="xsh.defaultInterpreterType"
		xsltprocArgs[${#xsltprocArgs[*]}]="${defaultInterpreterType}"
	fi
	
	if ! xsltproc "${xsltprocArgs[@]}" -o "${outputScriptFilePath}" "${xshXslTemplatePath}" "${xmlShellFileDescriptionPath}"
	then
		echo "Fail to process xsh file \"${xmlShellFileDescriptionPath}\""
		exit 6
	fi
	
	chmod 755 "${outputScriptFilePath}"
	return 0
}
build_python()
{
	baseModules=(__init__ Base Info Parser Validators)
	pythonModulePath="${xulScriptBasePath}/${python_moduleName}"
	nsPythonPath="${nsPath}/python/program/${programVersion}"
	
	cp -p "${python_pythonScriptPath}" "${commandLauncherFile}"
	[ -d "${pythonModulePath}" ] && ! ${update} && error "${pythonModulePath} already exists - set --update to overwrite"
	mkdir -p "${pythonModulePath}" || error "Failed to create Python module path ${pythonModulePath}"
	for m in ${baseModules[*]}
	do
		nsPythonFile="${nsPythonPath}/${m}.py"	
		[ -f "${nsPythonFile}" ] || error "Base python module not found (${nsPythonFile})"
		cp -fp "${nsPythonFile}" "${pythonModulePath}"
	done 
	
	# Create the Program module
	xslStyleSheetPath="${nsPath}/xsl/program/${programVersion}"
	if ! xsltproc --xinclude -o "${pythonModulePath}/Program.py" "${xslStyleSheetPath}/py/module.xsl" "${xmlProgramDescriptionPath}"
	then
		error 4 "Failed to create Program module"
	fi
	
	return 0
}
build_command()
{
	info " - Generate command launcher"
	echo -ne "#!/bin/bash\n${command_existingCommandPath} \${@}" > "${commandLauncherFile}"
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

scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
nsPath="$(ns_realpath "${scriptPath}/../..")/ns"
programVersion="2.0"
hostPlatform="linux"
macOSXVersion=""
macOSXFrameworkName="XUL.framework"
macOSXFrameworkPath="/Library/Frameworks/${macOSXFrameworkName}"
firefoxPath="/Applications/Firefox.app"
macOSXMajorVersion=""
macOSXMinorVersion=""
macOSXPatchVersion=""
macOSXArchitecture=""

logFile="/tmp/$(basename "${0}").log"
${isDebug} && echo "$(date): ${0} ${@}" > "${logFile}"

# Check (common) required programs
for x in xmllint xsltproc egrep cut expr head tail uuidgen 
do
	if ! which $x 1>/dev/null 2>&1
	then
		error "${x} program not found"
	fi
done

if [ "$(uname)" == "Darwin" ]
then
	hostPlatform="macosx"
	macOSXVersion="$(sw_vers -productVersion)"
	macOSXMajorVersion="$(echo "${macOSXVersion}" | cut -f 1 -d".")"
	macOSXMinorVersion="$(echo "${macOSXVersion}" | cut -f 2 -d".")"
	macOSXPatchVersion="$(echo "${macOSXVersion}" | cut -f 3 -d".")"
	macOSXArchitecture="$(uname -m)"
fi

defaultWindowWidth=${windowWidth}
defaultWindowHeight=${windowHeight}

if ! parse "${@}"
then
	if ${displayHelp}
	then
		usage ${parser_subcommand}
		exit 0
	fi
	
	parse_displayerrors
	exit 1
fi

if ${displayHelp}
then
	usage ${parser_subcommand}
	exit 0
fi

builderFunction="build_${parser_subcommand}"
if [ "$(type -t ${builderFunction})" != "function" ]
then
	error "Missing subcommand name"
fi

if [ "${targetPlatform}" == "host" ]
then
	targetPlatform="${hostPlatform}"
fi

# Guess ns-xml path
if [ ! -z "${nsxmlPath}" ]
then
	if ${nsxmlPathRelative}
	then
		nsPath="${scriptPath}/${nsxmlPath}"
	else
		nsPath="${nsxmlPath}"
	fi
	
	if [ ! -d "${nsPath}" ]
	then
		error "Invalid ns path \"${nsPath}\""
	fi
	
	nsPath="$(ns_realpath "${nsPath}")"
fi

# find schema version
programVersion="$(xsltproc --xinclude "${nsPath}/xsl/program/get-version.xsl" "${xmlProgramDescriptionPath}")"
info "Program schema version ${programVersion}"

if [ ! -f "${nsPath}/xsd/program/${programVersion}/program.xsd" ]
then
	error "Invalid program interface definition schema version"
fi  

# Check required templates
requiredTemplates="ui-mainwindow js-mainwindow js-application ../get-programinfo"
if [ "${targetPlatform}" == "macosx" ]
then
	requiredTemplates="${requiredTemplates} macosx-plist ui-hiddenwindow"
fi

for template in ${requiredTemplates}
do
	stylesheet="${nsPath}/xsl/program/${programVersion}/xul/${template}.xsl"
	if [ ! -f "${stylesheet}" ]
	then
		error "Missing XSLT stylesheet file \"${stylesheet}\""
	fi
done

# Validate program scheam
if ! ${skipValidation} && ! xml_validate "${nsPath}/xsd/program/${programVersion}/program.xsd" "${xmlProgramDescriptionPath}"
then
	error "program ${programVersion} XML schema error - abort"
fi

programStylesheetPath="${nsPath}/xsl/program/${programVersion}"
programInfoStylesheetPath="${programStylesheetPath}/get-programinfo.xsl"

appName="$(xsltproc --xinclude --stringparam name name "${programInfoStylesheetPath}" "${xmlProgramDescriptionPath}")"
appDisplayName="$(xsltproc --xinclude --stringparam name label "${programInfoStylesheetPath}" "${xmlProgramDescriptionPath}")"
xulAppName="$(echo "${appName}" | sed "s/[^a-zA-Z0-9]//g")"
appAuthor="$(xsltproc --xinclude --stringparam name author "${programInfoStylesheetPath}" "${xmlProgramDescriptionPath}")"
appVersion="$(xsltproc --xinclude --stringparam name version "${programInfoStylesheetPath}" "${xmlProgramDescriptionPath}")"
appUUID="$(uuidgen)"
appBuildID="$(date +%Y%m%d-%s)"

# Append application name to output path (auto)
outputPathBase="$(basename "${outputPath}")"

if [ "${outputPathBase}" != "${appName}" ] && [ "${outputPathBase}" != "${appDisplayName}" ]
then
	if [ "${targetPlatform}" == "macosx" ]
	then
		outputPath="${outputPath}/${appDisplayName}"
	else
		outputPath="${outputPath}/${appName}"
	fi
fi
appRootPath="${outputPath}"

if [ "${targetPlatform}" == "macosx" ]
then
	outputPath="${outputPath}.app"
	appRootPath="${outputPath}/Contents/Resources"

	info "Mac OS X version: ${macOSXVersion}"
	info "Mac OS X architecture: ${macOSXArchitecture}"
fi

# Check output folder
preexistantOutputPath=false
if [ -d "${appRootPath}" ] 
then
	(! ${update}) && error " - Folder \"${appRootPath}\" already exists. Set option --update to force update"
	(${update} && [ ! -f "${appRootPath}/application.ini" ]) && error " - Folder \"${appRootPath}\" exists - update option is set, but the folder doesn't seems to be a valid xul application folder"
	preexistantOutputPath=true
else
	mkdir -p "${outputPath}" || error "Unable to create output path \"${outputPath}\""
	mkdir -p "${appRootPath}" || error "Unable to create application root path \"${appRootPath}\""
fi

outputPath="$(ns_realpath "${outputPath}")"
appRootPath="$(ns_realpath "${appRootPath}")"

appIniFile="${appRootPath}/application.ini"
appPrefFile="${appRootPath}/defaults/preferences/pref.js"
appCssFile="${appRootPath}/chrome/content/${xulAppName}.css"
appMainXulFile="${appRootPath}/chrome/content/${xulAppName}.xul"
appOverlayXulFile="${appRootPath}/chrome/content/${xulAppName}-overlay.xul"
appHiddenWindowXulFile="${appRootPath}/chrome/content/${xulAppName}-hiddenwindow.xul"
xulScriptBasePath="${appRootPath}/sh"

info "XUL application will be built in \"${outputPath}\""

if ${preexistantOutputPath} && ${update}
then
	info " - Application will be updated"
	if egrep "ID=\{[a-fA-F0-9-]*\}" "${appIniFile}" 1>/dev/null 2>&1
	then
		egrep "ID=\{[a-fA-F0-9-]*\}" "${appIniFile}" | sed "s/\([a-fA-F0-9-]*\)/\1/g" 1>/dev/null 2>&1
		appUUID="$(egrep "ID=\{[a-fA-F0-9-]*\}" "${appIniFile}" | cut -f 2 -d"{" | cut -f 1 -d"}")"
		info " - Keep application UUID ${appUUID}"
	fi
fi

mkdir -p "${xulScriptBasePath}" || error "Unable to create shell sub directory"

xulScriptBasePath="$(ns_realpath "${xulScriptBasePath}")"
rebuildScriptFile="${xulScriptBasePath}/_rebuild.sh"
commandLauncherFile="${xulScriptBasePath}/${xulAppName}"
commandLauncherFile="$(ns_realpath "${commandLauncherFile}")"

${builderFunction} || error "Failed to build ${commandLauncherFile}"
chmod 755 "${commandLauncherFile}"

info " - Creating XUL application structure"
for d in "chrome/ns" "chrome/content" "defaults/preferences" "extensions"
do
	mkdir -p "${appRootPath}/${d}" || error "Unable to create \"${d}\""
done

info " - Copy ns-xml required files"
for d in xbl jsm xpcom
do
	rsync -Lprt "${nsPath}/${d}" "${appRootPath}/chrome/ns/"
done

if ${addNsXml}
then
	info " - Copy ns-xml optional files"
	for d in python sh xsh xsl 
	do
		rsync -Lprt "${nsPath}/${d}" "${appRootPath}/chrome/ns/"
	done
fi

info " - Generating manifest"
echo "content ${xulAppName} file:chrome/content/" > "${appRootPath}/chrome.manifest"
echo "resource ns file:chrome/ns/" >> "${appRootPath}/chrome.manifest"
# components
for c in value-autocomplete
do
	f="${nsPath}/xpcom/${c}.js"
	cid="$(cat "${f}" | egrep -h "CLASS_ID[ \t]=" | sed "s/.*('\(.*\)').*/\1/g")"
	contract="$(cat "${f}" | egrep -h "CONTRACT_ID[ \t]=" | sed "s/.*'\(.*\)'.*/\1/g")"
	echo "component {${cid}} chrome/ns/xpcom/${c}.js" >> "${appRootPath}/chrome.manifest"
	echo "contract ${contract} {${cid}}" >> "${appRootPath}/chrome.manifest"  
done 

echo "[App]
Version=${appVersion}
Vender=${appAuthor}
Name=${appDisplayName}
BuildID=${appBuildID}
ID={${appUUID}}
[Gecko]
MinVersion=2.0
MaxVersion=99.0.0" > "${appIniFile}"

echo "pref(\"toolkit.defaultChromeURI\", \"chrome://${xulAppName}/content/${xulAppName}.xul\");" > "${appPrefFile}"

if [ "${targetPlatform}" == "macosx" ]
then
	echo "pref(\"browser.hiddenWindowChromeURL\", \"chrome://${xulAppName}/content/$(basename "${appHiddenWindowXulFile}")\");" >> "${appPrefFile}" 
fi

if ${debugMode}
then
	echo "pref(\"browser.dom.window.dump.enabled\", true);
pref(\"javascript.options.showInConsole\", true);
pref(\"javascript.options.strict\", true);
pref(\"nglayout.debug.disable_xul_cache\", true);
pref(\"nglayout.debug.disable_xul_fastload\", true);" >> "${appPrefFile}"

	# Adding 'rebuild command script"
	# TODO need update for new args
	mkdir -p "$(dirname "${rebuildScriptFile}")"
	echo "#!/bin/bash" > "${rebuildScriptFile}"
	echo -en "$(ns_realpath "${0}") ${parser_subcommand} --update --debug --xml-description \"$(ns_realpath "${xmlProgramDescriptionPath}")\"" >> "${rebuildScriptFile}"
	echo -en " --output \"$(ns_realpath "${outputPath}")\"" >> "${rebuildScriptFile}"
	# TODO 
	if [ "${parser_subcommand}" == "xsh" ]
	then
		echo -en " --shell \"$(ns_realpath "${xsh_xmlShellFileDescriptionPath}")\"" >> "${rebuildScriptFile}"
	elif [ "${parser_subcommand}" == "python" ]
	then
		echo -en " --python \"$(ns_realpath "${python_pythonScriptPath}")\" --module-name ${python_moduleName}" >> "${rebuildScriptFile}"
	elif [ "${parser_subcommand}" == "command" ]
	then
		echo -en " --command \"$(ns_realpath "${existingCommandPath}")\"" >> "${rebuildScriptFile}"
	fi
	
	echo "" >> "${rebuildScriptFile}"
	chmod 755 "${rebuildScriptFile}"
fi

info " - Building UI layout"
#The xul for the main window
xsltOptions="--xinclude --stringparam prg.xul.appName ${xulAppName}"
# Do not force width and height if it was not set by the user
# The XUL XSLT stylesheets are made to use the same default values as build-xulapp 
[ -z "${windowWidth}" ] || [ "${defaultWindowWidth}" = "${windowWidth}" ] || xsltOptions="${xsltOptions} --param prg.xul.windowWidth ${windowWidth}"
[ -z "${windowHeight}" ] || [ "${defaultWindowHeight}" = "${windowHeight}" ] || xsltOptions="${xsltOptions} --param prg.xul.windowHeight ${windowHeight}"
 
xsltOptions="${xsltOptions} --stringparam prg.xul.platform ${targetPlatform}"
 
if ${debugMode}
then
	xsltOptions="${xsltOptions} --param prg.debug \"true()\""
fi

info " -- Main window"
if ! xsltproc ${xsltOptions} -o "${appMainXulFile}" "${programStylesheetPath}/xul/ui-mainwindow.xsl" "${xmlProgramDescriptionPath}"  
then
	error "Error while building XUL main window layout (${appMainXulFile} - ${xsltOptions})"
fi

info " -- Overlay"
if ! xsltproc ${xsltOptions} -o "${appOverlayXulFile}" "${programStylesheetPath}/xul/ui-overlay.xsl" "${xmlProgramDescriptionPath}"  
then
	error "Error while building XUL overlay layout (${appOverlayXulFile} - ${xsltOptions})"
fi

if [ "${targetPlatform}" == "macosx" ]
then
	info " -- Mac OS X hidden window"
	if ! xsltproc ${xsltOptions} -o "${appHiddenWindowXulFile}" "${programStylesheetPath}/xul/ui-hiddenwindow.xsl" "${xmlProgramDescriptionPath}" 
	then
		error "Error while building XUL hidden window layout (${appHiddenWindowXulFile} - ${xsltOptions})"
	fi 
fi

info " - Building CSS stylesheet"
rm -f "${appCssFile}"
for d in "${nsPath}/xbl" "${nsPath}/xbl/program/${programVersion}"
do
	find "${d}" -maxdepth 1 -mindepth 1 -name "*.xbl" | while read f
	do
		b="${f#${nsPath}/xbl/}"
		cssXsltOptions="--xinclude --param resourceURI \"resource://ns/xbl/${b}\""
		if [ ! -f "${appCssFile}" ]
		then
			cssXsltOptions="${cssXsltOptions} --param xbl.css.displayHeader \"true()\""
		fi
		
		info " -- Adding ${f}"
		if ! xsltproc ${cssXsltOptions} "${nsPath}/xsl/languages/xbl-css.xsl" "${f}" >> "${appCssFile}"
		then
			error "Failed to add CSS binding rules for XBL \"${f}\" (${cssXsltOptions})"
		fi
	done 
done

info " - Building Javascript code"
if ! xsltproc ${xsltOptions} -o "${appRootPath}/chrome/content/${xulAppName}.jsm" "${programStylesheetPath}/xul/js-application.xsl" "${xmlProgramDescriptionPath}"  
then
	error "Error while building XUL application code"
fi

if ! xsltproc ${xsltOptions} -o "${appRootPath}/chrome/content/${xulAppName}.js" "${programStylesheetPath}/xul/js-mainwindow.xsl" "${xmlProgramDescriptionPath}"  
then
	error "Error while building XUL main window code"
fi

userInitializationScriptOutputPath="${appRootPath}/chrome/content/${xulAppName}-user.js"
if [ ! -z "${userInitializationScript}" ]
then
	info " - Add user-defined initialization script"
	rsync -Lprt "${userInitializationScript}" "${userInitializationScriptOutputPath}"
	chmod 644 "${userInitializationScriptOutputPath}"
else
	# Remove if any previous script
	[ -r "${userInitializationScriptOutputPath}" ] && rm -f "${userInitializationScriptOutputPath}" 
fi

if [ "${targetPlatform}" == "macosx" ]
then
	info " - Create/Update Mac OS X application bundle structure"
	# Create structure
	mkdir -p "${outputPath}/Contents/MacOS"
	mkdir -p "${outputPath}/Contents/Resources"
	
	info " - Create/Update Mac OS X application property list"
	if ! xsltproc ${xsltOptions} --stringparam prg.xul.buildID "${appBuildID}" -o "${outputPath}/Contents/Info.plist" "${programStylesheetPath}/xul/macosx-plist.xsl" "${xmlProgramDescriptionPath}"  
	then
		error "Error while building XUL main window code"
	fi
fi

info " - Create/Update application launcher"
launcherPath=""
if [ "${targetPlatform}" == "macosx" ]
then
	launcherPath="${outputPath}/Contents/MacOS/xulrunner"
else
	launcherPath="${outputPath}/${appName}"
fi

cat > "${launcherPath}" << EOF
#!/bin/bash
ns_realpath()
{
	local path="\${1}"
	local cwd="\$(pwd)"
	[ -d "\${path}" ] && cd "\${path}" && path="."
	
	# -h : exists and is symlink
	while [ -h "\${path}" ] ; do path="\$(readlink "\${path}")"; done
	
	if [ -d "\${path}" ]
	then
		path="\$(cd -P "\$(dirname "\${path}")" && pwd)"
	else
		path="\$(cd -P "\$(dirname "\${path}")" && pwd)/\$(basename "\${path}")"
	fi
	
	cd "\${cwd}" 1>/dev/null 2>&1
	echo "\${path}"
}
#This variable indicates from which platform this app have been built
buildPlatform="${targetPlatform}"
debug=${debugMode}
platform="linux"
if [ "\$(uname)" == "Darwin" ]
then
	platform="macosx"
fi

scriptPath="\$(ns_realpath "\$(dirname "\${0}")")"
appIniPath="\$(ns_realpath "\${scriptPath}/application.ini")"
logFile="/tmp/${xulAppName}.log"
if [ "\${platform}" == "macosx" ]
then
	appIniPath="\$(ns_realpath "\${scriptPath}/../Resources/application.ini")"
	macOSXArchitecture="\$(uname -m)"
	cmdPrefix=""
	if [ "\${macOSXArchitecture}" = "i386" ]
	then
		cmdPrefix="arch -i386"
	fi
fi

debug()
{
	echo "\${@}"
	[ \${debugMode} ] && echo "\${@}" >> "\${logFile}"
}

[ \${debugMode} ] && echo "\$(date)" > "\${logFile}"
debug "Args: \${@}"

# Trying Xul.framework (Mac OS X)
use_framework()
{	
	debug use_framwork
	local frameworkName="XUL.framework"
	local bundledFrameworkPath="\$(ns_realpath "\${scriptPath}/../Frameworks/\${frameworkName}")"
	local systemFrameworkPathBase="Library/Frameworks/\${frameworkName}"
	minXulFrameworkVersion=4
	for xul in "\${bundledFrameworkPath}" "/\${systemFrameworkPathBase}" "/\${HOME}/\${systemFrameworkPathBase}"
	do
		debug "Check \${xul}"
		if [ -x "\${xul}/xulrunner-bin" ]
		then
			xulFrameworkVersion="\$(readlink "\${xul}/Versions/Current" | cut -f 1 -d.)"
			debug " Version: \${xulFrameworkVersion}"
			if [ \${xulFrameworkVersion} -ge \${minXulFrameworkVersion} ] 
			then
				debug " Using \${xul}"
				xul="\$(ns_realpath "\${xul}/Versions/Current")"
				PATH="\${xul}:\${PATH}"
				debug " PATH: \${PATH}"
				echo \${cmdPrefix} "\${xul}/xulrunner" -app "\${appIniPath}"
				\${cmdPrefix} "\${xul}/xulrunner" -app "\${appIniPath}"
				exit 0
			fi
		fi
	done
	
	return 1
}

# Trying firefox (assumes a version >= 4)
use_firefox()
{
	debug use_firefox
	if [ "\${platform}" == "macosx" ]
	then
		for ff in "/Applications/Firefox.app/Contents/MacOS/firefox-bin" "\${HOME}/Applications/Firefox.app/Contents/MacOS/firefox-bin"
		do
			debug "Check \${ff}" 
			if [ -x "\${ff}" ]
			then
				debug " Using \${ff}" 
				\${cmdPrefix} \${ff} -app "\${appIniPath}"
				exit 0
			fi
		done
	else
		if which firefox 1>/dev/null 2>&1
		then
			firefox -app "\${appIniPath}"
			return 0
		fi
	fi
	
	return 1
}

use_xulrunner()
{
	for x in xulrunner xulrunner-2.0
	do
		if which "\${x}" 1>/dev/null 2>&1
		then
			v="\$(\${x} --gre-version | cut -f 1 -d".")"
			if [ ! -z "\${v}" ] && [ \${v} -ge 2 ]
			then
				"\${x}" "\${appIniPath}"
				return 0
			fi
		fi
	done
	return 1
}

debug "Build platform: \${buildPlatform}"
debug "Platform: \${platform}"
debug "Application: \${appIniPath}"
if [ "\${platform}" == "macosx" ]
then
	use_framework || use_xulrunner || use_firefox
else
	use_firefox || use_xulrunner
fi
EOF
chmod 755 "${launcherPath}"


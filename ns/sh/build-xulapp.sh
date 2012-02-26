#!/bin/bash
# ####################################
# Copyright (c) 2011 by Renaud Guillard (dev@niao.fr)
# Author: Renaud Guillard
# Version: 2.0
# 
# Build (or update) a xul application launcher
#
# Program help
usage()
{
cat << EOFUSAGE
build-xulapp: Build (or update) a xul application launcher
Usage: 
  build-xulapp [-h] -o <path> -x <path> (-s <path> | -c <...>) [-t <...>] [-u] [-W <number> -H <number> -d] [-j <path> --resources <path [ ... ]>] [--ns-xml-path <path> --ns-xml-path-relative --ns-xml-add <...  [ ... ]>]
  With:
    -h, --help: Display the command documentation & options
    -o, --output: Output folder path for the XUL application structure
    -x, --xml-description: Program description file
    Launcher mode
    (
    	-s, --shell: Generated shell script from the given template
    	--command, -c: Launch the given existing command
    )
    --target-platform, --target, -t: Target platform
    	The argument value have to be one of the following:	
    		host, linux or macosx
    -u, --update: Update application if folder already exists
    User interface
    (
    	--window-width, -W: 
    	--window-height, -H: 
    	-d, --debug: Add debug options into the built interface
    )
    User data
    (
    	--init-script, -j: User-defined post-initialization script
    	--resources: Additional resources
    )
    ns-xml options
    (
    	--ns-xml-path: ns-xml source path
    	--ns-xml-path-relative: ns source path is relative this program path
    	--ns-xml-add: Add other ns-xml folder
    		The argument value have to be one of the following:	
    			sh, xsl or xsd
    )
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


parser_required[${#parser_required[*]}]="G_2_output:--output"
parser_required[${#parser_required[*]}]="G_3_xml-description:--xml-description"
parser_required[${#parser_required[*]}]="G_4_g:--shell or --command"
# Switch options

displayHelp=false
update=false
debugMode=false
nsxmlPathRelative=false
# Single argument options

outputPath=
xmlProgramDescriptionPath=
launcherModeXsh=
launcherModeExistingCommand=
targetPlatform="host"
windowWidth=
windowHeight=
userInitializationScript=
nsxmlPath=

parse_addmessage()
{
	local type="${1}"
	local message="${2}"
	local m="[${parser_option}:${parser_index}:${parser_subindex}] ${message}"
	eval "local c=\${#parser_${type}s[*]}"
	c=$(expr ${c} + ${parser_startindex})
	eval "parser_${type}s[${c}]=\"${m}\""
}

parse_addwarning()
{
	parse_addmessage "warning" "${@}"
}
parse_adderror()
{
	parse_addmessage "error" "${@}"
}
parse_addfatalerror()
{
	parse_addmessage "fatalerror" "${@}"
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
			parser_values[${#parser_values[*]}]="${parser_input[${a}]}"
		done
		parser_index=${parser_itemcount}
		return ${PARSER_OK}
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
				return ${PARSER_SC_ERROR}
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
					return ${PARSER_SC_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
			fi
			
			parser_subindex=0
			parser_optiontail=""
			if [ ! -e "${parser_item}" ]
			then
				parse_adderror "Invalid path \"${parser_item}\" for option ${parser_option}"
				return ${PARSER_SC_ERROR}
			fi
			
			if ! ([ -d "${parser_item}" ])
			then
				parse_adderror "Invalid patn type for option ${parser_option}"
				return ${PARSER_SC_ERROR}
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
					return ${PARSER_SC_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
			fi
			
			parser_subindex=0
			parser_optiontail=""
			if [ ! -e "${parser_item}" ]
			then
				parse_adderror "Invalid path \"${parser_item}\" for option ${parser_option}"
				return ${PARSER_SC_ERROR}
			fi
			
			if ! ([ -f "${parser_item}" ])
			then
				parse_adderror "Invalid patn type for option ${parser_option}"
				return ${PARSER_SC_ERROR}
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
					return ${PARSER_SC_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
			fi
			
			parser_subindex=0
			parser_optiontail=""
			if ! ([ "${parser_item}" = "host" ] || [ "${parser_item}" = "linux" ] || [ "${parser_item}" = "macosx" ])
			then
				parse_adderror "Invalid value for option \"${parser_item}\""
				
				return ${PARSER_SC_ERROR}
			fi
			targetPlatform="${parser_item}"
			parse_setoptionpresence G_5_target-platform
			;;
		update)
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_SC_ERROR}
			fi
			update=true
			parse_setoptionpresence G_6_update
			;;
		shell)
			# Group checks
			
			if ! ([ -z "${launcherMode}" ] || [ "${launcherMode}" = "${launcherModeXsh}" ] || [ "${launcherMode:0:1}" = "@" ])
			then
				parse_adderror "Another option of the group \"launcherMode\" was previously set (${launcherMode})"
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
			fi
			
			parser_subindex=0
			parser_optiontail=""
			if [ ! -e "${parser_item}" ]
			then
				parse_adderror "Invalid path \"${parser_item}\" for option ${parser_option}"
				return ${PARSER_SC_ERROR}
			fi
			
			if ! ([ -f "${parser_item}" ])
			then
				parse_adderror "Invalid patn type for option ${parser_option}"
				return ${PARSER_SC_ERROR}
			fi
			
			launcherModeXsh="${parser_item}"
			launcherMode="launcherModeXsh"
			parse_setoptionpresence G_4_g_1_shell;parse_setoptionpresence G_4_g
			;;
		command)
			# Group checks
			
			if ! ([ -z "${launcherMode}" ] || [ "${launcherMode}" = "${launcherModeExistingCommand}" ] || [ "${launcherMode:0:1}" = "@" ])
			then
				parse_adderror "Another option of the group \"launcherMode\" was previously set (${launcherMode})"
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
			fi
			
			parser_subindex=0
			parser_optiontail=""
			launcherModeExistingCommand="${parser_item}"
			launcherMode="launcherModeExistingCommand"
			parse_setoptionpresence G_4_g_2_command;parse_setoptionpresence G_4_g
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
					return ${PARSER_SC_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
			fi
			
			parser_subindex=0
			parser_optiontail=""
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
					return ${PARSER_SC_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
			fi
			
			parser_subindex=0
			parser_optiontail=""
			windowHeight="${parser_item}"
			parse_setoptionpresence G_7_g_2_window-height;parse_setoptionpresence G_7_g
			;;
		debug)
			# Group checks
			
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_SC_ERROR}
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
					return ${PARSER_SC_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
			fi
			
			parser_subindex=0
			parser_optiontail=""
			if [ ! -e "${parser_item}" ]
			then
				parse_adderror "Invalid path \"${parser_item}\" for option ${parser_option}"
				return ${PARSER_SC_ERROR}
			fi
			
			if ! ([ -f "${parser_item}" ])
			then
				parse_adderror "Invalid patn type for option ${parser_option}"
				return ${PARSER_SC_ERROR}
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
			if [ -z "${parser_item}" ]
			then
				if [ ! -e "${parser_item}" ]
				then
					parse_adderror "Invalid path \"${parser_item}\" for option ${parser_option}"
					return ${PARSER_SC_ERROR}
				fi
				
				if ! ([ -f "${parser_item}" ] || [ -d "${parser_item}" ])
				then
					parse_adderror "Invalid patn type for option ${parser_option}"
					return ${PARSER_SC_ERROR}
				fi
				
				userDataPaths[${#userDataPaths[*]}]="${parser_item}"
			fi
			
			local parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
			while [ ! -z "${parser_nextitem}" ] && [ "${parser_nextitem:0:1}" != "-" ] && [ ${parser_index} -lt ${parser_itemcount} ]
			do
				parser_index=$(expr ${parser_index} + 1)
				parser_item="${parser_input[${parser_index}]}"
				if [ ! -e "${parser_item}" ]
				then
					parse_adderror "Invalid path \"${parser_item}\" for option ${parser_option}"
					return ${PARSER_SC_ERROR}
				fi
				
				if ! ([ -f "${parser_item}" ] || [ -d "${parser_item}" ])
				then
					parse_adderror "Invalid patn type for option ${parser_option}"
					return ${PARSER_SC_ERROR}
				fi
				
				userDataPaths[${#userDataPaths[*]}]="${parser_item}"
				parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
			done
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
					return ${PARSER_SC_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
			fi
			
			parser_subindex=0
			parser_optiontail=""
			nsxmlPath="${parser_item}"
			parse_setoptionpresence G_9_g_1_ns-xml-path;parse_setoptionpresence G_9_g
			;;
		ns-xml-path-relative)
			# Group checks
			
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_SC_ERROR}
			fi
			nsxmlPathRelative=true
			parse_setoptionpresence G_9_g_2_ns-xml-path-relative;parse_setoptionpresence G_9_g
			;;
		ns-xml-add)
			# Group checks
			
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			fi
			
			parser_subindex=0
			parser_optiontail=""
			if [ -z "${parser_item}" ]
			then
				if ! ([ "${parser_item}" = "sh" ] || [ "${parser_item}" = "xsl" ] || [ "${parser_item}" = "xsd" ])
				then
					parse_adderror "Invalid value for option \"${parser_item}\""
					
					return ${PARSER_SC_ERROR}
				fi
				nsxmlAdditionalSources[${#nsxmlAdditionalSources[*]}]="${parser_item}"
			fi
			
			local parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
			while [ ! -z "${parser_nextitem}" ] && [ "${parser_nextitem:0:1}" != "-" ] && [ ${parser_index} -lt ${parser_itemcount} ]
			do
				parser_index=$(expr ${parser_index} + 1)
				parser_item="${parser_input[${parser_index}]}"
				if ! ([ "${parser_item}" = "sh" ] || [ "${parser_item}" = "xsl" ] || [ "${parser_item}" = "xsd" ])
				then
					parse_adderror "Invalid value for option \"${parser_item}\""
					
					return ${PARSER_SC_ERROR}
				fi
				nsxmlAdditionalSources[${#nsxmlAdditionalSources[*]}]="${parser_item}"
				parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
			done
			parse_setoptionpresence G_9_g_3_ns-xml-add;parse_setoptionpresence G_9_g
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
		h)
			displayHelp=true
			parse_setoptionpresence G_1_help
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
					return ${PARSER_SC_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
			fi
			
			parser_subindex=0
			parser_optiontail=""
			if [ ! -e "${parser_item}" ]
			then
				parse_adderror "Invalid path \"${parser_item}\" for option ${parser_option}"
				return ${PARSER_SC_ERROR}
			fi
			
			if ! ([ -d "${parser_item}" ])
			then
				parse_adderror "Invalid patn type for option ${parser_option}"
				return ${PARSER_SC_ERROR}
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
					return ${PARSER_SC_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
			fi
			
			parser_subindex=0
			parser_optiontail=""
			if [ ! -e "${parser_item}" ]
			then
				parse_adderror "Invalid path \"${parser_item}\" for option ${parser_option}"
				return ${PARSER_SC_ERROR}
			fi
			
			if ! ([ -f "${parser_item}" ])
			then
				parse_adderror "Invalid patn type for option ${parser_option}"
				return ${PARSER_SC_ERROR}
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
					return ${PARSER_SC_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
			fi
			
			parser_subindex=0
			parser_optiontail=""
			if ! ([ "${parser_item}" = "host" ] || [ "${parser_item}" = "linux" ] || [ "${parser_item}" = "macosx" ])
			then
				parse_adderror "Invalid value for option \"${parser_item}\""
				
				return ${PARSER_SC_ERROR}
			fi
			targetPlatform="${parser_item}"
			parse_setoptionpresence G_5_target-platform
			;;
		u)
			update=true
			parse_setoptionpresence G_6_update
			;;
		s)
			# Group checks
			
			if ! ([ -z "${launcherMode}" ] || [ "${launcherMode}" = "${launcherModeXsh}" ] || [ "${launcherMode:0:1}" = "@" ])
			then
				parse_adderror "Another option of the group \"launcherMode\" was previously set (${launcherMode})"
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
			fi
			
			parser_subindex=0
			parser_optiontail=""
			if [ ! -e "${parser_item}" ]
			then
				parse_adderror "Invalid path \"${parser_item}\" for option ${parser_option}"
				return ${PARSER_SC_ERROR}
			fi
			
			if ! ([ -f "${parser_item}" ])
			then
				parse_adderror "Invalid patn type for option ${parser_option}"
				return ${PARSER_SC_ERROR}
			fi
			
			launcherModeXsh="${parser_item}"
			launcherMode="launcherModeXsh"
			parse_setoptionpresence G_4_g_1_shell;parse_setoptionpresence G_4_g
			;;
		c)
			# Group checks
			
			if ! ([ -z "${launcherMode}" ] || [ "${launcherMode}" = "${launcherModeExistingCommand}" ] || [ "${launcherMode:0:1}" = "@" ])
			then
				parse_adderror "Another option of the group \"launcherMode\" was previously set (${launcherMode})"
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
			fi
			
			parser_subindex=0
			parser_optiontail=""
			launcherModeExistingCommand="${parser_item}"
			launcherMode="launcherModeExistingCommand"
			parse_setoptionpresence G_4_g_2_command;parse_setoptionpresence G_4_g
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
					return ${PARSER_SC_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
			fi
			
			parser_subindex=0
			parser_optiontail=""
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
					return ${PARSER_SC_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
			fi
			
			parser_subindex=0
			parser_optiontail=""
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
					return ${PARSER_SC_ERROR}
				fi
				
				parser_item="${parser_input[${parser_index}]}"
			fi
			
			parser_subindex=0
			parser_optiontail=""
			if [ ! -e "${parser_item}" ]
			then
				parse_adderror "Invalid path \"${parser_item}\" for option ${parser_option}"
				return ${PARSER_SC_ERROR}
			fi
			
			if ! ([ -f "${parser_item}" ])
			then
				parse_adderror "Invalid patn type for option ${parser_option}"
				return ${PARSER_SC_ERROR}
			fi
			
			userInitializationScript="${parser_item}"
			parse_setoptionpresence G_8_g_1_init-script;parse_setoptionpresence G_8_g
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
			parse_adderror "Unknown subcommand name \"${parser_item}\""
			return ${PARSER_ERROR}
			;;
		
		esac
	else
		parser_values[${#parser_values[*]}]="${parser_item}"
	fi
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
	
	local parser_errorcount=${#parser_errors[*]}
	if [ ${parser_errorcount} -eq 1 ] && [ -z "${parser_errors}" ]
	then
		parser_errorcount=0
	fi
	return ${parser_errorcount}
}

ns_realpath()
{
	body
}
ns_realpath()
{
	local path="${1}"
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
xml_validate()
{
	local schema="${1}"
	local xml="${2}"
	local tmpOut="/tmp/xml_validate.tmp"
	if  ! xmllint --noout --schema "${schema}" "${xml}" 1>"${tmpOut}" 2>&1
	then
		cat "${tmpOut}"
		return 1
	fi
	
	return 0
}

logFile="/tmp/$(basename "${0}").log"
${isDebug} && echo "$(date): ${0} ${@}" > "${logFile}"

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

# finding schema version
programVersion="$(xsltproc "${nsPath}/xsl/program/get-version.xsl" "${xmlProgramDescriptionPath}")"
info "Program schema version ${programVersion}"

if [ ! -f "${nsPath}/xsd/program/${programVersion}/program.xsd" ]
then
	error "Invalid program schema version"
fi  

requiredTemplates="xul-ui-mainwindow xul-js-mainwindow xul-js-application get-programinfo"
if [ "${targetPlatform}" == "macosx" ]
then
	requiredTemplates="${requiredTemplates} macosx-plist xul-ui-hiddenwindow"
fi

for template in ${requiredTemplates}
do
	stylesheet="${nsPath}/xsl/program/${programVersion}/${template}.xsl"
	if [ ! -f "${stylesheet}" ]
	then
		error "Missing XSLT stylesheet file \"${stylesheet}\""
	fi
done

# Validate xml
if ! xml_validate "${nsPath}/xsd/program/${programVersion}/program.xsd" "${xmlProgramDescriptionPath}"
then
	error "Schema error - abort"
fi

programStylesheetPath="${nsPath}/xsl/program/${programVersion}"
programInfoStylesheetPath="${programStylesheetPath}/get-programinfo.xsl"

appName="$(xsltproc --stringparam name name "${programInfoStylesheetPath}" "${xmlProgramDescriptionPath}")"
appDisplayName="$(xsltproc --stringparam name label "${programInfoStylesheetPath}" "${xmlProgramDescriptionPath}")"
xulAppName="$(echo "${appName}" | sed "s/[^a-zA-Z0-9]//g")"
appAuthor="$(xsltproc --stringparam name author "${programInfoStylesheetPath}" "${xmlProgramDescriptionPath}")"
appVersion="$(xsltproc --stringparam name version "${programInfoStylesheetPath}" "${xmlProgramDescriptionPath}")"
appUUID="$(uuidgen)"
appBuildID="$(date +%Y%m%d-%s)"

# Append application name to output path (auto)
outputPathBase="$(basename "${outputPath}")"

[ "${outputPathBase}" != "${appName}" ] && [ "${outputPathBase}" != "${appDisplayName}" ] && outputPath="${outputPath}/${appDisplayName}"
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
	(! ${update}) && error " - Folder already exists. Set option --update to force update"
	(${update} && [ ! -f "${appRootPath}/application.ini" ]) && error " - Folder exists - update option is set, but the folder doesn't seems to be a valid xul application folder"
	preexistantOutputPath=true
else
	mkdir -p "${outputPath}" || error "Unable to create output path \"${outputPath}\""
	mkdir -p "${appRootPath}" || error "Unable to create application root path \"${appRootPath}\""
	outputPath="$(ns_realpath "${outputPath}")"
	appRootPath="$(ns_realpath "${appRootPath}")"
fi

appIniFile="${appRootPath}/application.ini"
appPrefFile="${appRootPath}/defaults/preferences/pref.js"
appCssFile="${appRootPath}/chrome/content/${xulAppName}.css"
appMainXulFile="${appRootPath}/chrome/content/${xulAppName}.xul"
appOverlayXulFile="${appRootPath}/chrome/content/${xulAppName}-overlay.xul"
appHiddenWindowXulFile="${appRootPath}/chrome/content/${xulAppName}-hiddenwindow.xul"
rebuildScriptFile="${appRootPath}/sh/_rebuild.sh"
commandLauncherFile="${appRootPath}/sh/${xulAppName}.sh"

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

if ! mkdir -p "${appRootPath}/sh"
then
	error "Unable to create shell sub directory"
fi
commandLauncherFile="$(ns_realpath "${commandLauncherFile}")"

if [ "${launcherMode}" == "launcherModeXsh" ]
then
	info " - Generate shell file"
	debugParam=""
	if ${debugMode}
	then
		debugParam="--stringparam prg.debug \"true()\""
	fi
	
	xshXslTemplatePath="${nsPath}/xsl/program/${programVersion}/xsh.xsl"
	launcherModeXsh="$(ns_realpath "${launcherModeXsh}")"
	if ! xsltproc --xinclude -o "${commandLauncherFile}" ${debugParam} "${xshXslTemplatePath}" "${launcherModeXsh}"
	then
		echo "Fail to process xsh file \"${launcherModeXsh}\""
		exit 5
	fi
		
elif [ "${launcherMode}" == "launcherModeExistingCommand" ]
then 
	info " - Generate command launcher"
	echo -ne "#!/bin/bash\n${launcherModeExistingCommand} \${@}" > "${commandLauncherFile}"
fi
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

if [ ${#nsxmlAdditionalSources[*]} -gt 0 ]
then
	info " - Copy ns-xml additianal files"
	for ((i=0;${i}<${#nsxmlAdditionalSources[*]};i++))
	do
		d="${nsxmlAdditionalSources[${i}]}"
		info " -- ${d} -> ${appRootPath}/chrome/ns"
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
	echo -en "$(ns_realpath "${0}") --update --debug --xml-description \"$(ns_realpath "${xmlProgramDescriptionPath}")\"" >> "${rebuildScriptFile}"
	echo -en " --output \"$(ns_realpath "${outputPath}")\"" >> "${rebuildScriptFile}"
	if [ "${launcherMode}" == "launcherModeXsh" ]
	then
		echo -en " --shell-template \"$(ns_realpath "${launcherModeXsh}")\"" >> "${rebuildScriptFile}"
		
	elif [ "${launcherMode}" == "launcherModeExistingCommand" ]
	then
		echo -en " --command" >> "${rebuildScriptFile}"
	fi
	
	echo "" >> "${rebuildScriptFile}"
	
	chmod 755  "${rebuildScriptFile}"
fi

info " - Building UI layout"
#The xul for the main window
xsltOption="--stringparam prg.xul.appName ${xulAppName}"
[ -z "${windowWidth}" ] || xsltOption="${xsltOption} --param prg.xul.windowWidth ${windowWidth}"
[ -z "${windowHeight}" ] || xsltOption="${xsltOption} --param prg.xul.windowHeight ${windowHeight}"
 
xsltOption="${xsltOption} --stringparam prg.xul.platform ${targetPlatform}"
 
if ${debugMode}
then
	xsltOption="${xsltOption} --param prg.debug \"true()\""
fi

info " -- Main window"
if ! xsltproc ${xsltOption} "${programStylesheetPath}/xul-ui-mainwindow.xsl" "${xmlProgramDescriptionPath}" > "${appMainXulFile}"  
then
	error "Error while building XUL main window layout (${appMainXulFile} - ${xsltOption})"
fi

info " -- Overlay"
if ! xsltproc ${xsltOption} "${programStylesheetPath}/xul-ui-overlay.xsl" "${xmlProgramDescriptionPath}" > "${appOverlayXulFile}"  
then
	error "Error while building XUL overlay layout (${appOverlayXulFile} - ${xsltOption})"
fi

if [ "${targetPlatform}" == "macosx" ]
then
	info " -- Mac OS X hidden window"
	if ! xsltproc -o "${appHiddenWindowXulFile}" ${xsltOption} "${programStylesheetPath}/xul-ui-hiddenwindow.xsl" "${xmlProgramDescriptionPath}" 
	then
		error "Error while building XUL hidden window layout (${appHiddenWindowXulFile} - ${xsltOption})"
	fi 
fi

info " - Building CSS stylesheet"
rm -f "${appCssFile}"
for d in "${nsPath}/xbl" "${nsPath}/xbl/program/${programVersion}"
do
	find "${d}" -maxdepth 1 -mindepth 1 -name "*.xbl" | while read f
	do
		b="${f#${nsPath}/xbl/}"
		cssXsltOptions="--param resourceURI \"resource://ns/xbl/${b}\""
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
if ! xsltproc ${xsltOption} "${programStylesheetPath}/xul-js-application.xsl" "${xmlProgramDescriptionPath}" > "${appRootPath}/chrome/content/${xulAppName}.jsm"  
then
	error "Error while building XUL application code"
fi

if ! xsltproc ${xsltOption} "${programStylesheetPath}/xul-js-mainwindow.xsl" "${xmlProgramDescriptionPath}" > "${appRootPath}/chrome/content/${xulAppName}.js"  
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
	if ! xsltproc ${xsltOption} --stringparam prg.xul.buildID "${appBuildID}" "${programStylesheetPath}/macosx-plist.xsl" "${xmlProgramDescriptionPath}" > "${outputPath}/Contents/Info.plist"  
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
buildPlatform="${targetPlatform}"
debug=${debugMode}
platform="linux"
if [ "\$(uname)" == "Darwin" ]
then
	platform="macosx"
fi

scriptPath="\$(ns_realpath "\$(dirname "\${0}")")"
appIniPath="\$(ns_realpath "\${scriptPath}/application.ini")"
logFile="/tmp/\$(basename "\${0}").log"
if [ "\${buildPlatform}" == "macosx" ]
then
	appIniPath="\$(ns_realpath "\${scriptPath}/../Resources/application.ini")"
fi
if [ "\${platform}" == "macosx" ]
then
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
	
	minXulFrameworkVersion=4
	for xul in "/Library/Frameworks/XUL.framework" "\${HOME}/Library/Frameworks/XUL.framework"
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
	use_xulrunner || use_firefox
fi
EOF
chmod 755 "${launcherPath}"

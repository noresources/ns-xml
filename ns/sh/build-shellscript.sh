#!/bin/bash
# ####################################
# Copyright (c) 2011 by Renaud Guillard (dev@niao.fr)
# Author: Renaud Guillard
# Version: 2.0
# 
# Shell script builder which use XML description file to automatically generate command line processing and help messages
#
# Program help
usage()
{
cat << EOFUSAGE
build-shellscript: Shell script builder which use XML description file to automatically generate command line processing and help messages
Usage: 
  build-shellscript [--ns-xml-path <path> --ns-xml-path-relative] [-x <path>] -s <path> [-d] [-h] -o <path>
  With:
    ns-xml source path options
    (
    	--ns-xml-path: ns-xml source path
    	--ns-xml-path-relative: ns source path is relative this program path
    )
    -x, --xml-description: Program description file
    -s, --shell: XML shell file
    -d, --debug: Generate debug messages in help and command line parsing functions
    -h, --help: This help
    -o, --output: Output file path
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


parser_required[${#parser_required[*]}]="G_3_shell:--shell"
parser_required[${#parser_required[*]}]="G_6_output:--output"
# Switch options

nsxmlPathRelative=false
debugMode=false
displayHelp=false
# Single argument options

nsxmlPath=
xmlProgramDescriptionPath=
xmlShellFileDescriptionPath=
outputScriptFilePath=

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
			parse_setoptionpresence G_2_xml-description
			;;
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
			
			xmlShellFileDescriptionPath="${parser_item}"
			parse_setoptionpresence G_3_shell
			;;
		debug)
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_SC_ERROR}
			fi
			debugMode=true
			parse_setoptionpresence G_4_debug
			;;
		help)
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_SC_ERROR}
			fi
			displayHelp=true
			parse_setoptionpresence G_5_help
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
			outputScriptFilePath="${parser_item}"
			parse_setoptionpresence G_6_output
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
			parse_setoptionpresence G_1_g_1_ns-xml-path;parse_setoptionpresence G_1_g
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
			parse_setoptionpresence G_1_g_2_ns-xml-path-relative;parse_setoptionpresence G_1_g
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
			parse_setoptionpresence G_2_xml-description
			;;
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
			
			xmlShellFileDescriptionPath="${parser_item}"
			parse_setoptionpresence G_3_shell
			;;
		d)
			debugMode=true
			parse_setoptionpresence G_4_debug
			;;
		h)
			displayHelp=true
			parse_setoptionpresence G_5_help
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
			outputScriptFilePath="${parser_item}"
			parse_setoptionpresence G_6_output
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

# Global variables
scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
nsPath="$(ns_realpath "${scriptPath}/../..")/ns"
rootPath="$(ns_realpath "${scriptPath}/../..")"
programVersion="2.0"
 
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

# Check ns-xml library path
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

# Check required XSLT files
xshXslTemplatePath="${nsPath}/xsl/program/${programVersion}/xsh.xsl"
if [ ! -f "${xshXslTemplatePath}" ]
then
	echo "Missing XSLT stylesheet file \"${xshXslTemplatePath}\""
	exit 2
fi

# Validate xml program description (if given)
if [ -f "${xmlProgramDescriptionPath}" ]
then
	# Finding schema version
	programVersion="$(xsltproc "${nsPath}/xsl/program/get-version.xsl" "${xmlProgramDescriptionPath}")"
	echo "Program schema version ${programVersion}"
	
	if [ ! -f "${nsPath}/xsd/program/${programVersion}/program.xsd" ]
	then
		echo "Invalid program schema version"
		exit 3
	fi

	if ! xmllint --xinclude --noout --schema "${nsPath}/xsd/program/${programVersion}/program.xsd" "${xmlProgramDescriptionPath}" 1>/dev/null
	then
		echo "Schema error - abort"
		exit 4
	fi
fi

# Process xsh file
debugParam=""
if ${debugMode}
then
	debugParam="--stringparam prg.debug \"true()\""
fi

if ! xsltproc --xinclude -o "${outputScriptFilePath}" ${debugParam} "${xshXslTemplatePath}" "${xmlShellFileDescriptionPath}"
then
	echo "Fail to process xsh file \"${xmlShellFileDescriptionPath}\""
	exit 5
fi 
chmod 755 "${outputScriptFilePath}"

#!/bin/bash
# ####################################
# Copyright (c) 2011 by Renaud Guillard (dev@niao.fr)
# Author: Renaud Guillard
# Version: 1.0
# 
# Python script builder which use XML description file to automatically generate command line processing and help messages
#
# Program help
usage()
{
cat << EOFUSAGE
build-pyscript: Python script builder which use XML description file to automatically generate command line processing and help messages
Usage: 
  build-pyscript -p <path> [-m <...>] [-u] -x <path> [-S] [-d] [--help] [--ns-xml-path <path> --ns-xml-path-relative]
  With:
    -p, --python: Python script path
    	Location of the Python script body. The parser module will be created at the same place
    -m, --module-name, --module: Python module name
    	Set the name of the command line parser python module	
    	Default value: Program
    -u, --update: Update pythom module if already exists
    -x, --xml-description: Program description file
    	If the program description file is provided, the xml file will be validated before any XSLT processing
    --skip-validation, --no-validation, -S: Skip XML Schema validations
    The default behavior of the program is to validate the given xml-based file(s) against its/their xml schema (http://xsd.nore.fr/program etc.). This option will disable schema validations
    -d, --debug: Generate debug messages in help and command line parsing functions
    --help: Display program usage
    ns-xml source path options
    	--ns-xml-path: ns-xml source path
    		Location of the ns folder of ns-xml package
    	--ns-xml-path-relative: ns source path is relative this program path
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


parser_required[${#parser_required[*]}]="G_1_python:--python"
parser_required[${#parser_required[*]}]="G_4_xml-description:--xml-description"
# Switch options

update=false
skipValidation=false
debugMode=false
displayHelp=false
nsxmlPathRelative=false
# Single argument options

pythonScriptPath=
moduleName="Program"
xmlProgramDescriptionPath=
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
	elif [ "${parser_item:0:2}" = "--" ] 
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
			if [ ! -e "${parser_item}" ]
			then
				parse_adderror "Invalid path \"${parser_item}\" for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			if ! ([ -f "${parser_item}" ])
			then
				parse_adderror "Invalid patn type for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			pythonScriptPath="${parser_item}"
			parse_setoptionpresence G_1_python
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
			moduleName="${parser_item}"
			parse_setoptionpresence G_2_module-name
			;;
		update)
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_ERROR}
			fi
			update=true
			parse_setoptionpresence G_3_update
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
			if [ ! -e "${parser_item}" ]
			then
				parse_adderror "Invalid path \"${parser_item}\" for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			if ! ([ -f "${parser_item}" ])
			then
				parse_adderror "Invalid patn type for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			xmlProgramDescriptionPath="${parser_item}"
			parse_setoptionpresence G_4_xml-description
			;;
		skip-validation | no-validation)
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_ERROR}
			fi
			skipValidation=true
			parse_setoptionpresence G_5_skip-validation
			;;
		debug)
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_ERROR}
			fi
			debugMode=true
			parse_setoptionpresence G_6_debug
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
			nsxmlPath="${parser_item}"
			parse_setoptionpresence G_8_g_1_ns-xml-path;parse_setoptionpresence G_8_g
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
			parse_setoptionpresence G_8_g_2_ns-xml-path-relative;parse_setoptionpresence G_8_g
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
		p)
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
			if [ ! -e "${parser_item}" ]
			then
				parse_adderror "Invalid path \"${parser_item}\" for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			if ! ([ -f "${parser_item}" ])
			then
				parse_adderror "Invalid patn type for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			pythonScriptPath="${parser_item}"
			parse_setoptionpresence G_1_python
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
			moduleName="${parser_item}"
			parse_setoptionpresence G_2_module-name
			;;
		u)
			update=true
			parse_setoptionpresence G_3_update
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
			if [ ! -e "${parser_item}" ]
			then
				parse_adderror "Invalid path \"${parser_item}\" for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			if ! ([ -f "${parser_item}" ])
			then
				parse_adderror "Invalid patn type for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			xmlProgramDescriptionPath="${parser_item}"
			parse_setoptionpresence G_4_xml-description
			;;
		S)
			skipValidation=true
			parse_setoptionpresence G_5_skip-validation
			;;
		d)
			debugMode=true
			parse_setoptionpresence G_6_debug
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

# Global variables
scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
scriptName="$(basename "${scriptFilePath}")"
nsPath="$(ns_realpath "${scriptPath}/../..")/ns"
programVersion="2.0"
baseModules=(__init__ Base Info Parser Validators)
 
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

chunk_check_nsxml_ns_path || error "Invalid ns-xml ns folder (${nsPath})"
programVersion="$(get_program_version "${xmlProgramDescriptionPath}")"

pythonScriptPathBase="$(dirname "${pythonScriptPath}")"
pythonModulePath="${pythonScriptPathBase}/${moduleName}"

[ -d "${pythonModulePath}" ] && ! ${update} && error "${pythonModulePath} already exists - set --update to overwrite"

nsPythonPath="${nsPath}/python/program/${programVersion}"
for m in ${baseModules[*]}
do
	nsPythonFile="${nsPythonPath}/${m}.py"	
	[ -f "${nsPythonFile}" ] || error 2 "Base python module not found (${nsPythonFile})"
done

mkdir -p "${pythonModulePath}" || error 3 "Unable to create Module folder ${pythonModulePath}"
for m in ${baseModules[*]}
do
	nsPythonFile="${nsPythonPath}/${m}.py"
	cp -fp "${nsPythonFile}" "${pythonModulePath}"  
done

# Create the Program module
xslStyleSheetPath="${nsPath}/xsl/program/${programVersion}"
if ! xsltproc --xinclude -o "${pythonModulePath}/Program.py" "${xslStyleSheetPath}/py-module.xsl" "${xmlProgramDescriptionPath}"
then
	error 4 "Failed to create Program module"
fi


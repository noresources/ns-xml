#!/usr/bin/env bash
# ####################################
# Copyright © 2012 by Renaud Guillard (dev@nore.fr)
# Distributed under the terms of the MIT License, see LICENSE
# Author: Renaud Guillard
# Version: 2.0
# 
# Rebuild C Parser XSLT from C source code
#
# Program help
usage()
{
cat << EOFUSAGE
update-doc: Rebuild C Parser XSLT from C source code
Usage: 
  update-doc [--help] [-v <...>]
  With:
    --help: Display program usage
    -v, --version: Program schema version  
      Default value: 2.0
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
displayHelp=false
# Single argument options
programVersion=

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
	# programVersion
	if [ -z "${programVersion}" ]
	then
		parser_set_default=true
		if ${parser_set_default}
		then
			programVersion="2.0"
			parse_setoptionpresence G_2_version
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
	local parser_integer
	local parser_decimal
	parser_item="${parser_input[${parser_index}]}"
	if [ -z "${parser_item}" ] || [ "${parser_item:0:1}" != "-" ] || [ "${parser_item}" = "--" ]
	then
		return ${PARSER_SC_SKIP}
	fi
	
	return ${PARSER_SC_SKIP}
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
		version)
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
			programVersion="${parser_item}"
			parse_setoptionpresence G_2_version
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
		v)
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
			programVersion="${parser_item}"
			parse_setoptionpresence G_2_version
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
ns_isdir()
{
	local path
	if [ $# -gt 0 ]
	then
		path="${1}"
		shift
	fi
	[ ! -z "${path}" ] && [ -d "${path}" ]
}
ns_issymlink()
{
	local path
	if [ $# -gt 0 ]
	then
		path="${1}"
		shift
	fi
	[ ! -z "${path}" ] && [ -L "${path}" ]
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
ns_sed_inplace()
{
	local sedCommand
	if [ $# -gt 0 ]
	then
		sedCommand="${1}"
		shift
	fi
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
	
	while [ $# -gt 0 ]
	do	
		if [ ${sedForm} -eq 1 ]
		then
			"${sedBin}" --in-place "${sedCommand}" "${1}"
		elif [ ${sedForm} -eq 2 ]
		then
			"${sedBin}" -i "" "${sedCommand}" "${1}"
		fi
		
		shift
	done
}


scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
rootPath="$(ns_realpath "${scriptPath}/../..")"
xslPath="${rootPath}/ns/xsl"
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

hasAstyle=false
which astyle 1>/dev/null 2>&1 && hasAstyle=true 

astyleOptionsFile="${rootPath}/resources/astyle/c.style"

transformableFunctions=(\
	"nsxml_util_strncpy" \
	"nsxml_util_strcpy" \
	"nsxml_util_asnprintf" \
	"nsxml_util_string_starts_with" \
	"nsxml_util_path_access_check" \
	"nsxml_util_text_wrap_options_init" \
	"nsxml_util_text_wrap_fprintf"
)
		
transformableStructs=(\
	"nsxml_util_text_wrap_options" \
	"nsxml_message" \
	"nsxml_value" \
)

transformableEnumPrefixes=(\
	"nsxml_util_text_wrap_indent_" \
	"nsxml_util_text_wrap_eol_" \
	"nsxml_message_type_" \
	"nsxml_value_type_" \
	"nsxml_usage_format_" \
	"nsxml_message_warning_" \
	"nsxml_message_error_" \
	"nsxml_message_fatal_error_" \
)
															
transform_c()
{
	local input="${1}"
	local output="${2}"
	local templateName="${3}"
	
	local tmpFile="$(ns_mktemp)"
	([ ! -z "${tmpFile}" ] && [ -w "${tmpFile}" ]) || error 2 "Unable to access to temporary file '${tmpFile}'"

	cat > "${tmpFile}" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2012-$(date +%Y) by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->
<!-- C Source code in customizable XSLT form -->
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:prg="http://xsd.nore.fr/program">
	<import href="parser.generic-names.xsl" />
	<output method="text" encoding="utf-8" />
	<param name="prg.c.parser.header.filePath" select="'cmdline.h'" />
	
	<variable name="prg.c.parser.${templateName}"><![CDATA[
EOF
	# Use Artistic Style to format code
	if ${hasAstyle}
	then
		astyle --options="${astyleOptionsFile}" --suffix=none -q "${input}"
	fi 
	
	cat "${input}" >> "${tmpFile}"
		
	cat >> "${tmpFile}" << EOF
]]></variable>

	<template match="//prg:program">
		<value-of select="\$prg.c.parser.${templateName}"/>
	</template>
</stylesheet>

EOF
	
	# Replace hardcoded names by transformable ones
	for t in "${transformableStructs[@]}"
	do
		#echo "Transform struct $t"
		ns_sed_inplace "s,struct[ \t]\+${t}\([^_]\),struct ]]><value-of select=\"\$prg.c.parser.structName.${t}\"/><![CDATA[\\1,g" "${tmpFile}"
		ns_sed_inplace "s,\(typedef struct[ \t]\+[a-zA-Z0-9_-]\+[ \t]\+\)${t};,\\1]]><value-of select=\"\$prg.c.parser.structName.${t}\"/><![CDATA[;,g" "${tmpFile}"
		ns_sed_inplace "s,\(^\| \|\t\|(\)${t}\([ \t)]\+\),\\1]]><value-of select=\"\$prg.c.parser.structName.${t}\"/><![CDATA[\\2,g" "${tmpFile}"
	done
	
	for t in "${transformableFunctions[@]}"
	do
		#echo "Transform function $t()"
		ns_sed_inplace "s,${t}[ \t]*(,]]><value-of select=\"\$prg.c.parser.functionName.${t}\"/><![CDATA[(,g" "${tmpFile}"
	done
	
	for t in "${transformableEnumPrefixes[@]}"
	do
		#echo "Transform enum $t*"
		ns_sed_inplace "s,${t}\([a-zA-Z0-9_]\+\),]]><value-of select=\"\$prg.c.parser.variableName.${t}\\1\"/><![CDATA[,g" "${tmpFile}"
	done
	
	# Include (if source)
	ns_sed_inplace "s,#include[ \t][ \t]*\"nsxml_program_parser\.h\",#include \"]]><value-of select=\"\$prg.c.parser.header.filePath\"/><![CDATA[\",g" "${tmpFile}"

	# Finally 
	mv "${tmpFile}" "${output}"
}

create_identifier_variables()
{
	local output="${1}"
	local header="${2}"
	local tmpFile="$(ns_mktemp)"
	([ ! -z "${tmpFile}" ] && [ -w "${tmpFile}" ]) || error 2 "Unable to access to temporary file '${tmpFile}'"
	
	cat > "${tmpFile}" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2012-$(date +%Y) by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->
<!-- List of variable, structs and function names which can be modified by the user -->
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform"
	xmlns:prg="http://xsd.nore.fr/program" version="1.0">
	<import href="parser.base.xsl" />
	
EOF

	for t in "${transformableFunctions[@]}"
	do
		cat >> "${tmpFile}" << EOF
	<variable name="prg.c.parser.functionName.${t}">
		<call-template name="prg.c.parser.functionName">
			<with-param name="name" select="'${t}'" />
		</call-template>
	</variable>
EOF
	done	
	
	for t in "${transformableStructs[@]}"
	do
		cat >> "${tmpFile}" << EOF
	<variable name="prg.c.parser.structName.${t}">
		<call-template name="prg.c.parser.structName">
			<with-param name="name" select="'${t}'" />
		</call-template>
	</variable>
EOF
	done
	
	for b in "${transformableEnumPrefixes[@]}"
	do
		#echo "Search enum ${b} in ${header}"
		egrep -o "${b}[a-z0-9_]+" "${header}" | uniq | while read t
		do
			cat >> "${tmpFile}" << EOF
	<variable name="prg.c.parser.variableName.${t}">
		<call-template name="prg.c.parser.variableName">
			<with-param name="name" select="'${t}'" />
		</call-template>
	</variable>
EOF
		done
	done
	
	echo -e "</stylesheet>" >> "${tmpFile}"
	#xmllint --format --output "${tmpFile}" "${tmpFile}"
	
	# Finally 
	mv "${tmpFile}" "${output}"
}

cSourcePath="${rootPath}/resources/c/program/${programVersion}"
cSourceBaseFileName="nsxml_program_parser"
cXslPath="${xslPath}/program/${programVersion}/c"
cXslBaseFileName="parser.generic-"
[ -d "${cSourcePath}" ] || error 1 "Invalid path for C source"
[ -d "${cXslPath}" ] || error 1 "Invalid path for XSL output"

# XSLT Variables
create_identifier_variables "${cXslPath}/${cXslBaseFileName}names.xsl" "${cSourcePath}/${cSourceBaseFileName}.h" 
# Header & sources 
transform_c "${cSourcePath}/${cSourceBaseFileName}.h" "${cXslPath}/${cXslBaseFileName}header.xsl" "genericHeader"
transform_c "${cSourcePath}/${cSourceBaseFileName}.c" "${cXslPath}/${cXslBaseFileName}source.xsl" "genericSource"


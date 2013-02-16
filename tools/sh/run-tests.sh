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
cat << EOFUSAGE
run-tests: Run ns-xml unittests
Usage: 
  run-tests [-T] [-p <...  [ ... ]>] [-a <number [ ... ]>] [-t <...  [ ... ]>] [--help]
  With:
    -p, --parsers: Parser to test  
      The argument value have to be one of the following:  
        c, php, python or sh
    -a, --apps: Test groups to run
    -t, --tests: Test id(s) to run
    -T, --temp: Keep temporary files
      Don't remove temporary files even if test passed
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
keepTemporaryFiles=false
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
		parsers)
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			local parser_ma_local_count=0
			local parser_ma_total_count=${#parsers[*]}
			if [ -z "${parser_item}" ]
			then
				if ! ([ "${parser_item}" = "c" ] || [ "${parser_item}" = "php" ] || [ "${parser_item}" = "python" ] || [ "${parser_item}" = "sh" ])
				then
					parse_adderror "Invalid value for option \"${parser_option}\""
					
					return ${PARSER_ERROR}
				fi
				parsers[$(expr ${#parsers[*]} + ${parser_startindex})]="${parser_item}"
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
				if ! ([ "${parser_item}" = "c" ] || [ "${parser_item}" = "php" ] || [ "${parser_item}" = "python" ] || [ "${parser_item}" = "sh" ])
				then
					parse_adderror "Invalid value for option \"${parser_option}\""
					
					return ${PARSER_ERROR}
				fi
				parsers[$(expr ${#parsers[*]} + ${parser_startindex})]="${parser_item}"
				parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
				parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
				parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
			done
			if [ ${parser_ma_local_count} -eq 0 ]
			then
				parse_adderror "At least one argument expected for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			parse_setoptionpresence G_1_parsers
			;;
		apps)
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			local parser_ma_local_count=0
			local parser_ma_total_count=${#apps[*]}
			if [ -z "${parser_item}" ]
			then
				apps[$(expr ${#apps[*]} + ${parser_startindex})]="${parser_item}"
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
				apps[$(expr ${#apps[*]} + ${parser_startindex})]="${parser_item}"
				parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
				parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
				parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
			done
			if [ ${parser_ma_local_count} -eq 0 ]
			then
				parse_adderror "At least one argument expected for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			parse_setoptionpresence G_2_apps
			;;
		tests)
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			local parser_ma_local_count=0
			local parser_ma_total_count=${#tests[*]}
			if [ -z "${parser_item}" ]
			then
				tests[$(expr ${#tests[*]} + ${parser_startindex})]="${parser_item}"
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
				tests[$(expr ${#tests[*]} + ${parser_startindex})]="${parser_item}"
				parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
				parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
				parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
			done
			if [ ${parser_ma_local_count} -eq 0 ]
			then
				parse_adderror "At least one argument expected for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			parse_setoptionpresence G_3_tests
			;;
		temp)
			if [ ! -z "${parser_optiontail}" ]
			then
				parse_adderror "Unexpected argument (ignored) for option \"${parser_option}\""
				parser_optiontail=""
				return ${PARSER_ERROR}
			fi
			keepTemporaryFiles=true
			parse_setoptionpresence G_4_temp
			;;
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
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			local parser_ma_local_count=0
			local parser_ma_total_count=${#parsers[*]}
			if [ -z "${parser_item}" ]
			then
				if ! ([ "${parser_item}" = "c" ] || [ "${parser_item}" = "php" ] || [ "${parser_item}" = "python" ] || [ "${parser_item}" = "sh" ])
				then
					parse_adderror "Invalid value for option \"${parser_option}\""
					
					return ${PARSER_ERROR}
				fi
				parsers[$(expr ${#parsers[*]} + ${parser_startindex})]="${parser_item}"
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
				if ! ([ "${parser_item}" = "c" ] || [ "${parser_item}" = "php" ] || [ "${parser_item}" = "python" ] || [ "${parser_item}" = "sh" ])
				then
					parse_adderror "Invalid value for option \"${parser_option}\""
					
					return ${PARSER_ERROR}
				fi
				parsers[$(expr ${#parsers[*]} + ${parser_startindex})]="${parser_item}"
				parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
				parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
				parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
			done
			if [ ${parser_ma_local_count} -eq 0 ]
			then
				parse_adderror "At least one argument expected for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			parse_setoptionpresence G_1_parsers
			;;
		a)
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			local parser_ma_local_count=0
			local parser_ma_total_count=${#apps[*]}
			if [ -z "${parser_item}" ]
			then
				apps[$(expr ${#apps[*]} + ${parser_startindex})]="${parser_item}"
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
				apps[$(expr ${#apps[*]} + ${parser_startindex})]="${parser_item}"
				parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
				parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
				parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
			done
			if [ ${parser_ma_local_count} -eq 0 ]
			then
				parse_adderror "At least one argument expected for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			parse_setoptionpresence G_2_apps
			;;
		t)
			if [ ! -z "${parser_optiontail}" ]
			then
				parser_item="${parser_optiontail}"
			fi
			
			parser_subindex=0
			parser_optiontail=""
			[ "${parser_item:0:2}" = "\-" ] && parser_item="${parser_item:1}"
			local parser_ma_local_count=0
			local parser_ma_total_count=${#tests[*]}
			if [ -z "${parser_item}" ]
			then
				tests[$(expr ${#tests[*]} + ${parser_startindex})]="${parser_item}"
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
				tests[$(expr ${#tests[*]} + ${parser_startindex})]="${parser_item}"
				parser_ma_total_count=$(expr ${parser_ma_total_count} + 1)
				parser_ma_local_count=$(expr ${parser_ma_local_count} + 1)
				parser_nextitem="${parser_input[$(expr ${parser_index} + 1)]}"
			done
			if [ ${parser_ma_local_count} -eq 0 ]
			then
				parse_adderror "At least one argument expected for option \"${parser_option}\""
				return ${PARSER_ERROR}
			fi
			
			parse_setoptionpresence G_3_tests
			;;
		T)
			keepTemporaryFiles=true
			parse_setoptionpresence G_4_temp
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

#####################################################################"
# Parsers tests

parserTestsPathBase="${projectPath}/unittests/parsers"
tmpShellStylesheet="$(ns_mktemp "shell-xsl")"
programVersion="2.0"
xshStylesheet="${projectPath}/ns/xsl/program/${programVersion}/xsh.xsl"
pythonInterpreters=(python2.6 python2.7 python)

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

# Supported Python interpreter
for i in ${pythonInterpreters[*]}
do
	if which ${i} 1>/dev/null 2>&1
	then
		pythonInterpreter=${i}
	fi
done

# Supported shells
shells=(bash zsh ksh)
for s in ${shells[*]}
do
	if which ${s} 1>/dev/null 2>&1
	then
		check_func="check_${s}"
		if [ "$(type -t "${check_func}")" != "function" ] || ${check_func}
		then
			available_shells[${#available_shells[*]}]=${s}
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
	$(find "${parserTestsPathBase}/apps" -mindepth 1 -maxdepth 1 -type d -name "app*" | sort)
EOF
else
	for ((a=0;${a}<${#apps[@]};a++))
	do
		d="${parserTestsPathBase}/apps/app${apps[${a}]}"
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
	
	if [ ! -z "${pythonInterpreter}" ]
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
		elif [ "${parsers[${i}]}" = "python" ] && [ ! -z "${pythonInterpreter}" ]
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
	
	for s in ${available_shells[*]}
	do
		resultLineFormat="${resultLineFormat} %-7s |"	
	done
fi

if ${testPython}
then
	parserNames=("${parserNames[@]}" "Python")	
	resultLineFormat="${resultLineFormat} %-7s |"
fi

if ${testC}
then
	parserNames=("${parserNames[@]}" "C/${cc}")
	if ${testValgrind}
	then
		parserNames=("${parserNames[@]}" "C/Valgrind")
	fi
		
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
			valgrindArgs=("${valgrindArgs[@]}" "--dsymutil=yes")
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
	
	echo "${groupTestBasePath}"
	unset groupTests
	
	# Populate group tests
	if [ ${#tests[@]} -eq 0 ]
	then
		while read t
		do
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
		xsltproc --xinclude -o "${xshBodyFile}" "${parserTestsPathBase}/lib/sh-unittestprogram.xsl" "${xmlDescription}" || error "Failed to create ${xshBodyFile}"  
		
		for s in ${available_shells[*]}
		do
			shScript="${tmpScriptBasename}.${s}"
			shScripts[${#shScripts[*]}]="${shScript}"
			buildShScriptArgs=(\
				-i ${s} \
				-p \
				-x "${xmlDescription}" \
				-s "${xshFile}" \
				-o "${shScript}"\
			)
			log "Generating ${app} ${s} program (${buildShScriptArgs[@]})"
			"${projectPath}/ns/sh/build-shellscript.sh" "${buildShScriptArgs[@]}" || error "Failed to create ${shScript}" 
			chmod 755 "${shScript}"
		done
		
		${keepTemporaryFiles} || rm -f "${xshBodyFile}"
	fi
	
	if ${testPython}
	then
		log "Generate python script"
		pyScript="${tmpScriptBasename}.py"
		xsltproc --xinclude -o "${pyScript}" --stringparam interpreter ${pythonInterpreter} "${parserTestsPathBase}/lib/python-unittestprogram.xsl" "${xmlDescription}" || error "Failed to create ${pyScript}"
		chmod 755 "${pyScript}"
		
		# Create python module
		"${projectPath}/ns/sh/build-pyscript.sh" -p "${pyScript}" -u -x "${xmlDescription}"
	fi
	
	if ${testC}
	then
		cParserBase="${tmpScriptBasename}-parser"
		cProgram="${tmpScriptBasename}-exe"
		xsltproc --xinclude -o "${cProgram}.c" \
			"${parserTestsPathBase}/lib/c-unittestprogram.xsl" \
			"${xmlDescription}" || error "Failed to create ${cProgram} source"
		
		log "Create C files"
		"${projectPath}/ns/sh/build-c.sh" -eu \
			-x "${xmlDescription}" \
			-o "$(dirname "${tmpScriptBasename}")" \
			-f "$(basename "${cParserBase}")" \
			-p "app" || error "Failed to generated C parser"
			
		log "Build C program"
		gcc -Wall -pedantic -g -O0 \
		-o "${cProgram}" \
		"${cProgram}.c" "${cParserBase}.c" || error "Failed to build C program"   
	fi
	
	if ${testPHP}
	then
		phpLibrary="${tmpScriptBasename}-lib.php"
		phpProgram="${tmpScriptBasename}-exe.php"
		log "Create PHP program info"
		"${projectPath}/ns/sh/build-php.sh" -e \
			-x "${xmlDescription}" \
			-c "TestProgramInfo" \
			-o "${phpLibrary}" || error "Failed to generated PHP module"
			
		log "Create program"
		xsltproc --xinclude -o "${phpProgram}" \
			"${parserTestsPathBase}/lib/php-unittestprogram.xsl" \
			"${xmlDescription}" || error "Failed to create ${phpProgram}"
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
for s in ${available_shells[*]}
do
	shScript="${shScripts[${shi}]}"
	echo "\"${shScript}\" "${cli[@]}" > \"${result}-${s}\" 2>>\"${logFile}\""
	shi=$(expr ${shi} + 1)
done)
EOFSH
		fi
		if ${testPython} && [ ! -f "${base}.no-py" ]
		then
			cat >> "${tmpShellScript}" << EOFSH
"${pyScript}" ${cli} > "${result}-py"  2>>"${logFile}"
EOFSH
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
					for s in ${available_shells[*]}
					do
						resultLine[${#resultLine[@]}]="skipped"
					done
				else
					for s in ${available_shells[*]}
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
					resultLine[${#resultLine[@]}]="skipped"
				else
					if [ ! -f "${result}-py" ] || ! diff "${expected}" "${result}-py" >> "${logFile}"
					then
						passed=false
						resultLine[${#resultLine[@]}]="FAILED"
					else
						resultLine[${#resultLine[@]}]="passed"
						${keepTemporaryFiles} || rm -f "${result}-py"
					fi
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
				for s in ${available_shells[*]}
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
				cp "${result}-python" "${expected}"
			elif ${testPHP}
			then
				cp "${result}-php" "${expected}"
			elif ${testSb}
			then
				for s in ${available_shells[*]}
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
		for s in ${available_shells[*]}
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
		if [ $(find "${d}/tests" -name "*.result-py" | wc -l) -eq 0 ]
		then
			${keepTemporaryFiles} || rm -f "${pyScript}"
			${keepTemporaryFiles} || rm -fr "${d}/Program"
		fi
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
			${keepTemporaryFiles} || rm -f "${cProgram}.dSYM"
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

exit $(find "${parserTestsPathBase}" -name "*.result-*" | wc -l)


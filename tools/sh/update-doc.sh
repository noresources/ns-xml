#!/usr/bin/env bash
# ####################################
# Copyright © 2012 by Renaud Guillard (dev@niao.fr)
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
  update-doc [--help] [--xsl-output <path>] [--xsl-css <path>] [(--index-url <...> --relative-index-url | --index <path> --index-name <...> --copy-anywhere)]
  With:
    --help: Display program usage
    --xsl-output: XSLT output path
    --xsl-css: XSLT CSS file
    Directory index settings
    	URL
    		--index-url: Index URL
    		--relative-index-url: Index URL is relative to root
    	
    	File
    		--index: Index page source file path
    		--index-name: Index page output file name	
    			Default value: index.php
    		--copy-anywhere: Copy index file in all directories
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
indexUrlRelativeToRoot=false
indexCopyInFolders=false
# Single argument options

xsltDocOutputPath=
xsltDocCssFile=
indexUrl=
indexFile=
indexFileOutputName="index.php"

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
			parse_setoptionpresence G_1_help
			;;
		xsl-output)
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
			parse_setoptionpresence G_2_xsl-output
			;;
		xsl-css)
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
			parse_setoptionpresence G_3_xsl-css
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
			parse_setoptionpresence G_4_g_1_g_1_index-url;parse_setoptionpresence G_4_g_1_g;parse_setoptionpresence G_4_g
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
			parse_setoptionpresence G_4_g_1_g_2_relative-index-url;parse_setoptionpresence G_4_g_1_g;parse_setoptionpresence G_4_g
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
			parse_setoptionpresence G_4_g_2_g_1_index;parse_setoptionpresence G_4_g_2_g;parse_setoptionpresence G_4_g
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
			parse_setoptionpresence G_4_g_2_g_2_index-name;parse_setoptionpresence G_4_g_2_g;parse_setoptionpresence G_4_g
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
			parse_setoptionpresence G_4_g_2_g_3_copy-anywhere;parse_setoptionpresence G_4_g_2_g;parse_setoptionpresence G_4_g
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
ns_sed_inplace()
{
	local regex
	if [ $# -gt 0 ]
	then
		regex="${1}"
		shift
	fi
	# sedForm
	# 1: modern linux => sed --in-place
	# 2: Mac OS X 10.5 => sed -i ""
	local sedForm=1
	if [ "$(uname -s)" == "Darwin" ]
	then
		local macOSXVersion="$(sw_vers -productVersion)"
		if [ ! -z "${macOSXVersion}" ]
		then
			local macOSXMajorVersion="$(echo "${macOSXVersion}" | cut -f 1 -d".")"
			local macOSXMinorVersion="$(echo "${macOSXVersion}" | cut -f 2 -d".")"
			if [ ${macOSXMajorVersion} -eq 10 ] && [ ${macOSXMinorVersion} -le 5 ]
			then
				sedForm=2
			fi
		fi	
	fi
	
	while [ $# -gt 0 ]
	do	
		if [ ${sedForm} -eq 1 ]
		then
			sed --in-place "${regex}" "${1}"
		elif [ ${sedForm} -eq 2 ]
		then
			sed -i "" "${regex}" "${1}"
		fi
		
		shift
	done
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
rootPath="$(ns_realpath "${scriptPath}/../..")"
creolePath="${rootPath}/doc/wiki/creole"
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

for tool in nme find xsltproc
do
	which ${tool} 1>/dev/null 2>&1 || (echo "${tool} not found" && exit 1)
done

if update_item creole
then
	appXshPath="${rootPath}/ns/xsh/apps"
	outputPath="${creolePath}/apps"

	# TODO get program version 
	creoleXslStylesheet="${xslPath}/program/2.0/wikicreole-usage.xsl"

	find "${appXshPath}" -name "*.xml" | while read f
	do
		b="$(basename "${f}")"
		xsltproc --xinclude -o "${outputPath}/${b%xml}wiki" "${creoleXslStylesheet}" "${f}" 
	done
fi

if update_item html && which nme 1>/dev/null 2>&1
then
	htmlArticlePath="${rootPath}/doc/html/articles"
	
	for e in wiki jpg png gif
	do
		find "${creolePath}" -name "*.${e}" | while read f
		do
			#output="${htmlArticlePath}${f#${creolePath}}"
			
			#output="$(echo "${f#${creolePath}}" | tr -d "/")"
			#output="${htmlArticlePath}/${output}"
			
			output="$(filesystempath_to_nmepath "${creolePath}" "${htmlArticlePath}" "${f}")"
			
			[ "${e}" == "wiki" ] && output="${output%wiki}html"
			echo "${output}"
			mkdir -p "$(dirname "${output}")"
			if [ "${e}" == "wiki" ]
			then
				nme --easylink "$.html" < "${f}" > "${output}"
				ns_sed_inplace "s/\.\(png\|jpg\|gif\)\.html/.\1/g" "${output}"
			else
				rsync -lprt "${f}" "${output}"
			fi
		done
	done
fi

xslStylesheet="${xslPath}/languages/xsl/documentation-html.xsl"
defaultCssFile="${rootPath}/resources/css/xsl.doc.html.css"

if update_item xsl
then
	[ -z "${xsltDocOutputPath}" ] && xsltDocOutputPath="${rootPath}/doc/html/xsl"
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
	fi
		
	find "${xslPath}" -name "*.xsl" | while read f
	do
		output="${f#${xslPath}}"
		output="${xsltDocOutputPath}${output}"
		output="${output%xsl}html"
		outputFolder="$(dirname "${output}")"
		mkdir -p "${outputFolder}"
		cssPath="$(ns_relativepath "${xsltDocCssFile}" "${outputFolder}")"
		title="${output#${xsltDocOutputPath}/}"
		title="${title%.html}"
		 
		
		if [ "${indexMode}" = "indexModeUrl" ]
		then
			echo -n ""
		elif [ "${indexMode}" = "indexModeFile" ]
		then
			outputIndexPath="${outputFolder}/${indexFileOutputName}"
			if ${indexCopyInFolders} && [ "${indexFile}" != "${outputIndexPath}" ]
			then
				cp -pf "${indexFile}" "${outputIndexPath}"
			fi
		fi
		
		xsltproc --xinclude -o "${output}" \
			--stringparam "xsl.doc.html.fileName" "${title}" \
			--stringparam "xsl.doc.html.stylesheetPath" "${cssPath}" \
			--stringparam "xsl.doc.html.directoryIndexPathMode" "${xslDirectoryIndexMode}" \
			--stringparam "xsl.doc.html.directoryIndexPath" "${indexFileOutputName}" \
			"${xslStylesheet}" "${f}"

	done
fi

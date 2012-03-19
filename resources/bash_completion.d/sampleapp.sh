__sampleapp_getoptionname()
{
	local arg="${1}"
	if [ "${arg}" = "--" ]
	then
		# End of options marker
		return 0
	fi
	if [ "${arg:0:2}" = "--" ]
	then
		# It's a long option
		echo "${arg:2}"
		return 0
	fi
	if [ "${arg:0:1}" = "-" ] && [ ${#arg} -gt 1 ]
	then
		# It's a short option (or a combination of)
		local index="$(expr ${#arg} - 1)"
		echo "${arg:${index}}"
		return 0
	fi
}

__sampleapp_getfindpermoptions()
{
	local access="${1}"
	local res=""
	while [ ! -z "${access}" ]
	do
		res="${res} -perm /u=${access:0:1},g=${access:0:1},o==${access:0:1}"
		access="${access:1}"
	done
	echo "${res}"
}

__sampleapp_appendfsitems()
{
	local current="${1}"
	shift
	local currentLength="${#current}"
	local d
	local b
	local isHomeShortcut=false
	[ "${current:0:1}" == "~" ] && current="${HOME}${current:1}" && isHomeShortcut=true
	if [ "${current:$(expr ${currentLength} - 1)}" == "/" ]
	then
		d="${current%/}"
		b=""
	else
		d="$(dirname "${current}")"
		b="$(basename "${current}")"
	fi
	
	local findCommand="find \"${d}\" -mindepth 1 -maxdepth 1 -name \"${b}*\" -a \\( ${@} \\)"
	local files="$(eval ${findCommand} | while read file; do printf "%q\n" "${file#./}"; done)"
	local IFS=$'\n'
	local temporaryRepliesArray=(${files})
	for ((i=0;${i}<${#temporaryRepliesArray[*]};i++))
	do
		local p="${temporaryRepliesArray[$i]}"
		[ "${d}" != "." ] && p="${d}/$(basename "${p}")"
		[ -d "${p}" ] && p="${p%/}/"
		temporaryRepliesArray[$i]="${p}"
	done
	for ((i=0;${i}<${#temporaryRepliesArray[*]};i++))
	do
		COMPREPLY[${#COMPREPLY[*]}]="${temporaryRepliesArray[${i}]}"
	done
}

__sc_sub_bashcompletion()
{
	# Context
	local current="${COMP_WORDS[COMP_CWORD]}"
	local previous="${COMP_WORDS[COMP_CWORD-1]}"
	# argument option
	local option="$(__sampleapp_getoptionname ${previous})"
	if [ -z "${option}" ]
	then
		return 1
	fi
	
	
	case "${option}" in
	"sc-existing-file-argument")
		__sampleapp_appendfsitems "${current}"  
		if [ ${#COMPREPLY[*]} -gt 0 ]
		then
			return 0
		fi
		
		;;
	"sc-strict-enum")
		COMPREPLY=()
		for e in "OptionA" "ValueB" "ItemC"
		do
			local res="$(compgen -W "${e}" -- "${current}")"
			if [ ! -z "${res}" ]
			then
				COMPREPLY[${#COMPREPLY[*]}]="\"${e}\" "
			fi
		done
		if [ ${#COMPREPLY[*]} -gt 0 ]
		then
			return 0
		fi
		
		;;
	
	esac
	return 1
}
__sc_help_bashcompletion()
{
	# Context
	local current="${COMP_WORDS[COMP_CWORD]}"
	local previous="${COMP_WORDS[COMP_CWORD-1]}"
	# argument option
	local option="$(__sampleapp_getoptionname ${previous})"
	if [ -z "${option}" ]
	then
		return 1
	fi
	
	
	case "${option}" in
	
	esac
	return 1
}
__sc_version_bashcompletion()
{
	# Context
	local current="${COMP_WORDS[COMP_CWORD]}"
	local previous="${COMP_WORDS[COMP_CWORD-1]}"
	# argument option
	local option="$(__sampleapp_getoptionname ${previous})"
	if [ -z "${option}" ]
	then
		return 1
	fi
	
	
	case "${option}" in
	
	esac
	return 1
}

__sampleapp_bashcompletion()
{
	#Context
	COMPREPLY=()
	local current="${COMP_WORDS[COMP_CWORD]}"
	local previous="${COMP_WORDS[COMP_CWORD-1]}"
	local first="${COMP_WORDS[1]}"
	local globalargs="--help --ui-only --standard-arg --simpleswitch --switch-alone-in-group --basic-argument --string-argument --argument-with-default --numeric-argument --float-argument --existing-file-argument --rw-folder-argument --mixed-fskind-argument --multi-argument --multi-select-argument --multi-xml --hostname --simple-pattern-sh --strict-enum --non-strict-enum -s -H -P -E -e"
	local args="${globalargs}"
	
	# Subcommand proposal
	if [ ${COMP_CWORD} -eq 1 ]
	then
		local subcommands="sub help version"
		COMPREPLY=( $(compgen -W "${globalargs} ${subcommands}" -- ${current}) )
		local temporaryRepliesArray=( $(compgen -fd -- "${current}") )
		for ((i=0;${i}<${#temporaryRepliesArray[*]};i++))
		do
			[ -d "${temporaryRepliesArray[$i]}" ] && temporaryRepliesArray[$i]="${temporaryRepliesArray[$i]%/}/"
		done
		for ((i=0;${i}<${#temporaryRepliesArray[*]};i++))
		do
			COMPREPLY[${#COMPREPLY[*]}]="${temporaryRepliesArray[${i}]}"
		done
		for ((i=0;$i<${#COMPREPLY[*]};i++)); do COMPREPLY[${i}]="${COMPREPLY[${i}]} ";done
		
		return 0
	fi
	
	# Subcommand option argument proposal
	local sc_function_name="__sc_${first}_bashcompletion"
	if [ "$(type -t ${sc_function_name})" = "function" ] && ${sc_function_name}
	then
		return 0
	fi
	
	# Subcommand option completion
	case "${first}" in
	"sub")
		args="--switch --sc-switch --sc-existing-file-argument --sc-strict-enum ${globalargs}"
		;;
	"help")
		args=" ${globalargs}"
		;;
	"version")
		args=" ${globalargs}"
		;;
	
	esac
	
	# Option proposal
	if [[ ${current} == -* ]]
	then
		COMPREPLY=( $(compgen -W "${args}" -- ${current}) )
		for ((i=0;$i<${#COMPREPLY[*]};i++)); do COMPREPLY[${i}]="${COMPREPLY[${i}]} ";done
		return 0
	fi
	
	# Option argument proposal
	local option="$(__sampleapp_getoptionname ${previous})"
	if [ ! -z "${option}" ]
	then
		case "${option}" in
		"ui-only")
			local temporaryRepliesArray=( $(compgen -fd -- "${current}") )
			for ((i=0;${i}<${#temporaryRepliesArray[*]};i++))
			do
				[ -d "${temporaryRepliesArray[$i]}" ] && temporaryRepliesArray[$i]="${temporaryRepliesArray[$i]%/}/"
			done
			for ((i=0;${i}<${#temporaryRepliesArray[*]};i++))
			do
				COMPREPLY[${#COMPREPLY[*]}]="${temporaryRepliesArray[${i}]}"
			done
			if [ ${#COMPREPLY[*]} -gt 0 ]
			then
				return 0
			fi
			
			;;
		"standard-arg")
			local temporaryRepliesArray=( $(compgen -fd -- "${current}") )
			for ((i=0;${i}<${#temporaryRepliesArray[*]};i++))
			do
				[ -d "${temporaryRepliesArray[$i]}" ] && temporaryRepliesArray[$i]="${temporaryRepliesArray[$i]%/}/"
			done
			for ((i=0;${i}<${#temporaryRepliesArray[*]};i++))
			do
				COMPREPLY[${#COMPREPLY[*]}]="${temporaryRepliesArray[${i}]}"
			done
			if [ ${#COMPREPLY[*]} -gt 0 ]
			then
				return 0
			fi
			
			;;
		"basic-argument")
			local temporaryRepliesArray=( $(compgen -fd -- "${current}") )
			for ((i=0;${i}<${#temporaryRepliesArray[*]};i++))
			do
				[ -d "${temporaryRepliesArray[$i]}" ] && temporaryRepliesArray[$i]="${temporaryRepliesArray[$i]%/}/"
			done
			for ((i=0;${i}<${#temporaryRepliesArray[*]};i++))
			do
				COMPREPLY[${#COMPREPLY[*]}]="${temporaryRepliesArray[${i}]}"
			done
			if [ ${#COMPREPLY[*]} -gt 0 ]
			then
				return 0
			fi
			
			;;
		"string-argument")
			[ ${#COMPREPLY[*]} -eq 0 ] && COMPREPLY[0]="\"${current#\"}"
			return 0
			if [ ${#COMPREPLY[*]} -gt 0 ]
			then
				return 0
			fi
			
			;;
		"argument-with-default")
			local temporaryRepliesArray=( $(compgen -fd -- "${current}") )
			for ((i=0;${i}<${#temporaryRepliesArray[*]};i++))
			do
				[ -d "${temporaryRepliesArray[$i]}" ] && temporaryRepliesArray[$i]="${temporaryRepliesArray[$i]%/}/"
			done
			for ((i=0;${i}<${#temporaryRepliesArray[*]};i++))
			do
				COMPREPLY[${#COMPREPLY[*]}]="${temporaryRepliesArray[${i}]}"
			done
			if [ ${#COMPREPLY[*]} -gt 0 ]
			then
				return 0
			fi
			
			;;
		"numeric-argument")
			local temporaryRepliesArray=( $(compgen -fd -- "${current}") )
			for ((i=0;${i}<${#temporaryRepliesArray[*]};i++))
			do
				[ -d "${temporaryRepliesArray[$i]}" ] && temporaryRepliesArray[$i]="${temporaryRepliesArray[$i]%/}/"
			done
			for ((i=0;${i}<${#temporaryRepliesArray[*]};i++))
			do
				COMPREPLY[${#COMPREPLY[*]}]="${temporaryRepliesArray[${i}]}"
			done
			if [ ${#COMPREPLY[*]} -gt 0 ]
			then
				return 0
			fi
			
			;;
		"float-argument")
			local temporaryRepliesArray=( $(compgen -fd -- "${current}") )
			for ((i=0;${i}<${#temporaryRepliesArray[*]};i++))
			do
				[ -d "${temporaryRepliesArray[$i]}" ] && temporaryRepliesArray[$i]="${temporaryRepliesArray[$i]%/}/"
			done
			for ((i=0;${i}<${#temporaryRepliesArray[*]};i++))
			do
				COMPREPLY[${#COMPREPLY[*]}]="${temporaryRepliesArray[${i}]}"
			done
			if [ ${#COMPREPLY[*]} -gt 0 ]
			then
				return 0
			fi
			
			;;
		"existing-file-argument")
			__sampleapp_appendfsitems "${current}"  
			if [ ${#COMPREPLY[*]} -gt 0 ]
			then
				return 0
			fi
			
			;;
		"rw-folder-argument")
			__sampleapp_appendfsitems "${current}" $(__sampleapp_getfindpermoptions rw) -type d 
			if [ ${#COMPREPLY[*]} -gt 0 ]
			then
				return 0
			fi
			
			;;
		"mixed-fskind-argument")
			__sampleapp_appendfsitems "${current}" $(__sampleapp_getfindpermoptions rw) -type f -o -type d -o -type l 
			if [ ${#COMPREPLY[*]} -gt 0 ]
			then
				return 0
			fi
			
			;;
		"hostname" | "H")
			local temporaryRepliesArray=( $(compgen -A hostname -- "${current}") )
			for ((i=0;${i}<${#temporaryRepliesArray[*]};i++))
			do
				COMPREPLY[${#COMPREPLY[*]}]="${temporaryRepliesArray[${i}]}"
			done
			if [ ${#COMPREPLY[*]} -gt 0 ]
			then
				return 0
			fi
			
			;;
		"simple-pattern-sh" | "P")
			__sampleapp_appendfsitems "${current}" $(__sampleapp_getfindpermoptions x)  -name \"*.sh\" -o -name \"*.run\" -o -name \"*.xsh\" 
			if [ ${#COMPREPLY[*]} -gt 0 ]
			then
				return 0
			fi
			
			;;
		"strict-enum" | "E")
			COMPREPLY=()
			for e in "Option A" "Value B" "Item C" "ItemD with space"
			do
				local res="$(compgen -W "${e}" -- "${current}")"
				if [ ! -z "${res}" ]
				then
					COMPREPLY[${#COMPREPLY[*]}]="\"${e}\" "
				fi
			done
			if [ ${#COMPREPLY[*]} -gt 0 ]
			then
				return 0
			fi
			
			;;
		"non-strict-enum" | "e")
			COMPREPLY=()
			for e in "nOptionA" "nValueB" "nItemC" "nItemD with space"
			do
				local res="$(compgen -W "${e}" -- "${current}")"
				if [ ! -z "${res}" ]
				then
					COMPREPLY[${#COMPREPLY[*]}]="\"${e}\" "
				fi
			done
			local temporaryRepliesArray=( $(compgen -fd -- "${current}") )
			for ((i=0;${i}<${#temporaryRepliesArray[*]};i++))
			do
				[ -d "${temporaryRepliesArray[$i]}" ] && temporaryRepliesArray[$i]="${temporaryRepliesArray[$i]%/}/"
			done
			for ((i=0;${i}<${#temporaryRepliesArray[*]};i++))
			do
				COMPREPLY[${#COMPREPLY[*]}]="${temporaryRepliesArray[${i}]}"
			done
			if [ ${#COMPREPLY[*]} -gt 0 ]
			then
				return 0
			fi
			
			;;
		
		esac
	fi
	
	# Last hope: files and folders
	COMPREPLY=( $(compgen -fd -- "${current}") )
	for ((i=0;${i}<${#COMPREPLY[*]};i++))
	do
		[ -d "${COMPREPLY[$i]}" ] && COMPREPLY[$i]="${COMPREPLY[$i]%/}/"
	done
	return 0
}
complete -o nospace -F __sampleapp_bashcompletion sampleapp.sh

__build_c_getoptionname()
{
	local arg="${1}"
	if [ "${arg}" = '--' ]
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

__build_c_getfindpermoptions()
{
	local access="${1}"
	local res=''
	local permPrefix='/'
	[ "$(uname -s)"  = 'Darwin' ] && permPrefix='+'
	while [ ! -z "${access}" ]
	do
		res="${res} -perm ${permPrefix}u=${access:0:1},g=${access:0:1},o=${access:0:1}"
		access="${access:1}"
	done
	echo "${res}"
}

__build_c_appendfsitems()
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
		b=''
	else
		d="$(dirname "${current}")"
		b="$(basename "${current}")"
	fi
	
	if [ -d "${d}" ]
	then
		local findCommand="find \"${d}\" -mindepth 1 -maxdepth 1 -name \"${b}*\" -a \\( ${@} \\)"
		local files="$(eval ${findCommand} | while read file; do printf "%q\n" "${file#./}"; done)"
		local IFS=$'\n'
		local temporaryRepliesArray=(${files})
		for ((i=0;${i}<${#temporaryRepliesArray[*]};i++))
		do
			local p="${temporaryRepliesArray[$i]}"
			[ "${d}" != "." ] && p="${d}/$(basename "${p}")"
			[ -d "${p}" ] && p="${p%/}/"
			temporaryRepliesArray[$i]="${p} "
		done
		for ((i=0;${i}<${#temporaryRepliesArray[*]};i++))
		do
			COMPREPLY[${#COMPREPLY[*]}]="${temporaryRepliesArray[${i}]}"
		done
	fi
}


__build_c_bashcompletion()
{
	#Context
	COMPREPLY=()
	local current="${COMP_WORDS[COMP_CWORD]}"
	local previous="${COMP_WORDS[COMP_CWORD-1]}"
	local first="${COMP_WORDS[1]}"
	local globalargs="--base --schema-version --xml-description --skip-validation --no-validation --embed --include --prefix --struct-style --struct --function-style --function --func --variable-style --variable --var --output --file-base --file --overwrite --force --ns-xml-path --ns-xml-path-relative --help"
	local args="${globalargs}"
	
	
	# Option proposal
	if [[ ${current} == -* ]]
	then
		COMPREPLY=( $(compgen -W "${args}" -- ${current}) )
		for ((i=0;$i<${#COMPREPLY[*]};i++)); do COMPREPLY[${i}]="${COMPREPLY[${i}]} ";done
		return 0
	fi
	
	# Option argument proposal
	local option="$(__build_c_getoptionname ${previous})"
	if [ ! -z "${option}" ]
	then
		case "${option}" in
		"schema-version")
			COMPREPLY=()
			for e in "2.0"
			do
				local res="$(compgen -W "${e}" -- "${current}")"
				[ ! -z "${res}" ] && COMPREPLY[${#COMPREPLY[*]}]="\"${e}\" "
			done
			[ ${#COMPREPLY[*]} -gt 0 ] && return 0
			
			;;
		"xml-description" | "x")
			__build_c_appendfsitems "${current}"  -type f 
			[ ${#COMPREPLY[*]} -gt 0 ] && return 0
			
			;;
		"include" | "i")
			__build_c_appendfsitems "${current}"  -type f 
			[ ${#COMPREPLY[*]} -gt 0 ] && return 0
			
			;;
		"prefix" | "p")
			local temporaryRepliesArray=( $(compgen -fd -- "${current}") )
			for ((i=0;${i}<${#temporaryRepliesArray[*]};i++))
			do
				[ -d "${temporaryRepliesArray[$i]}" ] && temporaryRepliesArray[$i]="${temporaryRepliesArray[$i]%/}/"
			done
			for ((i=0;${i}<${#temporaryRepliesArray[*]};i++))
			do
				COMPREPLY[${#COMPREPLY[*]}]="${temporaryRepliesArray[${i}]}"
			done
			[ ${#COMPREPLY[*]} -gt 0 ] && return 0
			
			;;
		"struct-style" | "struct")
			COMPREPLY=()
			for e in "underscore" "camelCase" "PascalCase" "CamelCase" "none"
			do
				local res="$(compgen -W "${e}" -- "${current}")"
				[ ! -z "${res}" ] && COMPREPLY[${#COMPREPLY[*]}]="\"${e}\" "
			done
			[ ${#COMPREPLY[*]} -gt 0 ] && return 0
			
			;;
		"function-style" | "function" | "func")
			COMPREPLY=()
			for e in "underscore" "camelCase" "PascalCase" "CamelCase" "none"
			do
				local res="$(compgen -W "${e}" -- "${current}")"
				[ ! -z "${res}" ] && COMPREPLY[${#COMPREPLY[*]}]="\"${e}\" "
			done
			[ ${#COMPREPLY[*]} -gt 0 ] && return 0
			
			;;
		"variable-style" | "variable" | "var")
			COMPREPLY=()
			for e in "underscore" "camelCase" "PascalCase" "CamelCase" "none"
			do
				local res="$(compgen -W "${e}" -- "${current}")"
				[ ! -z "${res}" ] && COMPREPLY[${#COMPREPLY[*]}]="\"${e}\" "
			done
			[ ${#COMPREPLY[*]} -gt 0 ] && return 0
			
			;;
		"output" | "o")
			__build_c_appendfsitems "${current}"  -type d 
			[ ${#COMPREPLY[*]} -gt 0 ] && return 0
			
			;;
		"file-base" | "file" | "f")
			local temporaryRepliesArray=( $(compgen -fd -- "${current}") )
			for ((i=0;${i}<${#temporaryRepliesArray[*]};i++))
			do
				[ -d "${temporaryRepliesArray[$i]}" ] && temporaryRepliesArray[$i]="${temporaryRepliesArray[$i]%/}/"
			done
			for ((i=0;${i}<${#temporaryRepliesArray[*]};i++))
			do
				COMPREPLY[${#COMPREPLY[*]}]="${temporaryRepliesArray[${i}]}"
			done
			[ ${#COMPREPLY[*]} -gt 0 ] && return 0
			
			;;
		"ns-xml-path")
			__build_c_appendfsitems "${current}"  -type d 
			[ ${#COMPREPLY[*]} -gt 0 ] && return 0
			
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
complete -o nospace -F __build_c_bashcompletion build-c.sh

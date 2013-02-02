__build_xulapp_getoptionname()
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

__build_xulapp_getfindpermoptions()
{
	local access="${1}"
	local res=""
	while [ ! -z "${access}" ]
	do
		res="${res} -perm /u=${access:0:1},g=${access:0:1},o=${access:0:1}"
		access="${access:1}"
	done
	echo "${res}"
}

__build_xulapp_appendfsitems()
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
			temporaryRepliesArray[$i]="${p}"
		done
		for ((i=0;${i}<${#temporaryRepliesArray[*]};i++))
		do
			COMPREPLY[${#COMPREPLY[*]}]="${temporaryRepliesArray[${i}]}"
		done
	fi
}

__sc_php_bashcompletion()
{
	# Context
	local current="${COMP_WORDS[COMP_CWORD]}"
	local previous="${COMP_WORDS[COMP_CWORD-1]}"
	# argument option
	local option="$(__build_xulapp_getoptionname ${previous})"
	if [ -z "${option}" ]
	then
		return 1
	fi
	
	
	case "${option}" in
	"script-path" | "path")
		__build_xulapp_appendfsitems "${current}"  -type f 
		if [ ${#COMPREPLY[*]} -gt 0 ]
		then
			return 0
		fi
		
		;;
	"copy-script" | "copy")
		__build_xulapp_appendfsitems "${current}" $(__build_xulapp_getfindpermoptions r)  -type f 
		if [ ${#COMPREPLY[*]} -gt 0 ]
		then
			return 0
		fi
		
		;;
	"build-script" | "build" | "merge")
		__build_xulapp_appendfsitems "${current}" $(__build_xulapp_getfindpermoptions r)  -type f 
		if [ ${#COMPREPLY[*]} -gt 0 ]
		then
			return 0
		fi
		
		;;
	"parser-namespace" | "parser-ns")
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
	"program-namespace" | "program-ns" | "prg-ns")
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
	"classname" | "c")
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
	return 1
}
__sc_xsh_bashcompletion()
{
	# Context
	local current="${COMP_WORDS[COMP_CWORD]}"
	local previous="${COMP_WORDS[COMP_CWORD-1]}"
	# argument option
	local option="$(__build_xulapp_getoptionname ${previous})"
	if [ -z "${option}" ]
	then
		return 1
	fi
	
	
	case "${option}" in
	"shell" | "s")
		__build_xulapp_appendfsitems "${current}"  -type f 
		if [ ${#COMPREPLY[*]} -gt 0 ]
		then
			return 0
		fi
		
		;;
	"interpreter" | "i")
		COMPREPLY=()
		for e in "bash" "zsh" "ksh"
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
	"interpreter-cmd" | "I")
		COMPREPLY=()
		for e in "/usr/bin/env bash" "/bin/bash" "/usr/bin/env zsh" "/bin/zsh"
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
	return 1
}
__sc_python_bashcompletion()
{
	# Context
	local current="${COMP_WORDS[COMP_CWORD]}"
	local previous="${COMP_WORDS[COMP_CWORD-1]}"
	# argument option
	local option="$(__build_xulapp_getoptionname ${previous})"
	if [ -z "${option}" ]
	then
		return 1
	fi
	
	
	case "${option}" in
	"python" | "p")
		__build_xulapp_appendfsitems "${current}"  -type f 
		if [ ${#COMPREPLY[*]} -gt 0 ]
		then
			return 0
		fi
		
		;;
	"module-name" | "module" | "m")
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
	return 1
}
__sc_command_bashcompletion()
{
	# Context
	local current="${COMP_WORDS[COMP_CWORD]}"
	local previous="${COMP_WORDS[COMP_CWORD-1]}"
	# argument option
	local option="$(__build_xulapp_getoptionname ${previous})"
	if [ -z "${option}" ]
	then
		return 1
	fi
	
	
	case "${option}" in
	"command" | "cmd" | "c")
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
	return 1
}
__sc_sh_bashcompletion()
{
	__sc_xsh_bashcompletion
}
__sc_shell_bashcompletion()
{
	__sc_xsh_bashcompletion
}
__sc_py_bashcompletion()
{
	__sc_python_bashcompletion
}
__sc_cmd_bashcompletion()
{
	__sc_command_bashcompletion
}

__build_xulapp_bashcompletion()
{
	#Context
	COMPREPLY=()
	local current="${COMP_WORDS[COMP_CWORD]}"
	local previous="${COMP_WORDS[COMP_CWORD-1]}"
	local first="${COMP_WORDS[1]}"
	local globalargs="--help --output --xml-description --target-platform --target --update --skip-validation --no-validation --window-width --window-height --debug --init-script --resources --ns-xml-path --ns-xml-path-relative --ns --ns-xml-add -o -x -t -u -S"
	local args="${globalargs}"
	
	# Subcommand proposal
	if [ ${COMP_CWORD} -eq 1 ]
	then
		local subcommands="php xsh python command sh shell py cmd"
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
	"php")
		args=" ${globalargs}"
		;;
	"xsh" | "sh" | "shell")
		args="--shell --prefix-sc-variables -s -p ${globalargs}"
		;;
	"python" | "py")
		args="--python --module-name --module -p -m ${globalargs}"
		;;
	"command" | "cmd")
		args="--command --cmd -c ${globalargs}"
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
	local option="$(__build_xulapp_getoptionname ${previous})"
	if [ ! -z "${option}" ]
	then
		case "${option}" in
		"output" | "o")
			__build_xulapp_appendfsitems "${current}"  -type d 
			if [ ${#COMPREPLY[*]} -gt 0 ]
			then
				return 0
			fi
			
			;;
		"xml-description" | "x")
			__build_xulapp_appendfsitems "${current}"  -name \"*xml\" -o -name \"*XML\" -type f 
			if [ ${#COMPREPLY[*]} -gt 0 ]
			then
				return 0
			fi
			
			;;
		"target-platform" | "target" | "t")
			COMPREPLY=()
			for e in "host" "linux" "macosx"
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
		"window-width" | "W")
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
		"window-height" | "H")
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
		"init-script" | "j")
			__build_xulapp_appendfsitems "${current}"  -type f 
			if [ ${#COMPREPLY[*]} -gt 0 ]
			then
				return 0
			fi
			
			;;
		"ns-xml-path")
			__build_xulapp_appendfsitems "${current}"  -type d 
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
complete -o nospace -F __build_xulapp_bashcompletion build-xulapp.sh

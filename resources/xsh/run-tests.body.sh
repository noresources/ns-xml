scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
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
testPathBase="${projectPath}/unittests"
tmpShellStylesheet="$(mktemp --suffix .xsl)"
programVersion="2.0"
xshStylesheet="${projectPath}/ns/xsl/program/${programVersion}/xsh.xsl"
logFile="${projectPath}/${scriptName}.log"
pythonInterpreters=(python2.6 python2.7 python)
rm -f "${logFile}"

#http://stackoverflow.com/questions/4332478/read-the-current-text-color-in-a-xterm/4332530#4332530
#NORMAL_COLOR="$(tput sgr0)"
#ERROR_COLOR="$(tput setaf 1)"
#SUCCESS_COLOR="$(tput setaf 2)"
NORMAL_COLOR=""
ERROR_COLOR=""
SUCCESS_COLOR=""

error()
{
	echo "Error: ${@}"
	exit 1
}

log()
{
	echo "${@}" >> "${logFile}"
}

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
shells=(bash zsh)
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

# Test groups
if [ ${#apps[@]} -eq 0 ]
then
	while read d
	do
		selectedApps[${#selectedApps[@]}]="$(basename "${d}")"
	done << EOF
	$(find "${testPathBase}" -mindepth 1 -maxdepth 1 -type d -name "app*" | sort)
EOF
else
	for ((a=0;${a}<${#apps[@]};a++))
	do
		d="${testPathBase}/app${apps[${a}]}"
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
if [ ${#parsers[@]} -eq 0 ]
then
	if [ ${#available_shells[@]} -gt 0 ]
	then
		testSh=true
		parsers=("${parsers[@]}" sh)
		parserNames=("${parserNames[@]}" "${available_shells[@]}")
	fi
	if [ ! -z "${pythonInterpreter}" ]
	then
		testPython=true
		parsers=("${parsers[@]}" python)
		parserNames=("${parserNames[@]}" "Python")
	fi
else
	for ((i=0;${i}<${#parsers[@]};i++))
	do
		if [ "${parsers[${i}]}" = "sh" ] && [ ${#available_shells[@]} -gt 0 ]
		then
			parserNames=("${parserNames[@]}" "${available_shells[@]}")
			testSh=true
		elif [ "${parsers[${i}]}" = "python" ] && [ ! -z "${pythonInterpreter}" ]
		then
			parserNames=("${parserNames[@]}" "Python")
			testPython=true
		fi
	done 
fi

echo "Apps: ${selectedApps[@]}"
echo "Parsers: ${parserNames[@]}"

resultLineFormat="    %-10s |"
for s in ${available_shells[*]}
do
	resultLineFormat="${resultLineFormat} %-7s |"	
done

resultLineFormat="${resultLineFormat} %-7s | %7s\n"

for ((ai=0;${ai}<${#selectedApps[@]};ai++))
do
	app="${selectedApps[${ai}]}"
	d="${testPathBase}/${app}"
	
	groupTestBasePath="${d}/tests"
	
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
			tn="${groupTestBasePath}/$(printf "%03d.cli" ${tests[${t}]})"
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
		# Write the test body shell script
		xsltproc --xinclude -o "${d}/xsh/program.body.sh" "${testPathBase}/lib/sh-unittestprogram.xsl" "${xmlDescription}" || error "Failed to create ${d}/xsh/program.body.sh"  
		for s in ${available_shells[*]}
		do
			shScript="${tmpScriptBasename}.${s}"
			shScripts[${#shScripts[*]}]="${shScript}"
			"${projectPath}/ns/sh/build-shellscript.sh" -i "/usr/bin/env ${s}" -p -x "${xmlDescription}" -s "${d}/xsh/program.xsh" -o "${shScript}" || error "Failed to create ${shScript}"
			chmod 755 "${shScript}"
		done
		
		rm -f "${d}/xsh/program.body.sh"
	fi
	
	if ${testPython}
	then
		if [ ! -z "${pythonInterpreter}" ]
		then
			# Generate python script using the xslt stylesheet
			pyScript="${tmpScriptBasename}.py"
			xsltproc --xinclude -o "${pyScript}" --stringparam interpreter ${pythonInterpreter} "${testPathBase}/lib/python-unittestprogram.xsl" "${xmlDescription}" || error "Failed to create ${pyScript}"
			chmod 755 "${pyScript}"
			
			# Create python module
			"${projectPath}/ns/sh/build-pyscript.sh" -p "${pyScript}" -u -x "${xmlDescription}"
		fi
	fi
	
	# Run tests
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
		if ${testSh}
		then
			cat >> "${tmpShellScript}" << EOFSH
$(
shi=0
for s in ${available_shells[*]}
do
	shScript="${shScripts[${shi}]}"
	echo "\"${shScript}\" ${cli} > \"${result}-${s}\""
	shi=$(expr ${shi} + 1)
done)
EOFSH
		fi
		if ${testPython}
		then
			cat >> "${tmpShellScript}" << EOFSH
"${pyScript}" ${cli} > "${result}-py"
EOFSH
		fi
		
		# Run parsers 
		chmod 755 "${tmpShellScript}"	
		"${tmpShellScript}"
		
		resultLine=
		resultLine[0]="    ${testnumber}"
		log " ---- ${app}/${testnumber} ---- "
		passed=true
		if [ -f "${expected}" ]
		then
			i=0
			if ${testSh}
			then
				for s in ${available_shells[*]}
				do
					if ! diff "${expected}" "${result}-${s}" >> "${logFile}"
					then
						passed=false
						resultLine[${#resultLine[*]}]="${ERROR_COLOR}FAILED${NORMAL_COLOR}"
					else
						resultLine[${#resultLine[*]}]="${SUCCESS_COLOR}passed${NORMAL_COLOR}"
						rm -f "${result}-${s}"
					fi
					i=$(expr ${i} + 1)
				done
			fi
			
			if ${testPython}
			then
				if ! diff "${expected}" "${result}-py" >> "${logFile}"
				then
					passed=false
					resultLine[${#resultLine[*]}]="${ERROR_COLOR}FAILED${NORMAL_COLOR}"
				else
					resultLine[${#resultLine[*]}]="${SUCCESS_COLOR}passed${NORMAL_COLOR}"
					rm -f "${result}-py"
				fi
			fi
		else
			passed=true
			
			if ${testSh}
			then
				for s in ${available_shells[*]} python
				do
					resultLine[${#resultLine[*]}]="${SUCCESS_COLOR}IGNORED${NORMAL_COLOR}"
				done
			fi
			
			if ${testPython}
			then
				cp "${result}-python" "${expected}"
			fi
		fi
		
		if ${passed}
		then
			resultLine[${#resultLine[*]}]="${SUCCESS_COLOR}passed${NORMAL_COLOR}"
			rm -f "${tmpShellScript}"
		else
			resultLine[${#resultLine[*]}]="${ERROR_COLOR}FAILED${NORMAL_COLOR}"
		fi
		
		printf "${resultLineFormat}" "${resultLine[@]}"
		unset resultLine
	done
	
	# Remove if no error
	if ${testPython}
	then
		if [ $(find "${d}/tests" -name "*.result-py" | wc -l) -eq 0 ]
		then
			rm -f "${pyScript}"
			rm -fr "${d}/Program"
		fi
	fi
	
	if ${testSh}
	then
		si=0
		for s in ${available_shells[*]}
		do
			if [ $(find "${d}/tests" -name "*.result-${s}" | wc -l) -eq 0 ]
			then
				rm -f "${shScripts[${si}]}"
			fi
			si=$(expr ${si} + 1)
		done
		unset shScripts
	fi
done

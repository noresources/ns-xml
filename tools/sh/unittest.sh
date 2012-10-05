#!/bin/bash
# Copyright (c) 2011 by Renaud Guillard (dev@niao.fr)
################################################################################
# Run unittests
################################################################################

relativePathToRoot="../.."
scriptPath="$(dirname "${0}")"
scriptName="$(basename "${0}")"
projectPath="${scriptPath}/${relativePathToRoot}"

cwd="$(pwd)"
cd "${projectPath}"
projectPath="$(pwd)"
cd "${cwd}"

testPathBase="${projectPath}/unittests"
tmpShellStylesheet="/tmp/${scriptName}-sh-app-body.xsl"
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

run_test()
{
	local script="${1}"
	local app="${2}"
	local testnumber="${3}"
}

for i in ${pythonInterpreters[*]}
do
	if which ${i} 1>/dev/null 2>&1
	then
		pythonInterpreter=${i}
	fi
done

uniqueApp="${1}"
uniqueTest="${2}"

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

resultLineFormat="%-10s |"
for s in ${available_shells[*]}
do
	resultLineFormat="${resultLineFormat} %-7s |"	
done

resultLineFormat="${resultLineFormat} %-7s | %7s\n"

find "${testPathBase}" -mindepth 1 -maxdepth 1 -type d | sort | while read d
do
	if [ -f "${d}/xml/program.xml" ]
	then
		app="$(basename "${d}")"
		
		[ ! -z "${uniqueApp}" ] && [ "${app}" != "${uniqueApp}" ] && continue 
		
	
		echo "${d}"
		
		printf "${resultLineFormat}" "Test" ${available_shells[*]} "Python" "RESULT"
		
		xmlDescription="${d}/xml/program.xml"
		
		tmpScriptBasename="${d}/program"
		
		### Shell ###
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
		
		
		### Python ###
		if [ ! -z "${pythonInterpreter}" ]
		then
			# Generate python script using the xslt stylesheet
			pyScript="${tmpScriptBasename}.py"
			xsltproc --xinclude -o "${pyScript}" --stringparam interpreter ${pythonInterpreter} "${testPathBase}/lib/python-unittestprogram.xsl" "${xmlDescription}" || error "Failed to create ${pyScript}"
			chmod 755 "${pyScript}"
			
			# Create python module
			"${projectPath}/ns/sh/build-pyscript.sh" -p "${pyScript}" -u -x "${xmlDescription}"
		fi
		
		### Run tests ###
		find "${d}/tests" -type f -name "*.cli" | sort | while read t
		do
			base="${t%.cli}"
			testnumber="$(basename "${base}")"
			result="${base}.result"
			expected="${base}.expected"
			# Create a temporary script
			tmpShellScript="${tmpScriptBasename}-test-${app}-${testnumber}.sh"
			cli="$(cat "${t}")"
			cat > "${tmpShellScript}" << EOFSH
#!/usr/bin/env bash
$(
i=0
for s in ${available_shells[*]}
do
	shScript="${shScripts[${i}]}"
	echo "\"${shScript}\" ${cli} > \"${result}-${s}\""
	i=$(expr ${i} + 1)
done)
EOFSH
			if [ ! -z "${pythonInterpreter}" ]
			then
				cat >> "${tmpShellScript}" << EOFSH
"${pyScript}" ${cli} > "${result}-py"
EOFSH
			fi
			chmod 755 "${tmpShellScript}"	
			"${tmpShellScript}"
		
			resultLine[0]="${app}/${testnumber}"
			log " ---- ${app}/${testnumber} ---- "
			passed=true
			if [ -f "${expected}" ]
			then
				i=0
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
				
				if [ ! -z "${pythonInterpreter}" ]
				then
					if ! diff "${expected}" "${result}-py" >> "${logFile}"
					then
						passed=false
						resultLine[${#resultLine[*]}]="${ERROR_COLOR}FAILED${NORMAL_COLOR}"
					else
						resultLine[${#resultLine[*]}]="${SUCCESS_COLOR}passed${NORMAL_COLOR}"
						rm -f "${result}-py"
					fi
				else
					resultLine[${#resultLine[*]}]="${SUCCESS_COLOR}ignore${NORMAL_COLOR}"
				fi
			else
				passed=true
				for s in ${available_shells[*]} python
				do
					resultLine[${#resultLine[*]}]="${SUCCESS_COLOR}IGNORED${NORMAL_COLOR}"
				done
				cp "${result}-python" "${expected}"
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
		if [ $(find "${d}/tests" -name "*.result-py" | wc -l) -eq 0 ]
		then
			rm -f "${pyScript}"
			rm -fr "${d}/Program"
		fi
		i=0
		for s in ${available_shells[*]}
		do
			if [ $(find "${d}/tests" -name "*.result-${s}" | wc -l) -eq 0 ]
			then
				rm -f "${shScripts[${i}]}"
			fi
			i=$(expr ${i} + 1)
		done
		unset shScripts
	fi					
done

exit $(find "${testPathBase}" -name "*.result-*" | wc -l)

scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
scriptName="$(basename "${scriptFilePath}")"
rootPath="$(ns_realpath "${scriptPath}/../..")"
cwd="$(pwd)"

if ! parse "${@}"
then
	if ${displayHelp}
	then
		usage "${parser_subcommand}"
		exit 0
	fi
	
	parse_displayerrors
	exit 1
fi

if ${displayHelp}
then
	usage "${parser_subcommand}"
	exit 0
fi

projectPath="$(ns_realpath "${scriptPath}/../..")"
logFile="${projectPath}/${scriptName}.log"
rm -f "${logFile}"

# http://stackoverflow.com/questions/4332478/read-the-current-text-color-in-a-xterm/4332530#4332530
NORMAL_COLOR="$(tput sgr0)"
ERROR_COLOR="$(tput setaf 1)"
SUCCESS_COLOR="$(tput setaf 2)"

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

[ -z "${TRAVIS}" ] && TRAVIS=false

if [ "${parser_subcommand}" = 'parsers' ]
then
	parsers=("${parsers_parsers[@]}")
	apps=("${parsers_apps[@]}")
	tests=("${parsers_tests[@]}")
			
	parserTestsPathBase="${projectPath}/unittests/parsers"
	tmpShellStylesheet="$(ns_mktemp "shell-xsl")"
	programSchemaVersion="2.0"
	xshStylesheet="${projectPath}/ns/xsl/program/${programSchemaVersion}/xsh.xsl"
	
	
	for major in 2 3
	do
		for minor in 0 1 2 3 4 5 6 7 8 9
		do
			p="python${major}.${minor}"
			ns_which -s "${p}" \
				&& pythonInterpreters=("${pythonInterpreters[@]}" "${p}")
		done
	done
	
	# Supported shells
	shells=(bash zsh ksh)
	for s in ${shells[@]}
	do
		if ns_which -s ${s}
		then
			check_func="check_${s}"
			if [ "$(type -t "${check_func}")" != "function" ] || ${check_func}
			then
				available_shells[${#available_shells[@]}]=${s}
			fi
		fi
	done
	
	# C compilers
	if [ ! -z "${CC}" ] && ns_which -s "${CC}"
	then
		cc=${CC}
	else
		for c in gcc clang
		do
			if ns_which -s ${c}
			then
				cc=${c}
				break
			fi
		done
	fi
	
	if [ -z "${CFLAGS}" ]
	then
		cflags=(-Wall -pedantic -Wextra -Wconversion -g -O0)
	else
		cflags=(${CFLAGS})
	fi
	cflags=("${cflags[@]}" -Werror)
	
	# Test groups
	if [ ${#apps[@]} -eq 0 ]
	then
		while read d
		do
			selectedApps=("${selectedApps[@]}" "$(basename "${d}")")
		done << EOF
		$(find "${parserTestsPathBase}/apps" -mindepth 1 -maxdepth 1 -type d | sort)
EOF
	else
		for app in "${apps[@]}"
		do
			d="${parserTestsPathBase}/apps/${app}"
			if [ -d "${d}" ]
			then
				selectedApps=("${selectedApps[@]}" "${app}")
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
		
		if [ "${#pythonInterpreters[@]}" -gt 0 ]
		then
			parsers=("${parsers[@]}" python)
			testPython=true
		fi
		
		if ns_which -s ${cc}
		then
			parsers=("${parsers[@]}" c)
			testC=true
			if ns_which -s valgrind
			then
				testValgrind=true
			fi
		fi
		
		if ns_which -s php
		then
			parsers=("${parsers[@]}" php)
			testPHP=true
		fi
	else
		for parser in "${parsers[@]}"
		do
			if [ "${parser}" = "sh" ] && [ ${#available_shells[@]} -gt 0 ]
			then
				testSh=true
			elif [ "${parser}" = "python" ] && [ ${#pythonInterpreters[@]} -gt 0 ]
			then
				testPython=true
			elif [ "${parser}" = "c" ] && ns_which -s ${cc}
			then
				testC=true
				if ns_which -s valgrind
				then
					testValgrind=true
				fi
			elif [ "${parser}" = "php" ] && ns_which -s php
			then
				testPHP=true
			fi
		done 
	fi
	
	resultLineFormat="%20.20s |"
	if ${testSh}
	then
		parserNames=("${parserNames[@]}" "${available_shells[@]}")
		
		for s in "${available_shells[@]}"
		do
			resultLineFormat="${resultLineFormat} %-7s |"	
		done
	fi
	
	if ${testPython}
	then
		#parserNames=("${parserNames[@]}" "Python")	
		#resultLineFormat="${resultLineFormat} %-7s |"
		
		for p in "${pythonInterpreters[@]}"
		do
			pyVersion="$(echo "${p}" | sed "s,python\(.*\),\\1,g")"
			parserNames=("${parserNames[@]}" "py ${pyVersion}")
			resultLineFormat="${resultLineFormat} %-7s |"
		done
		
		log "Update Python parser XSLT" 
		"${scriptPath}/update-python-parser.sh"
	fi
	
	if ${testC}
	then
		parserNames=("${parserNames[@]}" "C/${cc}")
		if ${testValgrind}
		then
			parserNames=("${parserNames[@]}" "C/Valgrind")
		fi
			
		log "Update C parser XSLT "
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
				valgrindArgs=("${valgrindArgs[@]}" \
					"--dsymutil=yes" \
					"--suppressions=\"${rootPath}/resources/valgrind/Darwin.supp\""
					)
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
			
		log "Update PHP parser XSLT"
		"${scriptPath}/update-php-parser.sh"
		resultLineFormat="${resultLineFormat} %-7s |"
	fi
	
	# Result column
	resultLineFormat="${resultLineFormat} %7s\n"
	
	echo "Apps: ${selectedApps[@]}"
	echo "Parsers: ${parserNames[@]}"
	
	
	# Testing ...
	for app in "${selectedApps[@]}"
	do
		d="${parserTestsPathBase}/apps/${app}"
		
		groupTestBasePath="${d}/tests"
		
		unset groupTests
		
		# Populate group tests
		if [ ${#tests[@]} -eq 0 ]
		then
			while read t
			do
				[ -z "${t}" ] && continue
				groupTests[${#groupTests[@]}]="$(basename "${t}")"
			done << EOF
			$(find "${groupTestBasePath}" -mindepth 1 -maxdepth 1 -type f -name "*.cli" | sort)
EOF
		else
			for test in "${tests[@]}"
			do
				tn="${groupTestBasePath}/${test}.cli"
				if [ -f "${tn}" ]
				then 
					groupTests=("${groupTests[@]}" "${test}.cli")
				fi
			done
		fi
		
		if [ ${#groupTests[@]} -eq 0 ]
		then
			continue
		fi
			
		echo "${app} (${#groupTests[@]} tests)"
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
			xsltproc --xinclude -o "${xshBodyFile}" "${parserTestsPathBase}/lib/sh-unittestprogram.xsl" "${xmlDescription}" || ns_error "Failed to create ${xshBodyFile}"  
			
			for s in ${available_shells[@]}
			do
				shScript="${tmpScriptBasename}.${s}"
				shScripts[${#shScripts[@]}]="${shScript}"
				buildShScriptArgs=(\
					-i ${s} \
					-p \
					-x "${xmlDescription}" \
					-s "${xshFile}" \
					-o "${shScript}"\
				)
				log "Generating ${app} ${s} program (${buildShScriptArgs[@]})"
				"${projectPath}/ns/sh/build-shellscript.sh" "${buildShScriptArgs[@]}" || ns_error "Failed to create ${shScript}" 
				chmod 755 "${shScript}"
			done
			
			${keepTemporaryFiles} || rm -f "${xshBodyFile}"
		fi
		
		if ${testPython}
		then
			# Create python module
			pyParser="${d}/Parser.py"
			pyInfo="${d}/ProgramInfo.py"
			pyProgramBase="${tmpScriptBasename}-exe-"
			
			log "Create Python parser module"
			"${projectPath}/ns/sh/build-python.sh" -b \
				-x "${xmlDescription}" \
				-c "TestProgramInfo" \
				-o "${pyParser}" || ns_error "Failed to generated python module"
				
			log "Create Python program info module"
			"${projectPath}/ns/sh/build-python.sh" \
				-i "Parser" \
				-x "${xmlDescription}" \
				-c "TestProgramInfo" \
				-o "${pyInfo}" || ns_error "Failed to generated Python program info module"
				
			log "Generate python scripts"
			unset pyPrograms
			for p in "${pythonInterpreters[@]}"
			do
				pyProgram="${pyProgramBase}${p}.py"
				pyPrograms=("${pyPrograms[@]}" "${pyProgram}")
				xsltproc --xinclude -o "${pyProgram}" --stringparam interpreter ${p} "${parserTestsPathBase}/lib/python-unittestprogram.xsl" "${xmlDescription}" || ns_error "Failed to create ${pyProgram}"
				chmod 755 "${pyProgram}"
			done
		fi
		
		if ${testC}
		then
			cParserBase="${tmpScriptBasename}-parser"
			cProgram="${tmpScriptBasename}-exe"
			xsltproc --xinclude -o "${cProgram}.c" \
				"${parserTestsPathBase}/lib/c-unittestprogram.xsl" \
				"${xmlDescription}" || ns_error "Failed to create ${cProgram} source"
			
			log "Create C files"
			"${projectPath}/ns/sh/build-c.sh" -eu \
				-x "${xmlDescription}" \
				-o "$(dirname "${tmpScriptBasename}")" \
				-f "$(basename "${cParserBase}")" \
				-p "app" || ns_error "Failed to generated C parser"
				
			log "Build C program"
			${cc} "${cflags[@]}" \
				-o "${cProgram}" \
				"${cProgram}.c" "${cParserBase}.c" \
			|| ns_error "Failed to build C program"   
		fi
		
		if ${testPHP}
		then
			phpLibrary="${tmpScriptBasename}-lib.php"
			phpProgram="${tmpScriptBasename}-exe.php"
			log "Create PHP program info"
			"${projectPath}/ns/sh/build-php.sh" -e \
				-x "${xmlDescription}" \
				-c "TestProgramInfo" \
				-o "${phpLibrary}" || ns_error "Failed to generated PHP module"
				
			log "Create program"
			xsltproc --xinclude -o "${phpProgram}" \
				"${parserTestsPathBase}/lib/php-unittestprogram.xsl" \
				"${xmlDescription}" || ns_error "Failed to create ${phpProgram}"
			chmod 755 "${phpProgram}"
		fi
			
		log "Run test(s)"
		for test in "${groupTests[@]}"
		do
			t="${groupTestBasePath}/${test}"
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
	for s in ${available_shells[@]}
	do
		shScript="${shScripts[${shi}]}"
		echo "\"${shScript}\" "${cli[@]}" > \"${result}-${s}\" 2>>\"${logFile}\""
		shi=$(expr ${shi} + 1)
	done)
EOFSH
			fi
			if ${testPython} && [ ! -f "${base}.no-py" ]
			then
				pi=0
				for p in "${pythonInterpreters[@]}"
				do
					pyProgram="${pyPrograms[${pi}]}"
					cat >> "${tmpShellScript}" << EOFSH
	"${pyProgram}" ${cli} > "${result}-${p}"  2>>"${logFile}"
EOFSH
					pi=$(expr "${pi}" + 1)
				done
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
						for s in ${available_shells[@]}
						do
							resultLine[${#resultLine[@]}]="skipped"
						done
					else
						for s in ${available_shells[@]}
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
						for p in "${pythonInterpreters[@]}"
						do
							resultLine[${#resultLine[@]}]="skipped"
						done
					else
						for p in "${pythonInterpreters[@]}"
						do
							if [ ! -f "${result}-${p}" ] || ! diff "${expected}" "${result}-${p}" >> "${logFile}"
							then
								passed=false
								resultLine[${#resultLine[@]}]="FAILED"
							else
								resultLine[${#resultLine[@]}]="passed"
								${keepTemporaryFiles} || rm -f "${result}-${p}"
							fi
						done
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
					for s in ${available_shells[@]}
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
					for p in "${pythonInterpreters[@]}"
					do
						[ -f "${result}-${p}" ] && cp "${result}-${p}" "${expected}" && break
					done
				elif ${testPHP}
				then
					cp "${result}-php" "${expected}"
				elif ${testSb}
				then
					for s in ${available_shells[@]}
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
			for s in ${available_shells[@]}
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
			pi=${parser_startindex}
			hasErrors=false
			for p in "${pythonInterpreters[@]}"
			do
				if [ $(find "${d}/tests" -name "*.result-${p}" | wc -l) -eq 0 ]
				then
					${keepTemporaryFiles} || rm -f "${pyPrograms[${pi}]}"
				else
					hasErrors=true
				fi
				
				# Python cache files are always removed
				rm -f "${pyPrograms[${pi}]}c"
				rm -fr "${d}/__pycache__"
				
				pi=$(expr ${pi} + 1)
			done
			
			if ! ${hasErrors}
			then
				${keepTemporaryFiles} || rm -f "${pyInfo}"
				${keepTemporaryFiles} || rm -f "${pyParser}"
			fi
			
			rm -f "${pyInfo}c"
			rm -f "${pyParser}c"
					
			unset pyPrograms
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
				${keepTemporaryFiles} || rm -fr "${cProgram}.dSYM"
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
	
	count=0
	while read result
	do
		expected="$(sed -E 's,(.*)\..*$,\1,g' <<< "${result}").expected"
		[ -f "${expected}" ] || continue		
		if ! diff -q "${result}" "${expected}" 1>/dev/null 2>&1 
		then
			count=$(expr ${count} + 1)
			if ${TRAVIS}
			then
				echo "-- ${result} -----------------------"
				cat "${result}"
			fi
		fi 
	done << EOF
$(find "${parserTestsPathBase}" -name "*.result-*")
EOF
	if ${TRAVIS} && [ ${count} -gt 0 ]
	then
		echo '-- LOG ---------------'
		cat "${logFile}"	
	fi

	exit ${count}
elif [ "${parser_subcommand}" = 'xsh' ]
then
	xshTestsPathBase="${projectPath}/unittests/xsh"
	xshTestProgramStylesheet="${xshTestsPathBase}/testprogram.xsl"
	xshTestResult=0
	c=${#parser_values[@]}
	testResultFormat="%-40.40s | %-8s\n"
	[ -f "${xsh_stdout}" ] && rm -f "${xsh_stdout}"
	[ -f "${xsh_stderr}" ] && rm -f "${xsh_stderr}"
	while read test
	do
		xshTestBase="$(basename "${test}")"
		xshTestBase="${xshTestBase%.xsh}"
		if [ ${c} -gt 0 ]
		then
			xshTestFound=false
			for t in "${parser_values[@]}"
			do
				[ "${t}" = "${xshTestBase}" ] && xshTestFound=true && break 
			done 
			${xshTestFound} || continue
		fi
		
		printf "${testResultFormat}" "${xshTestBase}" "RESULT"
	
		xshTestProgram="$(dirname "${test}")/${xshTestBase}.run"
		testResult=false	
		xsltproc --output "${xshTestProgram}" \
				--xinclude \
				--stringparam out "${xsh_stdout}" \
				--stringparam err "${xsh_stderr}" \
				"${xshTestProgramStylesheet}" "${test}" \
		&& chmod 755 "${xshTestProgram}" \
		&& "${xshTestProgram}" \
		&& testResult=true
		
		testResultString="${ERROR_COLOR}PAILED${NORMAL_COLOR}"
		
		${testResult} \
		&& testResultString="${SUCCESS_COLOR}passed${NORMAL_COLOR}" \
		|| xshTestResult=$(expr ${xshTestResult} + 1)
		
		printf "${testResultFormat}" "$(printf '%.0s-' {1..40})" "${testResultString}"
		${keepTemporaryFiles} || rm -f "${xshTestProgram}"	  
	done << EOF
	$(find "${xshTestsPathBase}" -name '*.xsh') 
EOF
	exit ${xshTestResult}
elif [ "${parser_subcommand}" = 'xsd' ]
then
	xsdTestPathBase="${rootPath}/unittests/xsd"
	xsdPathBase="${projectPath}/ns/xsd"
	xsdTextResultFormat="%-15.15s | %-20.20s | %-10s | %-8s | %-.15s\n"
	printf "${xsdTextResultFormat}" 'schema' 'test' 'validation' 'expected' 'RESULT'
	xsdTestsResult=0
	while read f
	do
		b="$(basename "${f}" .xml)"
		n="${b%.failed}"
		n="${n%.passed}"
		expected='passed'
		echo "${b}" | egrep -q ".*.failed$" \
			&& expected='failed' 
			
		d="$(dirname "${f}")"
		xsdPath="${xsdPathBase}${d#${xsdTestPathBase}}.xsd"
		
		result='failed'
		xmllint --noout --xinclude --schema "${xsdPath}" "${f}" 1>"${f}.result" 2>&1 \
			&& result='passed'
		
		testResult='passed'
		[ "${result}" != "${expected}" ] \
			&& xsdTestsResult="$(expr "${xsdTestsResult}" + 1)" \
			&& testResult='failed'
		
		printf "${xsdTextResultFormat}" "${d#${xsdTestPathBase}/}" "${n}" "${result}" "${expected}" "${testResult}" \
			| sed "s,passed,${SUCCESS_COLOR}passed${NORMAL_COLOR},g" \
			| sed "s,failed,${ERROR_COLOR}FAILED${NORMAL_COLOR},g"
			
		if [ "${testResult}" = "${expected}" ] && ! ${keepTemporaryFiles}
		then
			rm -f "${f}.result"
		fi 
	done << EOF
$(find "${xsdTestPathBase}" -type f -name '*.xml')
EOF
	exit ${xsdTestsResult}
elif [ "${parser_subcommand}" = 'xslt' ]
then
	xsltTestsResult=0
	xsltTestPathBase="${rootPath}/unittests/xslt"
	unset testList
	if [ ${#parser_values[@]} -gt 0 ]
	then
		for v in "${parser_values[@]}"
		do
			if [ -f "${v}" ] && [ "${v%.info}" != "${v}" ]
			then
				testList=("${testList[@]}" "${v}")
			elif [ -f "${xsltTestPathBase}/${v}.info" ]
			then
				testList=("${testList[@]}" "${xsltTestPathBase}/${v}.info")
			else
				ns_error "Invalid xslt test '${v}'"
			fi
		done
	else
		while read f
		do
			testList=("${testList[@]}" "${f}")
		done << EOF
$(find "${xsltTestPathBase}" -name '*.info')
EOF
	fi

	resultFormat='%-25.25s | %-6s | %-9s | %-6s |\n'
	printf "${resultFormat}" "Test" "schema" "transform" "RESULT"
		
	for f in "${testList[@]}"
	do
		n="$(basename "${f}" .info)"
		schemaResult='skipped'
		transformResult='failed'
		testResult='passed'
		
		transform="$(grep -E '^transform' "${f}" | cut -f 2 -d':' | xargs echo)"
		schema="$(grep -E '^schema' "${f}" | cut -f 2 -d':' | xargs echo)"
		xml="${f%.info}.xml"
		expected="${f%.info}.expected"
		result="${f%.info}.transformresult"
		
		[ -z "${transform}" ] && ns_error "${n}: No XSLT file specified"
		transform="${rootPath}/${transform}"
		[ ! -f "${transform}" ] && ns_error "${n}: Invalid XSLT file '${transform}'"
		
		[ -f "${xml}" ] || ns_error "${n}: XML file not found"
		
		if [ ! -z "${schema}" ]
		then
			schema="${rootPath}/${schema}"
			[ ! -f "${schema}" ] && ns_error "${n}: Invalid schema file '${schema}'"
		
			schemaResult='failed'
			
			xmllint --xinclude --noout \
				--schema "${schema}" \
				"${xml}" \
				2>"${f%.info}.schemaresult" \
			&& schemaResult='passed'
		fi
		
		if [ -f "${expected}" ]
		then
			xsltproc --xinclude --output "${result}" "${transform}" "${xml}"
			diff -q "${result}" "${expected}" 1>/dev/null 2>&1 && transformResult='passed'
		else
			xsltproc --xinclude --output "${expected}" "${transform}" "${xml}"
			transformResult='skipped'
		fi
		
		if [ "${schemaResult}" = 'failed' ] || [ "${transformResult}" = 'failed' ]
		then
			xsltTestsResult=$(expr ${xsltTestsResult} + 1)
			testResult='failed'
		fi
		
		printf "${resultFormat}" "${n}" "${schemaResult}" "${transformResult}" "${testResult}" \
			| sed "s,passed,${SUCCESS_COLOR}passed${NORMAL_COLOR},g" \
			| sed "s,failed,${ERROR_COLOR}FAILED${NORMAL_COLOR},g"
		
	done

	if [ ${xsltTestsResult} -eq 0 ]
	then
		find "${xsltTestPathBase}" -name '*.transformresult' -exec rm -f "{}" \;
		find "${xsltTestPathBase}" -name '*.schemaresult' -exec rm -f "{}" \;
	fi
	
	exit ${xsltTestsResult}
fi

exit 0

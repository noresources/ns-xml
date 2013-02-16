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

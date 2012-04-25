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

rm -f "${logFile}"

NORMAL_COLOR="\\033[0;39m"
ERROR_COLOR="\\033[1;31m"
GREEN_COLOR="\\033[1;32m"


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

find "${testPathBase}" -mindepth 1 -maxdepth 1 -type d | while read d
do
	[ ! -f "${d}/xml/program.xml" ] && exit 0
	echo "${d}"
	app="$(basename "${d}")"
	
	xmlDescription="${d}/xml/program.xml"
	
	### Shell ###
	
	# Write the test body shell script
	xsltproc --xinclude -o "${d}/xsh/program.body.sh" "${testPathBase}/lib/sh-unittestprogram.xsl" "${xmlDescription}" || error "Failed to create ${d}/xsh/program.body.sh"  
	
	# Build the whole script
	shScript="${d}/program.sh"
	"${projectPath}/ns/sh/build-shellscript.sh" -p -x "${xmlDescription}" -s "${d}/xsh/program.xsh" -o "${shScript}" || error "Failed to create ${shScript}"  
	rm -f "${d}/xsh/program.body.sh"
	chmod 755 "${shScript}"
	
	### Python ###
	
	# Generate python script using the xslt stylesheet
	pyScript="${d}/program.py"
	xsltproc --xinclude -o "${pyScript}" "${testPathBase}/lib/python-unittestprogram.xsl" "${xmlDescription}" || error "Failed to create ${pyScript}"
	chmod 755 "${pyScript}"
	
	# Create python module
	"${projectPath}/ns/sh/build-pyscript.sh" -p "${pyScript}" -u -x "${xmlDescription}"
	
	### Run tests ###
	find "${d}/tests" -type f -name "*.cli" | while read t
	do
		base="${t%.cli}"
		testnumber="$(basename "${base}")"
		result="${base}.result"
		expected="${base}.expected"
		# Create a temporary script
		tmpShellScript="${shScript}-test-${app}-${testnumber}.sh"
		cli="$(cat "${t}")"
cat > "${tmpShellScript}" << EOFSH
#!/bin/bash
"${shScript}" ${cli} > "${result}-sh"
"${pyScript}" ${cli} > "${result}-py"
EOFSH
		chmod 755 "${tmpShellScript}"	
		"${tmpShellScript}"
		echo -n "${app}/sh/${testnumber}:"
		log " ---- ${app}/sh/${testnumber} ---- "
		passed=true
		if [ -f "${expected}" ]
		then
			if ! diff "${expected}" "${result}-sh" >> "${logFile}"
			then
				passed=false
				echo -en " ${ERROR_COLOR}[sh: FAILED]${NORMAL_COLOR}"
			else
				echo -en " ${GREEN_COLOR}[sh: passed]${NORMAL_COLOR}"
				rm -f "${result}-sh"
			fi
			
			if ! diff "${expected}" "${result}-py" >> "${logFile}"
			then
				passed=false
				echo -en " ${ERROR_COLOR}[py: FAILED]${NORMAL_COLOR}"
			else
				echo -en " ${GREEN_COLOR}[py: passed]${NORMAL_COLOR}"
				rm -f "${result}-py"
			fi
		else
			passed=true
			echo -en " ${GREEN_COLOR}[IGNORED]${NORMAL_COLOR}"
			cp "${result}-sh" "${expected}"
		fi
		
		if ${passed}
		then
			echo -e " ${GREEN_COLOR}[passed]${NORMAL_COLOR}"
			rm -f "${tmpShellScript}"
		else 
			echo -e " ${ERROR_COLOR}[FAILED]${NORMAL_COLOR}"
		fi
	done 
	
	# Remove if no error
	if [ $(find "${d}/tests" -name "*.result-py" | wc -l) -eq 0 ]
	then
		rm -f "${pyScript}"
		rm -fr "${d}/Program"
	fi
	if [ $(find "${d}/tests" -name "*.result-sh" | wc -l) -eq 0 ]
	then
		rm -f "${shScript}"
	fi
					
done

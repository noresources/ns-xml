scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
rootPath="$(ns_realpath "${scriptPath}/../..")"
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

transform_python()
{
	local input="${1}"
	local output="${2}"
	
	[ -r "${input}" ] || error 1 "Invalid input file \'${input}\'"
	
	local tmpFile="$(ns_mktemp)"
	([ ! -z "${tmpFile}" ] && [ -w "${tmpFile}" ]) || error 2 "Unable to access to temporary file '${tmpFile}'"

	cat > "${tmpFile}" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © $(date +%Y) by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Python Source code in customizable XSLT form -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="../../../strings.xsl" />
	<xsl:import href="base.xsl" />
	
	<xsl:output method="text" encoding="utf-8" />
	
	<!-- Base classes of the Python parser -->
EOF
	echo -ne "<xsl:variable name=\"prg.python.base.code\"><![CDATA[" >> "${tmpFile}"
	# TODO file customization
	# cat "${input}" >> "${tmpFile}"
	sed -n "/XSLT-begin/,/XSLT-end/p" "${input}" \
	| sed "/XSLT-begin/d" \
	| sed "/XSLT-end/d" >> "${tmpFile}"
	
	cat >> "${tmpFile}" << EOF
]]></xsl:variable>

	<!-- Output base code according to output rules -->
	<xsl:template name="prg.python.base.output">
		<xsl:value-of select="\$prg.python.base.code" />
	</xsl:template>
	
	<xsl:template match="/">
		<xsl:value-of select="\$prg.python.codingHint" />
		<xsl:value-of select="\$prg.python.copyright" />
		
		<xsl:call-template name="prg.python.base.output" />
	</xsl:template>
	
</xsl:stylesheet>
EOF

	# Finally 
	mv "${tmpFile}" "${output}"
}

pythonSourceFilePath="${rootPath}/resources/python/program/${programVersion}/Parser.py"
pythonXslFilePath="${xslPath}/program/${programVersion}/python/parser.xsl"

transform_python "${pythonSourceFilePath}" "${pythonXslFilePath}"

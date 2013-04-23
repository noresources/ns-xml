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

transform_php()
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

<!-- PHP Source code in customizable XSLT form -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:prg="http://xsd.nore.fr/program">
	
	<xsl:import href="../../../strings.xsl" />
	<xsl:import href="../../../languages/php.xsl" />
	<xsl:import href="base.xsl" />
	
	<xsl:output method="text" encoding="utf-8" />
	
	<!-- Base classes of the PHP parser -->
	<xsl:variable name="prg.php.base.code"><![CDATA[
EOF
	
	sed -n "/XSLT-begin/,/XSLT-end/p" "${input}" \
	| sed "/XSLT-begin/d" \
	| sed "/XSLT-end/d" >> "${tmpFile}"
	
	cat >> "${tmpFile}" << EOF
]]></xsl:variable>

	<!-- Output base code according to output rules -->
	<xsl:template name="prg.php.base.output">
		<xsl:call-template name="php.namespace">
			<xsl:with-param name="name" select="\$prg.php.parser.namespace" />
			<xsl:with-param name="content" select="\$prg.php.base.code" />
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="/">
		<if test="\$prg.php.phpmarkers">
			<text>&lt;?php</text>
			<value-of select="\$str.endl" />
		</if>
		
		<xsl:call-template name="prg.php.base.output" />
		
		<if test="\$prg.php.phpmarkers">
			<text>?&gt;</text>
			<value-of select="\$str.endl" />
		</if>
	</xsl:template>
	
</xsl:stylesheet>
EOF

	# Finally 
	mv "${tmpFile}" "${output}"
}

phpSourceFilePath="${rootPath}/resources/php/program/${programVersion}/Parser.php"
phpXslFilePath="${xslPath}/program/${programVersion}/php/parser.xsl"

transform_php "${phpSourceFilePath}" "${phpXslFilePath}"

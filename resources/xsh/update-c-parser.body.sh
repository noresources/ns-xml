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

hasAstyle=false
which astyle 1>/dev/null 2>&1 && hasAstyle=true 

astyleOptionsFile="${rootPath}/resources/astyle/c.style"

transformableFunctions=(\
	"nsxml_util_append" \
	"nsxml_util_strncpy" \
	"nsxml_util_strcpy" \
	"nsxml_util_strdup" \
	"nsxml_util_strcat" \
	"nsxml_util_asnprintf" \
	"nsxml_util_string_starts_with" \
	"nsxml_util_path_access_check" \
	"nsxml_util_text_wrap_options_init" \
	"nsxml_util_text_wrap_fprint"
)
		
transformableStructs=(\
	"nsxml_util_text_wrap_options" \
	"nsxml_message" \
	"nsxml_value" \
)

transformableEnumPrefixes=(\
	"nsxml_util_text_wrap_indent_" \
	"nsxml_util_text_wrap_eol_" \
	"nsxml_message_type_" \
	"nsxml_value_type_" \
	"nsxml_usage_format_" \
	"nsxml_message_warning_" \
	"nsxml_message_error_" \
	"nsxml_message_fatal_error_" \
)
															
transform_c()
{
	local input="${1}"
	local output="${2}"
	local templateName="${3}"
	
	local tmpFile="$(ns_mktemp)"
	
	([ ! -z "${tmpFile}" ] && [ -w "${tmpFile}" ]) || ns_error 2 "Unable to access to temporary file '${tmpFile}'"

	cat > "${tmpFile}" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2012-$(date +%Y) by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->
<!-- C Source code in customizable XSLT form -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:prg="http://xsd.nore.fr/program">
	<xsl:import href="parser.generic-names.xsl" />
	<xsl:output method="text" encoding="utf-8" />
	<xsl:param name="prg.c.parser.header.filePath" select="'cmdline.h'" />
	
	<xsl:variable name="prg.c.parser.${templateName}"><![CDATA[
EOF
	# Use Artistic Style to format code
	if ${hasAstyle}
	then
		astyle --options="${astyleOptionsFile}" --suffix=none -q "${input}"
	fi 
	
	cat "${input}" >> "${tmpFile}"
		
	cat >> "${tmpFile}" << EOF
]]></xsl:variable>

	<xsl:template match="//prg:program">
		<xsl:value-of select="\$prg.c.parser.${templateName}"/>
	</xsl:template>
</xsl:stylesheet>

EOF
	
	local ws='\b'
	local we='\b'
	if [ "$(uname -s)" = 'Darwin' ]
	then
		ws='[[:<:]]'
		we='[[:>:]]'
	fi
	
	# Replace hardcoded names by transformable ones
	for t in "${transformableStructs[@]}"
	do
		ns_sed_inplace \
			's,'${ws}${t}${we}',]]><xsl:value-of select="$prg.c.parser.structName.'${t}'"/><![CDATA[,g' \
			"${tmpFile}"
	done
	
	for t in "${transformableFunctions[@]}"
	do
		ns_sed_inplace \
			's,'${ws}${t}${we}',]]><xsl:value-of select="$prg.c.parser.functionName.'${t}'"/><![CDATA[,g' \
			"${tmpFile}"
	done
	
	for t in "${transformableEnumPrefixes[@]}"
	do
		ns_sed_inplace \
			's,'${ws}'\('${t}'[a-zA-Z0-9_][a-zA-Z0-9_]*\)'${we}',]]><xsl:value-of select="$prg.c.parser.variableName.\1"/><![CDATA[,g' \
			"${tmpFile}"
	done
	
	# Include (if source)
	ns_sed_inplace "s,#include[[:space:]][[:space:]]*\"nsxml_program_parser\.h\",#include \"]]><xsl:value-of select=\"\$prg.c.parser.header.filePath\"/><![CDATA[\",g" "${tmpFile}"

	# Finally
	mv "${tmpFile}" "${output}"
}

create_identifier_variables()
{
	local output="${1}"
	local header="${2}"
	local tmpFile="$(ns_mktemp)"
	([ ! -z "${tmpFile}" ] && [ -w "${tmpFile}" ]) || ns_error 2 "Unable to access to temporary file '${tmpFile}'"
	
	cat > "${tmpFile}" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2012-$(date +%Y) by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->
<!-- List of variable, structs and function names which can be modified by the user -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:prg="http://xsd.nore.fr/program" version="1.0">
	<xsl:import href="parser.base.xsl" />
	
EOF

	for t in "${transformableFunctions[@]}"
	do
		cat >> "${tmpFile}" << EOF
	<xsl:variable name="prg.c.parser.functionName.${t}">
		<xsl:call-template name="prg.c.parser.functionName">
			<xsl:with-param name="name" select="'${t}'" />
		</xsl:call-template>
	</xsl:variable>
EOF
	done	
	
	for t in "${transformableStructs[@]}"
	do
		cat >> "${tmpFile}" << EOF
	<xsl:variable name="prg.c.parser.structName.${t}">
		<xsl:call-template name="prg.c.parser.structName">
			<xsl:with-param name="name" select="'${t}'" />
		</xsl:call-template>
	</xsl:variable>
EOF
	done
	
	for b in "${transformableEnumPrefixes[@]}"
	do
		#echo "Search enum ${b} in ${header}"
		egrep -o "${b}[a-z0-9_]+" "${header}" | uniq | while read t
		do
			cat >> "${tmpFile}" << EOF
	<xsl:variable name="prg.c.parser.variableName.${t}">
		<xsl:call-template name="prg.c.parser.variableName">
			<xsl:with-param name="name" select="'${t}'" />
		</xsl:call-template>
	</xsl:variable>
EOF
		done
	done
	
	echo -e "</xsl:stylesheet>" >> "${tmpFile}"
	#xmllint --format --output "${tmpFile}" "${tmpFile}"
	
	# Finally 
	mv "${tmpFile}" "${output}"
}

cSourcePath="${rootPath}/resources/c/program/${programSchemaVersion}"
cSourceBaseFileName="nsxml_program_parser"
cXslPath="${xslPath}/program/${programSchemaVersion}/c"
cXslBaseFileName="parser.generic-"
[ -d "${cSourcePath}" ] || ns_error 1 "Invalid path for C source"
[ -d "${cXslPath}" ] || ns_error 1 "Invalid path for XSL output"

# XSLT Variables
create_identifier_variables "${cXslPath}/${cXslBaseFileName}names.xsl" "${cSourcePath}/${cSourceBaseFileName}.h" 
# Header & sources 
transform_c "${cSourcePath}/${cSourceBaseFileName}.h" "${cXslPath}/${cXslBaseFileName}header.xsl" "genericHeader"
transform_c "${cSourcePath}/${cSourceBaseFileName}.c" "${cXslPath}/${cXslBaseFileName}source.xsl" "genericSource"   

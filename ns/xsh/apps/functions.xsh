<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the BSD License, see LICENSE -->

<!-- A set of common functions for XSH apps -->
<xsh:functions xmlns:xsh="http://xsd.nore.fr/xsh">
	<xsh:function name="error">
		<xsh:parameter name="errno" type="numeric">1</xsh:parameter>
		<xsh:body>
<xsh:local name="message">${@}</xsh:local><![CDATA[
if [ -z "${errno##*[!0-9]*}" ]
then 
	message="${errno} ${message}"
	errno=1
fi
echo "${message}"
exit ${errno}
		]]></xsh:body>
	</xsh:function>
	<xsh:function name="chunk_check_nsxml_ns_path">
		<xsh:body><![CDATA[
if [ ! -z "${nsxmlPath}" ]
then
	if ${nsxmlPathRelative}
	then
		nsPath="${scriptPath}/${nsxmlPath}"
	else
		nsPath="${nsxmlPath}"
	fi
	
	[ -d "${nsPath}" ] || return 1
	
	nsPath="$(ns_realpath "${nsPath}")"
fi
[ -d "${nsPath}" ]
]]></xsh:body>
	</xsh:function>
	<xsh:function name="get_program_version">
		<xsh:parameter name="file" />
		<xsh:body>
		<xsh:local name="tmpXslFile">/tmp/get_program_version.xsl</xsh:local><![CDATA[
cat > "${tmpXslFile}" << GETPROGRAMVERSIONXSLEOF]]></xsh:body>
		<xsh:body indent="false"><![CDATA[<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	<xsl:output method="text" encoding="utf-8" />
	<xsl:template match="//prg:program">
		<xsl:value-of select="@version" />
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
</xsl:stylesheet>
GETPROGRAMVERSIONXSLEOF
]]></xsh:body>
		<xsh:body>
		<xsh:local name="result">$(xsltproc --xinclude "${tmpXslFile}" "${file}")</xsh:local><![CDATA[
rm -f "${tmpXslFile}"
if [ ! -z "${result##*[!0-9.]*}" ]
then
	echo "${result}"
	return 0
else
	return 1
fi
]]></xsh:body>
		<xsh:body><![CDATA[
]]></xsh:body>
	</xsh:function>
	<xsh:function name="xml_validate">
		<xsh:parameter name="schema" />
		<xsh:parameter name="xml" />
		<xsh:body>
		<xsh:local name="tmpOut">/tmp/xml_validate.tmp</xsh:local><![CDATA[
if ! xmllint --xinclude --noout --schema "${schema}" "${xml}" 1>"${tmpOut}" 2>&1
then
	cat "${tmpOut}"
	echo "Schema: ${scheam}"
	echo "File: ${xml}"
	return 1
fi

return 0]]></xsh:body>
	</xsh:function>
</xsh:functions>

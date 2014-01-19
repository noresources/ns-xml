<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->
<xsh:functions xmlns:xsh="http://xsd.nore.fr/xsh">
	<!-- in place file text replacement using sed -->
	<!-- Take care of sed version (at least on Mac OS X 10.5) -->
	<xsh:function name="ns_sed_inplace">
		<xsh:body><![CDATA[
# sedForm
# 1: modern linux => (g)sed --in-place
# 2: Mac OS X 10.5-10.8 - => sed -i ""
# TODO test Mac OS X < 10.5
]]><xsh:local name="sedForm" type="numeric">1</xsh:local>
# Use gsed if available
<xsh:local name="sedBin">$(which "gsed")</xsh:local><![CDATA[
[ -z "${sedBin}" ] && sedBin="$(which "sed")"
[ -z "${sedBin}" ] && return 1

if [ "$(uname -s)" == "Darwin" ] && [ "${sedBin}" = "/usr/bin/sed" ]
then
	]]><xsh:local name="macOSXVersion">$(sw_vers -productVersion)</xsh:local><![CDATA[
	if [ ! -z "${macOSXVersion}" ]
	then
		]]><xsh:local name="macOSXMajorVersion">$(echo "${macOSXVersion}" | cut -f 1 -d".")</xsh:local>
		<xsh:local name="macOSXMinorVersion">$(echo "${macOSXVersion}" | cut -f 2 -d".")</xsh:local><![CDATA[
		if [ ${macOSXMajorVersion} -eq 10 ] && [ ${macOSXMinorVersion} -ge 5 ]
		then
			sedForm=2
		fi
	fi	
fi

if [ ${sedForm} -eq 1 ]
then
	"${sedBin}" --in-place "${@}"
elif [ ${sedForm} -eq 2 ]
then
	"${sedBin}" -i ""  "${@}"
fi
]]></xsh:body>
	</xsh:function>
</xsh:functions>

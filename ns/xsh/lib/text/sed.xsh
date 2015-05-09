<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->
<xsh:functions xmlns:xsh="http://xsd.nore.fr/xsh">
	<!-- in place file text replacement using sed -->
	<!-- Take care of sed version (at least on Mac OS X 10.5) -->
	<xsh:function name="ns_sed_inplace">
		<xsh:body>
			<xsh:local name="inplaceOptionForm" /><![CDATA[
if [ -z "${__ns_sed_inplace_inplaceOptionForm}" ]
then
	if [ "$(uname -s)" = 'Darwin' ]
	then
		if [ "$(which sed 2>/dev/null)" = '/usr/bin/sed' ]
		then
			inplaceOptionForm='arg'			
		fi 
	fi
	
	if [ -z "${inplaceOptionForm}" ]
	then
		# Attempt to guess it from help
		if sed --helo 2>&1 | grep -q '\-i\[SUFFIX\]'
		then
			inplaceOptionForm='nested'
		elif sed --helo 2>&1 | grep -q '\-i extension'
		then
			inplaceOptionForm='arg'
		else
			inplaceOptionForm='noarg'
		fi
	fi
else
	inplaceOptionForm="${__ns_sed_inplace_inplaceOptionForm}"
fi

# Store for later use
__ns_sed_inplace_inplaceOptionForm="${inplaceOptionForm}"

if [ "${inplaceOptionForm}" = 'nested' ]
then
	sed -i'' "${@}"
elif [ "${inplaceOptionForm}" = 'arg' ]
then
	sed -i '' "${@}"
else
	sed -i "${@}"
fi
]]></xsh:body>
	</xsh:function>
</xsh:functions>

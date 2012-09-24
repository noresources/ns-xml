#!/bin/bash
if ! which xmlformat 1>/dev/null 2>&1
then
	return 0
fi

hg st -man | egrep "*\.(xsl|xml|xsh|xsd)" | while read f
do
	 xmlformat ${f}
done

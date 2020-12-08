<?xml version="1.0" encoding="UTF-8"?>
<xsh:functions xmlns:xsh="http://xsd.nore.fr/xsh">
	<xsh:function name="toboolstr">
		<xsh:parameter name="value" />
		<xsh:parameter name="trueString">True</xsh:parameter>
		<xsh:parameter name="falseString">False</xsh:parameter>
		<xsh:body><![CDATA[
[ -z "${value}" ] && echo "${falseString}" && return 0
for s in 0 0.0 no No NO nil Nil NIL none None NONE null Null NULL false False FALSE
do
	[ "${value}" = "${s}" ] && echo "${falseString}" && return 0
done
echo "${trueString}"
return 0
		]]></xsh:body>
	</xsh:function>
</xsh:functions>

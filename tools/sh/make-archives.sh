#!/usr/bin/env bash
# ####################################
# Copyright © 2012 by Renaud Guillard (dev@nore.fr)
# Distributed under the terms of the BSD License, see LICENSE
# ####################################
# Create ns-xml distributions
# ####################################

scriptFilePath="${0}"
cwd="$(pwd)"
scriptPath="$(dirname "${scriptFilePath}")"
cd "${scriptPath}"
scriptPath="$(pwd)"
projectPath="${scriptPath}/../.."
cd "${projectPath}"

hgnode=$(hg tip --template "{date|shortdate}-{node|short}")
echo "${hgnode}"

prg=(\
	ns/python/program/2.0 \
	ns/sh/build-c.sh \
	ns/sh/build-pyscript.sh \
	ns/sh/build-shellscript.sh \
	ns/sh/build-xulapp.sh \
	ns/sh/new-xsh.sh \
	ns/sh/prgproc.sh \
	resources/bash_completion.d/build-c.sh \
	resources/bash_completion.d/build-pyscript.sh \
	resources/bash_completion.d/build-shellscript.sh \
	resources/bash_completion.d/build-xulapp.sh \
	resources/bash_completion.d/new-xsh.sh \
	resources/bash_completion.d/prgproc.sh \
	ns/xbl \
	ns/xpcom \
	ns/xsd/program/2.0 \
	ns/xsd/www.w3.org/XML/1998/namespace.xsd \
	ns/xsl/documents/gengetopts-base.xsl \
	ns/xsl/languages \
	ns/xsl/program/2.0 \
	ns/xsl/strings.xsl	
)

prg_linux=("${prg[@]}")

xslt=(\
	--transform \
	's,doc/html/xsl,doc,' \
	--transform \
	s,ns/xsl,xsl, \
	doc/html/xsl/documents \
	doc/html/xsl/languages \
	doc/html/xsl/strings.html \
	ns/xsl/documents \
	ns/xsl/languages \
	ns/xsl/strings.xsl
)

error()
{
	local retval="${1}"
	shift
	echo "${@}"
	exit ${retval}
}

make_archive()
{
	local name="${1}"
	shift
	
	mkdir -p "${projectPath}/archives"
	tar -C "${projectPath}" --transform "s,^,${name}/," -cvzf "archives/${name}-${hgnode}.tgz" "${@}"
}

make_archive "ns-xml-pidf" "${prg[@]}"
make_archive "ns-xml-xsltlib" "${xslt[@]}"

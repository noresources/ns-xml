#!/usr/bin/env bash
# ####################################
# Copyright © 2012 by Renaud Guillard (dev@nore.fr)
# Distributed under the terms of the MIT License, see LICENSE
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

error()
{
	local retval="${1}"
	shift
	echo "${@}"
	exit ${retval}
}

hgnode=$(hg tip --template "{date|shortdate}-{node|short}")
echo "${hgnode}"

prg=(\
	ns/sh/build-c.sh \
	ns/sh/build-python.sh \
	ns/sh/build-php.sh \
	ns/sh/build-shellscript.sh \
	ns/sh/build-xulapp.sh \
	ns/sh/new-xsh.sh \
	ns/sh/prgproc.sh \
	resources/bash_completion.d/build-c.sh \
	resources/bash_completion.d/build-python.sh \
	resources/bash_completion.d/build-php.sh \
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
	ns/xsl/strings.xsl \
	LICENSE
)

prg_linux=("${prg[@]}" \
	--transform \
	"s,xul/linux,ns/xul," \
)

while read d
do
	prg_linux=("${prg_linux[@]}" "${d}")
done << EOF
$(find "xul/linux" -mindepth 1 -maxdepth 1 -type d) 
EOF

prg_osx=("${prg[@]}" \
	--transform \
	"s,xul/osx,ns/xul," \
)

while read d
do
	prg_osx=("${prg_osx[@]}" "${d}")
done << EOF
$(find "xul/osx" -mindepth 1 -maxdepth 1 -type d) 
EOF

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
	ns/xsl/strings.xsl \
	LICENSE
)

make_archive()
{
	local name="${1}"
	shift
	
	mkdir -p "${projectPath}/archives"
	tar -C "${projectPath}" --transform "s,^,${name}/," -cvzf "archives/${name}-${hgnode}.tgz" "${@}" || error 2
}

make_archive "ns-xml-pidf-linux" "${prg_linux[@]}"
make_archive "ns-xml-pidf-osx" "${prg_osx[@]}"
make_archive "ns-xml-xsltlib" "${xslt[@]}"

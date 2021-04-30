#!/usr/bin/env bash
# ####################################
# Copyright © 2012 - 2021 by Renaud Guillard (dev@nore.fr)
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

# hgnode=$(hg tip --template "{date|shortdate}-{node|short}")
# echo "${hgnode}"
gitref=$(git rev-parse --short HEAD)

platform="$(uname -s)"

transforms=(\
	"s,ns/sh,bin," \
	"s,resources/bash_completion.d,bash_completion.d," \
	"s,ns/xbl,share/xbl," \
	"s,ns/xpcom,share/xpcom," \
	"s,ns/xsd,share/xsd," \
	"s,ns/xsl,share/xsl," \
	"s,ns/ns-xml.plist,share/ns-xml.plist," \
	"s,resources/sh/,," \
)

# program interface definition framework
prg=(\
	ns/sh/build-c.sh \
	ns/sh/build-python.sh \
	ns/sh/build-php.sh \
	ns/sh/build-shellscript.sh \
	ns/sh/new-xsh.sh \
	ns/sh/prgproc.sh \
	resources/bash_completion.d/build-c.sh \
	resources/bash_completion.d/build-python.sh \
	resources/bash_completion.d/build-php.sh \
	resources/bash_completion.d/build-shellscript.sh \
	resources/bash_completion.d/new-xsh.sh \
	resources/bash_completion.d/prgproc.sh \
	ns/xbl \
	ns/xpcom \
	ns/xsd/program/2.0 \
	ns/xsd/www.w3.org/XML/1998/namespace.xsd \
	ns/ns-xml.plist \
	resources/sh/install.sh \
	LICENSE
)

while read f
do
	prg=("${prg[@]}" "${f}")
done << EOF
$(find "${projectPath}/ns/xsl/program" -name "*.xsl" \
	| xargs "${projectPath}/ns/sh/xsltdeps.sh" --relative "${projectPath}" --add-input --)
EOF

xslt=(\
	--transform \
	's,doc/html/xsl,doc,' \
	--transform \
	s,ns/xsl,share/xsl, \
	doc/html/xsl/documents \
	doc/html/xsl/languages \
	doc/html/xsl/strings.html \
	ns/xsl/documents \
	ns/xsl/languages \
	ns/xsl/strings.xsl \
	resources/sh/install.sh \
	LICENSE
)

make_archive()
{
	local name="${1}"
	shift
		
	mkdir -p "${projectPath}/archives"
	tar -C "${projectPath}" \
		--transform "s,^,${name}/," \
		-cvzf "archives/${name}-${gitref}.tgz" \
		"${@}" \
		"${transformArgs[@]}" \
	|| error 2
}

unset transformArgs
for t in "${transforms[@]}"
do
	transformArgs=("${transformArgs[@]}" --transform "${t}")
done

[ "${platform}" = "Linux" ] && make_archive "ns-xml-pidf-linux" "${prg[@]}" "${prg_linux[@]}"
[ "${platform}" = "Darwin" ] && make_archive "ns-xml-pidf-osx" "${prg[@]}" "${prg_osx[@]}"
make_archive "ns-xml-xsltlib" "${xslt[@]}"

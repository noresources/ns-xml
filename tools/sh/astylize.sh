#!/usr/bin/env bash
# ####################################
# Copyright © 2012 - 2021 by Renaud Guillard (dev@nore.fr)
# Distributed under the terms of the MIT License, see LICENSE
# ####################################
# Use Artistic style to format source code
# ####################################

scriptFilePath="${0}"
cwd="$(pwd)"
scriptPath="$(dirname "${scriptFilePath}")"
cd "${scriptPath}"
scriptPath="$(pwd)"
projectPath="${scriptPath}/../.."
cd "${cwd}"

astyleOptionFile="${projectPath}/resources/astyle/c.style"

if which astyle 1>/dev/null 2>&1 && [ -f "${astyleOptionFile}" ]
then
	while read f
	do
		astyle --options="${astyleOptionFile}" "${f}"
	done << EOFIND
	$(find ${projectPath}/resources/c -type f -a \( -name "*.c" -o -name "*.h" \))
EOFIND
fi

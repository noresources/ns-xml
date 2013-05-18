#!/bin/bash
scriptFilePath="${0}"
scriptPath="$(dirname "${scriptFilePath}")"
projectPath="${scriptPath}/../../.."

cd "${projectPath}"
find . -name "*.orig" -exec rm -f {} \;

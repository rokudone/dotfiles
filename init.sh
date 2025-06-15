#!/bin/bash
cd $(dirname $0)

scriptDir=`pwd -P`
echo $scriptDir

$scriptDir/bin/setup/link.sh
$scriptDir/bin/setup/install.sh
$scriptDir/bin/setup/rbenv.sh
$scriptDir/bin/setup/vim.sh
$scriptDir/bin/setup/vscode.sh

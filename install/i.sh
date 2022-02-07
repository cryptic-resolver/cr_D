#!/usr/bin/env bash
# coding: utf-8
#  ---------------------------------------------------
#  File          : i.sh
#  Authors       : ccmywish <ccmywish@qq.com>
#  Created on    : <2022-1-11>
#  Last modified : Auto generated when built
#
#  Install 'cr' on Linux or macOS
#  ---------------------------------------------------

echo "Downloading binary from github.com/cryptic-resolver/cr_D"

ostype=$(uname) 
cr_ver="1.1.2"

dlprefix="https://github.com/cryptic-resolver/cr_D/releases/download/v${dlprefix}${cr_ver}/cr-${cr_ver}-"

# You must split the string and ']]' with a space
# bash is really shit tool
if [[ $ostype == 'linux' ]] || [[ $ostype == 'Linux' ]]
then
   echo "Download Linux version"
   dl="${dlprefix}amd64-unknown-linux"
else
   echo "Download macOS version"
   dl="${dlprefix}arm64-apple-darwin"
fi

curl -fSL ${dl} -o cr

chmod +x ./cr

echo "move to /usr/local/bin"
sudo mv ./cr /usr/local/bin

echo "Finish! Try 'cr emacs' now"

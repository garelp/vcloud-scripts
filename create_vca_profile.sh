#!/bin/bash

#set -x

if [ $# -ne 1 ]
then
    echo "Usage: $0 <creds file>"
    exit 10
fi

if [ -f "$HOME/.vcloud-scripts-config" ]
then
	libPath=$(crudini --get $HOME/.vcloud-scripts-config Global library_path)
	vcaBin=$(crudini --get $HOME/.vcloud-scripts-config Global vca_bin) 
else
	libPath="./"
	vcaBin=$(type -p vca)
fi

CREDFILE="$1"
[ ! -f $CREDFILE ] && { echo "$INPUT file not found"; exit 99; }

source $libPath/vcloud-api-func
source $CREDFILE

if [ -z "$vcaProfile" ]; then
	echo "Please indicate a correct creds file."
	exit 10
fi

$vcaBin -p "$vcaProfile" -i login $vcdUser --password $vcdPass  --host $vcdHost --org $vcdOrg --version 5.5
$vcaBin profile
echo "**************************************************************"
echo "**   Don't forget to set the correct VDC for this profile   **"
echo "**                with set_vca_vdc function                 **"
echo "**************************************************************"

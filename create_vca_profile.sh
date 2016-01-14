#!/bin/bash

#set -x

if [ $# -ne 1 ]
then
    echo "Usage: $0 <creds file>"
    exit 10
fi

# Check availability of needed commands:
#command -v vca >/dev/null 2>&1 || { echo >&2 "I require vca-cli but it's not installed.  Aborting."; exit 1; }
command -v crudini >/dev/null 2>&1 || { echo >&2 "I require crudini but it's not installed.  Aborting."; exit 1; }
command -v xml2 >/dev/null 2>&1 || { echo >&2 "I require xml2 but it's not installed.  Aborting."; exit 1; }
command -v http >/dev/null 2>&1 || { echo >&2 "I require HTTPie but it's not installed.  Aborting."; exit 1; }


if [ -f "$HOME/.vcloud-scripts-config" ]
then
	libPath=$(crudini --get $HOME/.vcloud-scripts-config Global library_path)
	vcaBin=$(crudini --get $HOME/.vcloud-scripts-config Global vca_bin) 
else
	libPath="./"
fi

CREDFILE="$1"
[ ! -f $CREDFILE ] && { echo "$CREDFILE file not found"; exit 99; }

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

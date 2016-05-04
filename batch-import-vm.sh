#!/bin/bash

set -x

if [ $# -ne 2 ]
then
    echo "Usage: $0 <CSV_File> <creds file>"
    exit 10
fi

alias ovftool='/Applications/VMware\ Fusion.app/Contents/Library/VMware\ OVF\ Tool/ovftool'

# Check availability of needed commands:
command -v crudini >/dev/null 2>&1 || { echo >&2 "I require crudini but it's not installed.  Aborting."; exit 1; }
command -v xml2 >/dev/null 2>&1 || { echo >&2 "I require xml2 but it's not installed.  Aborting."; exit 1; }
command -v http >/dev/null 2>&1 || { echo >&2 "I require HTTPie but it's not installed.  Aborting."; exit 1; }
#command -v ovftool >/dev/null 2>&1 || { echo >&2 "I require OVFTools but it's not installed.  Aborting."; exit 1; }


if [ -f "$HOME/.vcloud-scripts-config" ]
then
	libPath=$(crudini --get $HOME/.vcloud-scripts-config Global library_path)
	vcaBin=$(crudini --get $HOME/.vcloud-scripts-config Global vca_bin) 
else
	libPath="./"
	vcaBin=$(command -v vca | cut -d = -f 2)
fi

INPUT="$1"
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }

CREDFILE="$2"
[ ! -f $CREDFILE ] && { echo "$INPUT file not found"; exit 99; }

source $libPath/vcloud-api-func
source $CREDFILE

if [ -z "$vcaProfile" ]; then
	echo "Please indicate a correct creds file."
	exit 10
fi


OLDIFS=$IFS
IFS=$'\n'

for line in $(cat "$INPUT")
do
	if [[ $line != "#"* ]]
	then 
		IFS=, read vcdPool vcdTmpl vappName vmName vappNet vappIp vappCpu vappRam ovfPath restofline <<< "$line"
		if [[ $vcdTmpl ]]; then
		    #echo "$vcdPool","$vcdTmpl","$vappName","$vmName","$vappNet","$vappIp","$vappCpu","$vappRam","$ovfPath"
		    check_tmpl_exists $vcdTmpl
		    if [ $? -eq 0 ]; then
				ovftool --maxVirtualHardwareVersion=9 --X:logFile=ovftool.log --X:logLevel=verbose "$ovfPath" "vcloud://$vcdUser:$vcdPass@$vcdHost/?org=$vcdOrg&catalog=$vcdCatalog&vappTemplate=$vcdTmpl"
			else
				echo "skipping $vcdTmpl already exists in catalog."
			fi
		fi
	fi
done

IFS=$OLDIFS

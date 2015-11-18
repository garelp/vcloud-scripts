#!/bin/bash

#set -x

if [ $# -ne 2 ]
then
    echo "Usage: $0 <CSV_File> <creds file>"
    exit 10
fi


INPUT="$1"
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }

CREDFILE="$2"
[ ! -f $CREDFILE ] && { echo "$INPUT file not found"; exit 99; }

source vcloud-api-func
source $CREDFILE

if [ -z "$vcaProfile" ]; then
	echo "Please indicate a correct creds file."
	exit 10
fi

#vcdCatalog="Private catalog"
#vcdUser=login
#vcdPass=password
#vcdOrg=CUSTOMER_ID
#vcdHost="api1.paris2.dc.fr.access-cloud.net"
#vcdUrl="https://$vcdHost/api"


OLDIFS=$IFS
IFS=$'\n'

for line in $(cat "$INPUT")
do
	IFS=, read vcdPool vcdTmpl vappName vappNet vappIp vappCpu vappRam ovfPath <<< "$line"
    #echo "$vcdPool","$vcdTmpl","$vappName","$vappNet","$vappIp","$vappCpu","$vappRam","$ovfPath"
    check_tmpl_exists $vcdTmpl
    if [ $? -eq 0 ]; then
		ovftool --maxVirtualHardwareVersion=9 "$ovfPath" "vcloud://$vcdUser:$vcdPass@$vcdHost/?org=$vcdOrg&catalog=$vcdCatalog&vappTemplate=$vcdTmpl"
	else
		echo "skipping $vcdTmpl already exists in catalog."
	fi
done

IFS=$OLDIFS

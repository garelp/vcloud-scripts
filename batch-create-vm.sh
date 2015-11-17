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

if [ -z $vcaProfile ]; then
	echo "Please indicate a correct creds file."
	exit 10
fi

#vcaProfile="NTTinfra"
#vcdCatalog="Private catalog"
#vcdUser=pgarel
#vcdPass=Ntt4API
#vcdOrg=CUSTOMER-481525-SERVICE-3248
#vcdHost="api1.paris2.dc.fr.access-cloud.net"
#vcdUrl="https://$vcdHost/api"

# Login to vcd with provided credentials
#vca --profile $vcaProfile -i login $vcdUser --password $vcdPass --host $vcdHost --org $vcdOrg --version 5.5

# setting the vca-cli profile:
set_vca_profile "$vcaProfile"

OLDIFS=$IFS
IFS=$'\n'

for line in $(cat "$INPUT")
do
	IFS=, read vcdPool vcdTmpl vappName vappNet vappIp vappCpu vappRam restofline <<< "$line"
    #echo "$vcdPool","$vcdTmpl","$vappName","$vappNet","$vappIp","$vappCpu","$vappRam"
    check_vm_exists $vappName
    if [ $? -eq 0 ]; then
    	vca vapp create -a $vappName -V $vappName -c "$vcdCatalog" -t $vcdTmpl -n $vappNet --ip $vappIp --cpu $vappCpu --ram $vappRam --mode MANUAL
		set_vm_custo $vappName on off off
    fi
done

IFS=$OLDIFS

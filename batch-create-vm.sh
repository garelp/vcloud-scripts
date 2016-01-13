#!/bin/bash

#set -x

if [ $# -ne 2 ]
then
    echo "Usage: $0 <CSV_File> <creds file>"
    exit 10
fi

# Check availability of needed commands:
command -v vca >/dev/null 2>&1 || { echo >&2 "I require vca-cli but it's not installed.  Aborting."; exit 1; }
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

#vcdCatalog="Private catalog"
#vcdUser=login
#vcdPass=password
#vcdOrg=CUSTOMER_ID
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
	if [[ $line != "#"* ]]
	then 
		IFS=, read vcdPool vcdTmpl vappName vmName vappNet vappIp vappCpu vappRam ovfPath vmCusto vmGenSID vmGenPass vappDesc <<< "$line"
		if [[ $vappName ]]; then
		    #echo "$vcdPool","$vcdTmpl","$vappName","$vmName","$vappNet","$vappIp","$vappCpu","$vappRam",$vmCusto,$vmGenSID,$vmGenPass,$vappDesc
		    check_vm_exists $vappName
		    if [ $? -eq 0 ]; then
				set_vca_vdc "$vcaProfile" "$vcdPool"
				$vcaBin vapp create -a $vappName -V $vmName -c "$vcdCatalog" -t $vcdTmpl -n $vappNet --ip $vappIp --cpu $vappCpu --ram $vappRam --mode MANUAL
				set_vm_custo $vmName $vmCusto $vmGenSID $vmGenPass $vappName
				if [[ $vappDesc ]]; then
					set_vapp_desc $vappName $vappDesc
				fi
			else
				echo "Skipping $vappName already exists in resource pool."
			fi
		fi
	fi
done

IFS=$OLDIFS

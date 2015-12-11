#!/usr/bin/env bash

function usage() {
  echo "$0: Snapshot management for Vapp"
  echo "Usage: $0 -f [create|remove|list|revert] -V [VappName]"
}

if [ $# -eq 0 ]
then
    usage
    exit 1
fi

while getopts "f:V:" opt; do
  case $opt in
    f)
      snapFunction=${OPTARG}
      ;;
    V)
      vappName=${OPTARG}
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

if [ -z "$vcdUser" ]; then
	echo "Please define your credential first."
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
source $libPath/vcloud-api-func

case $snapFunction in
	create)
		create_vapp_snaphot $vappName
	;;
	remove)
		remove_vapp_snapshot $vappName
	;;
	list)
		snapInfo=$(get_vapp_snapshot $vappName)
		snapDate=$( echo $snapInfo | cut -d , -f 3 )
		snapState=$( echo $snapInfo | cut -d , -f 2 )
		snapSize=$( echo $snapInfo | cut -d , -f 1 )
		if [ $snapState == "true" ]
		then
			snapState="PowerOn"
		else
			snapState="PowerOff"
		fi
		printf "| %-25s | %-20s | %-20s |\n" "Date taken" "vCD Snap Size (MB)" "Vapp Status" 
		echo "|-------------------------------------------------------------------------|"
		printf "| %-25s | %-20s | %-20s |\n" $snapDate $(($snapSize/1024/1024)) $snapState 
	;;
	revert)
		revert_vapp_snapshot $vappName
	;;
	*)
		echo "Function not supported."
		exit 1
	;;
esac

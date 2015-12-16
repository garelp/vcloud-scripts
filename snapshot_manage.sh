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

if [ -z "$snapFunction" ]; then
	echo "Please specify a snapshot function."
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
		if [ -z "$vappName" ]; then
			echo "Please specify the Vapp Name."
			exit 10
		fi
		create_vapp_snaphot $vappName
	;;
	remove)
		if [ -z "$vappName" ]; then
			echo "Please specify the Vapp Name."
			exit 10
		fi
		remove_vapp_snapshot $vappName
	;;
	list)
		if [ -z "$vappName" ]; then
			# No Vapp name so get all snapshot for current vDC
			echo "-------------------------------------------------------------------------------------------------------"
			printf "| %-25s | %-25s | %-20s | %-20s |\n" "Vapp Name" "Date taken" "vCD Snap Size (MB)" "Vapp Status" 
			echo "|-----------------------------------------------------------------------------------------------------|"
			for vapp in $(get_vapp_list)
			do
				snapInfo=$(get_vapp_snapshot $vapp)
				snapDate=$( echo $snapInfo | cut -d , -f 3 )
				if [ "$snapDate" ]
				then
					# A snapshot is present.
					snapState=$( echo $snapInfo | cut -d , -f 2 )
					snapSize=$( echo $snapInfo | cut -d , -f 1 )
					if [ $snapState == "true" ]
					then
						snapState="PowerOn"
					else
						snapState="PowerOff"
					fi
					printf "| %-25s | %-25s | %-20s | %-20s |\n" $vapp $snapDate $(($snapSize/1024/1024)) $snapState 
				fi				
			done
			echo "-------------------------------------------------------------------------------------------------------"
		else
			# Display snapshot infor for the given VappName
			snapInfo=$(get_vapp_snapshot $vappName)
			snapDate=$( echo $snapInfo | cut -d , -f 3 )
			if [ "$snapDate" ]
			then
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
			else
				echo "No snapshot found for $vappName."
				exit 1
			fi
		fi
	;;
	revert)
		revert_vapp_snapshot $vappName
	;;
	*)
		echo "Function not supported."
		exit 1
	;;
esac

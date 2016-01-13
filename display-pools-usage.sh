#!/bin/bash

#set -x

if [ -f "$HOME/.vcloud-scripts-config" ]
then
	libPath=$(crudini --get $HOME/.vcloud-scripts-config Global library_path)
	vcaBin=$(crudini --get $HOME/.vcloud-scripts-config Global vca_bin) 
else
	libPath="./"
	vcaBin=$(type -p vca)
fi

# Include the vloud function library.
source $libPath/vcloud-api-func

# Check if a crendial file is passed as argument.
if [ $# -eq 1 ]; then
	source $1
fi

# if no credential are present, ask to define them.
if [ -z "$vcdOrg" ]; then
	echo "Please indicate a correct creds file or source the credentials."
	exit 10
fi

# Check availability of needed commands:
command -v vca >/dev/null 2>&1 || { echo >&2 "I require vca-cli but it's not installed.  Aborting."; exit 1; }
command -v crudini >/dev/null 2>&1 || { echo >&2 "I require crudini but it's not installed.  Aborting."; exit 1; }
command -v xml2 >/dev/null 2>&1 || { echo >&2 "I require xml2 but it's not installed.  Aborting."; exit 1; }
command -v http >/dev/null 2>&1 || { echo >&2 "I require HTTPie but it's not installed.  Aborting."; exit 1; }


OLDIFS=$IFS
IFS=$'\n'

printf "| %-30s | %-10s | %-20s | %-20s | %-20s | %-20s | %-20s | %-20s |\n" "Pool Name" "# of Vapp" "CPU Used (MHz)" "CPU Limit (MHz)" "Memory used (MB)" "Memory Limit (MB)" "Storage Used (MB)" "Storage Limit (MB)"

# Draw a separator
printf -v line '%*s' 185
echo ${line// /-}

for pool in $(get_pool_list)
do
	#echo -n "-- $pool:"
	for poolValue in $(get_pool_info $pool | egrep 'cpuAllocationMhz|numberOfVApps|storageUsedMB|memoryUsedMB|memoryLimitMB|cpuLimitMhz|storageLimitMB')
	do
		# Getting the value for each pool element
		valueName=$(echo $poolValue | cut -d = -f 1)
		valueContent=$(echo $poolValue | cut -d = -f 2)
		case $valueName in
			'cpuAllocationMhz') cpuAllocationMhz=$valueContent
			;;
			'numberOfVApps') numberOfVApps=$valueContent
			;;
			'storageUsedMB') storageUsedMB=$valueContent
			;;
			'memoryUsedMB') memoryUsedMB=$valueContent
			;;
			'memoryLimitMB') memoryLimitMB=$valueContent
			;;
			'cpuLimitMhz') cpuLimitMhz=$valueContent
			;;
			'storageLimitMB') storageLimitMB=$valueContent
		esac
	done
	# Display the line with the pool info
	printf "| %-30s | %-10s | %-20s | %-20s | %-20s | %-20s | %-20s | %-20s |\n" $pool $numberOfVApps $cpuAllocationMhz $cpuLimitMhz $memoryUsedMB $memoryLimitMB $storageUsedMB $storageLimitMB 
done

IFS=$OLDIFS

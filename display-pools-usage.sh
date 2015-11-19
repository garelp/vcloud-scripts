#!/bin/bash

#set -x

# Include the vloud function library.
source vcloud-api-func

# Check if a crendial file is passed as argument.
if [ $# -eq 1 ]; then
	source $1
fi

# if no credential are present, ask to define them.
if [ -z "$vcdOrg" ]; then
	echo "Please indicate a correct creds file or source the credentials."
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

printf "| %-20s | %-10s | %-20s | %-20s | %-20s | %-20s | %-20s | %-20s |\n" "Pool Name" "# of Vapp" "CPU Used (MHz)" "CPU Limit (MHz)" "Memory used (MB)" "Memory Limit (MB)" "Storage Used (MB)" "Storage Limit (MB)"

# Draw a separator
printf -v line '%*s' 175
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
	printf "| %-20s | %-10s | %-20s | %-20s | %-20s | %-20s | %-20s | %-20s |\n" $pool $numberOfVApps $cpuAllocationMhz $cpuLimitMhz $memoryUsedMB $memoryLimitMB $storageUsedMB $storageLimitMB 
done

IFS=$OLDIFS

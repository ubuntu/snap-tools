#!/bin/bash
#

publisher=$(snapcraft whoami |grep username | awk '{print $2}')

if [[ -z "$publisher" ]]; then
	echo "Unknown publisher, please login with snapcraft login"
	exit
fi

snaps=$(snap find $publisher |grep -v Name | awk '{print $1}')
for snap in $snaps;
do
	# Get the output of snap info
	channel_map=$(snap info $snap | grep -A 4 channels: |grep -v channels:)
	stable=$(echo "$channel_map" | grep stable | awk '{print $4}' | sed 's/[()]//g')
	candidate=$(echo "$channel_map" | grep candidate | awk '{print $4}' | sed 's/[()]//g')
	edge=$(echo "$channel_map" | grep edge | awk '{print $4}' | sed 's/[()]//g')

	if [[ -z "$stable" ]]; then
 		continue
	fi

	if [[ -z "$candidate" ]]; then
 		candidate=$stable
	fi

	if [[ -z "$edge" ]]; then
 		edge=$candidate
	fi

	if [[ "$stable" -ne "$edge" ]]; then
	    echo "$snap latest/stable=$stable has revision $edge available"
	fi
done

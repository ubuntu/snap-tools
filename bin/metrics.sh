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
    metrics=$(snapcraft metrics --name=weekly_installed_base_by_channel --format=json $snap | jq)

    # Extract the 'values' arrays from each series object and sum them
    total_sum=$(echo "$metrics" | jq '[.series[].values[]] | add')

    # Print the total weekly install base for the snap
    echo "Total install base for $snap: $total_sum"
    grand_total=$((grand_total + total_sum))
done

# Print the total weekly install base for all snaps from publisher
echo "Grand Total: $grand_total"

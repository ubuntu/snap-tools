#!/bin/bash

# Check for dependencies
if ! which xdotool 2>&1 > /dev/null; then
  echo "xdotool not found"
  exit
fi
if ! which jq 2>&1 > /dev/null; then
  echo "jq not found"
  exit
fi

run_xdotool () {
  windowclass=$1
  ./auto_close_win_id $windowclass 2>&1 > /dev/null &
}

run_snap () {
  snap=$1
  output=$(snap run --trace-exec $1 2>&1 > /dev/null)
  snap_confine=$(echo "$output" | grep snap-confine | awk '{print $1}')
  desktop_launch=$(echo "$output" | grep desktop-launch | awk '{print $1}')
  total_time=$(echo "$output" | grep "Total time" | awk '{print $3}')
  echo "$snap snap-confine: $snap_confine"
  echo "$snap desktop-launch: $desktop_launch"
  echo "$snap total-time: $total_time"
}

for row in $(cat snaps.json | jq -r '.snaps[] | @base64'); do
  _jq() {
    echo ${row} | base64 --decode | jq -r ${1}
  }
  snap=$(_jq '.snap')
  windowclass=$(_jq '.windowclass')
  run_xdotool $windowclass
  run_snap $snap
done

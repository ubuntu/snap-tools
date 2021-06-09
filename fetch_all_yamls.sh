#!/bin/bash

# Simple script to download snap.yaml files for every snap in the store
# please do not run this frequently

echo "Checking for curl..."
which curl
nocurl=$?

if [ $nocurl -gt 0 ]; then
    echo "This requires curl to function. Please install curl and try again"
    exit 1
fi

echo "Checking for jq..."
which jq
nojq=$?

if [ $nojq -gt 0 ]; then
    echo "This requires jq to function. Please install jq and try again"
    exit 1
fi

echo "Checking for yq..."
which yq
noyq=$?

if [ $noyq -gt 0 ]; then
    echo "This requires yq to function. Please install yq and try again"
    exit 1
fi

DATESTAMP=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%H%M%S)
FOLDER="$PWD"/"$DATESTAMP"-"$TIMESTAMP"-download
if mkdir -p "$FOLDER" ; then
  echo "Created $FOLDER"
else
  echo "Failed creating $FOLDER"
  exit 1
fi
LOGFILE="$FOLDER"/"$DATESTAMP"-"$TIMESTAMP"-log.txt
LISTFILE="$FOLDER"/names
cp /var/cache/snapd/names "$LISTFILE"
echo "Processing $LISTFILE"
cd "$FOLDER"
for f in $(cat "$LISTFILE");
do
  echo "Download yaml for $f" >> "$LOGFILE"
  mkdir $f
  url="https://api.snapcraft.io/v2/snaps/info/${f}?fields=snap-yaml"
  #echo $url >> "$LOGFILE"
  if curl -H "Snap-Device-Series: 16" $url 2>/dev/null | jq '."channel-map"' | jq '.[]' | jq -c 'select (."channel"."architecture" == "amd64" and  ."channel"."name" == "stable" )' | jq '[."snap-yaml"]' | yq e -P - | sed 1d > $f/snap.yaml; then
    echo "$f" >> "$LOGFILE"
  else
    echo "$f - FAILED" >> "$LOGFILE"
  fi
done

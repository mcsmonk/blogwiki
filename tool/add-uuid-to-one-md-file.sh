#!/usr/bin/env bash

MD_FILES=$1

UUID=`uuidgen`
UUID_HEAD=`echo $UUID | cut -c -6`
UUID_TAIL=`echo $UUID | cut -c 7-`
echo $MD_FILES
echo "UUID =" $UUID
echo "resource:" $UUID_HEAD"/"$UUID_TAIL
perl -i -pe "s,(^tag *:.*$),\1\nresource: $UUID_HEAD/$UUID_TAIL," $MD_FILES

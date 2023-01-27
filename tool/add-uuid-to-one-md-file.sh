#!/usr/bin/env bash

MD_FILES=$1

UUID=`uuidgen`
UUID_HEAD=`echo $UUID | cut -c -2`
UUID_TAIL=`echo $UUID | cut -c 3-`
echo $MD_FILES
echo $UUID
echo $UUID_HEAD
echo $UUID_TAIL
perl -i -pe "s,(^tag *:.*$),\1\nresource: $UUID_HEAD/$UUID_TAIL," $MD_FILES

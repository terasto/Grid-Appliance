#!/bin/bash
dir="/usr/local/ipop"
VMM=`$dir/scripts/utils.sh vmm`
release=`$dir/scripts/utils.sh check_release`

if [[ $1 = "start" ]]; then
  if [[ $VMM = "vmware" ]]; then
    drive_prefix="s"
  else
    drive_prefix="h"
  fi

  if [ $release == "yes" ]; then
    mount -text3 /dev/"$drive_prefix"db1 /.unionfs
    mkdir /.unionfs/.unionfs
    mount -text3 /dev/"$drive_prefix"dc1 /.unionfs/.unionfs
    dirs=`ls /`
    for dir in $dirs; do
      if [[ -d "/$dir" && $dir != "proc" && $dir != "sys" ]]; then
        mkdir /.unionfs/$dir &> /dev/null
        mkdir /.unionfs/.unionfs/$dir &> /dev/null
        if [[ $dir = "tmp" ]]; then
          chmod 777 /.unionfs/.unionfs/$dir &> /dev/null
        else
          chmod 755 /.unionfs/.unionfs/$dir &> /dev/null
        fi
        mount -t unionfs -odefaults,dirs=/.unionfs/.unionfs/$dir=rw:/.unionfs/$dir=ro:/$dir=ro none /$dir
      fi
    done
  else
    mount -text3 /dev/"$drive_prefix"db1 /.unionfs
    dirs=`ls /`
    for dir in $dirs; do
      if [[ -d "/$dir" && $dir != "proc" && $dir != "sys" ]]; then
        mkdir /.unionfs/$dir &> /dev/null
        if [[ $dir = "tmp" ]]; then
          chmod 777 /.unionfs/$dir &> /dev/null
        else
          chmod 755 /.unionfs/$dir &> /dev/null
        fi
        mount -t unionfs -odefaults,dirs=/.unionfs/$dir=rw:/$dir=ro none /$dir
      fi
    done
  fi
fi

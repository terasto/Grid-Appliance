#!/bin/bash
dir="/usr/local/ipop"

if [ "$2" ]; then
  echo="logger -t update_ipop"
else
  echo="echo"
fi

#Checks to see if there is a newer version of iprouter available
if [[ $1 != "start" ]]; then
  sleeptime=`expr $RANDOM \* 120`
  sleeptime=`expr $sleeptime % 1800`
  $echo Sleeping for $sleeptime then checking for updates...
  sleep $sleeptime
fi

iptables -F

echo "Checking for latest version of iprouter"
wget http://128.227.56.252/~ipop/debian/ga2/current.txt -O $dir/var/current.txt &> /dev/null
if test -f $dir/var/current.txt; then
  web_version=`cat $dir/var/current.txt`
else
  web_version=-1
fi
local_version=`cat $dir/etc/current.txt`
if (( web_version > local_version )); then
  $echo "New version found!  Updating..."
  wget http://128.227.56.252/~ipop/debian/ga2/ipop.deb -O $dir/var/ipop.deb
  dpkg --install $dir/var/ipop.deb
  rm -f $dir/var/ipop.deb
else
  $echo "Current version is up to date!"
fi

rm $dir/var/current.txt
$echo "Complete"
$dir/scripts/iprules

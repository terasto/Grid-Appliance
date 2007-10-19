#!/bin/bash
dir="/usr/local/ipop"

if [[ $1 = "start" ]]; then
  ipop_ns=`cat /mnt/fd/ipop_ns`
  cp $dir/etc/condor_config /etc/condor/condor_config
  # Get a random servers IP address
  server=`$dir/scripts/DhtHelper.py get server $ipop_ns`
  flock=`$dir/scripts/DhtHelper.py get flock $ipop_ns`
  #  We bind to all interfaces for condor interface to work
  ip=`$dir/scripts/util.sh get_ip tap0`
  echo "NETWORK_INTERFACE = "$ip >> /etc/condor/condor_config
  $dir/scripts/sscndor.sh

  type=`cat /mnt/fd/type`
  if [ $type = "Server" ]; then
    DAEMONS="MASTER, COLLECTOR, NEGOTIATOR"
    $dir/scripts/DhtHelper.py unregister $ipop_ns:condor:server $oldip 1200
    $dir/scripts/DhtHelper.py register $ipop_ns:condor:server $ip 1200
    # Override the server with us, otherwise it won't work!!!
    server=$ip
  elif [ $type = "Submit" ]; then
    DAEMONS="MASTER, SCHEDD"
  elif [ $type = "Worker" ]; then
    DAEMONS="MASTER, STARTD"
  else #$type = Client
    DAEMONS="MASTER, STARTD, SCHEDD"
  fi

  echo "DAEMON_LIST = "$DAEMONS >> /etc/condor/condor_config
  echo "CONDOR_HOST = "$server >> /etc/condor/condor_config
  echo $server > $dir/var/condor_manager

  rm -f /opt/condor/var/log/* /opt/condor/var/log/*
  # This is run to limit the amount of memory condor jobs can use - up to the  contents
  # of physical memory, that means a swap disk is necessary!
  ulimit -v `cat /proc/meminfo | grep MemTotal | awk -F" " '{print $2}'`
  /opt/condor/sbin/condor_master
elif [[ $1 = "restart" ]]; then
  $dir/scripts/gridcndor.sh stop
  $dir/scripts/gridcndor.sh start
elif [[ $1 = "stop" ]]; then
  pkill -KILL condor
fi
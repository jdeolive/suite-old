#!/bin/bash

. functions

if [ -z $2 ]; then
  echo "Usage: $0 <INSTANCE_ID> <ZONE> [OPTIONS]"
  echo "OPTIONS:"
  echo -e " -nvol:\t\tNumber of volumes. Default is 4."
  echo -e " -size:\t\tSize of each volume. Default is 100G."
  echo -e " -dev:\t\tRaid device. Default is /dev/md0 ."
  echo -e " -mnt:\t\tMount point of raid device. Default is /mnt/raid ."
  exit 1
fi

check_ec2_tools

# defaults
NVOL=4
SIZE=100
MNT=/mnt/raid
DEV=/dev/md0

# parse command line args
args=$( $* )
for (( i=0; i < ${#args[*]}; i++ )); do
  arg=${args[$i]}
  if [ arg == "-nvol" ]; then 
    NVOL=${args[(( i+1 ))]}
  fi
  if [ arg == "-size" ]; then 
    SIZE=${args[(( i+1 ))]}
  fi
  if [ arg == "-mnt" ]; then 
    MNT=${args[(( i+1 ))]}
  fi
  if [ arg == "-dev" ]; then 
    DEV=${args[(( i+1 ))]}
  fi
done

# upload the setup script and invoke it
SSH_OPTS=`ssh_opts`
HOST=`ec2_instance_host $INTANCE_ID`
if [ -z $HOST ]; then
  echo "No instance $INSTANCE_ID. Exiting."
  exit 1
fi

scp $SSH_OPTS functions setup_raid.sh ubuntu@$HOST:/home/ubuntu
check_rc $? "upload raid setup scripts"

ssh $SSH_OPTS ubuntu@$HOST 'cd /home/ubuntu && ./setup_raid.sh $NVOL $SIZE $MNT $DEV'
check_rc $? "remote raid setup"


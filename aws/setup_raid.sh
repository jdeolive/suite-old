#!/bin/bash

. functions

if [ -z $5 ]; then
  echo "Usage: $0 NVOL SIZE DEV MNT INSTANCE_ID ZONE [--skip-create-volumes] [--with-volumes vol1 vol2 ...]"
  exit 1
fi

export EC2_PRIVATE_KEY=`ls ~/pk-*`
export EC2_CERT=`ls ~/cert-*`

NVOL=$1
SIZE=$2
DEV=$3
MNT=$4
INSTANCE_ID=$5
ZONE=$6

args=( $* )
for (( i=6; i < ${#args[*]}; i++ )); do
  arg=${args[$i]}
  if [ $arg == "--with-volumes" ]; then
     vol_ids=()
     for (( j=i+1; j < ${#args[*]}; j++ )); do
       vol_id=${args[$j]} 

       # verify that the volume exists and is available
       vol_status=`ec2_volume_status $vol_id`
       if [ -z $vol_status ]; then
         echo "Volume $vol_id does not exists. Exiting"
         exit 1
       fi
       if [ $vol_status != "available" ]; then
         echo "Volume $vol_id is not available. Status is $vol_status. Exiting."
         exit 1
       fi

       vol_ids[(( j-i-1 ))]=$vol_id
     done
     
     break
  fi
  if [ $arg == "--skip-create-volumes" ]; then
    SKIP_CREATE_VOLUMES="yes"
  fi
done

# raid stuff TODO: make these configurable
RAID_LEVEL=10
RAID_LAYOUT=f2
RAID_CHUNK=256

# check for existing raid config
cat /etc/mdadm.conf | grep $DEV > /dev/null
if [ $? -eq 0 ]; then
  echo "/etc/mdadm.conf already contains raid config for $DEV. Exiting" 
  exit 1
fi

devs=$(perl -e 'for$i("h".."k"){for$j(1..15){print"/dev/sd$i$j\n"}}'| head -$NVOL)
devs=( $devs )

log "Setting up raid with devices ${devs[*]}"

# check that the devices are not already mounted
for dev in ${devs[*]}; do
  if [ -e $dev ]; then
    echo "Device $dev already exists. Exiting."
    exit 1
  fi
done


RAID_MODE="assemble"
if [ -z $SKIP_CREATE_VOLUMES ]; then
  if [ -z $vol_ids ]; then
    RAID_MODE="create"

    # create the volumes
    vol_ids=()
    for (( i=0; i < $NVOL; i++ )); do
      vol_id=$(ec2-create-volume -z $ZONE --size $SIZE | cut -f2)
      check_rc $? "ec2-create-volume"
      log "Created $vol_id"

      vol_ids[$i]=$vol_id
    done
  fi

  log "Setting up RAID with volumes ${vol_ids[*]}"

  for (( i=0; i < $NVOL; i++ )); do
     dev=${devs[$i]}
     vol_id=${vol_ids[$i]}

     ec2-attach-volume $vol_id -i $INSTANCE_ID -d $dev
     check_rc $? "ec2-create-volume"
  done
fi

# wait for devices to attach
for dev in ${devs[*]}; do
  for (( i=0; i < 5; i++ )); do
    if [ -e $dev ]; then 
      break
    fi
    sleep 2
  done
  if [ ! -e $dev ]; then
    echo "$dev did not attach. Exiting."
    exit 1
  fi
done

sudo apt-get update &&
sudo apt-get install -y mdadm xfsprogs
check_rc $? "apt-get mdadm xfsprogs"

if [ $RAID_MODE == "create" ]; then
  yes | sudo mdadm \
  --create $DEV \
  --chunk=$RAID_CHUNK \
  --level=$RAID_LEVEL \
  --layout=$RAID_LAYOUT \
  --metadata=1.1 \
  --raid-devices $NVOL ${devs[*]}
  check_rc $? "mdadm"
else
  sudo mdadm --assemble $DEV ${devs[*]}
fi

# update mdadm.conf
if [ $( grep "DEVICE ${devs[*]}" /etc/mdadm.conf | wc -l ) -eq 0 ]; then
  echo "DEVICE ${devs[*]}" | sudo tee /etc/mdadm.conf
fi
sudo sed -i '/ARRAY $DEV/d' /etc/mdadm.conf
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm.conf

if [ $RAID_MODE == "create" ]; then
  sudo mkfs.xfs $DEV
  check_rc $? "mkfs.xsfs $DEV"
fi

# add an fstab entry
if [ $( grep "$DEV $MNT *" /etc/fstab | wc -l ) -eq 0 ]; then
  echo "$DEV $MNT xfs noatime 0 0" | sudo tee -a /etc/fstab
fi
if [ ! -d $MNT ]; then
  sudo mkdir $MNT
fi

sudo mount $MNT
check_rc $? "mount $MNT"

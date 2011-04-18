#!/bin/bash

. functions

# poll_instance <client_token> [<max_iterations>]
function poll_instance() {
  local client_token=$1
  local max_iter=$2
  local stat=""
  local i=0  

  if [ -z $max_iter ]; then
    max_iter=50
  fi

  while [ "$stat" != "running" ]; do
    if [ $i -lt $max_iter ]; then
       (( i++ ))
    else
       return 1
    fi
    sleep 5
    
    stat=`ec2-describe-instances -F client-token=$client_token | grep "^INSTANCE" | cut -f 6`   
    log "status of ami $client_token is $stat"
  done

  # poll until the host is able to accept ssh connections
  i=0
  local ret=1
  local SSH_OPTS=`ssh_opts` 
  local HOST=`ec2_instance_host $CLIENT_TOKEN` 
  while [ $ret -ne 0 ]; do
    if [ $i -lt $max_iter ]; then
       (( i++ ))
    else
       return 1
    fi
    sleep 5

    ssh $SSH_OPTS ubuntu@$HOST 'ls'
    ret=$?
  done

  return 0
}

# poll_image <image-id> [<max_iterations>]
function poll_image() {
  local image_id=$1
  local max_iter=$2
  local stat=""
  local i=0  

  if [ -z $max_iter ]; then
    max_iter=50
  fi

  while [ "$stat" != "available" ]; do
    if [ $i -lt $max_iter ]; then
       (( i++ ))
    else
       return 1
    fi
    sleep 5
    
    stat=`ec2_image_status $image_id`
    log "status of image $image_id is $stat"
  done

  return 0
}

set -x
if [ -z $3 ]; then
  echo "Usage: $0 AMI_ID IMAGE_NAME <dev|prod> [-t 'ebs'|'s3'] [ -a 'i386'|'x86_64'] [ -s 'm1.small'|'m1.large'] [ -bp <base|ee> ] [ -p <product_id> ] [--skip-create-image]"
  exit 1
fi

# ensure the ec2 api tools are properly setup
check_ec2_tools

# parse the command line args
args=( $* )
for (( i = 2; i < ${#args[*]}; i++ )); do
  arg=${args[$i]}
  val=${args[(( i+1 ))]}
  if [ $arg == "-t" ]; then
    IMAGE_TYPE=$val
  fi
  if [ $arg == "-a" ]; then
    IMAGE_ARCH=$val
  fi
  if [ $arg == "-s" ]; then
    IMAGE_SIZE=$val
  fi
  if [ $arg == "-bp" ]; then
    BUILD_PROFILE=$val
  fi
  if [ $arg == "-p" ]; then
    PRODUCT_ID=$val
  fi
  if [ $arg == "--skip-create-image" ]; then
    SKIP_CREATE_IMAGE="yes"
  fi
done

if [ -z $IMAGE_TYPE ]; then
  IMAGE_TYPE="ebs"
fi
if [ -z $IMAGE_ARCH ]; then
  IMAGE_ARCH="i386"
fi
if [ -z $IMAGE_SIZE ]; then
  IMAGE_SIZE="m1.small"
  if [ $IMAGE_ARCH == "x86_64" ]; then
    IMAGE_SIZE="m1.large"
  fi 
fi

AMI_ID=$1
IMAGE_NAME=$2
ACCOUNT=$3
if [ $ACCOUNT != "dev" ] && [ $ACCOUNT != "prod" ]; then
  echo "ACCOUNT must be one of 'dev' or 'prod'. Exiting"
  exit 1
fi

CLIENT_TOKEN=`uuidgen`

log "Starting instance from ami $AMI_ID with client token $CLIENT_TOKEN"
ec2-run-instances -k suite -t $IMAGE_SIZE $AMI_ID --client-token $CLIENT_TOKEN 
check_rc $? "ec2-run-instances"

log "Polling instance"
poll_instance $CLIENT_TOKEN
check_rc $? "poll_instance"

HOST=`ec2_instance_host $CLIENT_TOKEN`
log "instance available at $HOST"

INSTANCE_ID=`ec2_instance_id $CLIENT_TOKEN`
log "instance id is $INSTANCE_ID"

SSH_OPTS=`ssh_opts`

scp $SSH_OPTS setup_ubuntu_image.sh functions ubuntu@$HOST:/home/ubuntu
check_rc $? "updload setup script"

ssh $SSH_OPTS ubuntu@$HOST "cd /home/ubuntu && ./setup_ubuntu_image.sh $IMAGE_SIZE $BUILD_PROFILE"
check_rc $? "remote setup"

if [ -z $SKIP_CREATE_IMAGE ]; then
  # first check for an already registred image with this name and deregister it
  OLD_IMAGE_ID=$( ec2-describe-images -F name=$IMAGE_NAME | cut -f 2 ) 
  if [ ! -z $OLD_IMAGE_ID ]; then
     ec2-deregister $OLD_IMAGE_ID
     check_rc $? "ec2-deregister $OLD_IMAGE_ID"
  fi

  if [ $IMAGE_TYPE == "ebs" ]; then
    IMAGE_ID=$( ec2-create-image -n $IMAGE_NAME $INSTANCE_ID | cut -f 2 )
    check_rc $? "ec2-create-image"    

    poll_image $IMAGE_ID
    check_rc $? "ec2-create-image"    
  else
    scp $SSH_OPTS bundle_s3_image.sh $EC2_PRIVATE_KEY $EC2_CERT ubuntu@$HOST:/home/ubuntu
    check_rc $? "upload bundle script and private key and certificate"

    scp $SSH_OPTS s3-$ACCOUNT.properties ubuntu@$HOST:/home/ubuntu/s3.properties
    check_rc $? "upload s3 properties"

    scp $SSH_OPTS s3cfg-$ACCOUNT ubuntu@$HOST:/home/ubuntu/s3cfg
    check_rc $? "upload s3cfg-$ACCOUNT"
  
    ssh $SSH_OPTS ubuntu@$HOST "cd /home/ubuntu && ./bundle_s3_image.sh $IMAGE_NAME $IMAGE_ARCH -p $PRODUCT_ID"
    check_rc $? "remote bundle image"
  fi
fi

# shut down the instance
ec2-terminate-instances $INSTANCE_ID

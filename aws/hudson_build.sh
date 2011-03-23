#!/bin/bash

if [ -z $4 ]; then
  echo "Usage: $0 AMI_ID <i386|x86_64> <ebs|s3> <dev|prod> [-p <product_id>]"
  exit 1
fi

AMI_ID=$1
IMAGE_ARCH=$2
IMAGE_TYPE=$3
ACCOUNT=$4

if [ $5 == "-p" ]; then
  PRODUCT_ID=$6
fi

IMAGE_SIZE="m1.small"
if [ $IMAGE_ARCH == "x86_64" ]; then
  IMAGE_SIZE="m1.large"
fi

# initialize ec2 api stuff
pushd $HOME/.ec2/aws-suite-$ACCOUNT > /dev/null
. activate
popd > /dev/null

# get the ami version
. functions
ver=`get_ami_version $REPO_PATH`

# build it
./build_ubuntu_ami.sh $AMI_ID suite-$ver-$IMAGE_ARCH-`date +"%Y%m%d"` $ACCOUNT -t $IMAGE_TYPE -s $IMAGE_SIZE -a $IMAGE_ARCH -p $PRODUCT_ID

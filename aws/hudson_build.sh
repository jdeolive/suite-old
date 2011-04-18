#!/bin/bash

if [ -z $6 ]; then
  echo "Usage: $0 AMI_ID <i386|x86_64> <IMAGE_SIZE> <ebs|s3> <dev|prod> <base|ee> [-pi <product_id> -pn <product_name>]"
  exit 1
fi

AMI_ID=$1
IMAGE_ARCH=$2
IMAGE_SIZE=$3
IMAGE_TYPE=$4
ACCOUNT=$5
BUILD_PROFILE=$6

args=( $* )
for (( i=6; i < ${#args[*]}; i++ )); do
  if [ ${args[$i]} == "-pi" ]; then
    PRODUCT_ID=${args[(( i+1 ))]}
  fi
  if [ ${args[$i]} == "-pn" ]; then
    PRODUCT_NAME=${args[(( i+1 ))]}
  fi
done

if [ -z $PRODUCT_ID ] && [ ! -z $PRODUCT_NAME ]; then
  echo "Both product id and name must be specfied."
  exit 1
fi
if [ ! -z $PRODUCT_ID ] && [ -z $PRODUCT_NAME ]; then
  echo "Both product id and name must be specfied."
  exit 1
fi

# initialize ec2 api stuff
pushd $HOME/.ec2/aws-suite-$ACCOUNT > /dev/null
. activate
popd > /dev/null

# get the ami version
. functions
ver=`get_ami_version $REPO_PATH`

if [ ! -z $PRODUCT_ID ]; then
  prod="-pi $PRODUCT_ID -pn $PRODUCT_NAME"
fi

if [ "$ACCOUNT" == "dev" ]; then
  SKIP_PRODUCT_CODE="--skip-product-code"
fi

IMAGE_NAME=suite-$ver-$IMAGE_ARCH-`date +"%Y%m%d"`
if [ ! -z $PRODUCT_NAME ]; then
  IMAGE_NAME=suite-$PRODUCT_NAME-$ver-$IMAGE_ARCH-`date +"%Y%m%d"`
fi

# build it
./build_ubuntu_ami.sh $AMI_ID $IMAGE_NAME $ACCOUNT -t $IMAGE_TYPE -s $IMAGE_SIZE -a $IMAGE_ARCH -bp $BUILD_PROFILE $prod $SKIP_PRODUCT_CODE

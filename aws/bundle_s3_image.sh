#!/bin/bash

set -x

. functions
. s3.properties

if [ -z $2 ]; then
  echo "Usage: $0 NAME ARCH [-p PRODUCT_ID] [--skip-bundle] [--skip-upload] [--skip-register] [--skip-product-code ]"
  exit 1
fi
args=( $* )
for (( i=2; i < ${#args[*]}; i++ )); do
  if [ ${args[$i]} == "-p" ]; then
    PRODUCT_ID=${args[(( i+1 ))]}
  fi
  if [ ${args[$i]} == "--skip-bundle" ]; then
    SKIP_BUNDLE="yes"
  fi
  if [ ${args[$i]} == "--skip-upload" ]; then
    SKIP_UPLOAD="yes"
  fi
  if [ ${args[$i]} == "--skip-register" ]; then
    SKIP_REGISTER="yes"
  fi
  if [ ${args[$i]} == "--skip-product-code" ]; then
    SKIP_PRODUCT_CODE="yes"
  fi
done

IMAGE_NAME=$1
IMAGE_ARCH=$2
export EC2_PRIVATE_KEY=`ls ~/pk-*`
export EC2_CERT=`ls ~/cert-*`

# install the ec2-api/ami-tools and s3cmd
sudo bash -c "echo 'deb http://us.archive.ubuntu.com/ubuntu/ lucid multiverse' >> /etc/apt/sources.list"
sudo apt-get update
sudo apt-get -y install ec2-api-tools ec2-ami-tools s3cmd
check_rc $? "apt-get install ec2 api/ami + s3cmd tools"

if [ -z $SKIP_BUNDLE ]; then
  # bundle the image
  sudo ec2-bundle-vol -c $EC2_CERT -k $EC2_PRIVATE_KEY -u $S3_USER -r $IMAGE_ARCH -e /home/ubuntu
  check_rc $? "ec2-bundle-vol"
fi

IMAGE_MANIFEST=/tmp/image.manifest.xml
if [ ! -e  $IMAGE_MANIFEST ]; then
  echo "No such file $IMAGE_MANIFEST. Exiting."
  exit 1
fi

S3_BUCKET=$S3_BUCKET_ROOT/$IMAGE_NAME
S3CMD_CONFIG=~/s3cfg

s3cmd -c $S3CMD_CONFIG ls s3://$S3_BUCKET_ROOT 
check_rc $? "listing contents of $S3_BUCKET_ROOT"

# figure out if the directory already exists, and delete it if necessary
s3cmd -c $S3CMD_CONFIG ls s3://$S3_BUCKET_ROOT | grep $IMAGE_NAME
if [ $? -eq 0 ]; then
  s3cmd -c $S3CMD_CONFIG -r del s3://$S3_BUCKET
fi

if [ -z $SKIP_UPLOAD ]; then
  # upload the bundle
  ec2-upload-bundle -b $S3_BUCKET -m $IMAGE_MANIFEST -a $S3_ACCESS_KEY -s $S3_SECRET_KEY
  check_rc $? "ec2-upload-bundle"
fi

if [ -z $SKIP_REGISTER ]; then
  # register the ami
  IMAGE_ID=$( ec2-register $S3_BUCKET/image.manifest.xml -n $IMAGE_NAME -a $IMAGE_ARCH | cut -f 2 )
  check_rc $? "ec2-register"

  if [ ! -z $PRODUCT_ID ] && [ -z $SKIP_PRODUCT_CODE ]; then
    # link the image to the product id
    ec2-modify-image-attribute $IMAGE_ID -p $PRODUCT_ID
    check_rc $? "linking image $IMAGE_ID to product $PRODUCT_ID"
  
    # make the image public
    ec2-modify-image-attribute $IMAGE_ID -l -a all
    check_rc $? "making image $IMAGE_ID public"
  fi
fi

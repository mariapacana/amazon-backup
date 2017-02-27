#!/bin/bash

source ./amazon/tar_and_encrypt.sh

upload() {
  BACKUP_SOURCE_DIR="$1"
  BACKUP_DEST_DIR=~/tmp/"$(basename $BACKUP_SOURCE_DIR)"-backup
  PUBLICKEY=$2
  AMAZON_S3_DIR=$3

  if [ $# -lt 3 ]; then
    echo 1>&2 "$0: Not enough arguments. 'upload [source-dir] [/path/to/publickey] [s3-folder]'"
    exit 1
  fi

	echo "Backup Source Directory: $BACKUP_SOURCE_DIR"
  echo "Backup Destination Dir: $BACKUP_DEST_DIR"
  echo "PUBLICKEY: $PUBLICKEY"
  echo "Amazon S3 Dir: $AMAZON_S3_DIR"

  compress_and_encrypt $BACKUP_SOURCE_DIR $BACKUP_DEST_DIR $PUBLICKEY
  s3cmd sync $BACKUP_DEST_DIR $AMAZON_S3_DIR
  rm -rf $BACKUP_DEST_DIR
}


download() {
  AMAZON_SOURCE_DIR=$1
  PRIVATE_KEY=$2
  BACKUP_DEST_DIR="$3"-backup

  if [ $# -lt 3 ]; then
    echo 1>&2 "$0: Not enough arguments. 'download [amazon-source-dir] [/path/to/privatekey] [dest-folder]'"
    exit 1
  fi

  echo "Amazon Source Directory: $AMAZON_SOURCE_DIR"
  echo "Private Key Path: $PRIVATE_KEY"
  echo "Backup Destination: $BACKUP_DEST_DIR"

  mkdir $BACKUP_DEST_DIR

  s3cmd get "$AMAZON_SOURCE_DIR"/backup.enc $BACKUP_DEST_DIR
  s3cmd get "$AMAZON_SOURCE_DIR"/key.bin.enc $BACKUP_DEST_DIR
  decrypt_and_uncompress $PRIVATE_KEY $BACKUP_DEST_DIR
}

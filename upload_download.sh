#!/bin/bash

source ./amazon/tar_and_encrypt.sh

upload() {
	BACKUP_SOURCE_DIR="$1"
	BACKUP_DEST_DIR="$1"-backup
	PUBLICKEY=$2
	AMAZON_S3_DIR=$3

	if [ $# -lt 3 ]; then
  	echo 1>&2 "$0: Not enough arguments. 'upload [source-dir] [/path/to/publickey] [s3-folder]'"
  	exit 1
  fi

  compress_and_encrypt $BACKUP_SOURCE_DIR $BACKUP_DEST_DIR $PUBLICKEY
	s3cmd sync $BACKUP_DEST_DIR $AMAZON_S3_DIR
	rm -rf $BACKUP_DEST_DIR
}


download() {
	if [ $# -lt 1 ]; then
  	echo 1>&2 "$0: Not enough arguments. Need path to private key"
    exit 1
	fi
	mkdir amazon_backup_encrypted
  s3cmd get s3://sibilance-backup/backup/backup.enc amazon_backup_encrypted
	s3cmd get s3://sibilance-backup/backup/key.bin.enc amazon_backup_encrypted
  decrypt_and_uncompress $1 amazon_backup_encrypted/key.bin.enc amazon_backup_encrypted/backup.enc
}

#!/bin/bash

source ./amazon/tar_and_encrypt.sh

upload() {
	compress_and_encrypt "$@"
	s3cmd sync backup s3://sibilance-backup
	rm -rf backup
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

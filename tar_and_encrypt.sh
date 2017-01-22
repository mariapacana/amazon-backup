#!/bin/bash

encrypt() {
  tar -zcvf backup.tar.gz "$@" | \
	openssl rand -base64 32 > key.bin
	openssl rsautl -encrypt -inkey /home/maria/public.pem -pubin -in key.bin -out key.bin.enc
  openssl enc -aes-256-cbc -salt -in backup.tar.gz -out backup.enc -pass file:./key.bin
	rm backup.tar.gz
}

decrypt() {
	if [ $# -lt 3 ]; then
  	echo 1>&2 "$0: Not enough arguments. Need private key, symmetric key, backup file"
  exit 1
  fi
	openssl rsautl -decrypt -inkey $1 -in $2 -out key.bin 
	openssl enc -d -aes-256-cbc -in $3 -out BACKUP -pass file:./key.bin
	tar -zxvf BACKUP
}


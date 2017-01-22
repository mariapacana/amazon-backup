#!/bin/bash

# Generate a symmetric key. 
# Convert backup directory into tarball.
# Encrypt symmetric key with public key and encrypt tarball with symmetric key.
# Store tarball and encrypted symmetric key in backup/
compress_and_encrypt() {
	mkdir backup
	openssl rand -base64 32 > backup/key.bin
	openssl rsautl -encrypt -inkey /home/maria/public.pem -pubin -in backup/key.bin -out backup/key.bin.enc
  tar -zc "$@" | openssl enc -aes-256-cbc -salt -in /dev/stdin -out backup/backup.enc -pass file:./backup/key.bin
	rm backup/key.bin	
}

# Decrypt symmetric key with private key. 
# Decrypt tarball with decrypted symmetric key.
# Uncompress tarball into recovered_backup/
decrypt_and_uncompress() {
	if [ $# -lt 3 ]; then
  	echo 1>&2 "$0: Not enough arguments. Need private key, symmetric key, backup file"
  exit 1
  fi
	openssl rsautl -decrypt -inkey $1 -in $2 -out key.bin 
	mkdir recovered_backup
	openssl enc -d -aes-256-cbc -in $3 -out /dev/stdout -pass file:./key.bin | tar -zxvf /dev/stdin -C recovered_backup
	rm key.bin
}


#!/bin/bash

# Generate a symmetric key. 
# Convert backup directory into tarball.
# Encrypt symmetric key with public key and encrypt tarball with symmetric key.
# Store tarball and encrypted symmetric key in backup/
compress_and_encrypt() {
  BACKUP_SOURCE_DIR=$1
  BACKUP_DEST_DIR=$2
  PUBLICKEY=$3
  mkdir $BACKUP_DEST_DIR
  openssl rand -base64 32 > "$BACKUP_DEST_DIR"/key.bin
  openssl rsautl -encrypt -inkey $PUBLICKEY -pubin -in "$BACKUP_DEST_DIR"/key.bin -out "$BACKUP_DEST_DIR"/key.bin.enc
  tar -zc "$BACKUP_SOURCE_DIR" | openssl enc -aes-256-cbc -salt -in /dev/stdin -out "$BACKUP_DEST_DIR"/backup.enc -pass file:"$BACKUP_DEST_DIR"/key.bin
  rm "$BACKUP_DEST_DIR"/key.bin	
}

# Decrypt symmetric key with private key. 
# Decrypt tarball with decrypted symmetric key.
# Uncompress tarball into recovered_backup/
decrypt_and_uncompress() {
  PRIVATEKEY=$1
  BACKUP_DIR=$2

  if [ $# -lt 2 ]; then
    echo 1>&2 "$0: Not enough arguments. 'decrypt_and_uncompress [path/to/privatekey] [path/to/backupdir]'"
    exit 1
  fi
 
  echo "Private Key: $PRIVATEKEY"
  echo "$BACKUP_DIR"/key.bin.enc
  openssl rsautl -decrypt -inkey $PRIVATEKEY -in "$BACKUP_DIR"/key.bin.enc -out "$BACKUP_DIR"/key.bin 
  openssl enc -d -aes-256-cbc -in "$BACKUP_DIR"/backup.enc -out /dev/stdout -pass file:"$BACKUP_DIR"/key.bin | tar -zxvf /dev/stdin -C $BACKUP_DIR
  rm "$BACKUP_DIR"/key.bin "$BACKUP_DIR"/key.bin.enc "$BACKUP_DIR"/backup.enc
}


# amazon-backup

### Generate Symmetric Key in Hex Format
```
openssl rand -hex -out ~/Desktop/sym_keyfile.key 128
```

### Split up Symmetric Key into 5 Parts (3 Required)
```
./ssss-split -x -t 3 -n 5 < ~/Desktop/sym_keyfile.key
./ssss-combine -x -t 3 (to verify that SSSS worked)
```

### Generate Encrypted Private Key
```
openssl genrsa -out private.pem -passout file:sym_keyfile.key -des3 2048
```

### Extract Public Key from Private Key
```
openssl rsa -in private.pem -outform PEM -pubout -out public.pem -passin file:sym_keyfile.key
```


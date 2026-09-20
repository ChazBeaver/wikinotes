# Check If PEM is Valid using OpenSSL

```bash
openssl x509 -in <name-of-pem-file.pem> -text -noout
```

## NOTE

If that fails (which it might since this is a bundle with multiple certs), try this instead to see how many certs are in the file:

```bash
grep 'BEGIN CERTIFICATE' global-bundle.pem | wc -l
```

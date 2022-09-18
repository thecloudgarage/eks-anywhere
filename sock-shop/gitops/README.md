* Edit the hostname in the ingress resource file

* Create a base64 encoded value of tls.crt and tls.key & change in the provided YAML

```
cp sslcert.conf.sample sslcert.conf
sed -i 's/fqdnOfSockShopFrontEnd/<acutal-host-name>/g' sslcert.conf
openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout tls.key -out tls.crt -config sslcert.conf -extensions 'v3_req'
cat tls.crt | base64 -w 0 
# Copy the single line value and replace the existing one in the YAML
cat tls.key | base64 -w 0 
# Copy the single line value and replace the existing one in the YAML
```

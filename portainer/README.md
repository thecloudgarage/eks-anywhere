* For docker-compose ensure that the keycloak.pem is copied from the oidc directory here
* Before starting docker-compose, create the directory portainer-data
* Copy the sslcert.conf.sample as sslcert.conf and edit the portainer URL
* For docker-compose the exposed port is 11443

```
cp ../oidc/keycloak.pem .
mkdir portainer-data
cp sslcert.conf.sample sslcert.conf
openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout tls.key -out tls.crt -config sslcert.conf -extensions 'v3_req'
cp tls.crt portainer.crt
cp tls.key portainer.key
```
* Login and create the intial password (preferably admin@12345678)
* Navigate to settings > authentication > oidc and change the oidc settings

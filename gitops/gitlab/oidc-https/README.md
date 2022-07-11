![image](https://user-images.githubusercontent.com/39495790/176620649-31a6e806-7fd8-4781-aa65-7e6e9784dc62.png)

* Ensure that the three directories are created (config, data, logs) ahead of deploying the docker-compose
* Ensure the openssl cert generated tls.crt and tls.key are renamed as the FQDN.key and FQDN.pem as gitlab references them accordingly
* Edit the FQDN of the gitlab server and then copy the ssl sample cert conf file into sslcert.conf

```
cd $HOME/eks-anywhere/gitops/gitlab/oidc-https
cp sslcert.conf.sample sslcert.conf
openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout tls.key -out tls.crt -config sslcert.conf -extensions 'v3_req'
```
* If you reuse the SSL cert conf file that is used for the keycloak config, then SSL KEY INCOMPATIBLE ISSUE will happen
* Ensure that the format of the SSL cert conf file is followed as it is provided in this directory
* We will also need the keycloak PEM format of the certificate file that is used to trust the self-signed cert of the keycloak server
```
cd $HOME/eks-anywhere/gitops/gitlab/oidc-https
cp $HOME/eks-anywhere/oidc/tls.crt keycloak.pem
```

![gitlab-keycloak-sso](https://user-images.githubusercontent.com/39495790/176621088-8a99d2b3-7bf8-4bf4-9bd9-f73f56c1596f.gif)

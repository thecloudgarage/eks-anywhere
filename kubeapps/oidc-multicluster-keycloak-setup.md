* Assuming we have the basic keycloak setup for our EKSA setup with a Keycloak client called "kube"
* Next create a new Client called kubeapps with basic configs (standard flow enabled, direct grants and access type confidential) and a redirect url set to https://<kubeapps-FQDN>/oauth2/callback
* Go to client scopes within Kubeapps client and add the groups scope
* Once done., within the kubeapps client create a new mapper like the one below
  
![image](https://user-images.githubusercontent.com/39495790/186050280-8eefa39e-6142-4096-99c6-aa29c4aa11c7.png)

  

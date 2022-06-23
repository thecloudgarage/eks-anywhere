* Edit the host value in the ingress-front-end.yaml
* Ensure a MetalLB or KubeVIP load balancer is configured
* Apply the Ingress controller YAML
* Apply the namespace yaml
* The Storage class used in complete demo YAML defaults to "standard". Change if required
* Apply the complete demo YAML
* Validate the outputs from kubectl
* Create a DNS entry with the host value and the Ingress IP address
* Validate the application workflow
> NOTE: All the databases are initialized included the user-db and catalogue-db so no need to reseed the databases

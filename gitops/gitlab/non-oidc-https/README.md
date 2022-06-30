* Ensure the three sub-directories are created config, data, logs
* Ensure that the .crt and .key files exist with the file name as your gitlab server's FQDN
* Gitlab server will be available on https://fqdnOfGitlabServer:10443
* Execute the below command to retrieve the root password and then login with username as root and the password

```
sudo docker exec -it gitlab_web_1 grep 'Password:' /etc/gitlab/initial_root_password

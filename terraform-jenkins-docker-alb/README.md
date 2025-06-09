Provide Below Informations to provision the Infrastructure using Terrfaorm
```
1. Provide SSH Private Key in mykey.pem file.
2. Provide SSH Public Key in the files user_data_docker_server.sh, user_data_jenkins_master.sh, user_data_jenkins_slave.sh.
3. Provide kms_key_id to encrypt EBS and certificate_arn of you AWS Certificate Manager based SSL Certificate in file the terraform.tfvars.
4. Provide Group Email ID in the file newrelic-monitoring-logging.tf to create the destination and channel in NewRelic Alerts.
```

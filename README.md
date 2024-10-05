

# AWS Web Farm Setup

This project demonstrates the use of AWS technologies and deployment automation with Terraform. The core setup consists of an EC2 Auto Scaling group and a database, all connected through load balancers for high availability (HA). Depending on the configuration, the template will either deploy with or without HA, adjusting the number of availability zones, Auto Scaling Group (ASG) size, and database redundancy accordingly. In both cases, load balancers will manage traffic distribution.

System logs will be sent to CloudWatch, and performance metrics will be collected using installed monitoring agents. Web content distribution will be handled by CloudFront.

The environment is configured via installation scripts during deployment, with Ansible playbooks executed as needed. Shared storage is provided by EFS, allowing recovery in case of failure if HA is not selected, or providing shared storage for clustered instances when HA is enabled.

### Secondary Objectives

- Configure web services/software automatically through installation scripts to minimize manual intervention.
- Enable the use of a caching database (Redis) if selected.
- Automate deployments via GitHub Actions.

### Management & Branching Strategy

Each major step of the project will have its own GitHub branch, with the final version merged into the `main` branch. Deployments will automatically reflect the branch name, for example: `app-<branch>.domain.com`. This allows multiple developers to work on their own branches and deploy independently for testing.

GitHub Repository: [AWS-Web-Farm-Setup](https://github.com/twimprine/AWS-Web-Farm-Setup)

- Terraform Infrastructure - `Terraform` branch
- Logging - `Logging` branch
- Final Project - `main` branch

## Variables
Variables are defined in the ```variables.tf``` file however the default settings are set in the ```terraform.tfvars.json``` file. This is done for the deploy scripts in GitHub. It ensures they can be read and deployed properly, setting the environment variables for each branch 

## Tags
Since this is AWS and a lot is managed via Tags they are defined in the ```terraform.tfvars.json``` file. Additionally each module defines its own tags specifically. 

## Terraform
Terraform state will be stored in DynamoDB and S3 (with versioning). The objective is that this system will be able to be used by a team so it's being configured by default. This will create a state environment for each branch and manage it accordingly

### Local Deploy
You need to run ```terrform init``` however the variables need to be set from the files first. 
```bash
sudo apt install jq     # Adjust for your package manager
pip install --upgrade awscli
./generate_backend_config.sh
```
This will create a backend.conf file for terraform to read and use while initializing. It uses the ```awscli``` to create the S3 Bucket and DynamoDB for the state information. 

If you don't want to use remote state (I would highly recommend it if you use multiple machines) just remove or rename the ```backend.tf``` file. 

## Ansible
## Objective
Automated creation of Cognito User Pools which authorize the use of services. Each pool uses and external Idntity provider (IdP) for authentication. Each IdP can either be SAML or OICD compliant.
The following diagram shows the entire flow between application service with Cognito Authoirization server and third party IdP.
![alt text](cognito-auth-flow.jpg)

## Prerequisites
| Requirement | Description |
| ----------- | ----------- |
| Terraform | [Installation Instructions](https://learn.hashicorp.com/tutorials/terraform/install-cli) |
| AWS Account and CLI Credentials | [Create Account](https://ubuntu.com/advantage) |

## Installation

1. Create a state.tf file with AWS provider & AWS profile with admin access. 
Also recommended to store Terraform state and lock file in S3 bucket and DynamoDB table.
2. Deploy using Terraform and AWS provider
```
cd setup
terraform plan -out infra-plan.json
terraform apply 
```

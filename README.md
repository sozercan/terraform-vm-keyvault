# terraform-vm-keyvault
🐧  Microsoft Azure Linux VM created with Terraform that uses Azure Key Vault

## Getting Started

* Create an [Azure Service Principal](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authenticate-service-principal-cli)

* Add credentials as environment variables

```
export ARM_SUBSCRIPTION_ID=""
export ARM_CLIENT_ID=""
export ARM_CLIENT_SECRET=""
export ARM_TENANT_ID=""
```

* Create an Azure Key Vault service

* Add previously created service principal in Access Policies

* Make sure `Enable access to Azure Virtual Machines for deployment` is checked in Advanced Access Policies

* Go to Properties of the service and add Resource ID into `terraform_keyvault_source_vault_id` in `terraform.tf`

* Create PFX file you want to provision the VM with

* Edit `cert.json` file to include base64 encoded pfx and password

* Base64 encode `cert.json`

* In the previously created Key Vault service, create a Secret and then Add the base64 encoded `cert.json` string from the previous step as a manual upload option

* Go to properties of the created secret and add Secret Identifier into `terraform_keyvault_certificate_url` in `terraform.tf`

* Plan with `terraform plan` and then deploy with `terraform apply`

* Provisioned certificate can be found in `/var/lib/waagent` with the file name `<UppercaseThumbprint>.crt` for the X509 certificate file and `<UppercaseThumbprint>.prv` for private key

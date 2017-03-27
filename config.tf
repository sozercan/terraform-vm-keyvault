variable "terraform_azure_region" {
  type        = "string"
  description = "Azure region for deployment"
  default     = "East US"
}

variable "terraform_keyvault_certificate_url" {
  type        = "string"
  description = "URL where secrets are stored. It should be in the format https://<vaultEndpoint>/secrets/<secretName>/<secretVersion>."
}

variable "terraform_keyvault_source_vault_id" {
  type        = "string"
  description = "Keyvault ID. It should be in format /subscriptions/<subscriptionId>/resourceGroups/<resourceGroupName>/providers/Microsoft.KeyVault/vaults/<keyvaultName>"
}

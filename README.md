# Overview of Containers in Azure

## References & Tutorials

1. [Tutorial: Build and run a custom image in Azure App Service - Azure App Service | Microsoft Docs](https://docs.microsoft.com/en-us/azure/app-service/tutorial-custom-container?pivots=container-linux)
2. [Azure security baseline for Azure Kubernetes Service | Microsoft Docs](https://docs.microsoft.com/en-us/security/benchmark/azure/baselines/aks-security-baseline)
3. [AKS and AKV for Secrets](https://docs.microsoft.com/en-us/azure/aks/csi-secrets-store-driver)

## Components Required

1. AZ CLI
2. Docker Desktop
3. kubectl
4. git

## Steps

1. Create a `.env` file in the root directory with the following values:

```
# general deployment info
TENANT_ID=
SUBSCRIPTION_ID=
RG_NAME=
LOCATION=

# azure container registry name
ACR_NAME=

# app services container details
ASP_NAME=
APP_NAME=

# azure container instances details
SERVICE_PRINCIPAL_NAME=

# azure kubernetes service details
AKS_NAME=
KEYVAULT_NAME=
```

2. Set these values in your environment with the following commands:

```
set -a
source .env
set +a
```

3. Start with the `app-services-container` directory and work through the `deploy.sh` script.

>Info: recommended approach is to go line by line in the script along with the comments for better understanding

4. After completing the app services deployment, work through the `aci-container` script.

5. After completing the aci deployment, work through the `kubernetes-secret` script (specifically `deploy.sh` first)

6. For the secrets integration with Azure Key Vault, work through the `deploy-secrets.sh` 
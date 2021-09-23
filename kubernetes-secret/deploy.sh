# Register the AKS-AzureKeyVaultSecretsProvider feature flag on your subscription to use the add-on
az feature register --namespace "Microsoft.ContainerService" --name "AKS-AzureKeyVaultSecretsProvider"

# The command above takes a few minutes - you can check status with the following
# You should see 'Registered' once it's complete
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/AKS-AzureKeyVaultSecretsProvider')].{Name:name,State:properties.state}"

# Refresh the registration of the ContainerService resource provider
az provider register --namespace Microsoft.ContainerService

# Install the aks-preview CLI extension
az extension add --name aks-preview

# Update the extension to make sure you have the latest version installed
az extension update --name aks-preview

# Create an AKS Cluster to support container deployment and secrets add-on
az aks create -n $AKS_NAME -g $RG_NAME --enable-addons azure-keyvault-secrets-provider --enable-managed-identity

# attach aks and acr
# you can also attach acr to aks at deployment time
az aks update -n $AKS_NAME -g $RG_NAME --attach-acr $(az acr show --name $ACR_NAME -g $APP_SERVICES_RG_NAME --query id --output tsv)

# run the following to obtain credentials
az aks get-credentials -g $RG_NAME -n $AKS_NAME

# deploy the deployment and service to a demo namespace
# the service will provision a public IP on a standard Azure Load Balancer
kubectl create ns demo-site
envsubst < deployment-template.yaml > deployment.yaml
kubectl apply -f deployment.yaml -n demo-site
kubectl apply -f service.yaml -n demo-site
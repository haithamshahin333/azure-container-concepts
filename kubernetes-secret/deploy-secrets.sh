###
### As a pre-req, create the cluster using the commands in kubernetes-secret/deploy.sh
###

# Create an instance of key vault with a sample secret to use with the Secrets Store CSI Driver
az keyvault create -n $KEYVAULT_NAME -g $RG_NAME -l $LOCATION
az keyvault secret set --vault-name $KEYVAULT_NAME -n ExampleSecret --value MyAKSExampleSecret

# Use the azurekeyvaultsecretsprovider user-assigned identity to authentice with key vault
# give the identity permissions to get secrets
export SECRETS_IDENTITY=az aks show -n aksdemocluster -g demo-aks-secrets-cluster --query addonProfiles.azureKeyvaultSecretsProvider.identity.clientId -o json
az keyvault set-policy -n $KEYVAULT_NAME -g $RG_NAME --secret-permissions get --spn $SECRETS_IDENTITY

# Create an apply a SecretProviderClass object
envsubst < secrets-provider-template.yaml > secrets-provider.yaml
kubectl create ns secrets-demo
kubectl apply -f secrets-provider.yaml -n secrets-demo

# Apply a test pod to view the secrets data
kubectl apply -f pod.yaml -n secrets-demo

# View the secret (key store in filename, value is data within the file)
kubectl exec busybox-secrets-store-inline -n test-secrets -- ls /mnt/secrets-store
kubectl exec busybox-secrets-store-inline -n test-secrets -- cat /mnt/secrets-store/ExampleSecret
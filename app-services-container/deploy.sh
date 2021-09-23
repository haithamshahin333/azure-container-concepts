# Clone the following repo to the root directoy and build the container image locally
git clone https://github.com/Azure-Samples/docker-django-webapp-linux.git
cd docker-django-webapp-linux
docker build . -t appsvc-tutorial-custom-image

# Create Resource Group
az group create -n $RG_NAME -l $LOCATION

# Create Azure Container Registry
az acr create --name $ACR_NAME --resource-group $RG_NAME --sku Basic

# Login to the registry and push custom container image
az acr login --name $ACR_NAME
docker tag appsvc-tutorial-custom-image $ACR_NAME.azurecr.io/appsvc-tutorial-custom-image:latest
docker push $ACR_NAME.azurecr.io/appsvc-tutorial-custom-image:latest
az acr repository list -n $ACR_NAME

# Create app service plan and app service
# App won't work at this point - just creating to be able to configure
az appservice plan create --name $ASP_NAME --resource-group $RG_NAME --is-linux
az webapp create --resource-group $RG_NAME --plan $ASP_NAME --name $APP_NAME --deployment-container-image-name $ACR_NAME.azurecr.io/appsvc-tutorial-custom-image:latest
az webapp config appsettings set --resource-group $RG_NAME --name $APP_NAME --settings WEBSITES_PORT=8000
az webapp log config --name $APP_NAME --resource-group $RG_NAME --docker-container-logging filesystem

# Create a managed identity to authenticate to ACR
az webapp identity assign --resource-group $RG_NAME --name $APP_NAME --query principalId --output tsv
az role assignment create --assignee $(az webapp identity assign --resource-group $RG_NAME --name $APP_NAME --query principalId --output tsv) --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_NAME/providers/Microsoft.ContainerRegistry/registries/$ACR_NAME --role "AcrPull"

# Update config for container and set property to use managed identity for ACR
az webapp config container set --name $APP_NAME --resource-group $RG_NAME --docker-custom-image-name $ACR_NAME.azurecr.io/appsvc-tutorial-custom-image:latest --docker-registry-server-url https://$ACR_NAME.azurecr.io
az resource update --ids /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_NAME/providers/Microsoft.Web/sites/$APP_NAME/config/web --set properties.acrUseManagedIdentityCreds=True

# View logs
az webapp log tail --name $APP_NAME --resource-group $RG_NAME
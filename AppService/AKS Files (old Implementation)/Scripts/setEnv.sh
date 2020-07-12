# Check Resource Provider registration
namespace='Microsoft.ContainerService'
if [ "$(az provider show --namespace ${namespace} | jq -r .registrationState)" != 'Registered' ]
then
      az provider register --namespace ${namespace} --verbose
else
      echo "Namespace \"${namespace}\" is already registered."
fi



# Create Resource Group
resourceGroupName='techaks-rg'
resourceGroupLocation='southcentralus'
resourceGroup=$(az group create --name ${resourceGroupName} --location "${resourceGroupLocation}" --verbose)

# Deploy Log Analytics Workspace
templateFile="./Refactor/logAnalytics.json"

timestamp=$(date -u +%FT%TZ | tr -dc '[:alnum:]\n\r')
name="$(echo $resourceGroup | jq .name -r)-${timestamp}"
deployment=$(az group deployment create --resource-group $(echo $resourceGroup | jq .name -r) --name ${name} --template-file ${templateFile} --verbose)

### Deploy AKS environment
clusterName='aksAppCluster'

# Create Service Principal
spName=sp-aks-${clusterName}
keyvaultName='aks-azTech-kv' 
sp=$(az ad sp create-for-rbac --name ${spName}) 
#create keyvault
az keyvault create \
  --name $(echo $keyvaultName) \
  --resource-group  $(echo $resourceGroup | jq .name -r) \
  --location "southcentralus" \
  --enabled-for-template-deployment true

az keyvault set-policy -n  $(echo $keyvaultName) --spn $(echo $sp | jq .appId -r) --secret-permissions get list set --key-permissions create decrypt delete encrypt get list unwrapKey wrapKey
az keyvault secret set --vault-name $(echo $keyvaultName) --name "spPWD" --value  $(echo $sp | jq .password -r) 

#deploy Vnet with 2 subnets
vnetTemplate="./Templates/vnets.json"
vnetName='vnet'
vnetDeployment=$(az group deployment create --resource-group $(echo $resourceGroup | jq .name -r) --name  $(echo $vnetName) --template-file ${vnetTemplate} --verbose)


# Deploy AKS Cluster

logAnalyticsId=$(echo $deployment | jq .properties.outputs.workspaceResourceId.value -r)


az group deployment create \
    -g $(echo $resourceGroup | jq .name -r)  \
    --template-file "Templates/aksApp.json" \
    --parameters "Parameters/aksApp.parameters.json" \
    --parameters existingServicePrincipalClientId=$(echo $sp | jq .appId -r) \
    --parameters existingServicePrincipalClientSecret=$(echo $sp | jq .password -r) 


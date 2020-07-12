clusterName='aksAppCluster'
#clusterName='MC_techaks-rg_aksAppCluster_southcentralus'
ACR_NAME="techaksfgc"
resourceGroupName='techaks-rg'
resourceGroupLocation='southcentralus'
az acr create \
    --resource-group $resourceGroupName \
    --location $resourceGroupLocation \
    --name $ACR_NAME \
    --sku Standard

#testApps

#
git clone https://github.com/MicrosoftDocs/mslearn-aks-workshop-ratings-api.git

cd mslearn-aks-workshop-ratings-api

az acr build \
    --resource-group $resourceGroupName \
    --registry $ACR_NAME \
    --image ratings-api:v1 .


cd ..

git clone https://github.com/MicrosoftDocs/mslearn-aks-workshop-ratings-web.git

cd mslearn-aks-workshop-ratings-web

az acr build \
    --resource-group $resourceGroupName \
    --registry $ACR_NAME \
    --image ratings-web:v1 .

 cd ..

git clone https://github.com/giuliano64/AzAssesmentfgc.git
cd AzAssesmentfgc
az acr build \
    --resource-group $resourceGroupName \
    --registry $ACR_NAME \
    --image aspnetcore-fgc:latest .

 cd ..
#Update the AKS cluster to authenticate to the containers registry

az aks update \
    --name $clusterName \
    --resource-group $resourceGroupName \
    --attach-acr $ACR_NAME
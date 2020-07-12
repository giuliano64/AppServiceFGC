# **Technical Assessment FGC**


### Technical Assessment requirements
The focus will be on why you have chosen a certain way to approach this assignment
We could understand that you might need to make some assumptions during this assessment, please write down the assumptions you make as well
Please include a simple time log as well of the activities performed by you
Do not be afraid to use your own creativity and show us more than we have requested if you think some things could be handy as well

Key aspect we would like to see are:

1. Reusability
2. Flexibility
3. Robustness

  ### The assignment:

Sign up for a free Azure account at [GetAzureSubscription](https://azure.microsoft.com/nl-nl/free/)

### Using ARM templates and best practices, create the following:

1. An Azure Datalake Gen 2 storage account.
2. A key vault with a secret
3. A virtual network
4. A web app that can access both the datalake storage and the key vault secret
5. A load balancer that sits between the web app and the internet
6. Use tags to group the resources.

  

Take note of your assumptions, and explain the choices you made

  
### Deliverable:

Provide us with a public GitHub repository containing the assignment.

# Solution

This file explains in detail the process the average of time dedicated to each task in order to implement the whole requested system, the approaches and the decisions taken in the middle of the process. To see the code go the this [Repository]([https://github.com/giuliano64/azAssesmentAppServiceFGC])

The solution consists in an application ([https://fgcwebapp.azurewebsites.net/](https://fgcwebapp.azurewebsites.net/)) that let users to upload images to a cloud hosted environment and then the possibility of download those images (which were uploaded to a DataLake Gen 2 storage). This Web App is hosted in an app service plan that is autoscaled based on some **autoscaling rules** that has been set up at the deployment. Additionally the web app also connects to an Azure keyvault in which the DataLake Connection String and Key are stored, so when the application starts it goes and get those values from the keyvault in order to access and manage the blob storage containers. The web Application is developed with ASP .NET Core using C# in the Backend,cshtml and CSS (MVC Project), which respects pretty much the good practices in therms of **Reusability**, as I tried to respect design patterns, and avoided to accoplate functionalities. Then the system itself from a **Robustness** and **Flexibility** standpoint meets the requirements as depending on the amount of requests it will decrease or increase the capacity (add/reduce the amount of instances for the application, or it will increse/decrease the machine size) based on autoscaling rules. Also, as we have more than on instances of the application, even though one instance is failing, it's not high probable that all instances will be down increasing the avilability of the system. Last but not least, this is complemented with a good **Applications Monitoring**, using **Log Analytics, and Application Insights**.

## Clarification of the Approach taken and challenges over the Road
During the first days of the assessment I have decided to take the approach of implementing a Azure Kubernetes Services (AKS) cluster  due to the fact that is a highly scalable and maintainable solution, which also matches with what it’s really used nowadays in the market, as many companies are adopting kubernetes with containers as the main approach to implement cloud based applications whenever is possible (without mentioning the fact I have always wanted to learn more about containers, so I have taken the chance). Having said that, after many days I have realized that the learning curve of implementing properly that cluster hosting a container of a web app and make it work could take more time that the one I had available (I have made it to implement the AKS cluster with ARM templates but never ran the container on it). So, in the last 3 days I decided to go for an App Service Plan in which the web app was successfully hosted, with autoscaling rules (all via ARM templates and scripts).
Note: I am not considering in the effort of this assessment the time invested in AKS (which took me some days, and the commits for it can be find in this [repository]([https://github.com/giuliano64/AzAssesmentfgc](https://github.com/giuliano64/AzAssesmentfgc)) that **is not the one I used for the app service as decided to create another repository from scratch.** 

## Assumptions

1. There is not need for a Private connection. The web app is accessible for everyone over the internet
2. There is NO Sensitive Data in the Storage Account that should deserve to store all the components in different VNets and do VNet Peering when required
3. The solution may need at the moment just one region to be deployed. In the future, if more regions are required, it could be implemented in different regions and complemented with resources such as the traffic manager

## Resource group and Key vault creation (avg time of completion: Less than 2 hours)

This part have taken less than 2 hours as it’s something that could be done really quick with Azure CLI or Powershell with the Az Module:

**Resource Group Creation**:
  

```console
appsrv='appsrv'
spName=sp-appService
sp=$(az ad sp create-for-rbac --name ${spName})

```

**Keyvault creation:**

  

```console
keyVaultName=${appsrv}-kv

az keyvault create \
--name $(echo $keyVaultName) \
--resource-group $(echo $resourceGroup | jq .name -r) \
--location "southcentralus" \
--enabled-for-template-deployment true

az keyvault set-policy -n $(echo $keyVaultName) --spn $(echo $sp | jq .appId -r) --secret-permissions get list set --key-permissions create decrypt delete encrypt get list unwrapKey wrapKey
```
 

In the KeyVault creation also you have some lines to add access policies to add access to managed Identities when required.

  

## Log Analytics Workspace (avg time of completion: 3 hours)

Log Analytics workspace is a really useful feature to gather logs from many cloud based solutions, in order to make a better monitoring of your solutions and **improving the site reliability**.

  

```console
templateFile="./Templates/logAnalytics.json"
timestamp=$(date -u +%FT%TZ | tr -dc '[:alnum:]\n\r')
name="$(echo $resourceGroup | jq .name -r)-${timestamp}"
deployment=$(az group deployment create --resource-group $(echo $resourceGroup | jq .name -r) --name ${name} --template-file ${templateFile} --verbose)
```
 

## Vnet with 2 subnets (avg time of completion:Less than 2 hours)

```console
vnetTemplate="./Templates/appServiceVnet.json"
vnetName='appVnet'
vnetDeployment=$(az group deployment create --resource-group $(echo $resourceGroup | jq .name -r) --name $(echo $vnetName) --template-file ${vnetTemplate} --verbose)
```
  

## App Service with and WebApp for Media management in the Cloud (avg time of completion:Less than 18 hours)
```console
az group deployment create \
-g $(echo $resourceGroup | jq .name -r) \
--template-file "Templates/azuredeploy.json" \

```

  

## DataLake Gen 2 implementation (avg time of completion:2 hours)

  
```console
az group deployment create \
-g $(echo $resourceGroup | jq .name -r) \
--template-file "Templates/dataLake.json" \
```

## Things that would be nice to have which I did not have time to implement and/or test enough

1. Integrate resources with **VNets**. Following [Microsoft Documentation]([https://docs.microsoft.com/en-us/azure/app-service/web-sites-integrate-with-vnet](https://docs.microsoft.com/en-us/azure/app-service/web-sites-integrate-with-vnet)) and it would be really nice to find a way to have add that configuration tasks as part of the arm templates deployment.
2.  Implement **CI/CD** Pipeline to deploy the whole environment instead of the Azure CLI script. These comprehends to add a Service Connection, connect Azure Devops with GitHub Repository, Create the Tasks group, for each resource (one Task group for CI and another one for CD) and Both CI-CD pipelines.
3.  Implement a Tenant Registered account authentication, if for some section more permissions are needed
4. Deploy Solution in Different Regions, and implement a **Traffic Manager**.
5.  Implement an **express route** connection between some Machines to Connect securely
6. Add alerting rules to detect faster any failure in the App Service/Application instances (By creating queries that will be used in the azure monitor alerts, with its respecting action groups, to define how we will alert that the application has an issue, for instance, via email)

#Install Helm
helm repo add bitnami https://charts.bitnami.com/bitnami

helm search repo bitnami

spName='sp-aks-aksAppCluster'
secretName='spPWD'
vaultName='aks-azTech-kv'

secret=$(az keyvault secret show --vault-name $vaultName --name $secretName)

helm install ratings bitnami/mongodb \ 
    --namespace ratingsapp \ 
    --set auth.username=spName,auth.password=$secret, auth.database=ratingsdb

kubectl create secret generic mongosecret \
    --namespace ratingsapp \
    --from-literal=MONGOCONNECTION="mongodb://$spName:$secret@ratings-mongodb.ratingsapp:27017/ratingsdb"

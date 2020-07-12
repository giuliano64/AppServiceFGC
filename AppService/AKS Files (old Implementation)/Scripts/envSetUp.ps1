Param(
)

try
{
 
	git clone "https://github.com/giuliano64/AzAssesmentfgc.git"
	cd AzAssesmentfgc/Aks-App
	#get configuration from configuration,json file
	$cfgJson = Get-Content "Parameters/configuration.json" -raw | ConvertFrom-json

	#Create Resource group
	New-AzResourceGroup -Name $cfgJson.resourceGroup -location $cfgJson.location -Force
	write-host "Pause after RG creation to avoid timming issues"
	

	#create Service Principal
	$sp= Get-AzADServicePrincipal -DisplayName $cfgJson.spName
	
	if($sp.Length -eq 0)
	{
		$sp = New-AzADServicePrincipal -DisplayName $cfgJson.spName -
		write-host "$($sp.ApplicationId)"
		write-host "$($sp.Secret)"
		write-host "$($sp.object)"
	}
	else
	{
		write-host "SP already created"
	}

	#keyvault Deployment
	write-host "create keyvault"
	$kvJson = Get-Content "Parameters/keyvault.parameters.json" -raw | ConvertFrom-json
	$kv= Get-AzKeyvault -VaultName $kvJson.Parameters.keyVaultName
	
	if($kv.Length -eq 0)
	{

		New-AzResourceGroupDeployment   -ResourceGroupName $cfgJson.resourceGroup   -TemplateFile "Templates/keyvault.json"   -TemplateParameterFile ".\Parameters\keyvault.parameters.json" -Force
	}
	else
	{
		write-host "SP already created"
	}

	#$templateJson = Get-Content "Templates/vnets.parameters.json" -raw | ConvertFrom-json
	write-host "deploy Vnets"
	New-AzResourceGroupDeployment   -ResourceGroupName $cfgJson.resourceGroup   -TemplateFile "Templates/vnets.json" -Force
	
	
	#AKS Setup
	.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation $cfgJson.location

	#go back tp default location
	cd
	write-host "deployment went successful"
}
catch
{
	cd
	write-error $_.Exception.Message	
}


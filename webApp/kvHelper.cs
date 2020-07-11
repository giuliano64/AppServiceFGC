using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Routing;
using Microsoft.Azure.KeyVault;
using Microsoft.Azure.Services.AppAuthentication;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace webApp
{
    public class KvHelper
    {
  //      [FunctionName("KvHelper")]
        
        public KvHelper()
        {
            
        }
    
        //public static async Task<IActionResult> Run(string sec,
        //  [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
        //  ILogger log)
        //{
        //    log.LogInformation("C# HTTP trigger function processed a request.");

        //    AzureServiceTokenProvider azureServiceTokenProvider = new AzureServiceTokenProvider();

        //    var keyVaultClient = new KeyVaultClient(
        //        new KeyVaultClient.AuthenticationCallback(
        //            azureServiceTokenProvider.KeyVaultTokenCallback));

        //    var secret =
        //        await
        //        keyVaultClient.GetSecretAsync(
        //            "https://appsrv-kv.vault.azure.net/secrets/"+sec).ConfigureAwait(false);

        //    return new OkObjectResult(secret.Value);
        //}
        //public static async Task<IActionResult> getsec(string sec)
        //{            

        //    AzureServiceTokenProvider azureServiceTokenProvider = new AzureServiceTokenProvider();

        //    var keyVaultClient = new KeyVaultClient(
        //        new KeyVaultClient.AuthenticationCallback(
        //            azureServiceTokenProvider.KeyVaultTokenCallback));

        //    var secret =
        //        await
        //        keyVaultClient.GetSecretAsync(
        //            "https://appsrv-kv.vault.azure.net/secrets/"+sec).ConfigureAwait(false);

        //    return new OkObjectResult(secret.Value);
        //}
    }
}

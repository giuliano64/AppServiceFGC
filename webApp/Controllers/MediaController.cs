using Azure.Core;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Azure.Storage.Sas;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using webApp.Models;

namespace webApp.Controllers
{
    public class MediaController : Controller
    {
        private IConfiguration config;

        public MediaController(IConfiguration appConfig)
        {
            config = appConfig;
            SecretClientOptions options = new SecretClientOptions()
            {
                Retry =
                    {
                        Delay= TimeSpan.FromSeconds(2),
                        MaxDelay = TimeSpan.FromSeconds(16),
                        MaxRetries = 5,
                        Mode = RetryMode.Exponential
                    }
            };
            var credential = new ClientSecretCredential(config.GetSection("tenantId").Value, config.GetSection("clientId").Value, config.GetSection("clientSecret").Value);
            var client = new SecretClient(new Uri("https://appsrv-kv.vault.azure.net/"), credential, options);

            KeyVaultSecret blobConKv = client.GetSecret("BlobCon");
            KeyVaultSecret blobKeyKv = client.GetSecret("BlobKey");


            string blobConKvValue = blobConKv.Value;
            string blobKeyKvValue = blobKeyKv.Value;
            config.GetSection("BlobCon").Value = blobConKvValue;
            config.GetSection("Blobkey").Value = blobKeyKvValue;
        }

        public async Task<IActionResult> Index()
        {
            List<ImageModel> images = new List<ImageModel>();



            //get a list of images in the container and add to the list
            var containerClient = new BlobContainerClient(config.GetSection("BlobCon").Value, "pictures");

            var blobs = containerClient.GetBlobsAsync(BlobTraits.Metadata);
            await foreach (var item in blobs)
            {
                images.Add(new ImageModel
                {
                    Name = item.Name,
                    //Name = item.Metadata["Name"],
                    ImageFileName = item.Name
                });
            }

            return View(images);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        //[Authorize]
        public async Task<IActionResult> Index(ImageUploadModel model)
        {
            try
            {
                //upload image after authorizing user
                
                var containerClient = new BlobContainerClient(config.GetSection("BlobCon").Value, "pictures");
                if (model.ImageFile != null)
                {
                    var blobClient = containerClient.GetBlobClient(
                        model.ImageFile.FileName); // USE a temporary file name

                    var result = await blobClient.UploadAsync(model.ImageFile.OpenReadStream(),
                        new BlobHttpHeaders
                        {
                            ContentType = model.ImageFile.ContentType,
                            CacheControl = "public"
                        },
                        new Dictionary<string, string> { { "pictures",
                    model.Name} }
                        );

                }
                return RedirectToAction("Index");
            }
            catch(Exception ex)
            {
                return RedirectToAction("Index");
            }

        }



        [HttpGet]
        //[Authorize] // when using auth to make sure they should get the link
        public IActionResult Detail(string imageFileName)
        {
            ImageModel model = new ImageModel();
            //validate user is authenticated before showing the image!!

            //get image from storage and set URL and metadata name on model
            var containerClient = new BlobContainerClient(
               config.GetSection("BlobCon").Value, "pictures");

            var blob = containerClient.GetBlobClient(imageFileName);

            BlobSasBuilder builder = new BlobSasBuilder
            {
                BlobContainerName = containerClient.Name,
                BlobName = blob.Name,
                ExpiresOn = DateTime.UtcNow.AddMinutes(2),
                Protocol = SasProtocol.Https
            };
            builder.SetPermissions(BlobSasPermissions.Read);

            UriBuilder uBuilder = new UriBuilder(blob.Uri);
            var blobKey = config.GetSection("BlobKey").Value;
            byte[] bytes = System.Text.Encoding.ASCII.GetBytes(blobKey);
            var encodedKey = Convert.ToBase64String(bytes);

            uBuilder.Query = builder.ToSasQueryParameters(
                new Azure.Storage.StorageSharedKeyCredential(
                    containerClient.AccountName,
                    encodedKey
                )).ToString();

            //model.Url = uBuilder.Uri.ToString();
            model.Url = "https://" + containerClient.AccountName + ".blob.core.windows.net/"+ blob.BlobContainerName + "/" + imageFileName + "?" + blobKey;
            model.ImageFileName = imageFileName;

            return View(model);
        }
    }
}

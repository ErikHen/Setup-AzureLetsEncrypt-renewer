
$webappname = "letsencryptrenewer101" # Application name (lowercase alphanumeric only)
$subscriptionname = "Windows Azure MSDN - Visual Studio Premium"
$resourcegroupname ="$($webappname)-resourcegroup"
$location="West Europe"
$appsettingsfilename="C:\Projects\LetsEncrypt\AppSettings.xml"

Login-AzureRmAccount

### Creating the web app that will host the Let's Encrypt renewer ###

# At first I had problems running Test-AzureName. I got an error saying that no default subscription was set. When trying to set the default subscription I got another error.
# I was able to resolve that issue with this SO answer: https://stackoverflow.com/a/37909021/1249390
# ...or you can just make sure your app name is unique, and comment out this part.
if (Test-AzureName -Website -Name $webappname )
{
    write-host "A web app with that name already exists. Change name and retry."
    Return
}

# Change subscription (not needed if you only have access to one subscription)
Get-AzureRmSubscription –SubscriptionName $subscriptionname | Select-AzureRmSubscription -Default

# Create resource group if it doesn't exist.
$resourcegroup = Get-AzureRmResourceGroup -Name $resourcegroupname -ErrorAction SilentlyContinue
if ($resourcegroup -eq $null)
{
	New-AzureRmResourceGroup -Name $resourcegroupname -Location $location
}

# Create App Service Plan ("Free" tier).
New-AzureRmAppServicePlan -Name "$($webappname)-serviceplan" -Location $location -ResourceGroupName $resourcegroupname -Tier Free
# Create web app.
New-AzureRmWebApp -Name $webappname -Location $location -AppServicePlan "$($webappname)-serviceplan" -ResourceGroupName $resourcegroupname
Set-AzureRmWebApp -ResourceGroupName $resourcegroupname -Name $webappname -PhpVersion "Off" #Php is not needed, so turn it off



### Set Let's Encrypt settings to the web app ###

# Get existing values
$webapp = Get-AzureRmwebApp -ResourceGroupName $resourcegroupname -Name $webappname
$webappsettings = $webapp.SiteConfig.AppSettings
$appsettingshash = @{}
#Write-Host "The following application settings are already available in the Azure webapp '$webappname':"
#$webappsettings | ft

# copy existing app settings to hash
foreach ($setting in $webappsettings) {
    $appsettingshash[$setting.Name] = $setting.Value
}

# $webappconnectionstrings = $webapp.SiteConfig.ConnectionStrings
# $connectionstringshash = @{}
# # copy existing connectionstrings to hash
# foreach ($connectionstring in $webappconnectionstrings) {
#     $connectionstringshash[$connectionstring.Name] = $connectionstring.Value
# }
Write-Host "Loading appsettings file:" $appsettingsfilename;
$appsettingsfromfile = [xml](Get-Content $appsettingsfilename)
if ($appsettingsfromfile -eq $null) {
    Write-Host "Error loading appsettings file." -ForegroundColor Red
    Exit
}

# Merge settings from xml file to appsettings and connectionstrings
foreach($appsetting in $appsettingsfromfile.LetsEncrypt.AppSettings.Appsetting){
    $appsettingshash[$appsetting.Name] = $appsetting.Value;
}
# foreach($connectionstring in $appsettingsfromfile.LetsEncrypt.ConnectionStrings.ConnectionString){
#     #$connectionstringshash[$connectionstring.Name] = $connectionstring.Value;
#     $setting = @{Type=$keyValuePair.Type.ToString();Value=$keyValuePair.ConnectionString.ToString()}

#     $connectionstringshash.Add(
#     $hashItems.Add($keyValuePair.Name,$setting);
# }


# Save appsettings
Set-AzureRmwebApp -ResourceGroupName $resourcegroupname -Name $webappname -AppSettings $appsettingshash # -ConnectionStrings $connectionstringshash

# Download latest version of web job
# Download publish profile so that we can upload the web job, there is no powershell command for that, so use kudu api
$publishprofile = Invoke-AzureRmResourceAction -ResourceGroupName $resourcegroupname -ResourceType Microsoft.Web/sites/config -ResourceName $webappname/publishingcredentials -Action list -ApiVersion 2015-08-01 -Force
$publishusername = $res.Properties.PublishingUserName
$publishpassword = $res.Properties.PublishingPassword
https://$letsencryptrenewer101:Suaucwgfo6tuatu4hYbsu7wPtPxHgdHAYhSa2BCnr9EvBGjwaheWctPNnqwe@letsencryptrenewer101.scm.azurewebsites.net/api/triggeredwebjobs/ohadsoftletsencryptrenewer/run
https://letsencryptrenewer101.scm.azurewebsites.net/api/triggeredwebjobs/ohadsoftletsencryptrenewer/run
# Upload web job zip

# Output values
Write-Host "====================================================================`n"
Write-Host "Site url: $($webappname).azurewebsites.net"

Write-Host "`n===================================================================="
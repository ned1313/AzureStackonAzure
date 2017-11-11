# Specify Azure Active Directory tenant name.
$TenantName = "anexinetasp.onmicrosoft.com"

# Set the module repository and the execution policy.
Set-PSRepository `
  -Name "PSGallery" `
  -InstallationPolicy Trusted

Set-ExecutionPolicy RemoteSigned `
  -force

# Uninstall any existing Azure PowerShell modules. To uninstall, close all the active PowerShell sessions, and then run the following command:
Get-Module -ListAvailable | `
  where-Object {$_.Name -like "Azure*" } | `
  Uninstall-Module

# Install PowerShell for Azure Stack.
Install-Module `
  -Name AzureRm.BootStrapper `
  -Force

Use-AzureRmProfile `
  -Profile 2017-03-09-profile `
  -Force

Install-Module `
  -Name AzureStack `
  -RequiredVersion 1.2.11 `
  -Force 

# Download Azure Stack tools from GitHub and import the connect module.
cd \

invoke-webrequest `
  https://github.com/Azure/AzureStack-Tools/archive/master.zip `
  -OutFile master.zip

expand-archive master.zip `
  -DestinationPath . `
  -Force

cd AzureStack-Tools-master

Import-Module .\Connect\AzureStack.Connect.psm1

# For Azure Stack development kit, this value is set to https://adminmanagement.local.azurestack.external. To get this value for Azure Stack integrated systems, contact your service provider.
  $ArmEndpoint = "https://adminmanagement.local.azurestack.external"

# For Azure Stack development kit, this value is adminvault.local.azurestack.external 
$KeyvaultDnsSuffix = "adminvault.local.azurestack.external"


# Register an AzureRM environment that targets your Azure Stack instance
  Add-AzureRMEnvironment `
    -Name "AzureStackAdmin" `
    -ArmEndpoint $ArmEndpoint

# Get the Active Directory tenantId that is used to deploy Azure Stack
  $TenantID = Get-AzsDirectoryTenantId `
    -AADTenantName $TenantName `
    -EnvironmentName "AzureStackAdmin"

# Sign in to your environment
  Login-AzureRmAccount `
    -EnvironmentName "AzureStackAdmin" `
    -TenantId $TenantID


#Create a plan and offer
Import-module C:\AzureStack-Tools-master\ServiceAdmin\AzureStack.ServiceAdmin.psm1
$sub = Get-AzureRmSubscription -SubscriptionName "Default Provider Subscription"

$computeQuota = "/subscriptions/$($sub.id)/providers/Microsoft.Compute.Admin/locations/local/quotas/Default Quota"
$storageQuota = "/subscriptions/$($sub.id)/providers/Microsoft.Storage.Admin/locations/local/quotas/Default Quota"
$keyVaultQuota = "/subscriptions/$($sub.id)/providers/Microsoft.KeyVault.Admin/locations/local/quotas/Unlimited"
$networkQuota = "/subscriptions/$($sub.id)/providers/Microsoft.Network.Admin/locations/local/quotas/Default Quota"

New-AzureRmResourceGroup -Name PlansAndOffers -Location local

$plan = New-AzsPlan -Name "BasePlan" -DisplayName "Base Plan" -ResourceGroupName PlansAndOffers -QuotaIds @($computeQuota,$storageQuota,$keyVaultQuota,$networkQuota) -ArmLocation local

$offer = New-AzsOffer -Name "BaseOffer" -DisplayName "Base Offer" -State Public -BasePlanIds $plan.Id -ResourceGroupName PlansAndOffers -ArmLocation local

#Register Azure Stack with Azure
$YourCloudAdminCredential = Get-Credential -UserName "azurestack\azurestackadmin" -Message "Local Azure Stack Admin"
$YourAzureDirectoryTenantName = "nbellavanceanexinet.onmicrosoft.com"
$YourAzureSubscriptionId = "a6742967-9cbd-450b-926f-098437d94563"
$YourPrivilegedEndpoint = "AzS-ERCS01"

Import-Module C:\AzureStack-Tools-master\Registration\RegisterWithAzure.psm1

Add-AzsRegistration -CloudAdminCredential $YourCloudAdminCredential -AzureDirectoryTenantName $YourAzureDirectoryTenantName  -AzureSubscriptionId $YourAzureSubscriptionId -PrivilegedEndpoint $YourPrivilegedEndpoint -BillingModel Development

#Let's get some marketplace content!
#POST https://adminmanagement.local.azurestack.external/subscriptions/0a1d2f26-feff-43c9-b350-07480a7e2157/resourceGroups/azurestack-activation/providers/Microsoft.AzureBridge.Admin/activations/default/products/Microsoft.SQLIaaSExtension.1.2.18/download?api-version=2016-01-01 
#create the web session

#Get the product list

#Request each marketplace item

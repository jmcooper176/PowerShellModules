# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path 'path\to\Octopus.Client.dll'
$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"

# Azure service principle details
$azureSubscriptionNumber = "Subscription-Guid"
$azureTenantId = "Tenant-Guid"
$azureClientId = "Client-Guid"
$azureSecret = "Secret"

# Octopus Account details
$accountName = "Azure Account"
$accountDescription = "My Azure Account"
$accountTenantParticipation = "Untenanted"
$accountTenantTags = @()
$accountTenantIds = @()
$accountEnvironmentIds = @()
$spaceName = "default"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

try
{
    # Get space
    $space = $repository.Spaces.FindByName($spaceName)
    $repositoryForSpace = $client.ForSpace($space)

    # Create azure service principal object
    $azureAccount = New-Object -TypeName Octopus.Client.Model.Accounts.AzureServicePrincipalAccountResource
    $azureAccount.ClientId = $azureClientId
    $azureAccount.TenantId = $azureTenantId
    $azureAccount.Description = $accountDescription
    $azureAccount.Name = $accountName
    $azureAccount.Password = $azureSecret
    $azureAccount.SubscriptionNumber = $azureSubscriptionNumber
    $azureAccount.TenantedDeploymentParticipation = [Octopus.Client.Model.TenantedDeploymentMode]::$accountTenantParticipation
    $azureAccount.TenantTags = New-Object -TypeName Octopus.Client.Model.ReferenceCollection -ArgumentList $accountTenantTags
    $azureAccount.TenantIds = New-Object -TypeName Octopus.Client.Model.ReferenceCollection -ArgumentList $accountTenantIds
    $azureAccount.EnvironmentIds = New-Object -TypeName Octopus.Client.Model.ReferenceCollection -ArgumentList $accountEnvironmentIds

    # Create account
    $repositoryForSpace.Accounts.Create($azureAccount)
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}

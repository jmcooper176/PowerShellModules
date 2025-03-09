# Note: This script will only work with Octopus 2021.2 and higher.
# It also requires version 11.3.3355 or higher of the Octopus.Client library

# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path 'path\to\Octopus.Client.dll'
$octopusURL = "https://your.octopus.app"
$octopusAPIKey = "API-YOURAPIKEY"
$spaceName = "Default"

# Octopus Account name
$accountName = "My Google Cloud Account"

# Octopus Account Description
$accountDescription = "A Google Cloud account for my project"

# Tenant Participation e.g. Tenanted, or, Untenanted, or TenantedOrUntenanted
$accountTenantParticipation = "Untenanted"

# Google Cloud JSON key file
$jsonKeyPath = "/path/to/jsonkeyfile.json"

# (Optional) Tenant tags e.g.: "AWS Region/California"
$accountTenantTags = @()
# (Optional) Tenant Ids e.g.: "Tenants-101"
$accountTenantIds = @()
# (Optional) Environment Ids e.g.: "Environments-1"
$accountEnvironmentIds = @()

if(-not (Test-Path -LiteralPath $jsonKeyPath -PathType Leaf)) {
    Write-Warning -Message "The Json Key file was not found at '$jsonKeyPath'."
    return
}
else {
    $jsonContent = Get-Content -LiteralPath $jsonKeyPath
    $jsonKeyBase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($jsonContent))
}

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

try
{
    # Get space
    $space = $repository.Spaces.FindByName($spaceName)
    $repositoryForSpace = $client.ForSpace($space)

    # Create Google Cloud Account object
    $googleCloudAccount = New-Object -TypeName Octopus.Client.Model.Accounts.GoogleCloudAccountResource
    $googleCloudAccount.Name = $accountName
    $googleCloudAccount.Description = $accountDescription

    $jsonKeySensitiveValue = New-Object -TypeName Octopus.Client.Model.SensitiveValue
    $jsonKeySensitiveValue.NewValue = $jsonKeyBase64
    $jsonKeySensitiveValue.HasValue = $True
    $googleCloudAccount.JsonKey = $jsonKeySensitiveValue

    $googleCloudAccount.TenantedDeploymentParticipation = [Octopus.Client.Model.TenantedDeploymentMode]::$accountTenantParticipation
    $googleCloudAccount.TenantTags = New-Object -TypeName Octopus.Client.Model.ReferenceCollection -ArgumentList $accountTenantTags
    $googleCloudAccount.TenantIds = New-Object -TypeName Octopus.Client.Model.ReferenceCollection -ArgumentList $accountTenantIds
    $googleCloudAccount.EnvironmentIds = New-Object -TypeName Octopus.Client.Model.ReferenceCollection -ArgumentList $accountEnvironmentIds

    # Create account
    $repositoryForSpace.Accounts.Create($googleCloudAccount)
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}

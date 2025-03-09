# Load octopus.client assembly
Add-Type -Path "C:\octo\Octopus.Client.dll"

# Define working variables
$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"

# Purpose of the API Key. This field is mandatory.
$APIKeyPurpose = ""

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint

try
{
    # Get Current user
    $User = $repository.Users.GetCurrent()

    # Create API Key for user
    $ApiKeyResponse = $repository.Users.CreateApiKey($User, $APIKeyPurpose)

    # Return the API Key
    Write-Output "API Key created: $($ApiKeyResponse.ApiKey)"
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}

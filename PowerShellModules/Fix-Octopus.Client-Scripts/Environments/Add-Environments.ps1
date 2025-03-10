$ErrorActionPreference = "Stop"

# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path 'path\to\Octopus.Client.dll'

$octopusURL = "https://youroctopus.octopus.app"
$octopusAPIKey = "API-YOURAPIKEY"

$spaceName = "Default"
$environments = @("Development", "Test", "Staging", "Production")

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

# Get space
$space = $repository.Spaces.FindByName($spaceName)
$repositoryForSpace = $client.ForSpace($space)

foreach ($environmentName in $environments) {
    $environment = $repositoryForSpace.Environments.FindByName($environmentName)
    if($null -ne $environment) {
        Write-Information -MessageData "Environment '$environmentName' already exists. Nothing to create :)"
    }
    else {
        Write-Information -MessageData "Creating environment '$environmentName'"
        $environment = New-Object -TypeName Octopus.Client.Model.EnvironmentResource -Property @{
            Name = $environmentName
        }

        $response = $repositoryForSpace.Environments.Create($environment)
        Write-Information -MessageData "EnvironmentId: $($response.Id)"
    }
}

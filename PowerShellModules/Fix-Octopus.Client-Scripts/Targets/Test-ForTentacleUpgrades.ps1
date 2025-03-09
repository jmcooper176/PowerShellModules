# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
# Load octopus.client assembly
Add-Type -Path "c:\octopus.client\Octopus.Client.dll"

$octopusURL = "https://your.octopus.app/api"
$octopusAPIKey = "API-YOURAPIKEY"
$spaceName = "Default"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

try {
    # Get space
    $space = $repository.Spaces.FindByName($spaceName)
    $repositoryForSpace = $client.ForSpace($space)

    # Get Tentacles
    $targets = $repositoryForSpace.Machines.GetAll()
    $workers = $repositoryForSpace.Workers.GetAll()

    ($targets + $workers)
    | Where-Object -FilterScript { $_.Endpoint -and $_.Endpoint.TentacleVersionDetails }
    | ForEach-Object -Process {
        Write-Information -MessageData "Checking Tentacle version for $($_.Name)"
        $details = $_.Endpoint.TentacleVersionDetails

        Write-Information -MessageData "`tTentacle status: $($_.HealthStatus)"
        Write-Information -MessageData "`tCurrent version: $($details.Version)"
        Write-Information -MessageData "`tUpgrade suggested: $($details.UpgradeSuggested)"
        Write-Information -MessageData "`tUpgrade required: $($details.UpgradeRequired)"
    }
}
catch {
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
    throw $Error[0]
}

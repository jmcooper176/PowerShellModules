# Load octopus.client assembly
Add-Type -Path "c:\octopus.client\Octopus.Client.dll"

# Octopus variables
$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"
$spaceName = "default"
$hostName = "MyHost"
$tentacleThumbprint = "TentacleThumbprint"
$tentacleIdentifier = "PollingTentacleIdentifier" # Must match value in Tentacle.config file on tentacle machine; ie poll://RandomCharacters
$environmentNames = @("Development", "Production")
$roles = @("MyRole")

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

try
{
    # Get space
    $space = $repository.Spaces.FindByName($spaceName)
    $repositoryForSpace = $client.ForSpace($space)

    # Get environment ids
    $environments = $repositoryForSpace.Environments.FindAll() | Where-Object -FilterScript {$environmentNames -contains $_.Name}

    # Create new polling tentacle resource
    $newTarget = New-Object -TypeName Octopus.Client.Model.Endpoints.PollingTentacleEndpointResource

    $newTarget.Uri = "poll://$tentacleIdentifier"
    $newTarget.Thumbprint = $tentacleThumbprint

    # Create new machien resourece
    $tentacle = New-Object -TypeName Octopus.Client.Model.MachineResource
    $tentacle.Endpoint = $newTarget
    $tentacle.Name = $hostName

    # Add properties to host
    foreach ($environment in $environments)
    {
        # Add to target
        $tentacle.EnvironmentIds.Add($environment.Id)
    }

    foreach ($role in $roles)
    {
        # Add to target
        $tentacle.Roles.Add($role)
    }

    # Add to machine to space
    $repositoryForSpace.Machines.Create($tentacle)
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}

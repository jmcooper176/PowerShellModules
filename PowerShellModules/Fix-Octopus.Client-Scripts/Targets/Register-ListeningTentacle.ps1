# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
# Load octopus.client assembly
Add-Type -Path "path\to\Octopus.Client.dll"

# Octopus variables
$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"
$spaceName = "default"
$hostName = "MyHost"
$tentaclePort = "10933"
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
    $environments = $repositoryForSpace.Environments.GetAll() | Where-Object -FilterScript {$environmentNames -contains $_.Name}

    # Discover host
    $newTarget = $repositoryForSpace.Machines.Discover($hostName, $tentaclePort)

    # Add properties to host
    foreach ($environment in $environments)
    {
        # Add to target
        $newTarget.EnvironmentIds.Add($environment.Id) | Out-Null
    }

    foreach ($role in $roles)
    {
        # Add to target
        $newTarget.Roles.Add($role) | Out-Null
    }
    $newTarget.IsDisabled = $false

    # Add to machine to space
    $repositoryForSpace.Machines.Create($newTarget)
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}

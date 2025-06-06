# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
# Load octopus.client assembly
Add-Type -Path "path\to\Octopus.Client.dll"

# Octopus variables
$octopusURL = "https://your.octopus.app"
$octopusAPIKey = "API-YOURAPIKEY"
$spaceName = "default"
$role = "MyRole"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

try
{
    # Get space
    $space = $repository.Spaces.FindByName($spaceName)
    $repositoryForSpace = $client.ForSpace($space)

    # Get machine list
    $machines = $repositoryForSpace.Machines.GetAll() | Where-Object -FilterScript {$role -in $_.Roles}

    # Loop through list
    foreach ($machine in $machines)
    {
        # Delete machine
        $repositoryForSpace.Machines.Delete($machine)
    }
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}

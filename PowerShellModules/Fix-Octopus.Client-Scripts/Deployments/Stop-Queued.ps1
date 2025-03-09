# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/

# Load octopus.client assembly
Add-Type -Path "path\to\Octopus.Client.dll"

# Octopus variables
$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"
$spaceName = "default"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

try
{
    # Get space
    $space = $repository.Spaces.FindByName($spaceName)
    $repositoryForSpace = $client.ForSpace($space)

    # Get tasks
    $queuedDeployments = $repositoryForSpace.Tasks.FindAll() | Where-Object -FilterScript {$_.State -eq "Queued" -and $_.HasBeenPickedUpByProcessor -eq $false -and $_.Name -eq "Deploy"}

    # Loop through results
    foreach ($task in $queuedDeployments)
    {
        $repositoryForSpace.Tasks.Cancel($task)
    }
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}

# Load assembly
Add-Type -Path 'path:\to\Octopus.Client.dll'
$octopusURL = "https://YourURL"
$octopusAPIKey = "API-YourAPIKey"
$spaceName = "Default"
$lifecycleName = "MyLifecycle"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

# Get space
$space = $repository.Spaces.FindByName($spaceName)
$repositoryForSpace = $client.ForSpace($space)

# Check to see if lifecycle already exists
if ($null -eq $repositoryForSpace.Lifecycles.FindByName($lifecycleName))
{
    # Create new lifecyle
    $lifecycle = New-Object -TypeName Octopus.Client.Model.LifecycleResource
    $lifecycle.Name = $lifecycleName
    $repositoryForSpace.Lifecycles.Create($lifecycle)
}
else
{
    Write-Information -MessageData "$lifecycleName already exists."
}

# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
# Load octopus.client assembly
Add-Type -Path "path\to\Octopus.Client.dll"

# Octopus variables
$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"
$spaceName = "default"
$projectName = "MyProject"
$projectGroupName = "Default project group"
$lifecycleName = "Default lifecycle"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

try
{
    # Get space
    $space = $repository.Spaces.FindByName($spaceName)
    $repositoryForSpace = $client.ForSpace($space)

    # Get project group
    $projectGroup = $repositoryForSpace.ProjectGroups.FindByName($projectGroupName)

    # Get lifecycle
    $lifecycle = $repositoryForSpace.Lifecycles.FindByName($lifecycleName)

    # Create new project
    $project = $repositoryForSpace.Projects.CreateOrModify($projectName, $projectGroup, $lifecycle)
    $project.Save()
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}

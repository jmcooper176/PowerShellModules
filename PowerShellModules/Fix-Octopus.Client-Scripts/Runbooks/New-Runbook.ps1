# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
# Load octopus.client assembly
Add-Type -Path "path\to\Octopus.Client.dll"

# Octopus variables
$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"
$spaceName = "default"
$projectName = "MyProject"
$runbookName = "MyRunbook"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

try
{
    # Get space
    $space = $repository.Spaces.FindByName($spaceName)
    $repositoryForSpace = $client.ForSpace($space)

    # Get project
    $project = $repositoryForSpace.Projects.FindByName($projectName)

    # Create runbook retention object
    $runbookRetentionPolicy = New-Object -TypeName Octopus.Client.Model.RunbookRetentionPeriod
    $runbookRetentionPolicy.QuantityToKeep = 100
    $runbookRetentionPolicy.ShouldKeepForever = $false

    # Create runbook object
    $runbook = New-Object -TypeName Octopus.Client.Model.RunbookResource
    $runbook.Name = $runbookName
    $runbook.ProjectId = $project.Id
    $runbook.RunRetentionPolicy = $runbookRetentionPolicy

    # Save
    $repositoryForSpace.Runbooks.Create($runbook)
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}

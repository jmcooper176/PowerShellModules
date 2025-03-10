# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path 'path\to\Octopus.Client.dll'

$octopusURL = "https://youroctourl/"
$octopusAPIKey = "API-YOURAPIKEY"

$spaceName = "Default"
$projectName = "Your Project Name"
$releaseVersion = "0.0.1"
$environmentName = "Development"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint

try {
    # Get space id
    $space = $repository.Spaces.FindByName($spaceName)
    Write-Information -MessageData "Using Space named $($space.Name) with id $($space.Id)"

    # Create space specific repository
    $repositoryForSpace = [Octopus.Client.OctopusRepositoryExtensions]::ForSpace($repository, $space)

    # Get environment by name
    $environment = $repositoryForSpace.Environments.FindByName($environmentName)
    Write-Information -MessageData "Using Environment named $($environment.Name) with id $($environment.Id)"

    # Get project by name
    $project = $repositoryForSpace.Projects.FindByName($projectName)
    Write-Information -MessageData "Using Project named $($project.Name) with id $($project.Id)"

    # Get release by version
    $release = $repositoryForSpace.Projects.GetReleaseByVersion($project, $releaseVersion)
    Write-Information -MessageData "Using release version $($release.Version) with id $($release.Id)"

    # Create deployment
    $deployment = New-Object -TypeName Octopus.Client.Model.DeploymentResource -Property @{
        ReleaseId     = $release.Id
        EnvironmentId = $environment.Id
    }

    Write-Information -MessageData "Creating deployment for release $($release.Version) of project $projectName to environment $environmentName"
    $deployment = $repositoryForSpace.Deployments.Create($deployment)
}
catch {
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}

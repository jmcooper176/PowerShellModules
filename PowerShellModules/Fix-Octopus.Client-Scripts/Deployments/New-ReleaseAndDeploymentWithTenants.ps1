# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path 'path\to\Octopus.Client.dll'

$octopusBaseURL = "https://youroctourl/"
$octopusAPIKey = "API-YOURAPIKEY"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusBaseURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint

$spaceName = "Default"
$projectName = "Your Project Name"
$channelName = "Default"
$environmentName = "Dev"
$tenantNames = @("Customer A Name", "Customer B Name")

try {
    # Get space id
    $space = $repository.Spaces.FindByName($spaceName)
    Write-Information -MessageData "Using Space named $($space.Name) with id $($space.Id)"

    # Create space specific repository
    $repositoryForSpace = [Octopus.Client.OctopusRepositoryExtensions]::ForSpace($repository, $space)

    # Get project by name
    $project = $repositoryForSpace.Projects.FindByName($projectName)
    Write-Information -MessageData "Using Project named $($project.Name) with id $($project.Id)"

    # Get channel by name
    $channel = $repositoryForSpace.Channels.FindByName($project, $channelName)
    Write-Information -MessageData "Using Channel named $($channel.Name) with id $($channel.Id)"

    # Get environment by name
    $environment = $repositoryForSpace.Environments.FindByName($environmentName)
    Write-Information -MessageData "Using Environment named $($environment.Name) with id $($environment.Id)"

    # Get the deployment process template
    Write-Information -MessageData "Fetching deployment process template"
    $process = $repositoryForSpace.DeploymentProcesses.Get($project.DeploymentProcessId)
    $template = $repositoryForSpace.DeploymentProcesses.GetTemplate($process, $channel)

    Write-Information -MessageData "Creating release for $projectName"
    $release = New-Object -TypeName Octopus.Client.Model.ReleaseResource -Property @{
        ChannelId = $channel.Id
        ProjectId = $project.Id
        Version   = $template.NextVersionIncrement
    }

    # Set the package version to the latest for each package
    # If you have channel rules that dictate what versions can be used,
    #  you'll need to account for that by overriding the package version
    Write-Information -MessageData "Getting action package versions"
    $template.Packages | ForEach-Object -Process {
        $feed = $repositoryForSpace.Feeds.Get($_.FeedId)
        $latestPackage = [Linq.Enumerable]::FirstOrDefault($repositoryForSpace.Feeds.GetVersions($feed, @($_.PackageId)))

        $selectedPackage = New-Object -TypeName Octopus.Client.Model.SelectedPackage -Property @{
            ActionName = $_.ActionName
            Version    = $latestPackage.Version
        }

        Write-Information -MessageData "Using version $($latestPackage.Version) for action $($_.ActionName) package $($_.PackageId)"

        $release.SelectedPackages.Add($selectedPackage)
    }

    # Create release
    $release = $repositoryForSpace.Releases.Create($release, $false) # pass in $true if you want to ignore channel rules

    # Create deployment for each tenant
    $tenants = $repositoryForSpace.Tenants.FindByNames([Collections.Generic.List[String]]$tenantNames)

    $tenants | ForEach-Object -Process {
        $tenant = $_

        $deployment = New-Object -TypeName Octopus.Client.Model.DeploymentResource -Property @{
            ReleaseId     = $release.Id
            EnvironmentId = $environment.Id
            TenantId      = $tenant.Id
        }

        Write-Information -MessageData "Creating deployment for release $($release.Version) of project $projectName to environment $environmentName and tenant $($tenant.Name)"
        $deployment = $repositoryForSpace.Deployments.Create($deployment)
    }
}
catch {
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
    throw $Error[0]
}

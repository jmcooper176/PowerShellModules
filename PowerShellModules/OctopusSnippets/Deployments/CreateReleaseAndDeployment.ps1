<#
 =============================================================================
<copyright file="CreateReleaseAndDeployment.ps1" company="John Merryweather Cooper
">
    Copyright © 2025, John Merryweather Cooper.
    All Rights Reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:

       1. Redistributions of source code must retain the above
          copyright notice, this list of conditions and the following
          disclaimer.

       2. Redistributions in binary form must reproduce the above
          copyright notice, this list of conditions and the following
          disclaimer in the documentation and/or other materials
          provided with the distribution.

       3. Neither the name of the copyright holder nor the names of
          its contributors may be used to endorse or promote products
          derived from this software without specific prior written
          permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
   FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
   COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
   INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
   BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
   CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
   LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
   ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE.
</copyright>
<author>John Merryweather Cooper</author>
<date>Created:  2025-2-25</date>
<summary>
This file "CreateReleaseAndDeployment.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path 'path\to\Octopus.Client.dll'

$octopusBaseURL = "https://youroctourl/"
$octopusAPIKey = "API-YOURAPIKEY"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint($octopusBaseURL, $octopusAPIKey)
$repository = New-Object -TypeName Octopus.Client.OctopusRepository($endpoint)

$spaceName = "Default"
$projectName = "Your Project Name"
$channelName = "Default"
$environmentName = "Dev"

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
    throw $Error[0]
}
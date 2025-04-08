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

$ErrorActionPreference = "Stop";

# Define working variables
$octopusBaseURL = "https://youroctourl/api"
$octopusAPIKey = "API-YOURAPIKEY"
$headers = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

$spaceName = "Default"
$projectName = "Your Project Name"
$environmentName = "Development"
$channelName = "Default"

# Get space id
$spaces = Invoke-WebRequest -Uri "$octopusBaseURL/spaces/all" -Headers $headers -ErrorVariable octoError | ConvertFrom-Json
$space = $spaces | Where-Object -FilterScript { $_.Name -eq $spaceName }
Write-Information -MessageData "Using Space named $($space.Name) with id $($space.Id)"

# Create space specific url
$octopusSpaceUrl = "$octopusBaseURL/$($space.Id)"

# Get project by name
$projects = Invoke-WebRequest -Uri "$octopusSpaceUrl/projects/all" -Headers $headers -ErrorVariable octoError | ConvertFrom-Json
$project = $projects | Where-Object -FilterScript { $_.Name -eq $projectName }
Write-Information -MessageData "Using Project named $($project.Name) with id $($project.Id)"

# Get channel by name
$channels = Invoke-WebRequest -Uri "$octopusSpaceUrl/projects/$($project.Id)/channels" -Headers $headers -ErrorVariable octoError | ConvertFrom-Json
$channel = $channels | Where-Object -FilterScript { $_.Name -eq $channelName }
Write-Information -MessageData "Using Channel named $($channel.Name) with id $($channel.Id)"

# Get environment by name
$environments = Invoke-WebRequest -Uri "$octopusSpaceUrl/environments/all" -Headers $headers -ErrorVariable octoError | ConvertFrom-Json
$environment = $environments | Where-Object -FilterScript { $_.Name -eq $environmentName }
Write-Information -MessageData "Using Environment named $($environment.Name) with id $($environment.Id)"

# Get the deployment process template
Write-Information -MessageData "Fetching deployment process template"
$template = Invoke-WebRequest -Uri "$octopusSpaceUrl/deploymentprocesses/deploymentprocess-$($project.id)/template?channel=$($channel.Id)" -Headers $headers | ConvertFrom-Json

# Create the release body
$releaseBody = @{
    ChannelId        = $channel.Id
    ProjectId        = $project.Id
    Version          = $template.NextVersionIncrement
    SelectedPackages = @()
}

# Set the package version to the latest for each package
# If you have channel rules that dictate what versions can be used, you'll need to account for that
Write-Information -MessageData "Getting step package versions"
$template.Packages | ForEach-Object -Process {
    $uri = "$octopusSpaceUrl/feeds/$($_.FeedId)/packages/versions?packageId=$($_.PackageId)&take=1"
    $version = Invoke-WebRequest -Uri $uri -Method GET -Headers $headers -Body $releaseBody -ErrorVariable octoError | ConvertFrom-Json
    $version = $version.Items[0].Version

    $releaseBody.SelectedPackages += @{
        ActionName           = $_.ActionName
        PackageReferenceName = $_.PackageReferenceName
        Version              = $version
    }
}

# Create release
$releaseBody = $releaseBody | ConvertTo-Json
Write-Information -MessageData "Creating release with these values: $releaseBody"
$release = Invoke-WebRequest -Uri $octopusSpaceUrl/releases -Method POST -Headers $headers -Body $releaseBody -ErrorVariable octoError | ConvertFrom-Json

# Create deployment
$deploymentBody = @{
    ReleaseId     = $release.Id
    EnvironmentId = $environment.Id
} | ConvertTo-Json

Write-Information -MessageData "Creating deployment with these values: $deploymentBody"
$deployment = Invoke-WebRequest -Uri $octopusSpaceUrl/deployments -Method POST -Headers $headers -Body $deploymentBody -ErrorVariable octoError
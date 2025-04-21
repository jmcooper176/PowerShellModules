<#
 =============================================================================
<copyright file="ReDeployLatestReleaseInEnvironment.ps1" company="John Merryweather Cooper
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
This file "ReDeployLatestReleaseInEnvironment.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Define working variables
$octopusURL = "http://your.octopus.app"
$octopusAPIKey = "API-KEY"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

$spaceName = "Default"
$projectName = "YourProject"
$environmentName = "DEV1"

# Get space
$spaces = Invoke-RestMethod -Uri "$octopusURL/api/spaces?partialName=$([uri]::EscapeDataString($spaceName))&skip=0&take=100" -Headers $header
$space = $spaces.Items | Where-Object -FilterScript { $_.Name -eq $spaceName }
$spaceId = $space.Id

Write-Information -MessageData "The spaceId for $spaceName is $($spaceId)"

# Get project
$projects = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/projects?partialName=$([uri]::EscapeDataString($projectName))&skip=0&take=100" -Headers $header
$project = $projects.Items | Where-Object -FilterScript { $_.Name -eq $projectName }
$projectId = $project.Id

Write-Information -MessageData "The projectId for $spaceName is $($projectId)"

# Get environment
$environments = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/environments?partialName=$([uri]::EscapeDataString($environmentName))&skip=0&take=100" -Headers $header
$environment = $environments.Items | Where-Object -FilterScript { $_.Name -eq $environmentName } | Select-Object -First 1
$environmentId = $environment.Id

Write-Information -MessageData "The environmentId for $environmentName is $environmentId"
$progressionInformation = Invoke-RestMethod "$octopusURL/api/$spaceId/projects/$projectId/progression" -Headers $header

Write-Information -MessageData "Found $($progressionInformation.Releases.Length) releases"
$releaseId = ""

foreach ($release in $progressionInformation.Releases) {
    foreach ($deployEnv in $release.Deployments) {
        if (Get-Member -InputObject $deployEnv -Name $environmentId -MemberType Properties) {
            $releaseId = $release.Release.Id
            break
        }
    }

    if ([string]::IsNullOrWhiteSpace($releaseId) -eq $False) {
        break
    }
}

if ([string]::IsNullOrWhiteSpace($releaseId) -eq $True) {
    Write-Error -Message "A release couldn't be found deployed to $environmentName!"
    return
}

Write-Information -MessageData "The most recent release for $ProjectName in the $EnvironmentName Environment is $releaseId"

$bodyRaw = @{
    EnvironmentId            = "$environmentId"
    ExcludedMachineIds       = @()
    ForcePackageDownload     = $False
    ForcePackageRedeployment = $false
    FormValues               = @{}
    QueueTime                = $null
    QueueTimeExpiry          = $null
    ReleaseId                = "$releaseId"
    SkipActions              = @()
    SpecificMachineIds       = @()
    TenantId                 = $null
    UseGuidedFailure         = $false
}

$bodyAsJson = $bodyRaw | ConvertTo-Json

$redeployment = Invoke-RestMethod "$OctopusURL/api/$SpaceId/deployments" -Headers $header -Method Post -Body $bodyAsJson -ContentType "application/json"
$taskId = $redeployment.TaskId
$deploymentIsActive = $true

do {
    $deploymentStatus = Invoke-RestMethod "$OctopusURL/api/tasks/$taskId/details?verbose=false" -Headers $header
    $deploymentStatusState = $deploymentStatus.Task.State

    if ($deploymentStatusState -eq "Success" -or $deploymentStatusState -eq "Failed") {
        $deploymentIsActive = $false
    }
    else {
        Write-Information -MessageData "Deployment is still active...checking again in 5 seconds"
        Start-Sleep -Seconds 5
    }
} While ($deploymentIsActive)

Write-Information -MessageData "Redeployment has finished"

<#
 =============================================================================
<copyright file="UpdateRunbooksToLatestPackages.ps1" company="John Merryweather Cooper
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
This file "UpdateRunbooksToLatestPackages.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Define working variables
$octopusURL = "https://your.octopus.app"
$octopusAPIKey = "API-YOURAPIKEY"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }
$spaceName = "Default"
$projectName = "MyProject"

# Get space
$spaces = Invoke-RestMethod -Uri "$octopusURL/api/spaces?partialName=$([uri]::EscapeDataString($spaceName))&skip=0&take=100" -Headers $header
$space = $spaces.Items | Where-Object -FilterScript { $_.Name -eq $spaceName }

# Get project
$projects = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/projects?partialName=$([uri]::EscapeDataString($projectName))&skip=0&take=100" -Headers $header
$project = $projects.Items | Where-Object -FilterScript { $_.Name -eq $projectName }

# Get runbooks
$runbooks = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/projects/$($project.Id)/runbooks?skip=0&take=100" -Headers $header

$runbooksNeedingNewSnapshot = @()

foreach ($runbook in $runbooks.Items) {
    Write-Information -MessageData "Working on runbook: $($runbook.Name)"
    if ($null -ne $runbook.PublishedRunbookSnapshotId) {
        # Get the runbook snapshot
        $runbookSnapshot = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/runbookSnapshots/$($runbook.PublishedRunbookSnapshotId)" -Headers $header)

        if ($runbookSnapshot.SelectedPackages.Count -gt 0) {
            # Get Snapshot template to link packages to action/step
            $runbookSnapshotTemplate = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/runbookProcesses/$($runbook.RunbookProcessId)/runbookSnapshotTemplate?runbookSnapshotId=$($runbookSnapshot.Id)" -Headers $header
            foreach ($package in $runbookSnapshot.SelectedPackages) {
                # Get packageId from snapshot template
                $snapshotTemplatePackage = $runbookSnapshotTemplate.Packages | Where-Object -FilterScript { $_.StepName -eq $package.StepName -and $_.ActionName -eq $package.ActionName -and $_.PackageReferenceName -eq $package.PackageReferenceName } | Select-Object -First 1

                $snapshotPackageVersion = $package.Version

                # Get latest package version from built-in feed.
                $packages = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/feeds/$($snapshotTemplatePackage.FeedId)/packages/versions?packageId=$($snapshotTemplatePackage.PackageId)&take=1" -Headers $header
                $latestPackage = $packages.Items | Select-Object -First 1

                if ($latestPackage.Version -ne $snapshotPackageVersion) {
                    Write-Information -MessageData "Found package difference for $($snapshotTemplatePackage.PackageId) in runbook snapshot $($runbookSnapshot.Name)"
                    Write-Information -MessageData "Snapshot version: $($snapshotPackageVersion), Latest package version: $($latestPackage.Version)"
                    $runbookDetails = @{
                        ProjectId         = $project.Id
                        RunbookId         = $runbook.Id
                        RunbookProcessId  = $runbook.RunbookProcessId
                        RunbookSnapshotId = $runbookSnapshot.Id
                        RunbookName       = $runbook.Name
                    }
                    $runbooksNeedingNewSnapshot += $runbookDetails
                    break
                }
            }
        }
    }
}

if ($runbooksNeedingNewSnapshot.Count -gt 0) {
    Write-Information -MessageData "Found runbooks which need new snapshots"
    foreach ($runbookItem in $runbooksNeedingNewSnapshot) {
        Write-Information -MessageData "Creating new snapshot for runbook: $($runbookItem.RunbookName)"

        # Get a new runbook snapshot template
        $runbookSnapshotTemplate = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/runbookProcesses/$($runbookItem.RunbookProcessId)/runbookSnapshotTemplate" -Headers $header

        # Create a new runbook snapshot
        $body = @{
            ProjectId        = $runbookItem.ProjectId
            RunbookId        = $runbookItem.RunbookId
            Name             = $runbookSnapshotTemplate.NextNameIncrement
            Notes            = $null
            SelectedPackages = @()
        }

        # Include latest built-in feed packages
        foreach ($package in $runbookSnapshotTemplate.Packages) {
            if ($package.FeedId -eq "feeds-builtin") {
                # Get latest package version
                $packages = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/feeds/feeds-builtin/packages/versions?packageId=$($package.PackageId)&take=1" -Headers $header
                $latestPackage = $packages.Items | Select-Object -First 1
                $package = @{
                    ActionName           = $package.ActionName
                    Version              = $latestPackage.Version
                    PackageReferenceName = $package.PackageReferenceName
                }

                $body.SelectedPackages += $package
            }
        }

        $body = $body | ConvertTo-Json -Depth 10

        # Create runbook snapshot
        $runbookPublishedSnapshot = Invoke-RestMethod -Method Post -Uri "$octopusURL/api/$($space.Id)/runbookSnapshots?publish=true" -Body $body -Headers $header

        # Get runbook
        $runbook = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/runbooks/$($runbookItem.RunbookId)" -Headers $header

        # Publish the new snapshot
        $runbook.PublishedRunbookSnapshotId = $runbookPublishedSnapshot.Id
        Invoke-RestMethod -Method Put -Uri "$octopusURL/api/$($space.Id)/runbooks/$($runbook.Id)" -Body ($runbook | ConvertTo-Json -Depth 10) -Headers $header
        Write-Information -MessageData "Published new runbook snapshot: $($runbookPublishedSnapshot.Id) ($($runbookPublishedSnapshot.Name))"
    }
}

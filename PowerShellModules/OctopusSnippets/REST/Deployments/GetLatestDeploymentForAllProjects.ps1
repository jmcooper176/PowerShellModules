<#
 =============================================================================
<copyright file="GetLatestDeploymentForAllProjects.ps1" company="John Merryweather Cooper
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
This file "GetLatestDeploymentForAllProjects.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

###############################################################################################################################################################
# NOTE: This script only finds the initial deployment to an environment. Deployments to individual targets via a Deployment Target Trigger are not detected.  #
# NOTE: Use this script as a first pass to find projects that have not been deployed recently, but always verify the results.                                 #
###############################################################################################################################################################

$octopusURL = "YOUR OCTOPUS URL"
$apiKey = "YOUR OCTOPUS API KEY"
$spaceName = "YOUR SPACE NAME"
$outputFilePath = "DIRECTORY TO OUTPUT\OctopusProjectsLatestDeployment.csv"
$headers = @{ "X-Octopus-ApiKey" = $apiKey }

# Get space ID
$space = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/spaces/all" -Headers $headers) | Where-Object -FilterScript { $_.Name -eq $spaceName }
$spaceId = $space.Id
$octopusSpaceUrl = "$octopusURL/api/$spaceId"

$showProgress = $true

# Get first page of projects
$take = 30
$count = 1
$pageNumber = 0
Write-Information -MessageData "Getting page 1 of projects for space $spaceId"
$projects = Invoke-RestMethod -Uri "$octopusSpaceUrl/projects?take=$take" -Headers $headers
$total = $projects.TotalResults

# Initialize an array to hold the project details
$projectDetails = @()

Write-Information -MessageData "---"
Write-Information -MessageData "Calculating the latest deployment date for $total projects (this may take some time!)."
Write-Information -MessageData "---"

while ($pageNumber -le $projects.LastPageNumber) {
    foreach ($project in $projects.Items) {
        $per = [math]::Round($count / $total * 100.0, 2) - 1

        if ($showProgress) {
            Write-Progress -Activity "Checking project $($project.Name)".PadRight(60) -Status "$count/$total ($per% Complete)" -PercentComplete $per
        }

        $deploymentsUrl = "$octopusSpaceUrl/deployments?projects=$($project.Id)&take=1"
        try {
            $latestDeployment = Invoke-RestMethod -Uri $deploymentsUrl -Method Get -Headers $headers -ErrorAction Stop | Select-Object -ExpandProperty Items | Select-Object -First 1

            if ($null -ne $latestDeployment) {
                $releaseId = $latestDeployment.ReleaseId
                $releaseUrl = "$octopusURL/api/$spaceId/releases/$releaseId"
                $release = Invoke-RestMethod -Uri $releaseUrl -Method Get -Headers $headers

                $deploymentDate = Get-Date $latestDeployment.Created -Format "MMM-d-yyyy"

                $projectDetails += [PSCustomObject]@{
                    Project          = $project.Name
                    ProjectId        = $project.Id
                    LatestRelease    = $release.Version
                    LatestDeployment = $deploymentDate
                    Timestamp        = $latestDeployment.Created
                }
            }
            else {
                $projectDetails += [PSCustomObject]@{
                    Project          = $project.Name
                    ProjectId        = $project.Id
                    LatestRelease    = "N/A"
                    LatestDeployment = "N/A"
                    Timestamp        = 0
                }
            }
        }
        catch {
            $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
            $projectDetails += [PSCustomObject]@{
                Project          = $project.Name
                ProjectId        = $project.Id
                LatestRelease    = "Failed to retrieve"
                LatestDeployment = "Failed to retrieve"
                Timestamp        = 0
            }
        }

        $count += 1
    }
    $pageNumber += 1
    $skip = $pageNumber * $take
    if ($pageNumber -gt $projects.LastPageNumber) {
        break
    }

    Write-Information -MessageData "Getting page $($pageNumber + 1) of projects for space $spaceId"
    $projects = Invoke-RestMethod -Uri "$octopusSpaceUrl/projects?skip=$skip&take=$take" -Headers $headers
}

if ($showProgress) {
    Write-Progress -Activity "Creating $outputFilePath".PadRight(60) -Status "Almost done" -PercentComplete 100
}

$projectDetails | Sort-Object -Property Timestamp -Descending | Export-Csv -Path $outputFilePath -NoTypeInformation

Start-Sleep -Seconds 1

if ($showProgress) {
    Write-Progress -Activity "Export complete.".PadRight(60) -Status "100% Complete" -PercentComplete 100
}

Write-Information -MessageData "Export completed. File saved at: $outputFilePath"

<#
 =============================================================================
<copyright file="GetReleaseNotesForDeploymentsToEnvironment.ps1" company="John Merryweather Cooper
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
This file "GetReleaseNotesForDeploymentsToEnvironment.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Define working variables
$octopusURL = "https://your.octopus.app"
$octopusAPIKey = "API-YOURKEY"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }
$spaceName = "Default"
$environmentName = "Production"
$deploymentsQueuedAfter = "2021-06-01"

# Get space
$spaces = Invoke-RestMethod -Uri "$octopusURL/api/spaces?partialName=$([uri]::EscapeDataString($spaceName))&skip=0&take=100" -Headers $header 
$space = $spaces.Items | Where-Object -FilterScript { $_.Name -eq $spaceName }

# Get environment
$environmentsResources = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/environments?partialName=$([uri]::EscapeDataString($environmentName))&skip=0&take=100" -Headers $header 
$environments = ($environmentsResources.Items | Where-Object -FilterScript { $_.Name -eq $environmentName } | ForEach-Object -Process {"environments=$($_.Id)"}) -Join "&"

# Get Project groups
$projectGroupsResource = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/projectgroups?skip=0&take=100" -Headers $header 
$projectGroups = ($projectGroupsResource.Items | ForEach-Object -Process {"projectGroups=$($_.Id)"}) -Join "&"

# Get events
$eventsUrl = "$octopusURL/api/$($space.Id)/events?includeSystem=false&eventCategories=DeploymentQueued&documentTypes=Deployments&from=$($deploymentsQueuedAfter)T00%3A00%3A00%2B00%3A00&$($projectGroups)&$($environments)"

$events = @()
$response = $null
do {
    $uri = if ($response) { $octopusURL + $response.Links.'Page.Next' } else { $eventsUrl }
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
    $events += $response.Items
} while ($response.Links.'Page.Next')

$releaseItems=@()
foreach($event in $events)
{
    # Get Release Id
    $releaseId = $event.RelatedDocumentIds | Where-Object -FilterScript {$_ -like "Releases-*"} | Select-Object -First 1
    $projectId = $event.RelatedDocumentIds | Where-Object -FilterScript {$_ -like "Projects*"} | Select-Object -First 1
    $project = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/projects/$projectId" -Headers $header 
    $release = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/releases/$releaseId" -Headers $header 
    if(![string]::IsNullOrWhiteSpace($release.ReleaseNotes)) {
        $releaseItem = [PSCustomObject]@{
            Project = $project.Name;
            Version = $release.Version;
            Created = $event.Occurred;
            ReleaseNotes = $release.ReleaseNotes
        }
        $releaseItems += $releaseItem
    }
}
$releaseItems | Select-Object -Property * | Format-Table

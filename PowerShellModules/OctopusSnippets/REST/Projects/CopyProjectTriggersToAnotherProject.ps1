<#
 =============================================================================
<copyright file="CopyProjectTriggersToAnotherProject.ps1" company="John Merryweather Cooper
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
This file "CopyProjectTriggersToAnotherProject.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Define working variables
$octopusURL = "https://your.octopus.app"
$octopusAPIKey = "API-KEY"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }
$spaceName = "Default"
$sourceProjectName = "Source project"
$destProjectName = "Destination project"

# Get space
$spaces = Invoke-RestMethod -Uri "$octopusURL/api/spaces?partialName=$([uri]::EscapeDataString($spaceName))&skip=0&take=100" -Headers $header 
$space = $spaces.Items | Where-Object -FilterScript { $_.Name -eq $spaceName }

# Get source project
$sourceProjects = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/projects?partialName=$([uri]::EscapeDataString($sourceProjectName))&skip=0&take=100" -Headers $header 
$sourceProject = $sourceProjects.Items | Where-Object -FilterScript { $_.Name -eq $sourceProjectName }

# Get source project triggers
$sourceProjectTriggers = Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects/$($sourceProject.Id)/triggers" -Headers $header

# Get destination project
$destProjects = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/projects?partialName=$([uri]::EscapeDataString($destProjectName))&skip=0&take=100" -Headers $header 
$destProject = $destProjects.Items | Where-Object -FilterScript { $_.Name -eq $destProjectName }

# Get destination project triggers
$destProjectTriggers = Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects/$($destProject.Id)/triggers" -Headers $header

# Loop through source triggers
foreach ($projectTrigger in $sourceProjectTriggers.Items) {
    $matchingDestTriggers = @($destProjectTriggers.Items | Where-Object -FilterScript { $_.Name -ieq $projectTrigger.Name })
    if ($matchingDestTriggers.Count -gt 0) {
        Write-Warning -Message "'$($projectTrigger.Name)' already exists in '$($destProjectName)'"
    }
    else {
        Write-Information -MessageData "Trigger '$($projectTrigger.Name)' doesnt exist in $($destProjectName), creating."
        $projectTrigger.Id = $null
        $projectTrigger.Links = $null
        # IMPORTANT, switch project Id :)
        $projectTrigger.ProjectId = $destProject.Id
        $response = Invoke-RestMethod -Method Post -Uri "$octopusURL/api/$($space.Id)/projects/$($destProject.Id)/triggers" -Body ($projectTrigger | ConvertTo-Json -Depth 10) -Headers $header
        Write-Verbose -Message "Trigger creation response: $response"
    }
}
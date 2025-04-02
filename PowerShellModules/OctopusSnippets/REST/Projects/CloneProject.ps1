<#
 =============================================================================
<copyright file="CloneProject.ps1" company="U.S. Office of Personnel
Management">
    Copyright © 2025, U.S. Office of Personnel Management.
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
This file "CloneProject.ps1" is part of "OctopusSnippets".
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
$sourceProjectName = "Enter Source Project Name here"
$sourceLifecycleToUse = "Enter Lifecycle Name here"
$destinationProjectName = "Enter Destination Project Name here"
$destinationProjectGroupName = "Enter Project Group Name here"
$destinationProjectDescription = "Project clone of $($sourceProjectName)"

# Get space
$spaces = Invoke-RestMethod -Uri "$octopusURL/api/spaces?partialName=$([uri]::EscapeDataString($spaceName))&skip=0&take=100" -Headers $header 
$space = $spaces.Items | Where-Object -FilterScript { $_.Name -ieq $spaceName }

# Get source project
$sourceProjects = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/projects?partialName=$([uri]::EscapeDataString($sourceProjectName))&skip=0&take=100" -Headers $header 
$matchingSourceProjects = @($sourceProjects.Items | Where-Object -FilterScript { $_.Name -ieq $sourceProjectName }) 
$firstMatchingSourceProject = $matchingSourceProjects | Select-Object -First 1
if ($matchingSourceProjects.Count -gt 1) {
    Write-Warning -Message "Multiple projects found matching name $($sourceProjectName), choosing first one ($($firstMatchingSourceProject.Id))"
}

# Get lifecycle to use
$lifecycles = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/lifecycles?partialName=$([uri]::EscapeDataString($sourceLifecycleToUse))&skip=0&take=100" -Headers $header 
$matchingLifecycles = @($lifecycles.Items | Where-Object -FilterScript { $_.Name -ieq $sourceLifecycleToUse })
$firstMatchingLifecycle = $matchingLifecycles | Select-Object -First 1
if ($matchingLifecycles.Count -gt 1) {
    Write-Warning -Message "Multiple lifecycles found matching name $($sourceLifecycleToUse), choosing first one ($($firstMatchingLifecycle.Id))"
}

# Get project Group
$projectGroups = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/projectgroups?partialName=$([uri]::EscapeDataString($destinationProjectGroupName))&skip=0&take=100" -Headers $header 
$matchingProjectGroups = @($projectGroups.Items | Where-Object -FilterScript { $_.Name -ieq $destinationProjectGroupName }) 
$firstMatchingProjectGroup = $matchingProjectGroups | Select-Object -First 1
if ($matchingProjectGroups.Count -gt 1) {
    Write-Warning -Message "Multiple project groups found matching name $($destinationProjectGroupName), choosing first one ($($firstMatchingProjectGroup.Id))"
}

# Clone project
$clonedProjectRequest = @{
    Name           = $destinationProjectName
    Description    = $destinationProjectDescription
    LifecycleId    = $firstMatchingLifecycle.Id
    ProjectGroupId = $firstMatchingProjectGroup.Id
}

$newProject = Invoke-RestMethod -Method POST -Uri "$octopusURL/api/$($space.Id)/projects?clone=$($firstMatchingSourceProject.Id)" -Headers $header -Body ($clonedProjectRequest | ConvertTo-Json -Depth 10)
$newProject
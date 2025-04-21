<#
 =============================================================================
<copyright file="UpdateProjectLifecycle.ps1" company="John Merryweather Cooper
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
This file "UpdateProjectLifecycle.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

####
## Define working variables
####
$octopusURL = "https://myoctopusurl"
$octopusAPIKey = "API-YOURKEYHERE"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }
$spaceName = "default"

# Lifecycle name to search for and replace
$oldLifecycleName = "MyOldLifecycleName"
# New lifecycle to assign (must exist before running script)
$newLifecycleName = "MyNewLifecycleName"

# What-If flag (set to true to test changes without comitting them)
$whatIf = $true

####
## Perform API Calls
####

# Get space
$space = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/spaces/all" -Headers $header) | Where-Object -FilterScript { $_.Name -eq $spaceName }

# Get lifecycles
$allLifecycles = Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/lifecycles/all" -Headers $header
$originalLifecycle = $allLifecycles | Where-Object -FilterScript { $_.Name -eq $oldLifecycleName }
$newLifecycle = $allLifecycles | Where-Object -FilterScript { $_.Name -eq $newLifecycleName }

# Get projects for space
$projectList = Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects/all" -Headers $header

# Loop through projects
foreach ($project in $projectList) {
    # Set to false and change to identify when changes should be committed
    $changesMade = $false

    if ($project.LifecycleId -eq $($originalLifecycle.Id)) {
        Write-Information -MessageData -ForegroundColor Yellow "Project $($project.Name) is using deprecated lifecycle $($oldLifecycleName)"

        $project.LifecycleId = $($newLifecycle.Id)

        $changesMade = $true
    }

    if ($changesMade) {
        if ($whatIf) {
            Write-Information -MessageData -ForegroundColor Green "`tProject would be updated - '$($project.Name)' would be updated to use the lifecycle '$($newLifecycle.Name)'"
        }
        elseif ($project -ne $projectList[-1]) {
            Write-Information -MessageData "`tLifecycle values updated for $($step.Name) in $($project.Name), checking next project"
        }
        else {
            Write-Information -MessageData "`tLifecycle values updated for $($step.Name) in $($project.Name)."
        }
    }

    if (!$whatIf -and $changesMade) {
        Write-Information -MessageData -ForegroundColor Green "`tUpdating project metadata for $($project.Name)"
        Invoke-RestMethod -Method Put -Uri "$octopusURL/api/$($space.Id)/projects/$($project.Id)" -Headers $header -Body ($project | ConvertTo-Json -Depth 10)
    }
}

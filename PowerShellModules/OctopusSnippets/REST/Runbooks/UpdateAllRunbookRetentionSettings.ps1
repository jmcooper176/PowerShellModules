<#
 =============================================================================
<copyright file="UpdateAllRunbookRetentionSettings.ps1" company="John Merryweather Cooper
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
This file "UpdateAllRunbookRetentionSettings.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Define working variables
$octopusURL = "https://your.octopus.app"
$octopusAPIKey = "API-YOURKEY"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }
# Optional space filter
$spaceName = "Default"
# Optional project filter
$projectName = ""
# Optional runbook filter
$runbookName = ""

# Max runbook run qty per environment to keep
$runbookMaxRetentionRunPerEnvironment = 5

# Get spaces
$spaces = Invoke-RestMethod -Uri "$octopusURL/api/spaces/all" -Headers $header
if (![string]::IsNullOrWhitespace($spaceName)) {
    Write-Output "Filtering spaces to just $spaceName"
    $spaces = $spaces | Where-Object -FilterScript { $_.Name -ieq $spaceName }
}
Write-Output "Space Count: $($spaces.Length)"
foreach ($space in $spaces) {
    Write-Output "Working on space $($space.Name)"

    $projects = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/projects/all" -Headers $header
    if (![string]::IsNullOrWhitespace($projectName)) {
        Write-Output "Filtering projects to just $projectName"
        $projects = $projects | Where-Object -FilterScript { $_.Name -ieq $projectName }
    }
    Write-Output "Project Count: $($projects.Length)"

    foreach ($project in $projects) {
        Write-Output "Working on project $($project.Name)"

        $projectRunbooks = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/projects/$($project.Id)/runbooks" -Headers $header
        if (![string]::IsNullOrWhitespace($runbookName)) {
            Write-Output "Filtering runbooks to just $runbookName"
            $runbooks = $projectRunbooks.Items | Where-Object -FilterScript { $_.Name -ieq $runbookName }
        }
        else {
            $runbooks = $projectRunbooks.Items
        }
        Write-Output "Runbook Count: $($runbooks.Length)"

        foreach ($runbook in $runbooks) {
            Write-Output "Working on runbook $($runbook.Name)"
            $currentRetentionQuantityToKeep = $runbook.RunRetentionPolicy.QuantityToKeep

            if ($currentRetentionQuantityToKeep -gt $runbookMaxRetentionRunPerEnvironment) {
                Write-Output "Runbook '$($runbook.Name)' ($($runbook.Id)) has a retention run policy to keep of: $($currentRetentionQuantityToKeep) which is greater than $($runbookMaxRetentionRunPerEnvironment)"
                $runbook.RunRetentionPolicy.QuantityToKeep = $runbookMaxRetentionRunPerEnvironment
                Write-Output "Updating runbook run quantity to keep for '$($runbook.Name)' ($($runbook.Id)) to $runbookMaxRetentionRunPerEnvironment"

                $runbookResponse = Invoke-RestMethod -Method Put -Uri "$octopusURL/api/$($space.Id)/runbooks/$($runbook.Id)" -Body ($runbook | ConvertTo-Json -Depth 10) -Headers $header
                if ($runbookResponse.RunRetentionPolicy.QuantityToKeep -ne $runbookMaxRetentionRunPerEnvironment) {
                    throw "Update for '$($runbook.Name)' ($($runbook.Id)) doesnt look like it worked. QtyToKeep is: $($runbookResponse.RunRetentionPolicy.QuantityToKeep)"
                }
            }
        }
    }
}

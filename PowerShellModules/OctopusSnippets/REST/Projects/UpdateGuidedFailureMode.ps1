<#
 =============================================================================
<copyright file="UpdateGuidedFailureMode.ps1" company="John Merryweather Cooper
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
This file "UpdateGuidedFailureMode.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Define working variables
$octopusURL = "https://your.octopus.app/"
$octopusAPIKey = "API-KEY"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }
$spaceName = "Default"
$projectName = "Your-Project-Name"

$octopusURI = $octopusURL

$setting = "EnvironmentDefault"

# Get space
$spaces = Invoke-RestMethod -Uri "$octopusURL/api/spaces?partialName=$([uri]::EscapeDataString($spaceName))&skip=0&take=100" -Headers $header
$space = $spaces.Items | Where-Object -FilterScript { $_.Name -eq $spaceName }
$defaultSpaceId = $space.Id

$project = (Invoke-RestMethod -Uri "$octopusURI/api/$defaultSpaceId/projects/all" -Method GET -Headers $header) | Where-Object -FilterScript { $_.Name -eq $projectName }
if (!$project) {
    Write-Warning -Message "Can't find $projectName, skipping this project."
    return
}

# Get project deployment settings
$projectDeploymentSettings = Invoke-RestMethod -Uri "$octopusURI/api/$defaultSpaceId/projects/$($project.id)/deploymentsettings" -Method GET -Headers $header
if ($null -eq $projectDeploymentSettings) {
    Write-Warning -Message "Can't find deployment settings for $projectName, skipping this project."
    return
}

if ($setting -eq $projectDeploymentSettings.DefaultGuidedFailureMode) {
    Write-Information -MessageData "$projectname guided failure setting is already set to: $setting... Skipping"
    return
}
$projectDeploymentSettings.DefaultGuidedFailureMode = $setting
$jsonBody = $projectDeploymentSettings | ConvertTo-Json -Depth 12

try {
    Invoke-RestMethod -Uri "$octopusURI/api/$defaultSpaceId/projects/$($project.id)/deploymentsettings" -Method PUT -Headers $header -Body $jsonBody -ContentType "application/json"
    Write-Information -MessageData "Successfully updated $projectname"
}
catch {
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}

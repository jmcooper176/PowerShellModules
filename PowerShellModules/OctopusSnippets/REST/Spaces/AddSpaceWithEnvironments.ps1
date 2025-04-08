<#
 =============================================================================
<copyright file="AddSpaceWithEnvironments.ps1" company="John Merryweather Cooper
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
This file "AddSpaceWithEnvironments.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Define working variables
$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

$spaceName = "New Space"
$description = "Space for the new, top secret project."
$managersTeams = @() # an array of team Ids to add to Space Managers
$managerTeamMembers = @() # an array of user Ids to add to Space Managers
$environments = @('Development', 'Test', 'Production')

$body = @{
    Name = $spaceName
    Description = $description
    SpaceManagersTeams = $managersTeams
    SpaceManagersTeamMembers = $managerTeamMembers
    IsDefault = $false
    TaskQueueStopped = $false
} | ConvertTo-Json

$response = try {
    Write-Information -MessageData "Creating space '$spaceName'"
    (Invoke-WebRequest -Uri $octopusURL/api/spaces -Headers $header -Method Post -Body $body -ErrorVariable octoError)
} catch [System.Net.WebException] {
    Write-Error -Message $_.Exception.Response -ErrorAction Continue
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}

if ($octoError) {
    Write-Information -MessageData "An error was encountered trying to create the space: $($octoError.Message)"
    exit
}

$space = $response.Content | ConvertFrom-Json

foreach ($environment in $environments) {
    $body = @{
        Name = $environment
    } | ConvertTo-Json

    Write-Information -MessageData "Creating environment '$environment'"
    $response = try {
        (Invoke-WebRequest -Uri "$octopusURL/api/$($space.Id)/environments" -Headers $header -Method Post -Body $body -ErrorVariable octoError)
    } catch [System.Net.WebException] {
        Write-Error -Message $_.Exception.Response -ErrorAction Continue
        $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
    }

    if ($octoError) {
        Write-Information -MessageData "An error was encountered trying to create the environment: $($octoError.Message)"
        exit
    }
}
<#
 =============================================================================
<copyright file="FindEnvironmentsWithNoDeployments.ps1" company="John Merryweather Cooper
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
This file "FindEnvironmentsWithNoDeployments.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# Octopus Url
$OctopusUrl = "https://your-octopus-url"

# API Key
$APIKey = "API-XXXXXXXXX"

# Space where machines exist
$spaceName = "Default"

$header = @{ "X-Octopus-ApiKey" = $APIKey }

# Get SpaceId
Write-Information -MessageData "Getting list of all spaces: $OctopusUrl/api/Spaces?skip=0&take=100000"
$spaceList = (Invoke-RestMethod "$OctopusUrl/api/Spaces?skip=0&take=100000" -Headers $header)
$space = $spaceList.Items | Where-Object -FilterScript { $_.Name -eq $spaceName} | Select-Object -First 1
$spaceId = $space.Id

# Get List of All Environments for Space

$environmentUrl = "$OctopusUrl/api/$spaceId/environments?skip=0&take=100000"

Write-Information -MessageData "Getting list of environments: $environmentUrl"
$environmentResource = (Invoke-RestMethod $environmentUrl -Headers $header)
$environments = $environmentResource.Items

$deploymentsUrl = "$OctopusUrl/api/$spaceId/deployments?skip=0&take=100000"
Write-Information -MessageData "Getting list of deployments: $deploymentsUrl"
$deploymentsResource = (Invoke-RestMethod $deploymentsUrl -Headers $header)
$deployments = $deploymentsResource.Items

$foundEnvironments = @()
foreach ($deployment in $deployments) {
    $deploymentEnvironmentId = $deployment.EnvironmentId
    if( -not $foundEnvironments.Contains($deploymentEnvironmentId)) {
        $foundEnvironments += "$deploymentEnvironmentId"
    }
}

# Just the Ids for Space Environments
$spaceEnvironmentids = $environments | ForEach-Object -Process {"$($_.Id)"}

$result = $spaceEnvironmentids | Where-Object -FilterScript {!($foundEnvironments -contains $_)}
$total = $result.Count
Write-Information -MessageData "Found $total environments without deployments."
if($result.Count -gt 0) {
    $tempFile = [System.IO.Path]::GetTempFileName()
    $result | Out-File -append $tempFile
    Write-Information -MessageData "Written environments with no deployments to: $tempFile"
}

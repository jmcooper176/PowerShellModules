<#
 =============================================================================
<copyright file="FindLifecyclesWithNoAssociatedReleases.ps1" company="John Merryweather Cooper
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
This file "FindLifecyclesWithNoAssociatedReleases.ps1" is part of "OctopusSnippets".
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

# Get List of All Channels for Space (these contain the LifecycleIds)
$channelsUrl = "$OctopusUrl/api/$spaceId/channels?skip=0&take=100000"
Write-Information -MessageData "Getting list of channels: $channelsUrl"

$channelsResource = (Invoke-RestMethod $channelsUrl -Headers $header)
$channels = $channelsResource.Items
$lifecyclesWithoutReleases = @()

foreach($channel in $channels){
    $channelId = $channel.Id
    $channelName = $channel.Name
    $channelLifecycleId = $channel.LifecycleId
    $channelProjectId = $channel.ProjectId
    if($null -eq $channelLifecycleId) {
        $channelLifecycleId = "[Default Lifecycle]"
    }
    $channelReleasesUrl = "$OctopusUrl/api/$spaceId/channels/$channelId/releases?skip=0&take=10000"
    $channelReleasesResource = (Invoke-RestMethod $channelReleasesUrl -Headers $header)
    $channelReleases = $channelReleasesResource.Items
    if($channelReleases.Count -eq 0) {
        $lifecyleDesc =  "Channel: $channelName ($channelId),ProjectId: $channelProjectId, LifecycleId: $channelLifecycleId"
        if( -not $lifecyclesWithoutReleases.Contains($lifecyleDesc)) {
            $lifecyclesWithoutReleases += "$lifecyleDesc"
        }
    }
}

$totalFound = $lifecyclesWithoutReleases.Count
Write-Information -MessageData "Total Lifecyles with no releases: $totalFound"

if ($totalFound -gt 0) {
    $tempFile = [System.IO.Path]::GetTempFileName()
    $lifecyclesWithoutReleases | Out-File -append $tempFile
    Write-Information -MessageData "Found the following lifecycles with no releases:" -ForegroundColor Red
    foreach ($lifecycle in $lifecyclesWithoutReleases) {
        Write-Information -MessageData $lifecycle
    }
    Write-Information -MessageData "Written lifecycles with no releases to: $tempFile"
}

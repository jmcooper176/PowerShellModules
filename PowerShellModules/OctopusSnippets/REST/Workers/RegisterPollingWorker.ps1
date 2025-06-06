﻿<#
 =============================================================================
<copyright file="RegisterPollingWorker.ps1" company="John Merryweather Cooper
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
This file "RegisterPollingWorker.ps1" is part of "OctopusSnippets".
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
$communicationsStyle = "TentacleActive"
$hostName = "your-worker"
$workerPoolNames = @("Your worker pool")
$workerPoolIds = @()
$tentacleThumbprint = "TentacleThumbprint"
$tentacleIdentifier = "PollingTentacleIdentifier" # Must match value in Tentacle.config file on tentacle machine; ie poll://RandomCharacters

# Get space
$spaces = Invoke-RestMethod -Uri "$octopusURL/api/spaces?partialName=$([uri]::EscapeDataString($spaceName))&skip=0&take=100" -Headers $header
$space = $spaces.Items | Where-Object -FilterScript { $_.Name -eq $spaceName }

# Get workerpools
$workerpools = @()
$response = $null
do {
    $uri = if ($response) { $octopusURL + $response.Links.'Page.Next' } else { "$octopusURL/api/$($space.Id)/workerpools" }
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
    $workerpools += $response.Items
} while ($response.Links.'Page.Next')

foreach ($workerPoolName in $workerPoolNames)
{
    $workerPoolId = $workerpools | Where-Object -FilterScript { $_.Name -eq $workerPoolName } | Select-Object -ExpandProperty Id
    $workerPoolIds += $workerPoolId
}

# Create unique URI for tentacle
$tentacleURI = "poll://$tentacleIdentifier"

# Create JSON payload
$jsonPayload = @{
    Endpoint = @{
        CommunicationStyle = $communicationsStyle
        Thumbprint = $tentacleThumbprint
        Uri = $tentacleURI
    }
    WorkerPoolIds = $workerPoolIds
    Name = $hostName
    Status = "Unknown"
    IsDisabled = $false
}

$jsonPayload

# Register new worker to space
Invoke-RestMethod -Method Post -Uri "$octopusURL/api/$($space.Id)/workers" -Headers $header -Body ($jsonPayload | ConvertTo-Json -Depth 10)

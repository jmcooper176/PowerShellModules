<#
 =============================================================================
<copyright file="TargetsNeedingCalamariUpgrade.ps1" company="U.S. Office of Personnel
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
This file "TargetsNeedingCalamariUpgrade.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Add support for TLS 1.2 + TLS 1.3
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls13

# Fix ANSI Color on PWSH Core issues when displaying objects
if (($PSVersionTable.PSVersion.Major -gt 7) -or ($PSVersionTable.PSVersion.Major -eq 7 -and $PSVersionTable.PSVersion.Minor -ge 2)) {
    $PSStyle.OutputRendering = [System.Management.Automation.OutputRendering]::PlainText
}

$stopwatch = [system.diagnostics.stopwatch]::StartNew()

 #Define working variables
$octopusURL = "https://your.octopus.app"
$octopusAPIKey = "API-XXXX"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

# Validation that variable have been updated. Do not update the values here - they must stay as "https://your.octopus.app"
# and "API-XXXX", as this is how we check that the variables above were updated.
if ($octopusURL -eq "https://your.octopus.app" -or $octopusAPIKey -eq "API-XXXX") {
    Write-Information -MessageData "You must replace the placeholder variables with values specific to your Octopus instance"
    exit 1
}

# Get space
Write-Verbose -Message "Retrieving all spaces"
$spaces = Invoke-RestMethod -Uri "$octopusURL/api/spaces?skip=0&take=100" -Headers $header 
$spaces = $spaces.Items 

$machines = @()

foreach ($space in $spaces) {
    Write-Verbose -Message "Retrieving all machines in space '$($space.Name)'"

    $response = $null
    do {
        $uri = if ($response) { $octopusURL + $response.Links.'Page.Next' } else { "$octopusURL/api/$($space.Id)/machines" }
        $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
        $machines += $response.Items
    } while ($response.Links.'Page.Next')
    Write-Verbose -Message "Completed retrieval of all machines in space '$($space.Name)'"
}

$machinesNeedingCalamariUpgrade = $machines | Where-Object -FilterScript { $_.HasLatestCalamari -eq $false }

Write-Output "Found $($machinesNeedingCalamariUpgrade.Count) machines needing calamari upgrade"
if ($machinesNeedingCalamariUpgrade.Count -gt 0) {
    Write-Output ""
    $machinesNeedingCalamariUpgrade | Sort-Object -Property TenantName | Format-Table -Property SpaceId, Name, Id
}

$stopwatch.Stop()
Write-Output "Completed execution in $($stopwatch.Elapsed)"

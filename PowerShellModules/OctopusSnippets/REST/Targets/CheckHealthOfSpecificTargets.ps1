<#
 =============================================================================
<copyright file="CheckHealthOfSpecificTargets.ps1" company="John Merryweather Cooper
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
This file "CheckHealthOfSpecificTargets.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

#NOTE: This script does not RUN a health check, it only checks the current status of a machine from the latest health check.

# Define working variables
$OctopusURL = "https://"
$OctopusAPIKey = "API-"
$Header = @{ "X-Octopus-ApiKey" = $OctopusAPIKey }
$SpaceName = ""
$MachineIDs = @("Machines-501","Machines-991")   #comma separated list of machine ID's that you'd like to check the latest health status of.

$Space = (Invoke-RestMethod -Method Get -Uri "$OctopusURL/api/spaces/all" -Headers $Header) | Where-Object -FilterScript { $_.Name -eq $SpaceName }

Write-Information -MessageData "`r`n"
foreach ($machineID in $MachineIDs){
    $Machine = (Invoke-RestMethod -Method Get -Uri "$OctopusURL/api/$($Space.id)/machines/$($machineID)" -Headers $Header)
    Write-Information -MessageData "Machine: $($machine.Name)($($machineID)) `r`n| Disabled: $($machine.IsDisabled) `r`n| Health Status: $($machine.HealthStatus) `r`n| Status Summary: $($machine.StatusSummary)`r`n`r`n"
}

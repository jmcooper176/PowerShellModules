<#
 =============================================================================
<copyright file="SetRetentionPolicyOfAllLifecycles.ps1" company="John Merryweather Cooper
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
This file "SetRetentionPolicyOfAllLifecycles.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Define working variables
$octopusURL = "https://your.octopus.app"
$octopusAPIKey = "API-YOURAPIKEY"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

# Helpful notes:
# - Unit can be either of "Days" or "Items"
# - If ShouldKeepForever = True, QuantityToKeep should be 0 to keep all

# Choose release retention policy
# This could be applied to both the Lifecycle AND phases if configured.
$releaseRetentionPolicy = [PSCustomObject]@{
    Unit = "Days"
    QuantityToKeep = 30
    ShouldKeepForever = $false
}

# Choose tentacle release retention policy
# This could be applied to both the Lifecycle AND phases if configured.
$tentacleRetentionPolicy = [PSCustomObject]@{
    Unit = "Days"
    QuantityToKeep = 30
    ShouldKeepForever = $false
}

# Should we update the Lifecycle retention policy, with the values specified above?
$UpdateLifecycleRetentionPolicy = $True

# Should we update the retention policy in all phases found in the lifecycle, with the values specified above?
$UpdateRetentionPolicyInPhases = $True

# Get Lifecycle records
$AllLifecycles = (Invoke-WebRequest -Uri $OctopusURL/api/lifecycles/all -Headers $header).content | ConvertFrom-Json

# Loop through each lifecycle
foreach ($lifecycle in $AllLifecycles){

    Write-Information -MessageData "Working on lifecycle: [$($lifecycle.Name)]" -ForegroundColor Yellow
    # Update Lifecycle retention policy if configured.
    if($UpdateLifecycleRetentionPolicy -eq $True){
        Write-Information -MessageData "`tModifying lifecycle retention policy for: [$($lifecycle.Name)]" -ForegroundColor DarkBlue
        $lifecycle.ReleaseRetentionPolicy = $releaseRetentionPolicy
        $lifecycle.TentacleRetentionPolicy = $tentacleRetentionPolicy

    }
    else {
        Write-Information -MessageData "Skipping lifecycle retention policy update for: [$($lifecycle.Name)] as UpdateLifecycleRetentionPolicy = False" -ForegroundColor Yellow
    }

    # Update Lifecycle's phases retention policy if configured.
    if($UpdateRetentionPolicyInPhases -eq $True) {
        foreach ($phase in $lifecycle.Phases){
            Write-Information -MessageData "`tModifying retention policy of phase: [$($phase.Name)] for Lifecyle: [$($lifecycle.Name)]" -ForegroundColor Blue
            $phase.ReleaseRetentionPolicy = $releaseRetentionPolicy
            $phase.TentacleRetentionPolicy = $tentacleRetentionPolicy
        }
    }
    else {
        Write-Information -MessageData "Skipping phase retention policy updates for: [$($lifecycle.Name)] as UpdateRetentionPolicyInPhases = False" -ForegroundColor Yellow
    }

    $body = $lifecycle | ConvertTo-Json -Depth 10

    Write-Information -MessageData "Saving changes for lifecycle: [$($lifecycle.Name)]" -ForegroundColor Green
    Invoke-RestMethod -Method Put -Uri "$octopusURL/api/$($space.Id)/lifecycles/$($lifecycle.Id)" -Body $body -Headers $header
}
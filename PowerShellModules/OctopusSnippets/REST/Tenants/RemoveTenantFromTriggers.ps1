<#
 =============================================================================
<copyright file="RemoveTenantFromTriggers.ps1" company="U.S. Office of Personnel
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
This file "RemoveTenantFromTriggers.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# =========================================================
#      Removes a Tenant from existing Project Triggers
# =========================================================

$ErrorActionPreference = "Stop";

# Define working variables
$OctopusURL = "http://YOUR_OCTOPUS_URL"
$OctopusAPIKey = "API-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
$Header = @{ "X-Octopus-ApiKey" = $OctopusAPIKey }
$SpaceId = "Spaces-1"
$TenantName = "YOUR_TENANT_NAME"

# Find Tenant ID
$Tenant = (Invoke-RestMethod -Method GET "$OctopusURL/api/$($SpaceId)/Tenants/all" -Headers $Header) | Where-Object -FilterScript {$_.Name -eq $TenantName}


# Find Triggers that include $Tenant.Id
$TriggersList = (Invoke-RestMethod -Method GET "$OctopusURL/api/$($SpaceId)/projecttriggers" -Headers $Header) | Where-Object -FilterScript {$_.Items.Action.TenantIds -contains $($Tenant.Id)}
$Triggers = $TriggersList.items
Foreach ($Trigger in $Triggers) {
    $TriggerTenantIds = $Trigger.Action.TenantIds
    $Trigger.Action.TenantIds = @()
    Foreach ($TriggerTenantId in $TriggerTenantIds) {
        If ($TriggerTenantId -ne $($Tenant.Id)) {
            $Trigger.Action.TenantIds += $TriggerTenantId
        }
        Invoke-RestMethod -Method PUT "$OctopusURL/api/$($SpaceId)/projects/$($Trigger.ProjectId)/triggers/$($Trigger.Id)" -Body ($Trigger | ConvertTo-Json -Depth 10) -Headers $Header
    }
}
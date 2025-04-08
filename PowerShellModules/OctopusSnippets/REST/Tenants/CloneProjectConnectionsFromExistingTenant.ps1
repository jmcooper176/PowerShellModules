<#
 =============================================================================
<copyright file="CloneProjectConnectionsFromExistingTenant.ps1" company="John Merryweather Cooper
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
This file "CloneProjectConnectionsFromExistingTenant.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# ===========================================================
#      Clone Project connections from an existing Tenant
# ===========================================================

$ErrorActionPreference = "Stop";

# Define working variables
$OctopusURL = "http://YOUR_OCTOPUS_URL"
$OctopusAPIKey = "API-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
$Header = @{ "X-Octopus-ApiKey" = $OctopusAPIKey }
$SpaceId = "Spaces-1"
$SourceTenantName = "SOURCE_TENANT_NAME"
$DestinationTenantName = "DESTINATION_TENANT_NAME"

# Find Tenant IDs
$SourceTenant = (Invoke-RestMethod -Method GET "$OctopusURL/api/$($SpaceId)/Tenants/all" -Headers $Header) | Where-Object -FilterScript {$_.Name -eq $SourceTenantName}
$DestinationTenant = (Invoke-RestMethod -Method GET "$OctopusURL/api/$($SpaceId)/Tenants/all" -Headers $Header) | Where-Object -FilterScript {$_.Name -eq $DestinationTenantName}

# Modify $DestinationTenant to match .ProjectEnviroments with $SourceTenant
$DestinationTenant.ProjectEnvironments = $SourceTenant.ProjectEnvironments

# Commit
Invoke-RestMethod -Method PUT "$OctopusURL/api/$($SpaceId)/Tenants/$($DestinationTenant.Id)" -Body ($DestinationTenant | ConvertTo-Json -Depth 10) -Headers $Header
Write-Information -MessageData "Done!"
Write-Warning -Message "Please check your Tenant Common Variables before deploying via: `"$OctopusURL/app#/$($SpaceId)/Tenants/$($DestinationTenant.Id)/variables?activeTab=commonVariables`""

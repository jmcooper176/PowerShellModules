<#
 =============================================================================
<copyright file="RemoveEnvironmentfromProjectTenantconnection.ps1" company="John Merryweather Cooper
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
This file "RemoveEnvironmentfromProjectTenantconnection.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$whatif = $false #set to $true for a dry run where no changes are committed, set to $false to commit changes

$OctopusAPIKey = "API-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" 
$OctopusUrl = "YOUR_OCTOPUS_URL" # No trailing slashes example = "http://octopusinstance.bla"
$TenantId = "Tenants-XX" # Tenant ID you wish to remove Environments from
$SpaceId = "Spaces-XX" # Space ID where the Tenant specified above resides
$EnvironmentId = "Environments-XX" # Environment ID you want to remove

$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

$tenant = Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/$($SpaceId)/tenants/$($TenantId)" -Headers $header

Write-Information -MessageData "˅========Old JSON Between These Lines========˅"
$tenant | ConvertTo-Json
Write-Information -MessageData "˄========Old JSON Between These Lines========˄"
Write-Information -MessageData ""

$projectIds = @()
$projectEnvironments = @{}
foreach ($Obj in $tenant.ProjectEnvironments.PSObject.Properties) {
    $environmentIds = @()
    foreach ($environment in $Obj.value) {
        if ($environment -ne $EnvironmentId) {
            $environmentIds += $environment
        }
    }
    $projectEnvironments.Add($Obj.Name,$environmentIds)
}


# Build json payload
$jsonPayload = @{
    Name = $tenant.Name
    TenantTags = $tenant.TenantTags
    SpaceId = $SpaceId
    ProjectEnvironments = $projectEnvironments
}

Write-Information -MessageData "˅======Updated JSON Between These Lines======˅"
$jsonPayload | ConvertTo-Json
Write-Information -MessageData "^======Updated JSON Between These Lines======^"
Write-Information -MessageData ""

# Upload Tenant JSON payload
if ($whatif -eq $false) {
    Invoke-RestMethod -Method Put -Uri "$octopusURL/api/$($SpaceId)/tenants/$($TenantId)" -Body ($jsonPayload | ConvertTo-Json -Depth 10) -Headers $header -ContentType "application/json"
    }
Else {
    Write-Information -MessageData "Dry run detected. Set `$whatif to `$false to commit changes."
}

Write-Information -MessageData "Done"

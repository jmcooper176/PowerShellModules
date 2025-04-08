<#
 =============================================================================
<copyright file="FindTenantsMatchingTagSetFilter.ps1" company="John Merryweather Cooper
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
This file "FindTenantsMatchingTagSetFilter.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# Octopus URL
$octopusURL = "https://octopusurl"

# Octopus API Key
$octopusAPIKey = "API-YOURAPIKEY"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

# Space Name
$spaceName = "Default"

# Canonical TagSet Name. 
# e.g. "AWS Region/California" See: https://octopus.com/docs/deployment-patterns/multi-tenant-deployments/tenant-tags#TenantTags-Referencingtenanttags
$canonicalTagSet = "Tag Set Name/Tag Name"

$matchingTenantIds = @()

try
{
    # Get space
    $space = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/spaces/all" -Headers $header) | Where-Object -FilterScript {$_.Name -eq $spaceName}

    # Filter tenants by tag set
    $tenants = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/tenants/tag-test?tags=$canonicalTagSet" -Headers $header)

    $tenantProperties = Get-Member -InputObject $tenants -MemberType NoteProperty
    foreach ($tenantProp in $tenantProperties)
    {           
        $tenantId = $tenantProp.Name
        $tenant = $tenants | Select-Object -ExpandProperty $tenantProp.Name
        if($tenant.IsMatched -eq $True) {
            $matchingTenantIds += $tenantId
        }       
    }
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}

Write-Information -MessageData "Tenants found matching canonical tagset of $($canonicalTagSet):"
$matchingTenantIds
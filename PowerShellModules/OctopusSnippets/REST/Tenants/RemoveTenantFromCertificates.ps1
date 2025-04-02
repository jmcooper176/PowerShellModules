<#
 =============================================================================
<copyright file="RemoveTenantFromCertificates.ps1" company="U.S. Office of Personnel
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
This file "RemoveTenantFromCertificates.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# =============================================================== #
#      Removes a Tenant from existing and archived certificates   #
# =============================================================== #

$ErrorActionPreference = "Stop";

# Define working variables
$OctopusURL = "https://your.octopus.app"
$OctopusAPIKey = "API-KEY"
$Header = @{ "X-Octopus-ApiKey" = $OctopusAPIKey }

$spaceName = "Default"
$tenantName = "TenantName"

# Set this flag to $False to actually perform the operation
$WhatIf = $True

# Get Space
$spaces = Invoke-RestMethod -Uri "$octopusURL/api/spaces?partialName=$([uri]::EscapeDataString($spaceName))&skip=0&take=100" -Headers $header 
$space = $spaces.Items | Where-Object -FilterScript { $_.Name -ieq $spaceName }

# Find Tenant
$tenants = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/tenants?name=$tenantName" -Headers $header)
$tenant = $tenants.Items | Where-Object -FilterScript { $_.Name -ieq $tenantName } | Select-Object -First 1

Write-Output "Retrieving all current certificates for tenant"
$currentCerts = @()
$response = $null
do {
  $uri = if ($response) { $octopusURL + $response.Links.'Page.Next' } else { "$octopusURL/api/$($space.Id)/certificates?tenant=$($tenant.Id)&skip=0&take=100" }
  $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
  $currentCerts += $response.Items
} while ($response.Links.'Page.Next')

Write-Output "Retrieving all archived certificates for tenant"
$archivedCerts = @()
$response = $null
do {
  $uri = if ($response) { $octopusURL + $response.Links.'Page.Next' } else { "$octopusURL/api/$($space.Id)/certificates?tenant=$($tenant.Id)&archived=true&skip=0&take=100" }
  $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
  $archivedCerts += $response.Items
} while ($response.Links.'Page.Next')

if ($currentCerts.Count -eq 0 -and $archivedCerts.Count -eq 0) {
  Write-Output "No certificates found for tenant '$($tenant.Name)'"
  return
}
else {
    Write-Information -MessageData "Working on current certificates"
    foreach($cert in $currentCerts) {
        if ($WhatIf) {
            Write-Output "WhatIf: Would have removed tenant '$($tenant.Name)' association with certificate '$($cert.Name)'"
        }
        else {
            Write-Output "Removing tenant '$($tenant.Name)' association with certificate '$($cert.Name)'"
            $cert.TenantIds = $cert.TenantIds | Where-Object -FilterScript { $_ -ne $tenant.Id }
            if($cert.TenantIds.Length -eq 0 -and $cert.TenantedDeploymentParticipation -ieq "Tenanted") {
                Write-Warning -Message "Removing tenant assocation from current certificate '$($cert.Name)' would cause no tenants to be linked. Changing TenantedDeploymentParticipation to TenantedOrUntenanted"
                $cert.TenantedDeploymentParticipation = "TenantedOrUntenanted"
            }
            $certBody = $cert | ConvertTo-Json -Depth 10
            Invoke-RestMethod -Method Put -Uri "$octopusURL/api/$($space.Id)/certificates/$($cert.Id)" -Body $certBody -Headers $header
        }
    }

    Write-Information -MessageData "Working on archived certificates"
    foreach($cert in $archivedCerts) {
        if ($WhatIf) {
            Write-Output "WhatIf: Would have removed tenant '$($tenant.Name)' association with archived certificate '$($cert.Name)' ($($cert.Id))"
        }
        else {
            Write-Output "Removing tenant '$($tenant.Name)' association with archived certificate '$($cert.Name)' ($($cert.Id))"
            $cert.TenantIds = @($cert.TenantIds | Where-Object -FilterScript { $_ -ne $tenant.Id })
            if($cert.TenantIds.Length -eq 0 -and $cert.TenantedDeploymentParticipation -ieq "Tenanted") {
                Write-Warning -Message "Removing tenant assocation from archived certificate '$($cert.Name)' would cause no tenants to be linked. Changing TenantedDeploymentParticipation to TenantedOrUntenanted"
                $cert.TenantedDeploymentParticipation = "TenantedOrUntenanted"
            }
            $certBody = $cert | ConvertTo-Json -Depth 10
            Invoke-RestMethod -Method Put -Uri "$octopusURL/api/$($space.Id)/certificates/$($cert.Id)" -Body $certBody -Headers $header
        }
    }
}
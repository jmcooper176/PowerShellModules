<#
 =============================================================================
<copyright file="GetLatestDeploymentForAllTenants.ps1" company="John Merryweather Cooper
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
This file "GetLatestDeploymentForAllTenants.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$octopusURL = "YOUR OCTOPUS URL"
$apiKey = "YOUR OCTOPUS API KEY"
$spaceName = "YOUR SPACE NAME"
$outputFilePath = "DIRECTORY TO OUTPUT\OctopusTenantsLatestDeployment.csv"
$headers = @{ "X-Octopus-ApiKey" = $apiKey }

# Get space ID
$space = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/spaces/all" -Headers $headers) | Where-Object -FilterScript { $_.Name -eq $spaceName }
$spaceId = $space.Id

# Get all tenants in the specified space
$tenantListUrl = "$octopusURL/api/$spaceId/tenants/all"
$tenants = Invoke-RestMethod -Uri $tenantListUrl -Method Get -Headers $headers

# Initialize an array to hold the tenant details
$results = @()

Write-Information -MessageData "---"
Write-Information -MessageData "Calculating the latest deployment for $($tenants.count) tenants (this may take some time!)."
Write-Information -MessageData "---"

# Loop through each tenant to find the latest deployment
foreach ($tenant in $tenants) 
{
    $deploymentsUrl = "$octopusURL/api/$spaceId/deployments?tenants=$($tenant.Id)&take=1"
    $latestDeployment = Invoke-RestMethod -Uri $deploymentsUrl -Method Get -Headers $headers -ErrorAction Stop | Select-Object -ExpandProperty Items | Select-Object -First 1

    if ($null -ne $latestDeployment) 
    {
        # Convert date
        $deploymentDate = Get-Date $latestDeployment.Created -Format "MMM-d-yyyy"
        $row = New-Object -TypeName PSObject -Property @{
            TenantName = $tenant.Name
            TenantID = $tenant.Id
            LastDeploymentDate = $deploymentDate
        }
    } 
    else 
    {
        $row = New-Object -TypeName PSObject -Property @{
            TenantName = $tenant.Name
            TenantID = $tenant.Id
            LastDeploymentDate = "No deployments"
        }
    }
    $results += $row
}

# Export results to CSV
$results | Export-Csv -Path $outputFilePath -NoTypeInformation

Write-Information -MessageData "Export completed. File saved at: $outputFilePath"

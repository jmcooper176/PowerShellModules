<#
 =============================================================================
<copyright file="RunConfigAsCodeRunbook.ps1" company="U.S. Office of Personnel
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
This file "RunConfigAsCodeRunbook.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# This script is for early access Config-as-Code Runbooks. This script may break in subsequent changes.

$ErrorActionPreference = "Stop";

Add-Type -AssemblyName System.Net

# Define working variables
$octopusURL = "https://your.octopus.app"
$octopusAPIKey = "API-"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }
$spaceName = "Default"
$projectName = "MyProject"
$runbookName = "MyRunbook"
$gitRef = "refs/heads/main"
$environmentNames = @("Development", "Staging")
$environmentIds = @()

# Optional Tenant
$tenantName = ""
$tenantId = $null

# Get space
$space = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/spaces/all" -Headers $header) | Where-Object -FilterScript {$_.Name -eq $spaceName} 

# Get project
$project = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects/all" -Headers $header) | Where-Object -FilterScript {$_.Name -eq $projectName}

# Convert GitRef to safe string
$encodedGitRef = [System.Net.WebUtility]::UrlEncode($gitRef)

# Get runbook
$runbook = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/spaces/$($space.Id)/projects/$($project.Id)/$($encodedGitRef)/runbooks" -Headers $header).Items | Where-Object -FilterScript {$_.Name -eq $runbookName}

# Get environments
$environments = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/environments/all" -Headers $header) | Where-Object -FilterScript {$environmentNames -contains $_.Name}
foreach ($environment in $environments)
{
    $environmentIds += $environment.Id
}

# Optionally get tenant
if (![string]::IsNullOrEmpty($tenantName)) {
    $tenant = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/tenants/all" -Headers $header) | Where-Object -FilterScript {$_.Name -eq $tenantName} | Select-Object -First 1
    $tenantId = $tenant.Id
}

foreach ($environmentId in $environmentIds)
{
    # Create json payload
    $jsonPayload = @{
        SelectedPackages = @()
        SelectedGitResources = @()
        Runs = @(@{
            EnvironmentId = $environmentId
            TenantId = $tenantId
            SkipActions = @()
            SpecificMachineIds = @()
            ExcludedMachineIds = @()
        })
    }

    # Run runbook
    Invoke-RestMethod -Method Post -Uri "$octopusURL/api/spaces/$($space.Id)/projects/$($project.Id)/$($encodedGitRef)/runbooks/$($runbook.Slug)/run/v1" -Body ($jsonPayload | ConvertTo-Json -Depth 10) -Headers $header
}

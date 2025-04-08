<#
 =============================================================================
<copyright file="ListTenantsAndProjectTemplateValues.ps1" company="John Merryweather Cooper
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
This file "ListTenantsAndProjectTemplateValues.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Define working variables

$octopusURL = "https://your.octopus.app"
$octopusAPIKey = "API-YOURKEY"

$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

# Space name
$spaceName = "Default"

# Optional, filter by Tenant name
$tenantName = ""

# Optional, filter by Project name
$projectName = ""

# Optional, filter by Environment name
$environmentName = ""

# Get Space
$space = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/spaces/all" -Headers $header) | Where-Object -FilterScript {$_.Name -eq $spaceName}

# Get Environments
$environments = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/environments/all" -Headers $header)

# Get Environment
$environmentId = $null
if (-not [string]::IsNullOrWhitespace($environmentName)){
    
    $environment = $environments | Select-Object -First 1
    if($null -ne $environment) {
        Write-Information -MessageData "Found environment matching name: $($environment.Name) ($($environment.Id))"
        $environmentId = $environment.Id
    }
}

# Get Project
$projectId = $null
if (-not [string]::IsNullOrWhitespace($projectName)){
    $projectSearch = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects?name=$projectName" -Headers $header)
    $project = $projectSearch.Items | Select-Object -First 1
    if($null -ne $project) {
        Write-Information -MessageData "Found project matching name: $($project.Name) ($($project.Id))"
        $projectId = $project.Id
    }
}

# Get tenant(s)
$tenantsResponse = $null
$tenants = @()
if (-not [string]::IsNullOrWhitespace($tenantName)){
    $tenantsSearch = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/tenants?name=$tenantName" -Headers $header)
    $tenant = $tenantsSearch.Items | Select-Object -First 1
    if($null -ne $tenant) {
        Write-Information -MessageData "Found tenant matching name: $($tenant.Name) ($($tenant.Id))"
        $tenants += $tenant
    }
} 
else {
    do {
        $uri = if ($tenantsResponse) { $octopusURL + $tenantsResponse.Links.'Page.Next' } else { "$octopusURL/api/$($space.Id)/tenants" }
        $tenantsResponse = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
        $tenants += $tenantsResponse.Items
        
    } while ($tenantsResponse.Links.'Page.Next')
}

# Loop through tenants
foreach ($tenant in $tenants) {
    Write-Information -MessageData "Working on tenant: $($tenant.Name) ($($tenant.Id))"
    
    # Get tenant variables
    $variables = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/tenants/$($tenant.Id)/variables" -Headers $header)

    # Get project templates
    $projects = $variables.ProjectVariables | Get-Member | Where-Object -FilterScript {$_.MemberType -eq "NoteProperty"} | Select-Object -ExpandProperty "Name"
    
    if($null -ne $projectId){
        Write-Information -MessageData "Filtering on project: $($project.Name) ($($project.Id))"
        $projects = $projects | Where-Object -FilterScript { $_ -eq $projectId}
    }


    # Loop through projects
    foreach ($projectKey in $projects)
    {
        $project = $variables.ProjectVariables.$projectKey
        $projectName = $project.ProjectName
        if($project.Templates.Count -le 0) {
            continue;
        }
        Write-Information -MessageData "Working on Project: $($project.ProjectName) ($projectKey)"
        $projectConnectedEnvironments = $project.Variables | Get-Member | Where-Object -FilterScript {$_.MemberType -eq "NoteProperty"} | Select-Object -ExpandProperty "Name"
        
        if($null -ne $environmentId){
            Write-Information -MessageData "Filtering on project: $($project.Name) ($($project.Id))"
            $projectConnectedEnvironments = $projectConnectedEnvironments | Where-Object -FilterScript { $_ -eq $environmentId}
        }

        foreach($template in $project.Templates) {
            $templateId = $template.Id
            # Loop through each of the connected environments variables
            foreach($envId in $projectConnectedEnvironments) {
                $envName = ($environments | Where-Object -FilterScript {$_.Id -eq $envId} | Select-Object -First 1).Name
                Write-Information -MessageData "$($template.Name) value for $envName = $($project.Variables.$envId.$templateId)"
            }
        }
        Write-Information -MessageData ""
    }
}
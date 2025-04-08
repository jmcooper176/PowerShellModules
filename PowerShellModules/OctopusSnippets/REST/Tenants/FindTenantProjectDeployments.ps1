<#
 =============================================================================
<copyright file="FindTenantProjectDeployments.ps1" company="John Merryweather Cooper
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
This file "FindTenantProjectDeployments.ps1" is part of "OctopusSnippets".
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

# Tenant name
$tenantName = "TenantName"

# Environment name to evaluate for deployments
$environmentName = "EnvironmentName"

# Get Space
$space = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/spaces/all" -Headers $header) | Where-Object -FilterScript {$_.Name -eq $spaceName}

# Get Environment
$envSearch = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/environments?name=$environmentName" -Headers $header)
$environment = $envSearch.Items | Select-Object -First 1

# Get Tenant
$tenantsSearch = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/tenants?name=$tenantName" -Headers $header)
$tenant = $tenantsSearch.Items | Select-Object -First 1

# Get connected projects matching $environmentName
$projectIds = $tenant.ProjectEnvironments | Get-Member | Where-Object -FilterScript {$_.MemberType -eq "NoteProperty"} | Select-Object -ExpandProperty "Name" | Where-Object -FilterScript {$tenant.ProjectEnvironments.$_ -icontains $environment.Id}
$summaryItems = @()
$projectDeployments = @()
foreach($projectId in $projectIds)
{
    # Get project
    $project = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects/$projectId" -Headers $header)
    
    # Get deployments for project + environment
    $deployments = @()
    $response = $null
    do {
        $uri = if ($response) { $octopusURL + $response.Links.'Page.Next' } else { "$octopusURL/api/$($space.Id)/deployments?projects=$($projectId)&tenants=$($tenant.Id)&environments=$($environment.Id)" }
        $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
        $deployments += $response.Items
    } while ($response.Links.'Page.Next')

    if($deployments.Count -lt 1) {
        Write-Information -MessageData "No deployments found for '$($project.Name)' ($($projectId)) to $environmentName"
    }
    else {
        # Get last deployment 
        $lastDeployment = $deployments | Sort-Object -Property Created -Descending | Select-Object -First 1
        
        # Get server task
        $lastdeploymentTask = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/tasks/$($lastDeployment.TaskId)" -Headers $header)
        
        # Augment the last deployment with the task status (success/failed/canceled etc)
        $lastDeployment | Add-Member -NotePropertyName DeploymentState -NotePropertyValue $lastdeploymentTask.State
        
        # Create summary
        $summaryItem = [PsCustomObject]@{
            ProjectId = $project.Id
            ProjectName = $project.Name
            ReleaseId = $lastDeployment.ReleaseId
            DeploymentId = $lastDeployment.Id
            TaskId = $lastDeployment.TaskId
            DeploymentState = $lastDeployment.DeploymentState
            WebLink = "$octopusURL$($lastdeploymentTask.Links.Web)"
        }
        $summaryItems += $summaryItem
        
        # Add deployment to another list
        $projectDeployments += $lastDeployment
    }
}

# Summary
$summaryItems | Format-Table

# All details
#$projectDeployments | Format-Table

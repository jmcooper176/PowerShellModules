<#
 =============================================================================
<copyright file="RemoveNonExistantProjects.ps1" company="John Merryweather Cooper
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
This file "RemoveNonExistantProjects.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$OctopusAPIKey = "API-XXXXXXXXXXXXXXXXXXXXXX"
$OctopusUrl = "https://octopus.url"
$SpaceId = "Spaces-22"
$WhatIf = $true

$header = New-Object -TypeName "System.Collections.Generic.Dictionary[[String],[String]]"
$header.Add("X-Octopus-ApiKey", $OctopusAPIKey)

$tenantList = Invoke-RestMethod "$OctopusUrl/api/$SpaceId/tenants?skip=0&take=1000000" -Headers $header
$projectList = Invoke-RestMethod "$OctopusUrl/api/$SpaceId/projects?skip=0&take=1000000" -Headers $header

foreach ($tenant in $tenantList.Items)
{
    $tenantModified = $false

    $assignedProjects = $tenant.ProjectEnvironments | Get-Member | Where-Object -FilterScript {$_.MemberType -eq "NoteProperty"} | Select-Object -Property "Name"

    foreach ($project in $assignedProjects)
    {
        $projectId = $project.Name
        $filteredProjectList = @($projectList.Items | Where-Object -FilterScript {$_.Id -eq $projectId })
        if ($filteredProjectList.Length -gt 0)
        {
            Write-Information -MessageData "Project $projectId found for tenant $($tenant.Name)"
        }
        else
        {
            Write-Information -MessageData "Tenant $($tenant.Name) is assigned to the project $projectId which does not exist anymore - removing reference"
            $tenantModified = $true
            $tenant.ProjectEnvironments.PSObject.Properties.Remove($projectId)
        }
    }

    if ($tenantModified -eq $true)
    {
        Write-Information -MessageData "The tenant $($tenant.Name) was modified, calling the update endpoint"
        $tenantBodyAsJson = $tenant | ConvertTo-Json -Depth 10
        Write-Information -MessageData "The new tenant body will be:"
        Write-Information -MessageData $tenantBodyAsJson

        if ($WhatIf -eq $false)
        {
            Write-Information -MessageData "What if set to false, hitting the API"

            Write-Information -MessageData "Removing the dead projects from the tenant"
            Invoke-RestMethod "$OctopusUrl/$($tenant.Links.Self)" -Method PUT -Body $tenantBodyAsJson -Headers $header
        }
        else
        {
            Write-Information -MessageData "What if set to true, skipping API call"
        }
    }
}

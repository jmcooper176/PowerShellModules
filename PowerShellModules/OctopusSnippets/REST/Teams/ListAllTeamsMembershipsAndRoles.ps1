<#
 =============================================================================
<copyright file="ListAllTeamsMembershipsAndRoles.ps1" company="U.S. Office of Personnel
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
This file "ListAllTeamsMembershipsAndRoles.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$octopusURL = "https://yoururl.com" # Replace with your instance URL
$octopusAPIKey = "YOUR API KEY" # Replace with a service account API Key
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

Write-Information -MessageData "Pulling all users, teams, and roles"
$userList = Invoke-RestMethod -Method GET -Uri "$OctopusUrl/api/users?skip=0&take=10000" -Headers $header
$teamList = Invoke-RestMethod -Method GET -Uri "$OctopusUrl/api/teams?skip=0&take=10000&includeSystem=true" -Headers $header
$userRoleList = Invoke-RestMethod -Method GET -Uri "$OctopusUrl/api/userroles?skip=0&take=10000" -Headers $header
$spaceList = Invoke-RestMethod -Method GET -Uri "$OctopusUrl/api/spaces?skip=0&take=10000" -Headers $header
$environmentCache = @{}
$projectCache = @{}
$tenantCache = @{}
$projectGroupCache = @{}
Write-Information -MessageData "All data needed has been pulled."

foreach ($team in $teamList.Items)
{
    Write-Information -MessageData "Team: $($team.Name)"

    Write-Information -MessageData "    Users:"
    foreach ($memberId in $team.MemberUserIds)
    {
        $user = $userList.Items | Where-Object -FilterScript {$_.Id -eq $memberId}
        Write-Information -MessageData "        $($user.DisplayName) $($user.EmailAddress)"
    }

    Write-Information -MessageData "    External Security Groups:"
    foreach ($externalSecurityGroup in $team.ExternalSecurityGroups)
    {
        Write-Information -MessageData "        $($externalSecurityGroup.DisplayName)"
    }

    $scopedUserRoles = Invoke-RestMethod -Method GET -Uri "$OctopusUrl/api/teams/$($team.Id)/scopeduserroles?skip=0&take=10000" -Headers $header
    Write-Information -MessageData "    Roles:"
    foreach ($scopedRole in $scopedUserRoles.Items)
    {       
        $spaceId = $scopedRole.SpaceId 
        $space = $spaceList.Items | Where-Object -FilterScript {$_.Id -eq $spaceId}
        if ($space)
        {
            Write-Information -MessageData "        Space: $($space.Name)"
        }
        else
        {
            Write-Information -MessageData "        Space: System"
        }

        $role = $userRoleList.Items | Where-Object -FilterScript {$_.Id -eq $scopedRole.UserRoleId}
        Write-Information -MessageData "            $($role.Name)"
        if ($scopedRole.EnvironmentIds.Count -eq 0)
        {
            Write-Information -MessageData "                Environments: All"
        }
        else
        {
            
            if (Get-Member -InputObject $environmentCache -Name $spaceId -MemberType Properties)
            {
                $environmentList = $environmentCache.$spaceId
            }
            else
            {
                $environmentList = Invoke-RestMethod -Method GET -Uri "$OctopusUrl/api/$spaceId/environments?skip=0&take=10000" -Headers $header 
                $environmentCache.$spaceId = $environmentList
            }

            Write-Information -MessageData "                Environments:"
            foreach ($environmentId in $scopedRole.EnvironmentIds)
            {
                $environment = $environmentList.Items | Where-Object -FilterScript {$_.Id -eq $environmentId}
                Write-Information -MessageData "                    $($environment.Name)"
            }
        }

        if ($scopedRole.ProjectIds.Count -eq 0)
        {
            Write-Information -MessageData "                Projects: All"
        }
        else
        {
            
            if (Get-Member -InputObject $projectCache -Name $spaceId -MemberType Properties)
            {
                $projectList = $projectCache.$spaceId
            }
            else
            {
                $projectList = Invoke-RestMethod -Method GET -Uri "$OctopusUrl/api/$spaceId/projects?skip=0&take=10000" -Headers $header 
                $projectCache.$spaceId = $projectList
            }

            Write-Information -MessageData "                Projects:"
            foreach ($projectId in $scopedRole.ProjectIds)
            {
                $project = $projectList.Items | Where-Object -FilterScript {$_.Id -eq $projectId}
                Write-Information -MessageData "                    $($project.Name)"
            }
        }

        if ($scopedRole.ProjectGroupIds.Count -eq 0)
        {
            Write-Information -MessageData "                Projects Groups: All"
        }
        else
        {
            
            if (Get-Member -InputObject $projectGroupCache -Name $spaceId -MemberType Properties)
            {
                $projectGroupList = $projectGroupCache.$spaceId
            }
            else
            {
                $projectGroupList = Invoke-RestMethod -Method GET -Uri "$OctopusUrl/api/$spaceId/projectgroups?skip=0&take=10000" -Headers $header 
                $projectGroupCache.$spaceId = $projectGroupList
            }

            Write-Information -MessageData "                Project Groups:"
            foreach ($projectGroupId in $scopedRole.ProjectGroupIds)
            {
                $projectGroup = $projectGroupList.Items | Where-Object -FilterScript {$_.Id -eq $projectGroupId}
                Write-Information -MessageData "                    $($projectGroup.Name)"
            }
        }

        if ($scopedRole.TenantIds.Count -eq 0)
        {
            Write-Information -MessageData "                Tenants: All"
        }
        else
        {
            
            if (Get-Member -InputObject $tenantCache -Name $spaceId -MemberType Properties)
            {
                $tenantList = $projectGroupCache.$spaceId
            }
            else
            {
                $tenantList = Invoke-RestMethod -Method GET -Uri "$OctopusUrl/api/$spaceId/tenants?skip=0&take=10000" -Headers $header 
                $tenantCache.$spaceId = $tenantList
            }

            Write-Information -MessageData "                Tenants:"
            foreach ($tenantId in $scopedRole.TenantIds)
            {
                $tenant = $tenantList.Items | Where-Object -FilterScript {$_.Id -eq $tenantId}
                Write-Information -MessageData "                    $($tenant.Name)"
            }
        }
        
    }
}
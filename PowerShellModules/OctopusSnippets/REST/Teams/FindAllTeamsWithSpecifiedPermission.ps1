<#
 =============================================================================
<copyright file="FindAllTeamsWithSpecifiedPermission.ps1" company="U.S. Office of Personnel
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
This file "FindAllTeamsWithSpecifiedPermission.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#
.SYNOPSIS
This script returns all teams in an Octopus Deploy Space that have roles with the "DeploymentCreate" permission, either scoped to a specified environment or unscoped (applying to all environments).
>The "DeploymentCreate" permission can be changed to any permission found on any of the User Role overview screens.
>The "Production" environment can be changed to any of the environments in your Space.

.PREREQUISITES
1. Replace "<API_KEY>" with your actual API key (this API key must be for an Administrator account)
2. Replace "https://<OCTOPUS_URL>" with your Octopus Server URL
3. Replace "<SPACE_ID>" with the correct Space ID (found in the URL)

.EXAMPLE OUTPUT
Teams using roles with the 'DeploymentCreate' permission scoped to 'Production' or unscoped:
Product team (Roles: Project deployer, Deployment creator)
Space Managers (Roles: Space manager)
#>

$apiKey = "<API_KEY>"
$octopusBaseUrl = "https://<OCTOPUS_URL>"
$spaceId = "<SPACE_ID>"     #i.e. - "Spaces-17"

$permission = "DeploymentCreate"
$environmentName = "Production"
$headers = @{ "X-Octopus-ApiKey" = $apiKey }

# Get Environment ID
$environmentsUri = "$octopusBaseUrl/api/$spaceId/environments"
$environments = Invoke-RestMethod -Method Get -Uri $environmentsUri -Headers $headers
$environmentId = $environments.Items | Where-Object -FilterScript { $_.Name -eq $environmentName } | Select-Object -ExpandProperty Id

if (-not $environmentId) {
    Write-Output "Environment '$environmentName' not found."
    exit
}

# Get user roles with the specified permission
$userRolesUri = "$octopusBaseUrl/api/userroles"
$userRoles = Invoke-RestMethod -Method Get -Uri $userRolesUri -Headers $headers
$rolesWithPermission = $userRoles.Items | Where-Object -FilterScript { $permission -in $_.GrantedSpacePermissions } | Select-Object -Property Id, Name

if ($rolesWithPermission.Count -eq 0) {
    Write-Output "No user roles found with the '$permission' permission."
    exit
}

$teamRolesMap = @{}

# Get all teams with that role(s) that are unscoped or scoped to the specified environment
$teamsUri = "$octopusBaseUrl/api/$spaceId/teams"
$teams = Invoke-RestMethod -Method Get -Uri $teamsUri -Headers $headers

foreach ($team in $teams.Items) {
    $teamRolesUri = "$octopusBaseUrl/api/$spaceId/teams/$($team.Id)/scopeduserroles"
    $teamRoles = Invoke-RestMethod -Method Get -Uri $teamRolesUri -Headers $headers
    
    foreach ($role in $teamRoles.Items) {
        $matchedRole = $rolesWithPermission | Where-Object -FilterScript { $_.Id -eq $role.UserRoleId }

        if ($matchedRole) {
            # Check if role is unscoped or scoped to the specified environment
            if (-not $role.EnvironmentIds -or $role.EnvironmentIds -contains $environmentId) {
                if (-not $teamRolesMap.ContainsKey($team.Name)) {
                    $teamRolesMap[$team.Name] = New-Object -TypeName System.Collections.ArrayList
                }
                # Prevent duplication of teams
                if (-not $teamRolesMap[$team.Name].Contains($matchedRole.Name)) {
                    $teamRolesMap[$team.Name].Add($matchedRole.Name) | Out-Null
                }
            }
        }
    }
}

# Output team names and corresponding roles per team
if ($teamRolesMap.Count -eq 0) {
    Write-Output "No teams found using roles with the '$permission' permission scoped to '$environmentName' or unscoped."
} else {
    Write-Output "Teams using roles with the '$permission' permission scoped to '$environmentName' or unscoped:"
    foreach ($teamName in $teamRolesMap.Keys) {
        $rolesList = $teamRolesMap[$teamName] -join ', '
        Write-Output "$teamName (Roles: $rolesList)"
    }
}

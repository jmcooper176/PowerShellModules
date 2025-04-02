<#
 =============================================================================
<copyright file="FindUsersWithUserRole.ps1" company="U.S. Office of Personnel
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
This file "FindUsersWithUserRole.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Define working variables
$octopusBaseURL = "https://youroctourl/api"
$octopusAPIKey = "API-YOURAPIKEY"
$headers = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

$roleName = "Project Deployer"
$spaceName = "" # Leave blank if you're using an older version of Octopus or you want to search all spaces

# Get the space id
$spaceId = ((Invoke-RestMethod -Method Get -Uri "$octopusBaseURL/spaces/all" -Headers $headers -ErrorVariable octoError) | Where-Object -FilterScript {$_.Name -eq $spaceName}).Id

# Get reference to role
$role = (Invoke-RestMethod -Method Get -Uri "$octopusBaseURL/userroles/all" -Headers $headers -ErrorVariable octoError) | Where-Object -FilterScript {$_.Name -eq $roleName}

# Get list of teams
$teams = (Invoke-RestMethod -Method Get -Uri "$octopusBaseURL/teams/all" -Headers $headers -ErrorVariable octoError)

# Loop through teams
foreach ($team in $teams)
{
    # Get the scoped user role
    $scopedUserRoles = Invoke-RestMethod -Method Get -Uri ("$octopusBaseURL/teams/$($team.Id)/scopeduserroles") -Headers $headers -ErrorVariable octoError
    
    # Loop through the scoped user roles
    foreach ($scopedUserRole in $scopedUserRoles)
    {
        # Check to see if space was specified
        if (![string]::IsNullOrEmpty($spaceId))
        {
            # Filter items by space
            $scopedUserRole.Items = $scopedUserRole.Items | Where-Object -FilterScript {$_.SpaceId -eq $spaceId}
        }

        # Check to see if the team has the role
        if ($null -ne ($scopedUserRole.Items | Where-Object -FilterScript {$_.UserRoleId -eq $role.Id}))
        {
            # Display team name
            Write-Output "Team: $($team.Name)"

            # check space id
            if ([string]::IsNullOrEmpty($spaceName))
            {
                # Get the space id
                $teamSpaceId = ($scopedUserRole.Items | Where-Object -FilterScript {$_.UserRoleId -eq $role.Id}).SpaceId

                # Get the space name
                $teamSpaceName = (Invoke-RestMethod -Method Get -Uri "$octopusBaseURL/spaces/$teamSpaceId" -Headers $headers -ErrorVariable octoError).Name

                # Display the space name
                Write-Output "Space: $teamSpaceName"
            }
            else
            {
                # Display the space name
                Write-Output "Space: $spaceName"
            }

            Write-Output "Users:"

            # Loop through members
            foreach ($userId in $team.MemberUserIds)
            {
                # Get user object
                $user = Invoke-RestMethod -Method Get -Uri ("$octopusBaseURL/users/$userId") -Headers $headers -ErrorVariable octoError
                
                # Display user
                Write-Output "$($user.DisplayName)"
            }

            # Check for external security groups
            if (($null -ne $team.ExternalSecurityGroups) -and ($team.ExternalSecurityGroups.Count -gt 0))
            {
                # External groups
                Write-Output "External security groups:"

                # Loop through groups
                foreach ($group in $team.ExternalSecurityGroups)
                {
                    # Display group
                    Write-Output "$($group.Id)"
                }
            }
        }
    }   
}
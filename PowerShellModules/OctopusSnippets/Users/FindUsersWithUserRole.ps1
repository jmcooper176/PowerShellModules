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

# Define working variables
$octopusBaseURL = "https://youroctourl/api"
$octopusAPIKey = "API-YOURAPIKEY"

# Load the Octopus.Client assembly from where you have it located.
Add-type -Path "C:\Octopus.Client\Octopus.Client.dll"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint($octopusBaseURL, $octopusAPIKey)
$repository = New-Object -TypeName Octopus.Client.OctopusRepository($endpoint)

$roleName = "Project Deployer"
$spaceName = ""

try
{
    $space = $repository.Spaces.FindByName($spaceName)

    # Get specific role
    $role = $repository.UserRoles.FindByName($roleName)

    # Get all the teams
    $teams = $repository.Teams.GetAll()

    # Loop through the teams
    foreach ($team in $teams)
    {
        # Get all associated user roles
        $scopedUserRoles = $repository.Teams.GetScopedUserRoles($team)

        # Check to see if there was a space defined
        if (![string]::IsNullOrEmpty($spaceName))
        {
            # Filter on space
            $scopedUserRoles = $scopedUserRoles | Where-Object -FilterScript {$_.SpaceId -eq $space.Id}
        }

        # Loop through the scoped user roles
        foreach ($scopedUserRole in $scopedUserRoles)
        {
            # Check role id
            if ($scopedUserRole.UserRoleId -eq $role.Id)
            {
                # Display the team name
                Write-Output "Team: $($team.Name)"

                # Display the space name
                Write-Output "Space: $($repository.Spaces.Get($scopedUserRole.SpaceId).Name)"

                Write-Output "Users:"

                # Loop through the members
                foreach ($member in $team.MemberUserIds)
                {
                    # Get the user account
                    $user = $repository.Users.GetAll() | Where-Object -FilterScript {$_.Id -eq $member}
                    
                    # Display
                    Write-Output "$($user.DisplayName)"
                }

                # Check to see if there were external groups
                if (($null -ne $team.ExternalSecurityGroups) -and ($team.ExternalSecurityGroups.Count -gt 0))
                {
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
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}
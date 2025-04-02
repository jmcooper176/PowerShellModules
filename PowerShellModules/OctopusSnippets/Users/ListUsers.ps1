<#
 =============================================================================
<copyright file="ListUsers.ps1" company="U.S. Office of Personnel
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
This file "ListUsers.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Load assembly
Add-Type -Path 'path:\to\Octopus.Client.dll'
# Define working variables
$octopusURL = "https://YourURL"
$octopusAPIKey = "API-YourAPIKey"

# Optional: include user role details?
$includeUserRoles = $true

# Optional: include non-active users in output
$includeNonActiveUsers = $False

# Optional: include AD details
$includeActiveDirectoryDetails = $False

# Optional: include AAD details
$includeAzureActiveDirectoryDetails = $True

# Optional: set a path to export to csv
$csvExportPath = "path:\to\users.csv"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint($octopusURL, $octopusAPIKey)
$repository = New-Object -TypeName Octopus.Client.OctopusRepository($endpoint)
$client = New-Object -TypeName Octopus.Client.OctopusClient($endpoint)

# Get users
$users = $repository.Users.GetAll()
$usersList = @()

# Check to see if we're filtering out inactive
if ($includeNonActiveUsers -eq $true)
{
    # Filter out inactive users
    Write-Information -MessageData "Filtering users who arent active from results"
    $users = $users | Where-Object -FilterScript {$_.IsActive -eq $True}
}


# Loop through users
foreach ($user in $users)
{
    # Populate user details
    $userDetails = [ordered]@{
        Id = $user.Id
        Username = $user.Username
        DisplayName = $user.DisplayName
        IsActive = $user.IsActive
        IsService = $user.IsService
        EmailAddress = $user.EmailAddress
    }


    # Check to see if we're including user roles
    if ($includeUserRoles -eq $true)
    {
        $userDetails.Add("ScopedUserRoles", "")
        # Get users teams
        $userTeamNames = $repository.UserTeams.Get($user)

        # Loop through the users teams
        foreach ($teamName in $userTeamNames)
        {
            # Get the team
            $team = $repository.Teams.Get($team.Id)
            
            foreach ($role in $repository.Teams.GetScopedUserRoles($team))
            {
                $userDetails["ScopedUserRoles"] += "$(($repository.UserRoles.Get($role.UserRoleId).Name)) ($(($repository.Spaces.Get($role.SpaceId)).Name))|"
            }
        }
    }

    if ($includeActiveDirectoryDetails -eq $true)
    {
        # Get the identity provider object
        $activeDirectoryIdentity = $user.Identities | Where-Object -FilterScript {$_.IdentityProviderName -eq "Active Directory"}
        if ($null -ne $activeDirectoryIdentity) 
        {
            $userDetails.Add("AD_Upn", (($activeDirectoryIdentity.Claims | ForEach-Object -Process {"$($_.upn.Value)"}) -Join "|"))
            $userDetails.Add("AD_Sam", (($activeDirectoryIdentity.Claims | ForEach-Object -Process {"$($_.sam.Value)"}) -Join "|"))
            $userDetails.Add("AD_Email", (($activeDirectoryIdentity.Claims | ForEach-Object -Process {"$($_.email.Value)"}) -Join "|"))
        }
    }
    
    if ($includeAzureActiveDirectoryDetails -eq $true)
    {
        $azureAdIdentity = $user.Identities | Where-Object -FilterScript {$_.IdentityProviderName -eq "Azure AD"}
        if ($null -ne $azureAdIdentity)
        {
            $userDetails.Add("AAD_Dn", (($azureAdIdentity.Claims | ForEach-Object -Process {"$($_.dn.Value)"}) -Join "|"))
            $userDetails.Add("AAD_Email", (($azureAdIdentity.Claims | ForEach-Object -Process {"$($_.email.Value)"}) -Join "|"))
        }
    }

    
    $usersList += $userDetails    
}

# Write header
$header = $usersList.Keys | Select-Object -Unique
Set-Content -Path $csvExportPath -Value ($header -join ",")

foreach ($user in $usersList)
{
    Add-Content -Path $csvExportPath -Value ($user.Values -join ",")
}

$usersList | Format-Table
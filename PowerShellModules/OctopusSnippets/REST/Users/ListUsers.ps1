<#
 =============================================================================
<copyright file="ListUsers.ps1" company="John Merryweather Cooper
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
This file "ListUsers.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Define working variables
$octopusURL = "https://your.octopus.app"
$octopusAPIKey = "API-YOURAPIKEY"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

# Optional: include user role details?
$includeUserRoles = $False

# Optional: include user team details?
$includeUserTeams = $False

# Optional: include non-active users in output
$includeNonActiveUsers = $False

# Optional: include AD details
$includeActiveDirectoryDetails = $False

# Optional: include AAD details
$includeAzureActiveDirectoryDetails = $False

# Optional: set a path to export to csv
$csvExportPath = ""

$users = @()
$usersList = @()
$response = $null
do {
    $uri = if ($response) { $octopusURL + $response.Links.'Page.Next' } else { "$octopusURL/api/users" }
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
    $usersList += $response.Items
} while ($response.Links.'Page.Next')

# Filter non-active users
if($includeNonActiveUsers -eq $False) {
    Write-Information -MessageData "Filtering users who arent active from results"
    $usersList = $usersList | Where-Object -FilterScript {$_.IsActive -eq $True}
}

# If we are including user roles or teams, need to get team details
if ($includeUserRoles -eq $True -or $includeUserTeams -eq $True) {
    $teams = @()
    $response = $null
    do {
        $uri = if ($response) { $octopusURL + $response.Links.'Page.Next' } else { "$octopusURL/api/teams" }
        $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
        $teams += $response.Items
    } while ($response.Links.'Page.Next')

    foreach($team in $teams) {
        $scopedUserRoles = Invoke-RestMethod -Method Get -Uri ("$octopusURL/api/teams/$($team.Id)/scopeduserroles") -Headers $header
        $team | Add-Member -MemberType NoteProperty -Name "ScopedUserRoles" -Value $scopedUserRoles.Items
    }

    $allUserRoles = @()
    $response = $null
    do {
        $uri = if ($response) { $octopusURL + $response.Links.'Page.Next' } else { "$octopusURL/api/userroles" }
        $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
        $allUserRoles += $response.Items
    } while ($response.Links.'Page.Next')

    $spaces = @()
    $response = $null
    do {
        $uri = if ($response) { $octopusURL + $response.Links.'Page.Next' } else { "$octopusURL/api/spaces" }
        $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
        $spaces += $response.Items
    } while ($response.Links.'Page.Next')
}

foreach($userRecord in $usersList) {
    $usersRoles = @()

    $user = [PSCustomObject]@{
        Id = $userRecord.Id
        Username = $userRecord.Username
        DisplayName = $userRecord.DisplayName
        IsActive = $userRecord.IsActive
        IsService = $userRecord.IsService
        EmailAddress = $userRecord.EmailAddress
    }
    if($includeActiveDirectoryDetails -eq $True)
    {
        $user | Add-Member -MemberType NoteProperty -Name "AD_Upn" -Value $null
        $user | Add-Member -MemberType NoteProperty -Name "AD_Sam" -Value $null
        $user | Add-Member -MemberType NoteProperty -Name "AD_Email" -Value $null
    }
    if($includeAzureActiveDirectoryDetails -eq $True)
    {
        $user | Add-Member -MemberType NoteProperty -Name "AAD_DN" -Value $null
        $user | Add-Member -MemberType NoteProperty -Name "AAD_Email" -Value $null
    }

    $usersTeams = $teams | Where-Object -FilterScript { $_.MemberUserIds -icontains $user.Id }

    if ($includeUserTeams -eq $True) {
        foreach ($userTeam in $usersTeams) {
            $associatedTeams += "$($userTeam.Name)"

            if($userTeam -ne ($usersTeams | Select-Object -Last 1)) { $associatedTeams += "|" }
        }
        $user | Add-Member -MemberType NoteProperty -Name "UserTeams" -Value ($associatedTeams -Join "|")
        $associatedTeams = ""
    }

    if($includeUserRoles -eq $True) {
        foreach($userTeam in $usersTeams) {
            $roles = $userTeam.ScopedUserRoles
            foreach($role in $roles) {
                $userRole = $allUserRoles | Where-Object -FilterScript {$_.Id -eq $role.UserRoleId} | Select-Object -First 1
                $roleName = "$($userRole.Name)"
                $roleSpace = $spaces | Where-Object -FilterScript {$_.Id -eq $role.SpaceId} | Select-Object -First 1
                if (![string]::IsNullOrWhiteSpace($roleSpace)) {
                    $roleName += " ($($roleSpace.Name))"
                }
                $usersRoles+= $roleName
            }
        }
        $user | Add-Member -MemberType NoteProperty -Name "ScopedUserRoles" -Value ($usersRoles -Join "|")
    }

    if($userRecord.Identities.Count -gt 0) {
        if($includeActiveDirectoryDetails -eq $True)
        {
            $activeDirectoryIdentity = $userRecord.Identities | Where-Object -FilterScript {$_.IdentityProviderName -eq "Active Directory"} | Select-Object -ExpandProperty Claims
            if($null -ne $activeDirectoryIdentity) {
                $user.AD_Upn = (($activeDirectoryIdentity | ForEach-Object -Process {"$($_.upn.Value)"}) -Join "|")
                $user.AD_Sam = (($activeDirectoryIdentity | ForEach-Object -Process {"$($_.sam.Value)"}) -Join "|")
                $user.AD_Email = (($activeDirectoryIdentity | ForEach-Object -Process {"$($_.email.Value)"}) -Join "|")
            }
        }
        if($includeAzureActiveDirectoryDetails -eq $True)
        {
            $azureAdIdentity = $userRecord.Identities | Where-Object -FilterScript {$_.IdentityProviderName -eq "Azure AD"} | Select-Object -ExpandProperty Claims
            if($null -ne $azureAdIdentity) {
                $user.AAD_Dn = (($azureAdIdentity | ForEach-Object -Process {"$($_.dn.Value)"}) -Join "|")
                $user.AAD_Email = (($azureAdIdentity | ForEach-Object -Process {"$($_.email.Value)"}) -Join "|")
            }
        }
    }
    $users+=$user
}

if (![string]::IsNullOrWhiteSpace($csvExportPath)) {
    Write-Information -MessageData "Exporting results to CSV file: $csvExportPath"
    $users | Export-Csv -Path $csvExportPath -NoTypeInformation
}

$users | Format-Table

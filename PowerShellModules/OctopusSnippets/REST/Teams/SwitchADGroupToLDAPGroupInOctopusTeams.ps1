<#
 =============================================================================
<copyright file="SwitchADGroupToLDAPGroupInOctopusTeams.ps1" company="John Merryweather Cooper
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
This file "SwitchADGroupToLDAPGroupInOctopusTeams.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop"

$octopusURL = "https://your.octopus.app" # Replace with your instance URL
$octopusAPIKey = "API-YOURKEY" # Replace with a service account API Key
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

# Script options

# Provide the domain. This is needed to look up the group to ensure it's a valid AD Group we're working on.
$AD_Domain = "YOURDOMAIN"
# Set this to $False if you want the Script to perform the update on Octopus Teams.
$WhatIf = $True
# Set this to $True if you want the Script to remove old Active Directory teams once the LDAP group has been found and added.
$RemoveOldTeams = $False

# Limit how may teams are retrieved/updated. 
# Use these two variables to work through if you have hundreds of teams.
$skipIndex = 0
$recordsToBringBack = 30

# Get teams
Write-Information -MessageData "Pulling teams starting at index $skipIndex and getting a max of $recordsToBringBack records back"
$teamList = Invoke-RestMethod -Method GET -Uri "$OctopusUrl/api/teams?skip=$skipIndex&take=$recordsToBringBack" -Headers $header
$teams = $teamList.Items

$ldapRecordsToAdd = @()
$activeDirectoryRecordsToRemove = @()
$recordsUpdated = 0

foreach ($team in $teams) {
    try {
        Write-Information -MessageData "Working on team: '$($team.Name)'$(if (![string]::IsNullOrWhiteSpace($team.SpaceId)) {" from Space '$($team.SpaceId)'"})" 
    
        $teamExternalGroups = $team.ExternalSecurityGroups

        if ($teamExternalGroups.Count -eq 0) {
            Write-Verbose -Message "Team: '$($team.Name)' doesnt have any external groups, skipping"
            continue 
        }
        else {
            foreach ($externalSecurityGroup in $team.ExternalSecurityGroups) {
                $externalName = $externalSecurityGroup.DisplayName            
                if ($null -eq $externalName) {
                    continue
                }
                else {
                    # Check if this external group is an AD group
                    $ad_TeamNameToFind = "$AD_Domain\$externalName"
                    $directoryServicesResults = Invoke-RestMethod -Method GET -Uri "$octopusURL/api/externalgroups/directoryServices?partialName=$([System.Web.HTTPUtility]::UrlEncode($ad_TeamNameToFind))" -Headers $header
                    $matchFound = $False
                    foreach ($adResult in $directoryServicesResults) {
                        if ($adResult.DisplayName -eq $externalName -and $adResult.Id -eq $externalSecurityGroup.Id) {
                            Write-Information -MessageData "Found a matching team name in AD for '$($team.Name)' that matches the SID $($externalSecurityGroup.Id)." -ForegroundColor Green
                            $matchFound = $true
                            break;
                        }
                    }

                    # Next, check to see if to find a matching group in LDAP
                    if ($matchFound -eq $True) {
                        $ldapTeamNameToFind = "$externalName"
                
                        $ldapResults = Invoke-RestMethod -Method GET -Uri "$octopusURL/api/externalgroups/ldap?partialName=$([System.Web.HTTPUtility]::UrlEncode($ldapTeamNameToFind))" -Headers $header
                        foreach ($ldapResult in $ldapResults) {
                            if ($ldapResult.DisplayName -eq $externalName) {
                                Write-Information -MessageData "Found a matching team name in LDAP for '$($team.Name)'." -ForegroundColor Green
                                $ldapMatchFound = $true
                                break;
                            }
                        }
                        $foundExistingMatch = $False
                        if ($ldapMatchFound -eq $True) {
                            # Does the Octopus team already have this LDAP Group?
                            foreach ($group in $team.ExternalSecurityGroups) {                        
                                if ($group.Id -eq $ldapResult.Id) {
                                    $foundExistingMatch = $true
                                    break
                                }
                            }

                            if ($foundExistingMatch -eq $false) {
                                $ldapRecordsToAdd += $ldapResult
                            }
                            else {
                                Write-Information -MessageData "The LDAP group already existed on team '$($team.Name)'."
                            }
                            
                            if ($RemoveOldTeams -eq $True) {
                                Write-Information -MessageData "Existing AD Group with SID $($externalSecurityGroup.Id) in team '$($team.Name)' will be marked to be removed"
                                $activeDirectoryRecordsToRemove += $adResult.Id
                            }
                        }
                    }
                }
            }

            if ($ldapRecordsToAdd.Length -gt 0) {
                foreach ($teamToAdd in $ldapRecordsToAdd) {
                    $team.ExternalSecurityGroups += $teamToAdd
                }
            }

            if ($RemoveOldTeams -eq $True -and $activeDirectoryRecordsToRemove.Length -gt 0) {
                $externalGroups = @()
                foreach ($group in $team.ExternalSecurityGroups) {
                    if ($activeDirectoryRecordsToRemove -contains $group.Id) {
                        Write-Verbose -Message "Removing AD group with SID $($group.Id)"
                        continue
                    }
                    else {
                        $externalGroups += $group
                    }
                }
                Write-Information -MessageData "Filtered external groups from $($team.ExternalSecurityGroups.Length) to $($externalGroups.Length)"
                $team.ExternalSecurityGroups = $externalGroups
            }
             
            if ($ldapRecordsToAdd.Length -gt 0 -or ($RemoveOldTeams -eq $True -and $activeDirectoryRecordsToRemove.Length -gt 0)) {
                $TeamUpdateUri = "$OctopusUrl/api/teams/$($team.Id)"
                $TeamBody = $($team | ConvertTo-Json -Depth 10 -Compress)

                if ($WhatIf -eq $True) {
                    Write-Information -MessageData "WhatIf = True. Update for team '$($Team.Name)' would have been:" 
                    Write-Information -MessageData "$($TeamBody)"
                }
                else {
                    Write-Information -MessageData "Updating team '$($Team.Name)' in Octopus Deploy"
                    Invoke-RestMethod -Method PUT -Uri $TeamUpdateUri -Headers $header -Body $teamBody | Out-Null
                }
                
                $recordsUpdated += 1
            }
        }
    }
    catch {
        Write-Error -Message "An error occurred with Team: $($team.Name) - $($_.Exception.ToString())" -ErrorAction Continue
        $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
    }
}

Write-Information -MessageData "Updated $recordsUpdated team(s)."
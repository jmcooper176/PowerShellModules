<#
 =============================================================================
<copyright file="AddDomainTeamToOctopusTeam.ps1" company="John Merryweather Cooper
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
This file "AddDomainTeamToOctopusTeam.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop"

$octopusURL = "https://yoururl.com" # Replace with your instance URL
$octopusAPIKey = "YOUR API KEY" # Replace with a service account API Key
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }
$maxRecordsToUpdate = 2 # The max number of records you want to update in this batch

$newDomainToLookup = "Work" # Change this to the new domain

$skipIndex = 0
$recordsToBringBack = 30
$recordsUpdated = 0

while (1 -eq 1) #Continue until we reach the end of the user list or until we go over the max records to update
{
    Write-Information -MessageData "Pulling teams starting at index $skipIndex and getting a max of $recordsToBringBack records back"
    $teamList = Invoke-RestMethod -Method GET -Uri "$OctopusUrl/api/teams?skip=$skipIndex&take=$recordsToBringBack" -Headers $header
    #Update to pull back the next batch of users
    $skipIndex = $skipIndex + $recordsToBringBack

    if ($teamList.Items.Count -eq 0)
    {
        break
    }

    foreach ($team in $teamList.Items)
    {
        if ($team.ExternalSecurityGroups.Count -eq 0)
        {
            # Skip teams which don't have an external AD group
            continue 
        }

        Write-Information -MessageData "Checking to see if $($team.Name) is tied to an external active directory team."
        $activeDirectoryRecordsToAdd = @()

        foreach ($externalSecurityGroup in $team.ExternalSecurityGroups)
        {
            $externalName = $externalSecurityGroup.DisplayName            
            if ($null -eq $externalName)
            {
                continue
            }

            $teamNameToFind = "$newDomainToLookup\$externalName"
            $directoryServicesResults = Invoke-RestMethod -Method GET -Uri "$octopusURL/api/externalgroups/directoryServices?partialName=$([System.Web.HTTPUtility]::UrlEncode($teamNameToFind))" -Headers $header

            foreach ($result in $directoryServicesResults)
            {
                if ($result.DisplayName -eq $externalName)
                {
                    Write-Information -MessageData "Found a matching team name, checking if the SID is already assigned to the team"
                    $foundMatch = $false
                    foreach ($group in $team.ExternalSecurityGroups)
                    {                        
                        if ($group.Id -eq $result.Id)
                        {
                            $foundMatch = $true
                            break
                        }
                    }

                    if ($foundMatch -eq $false)
                    {
                        $activeDirectoryRecordsToAdd += $result
                    }
                    else
                    {
                        Write-Information -MessageData "The active directory group already existed on the team"
                    }

                    break
                }
            }
        }
        
        if ($activeDirectoryRecordsToAdd.Length -gt 0)
        {
            foreach ($teamToAdd in $activeDirectoryRecordsToAdd)
            {
                $team.ExternalSecurityGroups += $teamToAdd
            }

            Write-Information -MessageData "Updating the team $($Team.Name) in Octopus Deploy"
            Invoke-RestMethod -Method PUT -Uri "$OctopusUrl/api/teams/$($team.Id)" -Headers $header -Body $($team | ConvertTo-Json -Depth 10)
            $recordsUpdated += 1
        }
        
    }

    if ($recordsUpdated -ge $maxRecordsToUpdate)
    {
        Write-Information -MessageData "Reached the maximum number of records to update, stopping"
        break
    }
}
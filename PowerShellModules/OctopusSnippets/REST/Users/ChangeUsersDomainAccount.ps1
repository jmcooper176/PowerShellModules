<#
 =============================================================================
<copyright file="ChangeUsersDomainAccount.ps1" company="U.S. Office of Personnel
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
This file "ChangeUsersDomainAccount.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop"

$octopusURL = "https://yoururl.com" # Replace with your instance URL
$octopusAPIKey = "YOUR API KEY" # Replace with a service account API Key
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }
$maxRecordsToUpdate = 2 # The max number of records you want to update in this batch

$oldDomainToLookFor = "Home" # Change this to the old domain
$newDomainToLookup = "Work" # Change this to the new domain

$skipIndex = 0
$recordsToBringBack = 30
$recordsUpdated = 0

while (1 -eq 1) #Continue until we reach the end of the user list or until we go over the max records to update
{
    Write-Information -MessageData "Pulling users starting at index $skipIndex and getting a max of $recordsToBringBack records back"
    $userList = Invoke-RestMethod -Method GET -Uri "$OctopusUrl/api/users?skip=$skipIndex&take=$recordsToBringBack" -Headers $header
    #Update to pull back the next batch of users
    $skipIndex = $skipIndex + $recordsToBringBack

    if ($userList.Items.Count -eq 0)
    {
        break
    }

    foreach ($user in $userList.Items)
    {
        if ($user.IsService -eq $true -or $user.Identities.Count -eq 0)
        {
            # Skip Octopus Deploy Service Accounts or users not tied to an active directory account
            continue 
        }

        Write-Information -MessageData "Checking to see if $($user.UserName) has an active directory account."
        $replaceActiveDirectoryRecord = $false

        for ($i = 0; $i -lt $user.Identities.Count; $i++)
        {            
            if ($user.Identities[$i].IdentityProviderName -ne "Active Directory")
            {
                # We only care about active directory stuff
                continue
            }

            Write-Information -MessageData "$($user.UserName) has an active directory account, pulling out the domain name."

            $claimList = $user.Identities[$i].Claims | Get-Member | Where-Object -FilterScript {$_.MemberType -eq "NoteProperty"} | Select-Object -Property "Name"
            foreach ($claimName in $claimList)
            {
                $nameValue = $claimName.Name
                $claim = $user.Identities[$i].Claims.$nameValue
                                
                if ($claim.Value.ToLower().Contains($oldDomainToLookFor.ToLower()))
                {
                    Write-Information -MessageData "The claim $nameValue for $($user.UserName) has the value $($claim.Value) which matches $oldDomainToLookFor.  Updating this account."

                    ## This would be a good place to add additional AD lookup logic

                    $replaceActiveDirectoryRecord = $true
                    break
                }
            }

            if ($replaceActiveDirectoryRecord -eq $true)
            {
                break
            }
        }        

        if ($replaceActiveDirectoryRecord -eq $true)
        { 
            # This user record needs to be updated, clone the user object so we can manipulate it (and so we have the original)
            $userRecordToUpdate = $user | ConvertTo-Json -Depth 10 | ConvertFrom-Json
            # Grab any records that are not active directory
            $filteredOldRecords = $user.Identities | Where-Object -FilterScript {$_.IdentityProviderName -ne "Active Directory"}
            if ($null -ne $filteredOldRecords)
            {
                $userRecordToUpdate.Identities = @($filteredOldRecords)    
            }
            else
            {
                $userRecordToUpdate.Identities = @()    
            }
                        
            # Now let's find the new domain account
            $userNameToLookUp = "$newDomainToLookup\$($userRecordToUpdate.Username)"
            $expectedMatch = "$($userRecordToUpdate.Username)@$newDomainToLookUp.local"
            $foundUser = $false
            Write-Information -MessageData "Looking up the new domain account $userNameToLookup in Octopus Deploy"
            $directoryServicesResults = Invoke-RestMethod -Method GET -Uri "$octopusURL/api/externalusers/directoryServices?partialName=$([System.Web.HTTPUtility]::UrlEncode($userNameToLookUp))" -Headers $header
            
            foreach ($identity in $directoryServicesResults.Identities)
            {
                if ($identity.IdentityProviderName -eq "Active Directory")
                {
                    $claimList = $identity.Claims | Get-Member | Where-Object -FilterScript {$_.MemberType -eq "NoteProperty"} | Select-Object -Property "Name"

                    foreach ($claimName in $claimList)
                    {                  
                        $claimName = $claimName.Name
                        $claim = $identity.Claims.$ClaimName
                        
                        if ($claim.Value.ToLower() -eq $expectedMatch.Tolower() -and $claim.IsIdentifyingClaim -eq $true)
                        {
                            Write-Information -MessageData "Found the user's new domain record, add that to Octopus Deploy"
                            $userRecordToUpdate.Identities += $identity
                            $foundUser = $true
                            break
                        }
                    }

                    if ($foundUser)
                    {
                        break
                    }
                }                
            }

            if ($foundUser -eq $true)
            {
                Write-Information -MessageData "Updating the user $($UserRecordToUpdate.UserName) in Octopus Deploy"
                Invoke-RestMethod -Method PUT -Uri "$OctopusUrl/api/users/$($userRecordToUpdate.Id)" -Headers $header -Body $($userRecordToUpdate | ConvertTo-Json -Depth 10)
                $recordsUpdated += 1
            }

        }        
    }

    if ($recordsUpdated -ge $maxRecordsToUpdate)
    {
        Write-Information -MessageData "Reached the maximum number of records to update, stopping"
        break
    }
}
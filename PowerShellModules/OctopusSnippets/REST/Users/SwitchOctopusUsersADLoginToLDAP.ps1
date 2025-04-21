<#
 =============================================================================
<copyright file="SwitchOctopusUsersADLoginToLDAP.ps1" company="John Merryweather Cooper
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
This file "SwitchOctopusUsersADLoginToLDAP.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# This script demonstrates how to programmatically swap an Octopus user's Active Directory login record for a matching LDAP one.
# This can be useful when you are migrating from the Active Directory authentication provider to the LDAP provider.
#
# NOTE: The script won't work if the LDAP server and the AD Server domains are different
#       e.g. from "domain-one.local" to "domain-two.local"

$ErrorActionPreference = "Stop"

$octopusURL = "https://your.octopus.app" # Replace with your instance URL
$octopusAPIKey = "API-YOURKEY" # Replace with a service account API Key
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

# The max number of records you want to update in this batch
$maxRecordsToUpdate = 1

# Provide the domain. This is needed to find the user AD identity (to potentially remove)
$AD_Domain = "your-ad-domain.com"

# Provide the domain for LDAP. Typically this is the same as the AD_Domain value.
$LDAP_Domain = "your-ldap-domain.com"

# If set to $True  -> the script will search for a matching user in LDAP using the format: username@$LDAP_Domain
# If set to $False -> the script will search for a matching user in LDAP using the format: username
$LDAP_UsernameLookup_IncludeDomain = $True

# Set this to $False if you want the Script to perform the update on Octopus Users.
$WhatIf = $True

# Set this to $True if you want the Script to remove old Active Directory records once the LDAP user has been found and added.
$RemoveActiveDirectoryRecords = $False

$skipIndex = 0
$recordsToBringBack = 30
$recordsUpdated = 0

# Continue until we reach the end of the user list or until we go over the max records to update
while ($True) {
    try {
        Write-Information -MessageData "Pulling users starting at index $skipIndex and getting a max of $recordsToBringBack records back"
        $userList = Invoke-RestMethod -Method GET -Uri "$OctopusUrl/api/users?skip=$skipIndex&take=$recordsToBringBack" -Headers $header

        # Update to pull back the next batch of users
        $skipIndex = $skipIndex + $recordsToBringBack

        if ($userList.Items.Count -eq 0) {
            break;
        }

        foreach ($user in $userList.Items) {
            if ($user.IsService -eq $true -or $user.Identities.Count -eq 0) {
                # Skip Octopus Deploy Service Accounts or users not tied to an active directory account
                continue;
            }

            Write-Information -MessageData "Checking to see if $($user.UserName) has an active directory account."
            $foundActiveDirectoryRecordForUser = $false

            for ($i = 0; $i -lt $user.Identities.Count; $i++) {
                if ($user.Identities[$i].IdentityProviderName -ne "Active Directory") {
                    # We only care about active directory records.
                    continue;
                }

                Write-Information -MessageData "$($user.UserName) has an active directory account, pulling out the domain name."

                $claimList = $user.Identities[$i].Claims | Get-Member | Where-Object -FilterScript { $_.MemberType -eq "NoteProperty" } | Select-Object -Property "Name"
                foreach ($claimName in $claimList) {
                    $nameValue = $claimName.Name
                    $claim = $user.Identities[$i].Claims.$nameValue

                    if ($claim.Value.ToLower().Contains($AD_Domain.ToLower())) {
                        Write-Information -MessageData "The claim $nameValue for $($user.UserName) has the value $($claim.Value) which matches $AD_Domain.  Updating this account."

                        $foundActiveDirectoryRecordForUser = $true
                        break;
                    }
                }

                if ($foundActiveDirectoryRecordForUser -eq $true) {
                    break;
                }
            }

            if ($foundActiveDirectoryRecordForUser -eq $true) {
                # This user record potentially needs to be updated, clone the user object so we can manipulate it (and so we have the original)
                $userRecordToUpdate = $user | ConvertTo-Json -Depth 10 | ConvertFrom-Json

                if ($RemoveActiveDirectoryRecords -eq $True) {
                    # Grab any records that are not active directory
                    $filteredOldRecords = $user.Identities | Where-Object -FilterScript { $_.IdentityProviderName -ne "Active Directory" }
                    if ($null -ne $filteredOldRecords) {
                        $userRecordToUpdate.Identities = @($filteredOldRecords)
                    }
                    else {
                        $userRecordToUpdate.Identities = @()
                    }
                }

                # Let's attempt to find a matching LDAP account
                $userNameToLookUp = "$($userRecordToUpdate.Username)"
                if ($userRecordToUpdate.Username -like "*@*") {
                    $userNameToLookUp = ($userRecordToUpdate.Username -Split "@")[0]
                }
                elseif ($userRecordToUpdate.Username -like "*`\*") {
                    $userNameToLookUp = ($userRecordToUpdate.Username -Split "\\")[1]
                }

                $expectedMatch = "$userNameToLookUp"
                If ($LDAP_UsernameLookup_IncludeDomain -eq $True) {
                    $expectedMatch = "$($userNameToLookUp)@$($LDAP_Domain)"
                }

                $ldapMatchFound = $False

                Write-Information -MessageData "Looking up the LDAP account $userNameToLookup in Octopus Deploy"
                $ldapResults = Invoke-RestMethod -Method GET -Uri "$octopusURL/api/externalusers/ldap?partialName=$([System.Web.HTTPUtility]::UrlEncode($userNameToLookUp))" -Headers $header

                $LdapIdentity = $null
                # Search LDAP Identities
                foreach ($identity in $ldapResults.Identities) {
                    if ($identity.IdentityProviderName -eq "LDAP") {
                        $claimList = $identity.Claims | Get-Member | Where-Object -FilterScript { $_.MemberType -eq "NoteProperty" } | Select-Object -Property "Name"

                        foreach ($claimName in $claimList) {
                            $claimName = $claimName.Name
                            $claim = $identity.Claims.$ClaimName

                            if ($null -ne $claim.Value -and $claim.Value.ToLower() -eq $expectedMatch.Tolower() -and $claim.IsIdentifyingClaim -eq $true) {
                                Write-Information -MessageData "Found the user's LDAP record, add that to Octopus Deploy"
                                $LdapIdentity = $identity
                                $ldapMatchFound = $true
                                break;
                            }
                        }

                        if ($ldapMatchFound) {
                            break;
                        }
                    }
                }

                $foundExistingUserLdapMatch = $False
                if ($ldapMatchFound -eq $True) {
                    # Check existing user identities for a matching LDAP already being present.
                    for ($i = 0; $i -lt $user.Identities.Count; $i++) {
                        if ($user.Identities[$i].IdentityProviderName -ieq "LDAP") {
                            $claimList = $user.Identities[$i].Claims | Get-Member | Where-Object -FilterScript { $_.MemberType -eq "NoteProperty" } | Select-Object -Property "Name"
                            foreach ($claimName in $claimList) {
                                $nameValue = $claimName.Name
                                $claim = $user.Identities[$i].Claims.$nameValue

                                if ($null -ne $claim.Value -and $claim.Value.ToLower().Contains($LDAP_Domain.ToLower())) {
                                    $foundExistingUserLdapMatch = $true
                                    break;
                                }
                            }
                        }

                        if ($foundExistingUserLdapMatch -eq $True) {
                            break;
                        }
                    }

                    if ($foundExistingUserLdapMatch -eq $false) {
                        $userRecordToUpdate.Identities += $LdapIdentity
                    }
                    else {
                        Write-Information -MessageData "Ans LDAP identity already exists on user '$($user.Username)'."
                    }
                }

                $removalAdUpdateRequired = $foundActiveDirectoryRecordForUser -eq $True -and $RemoveActiveDirectoryRecords -eq $True
                $newLdapUpdateRequired = $ldapMatchFound -eq $True -and $foundExistingUserLdapMatch -eq $false
                if ($removalAdUpdateRequired -eq $True -or $newLdapUpdateRequired) {
                    $userUpdateUri = "$OctopusUrl/api/users/$($userRecordToUpdate.Id)"
                    $UserBody = $($userRecordToUpdate | ConvertTo-Json -Depth 10 -Compress)

                    if ($WhatIf -eq $True) {
                        Write-Information -MessageData "WhatIf = True. Update for user '$($userRecordToUpdate.Username)' would have been:"
                        Write-Information -MessageData "$($UserBody)"
                    }
                    else {
                        Write-Information -MessageData "Updating user '$($userRecordToUpdate.Username)' in Octopus Deploy"
                        Invoke-RestMethod -Method PUT -Uri $userUpdateUri -Headers $header -Body $UserBody | Out-Null
                    }
                    $recordsUpdated += 1
                }
                else {
                    Write-Information -MessageData "No update for user '$($userRecordToUpdate.Username)' is required, skipping."
                }

                if ($recordsUpdated -ge $maxRecordsToUpdate) {
                    break
                }
            }
        }

        if ($recordsUpdated -ge $maxRecordsToUpdate) {
            Write-Information -MessageData "Reached the maximum number of records to update, stopping"
            break
        }
    }
    catch {
        Write-Error -Message "An error occurred with user: $($user.Username) - $($_.Exception.ToString())" -ErrorAction Continue
        $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
    }
}

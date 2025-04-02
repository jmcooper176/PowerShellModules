<#
 =============================================================================
<copyright file="AddAzureActiveDirectoryLoginToUsers.ps1" company="U.S. Office of Personnel
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
This file "AddAzureActiveDirectoryLoginToUsers.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#
.Synopsis
   Adds Azure Active Directory login identities to existing Octopus users
.DESCRIPTION
   Migrating to using Azure Active Directory to login to Octopus brings advantages. However, if you are already using AD domain login, and you are synchronizing email addresses to AAD using ADFS - new users will be created in Octopus where a match can't be found.
   It's helpful to be able to add those Azure AD login identities to Octopus in one hit to avoid new users (with limited permissions) from being created.
   This script does this by either:
    - looping over a provided CSV file or
    - a supplied username and email address
   It checks for an existing AAD login, and it will either replace it (if Force = $true) or create a new identity.
   You can optionally update the Display name and email address for the matching octopus user.

.EXAMPLE
    OctopusUsername, AzureEmailAddress, AzureDisplayName
    OctoUser, octouser@exampledomain.com, Octo User
.EXAMPLE
   AddAzureADLogins -OctopusURL "https://your.octopus.app/" -OctopusAPIKey "API-KEY" -OctopusUsername "OctoUser" -AzureEmailAddress "octouser@exampledomain.com" -AzureDisplayName "Octo User" -ContinueOnError $False -Force $False -WhatIf $False -DebugLogging $False
.EXAMPLE
   AddAzureADLogins -OctopusURL "https://your.octopus.app/" -OctopusAPIKey "API-KEY" -Path "/path/to/user_azure_ad_logins.csv" -ContinueOnError $False -Force $False -WhatIf $False -DebugLogging $False
#>
function AddAzureADLogins {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param (
        [Parameter(Mandatory)]
        [String]
        $OctopusURL,

        [Parameter(Mandatory)]
        [String]
        $OctopusAPIKey,

        [String]
        $Path,

        [String]
        $OctopusUsername,

        [String]
        $AzureEmailAddress,

        [String]
        $AzureDisplayName = $null,

        [switch]
        $UpdateOctopusEmailAddress,

        [switch]
        $UpdateOctopusDisplayName,

        [switch]
        $ContinueOnError,

        [switch]
        $Force,

        [switch]
        $DebugLogging
    )

    if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
        $ConfirmPreference = 'None'
    }

    Write-Information -MessageData "OctopusURL: $OctopusURL"
    Write-Information -MessageData "OctopusAPIKey: ********"
    Write-Information -MessageData "Path: $Path"
    Write-Information -MessageData "OctopusUsername: $OctopusUsername"
    Write-Information -MessageData "AzureEmailAddress: $AzureEmailAddress"
    Write-Information -MessageData "AzureDisplayName: $AzureDisplayName"
    Write-Information -MessageData "UpdateOctopusEmailAddress: $UpdateOctopusEmailAddress"
    Write-Information -MessageData "UpdateOctopusDisplayName: $UpdateOctopusDisplayName"
    Write-Information -MessageData "ContinueOnError: $ContinueOnError"
    Write-Information -MessageData "Force: $Force"
    Write-Information -MessageData "WhatIf: $WhatIf"
    Write-Information -MessageData "DebugLogging: $DebugLogging"
    Write-Information -MessageData $("=" * 60)
    Write-Information -MessageData

    if (-not [string]::IsNullOrWhiteSpace($OctopusURL)) {
        $OctopusURL = $OctopusURL.TrimEnd('/')
    }

    if ($DebugLogging -eq $True) {
        $DebugPreference = "Continue"
    }

    $header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }
    $usersToUpdate = @()
    $recordsUpdated = 0
    # Validate we have minimum required details.
    if ([string]::IsNullOrWhiteSpace($Path) -eq $true) {
        if ([string]::IsNullOrWhiteSpace($OctopusUsername) -eq $true -or [string]::IsNullOrWhiteSpace($AzureEmailAddress) -eq $true) {
            Write-Warning -Message "Path not supplied. OctopusUsername or AzureEmailAddress are either null, or an empty string."
            return
        }
        $usersToUpdate += [PSCustomObject]@{
            OctopusUsername   = $OctopusUsername
            AzureEmailAddress = $AzureEmailAddress
            AzureDisplayName  = $AzureDisplayName
        }
    }
    else {
        # Validate path
        if (-not (Test-Path $Path)) {
            Write-Warning -Message "Path '$Path' not found. Does a file exist at that location?"
            return
        }

        $usersToUpdate = Import-Csv -Path $Path -Delimiter ","
    }

    # Check if we have any users. If we do, get existing octopus users
    if ($usersToUpdate.Count -gt 0) {
        Write-Information -MessageData "Users to update: $($usersToUpdate.Count)"
        $ExistingOctopusUsers = @()
        $response = $null
        do {
            $uri = if ($response) { $octopusURL + $response.Links.'Page.Next' } else { "$OctopusURL/api/users" }
            if ($PSCmdlet.ShouldProcess($uri, $CmdletName)) {
                $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
                return
            }
            $ExistingOctopusUsers += $response.Items
        } while ($response.Links.'Page.Next')

        Write-Debug -Message "Found $($ExistingOctopusUsers.Count) existing Octopus users"
    }
    else {
        Write-Information -MessageData "No users to update, exiting."
        return
    }

    if ($ExistingOctopusUsers.Count -le 0) {
        Write-Warning -Message "No users found in Octopus, exiting."
        return
    }

    foreach ($user in $usersToUpdate) {
        Write-Information -MessageData "Working on user $($User.OctopusUsername)"
        try {
            $existingOctopusUser = $ExistingOctopusUsers | Where-Object -FilterScript { $_.Username -eq $user.OctopusUsername } | Select-Object -First 1
            if ($null -ne $ExistingOctopusUser) {
                Write-Debug -Message "Found matching octopus user for $($user.OctopusUsername)"
                # Check if its a service account
                if ($user.IsService -eq $True) {
                    Write-Debug -Message "User $($user.OctopusUsername) is a Service account. This user won't be updated..."
                    continue
                }
                # Check if its an active account
                if ($user.IsActive -eq $False) {
                    Write-Debug -Message "User $($user.OctopusUsername) is an inactive account. This user won't be updated..."
                    continue
                }

                # Check for existing Azure AD Identity first.
                $azureAdIdentity = $existingOctopusUser.Identities | Where-Object -FilterScript { $_.IdentityProviderName -eq "Azure AD" } | Select-Object -First 1
                if ($null -ne $azureAdIdentity) {
                    Write-Debug -Message "Found existing AzureAD login for user $($user.OctopusUsername)"
                    if ($Force -eq $True) {
                        Write-Debug -Message "Force set to true. Replacing existing AzureAD Claims for Display Name and Email for user $($user.OctopusUsername)"
                        $azureAdIdentity.Claims.email.Value = $User.AzureEmailAddress
                        $azureAdIdentity.Claims.dn.Value = $User.AzureDisplayName
                    }
                    else {
                        Write-Debug -Message "Force set to false. Skipping replacing existing AzureAD Claims for Display Name and Email for user $($user.OctopusUsername)"
                    }
                }
                else {
                    Write-Debug -Message "No existing AzureAD login found for user $($user.OctopusUsername), creating new"
                    $newAzureADIdentity = @{
                        IdentityProviderName = "Azure AD"
                        Claims               = @{
                            email = @{
                                Value              = $User.AzureEmailAddress
                                IsIdentifyingClaim = $True
                            }
                            dn    = @{
                                Value              = $User.AzureDisplayName
                                IsIdentifyingClaim = $False
                            }
                        }
                    }
                    $existingOctopusUser.Identities += $newAzureADIdentity
                }

                # Update user's email address if set AND the value isnt empty.
                if ($UpdateOctopusEmailAddress -eq $True -and -not([string]::IsNullOrWhiteSpace($User.AzureEmailAddress) -eq $true)) {
                    Write-Debug -Message "Setting Octopus email address to: $($User.AzureEmailAddress)"
                    $existingOctopusUser.EmailAddress = $User.AzureEmailAddress
                }

                # Update user's display name if set AND the value isnt empty.
                if ($UpdateOctopusDisplayName -eq $True -and -not([string]::IsNullOrWhiteSpace($User.AzureDisplayName) -eq $true)) {
                    Write-Debug -Message "Setting Octopus display name to: $($User.AzureDisplayName)"
                    $existingOctopusUser.DisplayName = $User.AzureDisplayName
                }

                $userJsonPayload = $($existingOctopusUser | ConvertTo-Json -Depth 10)

                if ($WhatIf -eq $True) {
                    Write-Information -MessageData "What If set to true, skipping update for user $($User.OctopusUsername). For details of the payload, set DebugLogging to True"
                    Write-Debug -Message "Would have done a POST to $OctopusUrl/api/users/$($existingOctopusUser.Id) with body:"
                    Write-Debug -Message $userJsonPayload
                }
                else {
                    Write-Information -MessageData "Updating the user $($User.OctopusUsername) in Octopus Deploy"
                    Invoke-RestMethod -Method PUT -Uri "$OctopusUrl/api/users/$($existingOctopusUser.Id)" -Headers $header -Body $userJsonPayload | Out-Null
                    $recordsUpdated += 1
                }
            }
            else {
                Write-Warning -Message "No match found for an existing octopus user with Username: $($User.OctopusUsername)"
            }
        }
        catch {
            If ($ContinueOnError -eq $true) {
                Write-Warning -Message "Error encountered updating $($User.OctopusUsername): $($_.Exception.Message), continuing..."
                continue
            }
            else {
                $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
                throw $Error[0]
            }
        }
    }
    Write-Information -MessageData "Updated $($recordsUpdated) user records."
}

#AddAzureADLogins -OctopusURL "https://your.octopus.app/" -OctopusAPIKey "API-KEY" -Path "/path/to/user_azure_ad_logins.csv" -ContinueOnError $False -Force $False -WhatIf $False -DebugLogging $False

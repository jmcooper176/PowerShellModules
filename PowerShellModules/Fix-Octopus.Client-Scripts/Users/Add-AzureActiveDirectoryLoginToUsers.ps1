# Load assembly
Add-Type -Path 'path:\to\Octopus.Client.dll'

function AddAzureLogins
(
    [Parameter(Mandatory=$True)]
    [String]$OctopusURL,
    [Parameter(Mandatory=$True)]
    [String]$OctopusAPIKey,
    [String]$Path,
    [String]$OctopusUsername,
    [String]$AzureEmailAddress,
    [String]$AzureDisplayName = $null,
    [Boolean]$UpdateOctopusEmailAddress = $False,
    [Boolean]$UpdateOctopusDisplayName = $False,
    [Boolean]$ContinueOnError = $False,
    [Boolean]$Force = $False,
    [Boolean]$WhatIf = $True,
    [Boolean]$DebugLogging = $False
)
{
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

    if($DebugLogging -eq $True) {
        $DebugPreference = "Continue"
    }

    $endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $OctopusURL, $OctopusAPIKey
    $repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
    $client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

    $usersToUpdate = @()
    $recordsUpdated = 0
    # Validate we have minimum required details.
    if ([string]::IsNullOrWhiteSpace($Path) -eq $true) {
        if([string]::IsNullOrWhiteSpace($OctopusUsername) -eq $true -or [string]::IsNullOrWhiteSpace($AzureEmailAddress) -eq $true) {
            Write-Warning -Message "Path not supplied. OctopusUsername or AzureEmailAddress are either null, or an empty string."
            return
        }
        $usersToUpdate += [PSCustomObject]@{
            OctopusUsername = $OctopusUsername
            AzureEmailAddress = $AzureEmailAddress
            AzureDisplayName = $AzureDisplayName
        }
    }
    else {
        # Validate path
        if(-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
            Write-Warning -Message "Path '$Path' not found. Does a file exist at that location?"
            return
        }

        $usersToUpdate = Import-Csv -Path $Path -Delimiter ","
    }

    # Check if we have any users. If we do, get existing octopus users
    if($usersToUpdate.Count -gt 0) {
        Write-Information -MessageData "Users to update: $($usersToUpdate.Count)"
        $ExistingOctopusUsers = @()

        # Loop through users
        foreach ($user in $usersToUpdate)
        {
            # Retrieve user account from Octopus
            Write-Information -MessageData "Searching Octopus users for $($user.OctopusUsername) ..."
            $existingOctopusUser = $client.Repository.Users.FindByUsername($user.OctopusUsername)

            # Check for null
            if ($null -ne $existingOctopusUser)
            {
                # Check user types
                if ($existingOctopusUser.IsService)
                {
                    # This is a service account and will not be updated
                    Write-Warning -Message "$($user.OctopusUsername) is a service account, skipping ..."

                    continue
                }

                if ($existingOctopusUser.IsActive -eq $False)
                {
                    # Inactive user skipping
                    Write-Warning -Message "$($user.OctopusUsername) is an inactive account, skipping ..."

                    continue
                }

                # Check to see if there's already an Azure identity
                $azureAdIdentity = $existingOctopusUser.Identities | Where-Object -Property IdentityProviderName -EQ "Azure AD"
                if($null -ne $azureAdIdentity)
                {
                    Write-Debug -Message "Found existing AzureAD login for user $($user.OctopusUsername)"
                    if($Force -eq $True)
                    {
                        Write-Debug -Message "Force set to true. Replacing existing AzureAD Claims for Display Name and Email for user $($user.OctopusUsername)"
                        $azureAdIdentity.Claims.email.Value = $User.AzureEmailAddress
                        $azureAdIdentity.Claims.dn.Value = $User.AzureDisplayName
                    }
                    else
                    {
                        Write-Warning -Message "Force set to false. Skipping replacing existing AzureAD Claims for Display Name and Email for user $($user.OctopusUsername)"
                    }
                }
                else
                {
                    Write-Debug -Message "No existing AzureAD login found for user $($user.OctopusUsername), creating new"
                    $newAzureADIdentity = New-Object -TypeName Octopus.Client.Model.IdentityResource
                    $newAzureADIdentity.IdentityProviderName = "Azure AD"

                    $newEmailClaim = New-Object -TypeName Octopus.Client.Model.IdentityClaimResource
                    $newEmailClaim.IsIdentifyingClaim = $True
                    $newEmailClaim.Value = $user.AzureEmailAddress

                    $newAzureADIdentity.Claims.Add("email", $newEmailClaim) # Claims is a Dictionary object

                    $newDisplayClaim = New-Object -TypeName Octopus.Client.Model.IdentityClaimResource
                    $newDisplayClaim.IsIdentifyingClaim = $False
                    $newDisplayClaim.Value = $user.AzureDisplayName

                    $newAzureADIdentity.Claims.Add("dn", $newDisplayClaim)

                    $existingOctopusUser.Identities += $newAzureADIdentity # Identities is an array
                }

                # Update user's email address if set AND the value isnt empty.
                if($UpdateOctopusEmailAddress -eq $True -and -not([string]::IsNullOrWhiteSpace($User.AzureEmailAddress) -eq $true))
                {
                    Write-Debug -Message "Setting Octopus email address to: $($User.AzureEmailAddress)"
                    $existingOctopusUser.EmailAddress = $User.AzureEmailAddress
                }

                # Update user's display name if set AND the value isnt empty.
                if($UpdateOctopusDisplayName -eq $True -and -not([string]::IsNullOrWhiteSpace($User.AzureDisplayName) -eq $true))
                {
                    Write-Debug -Message "Setting Octopus display name to: $($User.AzureDisplayName)"
                    $existingOctopusUser.DisplayName = $User.AzureDisplayName
                }

                if($WhatIf -eq $True)
                {
                    Write-Information -MessageData "What If set to true, skipping update for user $($User.OctopusUsername). For details of the payload, set DebugLogging to True"
                    Write-Debug -Message "Would have done a POST to $OctopusUrl/api/users/$($existingOctopusUser.Id) with body:"
                    Write-Debug -Message $userJsonPayload
                }
                else
                {
                    Write-Information -MessageData "Updating the user $($User.OctopusUsername) in Octopus Deploy"
                    $client.Repository.Users.Modify($existingOctopusUser)
                    $recordsUpdated += 1
                }
            }
            else
            {
                # User not found
                Write-Warning -Message "$($user.OctopusUsername) not found!"
            }
        }
        Write-Debug -Message "Found $($ExistingOctopusUsers.Count) existing Octopus users"
    }
    else {
        Write-Information -MessageData "No users to update, exiting."
        return
    }
}

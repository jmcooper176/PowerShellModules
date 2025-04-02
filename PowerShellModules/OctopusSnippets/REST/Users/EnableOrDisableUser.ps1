<#
 =============================================================================
<copyright file="EnableOrDisableUser.ps1" company="U.S. Office of Personnel
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
This file "EnableOrDisableUser.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# This is a script that can enable or disable a user based on their username or email address in Octopus

$ErrorActionPreference = "Stop";

# Define working variables
$octopusURL = "https://YOUR_OCTOPUS_URL"
$octopusAPIKey = "API-XXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }
$userAccountEmailAddress = "OCTOPUS_EMAIL@SOMEEMAIL.COM"
$userAccountUsername = "OCTOPUS_USERNAME"
$usernameOrEmail = "email" # Set to "username" if you wish to delete by username
$enable = $false # Set to $true to enable an account, set to $false to disable an account

# Find user account
$allUserAccounts = Invoke-RestMethod -Method GET -uri "$octopusURL/api/users/all" -Headers $header

If ($usernameOrEmail -ieq "email") {  
    $userAccount = $allUserAccounts | Where-Object -FilterScript { $_.EmailAddress -ieq $userAccountEmailAddress }
    if ($userAccount.count -gt 1) {
        Write-Warning -Message "Multiple accounts detected with the specified email. Consider specifying an account by username instead."
        Foreach ($account in $userAccount) {
            Write-Information -MessageData "Username: $($account.Username)"
            Write-Information -MessageData "Email: $($account.EmailAddress)"
            Write-Information -MessageData "Id: $($account.Id)"
            Write-Information -MessageData "---"
        }
        Break
    }
}

Else {
    If ($usernameOrEmail -ieq "username") {
        $userAccount = ($allUserAccounts | Where-Object -FilterScript { $_.Username -ieq $userAccountUsername }) | Select-Object -First 1
    }
}

# Enable or disable user account
If (!$userAccount) {
    Write-Warning -Message "No users accounts found using the input parameters."
    Break
}

If ($userAccount) {
    If ($enable) { $enableDisable = "enabled" }; If (!$enable) { $enableDisable = "disabled" }
    Write-Information -MessageData "Committing changes to account: $($userAccount.DisplayName) ($($userAccount.Id))"
    $userAccount.IsActive = $enable
    $disableUser = Invoke-RestMethod -Method PUT -uri "$octopusURL/api/users/$($userAccount.Id)" -Body ($userAccount | ConvertTo-Json -Depth 10) -Headers $header
    Write-Information -MessageData "User account $enableDisable"
}

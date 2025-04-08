<#
 =============================================================================
<copyright file="MatchUsernamesToEmailAddress.ps1" company="John Merryweather Cooper
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
This file "MatchUsernamesToEmailAddress.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# =============================================================
#      Change usernames to match email addresses (for AAD)     
# =============================================================

$ErrorActionPreference = "Stop";

# Define working variables
$OctopusURL = "http://YOUR_OCTOPUS_URL"
$octopusAPIKey = "API-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
$Header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

# Get Users
$Users = (Invoke-RestMethod -Method GET "$OctopusURL/api/users/all" -Headers $Header)

$OriginalUsersJSON = (Invoke-RestMethod -Method GET "$OctopusURL/api/users/all" -Headers $Header)
$NoEmailUsers = @()
$ModifiedUserIds = @()

# Iterate through each user
Foreach ($User in $Users) {
    If (($User.IsService -eq $false) -and ($User.Username -ne $User.EmailAddress)) {
        If (!$User.EmailAddress) {
            $NoEmailUsers += $User.Id
        }
        $UserModifiedJSON = $User
        If ($User.EmailAddress) {
            $UserModifiedJSON.Username = $User.EmailAddress
            Invoke-RestMethod -Method PUT "$OctopusURL/api/users/$($UserModifiedJSON.Id)" -Body ($UserModifiedJSON | ConvertTo-Json -Depth 10) -Headers $Header
            $ModifiedUserIds += $UserModifiedJSON.Id
        }
    }
}
Write-Information -MessageData "The following User IDs were modified:"
$ModifiedUserIds
Write-Information -MessageData ""

If ($NoEmailUsers) {
    Write-Warning -Message "The following User IDs have no email associated (this excludes Service Accounts):"
    $NoEmailUsers
}

# OPTIONAL: Use the line below (uncommented) in the same PowerShell session you ran the script above to restore the users to their original JSON values.
# Foreach ($OriginalUser in $OriginalUsersJSON) { Invoke-RestMethod -Method PUT "$OctopusURL/api/users/$($OriginalUser.Id)" -Body ($OriginalUser | ConvertTo-Json -Depth 10) -Headers $Header }

<#
 =============================================================================
<copyright file="Find-UsersWithEditRoles.ps1" company="John Merryweather Cooper
">
    Copyright � 2025, John Merryweather Cooper.
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
This file "Find-UsersWithEditRoles.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = 'Stop';

# Define working variables
$octopusURL = "https://your.octopus.server"
$octopusAPIKey = "API-KEY"

$csvExportPath = ''

function Invoke-PagedOctoGet($uriFragment)
{
    $items = @()
    $response = $null
    do {
        $uri = if ($response) { $octopusURL + $response.Links.'Page.Next' } else { "$octopusURL/$uriFragment" }
        $response = Invoke-RestMethod -Method Get -Uri $uri -Headers @{ "X-Octopus-ApiKey" = $octopusAPIKey }
        $items += $response.Items
    } while ($response.Links.'Page.Next')

    $items
}

$users = Invoke-PagedOctoGet "api/users"
$usersWithEditPermissions = @()
foreach ($user in $users) {
    $permissions = (Invoke-RestMethod `
        -Uri "$octopusURL/api/users/$($user.Id)/permissions" `
        -Headers @{ "X-Octopus-ApiKey" = $octopusAPIKey }).SpacePermissions.PSObject.Members `
            | Where-Object MemberType -eq "NoteProperty"

    $editPermissionsForUser = @()
    foreach ($name in $permissions.Name) {
        if (($name -match "Edit") -or ($name -match "Create") -or ($name -match "Delete")) {
            $editPermissionsForUser += $name
        }
    }

    if ($editPermissionsForUser) {
        $usersWithEditPermissions += [PSCustomObject] @{
            Id = $user.Id
            EmailAddress = $user.EmailAddress
            Username = $user.Username
            DisplayName = $user.DisplayName
            IsActive = $user.IsActive
            IsService = $user.IsService
            Permissions = ($editPermissionsForUser -join ",")
        }
    }
}

if (![string]::IsNullOrWhiteSpace($csvExportPath)) {
    Write-Information -MessageData "Exporting results to CSV file: $csvExportPath"
    $usersWithEditPermissions | Export-Csv -Path $csvExportPath -NoTypeInformation
}

$usersWithEditPermissions | Format-Table

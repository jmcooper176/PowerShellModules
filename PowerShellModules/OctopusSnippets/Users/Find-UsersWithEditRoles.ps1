<#
 =============================================================================
<copyright file="Find-UsersWithEditRoles.ps1" company="John Merryweather Cooper
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
This file "Find-UsersWithEditRoles.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Load assembly
Add-Type -Path 'path:\to\Octopus.Client.dll'
# Define working variables
$octopusURL = "https://YourURL"
$octopusAPIKey = "API-YourAPIKey"
$csvExportPath = "path:\to\editpermissions.csv"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint($octopusURL, $octopusAPIKey)
$repository = New-Object -TypeName Octopus.Client.OctopusRepository($endpoint)
$client = New-Object -TypeName Octopus.Client.OctopusClient($endpoint)

# Get users
$users = $repository.Users.GetAll()
$usersList = @()

# Loop through users
foreach ($user in $users)
{
    $userPermissions = $repository.UserPermissions.Get($user)
    $editPermissions = @()
    foreach ($spacePermission in $userPermissions.SpacePermissions)
    {
        foreach ($permissionName in $spacePermission.Keys)
        {
            if ($permissionName.ToString().ToLower().Contains("create") -or $permissionName.ToString().ToLower().Contains("delete") -or $permissionName.ToString().ToLower().Contains("edit"))
            {
                $editPermissions += $permissionName.ToString()
            }
        }
    }

    if ($null -ne $editPermissions -and $editPermissions.Count -gt 0)
    {
        $usersList += @{
            Id = $user.Id
            EmailAddress = $user.EmailAddress
            Username = $user.Username
            DisplayName = $user.DisplayName
            IsActive = $user.IsActive
            IsService = $user.IsService
            Permissions = ($editPermissions -join "| ")
        }
    }
}

if (![string]::IsNullOrWhiteSpace($csvExportPath))
{
    # Write header
    $header = $usersList.Keys | Select-Object -Unique
    Set-Content -Path $csvExportPath -Value ($header -join ",")

    foreach ($user in $usersList)
    {
        Add-Content -Path $csvExportPath -Value ($user.Values -join ",")
    }
}
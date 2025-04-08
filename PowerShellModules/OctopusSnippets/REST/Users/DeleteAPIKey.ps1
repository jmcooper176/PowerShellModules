<#
 =============================================================================
<copyright file="DeleteAPIKey.ps1" company="John Merryweather Cooper
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
This file "DeleteAPIKey.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

##CONFIG
$OctopusURL = "" #Base url of Octopus server
$APIKey = ""#API Key to authenticate to Octopus Server

$UserName = "" #UserName of the user for which the API key will be created. You can check this value from the web portal under Configuration/Users
$APIKeyPurpose = "" #Purpose of the API Key. This is mandatory to identify which API key will be deleted.
##PROCESS

$header = @{ "X-Octopus-ApiKey" = $APIKey }

$body = @{
  Purpose = $APIKeyPurpose
  } | ConvertTo-Json

#Getting all users to filter target user by name
$allUsers = (Invoke-WebRequest -Uri "$OctopusURL/api/users/all" -Headers $header -Method Get).content | ConvertFrom-Json

#Getting user that owns API Key that will be deleted
$User = $allUsers | Where-Object -FilterScript {$_.username -eq $UserName}

#Getting all API Keys of user
$allAPIKeys = (Invoke-WebRequest -Uri "$OctopusURL/api/users/$($user.id)/ApiKeys" -Headers $header -Method Get).content | ConvertFrom-Json | Select-Object -ExpandProperty items

#Getting API Key to delete
$APIKeyResource = $allAPIKeys | Where-Object -FilterScript {$_.purpose -eq $APIKeyPurpose}

#Deleting API Key
Invoke-WebRequest -Uri "$OctopusURL/api/users/$($user.id)/ApiKeys/$($APIKeyResource.id)" -Headers $header -Method Delete


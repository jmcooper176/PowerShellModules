<#
 =============================================================================
<copyright file="GetUsersAPIKeyList.ps1" company="John Merryweather Cooper
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
This file "GetUsersAPIKeyList.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

##Disclaimer: This script only lists the Purpuse, created date & ID of all the currently valid/registered API Keys of each user. It does not show the actual API Key value which cannot be recovered in any way after it was created.

##CONFIG##
$OctopusAPIkey = ""#Your Octopus API Key
$OctopusURL = ""#Your Octopus server root URL

##PROCESS##
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }
$list = @()

$AllUsers = (Invoke-WebRequest -Uri $OctopusURL/api/users/all -Headers $header).content | ConvertFrom-Json

foreach($user in $AllUsers){
    $apikeys = $null

    $apikeys = (Invoke-WebRequest -Uri ($OctopusURL + $user.links.apikeys.Split('{')[0]) -Headers $header).content | ConvertFrom-Json

    $obj = [PSCustomObject]@{
                    UserName = $user.Username
                    ID = $user.Id
                    APIKeys = $apikeys.Items
                }
    $list += $obj
}

$list

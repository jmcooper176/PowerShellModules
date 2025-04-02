<#
 =============================================================================
<copyright file="GetTargetsPerSpace.ps1" company="U.S. Office of Personnel
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
This file "GetTargetsPerSpace.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Define working variables
$OctopusUrl = "https://youroctourl" # Octopus URL
$APIKey = "API-YOURAPIKEY" # API Key that can read the number of machines
$header = @{ "X-Octopus-ApiKey" = $APIKey }

# Get list of Spaces
$spaces = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/spaces/all" -Headers $header)

# Getting the deployment targets in each space
Foreach ($space in $spaces) {
    $spaceid = "$($space.id)"
    $spacename = "$($space.name)"
    If ($spacename -ne "Private")
        {
        Write-Information -MessageData "$($spaceid) ($($spacename))"
        $machines = (Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/$($spaceid)/machines?skip=0&take=100000" -Headers $header)
        $items = $machines.items
        Foreach ($item in $items) {
                 $machineid = $($item.id)
                $machinename = $($item.name)
                Write-Information -MessageData "$($machineid)  `t($($machinename)) - $OctopusUrl/api/$($spaceid)/infrastructure/machines/$($machineid)"
        }
    }
    Write-Information -MessageData "---"
}

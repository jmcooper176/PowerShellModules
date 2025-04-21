<#
 =============================================================================
<copyright file="Set-OctopusTargetLockUpgrade.ps1" company="John Merryweather Cooper
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
This file "Set-OctopusTargetLockUpgrade.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#
.SYNOPSIS
Sets the Octopus Target Machine Upgrade Locked Value to True or False

.DESCRIPTION
Sets the Octopus Target Machine Upgrade Locked Value to True or False

.PARAMETER API URL
Specify the full Octopus API URL. E.g. "https://192.168.99.100/octopus/api".

.PARAMETER API Key
Specify the Octopus API Key. E.g. "API-XXXXXXXXXXXXXXXXX".

.PARAMETER Lock Upgrade
Specify whether to lock ($true) or unlock ($false) the version upgrade for all target machines.

.EXAMPLE
Set-OctopusTargetLockUpgrade -Url https://192.168.99.100/octopus/api/ -ApiKey API-XXXXXXXXXXXX -LockUpgrade $true

.EXAMPLE
Set-OctopusTargetLockUpgrade -Url https://10.254.1.10/octopus/api -ApiKey API-XXXXXXXXXXXX -LockUpgrade $false

#>

function Set-OctopusTargetLockUpgrade {
    param (
        [Parameter(Mandatory=$true)]
        $Url,
        [Parameter(Mandatory=$true)]
        $ApiKey,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet($false,$true)]
        $LockUpgrade
    )

    if ([string]::IsNullOrWhiteSpace($Url)) {
        throw "Octopus API URL was not specified. Make sure you provid a valid URL to the Octopus API endpoint."
    }

    if ([string]::IsNullOrWhiteSpace($ApiKey)) {
        throw "Octopus API Key was not specified. Make sure you provide a valid API Key."
    }

    $LockUpgrade = [System.Convert]::ToBoolean($LockUpgrade)

    if ($Url.Substring($Url.Length - 1, 1) -eq "/") {
        $Url = $Url.Substring(0, $Url.Length - 1)
    }

    $header = @{ "X-Octopus-ApiKey" = $ApiKey }
    $allTargets = (Invoke-WebRequest -Uri $Url/machines/all -Headers $header).Content | ConvertFrom-Json

    foreach ($target in $allTargets) {
        $target.Endpoint.TentacleVersionDetails.UpgradeLocked = $LockUpgrade
        $body = $target | ConvertTo-Json -Depth 4
        $machineUrl = $machine.Links.Self
        $result = Invoke-WebRequest -Uri ($Url + $machineUrl.Substring($machineUrl.IndexOf("/machines/"), $machineUrl.Length - $machineUrl.IndexOf("/machines"))) -Method Put -Body $body -Headers $header
        if ($result.StatusCode -eq 200) {
            Write-Verbose -Message "Modified $($target.Name) with UpgradeLocked value of $LockUpgrade"
        }
        else {
            Write-Error -Message "Modification failed for $($target.Name)"
        }
    }
}

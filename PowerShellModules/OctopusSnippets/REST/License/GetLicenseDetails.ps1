<#
 =============================================================================
<copyright file="GetLicenseDetails.ps1" company="John Merryweather Cooper
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
This file "GetLicenseDetails.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

##CONFIG##

$OctopusURL = ""
$Octopusapikey = ""

$LicenseLevel = "" #Accepted values are  "Team","Professional","Enterprise"

##PROCESS##
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

$Projects = ((Invoke-WebRequest -Uri $OctopusURL/api/projects/all -Headers $header).content | ConvertFrom-Json).count
$Users = ((Invoke-WebRequest -Uri $OctopusURL/api/users/all -Headers $header).content | ConvertFrom-Json).count
$Machines = ((Invoke-WebRequest -Uri $OctopusURL/api/Machines/all -Headers $header).content | ConvertFrom-Json).count

$remaining = 0
$limit = 0

switch ($LicenseLevel)
{
    'Professional' {
        $limit = 60
        $remaining = $limit - $Projects - $Users - $Machines
    }
    'Team' {
        $limit = 180
        $remaining = $limit - $Projects - $Users - $Machines
    }
    'Enterprise' {
    }
    Default {Write-Error -Message "Unvalid value passed to `$LicenseLevel. Accepted values are 'Professional','Team','Enterprise'"}
}

Write-output "--Current status--"
Write-Output "Projects: $Projects"
Write-Output "Users: $Users"
Write-Output "Machines: $Machines"

If($LicenseLevel -eq "Enterprise"){
    Write-Output "Limit by license: Unlimited"
    Write-Output "Available 'Resources': Unlimited"
}
else{
    Write-Output "Limit by license: $limit"
    Write-Output "Available 'Resources': $remaining"
}

Write-Output "What are these Resource? Please read: https://github.com/OctopusDeploy/Issues/issues/1937"

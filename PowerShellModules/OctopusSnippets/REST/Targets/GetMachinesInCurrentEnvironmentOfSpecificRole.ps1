<#
 =============================================================================
<copyright file="GetMachinesInCurrentEnvironmentOfSpecificRole.ps1" company="John Merryweather Cooper
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
This file "GetMachinesInCurrentEnvironmentOfSpecificRole.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

##CONFIG##
$APIKey = "" #Octopus API. You might wanna create a service account that can only read (all) environments, then create an API key for it and use that Key.
$Role = "" #Role you are looking for

##PROCESS##
$OctopusURL = $OctopusParameters['Octopus.Web.BaseUrl']
$EnvironmentID = $OctopusParameters['Octopus.Environment.Id']
$header = @{ "X-Octopus-ApiKey" = $APIKey }

$environment = (Invoke-WebRequest -Uri "$OctopusURL/api/environments/$EnvironmentID" -Headers $header).content | ConvertFrom-Json

$environmentMachines = $Environment.Links.Machines.Split("{")[0]

$machines = ((Invoke-WebRequest -Uri ($OctopusURL + $environmentMachines) -Headers $header).content | ConvertFrom-Json).items

$MachinesInRole = $machines | Where-Object -FilterScript {$Role -in $_.Roles}

##OUTPUT##

#Name of machines in Octopus
$MachinesInRole.Name

#URI of machines
$MachinesInRole.URI

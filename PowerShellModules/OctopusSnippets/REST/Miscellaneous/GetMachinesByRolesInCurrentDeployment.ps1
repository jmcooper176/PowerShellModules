<#
 =============================================================================
<copyright file="GetMachinesByRolesInCurrentDeployment.ps1" company="U.S. Office of Personnel
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
This file "GetMachinesByRolesInCurrentDeployment.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#
This script should run from:

- A script step
- That's executed on the Octopus Server
- With a Window size of 1

It'll create an output variable called "MachineNames" Which will have the names of the machines (in octopus, so not the same as $env:computername).

To learn more about the usage of output variables read http://octopusdeploy.com/blog/fun-with-output-variables
#>

##CONFIG##
$Role = "" #Role you want to filter by.
$OctopusAPIkey = "" #API Key to authenticate in Octopus.

##PROCESS##
$OctopusURL = $OctopusParameters['Octopus.Web.BaseUrl']
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

$MachineIDs = ($OctopusParameters["Octopus.Environment.MachinesInRole[$Role]"]).Split(',')

$machineNamesArray = @()

foreach ($Id in $MachineIDs){
    $MachineNamesArray += ((Invoke-WebRequest -Uri $OctopusURL/api/machines/$id -Headers $header -Method Get).content | ConvertFrom-Json | Select-Object -ExpandProperty Name)
}

$MachineNamesString = $machineNamesArray -join ","

#Creating the Output variable
Set-OctopusVariable -name "MachineNames" -value $MachineNamesString
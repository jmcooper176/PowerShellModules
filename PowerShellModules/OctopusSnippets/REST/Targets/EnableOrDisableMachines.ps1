<#
 =============================================================================
<copyright file="EnableOrDisableMachines.ps1" company="John Merryweather Cooper
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
This file "EnableOrDisableMachines.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Define working variables
$octopusURL = "https://your.octopus.app"
$octopusAPIKey = "API-YOURAPIKEY"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

# Provide Space name
$spaceName = "Default"

# Provide list of machines to enable or disable
$machineNames = @("MyMachine1", "MyMachine2")

# Set this to $False to Disable machines, or $True to Enable the machines
$machinesEnabled = $false

# Get space
$spaces = Invoke-RestMethod -Uri "$octopusURL/api/spaces?partialName=$([uri]::EscapeDataString($spaceName))&skip=0&take=100" -Headers $header 
$space = $spaces.Items | Where-Object -FilterScript { $_.Name -eq $spaceName }

# Get all machines (paged)
$machines = @()
$response = $null
do {
    $uri = if ($response) { $octopusURL + $response.Links.'Page.Next' } else { "$octopusURL/api/$($space.Id)/machines" }
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
    Write-Verbose -Message "Found $($response.Items.Length) machines.";
    $machines += $response.Items
} while ($response.Links.'Page.Next')

# Work on updating each machine
foreach ($machineName in $machineNames) {
    $matchingMachines = @($machines | Where-Object -FilterScript { $_.Name -ieq $machineName })
    if ($null -eq $matchingMachines -or $matchingMachines.Count -eq 0) {
        Write-Warning -Message "Found no matching machines for $machineName, continuing"
    }
    if ($matchingMachines.Count -gt 1) {
        Write-Error -Message "Found multiple machines matching name: $machineName. Don't know which machine to enable or disable!"
    }
    $machine = $matchingMachines | Select-Object -First 1
    if ($null -eq $machine) {
        Write-Warning -Message "Machine object is null or empty for $machineName, skipping"
        Continue;
    }
    # Enable/disable machine
    $machine.IsDisabled = !$machinesEnabled

    # Update machine
    Write-Output "Updating machine: $($machine.Name) ($($machine.Id)), IsDisabled: $(!$machinesEnabled)"
    Invoke-RestMethod -Method Put -Uri "$octopusURL/api/$($space.Id)/machines/$($machine.Id)" -Headers $header -Body ($machine | ConvertTo-Json -Depth 10) | Out-Null
}
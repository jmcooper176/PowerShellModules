<#
 =============================================================================
<copyright file="SubmitScriptConsoleTask.ps1" company="John Merryweather Cooper
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
This file "SubmitScriptConsoleTask.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Define working variables
$octopusURL = "https://octopus-url/"
$octopusAPIKey = "API-XXX"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

$machineNames = @("server-01")

$spaceName = "Default"
# Get space
$spaces = Invoke-RestMethod -Uri "$octopusURL/api/spaces?partialName=$([uri]::EscapeDataString($spaceName))&skip=0&take=100" -Headers $header 
$space = $spaces.Items | Where-Object -FilterScript { $_.Name -eq $spaceName }
$spaceId = $space.Id

# Get machine 
$machineList = New-Object -TypeName.Collections.ArrayList

foreach ($machineName in $machineNames) {
    $machine = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/machines/all" -Headers $header) | Where-Object -FilterScript {$_.Name -eq $machineName}
    if (!$machine){
        Write-Warning -Message "Machine not found $($machineName)"
    } else {
        $machineList.Add($machine.Id)
    }
}

$script = 'echo \"hello\"'

$arguments = @{    
    MachineIds = $machineList
    TargetType = "Machines"
    Syntax = "Bash"
    ScriptBody = $script
}

# Create runbook Payload
$scriptTaskBody = (@{
    Name = "AdHocScript"
    Description = "Script run from management console"
    Arguments = $arguments
    SpaceId = $spaceId
}) | ConvertTo-Json -Depth 10

# Run the runbook 
Invoke-RestMethod -Method "POST" "$($octopusURL)/api/tasks" -body $scriptTaskBody -Headers $header -ContentType "application/json"

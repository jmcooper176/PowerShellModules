<#
 =============================================================================
<copyright file="RunRunbookWithPromptedVariablesSpecificMachines.ps1" company="John Merryweather Cooper
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
This file "RunRunbookWithPromptedVariablesSpecificMachines.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Define working variables
$octopusURL = "https://OCTOPUS-URL/"
$octopusAPIKey = "API-XXXX"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

$machineNames = @("server01","target-40","win-987")

$spaceName = "Default"
$environmentName = "ServerAdmin"
$runbookName = "Restart Windows Service"
$runbookSnapshotId = "" # Leave blank if you'd like to use the published snapshot
$variableName = @("Project.Service.Name")     # Enter multiple comma separated values if you have multiple prompted variables (e.g. @("promptedvar","promptedvar2"))
$newValue = @("Spooler")         # Enter multiple comma separated values if you have multiple prompted variables in the same order as the variable names above (e.g. @("value for promptedvar","value for promptedvar2"))

# Get space
$spaces = Invoke-RestMethod -Uri "$octopusURL/api/spaces?partialName=$([uri]::EscapeDataString($spaceName))&skip=0&take=100" -Headers $header
$space = $spaces.Items | Where-Object -FilterScript { $_.Name -eq $spaceName }
$spaceId = $space.Id

# Get runbook
$runbooks = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/runbooks?partialName=$([uri]::EscapeDataString($runbookName))&skip=0&take=100" -Headers $header
$runbook = $runbooks.Items | Where-Object -FilterScript { $_.Name -eq $runbookName }
$runbookId = $runbook.Id

# Get environment
$environments = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/environments?partialName=$([uri]::EscapeDataString($environmentName))&skip=0&take=100" -Headers $header
$environment = $environments.Items | Where-Object -FilterScript { $_.Name -eq $environmentName }
$environmentId = $environment.Id

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

# Use published snapshot if no id provided
if ([string]::IsNullOrEmpty($runbookSnapshotId)) {
    $runbookSnapshotId = $runbook.PublishedRunbookSnapshotId
}

# Get runbook preview for environment
$runbookPreview = Invoke-RestMethod -Uri "$octopusURL/api/$($spaceId)/runbooks/$($runbookId)/runbookRuns/preview/$($EnvironmentId)?includeDisabledSteps=true" -Headers $header

# Finds the element ID(s) you need to provide for the runbook
$elementItems = @()
$formValues = @{ }
foreach ($name in $variablename){
    $element = $runbookPreview.Form.Elements | Where-Object -FilterScript { $_.Control.Name -eq $name }
    if($null -ne $element) {
        $elementItems += $element
    }
}

# Add the variables to the json.
For ($i=0; $i -lt $elementItems.Count; $i++) {
    $runbookPromptedVariableId = $elementItems[$i].Name
    $runbookPromptedVariableValue = $newvalue[$i]
    $formValues.Add($runbookPromptedVariableId, $runbookPromptedVariableValue)
}

# Create runbook Payload
$runbookBody = (@{
    RunBookId = $runbookId
    RunbookSnapshotId = $runbookSnapshotId
    EnvironmentId = $environmentId
    FormValues    = $formValues
    SpecificMachineIds = $machineList
    SpaceId = $spaceId
    SkipActions = @()
    ExcludedMachineIds = @()
}) | ConvertTo-Json -Depth 10

# Run the runbook
Invoke-RestMethod -Method "POST" "$($octopusURL)/api/$($spaceid)/runbookRuns" -body $runbookBody -Headers $header -ContentType "application/json"

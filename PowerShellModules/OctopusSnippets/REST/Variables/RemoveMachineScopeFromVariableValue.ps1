<#
 =============================================================================
<copyright file="RemoveMachineScopeFromVariableValue.ps1" company="John Merryweather Cooper
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
This file "RemoveMachineScopeFromVariableValue.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Define working variables
$octopusURL = "" # example https://myoctopus.something.com
$octopusAPIKey = "" # example API-XXXXXXXXXXXXXXXXXXXXXXXXXXX
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }
$spaceName = "Default"
$projectName = "Your project name"
$variableName = "Your variable name"
$variableValue = "The value with incorrect scoping" # this script assumes the value exists only once
$targetToRemove = "The name of the target to remove"

# Get space
$spaces = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/spaces/all?partialName=$([uri]::EscapeDataString($spaceName))&skip=0&take=100" -Headers $header)
$space = $spaces.Items | Where-Object -FilterScript { $_.Name -eq $spaceName }

# Get target
$targets = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/machines?partialName=$([uri]::EscapeDataString($targetToRemove))&skip=0&take=100" -Headers $header)
$target = $targets.Items | Where-Object -FilterScript { $_.Name -eq $targetToRemove }

# Get project
$projects = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects?partialName=$([uri]::EscapeDataString($projectName))&skip=0&take=100" -Headers $header)
$project = $projects.Items | Where-Object -FilterScript { $_.Name -eq $projectName }

# Get project variables
$projectVariables = Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/variables/$($project.VariableSetId)" -Headers $header

# Check to see if varialbe is already present
$variableToUpdate = $projectVariables.Variables | Where-Object -FilterScript { $_.Name -eq $variableName -and $_.Value -eq $variableValue }

if ($variableToUpdate) {
    if ($variableToUpdate.Scope.Machine -and $variableToUpdate.Scope.Machine -contains $target.Id) {
        Write-Information -MessageData "Removing scope $targetToRemove ($($target.Id)) from variable $variableName"
        $machines = $variableToUpdate.Scope.Machine | Where-Object -FilterScript { $_ -ne $target.Id }
        $variableToUpdate.Scope.Machine = $machines

        Invoke-RestMethod -Method Put -Uri "$octopusURL/api/$($space.Id)/variables/$($project.VariableSetId)" -Headers $header -Body ($projectVariables | ConvertTo-Json -Depth 10)
    }
    else {
        Write-Information -MessageData "Could not find target '$($target.Name)' in the scope for variable '$variableName' value '$variableValue'"
    }
}
else {
    Write-Information -MessageData "Could not find the variable '$variableName' in project '$projectName'"
}

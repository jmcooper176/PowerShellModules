<#
 =============================================================================
<copyright file="CreateScriptStep.ps1" company="John Merryweather Cooper
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
This file "CreateScriptStep.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Define working variables
$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }
$spaceName = "default"
$role = "My role"
$scriptBody = "Write-Information -MessageData `"Hello world`""

# Project details
$projectName = "MyProject"


# Get space
$space = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/spaces/all" -Headers $header) | Where-Object -FilterScript {$_.Name -eq $spaceName}

# Get project
$project = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects/all" -Headers $header) | Where-Object -FilterScript {$_.Name -eq $projectName}

# Get deployment process
$deploymentProcess = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/deploymentprocesses/$($project.DeploymentProcessId)" -Headers $header)

# Get current steps
$steps = $deploymentProcess.Steps

# Add new step to process
$steps += @{
    Name = "Run a script"
    Properties = @{
    'Octopus.Action.TargetRoles' = $role
    }
    Condition = "Success"
    StartTrigger = "StartAfterPrevious"
    PackageRequirement = "LetOctopusDecide"
    Actions = @(
    @{
        ActionType = "Octopus.Script"
        Name = "Run a script"
        Environments = @()
        ExcludedEnvironments = @()
        Channels = @()
        TenantTags = @()
        Properties = @{
            'Octopus.Action.RunOnServer' = "false"
            'Octopus.Action.EnabledFeatures' = ""
            'Octopus.Action.Script.ScriptSource' = "Inline"
            'Octopus.Action.Script.Syntax' = "PowerShell"
            'Octopus.Action.Script.ScriptBody' = $scriptBody
        }
        Packages = @()
        IsDisabled = $false
        WorkerPoolId = ""
        WorkerPoolVariable = ""
        Container = @{
            "FeedId" = $null
            "Image" = $null
        }
        CanBeUsedForProjectVersioning = $false
        IsRequired = $false
    }
    )
}

# Convert steps to json
$deploymentProcess.Steps = $steps
$jsonPayload = $deploymentProcess | ConvertTo-Json -Depth 10

# Submit request
Invoke-RestMethod -Method Put -Uri "$octopusURL/api/$($space.Id)/deploymentprocesses/$($project.DeploymentProcessId)" -Headers $header -Body $jsonPayload
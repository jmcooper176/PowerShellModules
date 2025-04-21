<#
 =============================================================================
<copyright file="EnableDisableStepsbyName.ps1" company="John Merryweather Cooper
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
This file "EnableDisableStepsbyName.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# This script is designed to find steps in Runbooks and deployment processes with an exact name, then enable or disable the step via $disable

$ErrorActionPreference = "Stop";

# Define working variables
$octopusURL = "https://YOUR_OCTOPUS_URL"
$octopusAPIKey = "API-XXXXXXXXXXXXXXXXXXXXXXXXX"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }
$spaceName = "Default"
$stepName = "STEP_NAME_HERE"
$disable = $false # Set to $true to disable applicable steps. Set to $false to enable applicable steps

# Get space
$space = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/spaces/all" -Headers $header) | Where-Object -FilterScript { $_.Name -eq $spaceName }

# Get projects for space
$projectList = Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects/all" -Headers $header

# Loop through projects
foreach ($project in $projectList) {
    # If you do not want to apply this to Runbooks, comment out the section noted below
    # <-------->
    $runbooksListLink = "/api/$($space.Id)/projects/$($project.Id)/runbooks/all"
    $runbooksList = Invoke-RestMethod -Method Get -Uri "$octopusURL$runbooksListLink" -Headers $header

    # Loop through runbooks
    foreach ($runbook in $runbooksList) {
        $runbookProcessLink = $runbook.Links.RunbookProcesses

         try {
        $runbookProcess = Invoke-RestMethod -Method Get -Uri "$octopusURL$runbookProcessLink" -Headers $header | Where-Object -FilterScript { $_.steps.name -contains $stepName }
        }
        catch {
            Write-Information -MessageData "---"
            Write-Warning -Message "Failed to GET the Runbook process for `"$($runbook.Name)`" inside the Project `"$($project.Name)`" via the following URL: $octopusURL$runbookProcessLink"
        }
        # Find and enable/disable Steps in Runbook process
        if ($runbookProcess.Steps.name -contains $stepName) {
            $modifiedRunbookProcess = $runbookProcess
            Foreach ($action in $modifiedRunbookProcess.Steps.actions | Where-Object -FilterScript { $_.Name -eq $stepName }) {
                $action.IsDisabled = $disable
            }
            $updatedRunbookProcess = Invoke-RestMethod -Method Put -Uri "$octopusURL$runbookProcessLink" -Headers $header -Body ($modifiedRunbookProcess | ConvertTo-Json -Depth 10)
            If ($disable) {
                Write-Information -MessageData "Disabled step `"$stepName`" in Runbook `"$($runbook.Name)`" inside the Project `"$($project.Name)`. ($octopusURL$runbookProcessLink)"
            }
            If (!$disable) {
                Write-Information -MessageData "Enabled step `"$stepName`" in Runbook `"$($runbook.Name)`" inside the Project `"$($project.Name)`. ($octopusURL$runbookProcessLink)"
            }
        Write-Information -MessageData "---"
        }
    }
    # <-------->

    $deploymentProcessLink = $project.Links.DeploymentProcess

    # Check if project is Config-as-Code
    if ($project.IsVersionControlled) {
        # Get default Git branch for Config-as-Code project
        $defaultBranch = $project.PersistenceSettings.DefaultBranch
        $deploymentProcessLink = $deploymentProcessLink -Replace "{gitRef}", $defaultBranch
    }
    $deploymentProcess = $null
    try {
        $deploymentProcess = Invoke-RestMethod -Method Get -Uri "$octopusURL$deploymentProcessLink" -Headers $header | Where-Object -FilterScript { $_.steps.name -contains $stepName }
    }
    catch {
        Write-Warning -Message "Failed to GET the deployment process for `"$($project.Name)`" via the following URL: $octopusURL$deploymentProcessLink"
        Write-Information -MessageData "---"
    }

    # Find and enable/disable Steps in deployment process
    if ($deploymentProcess.Steps.name -contains $stepName) {
        $modifiedProcess = $deploymentProcess
        Foreach ($action in $modifiedProcess.Steps.actions | Where-Object -FilterScript { $_.Name -eq $stepName }) {
            $action.IsDisabled = $disable
        }
        $updatedDeploymentProcess = Invoke-RestMethod -Method Put -Uri "$octopusURL$deploymentProcessLink" -Headers $header -Body ($modifiedProcess | ConvertTo-Json -Depth 10)
        If ($disable) {
            Write-Information -MessageData "Disabled step `"$stepName`" deployment process for the Project `"$($project.Name)`. ($octopusURL$deploymentProcessLink)"
        }
        If (!$disable) {
            Write-Information -MessageData "Enabled step `"$stepName`" deployment process for the Project `"$($project.Name)`. ($octopusURL$deploymentProcessLink)"
        }
        Write-Information -MessageData "---"
    }
}

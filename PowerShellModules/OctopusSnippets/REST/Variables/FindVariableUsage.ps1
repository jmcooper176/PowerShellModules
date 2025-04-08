<#
 =============================================================================
<copyright file="FindVariableUsage.ps1" company="John Merryweather Cooper
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
This file "FindVariableUsage.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Define working variables
$octopusURL = "https://your.octopus.app"
$octopusAPIKey = "API-YOURAPIKEY"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

# Specify the Space to search in
$spaceName = "Default"

# Specify the Variable to find, without OctoStache syntax
# e.g. For #{MyProject.Variable} -> use MyProject.Variable
$variableToFind = "MyProject.Variable"

# Search through Project's Deployment Processes?
$searchDeploymentProcesses = $True

# Search through Project's Runbook Processes?
$searchRunbooksProcesses = $True

# Search through Variable Set values?
$searchVariableSets = $False

# Optional: set a path to export to csv
$csvExportPath = ""

$variableTracking = @()
$octopusURL = $octopusURL.TrimEnd('/')

# Get space
$space = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/spaces/all" -Headers $header) | Where-Object -FilterScript { $_.Name -eq $spaceName }

Write-Information -MessageData "Looking for usages of variable named $variableToFind in space: '$spaceName'"

# Get all projects
$projects = Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects/all" -Headers $header

# Loop through projects
foreach ($project in $projects) {
    Write-Information -MessageData "Checking project '$($project.Name)'"
    # Get project variables
    $projectVariableSet = Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/variables/$($project.VariableSetId)" -Headers $header

    # Check to see if variable is named in project variables.
    $matchingNamedVariables = $projectVariableSet.Variables | Where-Object -FilterScript { $_.Name -ieq "$variableToFind" }
    if ($null -ne $matchingNamedVariables) {
        foreach ($match in $matchingNamedVariables) {
            $result = [pscustomobject]@{
                Project           = $project.Name
                VariableSet       = $null
                MatchType         = "Named Project Variable"
                Context           = $match.Name
                Property          = $null
                AdditionalContext = $match.Value
                Link              = "$octopusURL$($project.Links.Web)/variables"
            }

            # Add and de-dupe later
            $variableTracking += $result
        }
    }

    # Check to see if variable is referenced in other project variable values.
    $matchingValueVariables = $projectVariableSet.Variables | Where-Object -FilterScript { $_.Value -like "*#{$variableToFind}*" }
    if ($null -ne $matchingValueVariables) {
        foreach ($match in $matchingValueVariables) {
            $result = [pscustomobject]@{
                Project           = $project.Name
                VariableSet       = $null
                MatchType         = "Referenced Project Variable"
                Context           = $match.Name
                Property          = $null
                AdditionalContext = $match.Value
                Link              = "$octopusURL$($project.Links.Web)/variables"
            }
            # Add and de-dupe later
            $variableTracking += $result
        }
    }

    # Search Deployment process if enabled
    if ($searchDeploymentProcesses -eq $True) {
        # Get project deployment process
        $deploymentProcess = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/deploymentprocesses/$($project.DeploymentProcessId)" -Headers $header)

        # Loop through steps
        foreach ($step in $deploymentProcess.Steps) {
            $props = $step | Get-Member | Where-Object -FilterScript { $_.MemberType -eq "NoteProperty" }
            foreach ($prop in $props) {
                $propName = $prop.Name
                $json = $step.$propName | ConvertTo-Json -Compress -Depth 10
                if ($null -ne $json -and ($json -like "*$variableToFind*")) {
                    $result = [pscustomobject]@{
                        Project           = $project.Name
                        VariableSet       = $null
                        MatchType         = "Step"
                        Context           = $step.Name
                        Property          = $propName
                        AdditionalContext = $null
                        Link              = "$octopusURL$($project.Links.Web)/deployments/process/steps?actionId=$($step.Actions[0].Id)"
                    }
                    # Add and de-dupe later
                    $variableTracking += $result
                }
            }
        }
    }

    # Search Runbook processes if enabled
    if ($searchRunbooksProcesses -eq $True) {

        # Get project runbooks
        $runbooks = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects/$($project.Id)/runbooks?skip=0&take=5000" -Headers $header)

        # Loop through each runbook
        foreach ($runbook in $runbooks.Items) {
            # Get runbook process
            $runbookProcess = (Invoke-RestMethod -Method Get -Uri "$octopusURL$($runbook.Links.RunbookProcesses)" -Headers $header)

            # Loop through steps
            foreach ($step in $runbookProcess.Steps) {
                $props = $step | Get-Member | Where-Object -FilterScript { $_.MemberType -eq "NoteProperty" }
                foreach ($prop in $props) {
                    $propName = $prop.Name
                    $json = $step.$propName | ConvertTo-Json -Compress -Depth 10
                    if ($null -ne $json -and ($json -like "*$variableToFind*")) {
                        $result = [pscustomobject]@{
                            Project           = $project.Name
                            VariableSet       = $null
                            MatchType         = "Runbook Step"
                            Context           = $runbook.Name
                            Property          = $propName
                            AdditionalContext = $step.Name
                            Link              = "$octopusURL$($project.Links.Web)/operations/runbooks/$($runbook.Id)/process/$($runbook.RunbookProcessId)/steps?actionId=$($step.Actions[0].Id)"
                        }
                        # Add and de-dupe later
                        $variableTracking += $result
                    }
                }
            }
        }
    }
}

if ($searchVariableSets -eq $True) { 
    $VariableSets = (Invoke-RestMethod -Method Get "$OctopusURL/api/libraryvariablesets?contentType=Variables" -Headers $header).Items

    foreach ($VariableSet in $VariableSets) {
        Write-Information -MessageData "Checking Variable Set: $($VariableSet.Name)"
        $variables = (Invoke-RestMethod -Method Get "$OctopusURL/$($VariableSet.Links.Variables)" -Headers $header).Variables | Where-Object -FilterScript { $_.Value -like "*#{$variableToFind}*" }
        $link = ($VariableSet.Links.Self -replace "/api", "app#") -replace "/libraryvariablesets/", "/library/variables/"
        foreach ($variable in $variables) {
            $result = [pscustomobject]@{
                Project           = $null
                VariableSet       = $VariableSet.Name
                MatchType         = "Variable Set"
                Context           = $variable.Name
                Property          = $null
                AdditionalContext = $variable.Value
                Link              = "$octopusURL$($link)"
            }

            # Add and de-dupe later
            $variableTracking += $result
        }
    }
}

# De-dupe
$variableTracking = @($variableTracking | Sort-Object -Property * -Unique)

if ($variableTracking.Count -gt 0) {
    Write-Information -MessageData ""
    Write-Information -MessageData "Found $($variableTracking.Count) results:"
    $variableTracking
    if (![string]::IsNullOrWhiteSpace($csvExportPath)) {
        Write-Information -MessageData "Exporting results to CSV file: $csvExportPath"
        $variableTracking | Export-Csv -Path $csvExportPath -NoTypeInformation
    }
}
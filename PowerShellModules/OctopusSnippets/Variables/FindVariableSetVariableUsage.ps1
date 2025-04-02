<#
 =============================================================================
<copyright file="FindVariableSetVariableUsage.ps1" company="U.S. Office of Personnel
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
This file "FindVariableSetVariableUsage.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Load assembly
Add-Type -Path 'path:\to\Octopus.Client.dll'


# Define working variables
$octopusURL = "https://YourURL"
$octopusAPIKey = "API-YourAPIKey"
$spaceName = "Default"
$searchDeploymentProcesses = $true
$searchRunbookProcesses = $true
$csvExportPath = "path:\to\variable.csv"


# Specify the name of the Library VariableSet to use to find variables usage of
$variableSetVariableUsagesToFind = "My-Variable-Set"

# Search through Project's Deployment Processes?
$searchDeploymentProcesses = $True

# Search through Project's Runbook Processes?
$searchRunbooksProcesses = $True



$variableTracking = @()

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint($octopusURL, $octopusAPIKey)
$repository = New-Object -TypeName Octopus.Client.OctopusRepository($endpoint)
$client = New-Object -TypeName Octopus.Client.OctopusClient($endpoint)

# Get space
$space = $repository.Spaces.FindByName($spaceName)
$repositoryForSpace = $client.ForSpace($space)

# Get first matching variableset record
$libraryVariableSet = $repositoryForSpace.LibraryVariableSets.FindByName($variableSetVariableUsagesToFind)

# Get variables for library variable set
$variableSet = $repositoryForSpace.VariableSets.Get($libraryVariableSet.VariableSetId)
$variables = $variableSet.Variables



Write-Information -MessageData "Looking for usages of variables from variable set '$variableSetVariableUsagesToFind' in space: '$spaceName'"

# Get all projects
$projects = $repositoryForSpace.Projects.GetAll()

# Loop through projects
foreach ($project in $projects)
{
    Write-Information -MessageData "Checking project '$($project.Name)'"
    
    # Get project variables
    $projectVariableSet = $repositoryForSpace.VariableSets.Get($project.VariableSetId)
    
    # Check to see if there are any project variable values that reference any of the library set variables.
    foreach($variable in $variables) {
        
        $matchingValueVariables = $projectVariableSet.Variables | Where-Object -FilterScript {$_.Value -like "*$($variable.Name)*"}

        if($null -ne $matchingValueVariables) {
            foreach($match in $matchingValueVariables) {
                $result = [pscustomobject]@{
                    Project = $project.Name
                    MatchType = "Referenced Project Variable"
                    VariableSetVariable = $variable.Name
                    Context = $match.Name
                    AdditionalContext = $match.Value
                    Property = $null
                    Link = "$octopusURL$($project.Links.Web)/variables"
                }
                # Add and de-dupe later
                $variableTracking += $result
            }
        }
    }

    # Search Deployment process if configured
    if($searchDeploymentProcesses -eq $True -and $project.IsVersionControlled -ne $true) {

        # Get project deployment process
        $deploymentProcess = $repositoryForSpace.DeploymentProcesses.Get($project.DeploymentProcessId)

        # Loop through steps
        foreach($step in $deploymentProcess.Steps)
        {
            foreach ($action in $step.Actions)
            {
                foreach ($property in $action.Properties.Keys)
                {
                    foreach ($variable in $variables)
                    {
                        if ($action.Properties[$property].Value -like "*$($variable.Name)*")
                        {
                            $result = [pscustomobject]@{
                                Project = $project.Name
                                MatchType= "Step"
                                VariableSetVariable = $variable.Name
                                Context = $step.Name
                                AdditionalContext = $null
                                Property = $propName
                                Link = "$octopusURL$($project.Links.Web)/deployments/process/steps?actionId=$($step.Actions[0].Id)"
                            }
                            # Add and de-dupe later
                            $variableTracking += $result

                        }
                    }
                }
            }
        }
    }

    # Search Runbook processes if configured
    if($searchRunbooksProcesses -eq $True) {
        
        # Get project runbooks
        $runbooks = $repositoryForSpace.Projects.GetAllRunbooks($project)

        # Loop through each runbook
        foreach($runbook in $runbooks)
        {
            # Get runbook process
            $runbookProcess = $repositoryForSpace.RunbookProcesses.Get($runbook.RunbookProcessId)
            
            # Loop through steps
            foreach($step in $runbookProcess.Steps)
            {
                foreach ($action in $step.Actions)
                {
                    foreach ($property in $action.Properties.Keys)
                    {
                        foreach ($variable in $variables)
                        {
                            if ($action.Properties[$property].Value -like "*$($variable.Name)*")
                            {
                                $result = [pscustomobject]@{
                                    Project = $project.Name
                                    MatchType= "Runbook Step"
                                    VariableSetVariable = $variable.Name
                                    Context = $runbook.Name
                                    AdditionalContext = $step.Name
                                    Property = $propName
                                    Link = "$octopusURL$($project.Links.Web)/operations/runbooks/$($runbook.Id)/process/$($runbook.RunbookProcessId)/steps?actionId=$($step.Actions[0].Id)"
                                }
                                # Add and de-dupe later
                                $variableTracking += $result
                            }
                        }
                    }
                }                
            }
        }
    }
}

# De-dupe
$variableTracking = @($variableTracking | Sort-Object -Property * -Unique)

if($variableTracking.Count -gt 0) {
    Write-Information -MessageData ""
    Write-Information -MessageData "Found $($variableTracking.Count) results:"
    if (![string]::IsNullOrWhiteSpace($csvExportPath)) {
        Write-Information -MessageData "Exporting results to CSV file: $csvExportPath"
        $variableTracking | Export-Csv -Path $csvExportPath -NoTypeInformation
    }
}
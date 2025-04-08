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

# Load assembly
Add-Type -Path 'path:\to\Octopus.Client.dll'
$octopusURL = "https://YourURL"
$octopusAPIKey = "API-YourAPIKey"
$spaceName = "Default"
$variableToFind = "MyProject.Variable"
$searchDeploymentProcesses = $true
$searchRunbookProcesses = $true
$csvExportPath = "path:\to\CSVFile.csv"

$variableTracking = @()


$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint($octopusURL, $octopusAPIKey)
$repository = New-Object -TypeName Octopus.Client.OctopusRepository($endpoint)
$client = New-Object -TypeName Octopus.Client.OctopusClient($endpoint)

# Get space
$space = $repository.Spaces.FindByName($spaceName)
$repositoryForSpace = $client.ForSpace($space)

Write-Information -MessageData "Looking for usages of variable named $variableToFind in space $($space.Name)"

# Get all projects
$projects = $repositoryForSpace.Projects.GetAll()

# Loop through projects
foreach ($project in $projects)
{
    Write-Information -MessageData "Checking $($project.Name)"
    
    # Get varaible set
    $projectVariableSet = $repositoryForSpace.VariableSets.Get($project.VariableSetId)
    
    # Find any name matches
    $matchingNamedVariable = $projectVariableSet.Variables | Where-Object -FilterScript {$_.Name -like "*$variableToFind*"}

    if ($null -ne $matchingNamedVariable)
    {
        foreach ($match in $matchingNamedVariable)
        {
            # Create new hashtable
            $result = [pscustomobject]@{
                Project = $project.Name
                MatchType = "Named Project Variable"
                Context = $match.Name
                Property = $null
                AdditionalContext = $match.Value
                Link = $project.Links["Variables"]
            }

            $variableTracking += $result
        }
    }

    # Find any value matches
    $matchingValueVariables = $projectVariableSet.Variables | Where-Object -FilterScript {$_.Value -like "*$variableToFind*"}

    if ($null -ne $matchingValueVariables)
    {
        foreach ($match in $matchingValueVariables)
        {
            $result = [pscustomobject]@{
                Project = $project.Name
                MatchType = "Referenced Project Variable"
                Context = $match.Name
                Property = $null
                AdditionalContext = $match.Value
                Link = $project.Links["Variables"]
            }

            $variableTracking += $result
        }
    }

    if ($searchDeploymentProcesses -eq $true)
    {
        if ($project.IsVersionControlled -ne $true)
        {
            # Get deployment process
            $deploymentProcess = $repositoryForSpace.DeploymentProcesses.Get($project.DeploymentProcessId)

            # Loop through steps
            foreach ($step in $deploymentProcess.Steps)
            {               
                foreach ($action in $step.Actions)
                {
                    foreach ($property in $action.Properties.Keys)
                    {
                        if ($action.Properties[$property].Value -like "*$variableToFind*")
                        {
                            $result = [pscustomobject]@{
                                Project = $project.Name
                                MatchType = "Step"
                                Context = $step.Name
                                Property = $property
                                AdditionalContext = $null
                                Link = "$octopusURL$($project.Links.Web)/deployments/process/steps?actionid=$($action.Id)"
                            }

                            $variableTracking += $result
                        }
                    }
                }
            }
        }
        else
        {
            Write-Information -MessageData "$($project.Name) is version controlled, skipping searching the deployment process."
        }
    }

    if ($searchRunbookProcesses -eq $true)
    {
        # Get project runbooks
        $runbooks = $repositoryForSpace.Projects.GetAllRunbooks($project)

        # Loop through runbooks
        foreach ($runbook in $runbooks)
        {
            # Get Runbook process
            $runbookProcess = $repositoryForSpace.RunbookProcesses.Get($runbook.RunbookProcessId)

            foreach ($step in $runbookProcess.Steps)
            {
                foreach ($action in $step.Actions)
                {
                    foreach ($proprety in $action.Properties.Keys)
                    {
                        if ($action.Properties[$property].Value -like "*$variableToFind*")
                        {
                            $result = [pscustomobject]@{
                                Project = $project.Name
                                MatchType = "Runbook Step"
                                Context = $runbook.Name
                                Property = $property
                                AdditionalContext = $step.Name
                                Link = "$octopusURL$($project.Links.Web)/operations/runbooks/$($runbook.Id)/process/$($runbook.RunbookProcessId)/steps?actionId=$($action.Id)"
                            }

                            $variableTracking += $result                            
                        }
                    }
                }
            }
        }
    }
}

# De-duplicate
$variableTracking = @($variableTracking | Sort-Object -Property * -Unique)

if ($variableTracking.Count -gt 0)
{
    Write-Information -MessageData ""
    Write-Information -MessageData "Found $($variableTracking.Count) results:"
    $variableTracking

    if(![string]::IsNullOrWhiteSpace($csvExportPath)) 
    {
        Write-Information -MessageData "Exporting results to CSV file: $csvExportPath"
        $variableTracking | Export-Csv -Path $csvExportPath -NoTypeInformation
    }
}
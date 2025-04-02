<#
 =============================================================================
<copyright file="CheckProjectsForManualIntervention.ps1" company="U.S. Office of Personnel
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
This file "CheckProjectsForManualIntervention.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$OctopusURL = ## YOUR URL
$APIKey = ## YOUR API KEY
$CurrentSpaceId = $OctopusParameters["Octopus.Space.Id"]
$projectIdsToIgnore = ## PROJECTS TO IGNORE

$projectListToIgnore = $projectIdsToIgnore.Split(",")

$header = @{ "X-Octopus-ApiKey" = $APIKey }

Write-Information -MessageData "Getting list of all spaces"
$spaceList = (Invoke-WebRequest -Uri "$OctopusUrl/api/Spaces?skip=0&take=100000" -Headers $header).content | ConvertFrom-Json
$badProjectsFound = $false
$badProjectList = ""

foreach ($space in $spaceList.Items)
{
    $spaceId = $space.Id
    if ($spaceId -ne $CurrentSpaceId)
    {
        Write-Information -MessageData "Getting all the projects for $spaceId"
        $projectList = (Invoke-WebRequest -Uri "$OctopusUrl/api/$spaceId/projects/all" -Headers $header).content | ConvertFrom-Json
        $projectCount = $taskList.Count

        Write-Information -MessageData "Found $projectCount projects in $spaceId space"
        foreach ($project in $projectList)
        {
            $projectId = $project.Id
            $projectName = $project.Name
            $projectWebUrl = $OctopusUrl + $project.Links.Web

            if ($projectListToIgnore -contains $projectId)
            {
                Write-Information -MessageData "Project $projectName in $spaceId is on the ignore list, skipping"
            }
            else
            {
                Write-Information -MessageData "Getting the deployment process for $projectName in $spaceId"
                $deploymentProcessUrl = $OctopusUrl + $project.Links.DeploymentProcess
                $projectProcess = (Invoke-WebRequest -Uri $deploymentProcessUrl -Headers $header).content | ConvertFrom-Json

                $manualInterventionActive = $false
                $trafficCopDeployment = $false

                foreach ($step in $projectProcess.Steps)
                {
                    foreach ($action in $step.Actions)
                    {
                        if ($action.ActionType -eq "Octopus.DeployRelease")
                        {
                            $trafficCopDeployment = $true
                        }
                        elseif ($action.ActionType -eq "Octopus.Manual" -and $action.IsDisabled -eq $false)
                        {
                            $manualInterventionActive = $true
                        }
                    }
                }

                if ($trafficCopDeployment -eq $true)
                {
                    Write-Information -MessageData "Project $projectName is a traffic cop project, skipping checks"
                }
                elseif ($manualInterventionActive -eq $false)
                {
                    Write-Highlight "Project $projectName is missing a manual intervention step"
                    $badProjectsFound = $true
                    $badProjectList += "The project $projectName found at $projectWebUrl does not have a active manual intervention step
"
                }
            }

            
        }
        
    }
}

Set-OctopusVariable -name "BadProjectsFound" -value $badProjectsFound
Set-OctopusVariable -name "BadProjectList" -value $badProjectList
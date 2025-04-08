<#
 =============================================================================
<copyright file="GetCurrentTargetCountPerProject.ps1" company="John Merryweather Cooper
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
This file "GetCurrentTargetCountPerProject.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# Gives a count of enabled targets per project at the time of the script running
#
# Output in JSON in the format:
# [{
#     "Id": "Projects-61",
#     "Name": "Canary Environment",
#     "WebUrl": "https://samples.octopus.app/app#/Spaces-43/projects/Projects-61",
#     "space": "Spaces-43",
#     "TargetRoles": [
#       "@{Name=OctoFX-Web; CountOfTargets=9}"
#     ],
#     "CountOfTargets": 9
#   },
#   {
#     "Id": "Projects-63",
#     "Name": "One Environment",
#     "WebUrl": "https://samples.octopus.app/app#/Spaces-43/projects/Projects-63",
#     "space": "Spaces-43",
#     "TargetRoles": [
#       "@{Name=OctoFX-Web-Canary; CountOfTargets=2}",
#       "@{Name=OctoFX-Web; CountOfTargets=9}"
#     ],
#     "CountOfTargets": 11
#   },
#   {
#     "Id": "Projects-41",
#     "Name": "Project1",
#     "WebUrl": "https://samples.octopus.app/app#/Spaces-42/projects/Projects-41",
#     "space": "Spaces-42",
#     "TargetRoles": [],
#     "CountOfTargets": 0
#   }
# ]
#
#-------------------------------------------------------------------------

$OctopusURL = ## YOUR URL
$APIKey = ## YOUR API KEY
$projectIdsToIgnore = "" ## PROJECTS TO IGNORE

$projectListToIgnore = $projectIdsToIgnore.Split(",")

# ---- Utility Functions --------------------------
# Create custom object
function Get-TargetObject($targetRoleName){
    return [pscustomobject] @{   
        'Name' = $targetRoleName
        'CountOfTargets' = 0
    }
}

function Get-ProjectObject($projectId, $projectName, $projectWebUrl, $space)
{      
    return [pscustomobject] @{    
        'Id' = $projectId 
        'Name' = $projectName
        'WebUrl' = $projectWebUrl
        'space' = $space
        'TargetRoles' = @()
        'CountOfTargets' = 0
    }
}

#-------------------------------------------------------------------------
function Get-ProjectTargetCount(){
    $header = @{ "X-Octopus-ApiKey" = $APIKey }

    Write-Information -MessageData "Getting list of all spaces"
    $spaceList = (Invoke-WebRequest -Uri "$OctopusUrl/api/Spaces?skip=0&take=10" -Headers $header).content | ConvertFrom-Json
    $projects = @();

    foreach ($space in $spaceList.Items)
    {
        $spaceId = $space.Id
        Write-Information -MessageData "Getting all the projects for $spaceId"
        $projectList = (Invoke-WebRequest -Uri "$OctopusUrl/api/$spaceId/projects/all" -Headers $header).content | ConvertFrom-Json
        $projectCount = $taskList.Count


        Write-Information -MessageData "Found $projectCount projects in $spaceId space"
        foreach ($project in $projectList)
        {
            $projectWebUrl = $OctopusUrl + $project.Links.Web
            $projectObj = Get-ProjectObject $project.Id $project.Name $projectWebUrl $spaceId
            $targets = @();


            if ($projectListToIgnore -contains $projectObj.Id)
            {
                Write-Information -MessageData "Project $($projectObj.Name) in $spaceId is on the ignore list, skipping"
            }
            else
            {
                Write-Information -MessageData "Getting the deployment process for $($projectObj.Name) in $spaceId"
                $deploymentProcessUrl = $OctopusUrl + $project.Links.DeploymentProcess
                $projectProcess = (Invoke-WebRequest -Uri $deploymentProcessUrl -Headers $header).content | ConvertFrom-Json

                foreach ($step in $projectProcess.Steps)
                {
                    if($step.properties.'Octopus.Action.TargetRoles'){ 
                        $roles = $step.properties.'Octopus.Action.TargetRoles'
                        
                        if ($targets.Name -notcontains $roles)
                        {
                            $tRole = Get-TargetObject $roles
                            $targets += $tRole
                        }
                    }
                }
                $projectObj.TargetRoles = $targets

                $targetCountForProject = 0
                foreach ($targetRole in $targets){
                    Write-Information -MessageData $targetRole
                    $targetUrl = "$OctopusUrl/api/$spaceId/machines?skip=0&take=2147483647&roles=$($targetRole.Name)&isDisabled=false"
                    $targetList = (Invoke-WebRequest -Uri $targetUrl -Headers $header).content | ConvertFrom-Json
                    $targetRole.CountOfTargets = $targetList.TotalResults
                    $targetCountForProject += $targetList.TotalResults
                }
                $projectObj.CountOfTargets = $targetCountForProject
            }
            $projects += $projectObj
            
        }

    }

    $projects | ConvertTo-Json
}

Get-ProjectTargetCount
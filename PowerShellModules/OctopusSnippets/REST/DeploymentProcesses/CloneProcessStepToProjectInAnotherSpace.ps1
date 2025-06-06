<#
 =============================================================================
<copyright file="CloneProcessStepToProjectInAnotherSpace.ps1" company="John Merryweather Cooper
">
    Copyright � 2025, John Merryweather Cooper.
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
This file "CloneProcessStepToProjectInAnotherSpace.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$OctopusUrl = "https://octopusURL" # Your URL
$ApiKey = "API-KEY" # Your API Key
$sourceProjectName = ""
$destinationProjectName = ""
$stepNameToClone = ""
$exportSpaceId = ""
$destinationSpaceId = ""

$header = @{ "X-Octopus-ApiKey" = $ApiKey }

# The Name does a starts with search
$sourceProjectList = Invoke-RestMethod "$octopusUrl/api/$exportSpaceId/projects?name=$sourceProjectName" -Headers $header
$sourceProject = $sourceProjectList.Items | Where-Object -FilterScript {$_.Name -eq $sourceProjectName}

$deploymentProcessUrl = $OctopusUrl + $sourceProject.Links.DeploymentProcess
$deploymentProcess = Invoke-RestMethod $deploymentProcessUrl -Headers $header

$stepToClone = $deploymentProcess.Steps | Where-Object -FilterScript {$_.Name -eq $stepNameToClone}
$stepToClone.Id = ""
foreach ($action in $stepToClone.Actions)
{
    $action.Id = ""
}

Write-Information -MessageData $stepToClone

$destinationProjectList = Invoke-RestMethod "$octopusUrl/api/$destinationSpaceId/projects?skip=0&take=10000" -Headers $header
$destinationProject = $destinationProjectList.Items | Where-Object -FilterScript {$_.Name -eq $destinationProjectName}

# If different permissions are required on the import space, update the API key value here to the key used for the import space.
$updateHeader = @{
    "X-Octopus-ApiKey" = $ApiKey
    "x-octopus-user-agent" = "Api Script"
}

$deploymentProcessUrl = $OctopusUrl + $destinationProject.Links.DeploymentProcess
$projectDeploymentProcess = Invoke-RestMethod $deploymentProcessUrl -Headers $header

$projectDeploymentProcess.Steps += $stepToClone

$deploymentProcessAsJson = $projectDeploymentProcess | ConvertTo-Json -Depth 8

Invoke-WebRequest -Uri $deploymentProcessUrl -Headers $updateHeader -Method Put -Body $deploymentProcessAsJson -ContentType "application/json"

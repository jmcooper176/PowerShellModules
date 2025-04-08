<#
 =============================================================================
<copyright file="RemoveInvalidChannelsFromDeploymentProcess.ps1" company="John Merryweather Cooper
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
This file "RemoveInvalidChannelsFromDeploymentProcess.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# Script written to fix broken channel references on a deployment process
# https://github.com/OctopusDeploy/Issues/issues/5267

## CONFIG ##
$OctopusAPIkey = "" #Octopus API Key
$OctopusURL = "" #Octopus root url
$ProjectName = "" #Name of the project

## PROCESS ##

$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

$allprojects = (Invoke-WebRequest -Uri $OctopusURL/api/projects/all -Headers $header).content | ConvertFrom-Json
$allchannels = (Invoke-WebRequest -Uri $OctopusURL/api/channels/all -Headers $header).content | ConvertFrom-Json

$project = $allprojects | Where-Object -FilterScript { $_.name -eq $ProjectName }

if ($null -ne $project) {
    $deploymentProcessUrl = $project.Links.DeploymentProcess
    $deploymentProcess = (Invoke-WebRequest -Uri "$($OctopusURL)$($deploymentProcessUrl)" -Headers $header).content | ConvertFrom-Json

    $channelsInProject = $allchannels | Where-Object -FilterScript { $_.ProjectId -eq $project.Id }

    foreach ($step in $deploymentProcess.Steps) {
        foreach ($action in $step.Actions) {
            # filter the channels on the action to only the channels that exist
            $action.Channels = @($action.Channels | Where-Object -FilterScript { $channelId = $_; $channelsInProject | Where-Object -FilterScript { $_.Id -eq $channelId }})
        }
    }

    $deploymentProcessJson = $deploymentProcess | ConvertTo-Json -depth 100

    Invoke-WebRequest -Uri "$($OctopusURL)$($deploymentProcessUrl)" -Method Put -Headers $header -Body $deploymentProcessJson
} else {
    Write-Error -Message "Project [$ProjectName] not found in $OctopusURL"
}

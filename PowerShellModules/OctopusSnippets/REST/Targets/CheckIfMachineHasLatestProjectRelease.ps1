<#
 =============================================================================
<copyright file="CheckIfMachineHasLatestProjectRelease.ps1" company="U.S. Office of Personnel
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
This file "CheckIfMachineHasLatestProjectRelease.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# Define Octopus variables
$octopusURL = "https://youroctopusurl"
$octopusAPIKey = "API-KEY"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

# Define working variables
$spaceName = "Default"
$channelName = "Default"
$machineName = "MyMachineName"
# This is the url-friendly name of the project e.g. "My Project" would be "my-project"
$projectSlug = "my-project"

try
{
    # Get space
    $space = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/spaces/all" -Headers $header) | Where-Object -FilterScript {$_.Name -eq $spaceName}

    # Get machine details
    $matchingMachines = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/machines?partialName=$machineName" -Headers $header)
    $machine = $matchingMachines.Items | Select-Object -First 1

    # Tweak this to change the number of machine tasks returned
    $machineTaskCount = 100
    
    # Get machine tasks
    $machineTaskSearch = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/machines/$($machine.Id)/tasks?skip=0&take=$machineTaskCount" -Headers $header)
    $machineTaskDeploymentIds = $machineTaskSearch.Items | Select-Object -Property @{Name="DeploymentIds"; Expression={ $_.Arguments.DeploymentId}} | Select-Object -ExpandProperty DeploymentIds
    
    # Get project details
    $project = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects/$projectSlug" -Headers $header)

    # Get matching project channel
    $channels = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects/$($project.Id)/channels?partialName=$channelName" -Headers $header)
    $channel = $channels.Items | Select-Object -First 1
    
    # Tweak this to change the number of release records returned
    $releaseCount = 100
    
    # Get project releases
    $releases = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects/$($project.Id)/releases?skip=0&take=$releaseCount" -Headers $header)
    
    # Get latest release matching project channel
    $latestRelease = $releases.Items | Where-Object -FilterScript {$_.ChannelId -eq $($channel.Id)} | Select-Object -First 1
        
    # Tweak this to change the number of deployment records returned
    $deploymentCount = 100

    # Get release deployments
    $releaseDeploymentsResource = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/releases/$($latestRelease.Id)/deployments?skip=0&take=$deploymentCount" -Headers $header)
    $releaseDeployments = $releaseDeploymentsResource.Items

    # Search release deployments for machine task deployment Id.
    $foundRelease = $False
    foreach($deployment in $releaseDeployments)
    {
        $releaseDeploymentId = $deployment.Id
        if($machineTaskDeploymentIds -contains $releaseDeploymentId) {
            $foundRelease = $True
            Write-Information -MessageData "Release $($latestRelease.Version) found for machine $($machine.Name) - deploymentId: $($releaseDeploymentId)"
        }
    }
    if($foundRelease -eq $False)
    {
        Write-Information -MessageData "Couldnt find release $($latestRelease.Version) for machine $($machine.Name)"
    }
}   
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}
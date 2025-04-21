<#
 =============================================================================
<copyright file="GetDeploymentLifecyclePhase.ps1" company="John Merryweather Cooper
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
This file "GetDeploymentLifecyclePhase.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$APIKey = "API-XXXXX" # Requires an API Key, preferably as a sensitive variable

$OctopusUrl = $OctopusParameters["Octopus.Web.ServerUri"]
$ProjectId = $OctopusParameters["Octopus.Project.Id"]
$ChannelId = $OctopusParameters["Octopus.Release.Channel.Id"]
$OctopusEnvironmentName = $OctopusParameters["Octopus.Environment.Name"]
$OctopusEnvironmentId = $OctopusParameters["Octopus.Environment.Id"]
$OctopusSpaceId = $OctopusParameters["Octopus.Space.Id"]

$header = @{ "X-Octopus-ApiKey" = $APIKey }
$OctopusChannels = (Invoke-RestMethod "$OctopusUrl/api/$OctopusSpaceId/channels/$ChannelId" -Headers $header)

$LifeCycleId = $OctopusChannels.LifecycleId
if ([string]::IsNullOrWhitespace($LifeCycleId))
{
	Write-Information -MessageData "LifecycleId is null, presumably due to Default Channel"
    $OctopusProject = (Invoke-RestMethod "$OctopusUrl/api/$OctopusSpaceId/projects/$ProjectId" -Headers $header)
	$LifeCycleId = $OctopusProject.LifecycleId
}
if ([string]::IsNullOrWhitespace($LifeCycleId))
{
	throw "Couldnt find LifeCycleId!"
}

Write-Information -MessageData "LifecycleId: " $LifeCycleId
$OctopusLifecycles = (Invoke-RestMethod "$OctopusUrl/api/$OctopusSpaceId/lifecycles/$LifeCycleId" -Headers $header)
$OctopusPhases = $OctopusLifecycles.Phases
foreach($phase in $OctopusPhases){
	foreach($environment in $phase.OptionalDeploymentTargets){
		if ($OctopusEnvironmentId -eq $environment){
			Write-Highlight "Environment: $($OctopusEnvironmentName)"
            Write-Highlight "Phase Name: $($phase.Name)"
            Exit 0
		}
	}
}

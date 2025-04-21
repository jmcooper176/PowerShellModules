<#
 =============================================================================
<copyright file="PromoteRelease.ps1" company="John Merryweather Cooper
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
This file "PromoteRelease.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
Add-Type -AssemblyName 'Octopus.Client'

$apikey = 'API-xx' # Get this from your profile
$octopusURI = 'http://octopus' # Your Octopus Server address

$projectName = "Web" # Name of the project to promote
$fromEnvironmentName = "Dev" # Name of the environment to promote from
$toEnvironmentName = "Staging" # Name of the environment to promote to

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint $octopusURI,$apikey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository $endpoint

$project = $repository.Projects.FindByName($projectName)
$environment = $repository.Environments.FindByName($fromEnvironmentName)
$toEnvironment = $repository.Environments.FindByName($toEnvironmentName)

$dashboard = $repository.Dashboards.GetDynamicDashboard($project.Id, $environment.Id)
$currentDeploymentInTest = $dashboard.Items | Where-Object -FilterScript {$_.IsCurrent} | Select-Object -First 1

$promotedDeployment = New-Object -TypeName Octopus.Client.Model.DeploymentResource
$promotedDeployment.EnvironmentId = $toEnvironment.Id
$promotedDeployment.ChannelId = $currentDeploymentInTest.ChannelId
$promotedDeployment.ProjectId = $currentDeploymentInTest.ProjectId
$promotedDeployment.ReleaseId = $currentDeploymentInTest.ReleaseId

$repository.Deployments.Create($promotedDeployment)

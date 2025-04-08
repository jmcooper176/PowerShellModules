<#
 =============================================================================
<copyright file="CreateAutoDeployTriggersForAllProjects.ps1" company="John Merryweather Cooper
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
This file "CreateAutoDeployTriggersForAllProjects.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
Add-Type -AssemblyName 'Octopus.Client' 

$apikey = 'API-MYAPIKEY' # Get this from your profile
$octopusURI = 'http://MY-OCTOPUS' # Your server address

$triggerEnvironment = "Dev" # Set this to whatever environment should auto deploy
$triggerRole = "Web-server" # Set this to the deployment target role that should auto deploy

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint $octopusURI,$apikey 
$repository = New-Object -TypeName Octopus.Client.OctopusRepository $endpoint

$environment = $repository.Environments.FindByName($triggerEnvironment)

$triggerFilter = New-Object -TypeName Octopus.Client.Model.Triggers.MachineFilterResource
$triggerFilter.EnvironmentIds.Add($environment.Id)
$triggerFilter.Roles.Add($triggerRole)
$triggerFilter.EventGroups.Add("MachineAvailableForDeployment")

$triggerAction = New-Object -TypeName Octopus.Client.Model.Triggers.AutoDeployActionResource
$triggerAction.ShouldRedeployWhenMachineHasBeenDeployedTo = $false

$projects = $repository.Projects.GetAll()

foreach ($project in $projects) {
    $repository.ProjectTriggers.CreateOrModify($project, "Automatically deploy to $triggerRole", $triggerFilter, $triggerAction)
}

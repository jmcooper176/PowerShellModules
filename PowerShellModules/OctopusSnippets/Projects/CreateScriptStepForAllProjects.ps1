<#
 =============================================================================
<copyright file="CreateScriptStepForAllProjects.ps1" company="U.S. Office of Personnel
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
This file "CreateScriptStepForAllProjects.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

Add-Type -AssemblyName 'Octopus.Client'

$apikey = 'API-XXXXXXXXXXXXXXXXXXXXXX' # Get this from your profile
$octopusURI = 'https://octopus.url' # Your server address

$stepName = "API-ADDED-STEP" # The name of the step to be created
$role = "Webserver" # The machine role to run this step against
$scriptBody = "Write-Information -MessageData 'Hello world'" # The body of the script step

## Uncomment the below line (And the other two) to scope the step to an Environment ##
#$environment = "Dev" #  The name of the Environment to scope step to

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint $octopusURI,$apikey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository $endpoint

$allProjects = $repository.Projects.GetAll()

## Uncomment the below line to scope the step to an Environment ##
#$environmentToAdd = $repository.Environments.FindByName($environment).Id

$step = New-Object -TypeName Octopus.Client.Model.DeploymentStepResource # Create new step object
$step.Name = $stepName
$step.Condition = [Octopus.Client.Model.DeploymentStepCondition]::Success # Step run condition (Success = Only run if previous step succeeds)
$step.Properties.Add("Octopus.Action.TargetRoles", $role)

$scriptAction = New-Object -TypeName Octopus.Client.Model.DeploymentActionResource # Create the steps action type
$scriptAction.ActionType = "Octopus.Script" # This will define this as a Script step
$scriptAction.Name = $stepName
$scriptAction.Properties.Add("Octopus.Action.Script.ScriptBody", $scriptBody) # Put the script content into the steps script body

## Uncomment the below line to scope the step to an Environment ##
#$scriptAction.Environments.Add($environmentToAdd)

$step.Actions.Add($scriptAction) # Adds the step action to the step

# Foreach project in all projects: Get the deployment process, add the step we just built, modify deployment process with added step
foreach ($a in $allProjects) {

    $process = $repository.DeploymentProcesses.Get($a.DeploymentProcessId)
    $process.Steps.Add($step)
    $repository.DeploymentProcesses.Modify($process)

}

<#
 =============================================================================
<copyright file="findAzureAccountUsage.ps1" company="U.S. Office of Personnel
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
This file "findAzureAccountUsage.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

#This script will look for the usage of a specific Azure Account in all projects and print the results

##CONFIG##

$apikey = 'API-xxxx' # Get this from your profile

$octopusURI = 'http://YourOctopusServer' # Your Octopus Server address

$AccountName = "Your Account Name" #Name of the account that you want to find

##PROCESS##

Add-Type -AssemblyName 'Octopus.Client'

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint $octopusURI,$apikey 
$repository = New-Object -TypeName Octopus.Client.OctopusRepository $endpoint

$AllProjects = $Repository.Projects.FindAll()

$Account = $Repository.Accounts.FindByName($AccountName)

foreach($project in $AllProjects){
    $deploymentProcess = $Repository.DeploymentProcesses.Get($project.deploymentprocessid)

    foreach($step in $deploymentProcess.steps){
        foreach ($action in $step.actions){
            if($action.Properties['Octopus.Action.Azure.AccountId'].value -eq $Account.Id){
                Write-Output "Project - [$($project.name)]"
                Write-Output "`t- Account [$($account.name)] is being used in the step [$($step.name)]"
            }
        }
    }
}
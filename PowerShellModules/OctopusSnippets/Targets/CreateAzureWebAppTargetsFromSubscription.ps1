<#
 =============================================================================
<copyright file="CreateAzureWebAppTargetsFromSubscription.ps1" company="U.S. Office of Personnel
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
This file "CreateAzureWebAppTargetsFromSubscription.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$octopusServerUrl = "http://yourserver"
$octopusApiKey = "API-zzzzzzzzzzzzzzzzzzzzzzzz"
$azureSubscription = "zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz"

$envName = "AzureDemo"
$spName = "My Service Principal"

$roleName = "CloudWebServer"

#=========================================================================================================

add-type -path 'C:\tools\Octopus.Client.dll'

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint $octopusServerUrl, $octopusApiKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository $endpoint

$environmentDetails = $repository.Environments.FindByName($envName)
$environmentId = $environmentDetails.Id
Write-Information -MessageData "got Octopus env " $environmentDetails.Name

$accountDetails = $repository.Accounts.FindByName($spName)
$accountId = $accountDetails.Id
Write-Information -MessageData "got Octopus account " $accountDetails.Name


Login-AzureRmAccount
Select-AzureRmSubscription $azureSubscription

Write-Information -MessageData "connected to Azure..."

$webApps = Get-AzureRmWebApp

foreach ($webApp in $webApps)
{
    Write-Information -MessageData "target for " $webApp.SiteName

    $target = New-Object -TypeName Octopus.Client.Model.MachineResource -Property @{
                        Name = $webApp.SiteName
                        Roles = New-Object -TypeName Octopus.Client.Model.ReferenceCollection($roleName)
                        Endpoint = New-Object -TypeName Octopus.Client.Model.Endpoints.AzureWebAppEndpointResource -Property @{
                            AccountId = $accountId 
                            ResourceGroupName = $webApp.ResourceGroup
                            WebAppName = $webApp.SiteName }
                        EnvironmentIds = New-Object -TypeName Octopus.Client.Model.ReferenceCollection($environmentId)
                    };

    Write-Information -MessageData "creating target in Octopus for " $webApp.SiteName

    $repository.Machines.Create($target, $null);
}

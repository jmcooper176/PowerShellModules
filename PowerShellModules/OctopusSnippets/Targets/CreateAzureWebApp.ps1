<#
 =============================================================================
<copyright file="CreateAzureWebApp.ps1" company="John Merryweather Cooper
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
This file "CreateAzureWebApp.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# Load octopus.client assembly
Add-Type -Path "path\to\Octopus.Client.dll"

# Octopus variables
$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"
$azureServicePrincipalName = "MyAzureAccount"
$azureResourceGroupName = "MyResourceGroup"
$azureWebAppName = "MyAzureWebApp"
$spaceName = "default"
$environmentNames = @("Development", "Production")
$roles = @("MyRole")

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient $endpoint

try
{
    # Get space
    $space = $repository.Spaces.FindByName($spaceName)
    $repositoryForSpace = $client.ForSpace($space)

    # Get environment ids
    $environments = $repositoryForSpace.Environments.FindAll() | Where-Object -FilterScript {$environmentNames -contains $_.Name}

    # Get Azure account
    $azureAccount = $repositoryForSpace.Accounts.FindByName($azureServicePrincipalName)

    # Create new Azure Web App object
    $azureWebAppTarget = New-Object -TypeName Octopus.Client.Model.Endpoints.AzureWebAppEndpointResource
    $azureWebAppTarget.AccountId = $azureAccount.Id
    $azureWebAppTarget.ResourceGroupName = $azureResourceGroupName
    $azureWebAppTarget.WebAppName = $azureWebAppName

    # Create new machine object
    $machine = New-Object -TypeName Octopus.Client.Model.MachineResource
    $machine.Endpoint = $azureWebAppTarget
    $machine.Name = $azureWebAppName

    # Add Environments
    foreach ($environment in $environments)
    {
        # Add to target
        $machine.EnvironmentIds.Add($environment.Id)
    }

    # Add roles
    foreach ($role in $roles)
    {
        $machine.Roles.Add($role)
    }

    # Add to machine to space
    $repositoryForSpace.Machines.Create($machine)
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}

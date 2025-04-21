<#
 =============================================================================
<copyright file="RetrievePagedListOfDeploymentsToEnvironment.ps1" company="John Merryweather Cooper
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
This file "RetrievePagedListOfDeploymentsToEnvironment.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# Load octopus.client assembly
Add-Type -AssemblyName "Octopus.Client.dll"
$octopusURL = "https://your.octopus.app"
$octopusAPIKey = "API-KEY"

$spaceName = "Default"
$environmentName = "Development"

$endpoint = New-Object -TypeName.Client.OctopusServerEndpoint $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName.Client.OctopusRepository $endpoint

# Get space id
$space = $repository.Spaces.FindByName($spaceName)
Write-Information -MessageData "Using Space named $($space.Name) with id $($space.Id)"

# Create space specific repository
$repositoryForSpace = [Octopus.Client.OctopusRepositoryExtensions]::ForSpace($repository, $space)

# Get environment
$environment = $repositoryForSpace.Environments.FindByName($environmentName)

# Get deployments to environment
$projects = @()
$environments = @($environment.Id)
$deployments = New-Object -TypeName.Collections.Generic.List[System.Object]

$repositoryForSpace.Deployments.Paginate($projects, $environments, {param ($page)
    Write-Information -MessageData "Found $($page.Items.Count) deployments.";
    $deployments.AddRange($page.Items);
    return $True;
})

Write-Information -MessageData "Retrieved $($deployments.Count) deployments to environment $($environmentName)"

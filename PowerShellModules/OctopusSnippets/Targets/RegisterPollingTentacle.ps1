<#
 =============================================================================
<copyright file="RegisterPollingTentacle.ps1" company="John Merryweather Cooper
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
This file "RegisterPollingTentacle.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# Load octopus.client assembly
Add-Type -Path "c:\octopus.client\Octopus.Client.dll"

# Octopus variables
$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"
$spaceName = "default"
$hostName = "MyHost"
$tentacleThumbprint = "TentacleThumbprint"
$tentacleIdentifier = "PollingTentacleIdentifier" # Must match value in Tentacle.config file on tentacle machine; ie poll://RandomCharacters
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

    # Create new polling tentacle resource
    $newTarget = New-Object -TypeName Octopus.Client.Model.Endpoints.PollingTentacleEndpointResource

    $newTarget.Uri = "poll://$tentacleIdentifier"
    $newTarget.Thumbprint = $tentacleThumbprint

    # Create new machien resourece
    $tentacle = New-Object -TypeName Octopus.Client.Model.MachineResource
    $tentacle.Endpoint = $newTarget
    $tentacle.Name = $hostName
    
    
    # Add properties to host
    foreach ($environment in $environments)
    {
        # Add to target
        $tentacle.EnvironmentIds.Add($environment.Id)
    }

    foreach ($role in $roles)
    {
        # Add to target
        $tentacle.Roles.Add($role)
    }
        
    # Add to machine to space
    $repositoryForSpace.Machines.Create($tentacle)
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}
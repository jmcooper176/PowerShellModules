<#
 =============================================================================
<copyright file="Get-SpaceRepository.ps1" company="U.S. Office of Personnel
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
<date>Created:  2025-2-19</date>
<summary>
This file "Get-SpaceRepository.ps1" is part of "InvokeOctopusRunbook".
</summary>
<remarks>description</remarks>
=============================================================================
#>

[CmdletBinding()] # Support -Verbose switch
[OutputType('Octopus.Client.RepositoryScope')]
param (
    [parameter(Mandatory)][string]$SpaceIdentifier,
    [parameter(Mandatory)][string]$OctopusBaseUrl,
    [parameter(Mandatory)][string]$OctopusApiKey
)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

& (Join-Path $PSScriptRoot 'Add-OctopusBootstrappedFunctionsIfMissing.ps1')
& (Join-Path $PSScriptRoot 'Load-OctopusClientDlls.ps1')
Write-Verbose -Message 'Create client endpoint to Octopus'
$endpoint = [Octopus.Client.OctopusServerEndpoint]::new($OctopusBaseUrl, $OctopusApiKey)
Write-Verbose -Message 'Create client object using the endpoint'
$client = [Octopus.Client.OctopusClient]::new($endpoint)
Write-Verbose -Message 'Get default repository'
$repository = $client.ForSystem()
$space = $null
if ($SpaceIdentifier -match '^(Spaces-[0-9]+|http.+)$') {
    $space = $repository.Spaces.Get($SpaceIdentifier)
}
else {
    Write-Verbose -Message 'Get space by name'
    $space = $repository.Spaces.FindByName($SpaceIdentifier)
}

Write-Verbose -Message 'Return space-specific repository'
$client.ForSpace($space)

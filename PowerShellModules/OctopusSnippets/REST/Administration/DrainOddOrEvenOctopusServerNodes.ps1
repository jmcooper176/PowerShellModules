<#
 =============================================================================
<copyright file="DrainOddOrEvenOctopusServerNodes.ps1" company="U.S. Office of Personnel
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
This file "DrainOddOrEvenOctopusServerNodes.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$octopusURL = "https://your.octopus.app"
$octopusAPIKey = "API-KEY"
$headers = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

# Set to $True to drain "even" numbered nodes
# Set to $False to drain "odd" numbered nodes
$DrainEvenNodes = $false

# Set WhatIf to $False to perform the drain of nodes

if ($octopusURL.EndsWith("/")) {
    $serverNodeUri = $OctopusUrl.Substring(0, $OctopusUrl.Length - 1);
}

Write-Verbose -Message "OctopusURL: $octopusURL"
Write-Verbose -Message "DrainEvenNodes: $DrainEvenNodes"

function Write-Message($message) {
    if ($PSBoundParameters.ContainsKey('WhatIf')) {
        $message = "WHATIF: " + $message
    }
    Write-Output $message
}

# Get Octopus Server Nodes
$octopusServerNodesResponse = Invoke-RestMethod -Method Get -Uri "$octopusURL/api/octopusservernodes/summary" -Headers $headers
$octopusServerNodes = $octopusServerNodesResponse.Nodes

for ($i = 0; $i -lt $octopusServerNodes.Length; $i++) {

    $octopusServerNode = $octopusServerNodes[$i]
    $nodeName = $octopusServerNode.Name

    # try to get node number from name
    [int]$nodeNumber = $null
    $nameParts = $nodeName.Split('-')
    if ($nameParts.Length -gt 1) {
        $possibleNodeNumber = $nameParts[1]

        if ([int32]::TryParse($possibleNodeNumber, [ref]$nodeNumber )) {
            Write-Verbose -Message "Parsed node number from $nodeName as: $nodeNumber"
        }
        else {
            Write-Warning -Message "Unable to parse node number from $nodeName, setting to index: $i"
            $nodeNumber = $i
        }
    }
    else {
        Write-Warning -Message "Unable to determine a possible node number from $nodeName, setting to index: $i"
        $nodeNumber = $i
    }

    $nodeModuloResult = $nodeNumber % 2
    $ContinueDrainOperation = ($DrainEvenNodes -eq $True -and $nodeModuloResult -eq 0) -or ($DrainEvenNodes -eq $False -and $nodeModuloResult -eq 1)
    if ($ContinueDrainOperation) {

        if ($octopusServerNode.IsInMaintenanceMode -eq $True) {
            Write-Message "Skipping drain of node: $nodeName as it's already in a draining/drained state"
            Continue;
        }

        Write-Message "Draining node: $nodeName"
        if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
            $body = @{
                Id                  = $octopusServerNode.Id
                Name                = $octopusServerNode.Name
                MaxConcurrentTasks  = $octopusServerNode.MaxConcurrentTasks
                IsInMaintenanceMode = $true
            }

            # Convert body to JSON
            $body = $body | ConvertTo-Json -Depth 10
            $serverNodeUri = $OctopusUrl + $octopusServerNode.Links.Node;

            # Post update
            $updateServerNodeResponse = Invoke-RestMethod -Method Put -Uri $serverNodeUri -Body $body -Headers $headers

            # This script can be extended to check the nodes have completed a drain operation here by checking the nodes RunningTaskCount property is 0
        }
    }
    else {
        Write-Message "Skipping drain of node: $nodeName as it's not a valid candidate"
    }
}

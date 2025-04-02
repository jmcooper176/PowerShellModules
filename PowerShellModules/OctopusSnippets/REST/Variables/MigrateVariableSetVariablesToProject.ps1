<#
 =============================================================================
<copyright file="MigrateVariableSetVariablesToProject.ps1" company="U.S. Office of Personnel
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
This file "MigrateVariableSetVariablesToProject.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$baseUri = "http://octopus.url" # <-- Update this to the base URL to your Octopus server(i.e. not including 'app' or 'api'
$apiKey = "API-xxxxxxxxxxxxxxxxxxxxxxxxxx" # <-- Update this to your API key
$headers = @{"X-Octopus-ApiKey" = $apiKey}
$libraryVariableSetId = "LibraryVariableSets-1" # <-- Update this to the Id of your variable set
$projectName = "ProejctName" # <-- Update this to the name of your project

function Get-OctopusResource([string]$uri) {
    Write-Information -MessageData "[GET]: $uri"
    return Invoke-RestMethod -Method Get -Uri "$baseUri/$uri" -Headers $headers
}

function Put-OctopusResource([string]$uri, [object]$resource) {
    Write-Information -MessageData "[PUT]: $uri"
    #Write-Output $resource | ConvertTo-Json -Depth 10
    Invoke-RestMethod -Method Put -Uri "$baseUri/$uri" -Body $($resource | ConvertTo-Json -Depth 10) -Headers $headers
}

$libVarSet = Get-OctopusResource "api/libraryvariablesets/$libraryVariableSetId"
#Write-Output $libVarSet | ConvertTo-Json -Depth 10
$varSet = Get-OctopusResource "api/variables/$($libVarSet.VariableSetId)"
#Write-Output $varSet | ConvertTo-Json -Depth 10

$project = Get-OctopusResource "api/projects/$projectName"
#Write-Output $project | ConvertTo-Json -Depth 10
$projVar = Get-OctopusResource "api/variables/$($project.VariableSetId)"
#Write-Output $projVar | ConvertTo-Json -Depth 10

$varSet.Variables | ForEach-Object -Process {
    if($_.IsSensitive) {
        $_.Value = ""
    }
    $projVar.Variables += $_
}

#Write-Information -MessageData "Library Variable Set variables"
#Write-Output $varSet.Variables | Format-List
#Write-Information -MessageData "Variables"
#Write-Output $projVar.Variables | Format-List

Put-OctopusResource "api/variables/$($projVar.Id)" $projVar
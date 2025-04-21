<#
 =============================================================================
<copyright file="FindVariableValueUsage.ps1" company="John Merryweather Cooper
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
This file "FindVariableValueUsage.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Define working variables
$octopusURL = "https://your.octopus.app"
$octopusAPIKey = "API-YOURAPIKEY"

$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

# Specify the Space to search in
$spaceName = "Default"

# Specify the Variable Value to find, without OctoStache syntax

$variableValueToFind = "mytestvalue"

# Optional: set a path to export to csv
$csvExportPath = ""

$variableTracking = @()
$octopusURL = $octopusURL.TrimEnd('/')

# Get space
$space = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/spaces/all" -Headers $header) | Where-Object -FilterScript {$_.Name -eq $spaceName}

Write-Information -MessageData "Looking for usages of variable value named '$variableValueToFind' in space: '$spaceName'"

# Get variables from variable sets
$variableSets = Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/libraryvariablesets?contentType=Variables&skip=0&take=5000" -Headers $header

foreach ($variableSet in $variableSets.Items)
{
    Write-Information -MessageData "Checking variable set '$($variableSet.Name)'"

    $variableSetVariables = Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/variables/variableset-$($variableSet.Id)" -Headers $header

    $matchingNamedVariables = $variableSetVariables.Variables | Where-Object -FilterScript {$_.Value -like "*$variableValueToFind*"}
    if($null -ne $matchingNamedVariables){
        foreach($match in $matchingNamedVariables){
            $result = [PSCustomObject]@{
                Project = $null
                VariableSet = $variableSet.Name
                MatchType = "Value in Library Set"
                Context = $match.Value
                Property = $null
                AddtionalContext = $match.Name
            }
            $variableTracking += $result
        }
    }
}

# Get all projects
$projects = Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects/all" -Headers $header

# Loop through projects
foreach ($project in $projects)
{
    Write-Information -MessageData "Checking project '$($project.Name)'"
    # Get project variables
    $projectVariableSet = Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/variables/$($project.VariableSetId)" -Headers $header

    # Check to see if variable is named in project variables.
    $ProjectMatchingNamedVariables = $projectVariableSet.Variables | Where-Object -FilterScript {$_.Value -like "*$variableValueToFind*"}
    if($null -ne $ProjectMatchingNamedVariables) {
        foreach($match in $ProjectMatchingNamedVariables) {
            $result = [pscustomobject]@{
                Project = $project.Name
                VariableSet = $null
                MatchType = "Named Project Variable"
                Context = $match.Value
                Property = $null
                AdditionalContext = $match.Name
            }

            # Add to tracking list
            $variableTracking += $result
        }
    }
}

if($variableTracking.Count -gt 0) {
    Write-Information -MessageData ""
    Write-Information -MessageData "Found $($variableTracking.Count) results:"
    $variableTracking
    if (![string]::IsNullOrWhiteSpace($csvExportPath)) {
        Write-Information -MessageData "Exporting results to CSV file: $csvExportPath"
        $variableTracking | Export-Csv -Path $csvExportPath -NoTypeInformation
    }
}

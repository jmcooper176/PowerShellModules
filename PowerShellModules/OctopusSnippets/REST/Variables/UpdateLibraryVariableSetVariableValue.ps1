<#
 =============================================================================
<copyright file="UpdateLibraryVariableSetVariableValue.ps1" company="John Merryweather Cooper
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
This file "UpdateLibraryVariableSetVariableValue.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Define working variables
$octopusURL = "http://your.octopus.app/"
$octopusAPIKey = "YOUR-APIKEY"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

# Specify the Space to search in
$spaceName = ""

# Library Variable Set
$libraryVariableSetName = ""

# Variable name to search for
$VariableName = ""

# New variable value to set
$VariableValue = ""

$space = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/spaces/all" -Headers $header) | Where-Object -FilterScript {$_.Name -eq $spaceName}

Write-Information -MessageData "Looking for library variable set '$libraryVariableSet'"
$LibraryvariableSets = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/libraryvariablesets?contentType=Variables" -Headers $header)
$LibraryVariableSet = $LibraryVariableSets.Items | Where-Object -FilterScript { $_.Name -eq $libraryVariableSetName }

if ($null -eq $libraryVariableSet) {
    Write-Warning -Message "Library variable set not found with name '$libraryVariableSetName'."
    exit
}

$LibraryVariableSetVariables = (Invoke-RestMethod -Method Get -Uri "$OctopusURL/api/$($Space.Id)/variables/$($LibraryVariableSet.VariableSetId)" -Headers $Header)

for($i=0; $i -lt $LibraryVariableSetVariables.Variables.Length; $i++) {
    $existingVariable = $LibraryVariableSetVariables.Variables[$i];
    if($existingVariable.Name -eq $VariableName) {
        Write-Information -MessageData "Found existing variable, updating its value"
        $existingVariable.Value = $VariableValue
    }
}

$existingVariable = $LibraryVariableSetVariables.Variables  | Where-Object -FilterScript {$_.name -eq $VariableName} | Select-Object -First 1

$UpdatedLibraryVariableSet = Invoke-RestMethod -Method Put -Uri "$OctopusURL/api/$($Space.Id)/variables/$($LibraryVariableSetVariables.Id)" -Headers $Header -Body ($LibraryVariableSetVariables | ConvertTo-Json -Depth 10)

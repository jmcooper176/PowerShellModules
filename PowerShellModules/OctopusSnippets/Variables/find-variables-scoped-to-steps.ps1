<#
 =============================================================================
<copyright file="find-variables-scoped-to-steps.ps1" company="U.S. Office of Personnel
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
This file "find-variables-scoped-to-steps.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/

Add-Type -Path 'C:\MyScripts\Octopus.Client\Octopus.Client.dll'

$apikey = 'API-XXXXXXXXXXXXXXXXXXXXXXXXXX' # Get this from your profile
$octopusURI = 'https://octopus.url' # Your Octopus Server address

$projectName = "TestProp"  # Enter project you want to search

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint $octopusURI, $apiKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository $endpoint

$project = $repository.Projects.FindByName($projectName)
$projectVariables = $repository.VariableSets.Get($project.VariableSetId)

foreach ($variables in $projectVariables.Variables)  # For each Variable in referenced project - Return Variable Name & Value
{
    Write-Information -MessageData "###########################"
    Write-Information -MessageData "Variable Name = ", $variables.Name
    Write-Information -MessageData "Variable Value = ", $variables.Value

    $scopeId = $variables.Scope.Values  # Get Scope ID for each Variable

    foreach ($x in $projectVariables.ScopeValues.Actions)  # Compare Scope ID to Scope value
        {
            if ($x.Id -eq $scopeId)  # Return Scope Name if ID matches
            {
                Write-Information -MessageData "Scoped to Step = ", $x.Name
            }
        }
}

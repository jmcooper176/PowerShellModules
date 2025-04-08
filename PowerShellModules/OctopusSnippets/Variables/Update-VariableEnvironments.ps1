<#
 =============================================================================
<copyright file="Update-VariableEnvironments.ps1" company="John Merryweather Cooper
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
This file "Update-VariableEnvironments.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#

.SYNOPSIS
Updates the environment IDs in variable scopes.

Use case: After using Copy-LibraryVariables.ps1, the scopes of some variables in
the target space include "Missing Resource" tags. By passing this script a list
of mappings between environment IDs in the source and target space the "missing
resource" tags become the desired target-space environment tags after the fact.

You can find the environment IDs and names for each space using urls in the form
https://foo.com/api/Spaces-1/environments?skip=0&take=2147483647
where "Spaces-1" can be replaced by the ID of the space of interest.

.PARAMETER OctopusUri
Example:
-OctopusUri 'https://foo.com/api'

.PARAMETER OctopusApiKey
Note: Ensure that the account corresponding to the API key has the requisite
permissions in the space designated by SpaceName.

.PARAMETER NugetPath
Full path to the nuget CLI executable. Example:
-NugetPath 'c:\foo\NuGet4.6.2.exe'

.PARAMETER SpaceName
The name (not ID) of the space in which the source variable set resides. Example:
-SpaceName 'Default' # Default, equivalent to space ID Spaces-1

.PARAMETER EnvironmentIDMappings
Example:
-EnvironmentIDMappings @{ 'Environments-1' = 'Environments-11'; 'Environments-99' = 'Environments-999'; }

.OUTPUTS
None

#>
[CmdletBinding(SupportsShouldProcess)] # Enable -WhatIf and -Verbose switches
param (
    [parameter(Mandatory)][string]$OctopusUri,
    [parameter(Mandatory)][string]$OctopusApiKey,
    [parameter(Mandatory)][string]$NugetPath,
    [parameter(Mandatory)][string]$SpaceName,
    [parameter(Mandatory)][Hashtable]$EnvironmentIDMappings
)
$ErrorActionPreference = 'Stop'
if ($PSBoundParameters['Debug']) {
    $DebugPreference = 'Continue' # avoid Inquire
}

function AcquireAssemblies() {
    [CmdletBinding()]
    param ()
    Write-Information -MessageData 'Acquiring dependent assemblies'
    @('Octopus.Client') | ForEach-Object -Process {
        & $NugetPath install $_ $nugetSourceArg $NugetSource -ExcludeVersion -PackageSaveMode nuspec -Framework net45 -Verbosity $script:NugetVerbosity -NonInteractive
    }
}

function LoadAssemblies() {
    [CmdletBinding()]
    param ()
    Write-Verbose -Message 'Loading dependent assemblies'
    @(
        '.\Octopus.Client\lib\net452\Octopus.Client.dll'
    ) | ForEach-Object -Process { Add-Type -Path $_ }
}


if ($VerbosePreference -eq 'SilentlyContinue') {
    $script:NugetVerbosity = 'quiet'
} else {
    $script:NugetVerbosity = 'normal'
}
AcquireAssemblies
LoadAssemblies

function UpdateEnvironments() {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [parameter(Mandatory)][string]$VariableSetId
    )
    Write-Information -MessageData "Processing variable set '$VariableSetId'"
    $variableSets = $repository.VariableSets.Get($VariableSetId)
    if ($variableSets.Count -ne 1) {
        throw "Expected 1 variable set with id '$($VariableSetId)' but there were $($variableSets.Count)"
    }
    $variableSet = $variableSets[0]
    $changeMade = $false
    foreach ($variable in $variableSet.Variables.Where( { $_.Scope['Environment'] } )) {
        # A ScopeValue is a HashSet
        Write-Information -MessageData "Processing variable '$($variable.Name)'"
        [Octopus.Client.Model.ScopeValue]$environmentScope = $variable.Scope['Environment']
        $originalEnvironmentScope = $environmentScope.Clone()
        foreach ($environmentId in $originalEnvironmentScope) {
            foreach ($key in $EnvironmentIDMappings.Keys.Where( { $originalEnvironmentScope.Contains($_) } )) {
                $environmentScope.Remove($key) | Out-Null
                $message = "'$key' will be removed; '$($EnvironmentIDMappings[$key])'"
                if ($environmentScope.Add($EnvironmentIDMappings[$key])) {
                    Write-Information -MessageData ($message + " will be added in its place" )
                } else {
                    Write-Warning -Message ($message + " was already present alongside it" )
                }
                $changeMade = $true
            }
        }
    }
    if ($changeMade) {
        $operation = 'Updating IDs of environments scoped to variables'
        if ($PSCmdlet.ShouldProcess($variableSet.Id, $operation)) {
            Write-Information -MessageData "$operation in '$($variableSet.Id)'"
            $repository.VariableSets.Modify($variableSets)
        }
    }
}

$endpoint = New-Object -TypeName.Client.OctopusServerEndpoint $OctopusUri, $OctopusApiKey
$defaultSpaceRepository = New-Object -TypeName.Client.OctopusRepository $endpoint
$repository = $defaultSpaceRepository.Client.ForSpace($defaultSpaceRepository.Spaces.FindByName($SpaceName))

$variableSetIds = @()
(
    $repository.LibraryVariableSets.GetAll() +
    $repository.Projects.GetAll()
) | ForEach-Object -Process {
    $variableSetIds += $_.VariableSetId
}

$variableSetIds | ForEach-Object -Process {
    UpdateEnvironments($_)
}

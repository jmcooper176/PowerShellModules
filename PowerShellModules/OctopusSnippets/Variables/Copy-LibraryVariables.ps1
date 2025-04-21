<#
 =============================================================================
<copyright file="Copy-LibraryVariables.ps1" company="John Merryweather Cooper
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
This file "Copy-LibraryVariables.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#

.SYNOPSIS
Copies a subset of variables from one library variable set to another

.PARAMETER OctopusUri
Example:
-OctopusUri 'https://foo.com/api'

.PARAMETER OctopusApiKey
Note: If copying between spaces, ensure that the account corresponding to the
API key has the requisite permissions in both spaces.

.PARAMETER NugetPath
Full path to the nuget CLI executable. Example:
-NugetPath 'c:\foo\NuGet4.6.2.exe'

.PARAMETER SourceSpaceId
The ID (not name) of the space in which the source library variable set resides. Example:
-SpaceId 'Spaces-1' # Default

.PARAMETER SourceLibraryVariableSetId
Example:
-SourceLibraryVariableSetId 'LibraryVariableSets-1'

.PARAMETER DestinationSpaceId
The ID (not name) of the space in which the destination library variable set resides. Example:
-SpaceId 'Spaces-1' # Default

.PARAMETER DestinationLibraryVariableSetId
Example:
-DestinationLibraryVariableSetId 'LibraryVariableSets-2'

.PARAMETER VariableNameRegexPattern
A Regular Expression that dictates which variables in the source variable set will be copied, based on
variable name. Case-insensitive.
Example 1, copy a single variable:
-VariableNameRegexPattern '^foo\.bar$'
Example 2, copy variables with names that begin with "foo.":
-VariableNameRegexPattern '^foo\..+'

.OUTPUTS
None

#>
[CmdletBinding(SupportsShouldProcess)] # Enable -WhatIf and -Verbose switches
param (
    [parameter(Mandatory)][string]$OctopusUri,
    [parameter(Mandatory)][string]$OctopusApiKey,
    [parameter(Mandatory)][string]$NugetPath,
    [parameter()][string]$SourceSpaceId = 'Spaces-1',
    [parameter(Mandatory)][string]$SourceLibraryVariableSetId,
    [parameter()][string]$DestinationSpaceId = 'Spaces-1',
    [parameter(Mandatory)][string]$DestinationLibraryVariableSetId,
    [parameter(Mandatory)][string]$VariableNameRegexPattern
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
        & $NugetPath install $_ -ExcludeVersion -PackageSaveMode nuspec -Framework net45 -Verbosity $script:NugetVerbosity -NonInteractive
    }
}

function LoadAssemblies() {
    [CmdletBinding()]
    param ()
    Write-Verbose 'Loading dependent assemblies'
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

$octopusRepository = (New-Object -TypeName Octopus.Client.OctopusRepository (New-Object -TypeName Octopus.Client.OctopusServerEndpoint $OctopusURI, $OctopusApiKey))

$headers = @{"X-Octopus-ApiKey" = $OctopusApiKey}

function Get-OctopusResource([string]$uri, [string]$spaceId) {
    # Adapted from https://github.com/OctopusDeploy/OctopusDeploy-Api/blob/master/REST/PowerShell/Variables/MigrateVariableSetVariablesToProject.ps1
    $uriWithSpace = [string]::Join('/', @(
            $OctopusUri.TrimEnd('/'),
            $spaceId))
    $fullUri = [string]::Join('/', @(
            $uriWithSpace,
            $uri))
    Write-Information -MessageData "[GET]: $fullUri"
    return Invoke-RestMethod -Method Get -Uri $fullUri -Headers $headers
}

function Put-OctopusResource([string]$uri, [string]$spaceId, [object]$resource) {
    # Adapted from https://github.com/OctopusDeploy/OctopusDeploy-Api/blob/master/REST/PowerShell/Variables/MigrateVariableSetVariablesToProject.ps1
    $uriWithSpace = [string]::Join('/', @(
            $OctopusUri.TrimEnd('/'),
            $spaceId))
    $fullUri = [string]::Join('/', @(
            $uriWithSpace,
            $uri))
    Write-Information -MessageData "[PUT]: $fullUri"
    Invoke-RestMethod -Method Put -Uri $fullUri -Body $($resource | ConvertTo-Json -Depth 10) -Headers $headers
}

$sourceLibraryVariableSet = Get-OctopusResource "/libraryvariablesets/$SourceLibraryVariableSetId" $SourceSpaceId
$sourceGlobalVariableSetId = $sourceLibraryVariableSet.VariableSetId
$sourceGlobalVariableSet = Get-OctopusResource "/variables/$sourceGlobalVariableSetId" $SourceSpaceId
$destinationLibraryVariableSet = Get-OctopusResource "/libraryvariablesets/$DestinationLibraryVariableSetId" $DestinationSpaceId
$destinationGlobalVariableSetId = $destinationLibraryVariableSet.VariableSetId
$destinationGlobalVariableSet = Get-OctopusResource "/variables/$destinationGlobalVariableSetId" $DestinationSpaceId

$changeMade = $false
$sourceGlobalVariableSet.Variables | ForEach-Object -Process {
    if ($_.Name -match $VariableNameRegexPattern) {
        if($_.IsSensitive) {
            Write-Warning -Message "Variable '$($_.Name)' will not be copied. It is marked Sensitive, so its value cannot be read."
        } else {
            Write-Verbose "Preparing to add variable '$($_.Name)' with value '$($_.Value)' in '$destinationGlobalVariableSetId'"
            if (($SourceSpaceId -ne $DestinationSpaceId) -and $_.Scope -and ($_.Scope.Count -ne 0)) {
                $scopeCategories = @('Environment', 'Role')
                $scopeWarnings = @("You must ensure variable '$($_.Name)' with value '$($_.Value)' is scoped appropriately in the destination space.")
                $scopeWarningDetails = @()
                foreach ($scopeCategory in $scopeCategories) {
                    if ($_.Scope.$scopeCategory) {
                        $scopeWarningDetails += ("$scopeCategory(s): " +
                            (@(foreach ($scopeId in $_.Scope.$scopeCategory) { $sourceGlobalVariableSet.ScopeValues.$("$scopeCategory`s").Where( { $_.Id -eq $scopeId }).Name }) -join ', '))
                    }
                }
                $scopeWarnings += $("'$($_.Name)'/'$($_.Value)': " + $($scopeWarningDetails -join '; '))
                foreach ($scopeWarning in $scopeWarnings) { Write-Warning -Message $scopeWarning }
            }
            $destinationGlobalVariableSet.Variables += $_
            $changeMade = $true
        }
    }
}

if ($changeMade) {
    $operation = "Adding variables"
    if ($PSCmdlet.ShouldProcess($destinationGlobalVariableSetId, $operation)) {
        Write-Information -MessageData "$operation to '$destinationGlobalVariableSetId'"
        Put-OctopusResource "/variables/$destinationGlobalVariableSetId" $DestinationSpaceId $destinationGlobalVariableSet
    }
} else {
    Write-Warning -Message "No variables matching Regex '$VariableNameRegexPattern' were found in '$sourceGlobalVariableSetId'"
}

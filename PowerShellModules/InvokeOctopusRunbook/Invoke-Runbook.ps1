<#
 =============================================================================
<copyright file="Invoke-Runbook.ps1" company="U.S. Office of Personnel
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
This file "Invoke-Runbook.ps1" is part of "InvokeOctopusRunbook".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#

.SYNOPSIS
Invokes an Octopus Deploy runbook

.NOTES
Includes code from Octopus step template "Run Octopus Deploy Runbook". Refs:
  - In library: https://library.octopus.com/step-templates/0444b0b3-088e-4689-b755-112d1360ffe3/actiontemplate-run-octopus-deploy-runbook
  - In repo (the script is JSON-encoded in this context): https://github.com/OctopusDeploy/Library/blob/master/step-templates/run-octopus-runbook.json

.OUTPUTS
None

.PARAMETER SnapshotPreference
Must be 'CreateNew' or 'UsePublished'.
Required.

CreateNew: Create a new snapshot of the specified runbook, and run it. The new snaphot will pick
up the current process, variables and packages (if applicable).

UsePublished: Use the current, published snapshot of the specified runbook. If no snapshot has been
published, an error will occur.

.PARAMETER WaitForFinish
If this switch is present, the command will block until the runbook run completes or CancelInSeconds
elapses.

.PARAMETER UseGuidedFailure
If this switch is present, the runbook will run with guided failure mode enabled. Otherwise, the
runbook will run with guided failure mode disabled.

.PARAMETER RunbookName
Tha name of the runbook to be run.
Required.

.PARAMETER EnvironmentName
The name of the environment for which to run the runbook. The environment must be in the same space
as the runbook.
Required.

.PARAMETER SpaceID
The ID of the space containing the runbook. Example: Spaces-1
SpaceID or SpaceName is required.

.PARAMETER SpaceName
The name of the space containing the runbook. Example: Default
SpaceID or SpaceName is required.

.PARAMETER CancelInSeconds
The maximum number of seconds to wait for the runbook run to complete from the time it begins (time
spent in the "queued" state is not counted). If this duration is reached, the runbook run will be
cancelled and an error will occur. Ignored if WaitForFinish is not present. Default: 7200 (2 hours)

.PARAMETER TenantName
The name of the tenant for which to run the runbook, if applicable.

.PARAMETER OctopusBaseUrl
The base URL of the Octopus instance. Example: http://octopus.foo/
Required.

.PARAMETER OctopusApiKey
An Octopus API key for a principal with the following permissions in SpaceID: RunbookRunCreate,
RunbookRunView, RunbookEdit, RunbookView
Required.

.PARAMETER PromptedVariables
An array of names and values of any prompted variables to pass to the runbook. Each item in the
array must be a string in the form 'NameOfPromptedVariable::Value of prompted variable'

.PARAMETER SpecificMachineIds
An array of Octopus machine IDs that are a subset of those that will match the EnvironmentName
parameter and the role(s) defined in the runbook steps.

.PARAMETER SpecificMachineNames
An array of Octopus machine names that are a subset of those that will match the EnvironmentName
parameter and the role(s) defined in the runbook steps, and that are in SpaceID.

.EXAMPLE
. .\Invoke-Runbook.ps1 -SnapshotPreference CreateNew -WaitForFinish -UseGuidedFailure:$false `
    -Verbose -RunbookName 'Configure Server' -EnvironmentName 'Test' -SpaceID 'Spaces-2' `
    -CancelInSeconds 7200 -TenantName '' -OctopusBaseUrl "https://octopus.opm.gov/" `
    -OctopusApiKey "API-00000000000000000000000000" `
    -PromptedVariables 'SqlResourceSizeForBuild::baby', 'Server Names To Configure::MGA-TSTAODB01.cld.mcn', 'Server Primary IP::10.214.26.70', 'SQLAOINSTANCENAME::AO20201207150800', 'SQLAO::true'
    -SpecificMachineIds 'Machines-1234', 'Machines-1235'
    -SpecificMachineNames 'Server1', 'Server2'

#>
[CmdletBinding()] # Support -Verbose switch
param (
    [parameter(Mandatory)][ValidateSet('CreateNew', 'UsePublished')][string]$SnapshotPreference,
    [parameter()][switch]$WaitForFinish,
    [parameter()][switch]$UseGuidedFailure,
    [parameter(Mandatory)][string]$RunbookName,
    [parameter(Mandatory)][string]$EnvironmentName,
    [parameter(Mandatory = $false)][string]$SpaceID,
    [parameter(Mandatory = $false)][string]$SpaceName,
    [parameter()][int]$CancelInSeconds = 7200, # (2 hours)
    [parameter()][string]$TenantName = '',
    [parameter(Mandatory)][string]$OctopusBaseUrl,
    [parameter(Mandatory)][string]$OctopusApiKey,
    [parameter()][string[]]$PromptedVariables,
    [parameter()][string[]]$SpecificMachineIds = @(),
    [parameter()][string[]]$SpecificMachineNames = @()
)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not (Test-Path Function:\Write-Highlight)) {
    function Write-Highlight {
        [CmdletBinding()]
        param ([Parameter(ValueFromPipeline = $true)][string]$Message)

        process { Write-Information -MessageData $Message }
    }
}

if (-not (Test-Path Function:\Fail-Step)) {
    function Fail-Step([string]$Message) {
        throw $Message
    }
}

function FindMatchingItemByName {
    param (
        [string] $EndPoint,
        [string] $NameToLookFor,
        [string] $ItemType,
        [string] $APIKey,
        [string] $PullFirstItem
    )

    $fullUrl = "$($EndPoint)?partialName=$NameToLookFor&skip=0&take=$([int]::MaxValue)"
    Write-Information -MessageData "Attempting to find $ItemType $NameToLookFor by hitting $fullUrl"

    $header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $header.Add("X-Octopus-ApiKey", $APIKey)

    $itemList = Invoke-RestMethod $fullUrl -Headers $header
    $foundItem = $null
    foreach ($item in $itemList.Items) {
        if ($item.Name -eq $NameToLookFor -or $PullFirstItem) {
            Write-Information -MessageData "$ItemType matching $NameToLookFor found"
            $foundItem = $item
            break
        }
    }
    if ($null -eq $foundItem) {
        Fail-Step "$ItemType $NameToLookFor not found"
    }

    return $foundItem
}

function GetCheckBoxBoolean {
    param (
        [string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($value) -eq $true) {
        return $false
    }

    return $value -eq "True"
}

function validatedUniqueIdentifiers {
    param (
        [string[]]$Identifiers,
        [string]$IdentifierRegex,
        [string]$ReplaceRegex = '',
        [string]$ReplaceSubstitution = ''
    )
    $uniqueProvidedIdentifiers = $null
    if ($Identifiers -and $Identifiers.Count -gt 0 -and `
        ($Identifiers | Where-Object -FilterScript { -not [string]::IsNullOrWhiteSpace($_) })) {
        Write-Verbose -Message "Unexpanded provided identifiers: $Identifiers"
        Write-Verbose -Message "Unexpanded provided identifiers count: $($Identifiers.Count)"
        $providedIdentifiers = @()
        foreach ($identifier in $Identifiers) {
            Write-Verbose -Message "`$identifier: $identifier"
            @(($identifier -Split '[,\n]').Trim()) | ForEach-Object -Process {
                $providedIdentifier = $_
                if ($ReplaceRegex) {
                    Write-Verbose -Message "Replacing any matches for RegEx '$ReplaceRegex' with '$ReplaceSubstitution' in provided identifier '$providedIdentifier'"
                    $providedIdentifier = $providedIdentifier -replace $ReplaceRegex, $ReplaceSubstitution
                }
                Write-Verbose -Message "Adding '$providedIdentifier' to `$providedIdentifiers"
                $providedIdentifiers += $providedIdentifier
            }
        }
        $providedIdentifiers = @($providedIdentifiers) | Where-Object -FilterScript {
            -not [string]::IsNullOrWhiteSpace($_)
        }
        if (-not $providedIdentifiers) {
            Fail-Step 'Identifiers was specified but contained only one or more empty and/or whitespace values'
        }
        $uniqueProvidedIdentifiers = [System.Collections.Generic.HashSet[string]]::new([string[]]$providedIdentifiers, [System.StringComparer]::OrdinalIgnoreCase)
        if ($providedIdentifiers.Count -ne $uniqueProvidedIdentifiers.Count) {
            Write-Warning -Message 'Identifiers contains duplicates'
        }
        @($uniqueProvidedIdentifiers) | ForEach-Object -Process {
            if ($_ -notmatch $IdentifierRegex) {
                Fail-Step "The following value from Identifiers does not match the RegEx pattern '$IdentifierRegex': $_"
            }
        }
    }
    # Return an array because PowerShell undermined attempts to return a hashset, in ways that were
    # not intuitive and that somehow did not all reproduce locally. -ASD
    # Credit for the comma trick to prevent PS from returning collection's items (and $null when
    # the array is empty): https://stackoverflow.com/a/35206944/704808
    if ($null -eq $uniqueProvidedIdentifiers -or $uniqueProvidedIdentifiers.Count -eq 0) {
        , @()
    }
    else {
        $uniqueProvidedIdentifiersArray = @()
        $uniqueProvidedIdentifiersArray = [string[]]::new($uniqueProvidedIdentifiers.Count)
        $uniqueProvidedIdentifiers.CopyTo($uniqueProvidedIdentifiersArray)
        , $uniqueProvidedIdentifiersArray
    }
}

function New-RunbookSnapshot {
    [CmdletBinding()] # Support -Verbose switch
    param (
        [string]$OctopusBaseUrl,
        [string]$APIKey,
        [string]$SpaceID,
        [string]$RunbookIdToRun
    )

    $fullUrl = "$OctopusBaseUrl/api/$SpaceID/runbookProcesses/RunbookProcess-$RunbookIdToRun"
    Write-Information -MessageData "Getting runbook process by hitting $fullUrl"

    $header = New-Object -TypeName "System.Collections.Generic.Dictionary[[String],[String]]"
    $header.Add("X-Octopus-ApiKey", $APIKey)
    $runbookProcess = Invoke-RestMethod $fullUrl -Headers $header

    $projectId = $runbookProcess.ProjectId # e.g. "Projects-1661"
    $packages = @()
    foreach ($step in $runbookProcess.Steps) {
        foreach ($action in $step.Actions) {
            if (-not $action.IsDisabled) {
                foreach ($package in $action.Packages) {
                    $fullUrl = "$OctopusBaseUrl/api/$SpaceID/feeds/$($package.FeedId)/packages/versions?packageId=$($package.PackageId)&take=1"
                    Write-Information -MessageData "Getting latest package version by hitting $fullUrl"
                    $latestVersion = Invoke-RestMethod $fullUrl -Headers $header
                    $packages += @{
                        ActionName           = $action.Name
                        PackageId            = $package.PackageId # e.g. "ServerConfiguration"
                        FeedId               = $package.FeedId # e.g. "Feeds-1343"
                        Version              = $latestVersion.Items[0].Version # e.g. "1.1.30291"
                        Published            = $latestVersion.Items[0].Published # e.g. "2020-11-18T16:15:11.020+00:00"
                        PackageReferenceName = $package.Name
                    }
                }
            }
        }
    }

    $selectedPackages = @()
    $packages | ForEach-Object -Process {
        $selectedPackages += @{
            ActionName           = $_.ActionName
            Version              = $_.Version
            PackageReferenceName = $_.PackageReferenceName
        }
    }

    $fullUrl = "$OctopusBaseUrl/api/$SpaceID/projects/$projectId"
    Write-Information -MessageData "Getting IncludedLibraryVariableSetIds by hitting $fullUrl"
    $project = Invoke-RestMethod $fullUrl -Headers $header

    $runbookSnapshotBody = @{
        ProjectId                     = $projectId # e.g. "Projects-1661"
        ProjectVariableSetSnapshotId  = "variableset-$projectId" # e.g. "variableset-Projects-1661"
        LibraryVariableSetSnapshotIds = $project.IncludedLibraryVariableSetIds
        RunbookId                     = $runbookIdToRun # e.g. "Runbooks-256"
        FrozenRunbookProcessId        = "RunbookProcess-$runbookIdToRun" # e.g. "RunbookProcess-Runbooks-256"
        FrozenProjectVariableSetId    = "variableset-$projectId" # e.g. "variableset-Projects-1661"
        SelectedPackages              = $selectedPackages
        Name                          = "Snapshot $runbookIdToRun $($selectedPackages | Select-Object Version -Unique | ForEach-Object -Process { $_.Version }) $([datetime]::Now.ToString('s'))"
    }
    $fullUrl = "$OctopusBaseUrl/api/$SpaceID/runbookSnapshots"
    $runbookSnapshotBodyAsJson = $runbookSnapshotBody | ConvertTo-Json -Depth 100
    Write-Information -MessageData "Creating runbook snapshot by posting to $fullUrl"
    Write-Verbose -Message "JSON for POST Body:`n$runbookSnapshotBodyAsJson"
    $runbookSnapshot = Invoke-RestMethod $fullUrl -Method POST -Headers $header -Body $runbookSnapshotBodyAsJson
    Write-Verbose -Message "Response content from POST to create runbook snapshot:`n$runbookSnapshot"
    $runbookSnapshot
}

& (Join-Path $PSScriptRoot 'Get-HttpErrorResponseBody.ps1')

$OctopusBaseUrl = $OctopusBaseUrl.TrimEnd('/')
$header = New-Object -TypeName "System.Collections.Generic.Dictionary[[String],[String]]"
$header.Add("X-Octopus-ApiKey", $APIKey)

if (-not $SpaceID -and -not $SpaceName) {
    Fail-Step "Either the SpaceID or SpaceName parameter must be provided"
}
if ($SpaceName) {
    $spaceIDUrl = "$OctopusBaseUrl/api/spaces/all?partialName=$SpaceName"
    $spaceIDResponse = Invoke-RestMethod $spaceIDUrl -Method GET -Headers $header
    if ($spaceIDResponse.Count -eq 0) {
        Fail-Step "No Space ID found for space name '$SpaceName'. URL: $spaceIDUrl"
    }
    if ($spaceIDResponse.Count -gt 1) {
        foreach ($spaceFound in $spaceIDResponse) {
            if ($spaceFound.Name -eq $SpaceName) {
                $FoundSpaceID = $spaceFound.Id
                break
            }
        }
        if (-not $SpaceID) {
            Fail-Step "Multiple Space IDs found matching space name search term '$SpaceName' but none have an exact Name match. URL: $spaceIDUrl"
        }
    }
    else {
        $FoundSpaceID = $spaceIDResponse[0].Id
    }
    if ($SpaceID -and $FoundSpaceID -ne $SpaceID) {
        Fail-Step "Both the SpaceID and SpaceName parameters were provided, but the provided name '$SpaceName' resolved to ID '$FoundSpaceID', which does not match the provided ID '$SpaceID'."
        else {
            $SpaceID = $FoundSpaceID
        }
    }
}

Write-Verbose -Message "Unexpanded provided prompted variables: $PromptedVariables"
Write-Verbose -Message "Unexpanded provided prompted variables count: $($PromptedVariables.Count)"
$providedPromptedVariables = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::OrdinalIgnoreCase)
if ($PromptedVariables -and $PromptedVariables.Count -gt 0) {
    foreach ($promptedVariable in $PromptedVariables) {
        Write-Verbose -Message "`$promptedVariable: $promptedVariable"
        @(($promptedVariable -Split '`n').Trim()) | ForEach-Object -Process {
            $parsed = @($_ -Split "::")
            if ($parsed.Count -ne 2) {
                Fail-Step ('PromptedVariables item is not in the required form ' +
                    "'NameOfPromptedVariable::Value of prompted variable': $_")
            }
            Write-Verbose -Message "Adding '$_' to `$providedPromptedVariables"
            $providedPromptedVariables.Add($parsed[0], $parsed[1])
        }
    }
}
Write-Verbose -Message "Expanded provided prompted variables count: $($providedPromptedVariables.Count)"

Write-Verbose -Message "`$SpecificMachineIds`: '$SpecificMachineIds' (Type: '$($SpecificMachineIds.GetType())'; Count: '$($SpecificMachineIds.Count)')"
$ValidatedUniqueMachineIds = [System.Collections.Generic.HashSet[string]]::new([string[]](
        validatedUniqueIdentifiers -Identifiers $SpecificMachineIds -IdentifierRegex '^Machines-[0-9]+$'
    ), [System.StringComparer]::OrdinalIgnoreCase)
Write-Verbose -Message "`$ValidatedUniqueMachineIds`: '$ValidatedUniqueMachineIds' (Type: '$($ValidatedUniqueMachineIds.GetType())'; Count: '$($ValidatedUniqueMachineIds.Count)')"
Write-Verbose -Message "`$SpecificMachineNames`: '$SpecificMachineNames' (Type: '$($SpecificMachineNames.GetType())'; Count: '$($SpecificMachineNames.Count)')"
$ValidatedUniqueMachineNames = [System.Collections.Generic.HashSet[string]]::new([string[]](
        validatedUniqueIdentifiers -Identifiers $SpecificMachineNames -IdentifierRegex '^[a-z0-9-]+$' -ReplaceRegex '\..+$'
    ), [System.StringComparer]::OrdinalIgnoreCase)
Write-Verbose -Message "`$ValidatedUniqueMachineNames`: '$ValidatedUniqueMachineNames' (Type: '$($ValidatedUniqueMachineNames.GetType())'; Count: '$($ValidatedUniqueMachineNames.Count)')"
if ($ValidatedUniqueMachineNames.Count -ne 0) {
    Write-Verbose -Message 'Preparing to query Octopus for machine IDs'
    $spaceRepository = & (Join-Path $PSScriptRoot 'Get-SpaceRepository.ps1') -SpaceIdentifier $SpaceID -OctopusBaseUrl $OctopusBaseUrl -OctopusApiKey $OctopusApiKey
    Write-Information -MessageData "Querying Octopus for machine IDs of machines named '$ValidatedUniqueMachineNames'"
    $machinesIdsFromNames = $spaceRepository.Machines.FindByNames($ValidatedUniqueMachineNames).id
    Write-Information -MessageData "Query returned machine IDs '$machinesIdsFromNames'"
    Write-Verbose -Message "`$machinesIdsFromNames Type: '$($machinesIdsFromNames.GetType())'; Count: '$($machinesIdsFromNames.Count)'"
    if ($ValidatedUniqueMachineNames.Count -ne $machinesIdsFromNames.Count) {
        Fail-Step 'Machine not found for 1 or more provided machine names (see machine ID query details logged above)'
    }
    Write-Information -MessageData "Creating unique list of machine IDs from $($ValidatedUniqueMachineIds.Count) provided IDs and $($ValidatedUniqueMachineNames.Count) provided names"
    $ValidatedUniqueMachineIds.UnionWith([string[]]$machinesIdsFromNames)
}
$allSpecificMachineIds = @()
if ($ValidatedUniqueMachineIds.Count -ne 0) {
    $allSpecificMachineIds = [string[]]::new($ValidatedUniqueMachineIds.Count)
    $ValidatedUniqueMachineIds.CopyTo($allSpecificMachineIds)
}
if ($allSpecificMachineIds.Count -eq 0) {
    Write-Information -MessageData "(Runbook run will not be restricted to specific machines by machine name or ID.)"
}
else {
    Write-Highlight "Runbook run will be restricted to $($allSpecificMachineIds.Count) specific machines: $allSpecificMachineIds"
}

if ($OctopusParameters) {
    $calledFromSpaceId = $OctopusParameters["Called-From-Space-ID"]
    $calledFromSpaceName = $OctopusParameters["Called-From-Space-Name"]
    if ($calledFromSpaceId -and $calledFromSpaceName) {
        $spaceBlurb = 'the space from which this runbook was called'
    }
    else {
        $spaceBlurb = 'this runbook''s space'
        $calledFromSpaceId = $OctopusParameters["Octopus.Space.Id"]
        $calledFromSpaceName = $OctopusParameters["Octopus.Space.Name"]
    }
    Write-Highlight "Passing $spaceBlurb ($calledFromSpaceId/$calledFromSpaceName) for prompted variables Called-From-Space-ID/Called-From-Space-Name"
    $providedPromptedVariables['Called-From-Space-ID'] = $calledFromSpaceId
    $providedPromptedVariables['Called-From-Space-Name'] = $calledFromSpaceName
}
else {
    Write-Information -MessageData "Script not running in Octopus, so not passing prompted variables Called-From-Space-ID/Called-From-Space-Name"
}

$runbookUseGuidedFailure = $UseGuidedFailure.IsPresent
$runbookWaitForFinish = $WaitForFinish.IsPresent
Write-Verbose -Message "Runbook Name $RunbookName"
Write-Verbose -Message "Runbook Base Url: $OctopusBaseUrl"
Write-Verbose -Message "Runbook Space Id: $SpaceID"
Write-Verbose -Message "Runbook Environment Name: $EnvironmentName"
Write-Verbose -Message "Runbook Tenant Name: $TenantName"
Write-Verbose -Message "Wait for Finish: $runbookWaitForFinish"
Write-Verbose -Message "Use Guided Failure: $runbookUseGuidedFailure"
Write-Verbose -Message "Cancel run in seconds: $CancelInSeconds"
Write-Verbose -Message "Snapshot preference: $SnapshotPreference"
Write-Verbose -Message ("Provided prompted variable values: " + ($dic.Keys.ForEach({ "$_::$($dic[$_])" }) -join ','))

$header = New-Object -TypeName "System.Collections.Generic.Dictionary[[String],[String]]"
$header.Add("X-Octopus-ApiKey", $OctopusApiKey)

$environmentToUse = FindMatchingItemByName -EndPoint "$OctopusBaseUrl/api/$SpaceID/environments" -NameToLookFor $EnvironmentName -ItemType "Environment" -APIKey $OctopusApiKey -PullFirstItem $false
$environmentIdToUse = $environmentToUse.Id
Write-Information -MessageData "The environment Id for $EnvironmentName is $environmentIdToUse"

$tenantIdToUse = $null
if ([string]::IsNullOrWhiteSpace($TenantName) -eq $false) {
    $tenantToUse = FindMatchingItemByName -EndPoint "$OctopusBaseUrl/api/$SpaceID/tenants" -NameToLookFor $TenantName -ItemType "Tenant" -APIKey $OctopusApiKey -PullFirstItem $false
    $tenantIdToUse = $tenantToUse.Id
    Write-Verbose -Message "The Tenant Id for $TenantName is $tenantIdToUse"
}

$runbookToRun = FindMatchingItemByName -EndPoint "$OctopusBaseUrl/api/$SpaceID/runbooks" -NameToLookFor $RunbookName -ItemType "Runbook" -APIKey $OctopusApiKey -PullFirstItem $false
$runbookIdToRun = $runbookToRun.Id
Write-Information -MessageData "The Runbook Id for $RunbookName is $runbookIdToRun"
$runbookProjectId = $runbookToRun.ProjectId
Write-Information -MessageData "The Runbook Project Id for $RunbookName is $runbookProjectId"

$runbookSnapShotIdToUse = $null
if ($SnapshotPreference -eq 'CreateNew') {
    Write-Information -MessageData "Creating new snapshot for $RunbookName"
    $runbookSnapShot = New-RunbookSnapshot -OctopusBaseUrl $OctopusBaseUrl -APIKey $OctopusApiKey -SpaceId $SpaceID -RunbookIdToRun $runbookIdToRun
    $runbookSnapShotIdToUse = $runbookSnapShot.Id
    if (-not $runbookSnapShotIdToUse) {
        Fail-Step "Failed to get an ID for a new snapshot"
    }
    Write-Information -MessageData "The newly-created snapshot for $RunbookName is $runbookSnapShotIdToUse"
}
else {
    $runbookSnapShotIdToUse = $runbookToRun.PublishedRunbookSnapshotId
    if (-not $runbookSnapShotIdToUse) {
        Fail-Step "SnapshotPreference is UsePublished, but runbook $runbookRunName does not have a published snapshot."
    }
    Write-Information -MessageData "Using last published snapshot for $runbookRunName`: $runbookSnapShotIdToUse"
}

$runbookPreviewUrl = "$OctopusBaseUrl/api/$SpaceID/runbookSnapshots/$runbookSnapShotIdToUse/runbookRuns/preview/$environmentIdToUse"
if ($tenantIdToUse) {
    $runbookPreviewUrl += "/$tenantIdToUse"
}

Write-Information -MessageData "Prompted variables: hitting the runbook preview endpoint $runbookPreviewUrl"
$runbookPreview = Invoke-RestMethod $runbookPreviewUrl -Headers $header
$runbookPreviewAsJson = $runbookPreview | ConvertTo-Json -Depth 20
Write-Verbose -Message "Prompted variables: runbook preview as JSON:`n$runbookPreviewAsJson"
$runbookPreviewControlNamesAndLabels = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$providedPromptedVariableNamesNotMatched = [System.Collections.Generic.HashSet[string]]::new($providedPromptedVariables.Keys, [System.StringComparer]::OrdinalIgnoreCase)
$runbookFormValues = @{}
foreach ($element in $runbookPreview.Form.Elements) {
    $uniqueName = $element.Name
    $isRequired = $element.Control.Required
    $promptedVariablefound = $false
    $namesToSearchFor = @($element.Control.Name)
    Write-Verbose -Message "`$namesToSearchFor = @(`$element.Control.Name) ('$($element.Control.Name)')"
    if ((-not [string]::IsNullOrWhiteSpace($element.Control.Label)) -and ($element.Control.Label -ne $element.Control.Name)) {
        Write-Verbose -Message "`$namesToSearchFor += `$element.Control.Label ('$($element.Control.Label)')"
        $namesToSearchFor += $element.Control.Label
    }
    Write-Verbose -Message "`$uniqueName (`$element.Name): '$uniqueName'"
    Write-Verbose -Message "`$isRequired (`$element.Control.Required): '$isRequired'"
    foreach ($nameToSearchFor in $namesToSearchFor) {
        Write-Verbose -Message "`$nameToSearchFor: $nameToSearchFor"
    }
    foreach ($nameToSearchFor in $namesToSearchFor) {
        if (-not $runbookPreviewControlNamesAndLabels.Add($nameToSearchFor)) {
            Fail-Step "More than one prompted variable has the name or label $nameToSearchFor. Runbook preview as JSON:`n$runbookPreviewAsJson"
        }

        Write-Verbose -Message "Looking for the prompted variable value for '$nameToSearchFor'"
        foreach ($providedPromptedVariableName in $providedPromptedVariables.Keys) {
            $providedValue = $providedPromptedVariables[$providedPromptedVariableName]
            # Write-Verbose -Message "Comparing '$nameToSearchFor' with provided prompted variable '$providedPromptedVariableName' (value: '$providedValue')"
            if ($providedPromptedVariableName -eq $nameToSearchFor) {
                if ($isRequired) { $descriptor = "required " } else { $descriptor = "optional " }
                Write-Highlight "Value provided for $descriptor`prompted variable '$nameToSearchFor': $providedValue"
                $runbookFormValues[$uniqueName] = $providedValue
                $promptedVariableFound = $true
                $providedPromptedVariableNamesNotMatched.Remove($providedPromptedVariableName) | Out-Null
                break
            }
        }
    }
    if (-not $promptedVariableFound) {
        if ($isRequired) {
            Fail-Step "No value provided for required prompted variable $namesToSearchFor"
        }
        else {
            $defaultValue = $runbookPreview.Form.Values.$uniqueName
            Write-Highlight "No value provided for optional prompted variable $namesToSearchFor. Will use default value: '$defaultValue'"
        }
    }
}

if ($providedPromptedVariableNamesNotMatched.Count -eq 0) {
    Write-Information -MessageData 'Every provided prompted variable value was matched with a target runbook prompted variable :-)'
}
else {
    foreach ($promptedVariableName in $providedPromptedVariableNamesNotMatched) {
        Write-Warning -Message "The target runbook does not have a prompted variable matching the provided '$promptedVariableName' (value: '$($providedPromptedVariables[$promptedVariableName])')"
    }
}

$runbookBody = @{
    RunbookId                = $runbookIdToRun;
    RunbookSnapShotId        = $runbookSnapShotIdToUse;
    FrozenRunbookProcessId   = $null;
    EnvironmentId            = $environmentIdToUse;
    TenantId                 = $tenantIdToUse;
    SkipActions              = @();
    QueueTime                = $null;
    QueueTimeExpiry          = $null;
    FormValues               = $runbookFormValues;
    ForcePackageDownload     = $false;
    ForcePackageRedeployment = $true;
    UseGuidedFailure         = $runbookUseGuidedFailure;
    SpecificMachineIds       = @($allSpecificMachineIds);
    ExcludedMachineIds       = @()
}

$runbookBodyAsJson = $runbookBody | ConvertTo-Json -Depth 100
$runbookPostUrl = "$OctopusBaseUrl/api/$SpaceID/runbookRuns"
Write-Information -MessageData "Kicking off runbook run by posting to $runbookPostUrl"
Write-Verbose -Message "JSON for POST Body:`n$runbookBodyAsJson"

try {
    $runbookResponse = Invoke-RestMethod $runbookPostUrl -Method POST -Headers $header -Body $runbookBodyAsJson
}
catch {
    $errorResponseBody = Get-HttpErrorResponseBody -ErrorFromInvokeRequest $_
    Fail-Step "$httpVerb to '$theURL' failed. Response body: '$errorResponseBody'. Error: '$_'"
}
Write-Verbose -Message "Response content from POST to kick off runbook:`n$runbookResponse"

If (-not $runbookResponse.TaskId) {
    Fail-Step "No TaskId property in response from POST to kick off runbook"
}
If (-not $runbookResponse.Id) {
    Fail-Step "No Id property in response from POST to kick off runbook"
}
$runbookServerTaskId = $runbookResponse.TaskId
Write-Verbose -Message "The task id of the new task is $runbookServerTaskId"
$runbookRunId = $runbookResponse.Id
Write-Verbose -Message "The runbook run id is $runbookRunId"

$projectResponse = Invoke-RestMethod "$OctopusBaseUrl/api/$SpaceID/projects/$runbookProjectId" -Headers $header
$projectNameForUrl = $projectResponse.Slug
Write-Information -MessageData "The Project Slug for $runbookProjectId is $projectNameForUrl"
$runbookRunWebUrl = "$OctopusBaseUrl/app#/$SpaceID/projects/$projectNameForUrl/operations/runbooks/$runbookIdToRun/snapshots/$runbookSnapShotIdToUse/runs/$runbookRunId`?activeTab=taskSummary"
$viewRunbookMessage = "You can view the runbook run [here]($runbookRunWebUrl)"
Write-Highlight "Runbook successfully invoked. $viewRunbookMessage"
if ($runbookWaitForFinish -eq $true) {
    Write-Information -MessageData "The setting to wait for completion was set; waiting until runbook run has finished"
    $startTime = Get-Date
    $currentTime = Get-Date
    $dateDifference = $currentTime - $startTime

    $taskStatusUrl = "$OctopusBaseUrl/api/tasks/$runbookServerTaskId"

    While ($dateDifference.TotalSeconds -lt $CancelInSeconds) {
        Write-Information -MessageData "Waiting 5 seconds to check status of the runbook run"
        Start-Sleep -Seconds 5
        $taskStatusResponse = Invoke-RestMethod $taskStatusUrl -Headers $header
        $taskStatusResponseState = $taskStatusResponse.State

        if ($taskStatusResponseState -eq "Success") {
            Write-Highlight "The runbook run finished with a status of Success. $viewRunbookMessage"
            exit 0
        }
        elseif ($taskStatusResponseState -eq "Failed" -or $taskStatusResponseState -eq "Canceled") {
            Fail-Step "The runbook run finished with a status of $taskStatusResponseState. $viewRunbookMessage"
        }

        Write-Verbose -Message "The runbook run state is currently $taskStatusResponseState"

        $startTime = $taskStatusResponse.StartTime
        if ([string]::IsNullOrWhiteSpace($startTime)) {
            Write-Verbose -Message "The runbook run is still queued, let's wait a bit longer"
            $startTime = Get-Date
        }
        $startTime = [DateTime]$startTime

        $currentTime = Get-Date
        $dateDifference = $currentTime - $startTime
    }

    Write-Information -MessageData "The cancel timeout has been reached, cancelling the runbook run. $viewRunbookMessage"
    $cancelResponse = Invoke-RestMethod "$OctopusBaseUrl/api/tasks/$runbookServerTaskId/cancel" -Headers $header -Method Post
    Fail-Step "Timeout reached. $viewRunbookMessage"
}

<#
 =============================================================================
<copyright file="ImportVariablesFromFile.ps1" company="John Merryweather Cooper
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
This file "ImportVariablesFromFile.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# Define octopus variables
$octopusURL = "https://your.octopus.app"
$octopusAPIKey = "API-YOURAPIKEY"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

# Define working variables
$spaceName = "Default"
$variableSetFilePath = "/path/to/project-variables-to-import.json"
$destinationProjectName = "your-project-to-import-to"

# Set this value to add additional variable values found on source data not in destination
$addAdditionalVariableValuesOnExistingVariableSets = $True
# Set this value to to true to overwrite existing variable values
$overwriteExistingVariables = $True

# Set this value to to true to keep existing account variable values unchanged from the source file
$keepSourceAccountVariableValues = $True

#region "Functions"
function Convert-SourceIdListToDestinationIdList {
    param (
        $SourceList,
        $DestinationList,
        $IdList
    )

    $NewIdList = @()
    Write-Information -MessageData "Converting id list with $($IdList.Length) item(s) over to destination space"     
    foreach ($idValue in $idList) {
        $ConvertedId = Convert-SourceIdToDestinationId -SourceList $SourceList -DestinationList $DestinationList -IdValue $IdValue

        if ($null -ne $ConvertedId) {
            $NewIdList += $ConvertedId
        }
    }

    return @($NewIdList)
}

function Convert-SourceIdToDestinationId {
    param (
        $SourceList,
        $DestinationList,
        $IdValue
    )

    $idValueSplit = $IdValue -split "-"
    if ($idValueSplit.Length -le 2) {
        if (($idValueSplit[1] -match "^[\d\.]+$") -eq $false) {
            Write-Information -MessageData "The id value $idValue is a built in id, no need to convert, returning it."
            return $IdValue
        }
    }
    
    Write-Information -MessageData "Getting Name of $IdValue"
    $sourceItem = Get-OctopusItemById -ItemList $SourceList -ItemId $IdValue

    $nameToUse = $sourceItem.Name
    if ([string]::IsNullOrWhiteSpace($nameToUse)) {
        Write-Information -MessageData "The name property is null attempting the username property"
        $nameToUse = $sourceItem.UserName
    }

    if ([string]::IsNullOrWhiteSpace($nameToUse)) {
        Write-Information -MessageData "Unable to find a name property for $IdValue"
        return $null
    }

    Write-Information -MessageData "The name of $IdValue is $nameToUse, attempting to find in destination list"    

    $destinationItem = Get-OctopusItemByName -ItemName $nameToUse -ItemList $DestinationList    

    if ($null -eq $destinationItem) {
        Write-Information -MessageData "Unable to find $nameToUse in the destination list"
        return $null
    }
    else {
        Write-Information -MessageData "The destination id for $nameToUse is $($destinationItem.Id)"
        return $destinationItem.Id
    }
}


function Get-OctopusItemById {
    param (
        $ItemList,
        $ItemId
    ) 
        
    Write-Information -MessageData "Attempting to find $ItemId in the item list of $($ItemList.Length) item(s)"

    foreach ($item in $ItemList) {
        Write-Information -MessageData "Checking to see if $($item.Id) matches with $ItemId"
        if ($item.Id -eq $ItemId) {
            Write-Information -MessageData "The Ids match, return the item $($item.Name)"
            return $item
        }
    }

    Write-Information -MessageData "No match found returning null"
    return $null    
}

function Get-OctopusItemByName {
    param (
        $ItemList,
        $ItemName
    )    

    return ($ItemList | Where-Object -FilterScript { $_.Name -eq $ItemName })
}
#endregion

# Get space
$spaceList = Invoke-RestMethod "$octopusURL/api/spaces/all" -Headers $header
$space = $spaceList | Where-Object -FilterScript { $_.Name -eq $spaceName }

# Get destination project
$projectList = Invoke-RestMethod "$octopusURL/api/$($space.Id)/projects/all" -Headers $header
$destinationProject = $projectList | Where-Object -FilterScript { $_.Name -eq $destinationProjectName }
$destinationProjectVariableSetId = $destinationProject.VariableSetId

# Get source variableset from file
$sourceVariableSetVariables = [IO.File]::ReadAllText($variableSetFilePath) | ConvertFrom-Json
$sourceEnvironmentList = $sourceVariableSetVariables.ScopeValues.Environments
$sourceChannelList = $sourceVariableSetVariables.ScopeValues.Channels
$sourceRunbookList = $sourceVariableSetVariables.ScopeValues.Processes | Where-Object -FilterScript { $_.ProcessType -eq "Runbook" }

# Get destination data
$destinationData = @{
    OctopusUrl    = $octopusUrl;
    OctopusApiKey = $octopusApiKey;
    SpaceName     = $spaceName
}

$destinationApiInformation = Invoke-RestMethod -Method Get -Uri "$octopusURL/api" -Headers $header
$destinationData.Version = $destinationApiInformation.Version
Write-Information -MessageData "The version of $octopusURL is $($destinationData.Version)"
$splitVersion = $destinationData.Version -split "\."
$destinationData.MajorVersion = [int]$splitVersion[0]
$destinationData.MinorVersion = [int]$splitVersion[1]
$destinationData.HasRunbooks = ($destinationData.MajorVersion -ge 2019 -and $destinationData.MinorVersion -ge 11) -or $destinationData.MajorVersion -ge 2020

$destinationVariableSetVariables = Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/variables/$destinationProjectVariableSetId" -Headers $header
$destinationEnvironmentList = Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/environments/all" -Headers $header
$destinationProjectChannelList = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects/$($destinationProject.Id)/channels" -Headers $header)
$destinationRunbookList = @()

If ($destinationData.HasRunbooks -eq $True) {
    $destinationRunbookList = Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects/$($destinationProject.Id)/runbooks" -Headers $header
}

$variableTracker = @{}

try {
    foreach ($octopusVariable in $sourceVariableSetVariables.Variables) {
        $variableName = $octopusVariable.Name

        if (Get-Member -InputObject $octopusVariable.Scope -Name "Environment" -MemberType Properties) {
            Write-Information -MessageData "$variableName has environment scoping, converting to destination values"
            $NewEnvironmentIds = @(Convert-SourceIdListToDestinationIdList -SourceList $sourceEnvironmentList -DestinationList $destinationEnvironmentList -IdList $octopusVariable.Scope.Environment)
            $octopusVariable.Scope.Environment = @($NewEnvironmentIds)            
        }

        if (Get-Member -InputObject $octopusVariable.Scope -Name "Channel" -MemberType Properties) {
            Write-Information -MessageData "$variableName has channel scoping, converting to destination values"
            $NewChannelIds = @(Convert-SourceIdListToDestinationIdList -SourceList $sourceChannelList -DestinationList $destinationProjectChannelList -IdList $octopusVariable.Scope.Channel)
            $octopusVariable.Scope.Channel = @($NewChannelIds)            
        }

        if (Get-Member -InputObject $octopusVariable.Scope -Name "ProcessOwner" -MemberType Properties) {
            if ($destinationData.HasRunbooks) {
                Write-Information -MessageData "$variableName has process owner scoping, converting to destination values"
                $NewOwnerIds = @()
                foreach ($value in $octopusVariable.Scope.ProcessOwner) {
                    Write-Information -MessageData "Attempting to convert $value to a destination value"

                    if ($value -like "Projects-*") {
                        Write-Information -MessageData "The process owner is the project, converting to the new project id"
                        $NewOwnerIds += $DestinationProjectData.Project.Id
                    }
                    elseif ($value -like "Runbooks-*") {
                        Write-Information -MessageData "The process owner is a runbook, converting to the new runbook id"
                        $NewOwnerIds += Convert-SourceIdToDestinationId -SourceList $sourceRunbookList -DestinationList $destinationRunbookList -IdValue $value
                    }
                }

                Write-Information -MessageData "The new process owner ids are $NewOwnerIds"
                
                $octopusVariable.Scope.ProcessOwner = @($NewOwnerIds)            
            }
            else {
                $octopusVariable.Scope.PSObject.Properties.Remove('ProcessOwner')    
            }
        }

        if ($octopusVariable.Type -match ".*Account") {
            if ($keepSourceAccountVariableValues -eq $false) {
                Write-Information -MessageData "Warning: Cannot convert account type to destination account as keepSourceAccountVariableValues set to false. Setting to DUMMY VALUE" -ForegroundColor Yellow  
                $octopusVariable.Value = "DUMMY VALUE"
            }
        }

        if ($octopusVariable.IsSensitive -eq $true) {
            Write-Information -MessageData "Warning: Setting sensitive value for $($variableName) to DUMMY VALUE" -ForegroundColor Yellow  
            $octopusVariable.Value = "DUMMY VALUE"
        }

        $trackingName = $variableName -replace "\.", ""        
        
        Write-Information -MessageData "Cloning $variableName"
        if ($null -eq $variableTracker[$trackingName]) {
            Write-Information -MessageData "This is the first time we've seen $variableName"
            $variableTracker[$trackingName] = 1
        }
        else {
            $variableTracker.$trackingName += 1
            Write-Information -MessageData "We've now seen $variableName $($variableTracker[$trackingName]) times"
        }

        $foundCounter = 0
        $foundIndex = -1
        $variableExistsOnDestination = $false        
        for ($i = 0; $i -lt $destinationVariableSetVariables.Variables.Length; $i++) {            
            if ($destinationVariableSetVariables.Variables[$i].Name -eq $variableName) {
                $variableExistsOnDestination = $true
                $foundCounter += 1
                if ($foundCounter -eq $variableTracker[$trackingName]) {
                    $foundIndex = $i
                }
            }
        }
        if ($foundCounter -gt 1 -and $variableExistsOnDestination -eq $true -and $addAdditionalVariableValuesOnExistingVariableSets -eq $false) {
            Write-Information -MessageData "The variable $variableName already exists on destination. You selected to skip duplicate instances, skipping."
        }
        elseif ($foundIndex -eq -1) {
            Write-Information -MessageData "New variable $variableName value found.  This variable has appeared so far $($variableTracker[$trackingName]) time(s) in the source variable set.  Adding to list."
            $destinationVariableSetVariables.Variables += $octopusVariable
        }
        elseif ($OverwriteExistingVariables -eq $false) {
            Write-Information -MessageData "The variable $variableName already exists on the host and you elected to only copy over new items, skipping this one."
        }                                         
        elseif ($foundIndex -gt -1 -and $destinationVariableSetVariables.Variables[$foundIndex].IsSensitive -eq $true) {
            Write-Information -MessageData "The variable $variableName at value index $($variableTracker[$trackingName]) is sensitive, leaving as is on the destination."
        }
        elseif ($foundIndex -gt -1) {
            $destinationVariableSetVariables.Variables[$foundIndex].Value = $octopusVariable.Value
            $destinationVariableSetVariables.Variables[$foundIndex].Scope = $octopusVariable.Scope
            if ($octopusVariable.Value -eq "Dummy Value") {                
                Write-Information -MessageData "The variable $variableName is a sensitive variable, value set to 'Dummy Value'" -ForegroundColor Yellow  
            }
        }  
    }
    Write-Information -MessageData "Saving variables to $octopusURL$($destinationProject.Links.Variables)"       
    Invoke-RestMethod -Method Put -Uri "$octopusURL$($destinationProject.Links.Variables)" -Body ($destinationVariableSetVariables | ConvertTo-Json -Depth 10) -Headers $header | Out-Null
}
catch {
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}

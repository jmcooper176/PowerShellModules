<#
 =============================================================================
<copyright file="ImportAzureDevopsVariableExportToLibraryVariableSet.ps1" company="John Merryweather Cooper
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
This file "ImportAzureDevopsVariableExportToLibraryVariableSet.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";
function ImportAzureDevopsVariableExportToLibraryVariableSet(
    [String]$OctopusURL,
    [String]$OctopusAPIKey,
    [String]$SpaceName,
    [String]$Path,
    [switch]$ForceUpdateVariablesWithMultipleScopes
)
{
    Write-Information -MessageData "OctopusURL: $OctopusURL"
    Write-Information -MessageData "OctopusAPIKey: API-********"
    Write-Information -MessageData "SpaceName: $SpaceName"
    Write-Information -MessageData "Path: $Path"

    if(-not (Test-Path $Path)) {
        Write-Warning -Message "$Path could not be found!"
    }
    else
    {
        Write-Information -MessageData "Found file: $Path"
        $StopWatch =  [System.Diagnostics.Stopwatch]::StartNew()
        $Headers = @{ "X-Octopus-ApiKey" = $OctopusAPIKey }

        # Check Space
        $Spaces = Invoke-RestMethod -Uri "$octopusURL/api/spaces?partialName=$([uri]::EscapeDataString($spaceName))&skip=0&take=100" -Headers $Headers
        $Space = $Spaces.Items | Where-Object -FilterScript { $_.Name -eq $SpaceName }

        if($null -eq $Space) {
            throw "Space not found with name '$SpaceName'."
        }

        Write-Information -MessageData "Found SpaceId '$($Space.Id)' for '$($SpaceName)'."

        $BaseName = (Get-Item $Path).Basename
        $BaseNameParts = $BaseName.Split("_")
        $VariableSetName = $BaseNameParts[0]
        $EnvironmentName = $BaseNameParts[1]

        # Check Environment
        $Environments = Invoke-RestMethod -Uri "$octopusURL/api/$($Space.Id)/environments?partialName=$([uri]::EscapeDataString($EnvironmentName))&skip=0&take=100" -Headers $Headers
        $Environment = $Environments.Items | Where-Object -FilterScript { $_.Name -eq $EnvironmentName }

        if($null -eq $Environment) {
            throw "Environment not found with name '$EnvironmentName'."
        }
        Write-Information -MessageData "Found EnvironmentId '$($Environment.Id)' for '$($EnvironmentName)'."

        # Check Variable Set Name
        $LibraryVariableSets = Invoke-RestMethod -Uri "$OctopusURL/api/$($Space.Id)/libraryvariablesets?partialName=$([uri]::EscapeDataString($VariableSetName))&skip=0&take=100" -Headers $Headers
        $LibraryVariableSet = $LibraryVariableSets.Items | Where-Object -FilterScript { $_.Name -eq $VariableSetName }

        if($null -eq $LibraryVariableSet) {
            Write-Warning -Message "Library variable set not found with name '$VariableSetName', creating."
            $body = (@{
                Name = $VariableSetName
                Description = "Variable set created from file $Path."
            } | ConvertTo-Json -Depth 10)

            $LibraryVariableSet = Invoke-RestMethod -Method Post -Uri "$octopusURL/api/$($space.Id)/libraryvariablesets" -Body $body -Headers $Headers
        }
        Write-Information -MessageData "Found Library variable set '$($LibraryVariableSet.Id)' for '$($VariableSetName)'."

        # Get Variable set variables
        $LibraryVariableSetVariables = Invoke-RestMethod -Uri "$OctopusURL/api/$($Space.Id)/variables/$($LibraryVariableSet.VariableSetId)" -Headers $Headers

        # Work through variables
        $FileContent = Get-Content -Path $Path
        $ADO_Output = ($FileContent | ConvertFrom-Json)

        $Count = 1
        foreach($entry in $ADO_Output.value) {
            Write-Information -MessageData "Iterating through entry $Count in file"
            $Variables = $entry.variables
            $VariableNames = $Variables | Get-Member | Where-Object -FilterScript {$_.MemberType -eq "NoteProperty"} | Select-Object -ExpandProperty "Name"
            foreach($VariableName in $VariableNames) {
                Write-Information -MessageData "Working on variable: $VariableName."
                $VariableValue = $Variables.$VariableName.value

                $Variable = @{
                    Name = $VariableName
                    Value = $VariableValue
                    Type = "String"
                    IsSensitive = $false
                    Scope = @{
                        Environment = @($Environment.Id)
                    }
                }

                $MatchingVariables = $LibraryVariableSetVariables.Variables | Where-Object -FilterScript {$_.Name -eq $Variable.Name}

                # If the variable does not exist, create it
                if ($null -eq $MatchingVariables)
                {
                    Write-Information -MessageData "No variable matches for '$($Variable.Name)', creating new variable."
                    # Create new object
                    $variableToUpdate = New-Object -TypeName PSObject
                    $variableToUpdate | Add-Member -MemberType NoteProperty -Name "Name" -Value $Variable.Name
                    $variableToUpdate | Add-Member -MemberType NoteProperty -Name "Value" -Value $Variable.Value
                    $variableToUpdate | Add-Member -MemberType NoteProperty -Name "Type" -Value $Variable.Type
                    $variableToUpdate | Add-Member -MemberType NoteProperty -Name "IsSensitive" -Value $Variable.IsSensitive
                    $variableToUpdate | Add-Member -MemberType NoteProperty -Name "Scope" -Value $Variable.Scope

                    # Add to collection
                    $LibraryVariableSetVariables.Variables += $variableToUpdate
                }
                else {
                    Write-Information -MessageData "Variable '$($Variable.Name)' exists ($($MatchingVariables.Count) found), updating."

                    $matchingVariablesWithEnvironmentScope = $MatchingVariables | Where-Object -FilterScript {$_.Scope.Environment -icontains $Environment.Id}
                    foreach($matchingVariable in $matchingVariablesWithEnvironmentScope) {
                        # Update variable value if it's a single environment scope OR if Force=True
                        if($matchingVariable.Value -ne $Variable.Value -and (($matchingVariable.Scope.Environment.Length -eq 1) -or ($matchingVariable.Scope.Environment.Length -gt 1 -and $ForceUpdateVariablesWithMultipleScopes -eq $True) )) {
                            Write-Information -MessageData "Matching environment scoped variable ($($matchingVariable.Id)) has different value, updating to new value."
                            $matchingVariable.Value = $Variable.Value
                        }
                    }

                    $matchingVariablesWithSameValue = $MatchingVariables | Where-Object -FilterScript {$_.Value -eq $Variable.Value}

                    foreach($matchingVariable in $matchingVariablesWithSameValue) {
                        if($matchingVariable.Scope.Environment -inotcontains $Environment.Id) {
                            Write-Information -MessageData "Matching variable ($($matchingVariable.Id)) has same value, but doesn't include environment scope, adding."
                            $matchingVariable.Scope.Environment += $Environment.Id
                        }
                    }
                    # Lastly check if we have at least one matching variable with the same value and environment scope.
                    $matchingVariablesWithValueAndEnvironment = $MatchingVariables | Where-Object -FilterScript {$_.Value -eq $Variable.Value -and $_.Scope.Environment -icontains $Environment.Id}

                    if($null -eq $matchingVariablesWithValueAndEnvironment) {
                        Write-Information -MessageData "Matching variable '$($Variable.Name)' has no matching value with this Environment scope, adding new."

                        # Create new object
                        $variableToUpdate = New-Object -TypeName PSObject
                        $variableToUpdate | Add-Member -MemberType NoteProperty -Name "Name" -Value $Variable.Name
                        $variableToUpdate | Add-Member -MemberType NoteProperty -Name "Value" -Value $Variable.Value
                        $variableToUpdate | Add-Member -MemberType NoteProperty -Name "Type" -Value $Variable.Type
                        $variableToUpdate | Add-Member -MemberType NoteProperty -Name "IsSensitive" -Value $Variable.IsSensitive
                        $variableToUpdate | Add-Member -MemberType NoteProperty -Name "Scope" -Value $Variable.Scope

                        # Add to collection
                        $LibraryVariableSetVariables.Variables += $variableToUpdate
                    }
                }
            }
            $Count += 1
        }
        Write-Information -MessageData "Updating library variable set."

        # Update the library variable set
        $UpdatedLibraryVariableSet = Invoke-RestMethod -Method Put -Uri "$OctopusURL/api/$($Space.Id)/variables/$($LibraryVariableSetVariables.Id)" -Headers $Headers -Body ($LibraryVariableSetVariables | ConvertTo-Json -Depth 10)

        $StopWatch.Stop()
        Write-Information -MessageData "Completed in $($StopWatch.Elapsed)."
    }
}

ImportAzureDevopsVariableExportToLibraryVariableSet -OctopusURL "https://my.octopus.app" -OctopusAPIKey "API-YOURKEY" -SpaceName "Default" -Path "/path/to/ado_variables_environment.json" -ForceUpdateVariablesWithMultipleScopes $False

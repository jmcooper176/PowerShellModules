<#
 =============================================================================
<copyright file="ModifyOrAddVariableToProject.ps1" company="U.S. Office of Personnel
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
This file "ModifyOrAddVariableToProject.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

function Set-OctopusVariable {
    param (
        $octopusURL = "https://xxx.octopus.app/", # Octopus Server URL
        $octopusAPIKey = "API-xxx",               # API key goes here
        $projectName = "",                        # Replace with your project name
        $spaceName = "Default",                   # Replace with the name of the space you are working in
        $environment = $null,                     # Replace with the name of the environment you want to scope the variables to
        $varName = "",                            # Replace with the name of the variable
        $varValue = "",                           # Replace with the value of the variable
        $gitRefOrBranchName = $null               # Set this value if you are storing a plain-text variable and the project is version controlled. If no value is set, the default branch will be used.
    )

    # Defines header for API call
    $header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

    # Get space
    $space = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/spaces/all" -Headers $header) | Where-Object -FilterScript {$_.Name -eq $spaceName}

    # Get project
    $project = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects/all" -Headers $header) | Where-Object -FilterScript {$_.Name -eq $projectName}

    # Get project variables
    $databaseVariables = Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/variables/$($project.VariableSetId)" -Headers $header

    if($project.IsVersionControlled -eq $true) {
        if ([string]::IsNullOrWhiteSpace($gitRefOrBranchName)) {
            $gitRefOrBranchName = $project.PersistenceSettings.DefaultBranch
            Write-Output "Using $($gitRefOrBranchName) as the gitRef for this operation."
        }
        $versionControlledVariables = Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects/$($project.Id)/$($gitRefOrBranchName)/variables" -Headers $header
    }

    # Get environment values to scope to
    $environmentObj = $databaseVariables.ScopeValues.Environments | Where-Object -FilterScript { $_.Name -eq $environment } | Select-Object -First 1

    # Define values for variable
    $variable = @{
        Name = $varName  # Replace with a variable name
        Value = $varValue # Replace with a value
        Type = "String"
        IsSensitive = $false
        Scope = @{
            Environment = @(
                $environmentObj.Id
                )
            }
    }
    # Assign the correct variables based on version-controlled project or not
    $projectVariables = $databaseVariables

    if($project.IsVersionControlled -eq $True -and $variable.IsSensitive -eq $False) {
        $projectVariables = $versionControlledVariables
    }

    # Check to see if variable is already present. If so, removing old version(s).
    $variablesWithSameName = $projectVariables.Variables | Where-Object -FilterScript {$_.Name -eq $variable.Name}

    if ($null -eq $environmentObj) {
        # The variable is not scoped to an environment
        $unscopedVariablesWithSameName = $variablesWithSameName | Where-Object -FilterScript { $_.Scope -like $null}
        $projectVariables.Variables = $projectVariables.Variables | Where-Object -FilterScript { $_.id -notin @($unscopedVariablesWithSameName.id)}
    }

    if (@($variablesWithSameName.Scope.Environment) -contains $variable.Scope.Environment){
        # At least one of the existing variables with the same name is scoped to the same environment, removing all matches
        $variablesWithMatchingNameAndScope = $variablesWithSameName | Where-Object -FilterScript { $_.Scope.Environment -like $variable.Scope.Environment}
        $projectVariables.Variables = $projectVariables.Variables | Where-Object -FilterScript { $_.id -notin @($variablesWithMatchingNameAndScope.id)}
    }

    # Adding the new value
    $projectVariables.Variables += $variable

    # Update the collection
    if($project.IsVersionControlled -eq $True -and $variable.IsSensitive -eq $False) {
        Invoke-RestMethod -Method Put -Uri "$octopusURL/api/$($space.Id)/projects/$($project.Id)/$($gitRefOrBranchName)/variables" -Headers $header -Body ($projectVariables | ConvertTo-Json -Depth 10)
    }
    else {
        Invoke-RestMethod -Method Put -Uri "$octopusURL/api/$($space.Id)/variables/$($project.VariableSetId)" -Headers $header -Body ($projectVariables | ConvertTo-Json -Depth 10)
    }

}

Set-OctopusVariable -octopusURL "https://xxx.octopus.app/" -octopusAPIKey "API-xxx" -projectName "hello_world" -varName "name" -varValue "alex" -environment "Production" -gitRefOrBranchName $null

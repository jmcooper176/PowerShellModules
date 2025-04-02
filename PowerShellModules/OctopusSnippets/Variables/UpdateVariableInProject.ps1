<#
 =============================================================================
<copyright file="UpdateVariableInProject.ps1" company="U.S. Office of Personnel
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
This file "UpdateVariableInProject.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

Clear-Host
function UpdateVarInProject {
    Param (
        [Parameter(Mandatory=$true)][string] $UserApiKey,
        [Parameter(Mandatory=$true)][string] $OctopusUrl,
        [Parameter(Mandatory=$true)][string] $ProjectName,
        [Parameter(Mandatory=$true)][string] $VariableToModify,
        [Parameter(Mandatory=$true)][string] $VariableValue,
        [Parameter()][string] $EnvironmentScope,
        [Parameter()][string] $RoleScope,
        [Parameter()][string] $MachineScope,
        [Parameter()][string] $ActionScope
    )
    Process {
        Set-Location "C:\Program Files\Octopus Deploy\Tentacle"
        Add-Type -Path 'Newtonsoft.Json.dll'
        Add-Type -Path 'Octopus.Client.dll'
        $endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint $OctopusUrl,$UserApiKey
        $repository = New-Object -TypeName Octopus.Client.OctopusRepository $endpoint
        $project = $repository.Projects.FindByName($ProjectName)
        $variableset = $repository.VariableSets.Get($project.links.variables)
        $variable = $variableset.Variables | Where-Object -FilterScript {$_.name -eq $VariableToModify}
        if ($variable) {
            $variable.Value = $VariableValue
            $Variable.IsSensitive = $false
        }
        else {
            $variable = New-Object -TypeName Octopus.Client.Model.VariableResource
            $variable.Name = $VariableToModify
            $variable.Value = $VariableValue
            $variableset.Variables.Add($variable)
        }
        try {
            if ($EnvironmentScope){
                $variable.Scope.Add([Octopus.Client.Model.ScopeField]::Environment, (New-Object -TypeName Octopus.Client.Model.ScopeValue($EnvironmentScope)))
            }
            if ($RoleScope){
                $variable.Scope.Add([Octopus.Client.Model.ScopeField]::Role, (New-Object -TypeName Octopus.Client.Model.ScopeValue($RoleScope)))
            }
            if ($MachineScope){
                $variable.Scope.Add([Octopus.Client.Model.ScopeField]::Machine, (New-Object -TypeName Octopus.Client.Model.ScopeValue($MachineScope)))
            }
            if ($ActionScope){
                $variable.Scope.Add([Octopus.Client.Model.ScopeField]::Action, (New-Object -TypeName Octopus.Client.Model.ScopeValue($ActionScope)))
            }
        }
        catch {
            $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
        }

        if ($repository.VariableSets.Modify($variableset)) {Write-Information -MessageData "variabe $VariableToModify in $ProjectName successfully modified"}
    }
}
$OctopusUrl = ""
$VarName = "" #Name of the variable to modify
$newvalue = "" # New value to set to the variable
$project = ""
$APIKey = ""
#Example
#UpdateVarInProject -UserApiKey $APIKey -OctopusUrl $OctopusUrl -ProjectName $project -VariableToModify $VarName -VariableValue $newvalue -EnvironmentScope "Environments-30"

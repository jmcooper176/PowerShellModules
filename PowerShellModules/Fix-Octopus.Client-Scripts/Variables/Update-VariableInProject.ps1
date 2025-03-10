cls
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
        $endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $OctopusUrl,$UserApiKey
        $repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
        $project = $repository.Projects.FindByName($ProjectName)
        $variableset = $repository.VariableSets.Get($project.links.variables)
        $variable = $variableset.Variables | Where-Object -Property name -EQ $VariableToModify
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
                $variable.Scope.Add([Octopus.Client.Model.ScopeField]::Environment, (New-Object -TypeName Octopus.Client.Model.ScopeValue -ArgumentList $EnvironmentScope))
            }
            if ($RoleScope){
                $variable.Scope.Add([Octopus.Client.Model.ScopeField]::Role, (New-Object -TypeName Octopus.Client.Model.ScopeValue -ArgumentList $RoleScope))
            }
            if ($MachineScope){
                $variable.Scope.Add([Octopus.Client.Model.ScopeField]::Machine, (New-Object -TypeName Octopus.Client.Model.ScopeValue -ArgumentList $MachineScope))
            }
            if ($ActionScope){
                $variable.Scope.Add([Octopus.Client.Model.ScopeField]::Action, (New-Object -TypeName Octopus.Client.Model.ScopeValue -ArgumentList $ActionScope))
            }
        }
        catch {
            $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
        }

        if ($repository.VariableSets.Modify($variableset)) {Write-Information -MessageData "variable $VariableToModify in $ProjectName successfully modified"}
    }
}
$OctopusUrl = ""
$VarName = "" #Name of the variable to modify
$newvalue = "" # New value to set to the variable
$project = ""
$APIKey = ""
#Example
#UpdateVarInProject -UserApiKey $APIKey -OctopusUrl $OctopusUrl -ProjectName $project -VariableToModify $VarName -VariableValue $newvalue -EnvironmentScope "Environments-30"

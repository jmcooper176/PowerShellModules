﻿$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest;

# Data fix for: http://help.octopusdeploy.com/discussions/problems/51848-variable-with-no-scope

# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path "C:\Program Files\Octopus Deploy\Tentacle\Octopus.Client.dll"

$apikey = 'API-XXXXXXXXXXXXXXXXXXXXXX' # You can get this from your profile
$octopusURI = 'https://octopus.url' # Your server address
$projectName = "Variables" # Name of the project where you want to update the variable

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURI, $apikey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint

#Get Project
$project = $repository.Projects.FindByName($projectName)

#Get Project's variable set
$variableset = $repository.VariableSets.Get($project.links.variables)

#Get variable to update
$variables = $variableset.Variables | Where-Object -Property Scope -NE $null

foreach($variable in $variables){
    $keys = @() + $variable.Scope.Keys
    foreach($propertyName in $keys){
        $propertyValue = $variable.Scope[$propertyName]
        if ($propertyValue.Count -eq 0) {
            Write-Information -MessageData "Removing empty '$propertyName' scope collection from '$($variable.Name)' variable"
            $variable.Scope.Remove($propertyName)
        }
    }
}

#Save variable set
$repository.VariableSets.Modify($variableset)

# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/

Add-Type -Path 'C:\MyScripts\Octopus.Client\Octopus.Client.dll'

$apikey = 'API-XXXXXXXXXXXXXXXXXXXXXXXXXX' # Get this from your profile
$octopusURI = 'https://octopus.url' # Your Octopus Server address

$projectName = "TestProp"  # Enter project you want to search

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURI, $apiKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint

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

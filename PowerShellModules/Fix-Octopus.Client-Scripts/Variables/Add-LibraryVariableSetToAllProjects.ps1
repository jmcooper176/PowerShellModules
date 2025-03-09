# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path 'Octopus.Client.dll'

$apikey = 'API-ABC123' # Get this from your profile
$octopusURI = 'http://octopus-uri' # Your server address

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURI,$apikey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint

$libraryVariableSet = New-Object -TypeName Octopus.Client.Model.LibraryVariableSetResource
$libraryVariableSet.Name = "Ignore config transform errors"
$libraryVariableSet = $repository.LibraryVariableSets.Create($libraryVariableSet)

$ignoreConfigTransformVariable = New-Object -TypeName Octopus.Client.Model.VariableResource
$ignoreConfigTransformVariable.Name = "Octopus.Action.Package.IgnoreConfigTransformationErrors"
$ignoreConfigTransformVariable.Value = "true"

$variables = $repository.VariableSets.Get($libraryVariableSet.VariableSetId)
$variables.Variables.Add($ignoreConfigTransformVariable)
$repository.VariableSets.Modify($variables)

$projects = $repository.Projects.FindAll()
foreach ($project in $projects) {
    $project.IncludedLibraryVariableSetIds.Add($libraryVariableSet.Id)
    $repository.Projects.Modify($project)
}

$ErrorActionPreference = "Stop"

# Load assembly
Add-Type -Path 'path:\to\Octopus.Client.dll'
# Define working variables
$octopusURL = "https://YourURL"
$octopusAPIKey = "API-YourAPIKey"
$spaceName = "Default"
$libraryVariableSetName = "MyLibraryVariableSet"
$variableName = "MyVariable"
$variableValue = "MyValue"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

# Get repository specific to space
$space = $repository.Spaces.FindByName($spaceName)
$repositoryForSpace = $client.ForSpace($space)

Write-Information -MessageData "Looking for library variable set '$libraryVariableSetName'"

$librarySet = $repositoryForSpace.LibraryVariableSets.FindByName($libraryVariableSetName)

# Check to see if something was returned
if ($null -eq $librarySet)
{
    Write-Warning -Message "Library variable not found with name '$libraryVariabelSetName'"
    exit
}

# Get the variableset
$variableSet = $repositoryForSpace.VariableSets.Get($librarySet.VariableSetId)

# Get the variable
($variableSet.Variables | Where-Object -FilterScript {$_.Name -eq $variableName}).Value = $variableValue

# Update
$repositoryForSpace.VariableSets.Modify($variableSet)

# Load assembly
Add-Type -Path 'path:\to\Octopus.Client.dll'
$octopusURL = "https://YourURL"
$octopusAPIKey = "API-YourAPIKey"
$spaceName = "Default"
$variableValueToFind = "MyValue"
$csvExportPath = "c:\temp\variable.csv"

$variableTracking = @()

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

# Get space
$space = $repository.Spaces.FindByName($spaceName)
$repositoryForSpace = $client.ForSpace($space)

Write-Information -MessageData "Looking for usages of variable value '$variableValueToFind' in space: $($space.Name)"

# Get all variable sets
$variableSets = $repositoryForSpace.LibraryVariableSets.GetAll()

# Loop through variable sets
foreach ($variableSet in $variableSets)
{
    Write-Information -MessageData "Checking variable set: $($variableSet.Name)"

    # Get variables associated with variable set
    $variables = $repositoryForSpace.VariableSets.Get($variableSet.VariableSetId)

    $matchingNamedVariables = $variableSetVariables.Variables | Where-Object -FilterScript {$_.Value -like "*$variableValueToFind*"}
    if($null -ne $matchingNamedVariables){
        foreach($match in $matchingNamedVariables){
            $result = [PSCustomObject]@{
                Project = $null
                VariableSet = $variableSet.Name
                MatchType = "Value in Library Set"
                Context = $match.Value
                Property = $null
                AddtionalContext = $match.Name
            }
            $variableTracking += $result
        }
    }
}

# Get all projects
$projects = $repositoryForSpace.Projects.GetAll()

# Loop through projects
foreach ($project in $projects)
{
    Write-Information -MessageData "Checking project '$($project.Name)'"
    # Get project variables
    $projectVariableSet = $repositoryForSpace.VariableSets.Get($project.VariableSetId)

    # Check to see if variable is named in project variables.
    $ProjectMatchingNamedVariables = $projectVariableSet.Variables | Where-Object -FilterScript {$_.Value -like "*$variableValueToFind*"}
    if($null -ne $ProjectMatchingNamedVariables) {
        foreach($match in $ProjectMatchingNamedVariables) {
            $result = [pscustomobject]@{
                Project = $project.Name
                VariableSet = $null
                MatchType = "Named Project Variable"
                Context = $match.Value
                Property = $null
                AdditionalContext = $match.Name
            }

            # Add to tracking list
            $variableTracking += $result
        }
    }
}

if($variableTracking.Count -gt 0) {
    Write-Information -MessageData ""
    Write-Information -MessageData "Found $($variableTracking.Count) results:"
    $variableTracking
    if (![string]::IsNullOrWhiteSpace($csvExportPath)) {
        Write-Information -MessageData "Exporting results to CSV file: $csvExportPath"
        $variableTracking | Export-Csv -Path $csvExportPath -NoTypeInformation
    }
}

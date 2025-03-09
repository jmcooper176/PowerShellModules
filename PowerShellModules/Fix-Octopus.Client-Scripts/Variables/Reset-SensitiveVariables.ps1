# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path "path\to\Octopus.Client.dll"

# Octopus variables
$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"
$spaceName = "default"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

Function Clear-SensitiveVariables
{
    # Define function variables
    param ($VariableSetId)

    # Get the variable set
    $variableSet = $repositoryForSpace.VariableSets.Get($VariableSetId)

    # Loop through variables
    foreach ($variable in $VariableSet)
    {
        # Check for sensitive
        if ($variable.IsSensitive)
        {
            $variable.Value = [string]::Empty
        }
    }

    # Update set
    $repositoryForSpace.VariableSets.Modify($variableSet)
}

try
{
    # Get space
    $space = $repository.Spaces.FindByName($spaceName)
    $repositoryForSpace = $client.ForSpace($space)

    # Loop through projects
    foreach ($project in $repositoryForSpace.Projects.GetAll())
    {
        # Clear the sensitive ones
        Clear-SensitiveVariables -VariableSetId $project.VariableSetId
    }

    # Loop through library variable sets
    foreach ($libararySet in $repositoryForSpace.LibraryVariableSets.GetAll())
    {
        # Clear sensitive ones
        Clear-SensitiveVariables -VariableSetId $libararySet.VariableSetId
    }
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}

# Load octopus.client assembly
Add-Type -Path "c:\octopus.client\Octopus.Client.dll"

# Octopus variables
$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"
$spaceName = "default"
$projectName = "MyProject"
$variable = @{
    Name = "MyVariable"
    Value = "MyValue"
    Type = "String"
    IsSensitive = $false
}

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

try
{
    # Get space
    $space = $repository.Spaces.FindByName($spaceName)
    $repositoryForSpace = $client.ForSpace($space)

    # Get project
    [Octopus.Client.Model.ProjectResource]$project = $repositoryForSpace.Projects.FindByName($projectName)

    # Get project variables
    $projectVariables = $repositoryForSpace.VariableSets.Get($project.VariableSetId)

    # Check to see if variable exists
    $variableToUpdate = ($projectVariables.Variables | Where-Object -FilterScript {$_.Name -eq $variable.Name})
    if ($null -eq $variableToUpdate)
    {
        # Create new object
        $variableToUpdate = New-Object -TypeName Octopus.Client.Model.VariableResource
        $variableToUpdate.Name = $variable.Name
        $variableToUpdate.IsSensitive = $variable.IsSensitive
        $variableToUpdate.Value = $variable.Value
        $variableToUpdate.Type = $variable.Type

        # Add to collection
        $projectVariables.Variables.Add($variableToUpdate)
    }
    else
    {
        # Update the value
        $variableToUpdate.Value = $variable.Value
    }

    # Update the projectvariable
    $repositoryForSpace.VariableSets.Modify($projectVariables)
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}

# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path 'path\to\Octopus.Client.dll'

$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint

$spaceName = "New Space"
$description = "Space for the new, top secret project."
$managersTeams = @() # an array of team Ids to add to Space Managers
$managerTeamMembers = @() # an array of user Ids to add to Space Managers
$environments = @('Development', 'Test', 'Production')

$space = New-Object -TypeName Octopus.Client.Model.SpaceResource -Property @{
    Name = $spaceName
    Description = $description
    SpaceManagersTeams = New-Object -TypeName Octopus.Client.Model.ReferenceCollection -ArgumentList $managersTeams
    SpaceManagersTeamMembers = New-Object -TypeName Octopus.Client.Model.ReferenceCollection -ArgumentList $managerTeamMembers
    IsDefault = $false
    TaskQueueStopped = $false
}

try {
    $space = $repository.Spaces.Create($space)
}
catch {
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
    throw $Error[0]
}

$repositoryForSpace = [Octopus.Client.OctopusRepositoryExtensions]::ForSpace($repository, $space)

foreach ($environmentName in $environments) {
    $environment = New-Object -TypeName Octopus.Client.Model.EnvironmentResource -Property @{
        Name = $environmentName
    }

    try {
        $repositoryForSpace.Environments.Create($environment)
    }
    catch {
        $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
        throw $Error[0]
    }
}

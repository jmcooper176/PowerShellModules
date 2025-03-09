# You can reference this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/

# Load octopus.client assembly
Add-Type -Path "path\to\Octopus.Client.dll"

# Octopus variables
$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"
$spaceName = "default"
$projectName = "MyProject"
$teamName = "MyTeam"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

try
{
    # Get space
    $space = $repository.Spaces.FindByName($spaceName)
    $repositoryForSpace = $client.ForSpace($space)

    # Get project
    $project = $repositoryForSpace.Projects.FindByName($projectName)

    # Get team
    $team = $repositoryForSpace.Teams.FindByName($teamName)

    # Get scoped user roles
    $scopedUserRoles = $repositoryForSpace.ScopedUserRoles.FindMany({param($p) $p.ProjectIds -contains $project.Id -and $p.TeamId -eq $team.Id})

    # Loop through scoped user roles and remove where present
    foreach ($scopedUserRole in $scopedUserRoles)
    {
        $scopedUserRole.ProjectIds = [Octopus.Client.Model.ReferenceCollection]($scopedUserRole.ProjectIds | Where-Object -FilterScript {$_ -notcontains $project.Id})
        $repositoryForSpace.ScopedUserRoles.Modify($scopedUserRole)
    }
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}

# You can reference this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/

Add-Type -Path "c:\octopus.client\Octopus.Client.dll"

# Octopus variables
$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"
$spaceName = "default"
$userRoleName = "Deployment creator"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

try
{
    # Get space
    $space = $repository.Spaces.FindByName($spaceName)
    $repositoryForSpace = $client.ForSpace($space)

    # Get team
    $teams = $repositoryForSpace.Teams.FindAll()

    # Get user role
    $userRole = $repositoryForSpace.UserRoles.FindByName($userRoleName)

    # Loop through teams
    $teamNames = @()
    foreach ($team in $teams)
    {
        # Get scopeduserrole
        $scopedUserRole = $repositoryForSpace.Teams.GetScopedUserRoles($team) | Where-Object -FilterScript {$_.UserRoleId -eq $userRole.Id}

        # Check for null
        if ($null -ne $scopedUserRole)
        {
            # Add to list
            $teamNames += $team.Name
        }
    }

    # Loop through results
    Write-Information -MessageData "The following teams are using role $($userRoleName):"
    foreach ($teamName in $teamNames)
    {
        Write-Information -MessageData "$teamName"
    }
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}

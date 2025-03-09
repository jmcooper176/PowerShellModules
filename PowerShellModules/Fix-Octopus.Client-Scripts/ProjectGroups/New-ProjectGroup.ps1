# Load assembly
Add-Type -Path 'path:\to\Octopus.Client.dll'
$octopusURL = "https://YourURL"
$octopusAPIKey = "API-YourAPIKey"
$spaceName = "Default"
$projectGroupName = "MyProjectGroup"
$projectGroupDescription = "MyDescription"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

# Get space
$space = $repository.Spaces.FindByName($spaceName)
$repositoryForSpace = $client.ForSpace($space)

# Create project group object
$projectGroup = New-Object -TypeName Octopus.Client.Model.ProjectGroupResource
$projectGroup.Description = $projectGroupDescription
$projectGroup.Name = $projectGroupName
$projectGroup.EnvironmentIds = $null
$projectGroup.RetentionPolicyId = $null

$repositoryForSpace.ProjectGroups.Create($projectGroup)

# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
# Load Octopus Client assembly
Add-Type -Path 'path\to\Octopus.Client.dll'

$octopusURL = "https://YourUrl"
$octopusAPIKey = "API-YourAPIKey"
$spaceName = "Default"
$projectName = "MyProject"
$channelName = "NewChannel"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

# Get space
$space = $repository.Spaces.FindByName($spaceName)
$repositoryForSpace = $client.ForSpace($space)

# Get project
$project = $repositoryForSpace.Projects.FindByName($projectName)

# Createw new channel object
$channel = New-Object -TypeName Octopus.Client.Model.ChannelResource
$channel.Name = $channelName
$channel.ProjectId = $project.Id
$channel.SpaceId = $space.Id

# Add channel
$repositoryForSpace.Channels.Create($channel)

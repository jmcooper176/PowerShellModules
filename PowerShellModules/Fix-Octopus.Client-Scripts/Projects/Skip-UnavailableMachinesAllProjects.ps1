# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path 'Octopus.Client.dll'

$apikey = 'API-MYAPIKEY' # Get this from your profile
$octopusURI = 'http://MY-OCTOPUS' # Your server address

$roles = "web-server", "app-server" # The roles that are transient

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURI,$apikey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint

$projects = $repository.Projects.GetAll()
$projects |ForEach-Object -Process{
    $project = $_
    $project.ProjectConnectivityPolicy.SkipMachineBehavior = [Octopus.Client.Model.SkipMachineBehavior]::SkipUnavailableMachines
    $roles |ForEach-Object -Process{ $project.ProjectConnectivityPolicy.TargetRoles.Add($_) }
    $repository.Projects.Modify($project)
}

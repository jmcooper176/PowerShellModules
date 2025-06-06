# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path 'Octopus.Client.dll'

$apikey = 'API-xxx' # Get this from your profile
$octopusURI = 'http://localhost' # Your Octopus Server address

$releaseId = "Releases-1" # Get this from /api/releases
$environmentId = "Environments-1" # Get this from /api/environments
$tenantId = "Tenants-1" # Get this from /api/tenants

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURI,$apikey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint

$release = $repository.Releases.Get($releaseId)
$deployment = New-Object -TypeName Octopus.Client.Model.DeploymentResource
$deployment.ReleaseId = $release.Id
$deployment.ProjectId = $release.ProjectId
$deployment.EnvironmentId = $environmentId
$deployment.TenantId = $tenantId

$repository.Deployments.Create($deployment)

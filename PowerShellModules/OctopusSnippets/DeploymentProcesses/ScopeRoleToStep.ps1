# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
Add-Type -AssemblyName 'Octopus.Client' 

$apikey = 'API-MCPLE1AQM2VKTRFDLIBMORQHBXA' # Get this from your profile
$octopusURI = 'http://localhost' # Your server address

$projectName = "Demo project" # The name of your project
$roleName = "demo-role" # The role this step will be scoped to

$endpoint = New-Object -TypeName.Client.OctopusServerEndpoint $octopusURI,$apikey 
$repository = New-Object -TypeName.Client.OctopusRepository $endpoint

$project = $repository.Projects.FindByName($projectName) 

$deploymentProcess = $repository.DeploymentProcesses.Get($project.DeploymentProcessId)

foreach ($step in $deploymentProcess.Steps)
{
  $step.Properties.'Octopus.Action.TargetRoles' = $roleName
}
$repository.DeploymentProcesses.Modify($deploymentProcess)

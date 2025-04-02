# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path "path\to\Octopus.Client.dll"

$apikey = "API-YOURAPIKEY"
$octopusURL = "https://youroctourl"
$spaceName = "default"
$stepName = "Run a script"
$environmentNames = @("Development", "Test")
$projectName = "MyProject"

# Create endpoint and client
$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint $octopusURL, $apikey
$client = New-Object -TypeName Octopus.Client.OctopusClient $endpoint

try
{
    $repository = $client.ForSystem()

    # Get space specific repository and get all projects in space
    $space = $repository.Spaces.FindByName($spaceName)
    $repositoryForSpace = $client.ForSpace($space)
    $project = $repositoryForSpace.Projects.FindByName($projectName)
    $environments = $repositoryForSpace.Environments.GetAll() | Where-Object -FilterScript {$environmentNames -contains $_.Name} | Select-Object -Property Id

    # Get process
    $deploymentProcess = $repositoryForSpace.DeploymentProcesses.Get($project.DeploymentProcessId)

    # Get step
    $step = $deploymentProcess.Steps | Where-Object -FilterScript {$_.Name -eq $stepName}

    # Update the action
    foreach ($action in $step.Actions)
    {
        foreach ($id in $environments.Id)
        {
            $action.Environments.Add($id)
        }
    }
    
    # Update deployment process
    $repositoryForSpace.DeploymentProcesses.Modify($deploymentProcess)
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}
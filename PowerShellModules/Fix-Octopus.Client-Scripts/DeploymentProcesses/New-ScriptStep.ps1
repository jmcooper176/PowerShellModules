# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
# Load Octopous Client assembly
Add-Type -Path 'c:\octopus.client\Octopus.Client.dll'

# Declare Octopus variables
$apikey = 'API-YOURAPIKEY'
$octopusURI = 'https://youroctourl'
$projectName = "MyProject"

# Create repository object
$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURI,$apikey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

# Get reference to space
$space = $repository.Spaces.FindByName($spaceName)
$repositoryForSpace = $client.ForSpace($space)

try
{
    # Get project
    $project = $repositoryForSpace.Projects.FindByName($projectName)

    # Get project process
    $process = $repositoryForSpace.DeploymentProcesses.Get($project.DeploymentProcessId)

    # Define new step
    $stepName = "Run a script" # The name of the step
    $role = "My role" # The machine role to run this step on
    $scriptBody = "Write-Information -MessageData 'Hello world'" # The script to run
    $step = New-Object -TypeName Octopus.Client.Model.DeploymentStepResource
    $step.Name = $stepName
    $step.Condition = [Octopus.Client.Model.DeploymentStepCondition]::Success
    $step.Properties.Add("Octopus.Action.TargetRoles", $role)

    # Define script action
    $scriptAction = New-Object -TypeName Octopus.Client.Model.DeploymentActionResource
    $scriptAction.ActionType = "Octopus.Script"
    $scriptAction.Name = $stepName
    $scriptAction.Properties.Add("Octopus.Action.Script.ScriptBody", $scriptBody)

    # Add step to process
    $step.Actions.Add($scriptAction)
    $process.Steps.Add($step)
    $repositoryForSpace.DeploymentProcesses.Modify($process)
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}

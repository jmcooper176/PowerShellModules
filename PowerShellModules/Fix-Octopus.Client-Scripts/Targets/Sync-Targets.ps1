# Load octopus.client assembly
Add-Type -Path "path\to\Octopus.Client.dll"

# Octopus variables
$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"
$spaceName = "default"
$machineNames = @("MyMachine")

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

try
{
    # Get space
    $space = $repository.Spaces.FindByName($spaceName)
    $repositoryForSpace = $client.ForSpace($space)

    # Get machines
    $machines = @()
    foreach ($machineName in $machineNames)
    {
        # Get machine
        $machine = $repositoryForSpace.Machines.FindByName($machineName)
        $machines += $machine.Id
    }

    # Create new task resource
    $task = New-Object -TypeName Octopus.Client.Model.TaskResource
    $task.Name = "Upgrade"
    $task.Description = "Upgrade machines"
    $task.Arguments.Add("MachineIds", $machines)

    # Execute
    $repositoryForSpace.Tasks.Create($task)
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}

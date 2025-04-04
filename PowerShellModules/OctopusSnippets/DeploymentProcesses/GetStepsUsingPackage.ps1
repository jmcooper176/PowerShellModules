Add-Type -Path "path\to\Octopus.Client.dll"

# Octopus variables
$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"
$spaceName = "default"
$packageId = "PackageId"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient $endpoint

# Get space
$space = $repository.Spaces.FindByName($spaceName)
$repositoryForSpace = $client.ForSpace($space)

$projectList = $repositoryForSpace.Projects.GetAll()

"Looking for steps with the package $($packageId) in them..."

foreach ($project in $projectList) {
    
    $deploymentProcess = $repositoryForSpace.DeploymentProcesses.Get($project)

    # Loop through steps
    foreach ($step in $deploymentProcess.Steps) {
        $packages = $step.Actions.Packages
        if ($null -ne $packages) {
            $packageIds = $packages | Where-Object -FilterScript { $_.PackageId -eq $packageId }
            if ($packageIds.Count -gt 0) {
                Write-Information -MessageData "Step: $($step.Name) of project: $($project.Name) is using package '$packageId'."
            }
        }
    }
}
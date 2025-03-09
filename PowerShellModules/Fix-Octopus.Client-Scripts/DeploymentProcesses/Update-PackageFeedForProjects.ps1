# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path 'Octopus.Client.dll'

$apikey = 'API-XXXXXXXXXXXXXXXXXXXXXX' # Get this from your profile
$octopusURI = 'https://octopus.url' # Your server address
$projectSearchString = "FOO" # Common string contained in projects to change

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURI,$apikey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint

$repository.Projects.FindMany({Param($p) $p.Name.Contains($projectSearchString)}) |ForEach-Object -Process{
    $process = $repository.DeploymentProcesses.Get($_.DeploymentProcessId)
    $process.Steps |ForEach-Object -Process{
        $_.Actions |ForEach-Object -Process{
            if ($_.ActionType -eq "Octopus.TentaclePackage")
            {
                Write-Output "Setting feed for step $($_.Name) to the built-in package repository"
                $_.Properties["Octopus.Action.Package.FeedId"] = "feeds-builtin"
            }
        }
    }
    $repository.DeploymentProcesses.Modify($process)
}

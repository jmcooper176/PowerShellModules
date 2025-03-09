# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path .\Octopus.Client.dll

$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"
$spaceName = "Default"
$Description = "Health check started from Powershell script"
$TimeOutAfterMinutes = 5
$MachineTimeoutAfterMinutes = 5

# Choose an Environment, a set of machine names, or both.
$EnvironmentName = ""
$MachineNames = @()

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

try
{
    # Get space
    $space = $repository.Spaces.FindByName($spaceName)
    $repositoryForSpace = $client.ForSpace($space)

    # Get EnvironmentId
    $EnvironmentID = $null
    if([string]::IsNullOrWhiteSpace($EnvironmentName) -eq $False)
    {
        $EnvironmentID = $repositoryForSpace.Environments.FindByName($EnvironmentName).Id
    }

    # Get MachineIds
    $MachineIds = $null
    if($MachineNames.Count -gt 0)
    {
        $MachineIds = ($repositoryForSpace.Machines.GetAll() | Where-Object -FilterScript {$MachineNames -contains $_.Name} | Select-Object -ExpandProperty Id) -Join ", "
    }

    # Execute health check
    $repositoryForSpace.Tasks.ExecuteHealthCheck($Description,$TimeOutAfterMinutes,$MachineTimeoutAfterMinutes,$EnvironmentID,$MachineIds)
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}

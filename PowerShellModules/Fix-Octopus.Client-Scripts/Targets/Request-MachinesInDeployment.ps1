# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path 'Octopus.Client.dll'

$apikey = 'API-xxx' # Get this from your profile
$octopusURI = 'http://octopus' # Your server address

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURI,$apikey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint

$machineIds = $OctopusParameters['Octopus.Deployment.Machines'].Split(',')

foreach ($machineId in $machineIds) {
    $machine = $repository.Machines.Get($machineId)
    Write-Information -MessageData $machine.Name
}

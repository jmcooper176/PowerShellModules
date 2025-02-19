# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path 'Octopus.Client.dll' 

$apikey = 'API-xxx' # Get this from your profile
$octopusURI = 'http://octopus' # Your server address

$endpoint = New-Object Octopus.Client.OctopusServerEndpoint $octopusURI,$apikey 
$repository = New-Object Octopus.Client.OctopusRepository $endpoint

$machineIds = $OctopusParameters['Octopus.Deployment.Machines'].Split(',')

foreach ($machineId in $machineIds) {    
    $machine = $repository.Machines.Get($machineId)
    Write-Host $machine.Name
}

# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
# Load Octopus Client assembly
Add-Type -Path 'path\to\Octopus.Client.dll'

# Create endpoint and client
$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList "http://OctopusServer/", "API-KEY"
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

# Get default repository and get space by name
#$repository = $client.ForSystem()
#$space = $repository.Spaces.FindByName("Second")

# Get space specific repository and get all projects in space
#$repo = $client.ForSpace($space)

$certificates = $client.Repository.Certificates.GetAll()

$certsToKeep = New-Object -TypeName Collections.Generic.List[string]

# Will remove any duplicate certificates from Octopus based on SerialNumber. Delete function is commented out for a dry run.

foreach ($cert in $certificates) {
    if ($certsToKeep -contains $cert.SerialNumber) {
    Write-Information -MessageData "Deleting:" $cert.id
    #$client.Repository.Certificates.Delete($cert) # Run this script before you enable the delete to confirm that you are Keeping & Deleting the correct certificates.
    }
    else {
        $certsToKeep.Add($cert.SerialNumber)
        Write-Information -MessageData "Keeping:" $cert.id
    }
}

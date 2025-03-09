# Load octopus.client assembly
Add-Type -Path "path\to\Octopus.Client.dll"

# Octopus variables
$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"
$spaceName = "default"
$librarySetName = "MyLibrarySet"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

try
{
    # Get space
    $space = $repository.Spaces.FindByName($spaceName)
    $repositoryForSpace = $client.ForSpace($space)

    # Get Library set
    $librarySet = $repositoryForSpace.LibraryVariableSets.FindByName($librarySetName)

    # Get Projects
    $projects = $repositoryForSpace.Projects.GetAll()

    # Show all projects using set
    Write-Information -MessageData "The following projects are using $librarySetName"
    foreach ($project in $projects)
    {
        if ($project.IncludedLibraryVariableSetIds -contains $librarySet.Id)
        {
            Write-Information -MessageData "$($project.Name)"
        }
    }
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}

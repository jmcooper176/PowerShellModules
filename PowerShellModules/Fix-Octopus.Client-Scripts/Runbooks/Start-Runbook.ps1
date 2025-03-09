# Load octopus.client assembly
Add-Type -Path "c:\octopus.client\Octopus.Client.dll"

# Octopus variables
$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"
$spaceName = "default"
$projectName = "MyProject"
$runbookName = "MyRunbook"
$environmentNames = @("Test", "Production")

# Optional Tenant
$tenantName = ""
$tenantId = $null

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

try
{
    # Get space
    $space = $repository.Spaces.FindByName($spaceName)
    $repositoryForSpace = $client.ForSpace($space)

    # Get project
    $project = $repositoryForSpace.Projects.FindByName($projectName)

    # Get runbook
    $runbook = $repositoryForSpace.Runbooks.FindMany({param($r) $r.Name -eq $runbookName}) | Where-Object -FilterScript {$_.ProjectId -eq $project.Id}

    # Get environments
    $environments = $repositoryForSpace.Environments.GetAll() | Where-Object -FilterScript {$environmentNames -contains $_.Name}

    # Optionally get tenant
    if (![string]::IsNullOrEmpty($tenantName)) {
        $tenant = $repositoryForSpace.Tenants.FindByName($tenantName)
        $tenantId = $tenant.Id
    }

    # Loop through environments
    foreach ($environment in $environments)
    {
        # Create a new runbook run object
        $runbookRun = New-Object -TypeName Octopus.Client.Model.RunbookRunResource
        $runbookRun.EnvironmentId = $environment.Id
        $runbookRun.ProjectId = $project.Id
        $runbookRun.RunbookSnapshotId = $runbook.PublishedRunbookSnapshotId
        $runbookRun.RunbookId = $runbook.Id
        $runbookRun.TenantId = $tenantId

        # Execute runbook
        $repositoryForSpace.RunbookRuns.Create($runbookRun)
    }
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}

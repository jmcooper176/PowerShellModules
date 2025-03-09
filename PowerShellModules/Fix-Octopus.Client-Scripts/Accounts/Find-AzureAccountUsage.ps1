<#
    .DESCRIPTION
    This script will look for the usage of a specific Azure Account in all projects and print the results.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidatePattern('^API-.*$')]
    [string]
    $ApiKey,

    [Parameter(Mandatory)]
    [ValidateScript({ [uri]::IsWellFormedUriString($_, 'Absolute') })]
    [string]
    $OctopusUri,

    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [string]
    $AccountName
)

BEGIN {
    $ScriptName = Initialize-PSScript -MyInvocation $MyInvocation

    Add-Type -Path 'Octopus.Client.dll'
}

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURI,$ApiKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint

$AllProjects = $Repository.Projects.FindAll()

$Account = $Repository.Accounts.FindByName($AccountName)

foreach($project in $AllProjects){
    $deploymentProcess = $Repository.DeploymentProcesses.Get($project.deploymentprocessid)

    foreach($step in $deploymentProcess.steps){
        foreach ($action in $step.actions){
            if($action.Properties['Octopus.Action.Azure.AccountId'].value -eq $Account.Id){
                Write-Output "Project - [$($project.name)]"
                Write-Output "`t- Account [$($account.name)] is being used in the step [$($step.name)]"
            }
        }
    }
}

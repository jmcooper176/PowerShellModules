$octopusServerUrl = "http://yourserver"
$octopusApiKey = "API-zzzzzzzzzzzzzzzzzzzzzzzz"
$azureSubscription = "zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz"

$envName = "AzureDemo"
$spName = "My Service Principal"

$roleName = "CloudWebServer"

#=========================================================================================================

add-type -path 'C:\tools\Octopus.Client.dll'

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusServerUrl, $octopusApiKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint

$environmentDetails = $repository.Environments.FindByName($envName)
$environmentId = $environmentDetails.Id
Write-Information -MessageData "got Octopus env " $environmentDetails.Name

$accountDetails = $repository.Accounts.FindByName($spName)
$accountId = $accountDetails.Id
Write-Information -MessageData "got Octopus account " $accountDetails.Name

Login-AzureRmAccount
Select-AzureRmSubscription $azureSubscription

Write-Information -MessageData "connected to Azure..."

$webApps = Get-AzureRmWebApp

foreach ($webApp in $webApps)
{
    Write-Information -MessageData "target for " $webApp.SiteName

    $target = New-Object -TypeName Octopus.Client.Model.MachineResource -Property @{
                        Name = $webApp.SiteName
                        Roles = New-Object -TypeName Octopus.Client.Model.ReferenceCollection -ArgumentList $roleName
                        Endpoint = New-Object -TypeName Octopus.Client.Model.Endpoints.AzureWebAppEndpointResource -Property @{
                            AccountId = $accountId
                            ResourceGroupName = $webApp.ResourceGroup
                            WebAppName = $webApp.SiteName }
                        EnvironmentIds = New-Object -TypeName Octopus.Client.Model.ReferenceCollection -ArgumentList $environmentId
                    }

    Write-Information -MessageData "creating target in Octopus for " $webApp.SiteName

    $repository.Machines.Create($target, $null)
}

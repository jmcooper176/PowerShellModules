#
# OctopusClientModule.psm1
#

<###########################################
    Get-AccountByName
##########################################>
function Get-AccountByName {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Octopus.Client.OctopusRepository]
        $Repository,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $AccountName
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Add-Type -Path 'Octopus.Client.dll'
    }

    PROCESS {
        $Repository.Accounts.FindByName($AccountName) | Write-Output
    }
}

<###########################################
    Get-Action
##########################################>
function Get-Action {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        $Step
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Add-Type -Path 'Octopus.Client.dll'
    }

    PROCESS {
        $Step.actions | Write-Output
    }
}

<###########################################
    Get-ActionProperty
##########################################>
function Get-ActionProperty {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        $Step,

        [Parameter(Mandatory)]
        [ValidateSet('Octopus.Action.Azure.AccountId')]
        [string]
        $Property
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Add-Type -Path 'Octopus.Client.dll'
    }

    PROCESS {
        $Step | Get-Action | ForEach-Object -Process { $_.Properties[$Property].value | Write-Output }
    }
}

<###########################################
    Get-DeploymentProcess
##########################################>
function Get-DeploymentProcess {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Octopus.Client.OctopusRepository]
        $Repository,

        [Parameter(Mandatory)]
        $Project
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Add-Type -Path 'Octopus.Client.dll'
    }

    PROCESS {
        $Repository.DeploymentProcesses.Get($Project.deploymentprocessid)
    }
}

<###########################################
    Get-Project
##########################################>
function Get-Project {
    [CmdletBinding()]
    [OutputType([Octopus.Client.])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Octopus.Client.OctopusRepository]
        $Repository,

        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [switch]
        $All
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Add-Type -Path 'Octopus.Client.dll'
    }

    PROCESS {
        if ($All.IsPresent) {
            $Repository.Projects.FindAll() | Write-Output
        }
        elseif ($PSBoundParameters.ContainsKey('Name')) {
            $Repository.Projects.FindAll() | Where-Object -Property Name -EQ $Name | Write-Output
        }
        else {
            return $null
        }
    }
}

<###########################################
    Get-Step
##########################################>
function Get-Step {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        $DeploymentProcess
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Add-Type -Path 'Octopus.Client.dll'
    }

    PROCESS {
        $DeploymentProcess.steps | Write-Output
    }
}

<###########################################
    Initialize-AzureServicePrincipal
##########################################>
function Initialize-AzureServicePrincipal {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Octopus.Client.Model.Accounts.AzureServicePrincipalAccountResource]
        $AzureServicePrincipal,

        [hashtable]
        $PropertyValue
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Add-Type -Path 'Octopus.Client.dll'
    }

    PROCESS {
        $AzureServicePrincipal | ForEach-Object -Process {
            if (-not $PSBoundParameters.ContainsKey('PropertyValue') -or ($null -eq $PropertyValue) -or ($PropertyValue.Keys.Count -lt 1)) {
                return $_
            }

            if ($PropertyValue.ContainsKey('ClientId')) {
                $_.ClientId = $PropertyValue['ClientId']
            }

            if ($PropertyValue.ContainsKey('TenantId')) {
                $_.TenantId = $PropertyValue['TenantId']
            }

            if ($PropertyValue.ContainsKey('Description')) {
                $_.Description = $PropertyValue['Description']
            }

            if ($PropertyValue.ContainsKey('Name')) {
                $_.Name = $PropertyValue['Name']
            }

            if ($PropertyValue.ContainsKey('Password')) {
                $_.Password = $PropertyValue['Password']
            }

            if ($PropertyValue.ContainsKey('SubscriptionNumber')) {
                $_.SubscriptionNumber = $PropertyValue['SubscriptionNumber']
            }

            if ($PropertyValue.ContainsKey('TenantedDeploymentParticipation')) {
                $_.TenantedDeploymentParticipation = $PropertyValue['TenantedDeploymentParticipation']
            }

            if ($PropertyValue.ContainsKey('TenantTags')) {
                $_.TenantTags = $PropertyValue['TenantTags']
            }

            if ($PropertyValue.ContainsKey('TenantIds')) {
                $_.TenantIds = $PropertyValue['TenantIds']
            }

            if ($PropertyValue.ContainsKey('EnvironmentIds')) {
                $_.EnvironmentIds = $PropertyValue['EnvironmentIds']
            }

            $_ | Write-Output
        }
    }
}

<###########################################
    New-AzureServicePrincipal
##########################################>
function New-AzureServicePrincipal {
    [CmdletBinding()]
    [OutputType([Octopus.Client.Model.Accounts.AzureServicePrincipalAccountResource])]
    param ()

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    Add-Type -Path 'Octopus.Client.dll'

    New-Object -TypeName Octopus.Client.Model.Accounts.AzureServicePrincipalAccountResource | Write-Output
}

<###########################################
    New-Client
##########################################>
function New-Client {
    [CmdletBinding()]
    [OutputType([Octopus.Client.OctopusClient])]
    param (
        [Parameter(Mandatory)]
        [Octopus.Client.OctopusServer.Endpoint]
        $Endpoint
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    Add-Type -Path 'Octopus.Client.dll'

    New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $Endpoint
}

<###########################################
    New-Endpoint
##########################################>
function New-Endpoint {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([Octopus.Client.OctopusServer.Endpoint])]
    param (
        [Parameter(Mandatory)]
        [ValidatePattern('^API-.*$')]
        [string]
        $ApiKey,

        [Parameter(Mandatory)]
        [ValidateScript({ [uri]::IsWellFormedUriString($_, 'Absolute') })]
        [string]
        $OctopusUri
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    Add-Type -Path 'Octopus.Client.dll'

    New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $OctopusUri, $ApiKey | Write-Output
}

<###########################################
    New-Repository
##########################################>
function New-Repository {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'UsingEndpoint')]
    [OutputType(Octopus.Client.OctopusRepository)]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingEndpoint')]
        [Octopus.Client.OctopusServerEndpoint]
        $Endpoint,

        [Parameter(Mandatory, ParameterSetName = 'UsingClient')]
        [Octopus.Client.OctopusClient]
        $Client,

        [Parameter(Mandatory, ParameterSetName = 'UsingClient')]
        $Space
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    Add-Type -Path 'Octopus.Client.dll'

    if ($PSCmdlet.ParameterSetName -eq 'UsingClient') {
        $Client.ForSpace($Space) | Write-Output
    }
    else {
        New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $Endpoint | Write-Output
    }
}

<###########################################
    New-Space
##########################################>
function New-Space {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([])]
    param (
        [Paramter(Mandatory)]
        [Octopus.Client.OctopusRepository]
        $Repository,

        [ValidateNotNullOrEmpty()]
        [string]
        $SpaceName = 'default'
    )

    Add-Type -Path 'Octopus.Client.dll'

    $Repository.Spaces.FindByName($SpaceName) | Write-Output
}

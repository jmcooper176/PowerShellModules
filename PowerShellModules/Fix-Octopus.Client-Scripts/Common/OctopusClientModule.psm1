#
# OctopusClientModule.psm1
#

<#
    Get-AccountByName
#>
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
        Set-StrictMode -Version 3.0
        Set-Variable -Name ScriptName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        Add-Type -Path 'Octopus.Client.dll'
    }
}

<#
    Get-Project
#>
function Get-Project {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Octopus.Client.OctopusRepository]
        $Repository,

        [ValidateNotNullOrEmpty()]
        [switchblock]
        $FilterScript,

        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [switch]
        $All
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name ScriptName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        Add-Type -Path 'Octopus.Client.dll'
    }

    PROCESS {
        if ($All.IsPresent) {
            $Repository.Projects.FindAll() | Write-Output
        }
        elseif ($PSBoundParameters.ContainsKey('FilterScript')) {
            $Repository.Projects.FindAll() | Where-Object -FilterScript $FilterScript | Write-Output
        }
        elseif ($PSBoundParameters.ContainsKey('Name')) {
            $Repository.Projects.FindAll() | Where-Object -Property Name -EQ $Name | Write-Output
        }
        else {
            return $null
        }
    }
}

<#
    New-Endpoint
#>
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

    Set-StrictMode -Version 3.0
    Set-Variable -Name ScriptName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    Add-Type -Path 'Octopus.Client.dll'
    New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $OctopusUri, $ApiKey | Write-Output
}

<#
    New-Repository
#>
function New-Repository {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Octopus.Client.OctopusServerEndpoint]
        $Endpoint
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name ScriptName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        Add-Type -Path 'Octopus.Client.dll'
    }

    PROCESS {
        New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $Endpoint | Write-Output
    }
}

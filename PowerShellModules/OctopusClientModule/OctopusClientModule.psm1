<#
 =============================================================================
<copyright file="OctopusClientModule.psm1" company="John Merryweather Cooper
">
    Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.
    All Rights Reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:

       1. Redistributions of source code must retain the above
          copyright notice, this list of conditions and the following
          disclaimer.

       2. Redistributions in binary form must reproduce the above
          copyright notice, this list of conditions and the following
          disclaimer in the documentation and/or other materials
          provided with the distribution.

       3. Neither the name of the copyright holder nor the names of
          its contributors may be used to endorse or promote products
          derived from this software without specific prior written
          permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
   FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
   COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
   INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
   BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
   CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
   LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
   ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE.
</copyright>
<author>John Merryweather Cooper</author>
<date>Created:  2025-2-19</date>
<summary>
This file "OctopusClientModule.psm1" is part of "PurgeNugetFeeds".
</summary>
<remarks>description</remarks>
=============================================================================
#>

#
# OctopusClientModule.psm1
#

<##########################################
    Add-AssemblyType
##########################################>
function Add-AssemblyType {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low', DefaultParameterSetName = 'UsingPath')]
    [OutputType([void])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Get-ChildItem -Path $_ | Test-Path -PathType Leaf },
            ErrorMessage = "Path '{0}' is not a valid path to an Assembly file")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "LiteralPath '{0}' is not a valid path to an Assembly file")]
        [string[]]
        $LiteralPath,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingAssemblyName')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $AssemblyName,

        [switch]
        $Force
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }
    }

    PROCESS {
        switch ($PSCmdlet.ParameterSetName) {
            'UsingAssemblyName' {
                $AssemblyName | ForEach-Object -Process {
                    if ($PSCmdlet.ShouldProcess($_, $CmdletName)) {
                        Add-Type -AssemblyName $_
                    }
                }

                break
            }

            'UsingLiteralPath' {
                $LiteralPath | ForEach-Object -Process {
                    if ($PSCmdlet.ShouldProcess($_, $CmdletName)) {
                        Add-Type -LiteralPath $_
                    }
                }

                break
            }

            default {
                Get-ChildItem -Path $Path | ForEach-Object -Process {
                    if ($PSCmdlet.ShouldProcess($_, $CmdletName)) {
                        Add-Type -LiteralPath $_.FullName
                    }
                }

                break
            }
        }
    }
}

<##########################################
    Approve-MandatoryMachineRole
##########################################>
function Approve-MandatoryMachineRole {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]
        $MandatoryRoles
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        Add-Type -AssemblyName 'Octopus.Client'
    }

    PROCESS {
        $RolesInMachineSplit = $OctopusParameters['Octopus.Machine.Roles'].Split(',')
        $MachineName = $($OctopusParameters['Octopus.Machine.Name'])

        $MissingRoles = @()

        $MandatoryRoles | ForEach-Object -Process {
            $mandatoryRole = $_

            If ($mandatoryRole -notin $RolesInMachineSplit) {
                $MissingRoles += $mandatoryRole
            }
        }

        If ($MissingRoles.Count -ne 0) {
            $newObjectSplat = @{
                TypeName     = 'System.Management.Automation.ErrorRecord'
                ArgumentList = @(
                    [System.Security.SecurityException]::new("$($CmdletName) : The following mandatory roles were not found in [$($MachineName)]:  '$($MissingRoles)'"),
                    'PermissionDenied',
                    "$(CmdletName)-SecurityException-$($MyInvocation.ScriptLineNumber)",
                    $MissingRoles
                )
            }

            $er = New-Object @newObjectSplat
            Write-Error -ErrorRecord $er -ErrorAction Continue
            throw $er
        }
    }
}

<##########################################
    Copy-OctopusAssemblyFile
##########################################>
function Copy-OctopusAssemblyFile {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low', DefaultParameterSetName = 'UsingPath')]
    [OutputType([void])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Get-ChildItem -Path $_ | Test-Path -IsValid },
            ErrorMessage = "Path '{0}' is not a valid path to Octopus Assembly file")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid },
            ErrorMessage = "LiteralPath '{0}' is not a valid path to Octopus Assembly file")]
        [string[]]
        $LiteralPath,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "Destination '{0}' is not a valid path container for Octopus Assembly file(s)")]
        [string]
        $Destination,

        [ValidateSet('', 'net4*', 'net45*', 'net46*', 'net47*', 'net48*', 'netstandard2.*', 'net6.*', 'net8.*', 'net9.*')]
        [AllowEmptyString()]
        [string]
        $Filter = 'net4*',

        [AllowEmptyString()]
        [string]
        $Include = '*.dll',

        [switch]
        $Force,

        [switch]
        $NoContainer,

        [switch]
        $Recurse
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            Get-ChildItem -Path $Path -Filter $Filter -Recurse |
                Get-ChildItem -Filter $Include -File -Recurse |
                ForEach-Object -Process {
                    if ($PSCmdlet.ShouldProcess($_.FullName, $CmdletName)) {
                        Copy-Item -Destination $Destination -Container:(-not $NoContainer.IsPresent) -Force:$Force.IsPresent -Recurse:$Recurse.IsPresent
                    }
                }
        }
        else {
            Get-ChildItem -Path $Path -Filter $Filter -Recurse |
                Get-ChildItem -Filter $Include -File -Recurse |
                ForEach-Object -Process {
                    if ($PSCmdlet.ShouldProcess($_.FullName, $CmdletName)) {
                        Copy-Item -Destination $Destination -Container:(-not $NoContainer.IsPresent) -Force:$Force.IsPresent -Recurse:$Recurse.IsPresent
                    }
                }
        }
    }
}

<##########################################
    Get-AzureRoleInstanceStatus
##########################################>
function Get-AzureRoleInstanceStatus {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('ServiceName')]
        [string]
        $Name, # '#{YourCloudService}

        [string]
        $Slot = 'Staging'
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        Get-AzureRole -ServiceName $Name -Slot $Slot -InstanceDetails | Select-Object -ExpandProperty InstanceStatus | Write-Output
    }
}

<##########################################
    Get-OctopusAssembly
##########################################>
function Get-OctopusAssembly {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]
        $Assembly, # @('Octopus.Client', 'Octostache', 'NuGet.Versioning')

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_.FullName -PathType Container },
            ErrorMessage = "OutputDirectory '{0}' is not a valid path container")]
        [string]
        $OutputDirectory,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_.FullName -PathType Leaf },
            ErrorMessage = "NugetPath '{0}' is not a valid path to the NuGet executable")]
        [string]
        $NugetPath,

        [ValidateScript({ [uri]::IsWellFormedUriString($_, 'Absolute') },
            ErrorMessage = "FeedUri '{0}' is not a valid, absolute URI path to a NuGet source repository")]
        [Alias('Source')]
        [string]
        $FeedUri = 'https://api.nuget.org/v3/index.json',

        [ValidateSet('net40', 'net45', 'net451', 'net452', 'net46', 'net461', 'net462', 'net47', 'net471', 'net472', 'net48', 'net481', 'net6.0', 'net8.0', 'net9.0')]
        [string]
        $Framework = 'net40'
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        Write-Information -MessageData "$($CmdletName) : Acquiring packages containing assemblies from feed '$($FeedUri)'" `
            -InformationAction Continue
        Write-Information -MessageData "  - Will use '$($NugetPath)'" -InformationAction Continue
        Write-Information -MessageData "  - Will extract to '$($OutputDirectory)'" -InformationAction Continue
        Write-Information -MessageData "  - Will select packages for '$($Framework)'" -InformationAction Continue

        if ($VerbosePreference -eq 'SilentlyContinue') {
            $verbosity = 'quiet'
        }
        elseif ($VerbosePreference -eq 'Continue') {
            $verbosity = 'detailed'
        }
        else {
            $verbosity = 'normal'
        }
    }

    PROCESS {
        $Assembly | ForEach-Object -Process {
            Write-Information -MessageData "Installing Assembly '$($_)'" -InformationAction Continue
            & $NugetPath install $_ -Source $FeedUri -OutputDirectory $OutputDirectory -ExcludeVersion -Framework $Framework -Verbosity $verbosity -NonInteractive
            $LASTEXITCODE | Write-Output
        }
    }
}

<##########################################
    Get-Project
##########################################>
function Get-Project {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Octopus.Client.OctopusRepository]
        $Repository,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('ProjectName')]
        [string]
        $Name,

        [switch]
        $All
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        Add-Type -AssemblyName 'Octopus.Client'
    }

    PROCESS {
        if ($All.IsPresent) {
            $Repository.Projects.FindAll() | Write-Output
        }
        else {
            $Repository.Projects.FindAll() | Where-Object -Property Name -EQ $Name | Write-Output
        }
    }
}

<##########################################
    Install-OctopusAssembly
##########################################>
function Install-OctopusAssembly {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    [OutputType([void], [bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "Source '{0}' is not a valid path container")]
        [Alias('OutputDirectory')]
        [string]
        $Source,

        [ValdiateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "Destination '{0}' is not a valid path container")]
        [string]
        $Destination,

        [switch]
        $CheckExistingOnly,

        [switch]
        $Force
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name -WhatIf:$false

        if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }

        if (-not $PSBoundParameters.ContainsKey('Destination')) {
            $Destination = Join-Path -Path $Source -ChildPath 'Octostache\lib\net40'
        }
    }

    PROCESS {
        if (-not $CheckExistingOnly.IsPresent) {
            # Validate Octopus Assemblies are present in OutputDirectory
            @(
                'Markdig\lib\net4*\Markdig.dll',
                'Newtonsoft.Json\lib\net40\Newtonsoft.Json.dll',
                'NuGet.Versioning\lib\netstandard2.0\NuGet.Versioning.dll',
                'Octopus.Client\lib\net462\Octopus.Client.dll',
                'Octostache\lib\net40\Octostache.dll',
                'Sprache\lib\net40\Sprache.dll'
            ) | ForEach-Object -Process {
                $path = Join-Path -Path $Source -ChildPath $_
                if (Test-Path -LiteralPath $path -PathType Leaf) {
                    $newObjectSplat = @{
                        TypeName     = 'System.Management.Automation.ErrorRecord'
                        ArgumentList = @(
                            [System.IO.FileNotFoundException]::("$($CmdletName) : Assembly File '$($path)' not found", $path),
                            'ObjectNotFound',
                            "$($CmdletName)-FileNotFoundException-$($MyInvocation.ScriptLineNumber)",
                            $path
                        )
                    }

                    $er = New-Object @newObjectSplat
                    Write-Error -ErrorRecord $er -ErrorAction Continue
                    throw $er
                }
            }

            # Copy Octopus Assemblies to Destination
            Push-Location -LiteralPath $Source
            @(
                'Markdig\lib\net4*\Markdig.dll',
                'Newtonsoft.Json\lib\net40\Newtonsoft.Json.dll',
                'NuGet.Versioning\lib\netstandard2.0\NuGet.Versioning.dll',
                'Octopus.Client\lib\net462\Octopus.Client.dll',
                'Sprache\lib\net40\Sprache.dll'
            ) | Copy-OctopusAssemblyFile -OutputDirectory $Source -Destination $Destination -Force -NoContainer

            'NuGet.Versioning\lib\netstandard2.0\NuGet.Versioning.dll' |
                Copy-OctopusAssemblyFile -OutputDirectory $OutputDirectory -Destination $Destination -Filter 'netstandard2.*' -Force -NoContainer
            Pop-Location

            # Add Assemblies Types to PowerShell
            Push-Location -LiteralPath $Destination
            @(
                'Newtonsoft.Json.dll',
                'Octopus.Client.dll',
                'Octostache.dll',
                'NuGet.Versioning.dll'
            ) | Add-AssemblyType
            Pop-Location
        }
        else {
            # Just checking Octopus Assemblies are present in Destination
            @(
                'Markdig.dll',
                'Newtonsoft.Json.dll',
                'NuGet.Versioning.dll',
                'Octopus.Client.dll',
                'Octostache.dll',
                'Sprache.dll'
            ) | ForEach-Object -Process {
                $path = Join-Path -Path $Destination -ChildPath $_
                Write-Verbose -Message "$($CmdletName) : Checking Assembly Path '$($path)' in Destination '$($Destination)'"
                (Test-Path -LiteralPath $path -PathType Leaf) | Write-Output
            }
        }
    }
}

<##########################################
    New-AzureServicePrincipal
##########################################>
function New-AzureServicePrincipal {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([Octopus.Client.Model.Accounts.AzureServicePrincipalAccountResource])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Octopus.Client.OctopusRepository]
        $Repository,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Octopus.Client.OctopusClient]
        $Client,

        [Parameter(Mandatory)]
        [ValidateCount(1, 2147483647)]
        [ValidateScript({ 'Name' -in $_.Keys },
            ErrorMessage = "Property '{0}' hashtable does not have 'Name' as a key")]
        [hastable]
        $Property,

        [ValidatePattern('(?<space>(space\-\d+))|(?<default>([DdEeFfAaUuLlTt]{7}))')]
        [string]
        $SpaceName = 'default',

        [switch]
        $Force
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name -WhatIf:$false

        Add-Type -AssemblyName 'Octopus.Client'
    }

    PROCESS {
        try {
            $space = $Repository.Spaces.FindByName($SpaceName)
            $repositoryForSpace = $Client.ForSpace($space)

            $azureAccount = New-Object -TypeName Octopus.Client.Model.Accounts.AzureServicePrincipalAccountResource

            if ($Property.ContainsKey('ClientId')) {
                $azureAccount.ClientId = $Property['ClientId']
            }

            if ($Property.ContainsKey('TenantId')) {
                $azureAccount.ClientId = $Property['TenantId']
            }

            if ($Property.ContainsKey('Description')) {
                $azureAccount.ClientId = $Property['Description']
            }

            if ($Property.ContainsKey('Name')) {
                $azureAccount.Name = $Property['Name']
            }

            if ($Property.ContainsKey('Password')) {
                $azureAccount.Password = $Property['Password']
            }

            if ($Property.ContainsKey('SubscriptionNumber')) {
                $azureAccount.SubscriptionNumber = $Property['SubscriptionNumber']
            }

            if ($Property.ContainsKey('TenantedDeploymentParticipation')) {
                $azureAccount.TenantedDeploymentParticipation = $Property['TenantedDeploymentParticipation']
            }

            if ($Property.ContainsKey('TenantTags')) {
                $azureAccount.TenantTags = $Property['TenantTags']
            }

            if ($Property.ContainsKey('TenantIds')) {
                $azureAccount.TenantIds = $Property['TenantIds']
            }

            if ($Property.ContainsKey('EnvironmentIds')) {
                $azureAccount.EnvironmentIds = $Property['EnvironmentIds']
            }

            if ($PSCmdlet.ShouldProcess($azureAccount.Name, $CmdletName)) {
                $repositoryForSpace.Accounts.Create($azureAccount) | Write-Output
            }
        }
        catch {
            $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
            throw $Error[0]
        }
    }
}

<##########################################
    New-Client
##########################################>
function New-Client {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([Octopus.Client.OctopusClient])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Octopus.Client.OctopusServerEndpoint]
        $Endpoint
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name -WhatIf:$false

        Add-Type -AssemblyName 'Octopus.Client'
    }

    PROCESS {
        if ($PSCmdlet.ShouldProcess($Endpoint, $CmdletName)) {
            New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $Endpoint | Write-Output
        }
    }
}

<##########################################
    New-Endpoint
##########################################>
function New-Endpoint {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([Octopus.Client.OctopusServerEndpoint])]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ [uri]::IsWellFormedUriString($_, 'Absolute') },
            ErrorMessage = "OctopusUri '{0}' is not a valid, absolute URI representing the Octopus Deploy Server URI")]
        [Alias('Uri')]
        [string]
        $OctopusUri,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('ApiKey')]
        [string]
        $OctopusApiKey
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name -WhatIf:$false

    Add-Type -AssemblyName 'Octopus.Client'

    if ($PSCmdlet.ShouldProcess($OctopusUri, $CmdletName)) {
        New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $OctopusUrl, $OctopusApiKey | Write-Output
    }
}

<##########################################
    New-Repository
##########################################>
function New-Repository {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([Octopus.Client.OctopusRepository])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Octopus.Client.OctopusServerEndpoint]
        $Endpoint
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name -WhatIf:$false

        Add-Type -AssemblyName 'Octopus.Client'
    }

    PROCESS {
        if ($PSCmdlet.ShouldProcess($Endpoint, $CmdletName)) {
            New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $Endpoint | Write-Output
        }
    }
}

<##########################################
    Test-OctopusAssemblyFile
##########################################>
function Test-OctopusAssemblyFile {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf },
            ErrorMessage = "AssemblyFile '{0}' is not a valid path to an Assembly file")]
        [SupportsWildcards()]
        [string[]]
        $AssemblyFile,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "Destination '{0}' is not a valid path container")]
        [string]
        $Destination
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $AssemblyFile | Get-Item {
            $assemblyShortName = $_.Name
            $assemblyShortNamePath = Join-Path -Path $Destination -ChildPath $assemblyShortName

            (Test-Path -LiteralPath $assemblyShortNamePath -PathType Leaf) | Write-Output
        }
    }
}

<##########################################
    Test-OctopusAssemblyFolder
##########################################>
function Test-OctopusAssemblyFolder {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "AssemblyDirectory '{0}' is not a valid path container absolute URI")]
        [string[]]
        $AssemblyDirectory,

        [ValidateSet('net4*', 'net6*', 'net8*', 'net9*', 'netstandard2.*')]
        [string[]]
        $Filter = 'net4*'
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $AssemblyDirectory | Get-ChildItem -LiteralPath $_ -Filter $Filter -Directory | Sort-Object -Property Name -Descending -Unique {
            $packageIdPath = $_.FullName

            (Test-Path -LiteralPath $packageIdPath -PathType Container) | Write-Output
        }
    }
}

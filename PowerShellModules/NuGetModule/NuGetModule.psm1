<#
 =============================================================================
<copyright file="NuGetModule.psm1" company="John Merryweather Cooper
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
This file "NuGetModule.psm1" is part of "PurgeNugetFeeds".
</summary>
<remarks>description</remarks>
=============================================================================
#>

using module .\CommandLineBuilderClass.psm1

#
# NuGetModule.psm1
#

<###########################################
    Add-NuGetConfigSource
##########################################>
function Add-NuGetConfigSource {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    [OutputType([int])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('SourceName')]
        [string]
        $Name,

        [Parameter(Mandatory)]
        [ValidateScript({ [uri]::IsWellFormedUriString($_, 'Absolute') },
            ErrorMessage = "Source '{0}' is not a valid, absolute URI to a NuGet source repository")]
        [Alias('FeedUri')]
        [string]
        $Source,

        [ValidateRange(2, 3)]
        [int]
        $ProtocolVersion = 3,

        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "ConfigFile '{0}' is not a valid path to a NuGet configuration file")]
        [Alias('NugetConfigPath')]
        [string]
        $ConfigFile,

        [Alias('UseInvariant')]
        [switch]
        $ForceEnglishOutput,

        [switch]
        $Force,

        [switch]
        $UseNuGet
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name -WhatIf:$false

    if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
        $ConfirmPreference = 'None'
    }

    if ($PSBoundParameters.ContainsKey('Verbose') -or ($VerbosePreference -eq 'Continue')) {
        $verbosity = 'detailed'
    }
    elseif ($VerbosityPreference -eq 'SilentlyContinue') {
        $verbosity = 'quiet'
    }
    else {
        $verbosity = 'normal'
    }

    $commandLine = [CommandLineBuilder]::new()

    if ($UseNuGet.IsPresent) {
        $commandLine.AppendArgument('sources', 'Add')
        $commandLine.AppendSwitch('-Name ', $Source)
        $commandLine.AppendSwitch('-ProtocolVersion ', $ProcolVersion)
        $commandLine.AppendSwitchIf($PSBoundParameters.ContainsKey('ConfigFile'), '-ConfigFile')
        $commandLine.AppendFileNameIfNotNull($ConfigFIle)
        $commandLine.AppendSwitch('-Verbosity ', $verbosity)
        $commandLine.AppendSwitch('-NonInteractive')
        $commandLine.AppendSwitchIf($ForceEnglishOutput, '-ForceEnglishOutput')

        Invoke-Tool -Name 'nuget' -Argument $commandLine.ToString() -Force:$Force.IsPresent -WhatIf:$false | Write-Output
    }
    else {
        $commandLine.AppendArgument('nuget', 'add', 'source')
        $commandLine.AppendSwitch('--name ', $Name)
        $commandLine.AppendArgument($Source)
        $commandLine.AppendSwitch('--protocol-version ', $ProtocolVersion)
        $commandLine.AppendSwitchIf($PSBoundParameters.ContainsKey('ConfigFile'), '--configfile')
        $commandLine.AppendFileNameIfNotNull($ConfigFIle)

        Invoke-Tool -Name 'dotnet' -Argument $commandLine.ToString() -Version 8.0.0 -Force:$Force.IsPresent -WhatIf:$false | Write-Output
    }

    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER Name
        .PARAMETER Source
        .PARAMETER ProtocolVersion
        .PARAMETER ForceEnglishOutput
        .PARAMETER Force
        .PARAMETER UseNuGet
        .INPUTS
        None.  `Add-NugetConfigSource` does not accept input from the PowerShell pipeline.

        .OUTPUTS
        [int]  `Add-NuGetConfigSource` returns the nuget return code store in 'LASTEXITCODE' to the PowerShell pipeline.

        .EXAMPLE
        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINKS
        about_CommonParameters
        .LINKS
        about_Function_Advanced

        .LINKS
        Invoke-Tool

        .LINKS
        Out-Null

        .LINKS
        Set-StrictMode

        .LINKS
        Set-Variable

        .LINKS
        Test-Path

        .LINKS
        Write-Output
    #>
}

<###########################################
    Disable-NuGetConfigSource
##########################################>
function Disable-NuGetConfigSource {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    [OutputType([int])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('SourceName')]
        [string]
        $Name,

        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "ConfigFile '{0}' is not a valid path to a NuGet configuration file")]
        [Alias('NugetConfigPath')]
        [string]
        $ConfigFile,

        [Alias('UseInvariant')]
        [switch]
        $ForceEnglishOutput,

        [switch]
        $Force,

        [switch]
        $UseNuGet
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name -WhatIf:$false

    if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
        $ConfirmPreference = 'None'
    }

    if ($PSBoundParameters.ContainsKey('Verbose') -or ($VerbosePreference -eq 'Continue')) {
        $verbosity = 'detailed'
    }
    elseif ($VerbosityPreference -eq 'SilentlyContinue') {
        $verbosity = 'quiet'
    }
    else {
        $verbosity = 'normal'
    }

    $commandLine = [CommandLineBuilder]::new()

    if ($UseNuGet.IsPresent) {
        $commandLine.AppendArgument('sources', 'Disable')
        $commandLine.AppendSwitch('-Name ', $Name)
        $commandLine.AppendSwitchIf($PSBoundParameters.ContainsKey('ConfigFile'), '-ConfigFile')
        $commandLine.AppendFileNameIfNotNull($ConfigFile)
        $commandLine.AppendSwitch('-Verbosity ', $verbosity)
        $commandLine.AppendSwitch('-NonInteractive')
        $commandLine.AppendSwitchIf($ForceEnglishOutput.IsPresent, '-ForceEnglishOutput')

        Invoke-Tool -Name 'nuget' -Argument $commandLine.ToString() -Force:$Force.IsPresent -WhatIf:$false | Write-Output
    }
    else {
        $commandLine.AppendArgument('nuget', 'disable', 'source')
        $commandLine.AppendSwitch('--name ', $Name)
        $commandLine.AppendSwitchIf($PSBoundParameters.ContainsKey('ConfigFile'), '--configfile')
        $commandLine.AppendFileNameIfNotNull($ConfigFile)

        Invoke-Tool -Name 'dotnet' -Version 8.0.0 -Argument $commandLine.ToString() -Force:$Force.IsPresent -WhatIf:$false | Write-Output
    }

    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER Name
        .PARAMETER ConfigFile
        .PARAMETER ForceEnglishOutput
        .PARAMETER Force
        .INPUTS
        None.  `Disable-NugetConfigSource` does not accept input from the PowerShell pipeline.

        .OUTPUTS
        [int]  `Disable-NuGetConfigSource` returns the nuget return code store in 'LASTEXITCODE' to the PowerShell pipeline.
        .EXAMPLE
        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.
        .LINKS
        about_CommonParameters
        .LINKS
        about_Function_Advanced

        .LINKS
        Invoke-Tool

        .LINKS
        Out-Null

        .LINKS
        Set-StrictMode

        .LINKS
        Set-Variable

        .LINKS
        Test-Path

        .LINKS
        Write-Output
    #>
}

<###########################################
    Enable-NuGetConfigSource
##########################################>
function Enable-NuGetConfigSource {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    [OutputType([int])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('SourceName')]
        [string]
        $Name,

        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "ConfigFile '{0}' is not a valid path to a NuGet configuration file")]
        [Alias('NugetConfigPath')]
        [string]
        $ConfigFile,

        [Alias('UseInvariant')]
        [switch]
        $ForceEnglishOutput,

        [switch]
        $Force,

        [switch]
        $UseNuGet
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name -WhatIf:$false

    if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
        $ConfirmPreference = 'None'
    }

    if ($PSBoundParameters.ContainsKey('Verbose') -or ($VerbosePreference -eq 'Continue')) {
        $verbosity = 'detailed'
    }
    elseif ($VerbosityPreference -eq 'SilentlyContinue') {
        $verbosity = 'quiet'
    }
    else {
        $verbosity = 'normal'
    }

    $commandLine = [CommandLineBuilder]::new()

    if ($UseNuGet.IsPresent) {
        $commandLine.AppendArgument('sources', 'Enable')
        $commandLine.AppendSwitch('-Name ', $Name)
        $commandLine.AppendSwitchIf($PSBoundParameters.ContainsKey('ConfigFile'), '-ConfigFile')
        $commandLine.AppendFileNameIfNotNull($ConfigFile)
        $commandLine.AppendSwitch('-Verbosity ', $verbosity)
        $commandLine.AppendSwitch('-NonInteractive')
        $commandLine.AppendSwitchIf($ForceEnglishOutput.IsPresent, '-ForceEnglishOutput')

        Invoke-Tool -Name 'nuget' -Argument $commandLine.ToString() -Force:$Force.IsPresent -WhatIf:$false | Write-Output
    }
    else {
        $commandLine.AppendArgument('nuget', 'enable', 'source')
        $commandLine.AppendSwitch('--name ', $Name)
        $commandLine.AppendSwitchIf($PSBoundParameters.ContainsKey('ConfigFile'), '--configfile')
        $commandLine.AppendFileNameIfNotNull($ConfigFile)

        Invoke-Tool -Name 'dotnet' -Version 8.0.0 -Argument $commandLine.ToString() -Force:$Force.IsPresent -WhatIf:$false | Write-Output
    }

    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER Name
        .PARAMETER ConfigFile
        .PARAMETER ForceEnglishOutput
        .PARAMETER Force
        .INPUTS
        None.  `Enable-NugetConfigSource` does not accept input from the PowerShell pipeline.

        .OUTPUTS
        [int]  `Enable-NuGetConfigSource` returns the nuget return code store in 'LASTEXITCODE' to the PowerShell pipeline.

        .EXAMPLE
        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.
        .LINKS
        about_CommonParameters
        .LINKS
        about_Function_Advanced

        .LINKS
        Invoke-Tool

        .LINKS
        Out-Null

        .LINKS
        Set-StrictMode

        .LINKS
        Set-Variable

        .LINKS
        Write-Output
    #>
}

<###########################################
    Find-Package
##########################################>
function Find-Package {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('PackageId', 'Id', 'Tag', 'Description')]
        [string[]]
        $Term,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ [uri]::IsWellFormedUriString($_, 'Absolute') },
            ErrorMessage = "Source '{0}' is not a valid, absolute URI to a NuGet source repository")]
        [Alias('FeedUri')]
        [string[]]
        $Source,

        [switch]
        $Prerelease,

        [ValidateRange(1, 2147483647)]
        [int]
        $Take = 20,

        [Alias('UseInvariant')]
        [switch]
        $ForceEnglishOutput
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        if ($PSBoundParameters.ContainsKey('Verbose') -or ($VerbosePreference -eq 'Continue')) {
            $verbosity = 'detailed'
        }
        elseif ($VerbosityPreference -eq 'SilentlyContinue') {
            $verbosity = 'quiet'
        }
        else {
            $verbosity = 'normal'
        }

        $commandLine = [CommandLineBuilder]::new()
    }

    PROCESS {
        $commandLine.Clear()
        $commandLine.AppendArgument('search')
        $commandLine.AppendArgument($Term)

        if ($PSBoundParameters.ContainsKey('Source')) {
            $Source | ForEach-Object -Process {
                $commandLine.AppendSwitch('-Source ', $_)
            }
        }

        $commandLine.AppendSwitchIf($Prerelease.IsPresent, '-Prerelease')
        $commandLine.AppendSwitchIf($PSBoundParameters.ContainsKey('Take') -and ($Take -ne 20), '-Take ', $Take)
        $commandLine.AppendSwitch('-Verbosity ', $verbosity)
        $commandLine.AppendSwitch('-NonInteractive')
        $commandLine.AppendSwitchIf($ForceEnglishOutput.IsPresent, '-ForceEnglishOutput')

        Invoke-Tool -Name 'nuget' -Argument $commandLine.ToString() -StdOut -WhatIf:$false | Write-Output
    }

<#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER Term
        .PARAMETER Source
        .PARAMETER Prerelease
        .PARAMETER Take
        .INPUTS
        [string[]]  `Find-Package accepts one or more 'Source' URI strings from the PowerShell pipeline.

        .OUTPUTS
        [string]  `Find-Package` returns zero or more NuGet PackageIds one-by-one to the PowerShell pipeline.

        .EXAMPLE
        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.
        .LINKS
        about_CommonParameters
        .LINKS
        about_Function_Advanced

        .LINKS
        Invoke-Tool

        .LINKS
        Out-Null

        .LINKS
        Set-StrictMode

        .LINKS
        Set-Variable

        .LINKS
        Write-Output
    #>
}

<###########################################
    Get-NuGetConfigSource
##########################################>
function Get-NuGetConfigSource {
    [CmdletBinding(DefaultParameterSetName = 'UsingName')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingName')]
        [ValidateNotNullOrEmpty()]
        [Alias('SourceName')]
        [string]
        $Name,

        [Parameter(Mandatory, ParameterSetName = 'UsingSource')]
        [ValidateScript({ [uri]::IsWellFormedUriString($_, 'Absolute') },
            ErrorMessage = "Source '{0}' is not a valid, absolute URI to a NuGet source repository")]
        [Alias('FeedUri')]
        [string]
        $Source,

        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "ConfigPath '{0}' is not a valid path to a NuGet configuration file")]
        [Alias('NugetConfigPath')]
        [string]
        $ConfigFile,

        [Alias('UseInvariant')]
        [switch]
        $ForceEnglishOutput,

        [switch]
        $UseNuGet
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name -WhatIf:$false

    if ($PSBoundParameters.ContainsKey('Verbose') -or ($VerbosePreference -eq 'Continue')) {
        $verbosity = 'detailed'
    }
    elseif ($VerbosityPreference -eq 'SilentlyContinue') {
        $verbosity = 'quiet'
    }
    else {
        $verbosity = 'normal'
    }

    $commandLine = [CommandLineBuilder]::new()

    if ($UseNuGet.IsPresent) {
        $commandLine.AppendArgument('sources', 'List')
        $commandLine.AppendSwitchIf($PSBoundParameters.ContainsKey('Name'), '-Name ', $Name)
        $commandLine.AppendSwitchIf($PSBoundParameters.ContainsKey('Source'), '-Source ', $Source)
        $commandLine.AppendSwitchIf($PSBoundParameters.ContainsKey('ConfigFile'), '-ConfigFile')
        $commandLine.AppendFileNameIfNotNull($ConfigFile)
        $commandLine.AppendSwitch('-Verbosity ', $verbosity)
        $commandLine.AppendSwitch('-NonInteractive')
        $commandLine.AppendSwitchIf($ForceEnglishOutput.IsPresent, '-ForceEnglishOutput')

        Invoke-Tool -Name 'nuget' -Argument $commandLine.ToString() -StdOut -WhatIf:$false | Write-Output
    }
    else {
        $commandLine.AppendArgument('nuget', 'list', 'source')
        $commandLine.AppendSwitchIf($verbosity -eq 'quite', '--format ', 'Short')
        $commandLine.AppendSwitchIf($PSBoundParameters.ContainsKey('ConfigFile'), '-ConfigFile')
        $commandLine.AppendFileNameIfNotNull($ConfigFile)

        Invoke-Tool -Name 'dotnet' -Version 8.0.0  -Argument $commandLine.ToString() -StdOut -WhatIf:$false | Write-Output
    }

    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER Name
        .PARAMETER Source
        .PARAMETER ConfigFile
        .PARAMETER Take
        .INPUTS
        None.  `Get-NugetConfigSource` does not accept input from the PowerShell pipeline.

        .OUTPUTS
        [string]  `Get-NuGetConfigSource` returns the either Name associated with a Source, or a Source associated by a Name to the PowerShell pipeline.
        .EXAMPLE
        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.
        .LINKS
        about_CommonParameters
        .LINKS
        about_Function_Advanced

        .LINKS
        Invoke-Tool

        .LINKS
        Set-StrictMode

        .LINKS
        Set-Variable

        .LINKS
        Test-Path
    #>
}

<###########################################
    Get-Package
##########################################>
function Get-Package {
    [CmdletBinding()]
    [OutputType([string], [string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ [uri]::IsWellFormedUriString($_, 'Absolute') },
            ErrorMessage = "Source '{0}' is not a valid, absolute URI to a NuGet source repository")]
        [Alias('FeedUri')]
        [string[]]
        $Source,

        [switch]
        $AllVersions,

        [switch]
        $Prerelease,

        [switch]
        $IncludeDelisted,

        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "ConfigFile '{0}' is not a valid path to a NuGet configuration file")]
        [Alias('NugetConfigPath')]
        [string]
        $ConfigFile,

        [Alias('UseInvariant')]
        [switch]
        $ForceEnglishOutput
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation

        if ($PSBoundParameters.ContainsKey('Verbose') -or ($VerbosePreference -eq 'Continue')) {
            $verbosity = 'detailed'
        }
        elseif ($VerbosityPreference -eq 'SilentlyContinue') {
            $verbosity = 'quiet'
        }
        else {
            $verbosity = 'normal'
        }

        $commandLine = [CommandLineBuilder]::new()
    }

    PROCESS {
        $commandLine.Clear()
        $commandLine.AppendArgument('list')

        $Source | ForEach-Object -Process {
            $commandLine.AppendSwitch('-Source', $_)
        }

        $commandLine.AppendSwitchIf($PSBoundParameters.ContainsKey('Verbose'), '-Verbose')
        $commandLine.AppendSwitchIf($AllVersions.IsPresent, '-AllVersions')
        $commandLine.AppendSwitchIf($Prerelease.IsPresent, '-Prerelease')
        $commandLine.AppendSwitchIf($IncludeDelisted.IsPresent, '-IncludeDelisted')
        $commandLine.AppendSwitch('-Verbosity ', $verbosity)
        $commandLine.AppendSwitch('-NonInteractive')
        $commandLine.AppendSwitchIf($ForceEnglishOutput.IsPresent, '-ForceEnglishOutput')

        Invoke-Tool -Name 'nuget' -ArgumentList $argumentList.ToArray() -StdOut -WhatIf:$false | Write-Output
    }

    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER Source
        .PARAMETER AllVersions
        .PARAMETER Prerelease
        .PARAMETER IncludeDelisted
        .PARAMETER ConfigFile
        .INPUTS
        [string[]]  `Get-Package accepts one or more 'Source' URI strings from the PowerShell pipeline.

        .OUTPUTS
        [string]  `Get-Package` returns zero or more NuGet PackageIds one-by-one to the PowerShell pipeline.

        [string[]]  If 'AllVersions' is passed, `Get-Package` returns one or more NuGet PackageIds to the PowerShell pipeline.

        .EXAMPLE
        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.
        .LINKS
        about_CommonParameters
        .LINKS
        about_Function_Advanced

        .LINKS
        Invoke-Tool

        .LINKS
        Out-Null

        .LINKS
        Test-Path
    #>
}

<###########################################
    Install-NuGet
##########################################>
function Install-NuGet {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    [OutputType([void], [Microsoft.PowerShell.Commands.BasicHtmlWebResponseObject])]
    param (
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "OutputDirectory '{0}' is not a valid path container")]
        [Alias('RepositoryPath', 'PackagesDirectory')]
        [string]
        $OutputDirectory,

        [ValidateScript({ [uri]::IsWellFormedUriString($_, 'Absolute') },
            ErrorMessage = "Source '{0}' is not a valid, absolute URI to a NuGet source repository")]
        [Alias('FeedUri')]
        [string]
        $Source = 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe',

        [switch]
        $DisableKeepAlive,

        [ValidateRange(1, 255)]
        [int]
        $MaximumRetryCount = 3,

        [switch]
        $Force,

        [switch]
        $PassThru,

        [switch]
        $Resume,

        [ValidateRange(1, 2147483647)]
        [int]
        $RetryIntervalSec = 30
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name -WhatIf:$false

    if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
        $ConfirmPreference = 'None'
    }

    if ([Environment]::OSVersion.Platform -eq 'Unix') {
        # per Microsoft
        if (-not $PSBoundParameters.ContainsKey('OutputDirectory')) {
            $OutputDirectory = '/usr/local/bin'
        }

        # assumes Ubuntu
        & sudo apt-get install mono-complete
        Write-Warning -Message (@("$($CmdletName):  Execution, assuming 'nuget.exe' is in the PATH, is with 'mono nuget.exe'.",
                "GitHub runners under Ubuntu wrap this in a script so it is transparent to you") -join [Environment]::NewLine)
    }
    elseif ([Environment]::OSVersion.Platform -eq 'Win32NT') {
        if (-not $PSBoundParameters.ContainsKey('OutputDirectory')) {
            $OutputDirectory = $PWD
        }
    }
    else {
        $newObjectSplat = @{
            TypeName     = 'System.Management.Automation.ErrorRecord'
            ArgumentList = @(
                [System.NotSupportedException]::new("$($CmdletName) : '$([Environment]::OSVersion.Platform)' is not supported"),
                'NotSupported',
                "$($CmdletName)-NotSupportedException-$($MyInvocation.ScriptLineNumber)",
                [Environment]::OSVersion.Platform
            )
        }

        $er = New-Object @newObjectSlat
        Write-Error -ErrorRecord $er -ErrorAction Continue
        throw $er
    }

    $pathArray = ($env:PATH -split [System.IO.Path]::PathSeparator)

    if ($OutputDirectory -notin $pathArray) {
        Write-Warning -Message "$($CmdletName):  '$($OutputDirectory)' is not in PATH, failures may occur"
    }

    $invokeWebRequestSplat = @{
        Uri               = $Source
        OutFile           = (Join-Path -Path $OutputDirectory -ChildPath 'nuget.exe')
        UseBasicParsing   = $true
        DisableKeepAlive  = $DisableKeepAlive.IsPresent
        MaximumRetryCount = $MaximumRetryCount
        Force             = $Force.IsPresent
        PassThru          = $PassThru.IsPresent
        Resume            = $Resume.IsPresent
        RetryIntervalSec  = $RetryIntervalSec
    }

    if ($PSCmdlet.ShouldProcess($invokeWebRequestSplat['OutFile'], $CmdletName)) {
        if ($PassThru.IsPresent) {
            Invoke-WebRequest @invokeWebRequestSplat | Write-Output
        }
        else {
            Invoke-WebRequest @invokeWebRequestSplat
        }
    }

    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER OutputDirectory
        .PARAMETER Source
        .PARAMETER DisableKeepAlive
        .PARAMETER MaximumRetryCount
        .PARAMETER Force
        .PARAMETER Resume
        .PARAMETER RetryIntervalSec
        .INPUTS
        None.  `Install-Nuget` does not accept input from the PowerShell pipeline.

        .OUTPUTS
        None.  `Install-NuGet` does not return any output to the Powershell pipeline.

        .EXAMPLE
        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.
        .LINKS
        about_CommonParameters

        .LINKS
        about_Function_Advanced

        .LINKS
        Invoke-WebRequest

        .LINKS
        New-Object

        .LINKS
        Write-Error

        .LINKS
        Write-Warning
    #>
}

<###########################################
    Install-Package
##########################################>
function Install-Package {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low', DefaultParameterSetName = 'UsingPackageId')]
    [OutputType([int])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPackageId')]
        [ValidateNotNullOrEmpty()]
        [Alias('PackageId', 'Id')]
        [string[]]
        $Name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPathToPackagesConfig')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "Config '{0}' is not a valid path to a NuGet packages.config file")]
        [Alias('PathToPackagesConfig', 'PackagesConfigPath')]
        [string[]]
        $Config,

        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "OutputDirectory '{0}' is not a valid path container")]
        [Alias('RepositoryPath', 'PackagesDirectory')]
        [string]
        $OutputDirectory,

        [version]
        $Version,

        [ValidateSet('Lowest', 'HighestPatch', 'HighestMinor', 'Highest', 'Ignore')]
        [string]
        $DependencyVersion = 'Lowest',

        [ValidateSet(
            'Any', 'net40',
            'net45', 'net451', 'net452',
            'net46', 'net461', 'net462',
            'net47', 'net471', 'net472',
            'net48', 'net481',
            'net6.0', 'net6.0-windows',
            'net8.0', 'net8.0-windows',
            'net9.0', 'net9.0-windows')]
        [string]
        $Framework = 'Any',

        [switch]
        $ExcludeVersion,

        [switch]
        $Prerelease,

        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "SolutionDirectori '{0}' is not a valid path container containing a Visual Studio SLN file")]
        [string]
        $SolutionDirectory,

        [ValidateScript({ [uri]::IsWellFormedUriString($_, 'Absolute') },
            ErrorMessage = "Source '{0}' is not a valid, absolute URI to a NuGet source repository")]
        [Alias('FeedUri')]
        [string[]]
        $Source,

        [ValidateScript({ [uri]::IsWellFormedUriString($_, 'Absolute') },
            ErrorMessage = "FallbackSource '{0}' is not a valid, absolute URI to a NuGet fallback source repository")]
        [Alias('FallbackFeedUri')]
        [string[]]
        $FallbackSource,

        [switch]
        $NoHttpCache,

        [switch]
        $DirectDownload,

        [switch]
        $DisableParallelProcessing,

        [ValidateSet('nuspec', 'nupkg', 'nuspec;nupkg')]
        [string]
        $PackageSaveMode = 'nuspec;nupkg',

        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "ConfigFile '{0}' is not a valid path to a NuGet configuration file")]
        [Alias('NugetConfigPath')]
        [string]
        $ConfigFile,

        [Alias('UseInvariant')]
        [switch]
        $ForceEnglishOutput,

        [switch]
        $Force
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation -WhatIf:$false

        if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }

        if ($PSBoundParameters.ContainsKey('Verbose') -or ($VerbosePreference -eq 'Continue')) {
            $verbosity = 'detailed'
        }
        elseif ($VerbosityPreference -eq 'SilentlyContinue') {
            $verbosity = 'quiet'
        }
        else {
            $verbosity = 'normal'
        }

        $argumentList = [System.Collections.ArrayList]::new()
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName = 'UsingPathToPackagesConfig') {
            $Config | ForEach-Object -Process {
                $argumentList.Clear() | Out-Null
                $argumentList.Add(('install "{0)"' -f $_)) | Out-Null

                if ($PSBoundParameters.ContainsKey('OutputDirectory')) {
                    $argumentList.Add(('-OutputDirectory "{0}"' -f $OutputDirectory)) | Out-Null
                }

                if ($PSBoundParameters.ContainsKey('Source')) {
                    $Source | ForEach-Object -Process {
                        $argumentList.Add('-Source "{0}"' -f $_) | Out-Null
                    }
                }

                if ($PSBoundParameters.ContainsKey('FallbackSource')) {
                    $FallbackSource | ForEach-Object -Process {
                        $argumentList.Add('-FallbackSource "{0}"' -f $_) | Out-Null
                    }
                }

                if ($NoHttpCache.IsPresent) {
                    $argumentList.Add('-NoHttpCache') | Out-Null
                }

                if ($DirectDownload.IsPresent) {
                    $argumentList.Add('-DirectDownload') | Out-Null
                }

                if ($DisableParallelProcessing.IsPresent) {
                    $argumentList.Add('-DisableParallelProcessing') | Out-Null
                }

                if ($PSBoundParameters.ContainsKey('PackageSaveMode') -and ($PackageSaveMode -ne 'nuspec;nupkg')) {
                    $argumentList.Add(('-PackageSaveMode {0}' -f $PackageSaveMode))
                }

                $argumentList.Add(('-Verbosity {0}' -f $verbosity)) | Out-Null
                $argumentList.Add('-NonInteractive') | Out-Null

                if ($PSBoundParameters.ContainsKey('ConfigFile')) {
                    $argumentList.Add('-ConfigFile "{0}"' -f $ConfigFile) | Out-Null
                }

                if ($ForceEnglishOutput.IsPresent) {
                    $argumentList.Add('-ForceEnglishOutput')
                }

                Invoke-Tool -Name 'nuget' -ArgumentList $argumentList.ToArray() -Force:$Force.IsPresent | Write-Output
            }
        }
        else {
            $Name | ForEach-Object -Process {
                $argumentList.Clear() | Out-Null
                $argumentList.Add(('install "{0)"' -f $_)) | Out-Null

                if ($PSBoundParameters.ContainsKey('OutputDirectory')) {
                    $argumentList.Add(('-OutputDirectory "{0}"' -f $OutputDirectory)) | Out-Null
                }

                if ($PSBoundParameters.ContainsKey('Version')) {
                    $argumentList.Add(('-Version {0}' -f $Version)) | Out-Null
                }

                if ($PSBoundParameters.ContainsKey('DependencyVersion') -and ($DependencyVersion -ne 'Lowest')) {
                    $argumentList.Add(('-DependencyVersion {0}' -f $DependencyVersion)) | Out-Null
                }

                if ($PSBoundParameters.ContainsKey('Framework') -and ($Framework -ne 'Any')) {
                    $argumentList.Add(('-Framework {0}' -f $Framework)) | Out-Null
                }

                if ($Prerelease.IsPresent) {
                    $argumentList.Add('-Prerelease') | Out-Null
                }

                if ($PSBoundParameters.ContainsKey('SolutionDirectory')) {
                    $argumentList.Add('-SolutionDirectory "{0}"' -f $SolutionDirectory) | Out-Null
                }

                if ($PSBoundParameters.ContainsKey('Source')) {
                    $Source | ForEach-Object -Process {
                        $argumentList.Add('-Source "{0}"' -f $_) | Out-Null
                    }
                }

                if ($PSBoundParameters.ContainsKey('FallbackSource')) {
                    $FallbackSource | ForEach-Object -Process {
                        $argumentList.Add('-FallbackSource "{0}"' -f $_) | Out-Null
                    }
                }

                if ($NoHttpCache.IsPresent) {
                    $argumentList.Add('-NoHttpCache') | Out-Null
                }

                if ($DirectDownload.IsPresent) {
                    $argumentList.Add('-DirectDownload') | Out-Null
                }

                if ($DisableParallelProcessing.IsPresent) {
                    $argumentList.Add('-DisableParallelProcessing') | Out-Null
                }

                if ($PSBoundParameters.ContainsKey('PackageSaveMode') -and ($PackageSaveMode -ne 'nuspec;nupkg')) {
                    $argumentList.Add(('-PackageSaveMode {0}' -f $PackageSaveMode)) | Out-Null
                }

                $argumentList.Add(('-Verbosity {0}' -f $verbosity)) | Out-Null
                $argumentList.Add('-NonInteractive') | Out-Null

                if ($PSBoundParameters.ContainsKey('ConfigFile')) {
                    $argumentList.Add('-ConfigFile "{0}"' -f $ConfigFile) | Out-Null
                }

                if ($ForceEnglishOutput.IsPresent) {
                    $argumentList.Add('-ForceEnglishOutput') | Out-Null
                }

                Invoke-Tool -Name 'nuget' -ArgumentList $argumentList.ToArray() -Force:$Force.IsPresent | Write-Output
            }
        }
    }

    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER Name
        .PARAMETER Config
        .PARAMETER OutputDirectory
        .PARAMETER Version
        .PARAMETER DependencyVersion
        .PARAMETER Framework
        .PARAMETER ExcludeVersion
        .PARAMETER Prerelease
        .PARAMETER SolutionDirectory
        .PARAMETER Source
        .PARAMETER FallbackSource
        .PARAMETER NoHttpCache
        .PARAMETER DirectDownload
        .PARAMETER DisableParallelProcessing
        .PARAMETER PackageSaveMode
        .PARAMETER ConfigFile
        .PARAMETER ForceEnglishOutput
        .PARAMETER Force
        .INPUTS
        [string[]]  `Install-Package` accepts one or more package 'Name's from the PowerShell pipeline.

        [string[]]  `Install-Package` accepts one or more literal packages.config file paths from the PowerShell pipeline.

        .OUTPUTS
        [int]  `Install-Package` returns the nuget return code store in 'LASTEXITCODE' to the PowerShell pipeline.

        .EXAMPLE

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINKS
        about_CommonParameters

        .LINKS
        about_Function_Advanced

        .LINKS
        ForEach-Object

        .LINKS
        Invoke-Tool

        .LINKS
        Out-Null

        .LINKS
        Set-StrictMode

        .LINKS
        Set-Variable

        .LINKS
        Write-Output
    #>
}

<###########################################
    Push-Package
##########################################>
function Push-Package {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low', DefaultParameterSetName = 'UsingPath')]
    [OutputType([int])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Get-ChildItem -Path $_ -File | Test-Path -PathType Leaf },
            ErrorMessage = "Path '{0}' is not a valid path to a NuGet NUPKG package file")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Get-ChildItem -Path $_ -File | Test-Path -PathType Leaf },
            ErrorMessage = "LiteralPath '{0}' is not a valid path to a NuGet NUPKG package file")]
        [string[]]
        $LiteralPath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ApiKey,

        [ValidateScript({ [uri]::IsWellFormedUriString($_, 'Absolute') },
            ErrorMessage = "Source '{0}' is not a valid, absolute URI to a NuGet source repository")]
        [Alias('FeedUri')]
        [string]
        $Source,

        [ValidateScript({ [uri]::IsWellFormedUriString($_, 'Absolute') },
            ErrorMessage = "Symbol Source '{0}' is not a valid, absolute URI to a NuGet symbol repository")]
        [Alias('SymbolServerUri')]
        [string]
        $SymbolSource,

        [ValidateNotNullOrEmpty()]
        [string]
        $SymbolApiKey,

        [ValidateRange(1, 2147483647)]
        [int]
        $Timeout = 300,

        [switch]
        $DisableBuffering,

        [switch]
        $NoSymbols,

        [switch]
        $NoServiceEndpoint,

        [switch]
        $SkipDuplicate,

        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "ConfigFile '{0}' is not a valid path to a NuGet configuration file")]
        [Alias('NugetConfigPath')]
        [string]
        $ConfigFile,

        [Alias('UseInvariant')]
        [switch]
        $ForceEnglishOutput,

        [switch]
        $Recurse,

        [switch]
        $Force,

        [switch]
        $UseNuGet
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation -WhatIf:$false

        if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }

        if ($PSBoundParameters.ContainsKey('Verbose') -or ($VerbosePreference -eq 'Continue')) {
            $verbosity = 'detailed'
        }
        elseif ($VerbosityPreference -eq 'SilentlyContinue') {
            $verbosity = 'quiet'
        }
        else {
            $verbosity = 'normal'
        }

        $argumentList = [System.Collections.ArrayList]::new()
    }

    PROCESS {
        if ($UseNuget.IsPresent) {
            if ($PSCmdlet.ParameterSetName = 'UsingLiteralPath') {
                $LiteralPath | ForEach-Object -Process {
                    $argumentList.Clear() | Out-Null
                    $argumentList.Add('push "{0}"' -f $_) | Out-Null

                    $argumentList.Add('-ApiKey {0}' -f $ApiKey) | Out-Null

                    if ($PSBoundParameters.ContainsKey('Source')) {
                        $argumentList.Add('-Source "{0}"' -f $Source) | Out-Null
                    }

                    if ($PSBoundParameters.ContainsKey('SymbolSource')) {
                        $argumentList.Add('-SymbolSource "{0}"' -f $SymbolSource) | Out-Null
                    }

                    if ($PSBoundParameters.ContainsKey('SymbolApiKey')) {
                        $argumentList.Add('-SymbolApiKey {0}' -f $SymbolApiKey) | Out-Null
                    }

                    if ($PSBoundParameters.ContainsKey('Timeout') -and ($Timeout -ne 300)) {
                        if ($Timeout -lt 15) {
                            Write-Warning -Message "$($CmdletName) : A typical DNS transaction can take up to 15 seconds.  Setting the timeout to '$($Timeout)' seconds invites failure"
                        }
                        elseif ($Timeout -gt 600) {
                            Write-Warning -Message "$($CmdletName) : Setting the timeout to '$($Timeout)' is excessive in most cases"
                        }

                        $argumentList.Add(('-Timeout {0}' -f $Timeout)) | Out-Null
                    }

                    if ($DisableBuffering.IsPresent) {
                        Write-Warning -Message "$($CmdletName) : Setting -DisableBuffering may reduce memory usage, but WindowsAuthentication may fail"
                        $argumentList.Add('-DisableBuffering') | Out-Null
                    }

                    if ($NoSymbols.IsPresent) {
                        $argumentList.Add('-NoSymbols') | Out-Null
                    }

                    if ($NoServiceEndpoint.IsPresent) {
                        $argumentList.Add('-NoServiceEndpoint') | Out-Null
                    }

                    if ($SkipDuplicate.IsPresent) {
                        $argumentList.Add('-SkipDuplicate') | Out-Null
                    }

                    if ($PSBoundParameters.ContainsKey('ConfigFile')) {
                        $argumentList.Add(('-ConfigFile "{0}"' -f $ConfigFile)) | Out-Null
                    }

                    $argumentList.Add(('-Verbosity {0}' -f $verbosity)) | Out-Null
                    $argumentList.Add('-NonInteractive') | Out-Null

                    if ($ForceEnglishOutput.IsPresent) {
                        $argumentList.Add('-ForceEnglishOutput') | Out-Null
                    }

                    if ($PSCmdlet.ShouldProcess($_, $CmdletName)) {
                        Invoke-Tool -Name 'nuget' -ArgumentList $argumentList.ToArray() -Force:$Force.IsPresent -WhatIf:$false | Write-Output
                    }
                }
            }
            else {
                $pushPackageSplat = @{
                    ApiKey             = $ApiKey
                    Timeout            = $Timeout
                    DisableBuffering   = $DisableBuffering.IsPresent
                    NoSymbols          = $NoSymbols.IsPresent
                    NoServiceEndpoint  = $NoServiceEndpoint.IsPresent
                    SkipDuplicate      = $SkipDulpicate.IsPresent
                    ForceEnglishOutput = $ForceEnglishOutput.IsPresent
                    UseNuGet           = $UseNuGet.IsPresent
                }

                if ($PSBoundParameters.ContainsKey('Source')) {
                    $pushPackageSplat.Add('Source', $Source) | Out-Null
                }

                if ($PSBoundParameters.ContainsKey('SymbolSource')) {
                    $pushPackageSplat.Add('SymbolSource', $SymbolSource) | Out-Null
                }

                if ($PSBoundParameters.ContainsKey('SymbolApiKey')) {
                    $pushPackageSplat.Add('SymbolApiKey', $SymbolApiKey) | Out-Null
                }

                if ($PSBoundParameters.ContainsKey('ConfigFile')) {
                    $pushPackageSplat.Add('ConfigFile', $ConfigFile) | Out-Null
                }

                Get-ChildItem -Path $Path -File -Recurse:$Recurse.IsPresent | ForEach-Object -Process {
                    Push-Package -LiteralPath $_.FullName @pushPackageSplat | Write-Output
                }
            }
        }
        else {
            if ($PSCmdlet.ParameterSetName = 'UsingLiteralPath') {
                $LiteralPath | ForEach-Object -Process {
                    $argumentList.Clear() | Out-Null
                    $argumentList.Add('nuget push "{0}"' -f $_) | Out-Null

                    $argumentList.Add('--api-key {0}' -f $ApiKey) | Out-Null

                    if ($PSBoundParameters.ContainsKey('Source')) {
                        $argumentList.Add('--source "{0}"' -f $Source) | Out-Null
                    }

                    if ($PSBoundParameters.ContainsKey('SymbolSource')) {
                        $argumentList.Add('--symbol-source "{0}"' -f $SymbolSource) | Out-Null
                    }

                    if ($PSBoundParameters.ContainsKey('SymbolApiKey')) {
                        $argumentList.Add('--symbol-api-key {0}' -f $SymbolApiKey) | Out-Null
                    }

                    if ($PSBoundParameters.ContainsKey('Timeout') -and ($Timeout -ne 300)) {
                        if ($Timeout -lt 15) {
                            Write-Warning -Message "$($CmdletName) : A typical DNS transaction can take up to 15 seconds.  Setting the timeout to '$($Timeout)' seconds invites failure"
                        }
                        elseif ($Timeout -gt 600) {
                            Write-Warning -Message "$($CmdletName) : Setting the timeout to '$($Timeout)' is excessive in most cases"
                        }

                        $argumentList.Add(('--timeout {0}' -f $Timeout)) | Out-Null
                    }

                    if ($DisableBuffering.IsPresent) {
                        Write-Warning -Message "$($CmdletName) : Setting -DisableBuffering may reduce memory usage, but WindowsAuthentication may fail"
                        $argumentList.Add('--disable-buffering') | Out-Null
                    }

                    if ($NoSymbols.IsPresent) {
                        $argumentList.Add('--no-symbols') | Out-Null
                    }

                    if ($NoServiceEndpoint.IsPresent) {
                        $argumentList.Add('--no-service-endpoint') | Out-Null
                    }

                    if ($SkipDuplicate.IsPresent) {
                        $argumentList.Add('--skip-duplicate') | Out-Null
                    }

                    if ($ForceEnglishOutput.IsPresent) {
                        $argumentList.Add('--force-english-output') | Out-Null
                    }

                    if ($PSCmdlet.ShouldProcess($_, $CmdletName)) {
                        Invoke-Tool -Name 'dotnet' -ArgumentList $argumentList.ToArray() -Force:$Force.IsPresent -WhatIf:$false | Write-Output
                    }
                }
                else {
                    $pushPackageSplat = @{
                        ApiKey             = $ApiKey
                        Timeout            = $Timeout
                        DisableBuffering   = $DisableBuffering.IsPresent
                        NoSymbols          = $NoSymbols.IsPresent
                        NoServiceEndpoint  = $NoServiceEndpoint.IsPresent
                        SkipDuplicate      = $SkipDulpicate.IsPresent
                        ForceEnglishOutput = $ForceEnglishOutput.IsPresent
                        UseNuGet           = $UseNuGet.IsPresent
                    }

                    if ($PSBoundParameters.ContainsKey('Source')) {
                        $pushPackageSplat.Add('Source', $Source) | Out-Null
                    }

                    if ($PSBoundParameters.ContainsKey('SymbolSource')) {
                        $pushPackageSplat.Add('SymbolSource', $SymbolSource) | Out-Null
                    }

                    if ($PSBoundParameters.ContainsKey('SymbolApiKey')) {
                        $pushPackageSplat.Add('SymbolApiKey', $SymbolApiKey) | Out-Null
                    }

                    Get-ChildItem -Path $Path -File -Recurse:$Recurse.IsPresent | ForEach-Object -Process {
                        Push-Package -LiteralPath $_.FullName @pushPackageSplat | Write-Output
                    }
                }
            }
        }
    }

    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER Path
        .PARAMETER LiteralPath
        .PARAMETER ApiKey
        .PARAMETER Source
        .PARAMETER SymbolSource
        .PARAMETER SymbolApiKey
        .PARAMETER Timeout
        .PARAMETER DisableBuffering
        .PARAMETER NoSymbols
        .PARAMETER NoServiceEndpoint
        .PARAMETER SkipDuplicate
        .PARAMETER ConfigFile
        .PARAMETER ForceEnglishOutput
        .PARAMETER Recurse
        .PARAMETER Force
        .PARAMETER UseNuGet
        .INPUTS
        None.  `Push-Package` does not accept any input from the PowerShell pipeline.

        .OUTPUTS
        [int]  `Push-Package` returns the nuget return code store in 'LASTEXITCODE' to the PowerShell pipeline.

        .EXAMPLE
        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINKS
        about_CommonParameters

        .LINKS
        about_Function_Advanced

        .LINKS
        ForEach-Object

        .LINKS
        Get-ChildItem

        .LINKS
        Invoke-Tool

        .LINKS
        Write-Output

        .LINKS
        Write-Warning
    #>
}

<###########################################
    Remove-NuGetConfigSource
##########################################>
function Remove-NuGetConfigSource {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    [OutputType([int])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('SourceName')]
        [string]
        $Name,

        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "ConfigFile '{0}' is not a valid path to a NuGet configuration file")]
        [Alias('NugetConfigPath')]
        [string]
        $ConfigFile,

        [Alias('UseInvariant')]
        [switch]
        $ForceEnglishOutput,

        [switch]
        $Force,

        [switch]
        $UseNuGet
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name -WhatIf:$false

    if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
        $ConfirmPreference = 'None'
    }

    if ($PSBoundParameters.ContainsKey('Verbose') -or ($VerbosePreference -eq 'Continue')) {
        $verbosity = 'detailed'
    }
    elseif ($VerbosityPreference -eq 'SilentlyContinue') {
        $verbosity = 'quiet'
    }
    else {
        $verbosity = 'normal'
    }

    $argumentList = [System.Collections.ArrayList]::new()

    if ($UseNuGet.IsPresent) {
        $argumentList.Add(('sources Remove -Name {0}' -f $Name)) | Out-Null

        if ($PSBoundParameters.ContainsKey('ConfigFile')) {
            $argumentList.Add(('-ConfigFile "{0}"' -f $ConfigFile)) | Out-Null
        }

        $argumentList.Add(('-Verbosity {0}' -f $verbosity)) | Out-Null
        $argumentList.Add('-NonInteractive') | Out-Null

        if ($ForceEnglishOutput.IsPresent) {
            $argumentList.Add('-ForceEnglishOutput') | Out-Null
        }

        if ($PSCmdlet.ShouldProcess($Name, $CmdletName)) {
            Invoke-Tool -Name 'nuget' -ArgumentList $argumentList.ToArray() -Force:$Force.IsPresent -WhatIf:$false | Write-Output
        }
    }
    else {
        $argumentList.Add(('nuget remove source {0}' -f $Name)) | Out-Null

        if ($PSBoundParameters.ContainsKey('ConfigFile')) {
            $argumentList.Add(('--configfile "{0}"' -f $ConfigFile)) | Out-Null
        }

        if ($PSCmdlet.ShouldProcess($Name, $CmdletName)) {
            Invoke-Tool -Name 'dotnet' -Version 8.0.0 -ArgumentList $argumentList.ToArray() -Force:$Force.IsPresent -WhatIf:$false | Write-Output
        }
    }

    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER Name
        .PARAMETER ConfigFile
        .PARAMETER ForceEnglishOutput
        .PARAMETER Force
        .PARAMETER UseNuGet
        .INPUTS
        None.  `Remove-NuGetConfigSource` does not accept any input from the PowerShell pipeline.

        .OUTPUTS
        [int]  `Remove-NuGetConfigSource` returns the nuget return code store in 'LASTEXITCODE' to the PowerShell pipeline.

        .EXAMPLE
        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINKS
        about_CommonParameters

        .LINKS
        about_Function_Advanced

        .LINKS
        Invoke-Tool

        .LINKS
        Out-Null

        .LINKS
        Set-StrictMode

        .LINKS
        Set-Variable

        .LINKS
        Write-Output
    #>
}

<###########################################
    Remove-Package
##########################################>
function Remove-Package {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low', DefaultParameterSetName = 'UsingNameValue')]
    [OutputType([int])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, 'UsingTable')]
        [hashtable]
        $Table,

        [Parameter(Mandatory, ParameterSetName = 'UsingNameValue')]
        [ValidateNotNullOrEmpty()]
        [Alias('PackageId', 'Id')]
        [string]
        $Name,

        [Parameter(Mandatory, ParameterSetName = 'UsingNameValue')]
        [version]
        $Version,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ApiKey,

        [Parameter(Mandatory)]
        [ValidateScript({ [uri]::IsWellFormedUriString($_, 'Absolute') },
            ErrorMessage = "Source '{0}' is not a valid, absolute URI to a NuGet soruce repository")]
        [Alias('FeedUri')]
        [string]
        $Source,

        [switch]
        $NoServiceEndpoint,

        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "ConfigFile '{0}' is not a valid path to a NuGet configuration file")]
        [Alias('NugetConfigPath')]
        [string]
        $ConfigFile,

        [Alias('UseInvariant')]
        [switch]
        $ForceEnglishOutput,

        [switch]
        $Force
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation -WhatIf:$false

        if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }

        if ($PSBoundParameters.ContainsKey('Verbose') -or ($VerbosePreference -eq 'Continue')) {
            $verbosity = 'detailed'
        }
        elseif ($VerbosityPreference -eq 'SilentlyContinue') {
            $verbosity = 'quiet'
        }
        else {
            $verbosity = 'normal'
        }

        $argumentList = [System.Collections.ArrayList]::new()
    }

    PROCESS {
        if ($UseNuGet.IsPresent) {
            $argumentList.Clear() | Out-Null
            $argumentList.Add('delete') | Out-Null

            if ($PSCmdlet.ParameterSetName = 'UsingTable') {
                $target = $Table

                $Table.GetEnumerator() | ForEach-Object -Process {
                    $removePackageSplat = @{
                        Name               = $_.Key
                        Version            = $_.Value
                        ApiKey             = $ApiKey
                        Source             = $Source
                        NoServiceEndpoint  = $NoServiceEndpoint.IsPresent
                        ForceEnglishOutput = $ForceEnglishOutput.IsPresent
                        Force              = $Force.IsPresent
                    }

                    if ($PSBoundParameters.ContainsKey('ConfigFile')) {
                        $removePackageSplat.Add('ConfigFile', $ConfigFile) | Out-Null
                    }

                    Remove-Package @removePackageSplat | Write-Output
                }
            }
            else {
                $argumentList.Clear() | Out-Null
                $argumentList.Add('nuget delete') | Out-Null

                $argumentList.Add('{0} {1} {2}' -f $Name, $Version, $ApiKey) | Out-Null

                $target = $Name

                $argumentList.Add('-Source "{0}"' -f $Source) | Out-Null

                $argumentList.Add('-NoPrompt') | Out-Null

                if ($NoServiceEndpoint.IsPresent) {
                    $argumentList.Add('-NoServiceEndpoint') | Out-Null
                }

                $argumentList.Add(('-Verbosity {0}' -f $verbosity)) | Out-Null
                $argumentList.Add('-NonInteractive') | Out-Null

                if ($ForceEnglishOutput.IsPresent) {
                    $argumentList.Add('-ForceEnglishOutput') | Out-Null
                }

                if ($PSCmdlet.ShouldProcess($target, $CmdletName)) {
                    Invoke-Tool -Name 'nuget' -ArgumentList $argumentList.ToArray() -Force:$Force.IsPresent | Write-Output
                }
            }
        }
        else {
            $argumentList.Clear() | Out-Null
            $argumentList.Add('nuget delete') | Out-Null

            if ($PSCmdlet.ParameterSetName = 'UsingTable') {
                $target = $Table

                $Table.GetEnumerator() | ForEach-Object -Process {
                    $removePackageSplat = @{
                        Name               = $_.Key
                        Version            = $_.Value
                        ApiKey             = $ApiKey
                        Source             = $Source
                        NoServiceEndpoint  = $NoServiceEndpoint.IsPresent
                        ForceEnglishOutput = $ForceEnglishOutput.IsPresent
                        Force              = $Force.IsPresent
                        UseNuGet           = $UseNuGet.IsPresent
                    }

                    Remove-Package @removePackageSplat | Write-Output
                }
            }
            else {
                $argumentList.Add('{0} {1} --api-key {2}' -f $Name, $Version, $ApiKey) | Out-Null

                $target = $Name

                $argumentList.Add('--source "{0}"' -f $Source) | Out-Null

                if ($NoServiceEndpoint.IsPresent) {
                    $argumentList.Add('--no-service-endpoint') | Out-Null
                }

                $argumentList.Add('--non-interactive') | Out-Null

                if ($ForceEnglishOutput.IsPresent) {
                    $argumentList.Add('--force-english-output') | Out-Null
                }

                if ($PSCmdlet.ShouldProcess($target, $CmdletName)) {
                    Invoke-Tool -Name 'dotnet' -Version 8.0.0 -ArgumentList $argumentList.ToArray() -Force:$Force.IsPresent | Write-Output
                }
            }
        }
    }

    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER Table
        .PARAMETER Name
        .PARAMETER Version
        .PARAMETER ApiKey
        .PARAMETER Source
        .PARAMETER NoServiceEndpoint
        .PARAMETER ConfigFile
        .PARAMETER ForceEnglishOutput
        .PARAMETER Force
        .PARAMETER UseNuGet
        .INPUTS
        [hashtable]  `Remove-Package` accepts a table as input from the PowerShell pipeline where:

        * Key is the PackageId; AND
        * Value is the Version of the PackageId to remove.

        .OUTPUTS
        [int]  `Remove-Package` returns the nuget return code store in 'LASTEXITCODE' to the PowerShell pipeline.

        .EXAMPLE
        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINKS
        about_CommonParameters

        .LINKS
        about_Function_Advanced

        .LINKS
        ForEach-Object

        .LINKS
        Invoke-Tool

        .LINKS
        Out-Null

        .LINKS
        Set-StrictMode

        .LINKS
        Set-Variable
    #>
}

<###########################################
    Update-NuGetConfigSource
##########################################>
function Update-NuGetConfigSource {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    [OutputType([int])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('SourceName')]
        [string]
        $Name,

        [Parameter(Mandatory)]
        [ValidateScript({ [uri]::IsWellFormedUriString($_, 'Absolute') },
            ErrorMessage = "Source '{0}' is not a valid, absolute URI to a NuGet source repository")]
        [Alias('FeedUri')]
        [string]
        $Source,

        [ValidateRange(2, 3)]
        [int]
        $ProtocolVersion = 3,

        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "ConfigFile '{0}' is not a valid path to a NuGet configuration file")]
        [Alias('NugetConfigPath')]
        [string]
        $ConfigFile,

        [Alias('UseInvariant')]
        [switch]
        $ForceEnglishOutput,

        [switch]
        $Force,

        [switch]
        $UseNuGet
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name -WhatIf:$false

    if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
        $ConfirmPreference = 'None'
    }

    if ($PSBoundParameters.ContainsKey('Verbose') -or ($VerbosePreference -eq 'Continue')) {
        $verbosity = 'detailed'
    }
    elseif ($VerbosityPreference -eq 'SilentlyContinue') {
        $verbosity = 'quiet'
    }
    else {
        $verbosity = 'normal'
    }

    $argumentList = [System.Collections.ArrayList]::new()

    if ($UseNuGet.IsPresent) {
        $argumentList.Add(('sources Update -Name {0} -Source "{1}"' -f $Name, $Source)) | Out-Null

        if ($PSBoundParameters.ContainsKey('ConfigFile')) {
            $argumentList.Add(('-ConfigFile "{0}"' -f $ConfigFile)) | Out-Null
        }

        $argumentList.Add(('-ProtocolVersion {0}' -f $ProtocolVersion))
        $argumentList.Add(('-Verbosity {0}' -f $verbosity)) | Out-Null
        $argumentList.Add('-NonInteractive') | Out-Null

        if ($ForceEnglishOutput.IsPresent) {
            $argumentList.Add('-ForceEnglishOutput') | Out-Null
        }

        if ($PSCmdlet.ShouldProcess($Name, $CmdletName)) {
            Invoke-Tool -Name 'nuget' -ArgumentList $argumentList.ToArray() -Force:$Force.IsPresent -WhatIf:$false | Write-Output
        }
    }
    else {
        $argumentList.Add(('nuget update source {0} --source "{1}"' -f $Name, $Source)) | Out-Null

        if ($PSBoundParameters.ContainsKey('ConfigFile')) {
            $argumentList.Add(('--configfile "{0}"' -f $ConfigFile)) | Out-Null
        }

        $argumentList.Add(('--protocol-version {0}' -f $ProtocolVersion))

        if ($PSCmdlet.ShouldProcess($Name, $CmdletName)) {
            Invoke-Tool -Name 'dotnet' -Version 8.0.0 -ArgumentList $argumentList.ToArray() -Force:$Force.IsPresent -WhatIf:$false | Write-Output
        }
    }

    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER Name
        .PARAMETER Source
        .PARAMETER ProtocolVersion
        .PARAMETER ConfigFile
        .PARAMETER ForceEnglishOutput
        .PARAMETER Force
        .INPUTS
        None.  `Update-NuGetConfigSource` does not accept any input from the PowerShell pipeline.

        .OUTPUTS
        [int]  `Update-NuGetConfigSource` returns the nuget return code store in 'LASTEXITCODE' to the PowerShell pipeline.

        .EXAMPLE

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINKS
        about_CommonParameters

        .LINKS
        about_Function_Advanced

        .LINKS
        Invoke-Tool

        .LINKS
        Out-Null

        .LINKS
        Set-StrictMode

        .LINKS
        Set-Variable

        .LINKS
        Test-Path

        .LINKS
        Write-Output
    #>
}

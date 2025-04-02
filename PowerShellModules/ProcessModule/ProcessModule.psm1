<#
 =============================================================================
<copyright file="ProcessModule.psm1" company="John Merryweather Cooper
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
<date>Created:  2025-3-11</date>
<summary>
This file "ProcessModule.psm1" is part of "PurgeNugetFeeds".
</summary>
<remarks>description</remarks>
=============================================================================
#>

#
# ProcessModule.psm1
#

<#
    Add-TypeIf
##########################################>
function Add-TypeIf {
    [CmdletName(SupportsShouldProcess, ConfirmImpact = 'Low', DefaultParameterSetName = 'UsingPath')]
    [OutputType([void])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Get-ChildItem -Path $_ | Test-Path -PathType Leaf },
            ErrorMessage = "Path '{0}' is not a valid path to an Assembly file")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingCodeBase')]
        [ValidateScript({ [uri]::IsWellFormedUriString($_, 'Absolute') },
            ErrorMessage = "CodeBase '{0}' is not a valid, absolute URI to an Assembly file")]
        [Alias('Uri')]
        [string[]]
        $CodeBase,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLocation')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "LiteralPath '{0}' is not a valid path to an Assembly file")]
        [Alias('LiteralPath')]
        [string[]]
        $Location,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingName')]
        [ValidateNotNullOrEmpty()]
        [Alias('AssemblyName')]
        [string[]]
        $Name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingFullName')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $FullName,

        [switch]
        $Force,

        [Parameter(ParameterSetName = 'UsingPath')]
        [switch]
        $Recurse,

        [switch]
        $Trusted
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
            'UsingCodeBase' {
                $CodeBase | ForEach-Object -Process {
                    if (Test-PSAssemblyLoaded -CodeBase $_ -Trusted:$Trusted.IsPresent) {
                        if ($PSCmdlet.ShouldProcess($_, $CmdletName)) {
                            $Location = Get-PSAssemblyLoad | Where-Object -Property CodeBase -EQ $_ | Select-Object -ExpandProperty Location
                            Add-Type -Path $Location -WhatIf:$false
                        }
                    }
                    else {
                        $newErrorRecordSplat = @{
                            Exception    = [System.IO.FileNotFoundException]::new("$($CmdletName) : Assembly Location not found or is not loadable", $_)
                            Category     = 'ObjectNotFound'
                            ErrorId      = Format-ErrorId -Caller $CmdletName -Name 'FileNotFoundException' -Position $MyInvocation.ScriptLineNumber
                            TargetObject = $_
                        }

                        New-ErrorRecord @newErrorRecordSplat | Write-Error -ErrorAction Continue
                    }
                }

                break
            }

            'UsingLocation' {
                $Location | ForEach-Object -Process {
                    if (Test-PSAssemblyLoaded -Location $_ -Trusted:$Trusted.IsPresent) {
                        if ($PSCmdlet.ShouldProcess($_, $CmdletName)) {
                            Add-Type -Path $_ -WhatIf:$false
                        }
                    }
                    else {
                        $newErrorRecordSplat = @{
                            Exception    = [System.IO.FileNotFoundException]::new("$($CmdletName) : Assembly Location not found or is not loadable", $_)
                            Category     = 'ObjectNotFound'
                            ErrorId      = Format-ErrorId -Caller $CmdletName -Name 'FileNotFoundException' -Position $MyInvocation.ScriptLineNumber
                            TargetObject = $_
                        }

                        New-ErrorRecord @newErrorRecordSplat | Write-Error -ErrorAction Continue
                    }
                }

                break
            }

            'UsingName' {
                $Name | ForEach-Object -Process {
                    if (Test-PSAssemblyLoaded -Name $_ -Trusted:$Trusted.IsPresent) {
                        if ($PSCmdlet.ShouldProcess($_, $CmdletName)) {
                            Add-Type -AssemblyName $_ -WhatIf:$false
                        }
                    }
                    else {
                        $newErrorRecordSplat = @{
                            Exception    = [System.TypeLoadException]::new("$($CmdletName) : Assembly Name '$($_)' not loadable")
                            Category     = 'InvalidType'
                            ErrorId      = Format-ErrorId -Caller $CmdletName -Name 'TypeLoadException' -Position $MyInvocation.ScriptLineNumber
                            TargetObject = $_
                        }

                        New-ErrorRecord @newErrorRecordSplat | Write-Error -ErrorAction Continue
                    }
                }

                break
            }

            'UsingFullName' {
                $FullName | ForEach-Object -Process {
                    if (Test-PSAssemblyLoaded -FullName $_ -Trusted:$Trusted.IsPresent) {
                        if ($PSCmdlet.ShouldProcess($_, $CmdletName)) {
                            Add-Type -AssemblyName $_ -WhatIf:$false
                        }
                    }
                    else {
                        $newErrorRecordSplat = @{
                            Exception    = [System.TypeLoadException]::new("$($CmdletName) : Assembly Name '$($_)' not loadable")
                            Category     = 'InvalidType'
                            ErrorId      = Format-ErrorId -Caller $CmdletName -Name 'TypeLoadException' -Position $MyInvocation.ScriptLineNumber
                            TargetObject = $_
                        }

                        New-ErrorRecord @newErrorRecordSplat | Write-Error -ErrorAction Continue
                    }
                }

                break
            }

            default {
                Get-ChildItem -Path $Path -File -Resolve:$Resolve.IsPresent | ForEach-Object -Process {
                    if (Test-PSAssemblyLoaded -Location $_ -Trusted:$Trusted.IsPresent) {
                        if ($PSCmdlet.ShouldProcess($_, $CmdletName)) {
                            Add-Type -Path $_ -WhatIf:$false
                        }
                    }
                    else {
                        $newErrorRecordSplat = @{
                            Exception    = [System.IO.FileNotFoundException]::new("$($CmdletName) : Assembly Location not found or is not loadable", $_.FullName)
                            Category     = 'ObjectNotFound'
                            ErrorId      = Format-ErrorId -Caller $CmdletName -Name 'FileNotFoundException' -Position $MyInvocation.ScriptLineNumber
                            TargetObject = $_.FullName
                        }

                        New-ErrorRecord @newErrorRecordSplat | Write-Error -ErrorAction Continue
                    }
                }
            }
        }
    }
}

<###########################################
    Get-PSAssemblyLoaded
##########################################>
function Get-PSAssemblyLoaded {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param ()

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    [System.AppDomain]::CurrentDomain.ReflectionOnlyGetAssemblies() | Where-Object -FilterScript { -not [string]::IsNullOrEmpty($_.Location) } | ForEach-Object -Process {
        $assemblyPropertiesOfInterest = [PSCustomObject]@{
            CodeBase               = $_.CodeBase
            FullName               = $_.FullName
            GlobalAssemblyCache    = $_.GlobalAssemblyCache
            IsFullyTrusted         = $_.IsFullyTrusted
            Location               = $_.Location
            Name                   = $_.GetName().Name
            AssemblyVersion        = $_.GetName().Version
            AssemblyFileVersion    = Get-Item -LiteralPath $_.Location | Select-Object -ExpandProperty VersionInfo | Select-Object -ExpandProperty FileVersion
            AssemblyProductVersion = Get-Item -LiteralPath $_.Location | Select-Object -ExpandProperty VersionInfo | Select-Object -ExpandProperty ProductVersion
        }

        $assemblyPropertiesOfInterest | Write-Output
    }
}

<###########################################
    Invoke-Tool
##########################################>
function Invoke-Tool {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([int])]
    [OutputType([string], ParameterSetName = 'UsingStringOutput')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingName')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory, ParameterSetName = 'UsingFilePath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "FilePath '{0}' is not a valid path to an executable")]
        [string]
        $FilePath,

        [ValidateNotNullOrEmpty()]
        [ValidateCount(1, 2147483647)]
        [Alias('Argument')]
        [string[]]
        $ArgumentList,

        [string]
        $Separator = ' ',

        [version]
        $Version,

        [Parameter(Mandatory, ParameterSetName = 'UsingStringOutput')]
        [switch]
        $StdOut,

        [switch]
        $Force,

        [switch]
        $Quiet
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name -WhatIf:$false

    if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
        $ConfirmPreference = 'None'
    }

    if ($PSBoundParameters.ContainsKey('FilePath') -and $PSBoundParameters.ContainsKey('Name')) {
        $newObjectSplat = @{
            TypeName     = 'System.Management.Automation.ErrorRecord'
            ArgumentList = @(
                [System.InvalidOperationException]::new("$($CmdletName) : Both 'FilePath' and 'Name' cannot be passed"),
                'InvalidOperation',
                "$($CmdletName)-InvalidOperationException-$($MyInvocation.ScriptLineNumber)",
                $PSBoundParameters
            )
        }

        $er = New-Object @newObjectSplat
        Write-Error -ErrorRecord $er -ErrorAction Continue
        throw $er
    }
    elseif ($PSBoundParameters.ContainsKey('FilePath')) {
        Write-Debug -Message "$($CmdletName) : Tool '$($FilePath)' exists"

        if ($PSBoundParameters.ContainsKey('Version')) {
            $productVersion = Get-Item -LiteralPath $FilePath | Select-Object -ExpandProperty VersionInfo | Select-Object -ExpandProperty ProductVersion

            if ([version]$productVersion -ge $Version) {
                Write-Debug -Message "$($CmdletName) : Tool '$($FilePath)' has Version greater than or equal to '$($Version)'"
            }
            else {
                $newObjectSplat = @{
                    TypeName     = 'System.Management.Automation.ErrorRecord'
                    ArgumentList = @(
                        [System.IO.FileNotFoundException]::new("$($CmdletName) : Tool '$($FilePath)' does not have Version greater than or equal to '$($Version)'", $FilePath),
                        'NotInstalled',
                        "$($CmdletName)-FileNotFoundException-$($MyInvocation.ScriptLineNumber)",
                        "$($FilePath):$($Version)"
                    )
                }

                $er = New-Object @newObjectSplat
                Write-Error -ErrorRecord $er -ErrorAction Continue
                throw $er
            }
        }

        if ($PSBoundParameters.ContainsKey('Argument')) {
            $commandLine = ('"{0}"{1}{2}' -f $FilePath, $Separator, $Argument)
        }
        if ($PSBoundParameters.ContainsKey('ArgumentList')) {
            $Argument = ($ArgumentList -join $Separator)
            $commandLine = ('"{0}"{1}{2}' -f $FilePath, $Separator, $Argument)
        }
        else {
            $commandLine = ('"{0}"' -f $FilePath)
        }

        $command = $FilePath
    }
    elseif ($PSBoundParameters.ContainsKey('Name')) {
        $path = Get-Command -All | Where-Object -Property Name -EQ $Name | Select-Object -ExpandProperty Path

        if (($null -ne $path)) {
            Write-Debug -Message "$($CmdletName) : Tool '$($Name)' is on the PATH at '$($path)'"
        }
        else {
            $newErrorRecordSplat = @{
                Exception    = [System.IO.FileNotFoundException]::new("$($CmdletName) : Tool '$($Name)' cannot be found on the PATH with any extension in '$($env:PATHEXT)'", $path)
                Category     = 'ObjectNotFound'
                ErrorId      = Format-ErrorId -Caller $CmdletName -Name 'FileNotFoundException' -Position $MyInvocation.ScriptLineNumber
                TargetObject = $path
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }
        else {
            $newErrorRecordSplat = @{
                Exception    = [System.InvalidOperationException]::new("$($CmdletName) : One of 'FilePath' xor 'Name' must be passed")
                Category     = 'InvalidOperation'
                ErrorId      = Format-ErrorId -Caller $CmdletName -Name 'InvalidOperationException' -Position $MyInvocation.ScriptLineNumber
                TargetObject = $PSBoundParameters
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ($PSBoundParameters.ContainsKey('Version')) {
            $productVersion = Get-Command -All | Where-Object -Property Name -EQ $Name | Select-Object -ExpandProperty Version

            if ($productVersion -ge $Version) {
                Write-Debug -Message "$($CmdletName) : Tool '$($Name)' is on the PATH with Version greater than or equal to '$($Version)'"
            }
            else {
                $newErrorRecordSplat = @{
                    Exception    = [System.IO.FileNotFoundException]::new("$($CmdletName) : Tool '$($Name):$($Version)' cannot be found on the PATH with Version", $Name)
                    Category     = 'NotInstalled'
                    ErrorId      = Format-ErrorId -Caller $CmdletName -Name 'FileNotFoundException' -Position $MyInvocation.ScriptLineNumber
                    TargetObject = "$($Name):$($Version)"
                }

                New-ErrorRecord @newErrorRecordSplat | Write-Fatal
            }

            if ($PSBoundParameters.ContainsKey('ArgumentList')) {
                $commandLine = ('{0}{1}{2}' -f $Name, $Separator, ($ArgumentList -join $Separator))
            }
            else {
                $commandLine = $Name
            }

            $command = $Name

            if ($PSCmdlet.ShouldProcess($commandLine, $CmdletName)) {
                if ($PSCmdlet.ParameterSetName -eq 'UsingStringOutput') {
                    & commandLine | Write-Output
                }
                elseif ($Quiet.IsPresent) {
                    & commandLine | Out-Null
                    $LASTEXITCODE | Write-Output
                }
                else {
                    & commandLine
                    $LASTEXITCODE | Write-Output
                }

                if ($LASTEXITCODE -eq 0) {
                    Write-Verbose -Message "$($CmdletName) : '$($command)' returned '0' which indicates success"
                }
                elseif ($LASTEXITCODE -gt 0) {
                    Write-Warning -Message ("$($CmdletName) : '$($command)' returned '{0}|0x{0:X8}' which indicates failure" -f $LASTEXITCODE)
                }
                elseif ($LASTEXITCODE -lt 0) {
                    $newErrorRecordSplat = @{
                        Exception    = [System.InvalidOperationException]::new(("$($CmdletName) : '$($command)' returned '{0}|0x{0:X8}' which indicates system failure" -f $LASTEXITCODE))
                        Category     = 'InvalidResult'
                        ErrorId      = Format-ErrorId -Caller $CmdletName -Name 'InvalidOperationException' -Position $MyInvocation.ScriptLineNumber
                        TargetObject = $LASTEXITCODE
                    }

                    New-ErrorRecord @newErrorRecordSplat | Write-Error -ErrorAction Continue
                }
            }
        }
    }

        <#
        .SYNOPSIS
        Runs a tool with or without command line arguments.

        .DESCRIPTION
        `Invoke-Tool` runs a tool with or without command line arguments directly with the invoke operator.  `LASTEXITCODE` is checked for succes for failure:

        * a value of zero indicates success;
        * a value greater than zero indicates an application error; AND
        * a value less than zero indicates a system error.

        .PARAMETER Name
        Specifies the base name of the executable.  'Name' xor 'FilePath' must be provided.

        .PARAMETER FilePath
        Specifies the full path of the executable.  'FilePath' xor 'Name' must be provided.

        .PARAMETER ArgumentList
        Specifies the arguments to pass to either 'Name' or 'FilePath'.

        .PARAMETER Separator
        Specifies the argument separator.  The most common are 'space' and [Environment]::NewLine.

        .PARAMETER Version
        Specifies the minimum version of the tool for execution.  If the tool does not have a product version greater than or equal to 'Version', execution will be aborted.

        .PARAMETER StdOut
        If specified, pass strings to the PowerShell pipeline instead of an integer return code.

        .PARAMETER Force
        If specified, disable 'Confirm' unless it is explictly passed.

        .PARAMETER Quiet
        If specified, standard output is shunted to 'Out-Null'

        .INPUTS
        None.  `Invoke-Tool` does not accept input from the PowerShell pipeline.

        .OUTPUTS
        [int] `Invoke-Tool` returns the $LASTEXITCODE value to the PowerShell pipeline.

        [string]  If 'StdOut' is passed to `Invoke-Tool`, it returns multile strings one string at a time.

        .EXAMPLE
        PS> Invoke-Tool -Name 'msbuild'

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINKS
        about_CommonParameters

        .LINKS
        about_Function_Advanced

        .LINKS
        Get-Command

        .LINKS
        Get-Item

        .LINKS
        New-Object

        .LINKS
        Select-Object

        .LINKS
        Set-StrictMode

        .LINKS
        Set-Variable

        .LINKS
        Test-Path

        .LINKS
        Where-Object

        .LINKS
        Write-Debug

        .LINKS
        Write-Error

        .LINKS
        Write-Output

        .LINKS
        Write-Verbose

        .LINKS
        Write-Warning
    #>
}

    <###########################################
    Start-Command
##########################################>
    function Start-Command {
        [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
        [OutputType([System.Diagnostics.Process])]
        param (
            [Parameter(Mandatory)]
            [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
                ErrorMessage = "FilePath '{0}' is not a valid path to an executable")]
            [string]
            $FilePath,

            [string[]]
            $ArgumentList,

            [switch]
            $CreateNoWindow,

            [hashtable]
            $Environment,

            [switch]
            $LoadUserProfile,

            [Parameter(Mandatory, ParameterSetName = 'UsingUserNamePassword')]
            [securestring]
            $Password,

            [switch]
            $RedirectStandardError,

            [switch]
            $RedirectStandardInput,

            [switch]
            $RedirectStandardOutput,

            [ValidateSet('ASCII', 'BigEndianUnicode', 'Default', 'Latin1', 'Unicode', 'UTF32', 'UTF8')]
            [AllowNull()]
            [System.Text.Encoding]
            $StandardErrorEncoding = 'Default',

            [ValidateSet('ASCII', 'BigEndianUnicode', 'Default', 'Latin1', 'Unicode', 'UTF32', 'UTF8')]
            [AllowNull()]
            [System.Text.Encoding]
            $StandardInputEncoding = 'Default',

            [ValidateSet('ASCII', 'BigEndianUnicode', 'Default', 'Latin1', 'Unicode', 'UTF32', 'UTF8')]
            [AllowNull()]
            [System.Text.Encoding]
            $StandardOutputEncoding = 'Default',

            [ValidateScript({ Test-Path -LiteralPath -PathType Leaf },
                ErrorMessage = "StandardInputFile '{0}' is not a valid path to an input file")]
            [string]
            $StandardInputFile,

            [Parameter(Mandatory, ParameterSetName = 'UsingUserNamePassword')]
            [ValidatePatter('^(?:(?<username>[^@]+)@(?<domain>.+) | (?<domain>[^\\]+)\\(?<username>.+))$')]
            [string]
            $UserName,

            [ValidateSet('Normal', 'Hidden', 'Minimized', 'Maximized')]
            [System.Diagnostics.ProcessWindowStyle]
            $WindowsStyle = 'Normal',

            [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
                ErrorMessage = "WorkingDirectory '{0}' is not a valid path container")]
            [AllowEmptyString()]
            [string]
            $WorkingDirectory = '',

            [switch]
            $Force
        )

        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }

        if ($PSBoundParameters.ContainsKey('Verbose') -or ($VerbosePreference -ne 'SilentlyContinue')) {
            $quiet = $false
        }
        elseif ($InformationPreference -ne 'SilentlyContinue') {
            $quite = $false
        }
        elseif ($PSBoundParameters.ContainsKey('Debug') -or (Test-Path -LiteralPath variable:\DebugContext) -or ($DebugPreference -ne 'SilentlyContinue')) {
            $quite = $false
        }
        else {
            $quiet = $true
        }

        if ($PSBoundParameters.ContainsKey('ArgumentList')) {
            $startInfo = [System.Diagnostics.ProcessStartInfo]::new($FilePath, $ArgumentList)
        }
        else {
            $startInfo = [System.Diagnostics.ProcessStartInfo]::new($FilePath)
        }

        $startInfo.UseShellExecute = $false
        $startInfo.CreateNoWindow = $CreateNoWindow.IsPresent

        if ($PSCmdlet.ParameterSetName -eq 'UsingUserNamePassword') {
            if ($UserName -match '^(?<username>[^@]+)@(?<domain>.+)$' -and $UserName.Length -le 1024) {
                $startInfo.Domain = $null
                $startInfo.UserName = $UserName
                $startInfo.Password = $Password
            }
            elseif ($UserName -match '^(?<domain>[^\\]{1,15})\\(?<username>.{1,256}$') {
                $startInfo.Domain = $Matches['domain']
                $startInfo.UserName = $Matches['username']
                $startInfo.Password = $Password
            }
        }

        if ($PSBoundParameters.ContainsKey('Environment')) {
            $Environment.GetEnumerator() | ForEach-Object -Process {
                $startInfo.Environment.Add($_.Key, $_.Value)
            }
        }

        $startInfo.LoadUserProfile = $LoadUserProfile.IsPresent
        $startInfo.RedirectStandardError = $RedirectStandardError.IsPresent

        if ($RedirectStandardInput.IsPresent -and $PSBoundParameters.ContainsKey('StandardInputFile')) {
            $startInfo.RedirectStandardInput = $RedirectStandardInput.IsPresent
        }

        $startInfo.RedirectStandardOutput = $RedirectStandardOutput.IsPresent

        if (($null -ne $StandardErrorEncoding) -and ($StandarErrorEncoding -ne 'Default')) {
            $startInfo.StandardErrorEncoding = $StandardErrorEncoding
        }

        if (($null -ne $StandardInputEncoding) -and ($StandarInputEncoding -ne 'Default')) {
            $startInfo.StandardInputEncoding = $StandardInputEncoding
        }

        if (($null -ne $StandardOutputEncoding) -and ($StandardOutputEncoding -ne 'Default')) {
            $startInfo.StandardOutputEncoding = $StandardOutputEncoding
        }

        if (-not $CreateNoWindow.IsPresent -and ($WindowStyle -ne 'Normal')) {
            $startInfo.WindowStyle = $WindowStyle
        }

        if ($PSBoundParameters.ContainsKey('WorkingDirectory') -and -not [string]::IsNullOrWhiteSpace($WorkingDirectory)) {
            $startInfo.WorkingDirectory = $WorkingDirectory
        }

        if ($PSCmdlet.ShouldProcess($FilePath, $CmdletName)) {
            Write-Debug -Message "$($CmdletName) : Command Line '$($FilePath) $($ArgumentList -join " ")'"

            $process = [System.Diagnostics.Process]::Start($startInfo)

            if ($RedirectStandarError.IsPresent -or $RedirectStandareOutput.IsPresent) {
                Write-Debug -Message "$($CmdletName) : Enabling Raising Events"
                $process.EnableRaisingEvents = $true

                Write-Verbose -Message "$($CmdletName) : Registering 'Exited' Event Handler"

                Register-ObjectEvent -InputObject $process -EventName Exited -Action {
                    if ($RedirectStandardError.IsPresent) {
                        $errorTask = $process.StandardError.ReadToEndAsync()
                        $errorBuffer.Append($errorTask.Result)
                        $process.CancelErrorRead()
                    }

                    if ($RedirectStandardOutput.IsPresent) {
                        $outputTask = $process.StandardOutput.ReadToEndAsync()
                        $outputBuffer.Append($outputTask.Result)
                        $process.CancelOutputRead()
                    }

                    if ($RedirectStandareInput.IsPresent) {
                        $process.StandardInput.Close()
                    }

                    $elapsed = $process.StopTime.Subtract($process.StartTime)
                    Write-Verbose -Message "$($CmdletName) : '$($FilePath)' Start Time '$($process.StartTime)' Stop Time '$($process.StopTime)' Elapsed Time '$($elapsed)'"
                }
            }

            if ($RedirectStandardError.IsPresent) {
                $errorBuffer = [System.Text.StringBuilder]::new()

                Write-Verbose -Message "$($CmdletName) : Registering 'ErrorDataReceived' Event Handler"

                Register-ObjectEvent -InputObject $process -EventName ErrorDataReceived -Action {
                    $errorTask = $process.StandardError.ReadToEndAsync()
                    $errorBuffer.Append($errorTask.Result)
                }

                $process.BeginErrorReadline()
            }

            if ($RedirectStandardOutput.IsPresent) {
                $outputBuffer = [System.Text.StringBuilder]::new()

                Write-Verbose -Message "$($CmdletName) : Registering 'OutputDataReceived' Event Handler"
                Register-ObjectEvent -InputObject $process -EventName OutputDataReceived -Action {
                    $outputTask = $process.StandardOutput.ReadLineAsync()
                    $outputBuffer.AppendLine($outputTask.Result)
                }

                $process.BeginOutputReadline()
            }

            $process | Write-Output

            # process standard input
            if ($RedirectStandardInput.IsPresent -and $PSBoundParameters.ContainsKey('StandardInputFile')) {
                Write-Verbose -Message "$($CmdletName) : Processing '$($StandardInputFile)' to redirected standard input"

                # loop over input
                Get-Content -LiteralPath $StandardInputFile -Encoding $StandardInputEncoding | ForEach-Object -Process {
                    Write-Debug -Message "$($CmdletName) : Echo '$($_)'"
                    $process.StandardInput.WriteLineAsync($_)
                }

                Write-Debug -Message "$($CmdletName) : Flushing standard input"
                $process.StandardInput.FlushAsync()
            }

            # necessary if redirecting
            if ($RedirectStandardError.IsPresent -or $RedirectStandardOutput.IsPresent -or $RedictStandardInput.IsPresent) {
                $process.WaitForExit()
            }

            # alway output anything from StandardError
            if ($process.HasExited -and $RedirectStandardError.IsPresent) {
                $errorBuffer.ToString() -split [Environment]::NewLine | ForEach-Object -Process { Write-Warning -Message $_ }
            }

            if ($process.HasExited -and -not $quiet -and $RedirectStandardOutput.IsPresent) {
                $outputBuffer.ToString() -split [Environment]::NewLine | ForEach-Object -Process { Write-Information -MessageData $_ -InformationAction Continue }
            }
        }

        <#
        .SYNOPSIS
        Directly runs a command with or without arguments.

        .DESCRIPTION
        `Start-Command` directly runs a command with or without arguments.

        .PARAMETER FilePath
        Specifies the file path of the command to execute.  This parameter is mandatory and must resolve to a path that is a 'Leaf'.

        .PARAMETER ArgumentList
        Specifies one or more arguments to pass to 'FilePath'.

        .PARAMETER CreateNoWindow
        If specified, a new window is not created on process start.  When this parameter is set, 'WindowsStyle' has no effect.

        .PARAMETER Environment
        Specifies a hashtable of environment variables to add or modify before command execution.

        .PARAMETER LoadUserProfile
        If set, the user profile, not the PowerShell user profile, is loaded before the command starts.

        .PARAMETER Password
        Specifies the secure string password associated with 'UserName'.

        .PARAMETER RedirectStandardError
        If set, StandardError will be redirected via an event handle and displayed at the end of command execution as a serious of 'Write-Warnings'.

        .PARAMETER RedirectStandardInput
        If set, StandardInput will be redirected via the StandardOutput event handler to the file supplied by 'StandardInputFile'.  This means if StandardInput redirection is desired, then at least StandardOutput must also be redirected.

        .PARAMETER RedirectStandardOutput
        If set, StandardOutput will be redirected via an event handle and displayed at the end of command execution as a serious of 'Write-Informations', if 'quiet' is not set as true internally.  'Verbose' always disables 'quiet' mode.

        .PARAMETER StandardErrorEncoding
        Specifies the StandardError encoding.  The default value is 'Default'.

        .PARAMETER StandardInputEncoding
        Specifies the StandardInput encoding.  The default value is 'Default'.  The contents of 'StandardInputFile' will be read using this encoding.

        .PARAMETER StandardOutputEncoding
        Specifies the StandardOutput encoding.  The default value is 'Default'.

        .PARAMETER StandardInputFile
        Specifies the file path, which must exist, which will be read and supplied line-by-line to StandardInput.

        .PARAMETER UserName
        Specifies the user name part of the 'UserName/Password' credential, both of which must be passed if credentials are required.
        If 'UserName' is a UPN, 'Domain' will be internally set to $null.  Otherwise, 'UserName' will be parsed and the Domain-part
        will be assigned to 'Domain' and the UserName-part will be assigned to 'UserName'.  All OS limitations on UPN and Windows
        login user names are enforced.

        .PARAMETER WindowsStyle
        If 'CreateNoWindow' is not set, this parameter sets the Windows style for the process on startup.  The default value is 'Normal'.

        .PARAMETER WorkingDirectory
        Specifies the directory that will be changed into before the command is executed.

        .PARAMETER Force
        If specified, 'Confirm' is disabled unless 'Confirm' is expressly passed.

        .INPUTS
        None.  `Start-Command` does not receive any input from the PowerShell pipeline.

        .OUTPUTS
        [System.Diagnostics.Process]  `Start-Command` returns a [System.Diagnostics.Process] instance to the PowerShell pipeline.

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINKS
        about_CommonParameters

        .LINKS
        about_Function_Advanced

        .LINKS
        ForEach-Object

        .LINKS
        Get-Content

        .LINKS
        Register-ObjectEvent

        .LINKS
        Set-StrictMode

        .LINKS
        Set-Variable

        .LINKS
        Test-Path

        .LINKS
        Write-Information

        .LINKS
        Write-Output

        .LINKS
        Write-Verbose

        .LINKS
        Write-Warning
    #>
    }

    <###########################################
    Start-ShellExecute
##########################################>
    function Start-ShellExecute {
        [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
        [OutputType([System.Diagnostics.Process])]
        param (
            [Parameter(Mandatory)]
            [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
                ErrorMessage = "FilePath '{0}' is not a valid path to an executable or registered data file")]
            [string]
            $FilePath,

            [string[]]
            $ArgumentList,

            [hashtable]
            $Environment,

            [switch]
            $LoadUserProfile,

            [Parameter(Mandatory, ParameterSetName = 'UsingUserNamePassword')]
            [securestring]
            $Password,

            [Parameter(Mandatory, ParameterSetName = 'UsingUserNamePassword')]
            [ValidatePatter('^(?:(?<username>[^@]+)@(?<domain>.+) | (?<domain>[^\\]+)\\(?<username>.+))$')]
            [string]
            $UserName,

            [ValidateSet('Normal', 'Hidden', 'Minimized', 'Maximized')]
            [System.Diagnostics.ProcessWindowStyle]
            $WindowsStyle = 'Normal',

            [switch]
            $Force
        )

        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }

        if ($PSBoundParameters.ContainsKey('ArgumentList')) {
            $startInfo = [System.Diagnostics.ProcessStartInfo]::new($FilePath, $ArgumentList)
        }
        else {
            $startInfo = [System.Diagnostics.ProcessStartInfo]::new($FilePath)
        }

        $startInfo.UseShellExecute = $true

        if ($PSCmdlet.ParameterSetName -eq 'UsingUserNamePassword') {
            if ($UserName -match '^(?<username>[^@]+)@(?<domain>.+)$' -and $UserName.Length -le 1024) {
                $startInfo.Domain = $null
                $startInfo.UserName = $UserName
                $startInfo.Password = $Password
            }
            elseif ($UserName -match '^(?<domain>[^\\]{1,15})\\(?<username>.{1,256}$') {
                $startInfo.Domain = $Matches['domain']
                $startInfo.UserName = $Matches['username']
                $startInfo.Password = $Password
            }
        }

        if ($PSBoundParameters.ContainsKey('Environment')) {
            $Environment.GetEnumerator() | ForEach-Object -Process {
                $startInfo.Environment.Add($_.Key, $_.Value)
            }
        }

        $startInfo.LoadUserProfile = $LoadUserProfile.IsPresent
        $startInfo.WindowStyle = $WindowStyle
        $startInfo.WorkingDirectory = Get-ItemProperty -LiteralPath $FilePath -Name DirectoryName

        $process = [System.Diagnostics.Process]::Start($startInfo)

        $process | Write-Output

        <#
        .SYNOPSIS
        Runs the Application or registered Data File in the GUI shell.

        .DESCRIPTION
        `Start-ShellExecute` runs the Application or registered Data File in the GUI shell.

        .PARAMETER FilePath
        Specifies the file path of the application or registered data file to execute.  This parameter is mandatory and must resolve to a path that is a 'Leaf'.

        .PARAMETER ArgumentList
        Specifies one or more arguments to pass to 'FilePath'.

        .PARAMETER Environment
        Specifies a hashtable of environment variables to add or modify before the application or registered data file starts..

        .PARAMETER LoadUserProfile
        If set, the user profile, not the PowerShell user profile, is loaded before the application or registered data file starts.

        .PARAMETER Password
        Specifies the secure string password associated with 'UserName'.

        .PARAMETER UserName
        Specifies the user name part of the 'UserName/Password' credential, both of which must be passed if credentials are required.
        If 'UserName' is a UPN, 'Domain' will be internally set to $null.  Otherwise, 'UserName' will be parsed and the Domain-part
        will be assigned to 'Domain' and the UserName-part will be assigned to 'UserName'.  All OS limitations on UPN and Windows
        login user names are enforced.

        .PARAMETER WindowsStyle
        Specifies the Windows style for the application or registered data file on startup.  The default value is 'Normal'.

        If specified, 'Confirm' is disabled unless 'Confirm' is expressly passed.

        .INPUTS
        None.  `Start-ShellExecute` does not receive any input from the PowerShell pipeline.

        .OUTPUTS
        [System.Diagnostics.Process]  `Start-ShellExecute` returns a [System.Diagnostics.Process] instance to the PowerShell pipeline.

        .EXAMPLE
        PS> Start-ShellExecute -FilePath 'C:\Windows\System32\notepad.exe' -ArgumentList 'C:\AUTOEXEC.BAT'

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINKS
        about_CommonParameters

        .LINKS
        about_Function_Advanced

        .LINKS
        Get-ItemProperty

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
        Test-PSAssemblyLoaded
##########################################>
    function Test-PSAssemblyLoaded {
        [CmdletBinding()]
        [OutputType([bool])]
        param (
            [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
            [ValidateScript({ Get-ChildItem -Path $_ | Test-Path -PathType Leaf },
                ErrorMessage = "Path '{0}' is not a valid path to an Assemlby file")]
            [SupportsWildcards()]
            [string[]]
            $Path,

            [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingCodeBase')]
            [ValidateScript({ [uri]::IsWellFormedUriString($_, 'Absolute') },
                ErrorMessage = "CodeBase '{0}' is not a valid, absolute URI to an Assembly file")]
            [Alias('Uri')]
            [string[]]
            $CodeBase,

            [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLocation')]
            [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
                ErrorMessage = "Location '{0}' is not a valid literal path to an Assembly file")]
            [Alias('LiteralPath')]
            [string[]]
            $Location,

            [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingName')]
            [ValidateNotNullOrEmpty()]
            [Alias('AssemblyName')]
            [string[]]
            $Name,

            [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingFullName')]
            [ValidateNotNullOrEmpty()]
            [string[]]
            $FullName,

            [Parameter(ParameterSetName = 'UsingPath')]
            [switch]
            $Recurse,

            [switch]
            $Trusted
        )

        BEGIN {
            Set-StrictMode -Version 3.0
            Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
        }

        PROCESS {
            switch ($PSCmdlet.ParameterSetName) {
                'UsingCodeBase' {
                    $isFullyTrusted = $false
                    $isGlobalAssemblyCache = $false
                    $isPSLoaded = $false

                    $CodeBase | ForEach-Object -Process {
                        if ((Get-PSAssemblyLoaded | Where-Object -Property CodeBase -EQ $_ | Select-Object -ExpandProperty GlobalAssemblyCache)) {
                            $isGlobalAssemblyCache = $true
                        }

                        if ((Get-PSAssemblyLoaded | Where-Object -Property CodeBase -EQ $_ | Select-Object -ExpandProperty Location)) {
                            $isPSLoaded = $true
                        }

                        if ($Trusted.IsPresent -and (Get-PSAssemblyLoaded | Where-Object -Property CodeBase -EQ $_ | Select-Object -ExpandProperty IsFullyTrusted)) {
                            $isFullyTrusted = $true
                        }
                        else {
                            $isFullyTrusted = -not $Trusted.IsPresent
                        }

                    ($isFullyTrusted) -and ($isGlobalAssemblyCache -or $isPSLoaded) | Write-Output
                    }

                    break
                }

                'UsingLocation' {
                    $isFullyTrusted = $false
                    $isGlobalAssemblyCache = $false
                    $isPSLoaded = $false

                    $Location | ForEach-Object -Process {
                        if ((Get-PSAssemblyLoaded | Where-Object -Property Location -EQ $_ | Select-Object -ExpandProperty GlobalAssemblyCache)) {
                            $isGlobalAssemblyCache = $true
                        }

                        if ((Get-PSAssemblyLoaded | Where-Object -Property Location -EQ $_ | Select-Object -ExpandProperty Location)) {
                            $isPSLoaded = $true
                        }

                        if ($Trusted.IsPresent -and (Get-PSAssemblyLoaded | Where-Object -Property Location -EQ $_ | Select-Object -ExpandProperty IsFullyTrusted)) {
                            $isFullyTrusted = $true
                        }
                        else {
                            $isFullyTrusted = -not $Trusted.IsPresent
                        }

                    ($isFullyTrusted) -and ($isGlobalAssemblyCache -or $isPSLoaded) | Write-Output
                    }

                    break
                }

                'UsingName' {
                    $Name | ForEach-Object -Process {
                        $isFullyTrusted = $false
                        $isGlobalAssemblyCache = $false
                        $isPSLoaded = $false

                        if ((Get-PSAssemblyLoaded | Where-Object -Property Name -EQ $_ | Select-Object -ExpandProperty GlobalAssemblyCache)) {
                            $isGlobalAssemblyCache = $true
                        }

                        if ((Get-PSAssemblyLoaded | Where-Object -Property Name -EQ $_ | Select-Object -ExpandProperty Location)) {
                            $isPSLoaded = $true
                        }

                        if ($Trusted.IsPresent -and (Get-PSAssemblyLoaded | Where-Object -Property Name -EQ $_ | Select-Object -ExpandProperty IsFullyTrusted)) {
                            $isFullyTrusted = $true
                        }
                        else {
                            $isFullyTrusted = -not $Trusted.IsPresent
                        }

                    ($isFullyTrusted) -and ($isGlobalAssemblyCache -or $isPSLoaded) | Write-Output
                    }

                    break
                }

                'UsingFullName' {
                    $FullName | ForEach-Object -Process {
                        $isFullyTrusted = $false
                        $isGlobalAssemblyCache = $false
                        $isPSLoaded = $false

                        $CodeBase | ForEach-Object -Process {
                            if ((Get-PSAssemblyLoaded | Where-Object -Property FullName -EQ $_ | Select-Object -ExpandProperty GlobalAssemblyCache)) {
                                $isGlobalAssemblyCache = $true
                            }

                            if ((Get-PSAssemblyLoaded | Where-Object -Property FullName -EQ $_ | Select-Object -ExpandProperty Location)) {
                                $isPSLoaded = $true
                            }

                            if ($Trusted.IsPresent -and (Get-PSAssemblyLoaded | Where-Object -Property FullName -EQ $_ | Select-Object -ExpandProperty IsFullyTrusted)) {
                                $isFullyTrusted = $true
                            }
                            else {
                                $isFullyTrusted = -not $Trusted.IsPresent
                            }

                        ($isFullyTrusted) -and ($isGlobalAssemblyCache -or $isPSLoaded) | Write-Output
                        }

                        break
                    }
                }

                default {
                    Get-ChildItem -Path $Path -File -Recurse:$Recurse.IsPresent | ForEach-Object {
                        $isFullyTrusted = $false
                        $isGlobalAssemblyCache = $false
                        $isPSLoaded = $false

                        if ((Get-PSAssemblyLoaded | Where-Object -Property Location -EQ $_.FullName | Select-Object -ExpandProperty GlobalAssemblyCache)) {
                            $isGlobalAssemblyCache = $true
                        }

                        if ((Get-PSAssemblyLoaded | Where-Object -Property Location -EQ $_.FullName | Select-Object -ExpandProperty Location)) {
                            $isPSLoaded = $true
                        }

                        if ($Trusted.IsPresent -and (Get-PSAssemblyLoaded | Where-Object -Property Location -EQ $_.FullName | Select-Object -ExpandProperty IsFullyTrusted)) {
                            $isFullyTrusted = $true
                        }
                        else {
                            $isFullyTrusted = -not $Trusted.IsPresent
                        }

                    ($isFullyTrusted) -and ($isGlobalAssemblyCache -or $isPSLoaded) | Write-Output
                    }

                    break
                }
            }
        }
    }

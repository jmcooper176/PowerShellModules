<#
 =============================================================================
<copyright file="ProcessLauncherModule.psm1" company="U.S. Office of Personnel
Management">
    Copyright (c) 2022-2025, John Merryweather Cooper.
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
<date>Created:  2025-1-27</date>
<summary>
This file "ProcessLauncherModule.psm1" is part of "ProcessLauncherModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

#requires -version 7.4
#requires -Module TypeAcceleratorModule

<#
    ProcessLauncher Class
#>
class ProcessLauncher : System.IDisposable {
    <#
        Constructors
    #>
    ProcessLauncher([string]$FilePath) {
        $this.ClassName = Initialize-PSClass -Name [ProcessLauncher].Name

        $initializeSplat = @{
            CreateNoNewWindow      = $true
            EnableRaisingEvents    = $true
            RedirectStandardError  = $true
            RedirectStandardOutput = $true
            UseShellExecute        = $false
        }

        $this.Initialize($FilePath, $initializeSplat)
    }

    ProcessLauncher([System.IO.FileInfo]$File) {
        $this.ClassName = Initialize-PSClass -Name [ProcessLauncher].Name

        $initializeSplat = @{
            CreateNoNewWindow      = $true
            EnableRaisingEvents    = $true
            RedirectStandardError  = $true
            RedirectStandardOutput = $true
            UseShellExecute        = $false
        }

        $this.Initialize($File.FullName, $initializeSplat)
    }

    ProcessLauncher([string]$FilePath, [string[]]$ArgumentList) {
        $this.ClassName = Initialize-PSClass -Name [ProcessLauncher].Name

        $initializeSplat = @{
            CreateNoNewWindow      = $true
            EnableRaisingEvents    = $true
            RedirectStandardError  = $true
            RedirectStandardOutput = $true
            UseShellExecute        = $false
        }

        $this.Initialize($FilePath, $initializeSplat)

        foreach ($arg in $ArgumentList) {
            $this.Add($arg)
        }
    }

    ProcessLauncher([System.IO.FileInfo]$File, [string[]]$ArgumentList) {
        $this.ClassName = Initialize-PSClass -Name [ProcessLauncher].Name

        $initializeSplat = @{
            CreateNoNewWindow      = $true
            EnableRaisingEvents    = $true
            RedirectStandardError  = $true
            RedirectStandardOutput = $true
            UseShellExecute        = $false
        }

        $this.Initialize($File.FullName, $initializeSplat)

        foreach ($arg in $ArgumentList) {
            $this.Add($arg)
        }
    }

    ProcessLauncher([string]$FilePath, [string]$InputFilePath, [string[]]$ArgumentList) {
        $this.ClassName = Initialize-PSClass -Name [ProcessLauncher].Name

        $initializeSplat = @{
            Input                  = $InputFilePath
            CreateNoNewWindow      = $true
            EnableRaisingEvents    = $true
            RedirectStandardError  = $true
            RedirectStandardInput  = $true
            RedirectStandardOutput = $true
            UseShellExecute        = $false
        }

        $this.Initialize($FilePath, $initializeSplat)

        foreach ($arg in $ArgumentList) {
            $this.Add($arg)
        }
    }

    ProcessLauncher([System.IO.FileInfo]$File, [System.IO.FileInfo]$InputFile, [string[]]$ArgumentList) {
        $this.ClassName = Initialize-PSClass -Name [ProcessLauncher].Name

        $initializeSplat = @{
            Input                  = $InputFile.FullName
            CreateNoNewWindow      = $true
            EnableRaisingEvents    = $true
            RedirectStandardError  = $true
            RedirectStandardInput  = $true
            RedirectStandardOutput = $true
            UseShellExecute        = $false
        }

        $this.Initialize($File.FullName, $initializeSplat)

        foreach ($arg in $ArgumentList) {
            $this.Add($arg)
        }
    }

    ProcessLauncher([string]$FilePath, [string[]]$ArgumentList, [hashtable]$Properties) {
        $this.ClassName = Initialize-PSClass -Name [ProcessLauncher].Name

        $this.Update($Properties, 'CreateNoNewWindow', $true)
        $this.Update($Properties, 'EnableRaisingEvents', $true)
        $this.Update($Properties, 'RedirectStandardError', $true)
        $this.Update($Properties, 'RedirectStandardOutput', $true)
        $this.Update($Properties, 'UseShellExecute', $false)

        $this.Initialize($FilePath, $Properties)

        foreach ($arg in $ArgumentList) {
            $this.Add($arg)
        }
    }

    <#
        Common Initializer
    #>
    [void] Initialize([string]$FileName, [hashtable]$Properties) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        $this.Timeout = [TimeSpan]::Zero
        $this.EnableRaisingEvents = $false

        if (Test-Path -LiteralPath $FileName -PathType Leaf) {
            $FileName = Resolve-Path -LiteralPath $FileName
        }
        else {
            $FileName = Get-Command -Name $FileName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path
        }

        if (-not [string]::IsNullOrEmpty($FileName)) {
            $this.startInfo = New-Object -TypeName System.Diagnostics.ProcessStartInfo -ArgumentList $FileName

            foreach ($DefinitionSplat in [ProcessLauncher]::PropertyDefinitions) {
                Update-TypeData -TypeName [ProcessLauncher].Name @DefinitionSplat
            }
        }
        else {
            $message = "$($MethodName) : The file '$($FileName)' does not exist or cannot be resolved."
            $newErrorRecordSplat = @{
                Exception    = [System.IO.FileNotFoundException]::new($message, $FileName)
                Message      = $message
                Category     = 'ObjectNotFound'
                TargetObject = $FileName
            }

            $er = New-ErrorRecord @newErrorRecordSplat
            Write-Error -ErrorRecord $er -ErrorAction Continue
            $PSCmdlet.ThrowTerminatingError($er)
        }

        $this.WorkingDirectory = $this.startInfo.WorkingDirectory

        $Properties.GetEnumerator() | ForEach-Object -Process {
            switch ($_.Key) {
                'Arguments' {
                    $this.startInfo.Arguments = $_.Value
                    break
                }

                'ArgumentList' {
                    $this.startInfo.ArgumentList.Clear()

                    foreach ($arg in $_.Value) {
                        $this.startInfo.ArgumentList.Add($arg) | Out-Null
                    }

                    break
                }

                'CreateNoNewWindow' {
                    $this.startInfo.CreateNoNewWindow = $_.Value
                    break
                }

                'Domain' {
                    if (-not [OperatingSystem]::IsWindows()) {
                        $message = "$($MethodName) : The 'Domain' property is only supported on the Windows operating systems."
                        $newErrorRecordSplat = @{
                            Exception    = [System.NotSupportedException]::new($message)
                            Message      = $message
                            Category     = 'NotSupported'
                            TargetObject = $this.startInfo.Domain
                        }

                        $er = New-ErrorRecord $newErrorRecordSplat
                        Write-Error -ErrorRecord $er -ErrorAction Continue
                        $PSCmdlet.ThrowTerminatingError($er)
                    }

                    $this.startInfo.Domain = $_.Value

                    if ([string]::IsNullOrEmpty($this.startInfo.Domain)) {
                        if (-not $this.startInfo.UserName.Contains('@')) {
                            $message = "$($MethodName) : The 'Domain' property is required when the 'UserName' property is not in UPN format."
                            $newErrorRecordSplat = @{
                                Exception    = [System.ArgumentException]::new($message, 'Domain')
                                Message      = $message
                                Category     = 'InvalidArgument'
                                TargetObject = $this.startInfo.Domain
                            }

                            $er = New-ErrorRecord @newErrorRecordSplat
                            Write-Error -ErrorRecord $er -ErrorAction Continue
                            $PSCmdlet.ThrowTerminatingError($er)
                        }
                    }

                    break
                }

                'Environment' {
                    if (-not $this.startInfo.UseShellExecute) {
                        $splitOnEquals = ($_.Value -split '=')
                        $pair = New-Object -TypeName System.Collections.Generic.KeyValuePair[string, string] -ArgumentList @($splitOnEquals[0], $splitOnEquals[1])
                        $this.startInfo.Environment.Add($pair)
                    }
                    else {
                        Write-Warning -Message "$($MethodName) : The 'Environment' property can only be updated when the 'UseShellExecute' property is set to $false."
                    }

                    break
                }

                'EnableRaisingEvents' {
                    $this.EnableRaisingEvents = $_.Value
                    break
                }

                'EnvironmentVariables' {
                    if (-not $this.startInfo.UseShellExecute) {
                        $splitOnEquals = ($_.Value -split '=')
                        $this.startInfo.EnvironmentVariables.Add($splitOnEquals[0], $splitOnEquals[1])
                    }
                    else {
                        Write-Warning -Message "$($MethodName) : The 'EnvironmentVariables' property can only be updated when the 'UseShellExecute' property is set to $false."
                    }

                    break
                }

                'Error' {
                    Write-Warning -Message "$($MethodName) : The 'Error' property is read-only."
                    break
                }

                'ErrorDialog' {
                    $this.startInfo.ErrorDialog = $_.Value
                    break
                }

                'ErrorDialogParentHandle' {
                    if ($this.startInfo.ErrorDialog) {
                        $this.startInfo.ErrorDialogParentHandle = $_.Value
                    }
                    else {
                        Write-Warning -Message "$($MethodName) : The 'ErrorDialogParentHandle' property can only be updated when the 'ErrorDialog' property is set to $true."
                    }

                    break
                }

                'FileName' {
                    Write-Warning -Message "$($MethodName) : The 'FileName' property is passed as a parameter only."
                    break
                }

                'Input' {
                    if (Test-Path -LiteralPath $_.Value -PathType Leaf) {
                        $this.startInfo.Input = $_.Value
                    }
                    else {
                        $message = "$($MethodName) : The input file '$($_.Value)' does not exist or cannot be resolved."
                        $newErrorRecordSplat = @{
                            Exception    = [System.IO.FileNotFoundException]::new($message, $_.Value)
                            Message      = $message
                            Category     = 'ObjectNotFound'
                            TargetObject = $_.Value
                        }

                        $er = New-ErrorRecord @newErrorRecordSplat
                        Write-Error -ErrorRecord $er -ErrorAction Continue
                        $PSCmdlet.ThrowTerminatingError($er)
                    }

                    break
                }

                'LoadUserProfile' {
                    $this.startInfo.LoadUserProfile = $_.Value
                    break
                }

                'Output' {
                    Write-Warning -Message "$($MethodName) : The 'Output' property is read-only."
                    break
                }

                'Password' {
                    $this.startInfo.Password = $_.Value
                    break
                }

                'PasswordInClearText' {
                    Write-Warning -Message "$($MethodName) : The 'PasswordInClearText' property is a security vulnerability.  Use the 'Password' property instead."
                    $this.startInfo.PasswordInClearText = $_.Value
                    break
                }

                'RedirectStandardError' {
                    $this.startInfo.RedirectStandardError = $_.Value
                    break
                }

                'RedirectStandardInput' {
                    $this.startInfo.RedirectStandardInput = $_.Value
                    break
                }

                'RedirectStandardOutput' {
                    $this.startInfo.RedirectStandardOutput = $_.Value
                    break
                }

                'StandardErrorEncoding' {
                    $this.startInfo.StandardErrorEncoding = $_.Value
                    break
                }

                'StandardInputEncoding' {
                    $this.startInfo.StandardInputEncoding = $_.Value
                    break
                }

                'StandardOutputEncoding' {
                    $this.startInfo.StandardOutputEncoding = $_.Value
                    break
                }

                'UseCredentialsForNetworkingOnly' {
                    $this.startInfo.UseCredentialsForNetworkingOnly = $_.Value
                    break
                }

                'UserName' {
                    $this.startInfo.UserName = $_.Value

                    if (-not [string]::IsNullOrEmpty($this.startInfo.UserName)) {
                        Write-Warning -Message "$($MethodName) : The 'UserName' property is forcing the 'UseShellExecute' property to $false."
                        $this.startInfo.UseShellExecute = $false
                    }

                    break
                }

                'Verb' {
                    $this.startInfo.Verb = $_.Value
                    break
                }

                'Verbs' {
                    Write-Warning -Message "$($MethodName) : The 'Verbs' property is read-only."
                    break
                }

                'WindowStyle' {
                    $this.startInfo.WindowStyle = $_.Value
                    break
                }

                'WorkingDirectory' {
                    if (-not $this.startInfo.UseShellExecute) {
                        $this.WorkingDirectory = $_.Value
                    }
                    else {
                        Write-Warning -Message "$($MethodName) : The 'WorkingDirectory' property can only be updated when the 'UseShellExecute' property is set to $false."
                    }

                    break
                }

                default {
                    $message = "$($MethodName) : The property '$($_.Key)' is not supported."
                    $newErrorRecordSplat = @{
                        Exception    = [System.Management.Automation.PSArgumentException]::new($message, $_.Key)
                        Message      = $message
                        Category     = 'InvalidArgument'
                        TargetObject = $_.Key
                    }

                    $er = New-ErrorRecord @newErrorRecordSplat
                    Write-Error -ErrorRecord $er -ErrorAction Continue
                    $PSCmdlet.ThrowTerminatingError($er)
                }
            }
        }

        if ($this.startInfo.RedirectStartError) {
            $this.Error = New-Object -TypeName System.Text.StringBuilder
        }

        if ($this.startInfo.RedirectStandardOutput) {
            $this.Output = New-Object -TypeName System.Text.StringBuilder
        }
    }

    <#
        Public Properties
    #>
    [string]$ClassName = [ProcessLauncher].Name
    [bool]$EnableRaisingEvents
    [System.Text.StringBuilder]$Error
    [string]$Input
    [System.Text.StringBuilder]$Output
    [TimeSpan]$Timeout

    <#
        Public Script Property Definitions
    #>
    static [hashtable[]] $PropertyDefinitions = @(
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'Count'
            Value      = { $this.startInfo.ArgumentList.Count }
        }

        @{
            MemberType = 'ScriptProperty'
            MemberName = 'Items'
            Value      = { $this.startInfo.ArgumentList.Items }
        }

        @{
            MemberType = 'ScriptProperty'
            MemberName = 'Verbs'
            Value      = { $this.startInfo.Verbs }
        }
    )

    <#
        Private Properties
    #>
    hidden [bool]$disposed = $false
    hidden [System.Diagnostics.Process]$processLauncher
    hidden [System.Diagnostics.ProcessStartInfo]$startInfo

    <#
        Public Methods
    #>
    [void]Add([string]$Argument) {
        Initialize-PSMethod -MyInvocation $MyInvocation

        $this.startInfo.ArgumentList.Add($Argument) | Out-Null
    }

    [void]AddRange([string[]]$Arguments) {
        Initialize-PSMethod -MyInvocation $MyInvocation

        foreach ($arg in $Arguments) {
            $this.startInfo.ArgumentList.Add($arg) | Out-Null
        }
    }

    [void]clear() {
        Initialize-PSMethod -MyInvocation $MyInvocation

        $this.startInfo.ArgumentList.Clear()
    }

    [bool]Contains([string]$Argument) {
        Initialize-PSMethod -MyInvocation $MyInvocation

        return $this.startInfo.ArgumentList.Contains($Argument)
    }

    [void]CopyTo([string[]]$Array, [int]$Index) {
        Initialize-PSMethod -MyInvocation $MyInvocation

        $this.startInfo.ArgumentList.CopyTo($Array, $Index)
    }

    [void]Dispose() {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if (-not $this.disposed) {
            $this.startInfo.Dispose()
            $this.process.Dispose()
            $this.disposed = $true
        }
        else {
            Write-Warning -Message "$($MethodName) : The '$([ProcessLauncher].Name)' object has already been disposed."
        }
    }

    [int]IndexOf([string]$Argument) {
        Initialize-PSMethod -MyInvocation $MyInvocation

        return $this.startInfo.ArgumentList.IndexOf($Argument)
    }

    [void]Insert([int]$Index, [string]$Argument) {
        Initialize-PSMethod -MyInvocation $MyInvocation

        $this.startInfo.ArgumentList.Insert($Index, $Argument)
    }

    [bool]Remove([string]$Argument) {
        Initialize-PSMethod -MyInvocation $MyInvocation

        return $this.startInfo.ArgumentList.Remove($Argument)
    }

    [void]RemoveAt([int]$Index) {
        Initialize-PSMethod -MyInvocation $MyInvocation

        $this.startInfo.ArgumentList.RemoveAt($Index)
    }

    [void]SetItem([int]$Index, [string]$Argument) {
        Initialize-PSMethod -MyInvocation $MyInvocation

        $this.startInfo.ArgumentList[$Index] = $Argument
    }

    [void]SetTimeout([int]$Milliseconds) {
        Initialize-PSMethod -MyInvocation $MyInvocation

        $this.Timeout = [TimeSpan]::FromMilliseconds($Milliseconds)
    }

    [string]ToString() {
        Initialize-PSMethod -MyInvocation $MyInvocation

        return ($this.startInfo.ArgumentList -join ' ')
    }

    [int]Run() {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        $this.processLauncher = [System.Diagnostics.Process]::Start($this.startInfo)
        $this.processLauncher.EnableRaisingEvents = $this.EnableRaisingEvents

        if ($this.startInfo.RedirectStandardOutput -and $this.EnableRaisingEvents) {
            $this.OutputDataReceived += [System.Diagnostics.DataReceivedEventHandler]::new($this.TheProcess_OutputDataReceived)
            $this.processLauncher.BeginOutputReadLine()
        }
        elseif ($this.startInfo.RedirectStandardOutput) {
            while (-not $this.processLauncher.StandardOutput.EndOfStream) {
                $this.Output.AppendLine($this.processLauncher.StandardOutput.ReadLine())
            }
        }
        else {
            Write-Verbose -Message "$($MethodName) : No output processing logged from standard output.  All output to console."
        }

        if ($this.startInfo.RedirectStandardError -and $this.EnableRaisingEvents) {
            $this.ErrorDataReceived += [System.Diagnostics.DataReceivedEventHandler]::new($this.TheProcess_ErrorDataReceived)
            $this.processLauncher.BeginErrorReadLine()
        }
        elseif ($this.startInfo.RedirectStandardError) {
            while (-not $this.processLauncher.StandardError.EndOfStream) {
                $this.Error.AppendLine($this.processLauncher.StandardError.ReadLine())
            }
        }
        else {
            Write-Verbose -Message "$($MethodName) : No output processing logged from standard error.  All output to console."
        }

        if ($this.EnableRaisingEvents) {
            $this.processLauncher.Exited += [System.EventHandler]::new($this.TheProcess_Exited)
            $this.Timeout = [TimeSpan]::Zero
        }
        else {
            Write-Verbose -Message "$($MethodName) : No exit events will be raised for the process '$($this.processLauncher.Id)'."
        }

        if ($this.Timeout -eq [TimeSpan]::Zero) {
            $this.processLauncher.WaitForExit()
        }
        else {
            $this.processLauncher.WaitForExit($this.Timeout)

            if (-not $this.processLauncher.HasExited) {
                Write-Warning -Message "$($MethodName) : The process '$($this.processLauncher.Id)' timed out and will be killed."
                $this.Process.Kill()
            }
        }

        if ($this.process.ExitCode -eq 0) {
            Write-Verbose -Message "$($MethodName) : ProcessLauncher '$($this.processLauncher.Id)' exited with '$($this.processLauncher.ExitCode)' which is interpreted as success"
        }
        else {
            $formattedExitCode = ('0x{0:X8}|{0}' -f $this.processLauncher.ExitCode)
            Write-Warning -Message "$($MethodName) : ProcessLauncher '$($this.processLauncher.Id)' exited with '$($formattedExitCode) which is interpreted as failure"
        }

        return $this.processLauncher.ExitCode
    }

    [void]WriteErrorStream() {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($this.Error.Length -gt 0) {
            foreach ($line in ($this.Error.ToString() -split [Environment]::NewLine)) {
                if ($line.Contains('error', [StringComparison]::InvariantCultureIgnoreCase)) {
                    Write-Error -Message $line -Category FromStdErr -TargetObject $line
                }
                elseif ($line.Contains('warn', [StringComparison]::InvariantCultureIgnoreCase)) {
                    Write-Warning -Message $line
                }
                else {
                    Write-Information -MessageData $line -InformationAction Continue -Tags @([ProcessLauncher].Name, 'StdErr', 'Error')
                }
            }
        }
        else {
            Write-Verbose -Message "$($MethodName) : No output logged from standard error"
        }
    }

    [void]WriteOutputStream() {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($this.Output.Length -gt 0) {
            foreach ($line in ($this.Error.ToString() -split [Environment]::NewLine)) {
                Write-Information -MessageData $line -InformationAction Continue -Tags @([ProcessLauncher].Name, 'StdOut', 'Output')
            }
        }
        else {
            Write-Warning -Message "$($MethodName) : No output logged from standard output"
        }
    }

    <#
        Public Static Methods
    #>
    static [void]Update([hashtable]$Properties, [string]$Key, [object]$Value) {
        Initialize-PSMethod -MyInvocation $MyInvocation

        if ($Properties.ContainsKey($Key)) {
            $Properties[$Key] = $Value
        }
        else {
            $Properties.Add($Key, $Value)
        }
    }

    <#
            Private Event Handlers
    #>
    hidden [void]TheProcess_Exited([object]$sender, [System.EventArgs]$e) {
        while (-not $sender.StandardOutput.EndOfStream) {
            $this.Output.AppendLine($sender.StandardOutput.ReadLine())
        }

        while (-not $sender.StandardError.EndOfStream) {
            $this.Error.AppendLine($sender.StandardError.ReadLine())
        }

        $this.Dispose()
    }

    hidden [void]TheProcess_ErrorDataReceived([object]$sender, [System.Diagnostics.DataReceivedEventArgs]$e) {
        if (-not [string]::IsNullOrEmpty($e.Data)) {
            $this.Error.AppendLine($e.Data)
        }
    }

    hidden [void]TheProcess_OutputDataReceived([object]$sender, [System.Diagnostics.DataReceivedEventArgs]$e) {
        if (-not [string]::IsNullOrEmpty($e.Data)) {
            $this.Output.AppendLine($e.Data)
        }
    }
} # class ProcessLauncher end

<#
    Import-Module supporting Constructor
#>
function New-ProcessLauncher {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([ProcessLauncher])]
    param ()

    $CmdletName = Initialize-PSCmdlet -Invocation $MyInvocation

    if ($PSCmdlet.ShouldProcess("[ProcessLauncher] with default constructor", $CmdletName)) {
        [ProcessLauncher]::new() | Write-Output
    }
}

# Initialize this type with TypeAccelerator
$newTypeAcceleratorSlat = @{
    ExportedTypes = ([System.Type[]]@([ProcessLauncher]))
    Response      = ([ErrorResponseType]::Error -bor [ErrorResponseType]::NonTerminatingErrorOn)
}

New-TypeAccelerator @newTypeAccelerator

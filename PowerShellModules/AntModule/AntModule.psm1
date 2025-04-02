<#
 =============================================================================
<copyright file="AntModule.psm1" company="John Merryweather Cooper
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
<date>Created:  2024-9-12</date>
<summary>
This file "AntModule.psm1" is part of "AntModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# using module CommandLine
# using module ProcessLauncher

<#
 =============================================================================
<copyright file="AntModule.psm1" company="John Merryweather Cooper
">
    Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights
    Reserved.

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
<date>Created:  2024-3-8</date>
<summary>
This file "AntModule.psm1" is part of "PSInstallCom.Utility".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<###########################################
    Get-AntPath
##########################################>
function Get-AntPath {
    [CmdletBinding()]
    param ()

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    # search on the path
    $antPath = Get-Command -Name 'ant.exe' -CommandType Application | Select-Object -ExpandProperty Path

    # search on ANT_HOME
    if (-not (Test-Path -Path $antPath -PathType Leaf)) {
        $antPath = Join-Path -Path $env:ANT_HOME -ChildPath 'bin' -AdditionalChildPath 'ant.exe'
    }

    # default to fileName
    if (-not (Test-Path -Path $antPath -PathType Leaf)) {
        $antPath = 'ant.exe'
    }

    $antPath | Write-Output

    <#
        .SYNOPSIS
        Get the path to the ANT executable.

        .DESCRIPTION
        Get the path to the ANT executable.

        .INPUTS
        None.  `Get-AntPath` takes not input from the pipeline.

        .OUTPUTS
        [System.String].  The path to the ANT executable.

        .EXAMPLE

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}

function Start-Ant {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "BuildFile '{0}' is not a valid path leaf")]
        [string]
        $BuildFile,

        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "LibPath '{0}' is not a valid path container")]
        [string]
        $LibPath,

        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid },
            ErrorMessage = "LogPath '{0}' is not a valid path container")]
        [string]
        $LogPath,

        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "PropertiesFile '{0}' is not a valid path leaf")]
        [string]
        $PropertyFile,

        [AllowNull()]
        [hashtable]
        $Defines,

        [AllowNull()]
        [string[]]
        $Targets,

        [int[]]
        $Success = 0,

        [switch]
        $Quiet,

        [switch]
        $Silent,

        [switch]
        $Emacs,

        [switch]
        $NoInput,

        [switch]
        $KeepGoing,

        [switch]
        $NoUserLib,

        [switch]
        $NoClassPath,

        [switch]
        $AutoProxy
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $cmdLine = New-Object -TypeName CommandLine

    if ($null -ne $Defines -and $Defines.Count -gt 0) {
        $Defines.GetEnumerator() | ForEach-Object -Process {
            $cmdLine.AppendSwitch('-D')
            $cmdLine.AppendTextWithQuoting("{0}={1}" -f $_.Key, $_.Value)
            $cmdLine.AppendSpaceIfNotEmpty()
        }
    }

    if ($Quiet.IsPresent) {
        $cmdLine.AppendSwitch('-quiet')
    }

    if ($Silent.IsPresent) {
        $cmdLine.AppendSwitch('-silent')
    }

    if (Test-PSParameter -Name 'Verbose' -Parameters $PSBoundParameters) {
        $cmdLine.AppendSwitch('-verbose')
    }

    if (Test-PSParameter -Name 'Debug' -Parameters $PSBoundParameters) {
        $cmdLine.AppendSwitch('-Debug')
    }

    if ($Emacs.IsPresent) {
        $cmdLine.AppendSwitch('-emacs')
    }

    if (Test-PSParameter -Name 'LibPath' -Parameters $PSBoundParameters) {
        $cmdLine.AppendSwitch('-lib')
        $cmdLine.AppendFileNameIfNotNull($LibPath)
    }

    if (Test-PSParameter -Name 'LogPath' -Parameters $PSBoundParameters) {
        $cmdLine.AppendSwitch('-logfile')
        $cmdLine.AppendFileNameIfNotNull($LogPath)
    }

    if (Test-PSParameter -Name 'PropertyFile' -Parameters $PSBoundParameters) {
        $cmdLine.AppendSwitch('-propertyfile')
        $cmdLine.AppendFileNameIfNotNull($PropertyFile)
    }

    if (Test-PSParameter -Name 'BuildFile' -Parameters $PSBoundParameters) {
        $cmdLine.AppendSwitch('-buildfile')
        $cmdLine.AppendFileNameIfNotNull($BuildFile)
    }

    if ($NoInput.IsPresent) {
        $cmdLine.AppendSwitch('-noinput')
    }

    if ($KeepGoing.IsPresent) {
        $cmdLine.AppendSwitch('-keep-going')
    }

    if ($NoUserLib.IsPresent) {
        $cmdLine.AppendSwitch('-nouserlib')
    }

    if ($NoClassPath.IsPresent) {
        $cmdLine.AppendSwitch('-noclasspath')
    }

    if ($AutoProxy.IsPresent) {
        $cmdLine.AppendSwitch('-autoproxy')
    }

    if ($null -ne $Targets -and $Targets.Length -gt 0) {
        $Targets | ForEach-Object -Process {
            $cmdLine.AppendSpaceIfNotEmpty()
            $cmdLine.AppendTextUnquoted($_)
        }
    }

    $antProcess = New-Object -TypeName ProcessLauncher -ArgumentList (Get-AntPath), $cmdLine.ToString()
    $exitCode = $antProcess.Run()

    if ($Success -contains $exitCode) {
        $true | Write-Output
    }
    else {
        $false | Write-Output
    }

    <#
        .SYNOPSIS
        Start the ANT build process.

        .DESCRIPTION
        Start the ANT build process.

        .PARAMETER BuildXmlPath
        The path to the build.xml file.

        .PARAMETER Defines
        The key-value pairs to define.

        .PARAMETER Target
        The target to build.

        .PARAMETER Success
        The success code(s).

        .INPUTS
        None.  `Start-Ant` takes not input from the pipeline.

        .OUTPUTS
        [System.Boolean].  The success of the build.

        .EXAMPLE

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        Get-AntPath
    ##########################################>
}

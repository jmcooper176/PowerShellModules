<#
 =============================================================================
<copyright file="Write-ChangeLog.ps1" company="John Merryweather Cooper
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
This file "Write-ChangeLog.ps1" is part of "Write-ChangeLog".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#PSScriptInfo

    .VERSION 1.0.0

    .GUID 0FDC4220-823B-42F6-B059-30F9607A09D5

    .AUTHOR John Merryweather Cooper

    .COMPANYNAME John Merryweather Cooper

    .COPYRIGHT Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

    .TAGS write git change log markdown

    .LICENSEURI https://www.opensource.org/licenses/BSD-3-Clause

    .PROJECTURI https://github.com/jmcooper176/PowerShellModules/Write-ChangeLog

    .ICONURI

    .EXTERNALMODULEDEPENDENCIES PowerShellModule GitModule

    .REQUIREDSCRIPTS

    .EXTERNALSCRIPTDEPENDENCIES

    .RELEASENOTES

    .PRIVATEDATA

#>

#requires -Module GitModule
#requires -Module PowerShellModule

<#
    .SYNOPSIS
    Writes a change log to a file path.

    .DESCRIPTION
    The `Write-ChangeLog.ps1` script writes a change log to a file path.  The change log is written in markdown format and echoed
    to standard output.

    .PARAMETER FilePath
    Specifies the path to the file to write the change log.  The default value is the value of the environment variable CHANGELOG_PATH.

    .PARAMETER Channel
    Specifies the channel for the change log.  The default value is 'DEV'.

    .INPUTS
    None.  `Write-ChangeLog` does not accept pipeline input.

    .OUTPUTS
    None.  `Write-ChangeLog` does not generate any output.  It does generate a log written or appended to `FilePath`.

    .EXAMPLE
    PS> .\Write-ChangeLog.ps1 -FilePath '..\CHANGELOG.md' -Verbose

    VERBOSE: Performing the operation "Write-ChangeLog.ps1" on target "Writing Title".
    # DEV CHANGE LOG
    VERBOSE: Performing the operation "Write-ChangeLog.ps1" on target "Writing Clone URL".
    ## Clone URL:  <https://github.com/OPM-OCIO-FITBS-HRSITPMO-USAJOBS/SFS-Main.git>
    VERBOSE: Performing the operation "Write-ChangeLog.ps1" on target "Create or Append to Git Log Data File".
    * commit 63582d1fe704acf76d1cc1d211d53f0d7cebc0ef
    | Author: Cooper, John M. (CTR) <jmcooper8654@gmail.com>
    | Date:   Fri Jan 10 00:30:03 2025 -0600
    |
    |     Fixup Container Classes
    |
    * commit 0022b87714f5b49c53eaccec6eb60603adf62b8e
    | Author: Cooper, John M. (CTR) <jmcooper8654@gmail.com>
    | Date:   Fri Jan 10 00:07:09 2025 -0600
    |
    |     Fix TypeAcceleratorModule
    |
    * commit d3db7279b975763691a5cb7a714eb056576302f1
    | Author: Cooper, John M. (CTR) <jmcooper8654@gmail.com>
    | Date:   Fri Jan 10 00:04:20 2025 -0600
    |
    |     Cleanup
    |
    * commit 6185fe770553ca569976fc7812dca3e07c5328d0
    | Author: Cooper, John M. (CTR) <jmcooper8654@gmail.com>
    | Date:   Thu Jan 9 23:23:40 2025 -0600
    |

    * * *

    .NOTES
    Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

    .LINK
    about_CommonParameters

    .LINK
    about_Functions_Advanced

    .LINK
    Get-GitFormattedLog

    .LINK
    Set-StrictMode

    .LINK
    Set-Variable

    .LINK
    Test-Path

    .LINK
    Test-Uri

    .LINK
    Write-ChangeLog

    .LINK
    Write-ChangeLogHeader

    .LINK
    Write-Output

    .LINK
    Write-Verbose
#>

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -IsValid },
        ErrorMessage = "FilePath '{0}' is not a valid path leaf")]
    [string]
    $FilePath,

    [ValidateSet('DEV', 'Development', 'TST', 'Test', 'UAT', 'UserAcceptanceTesting', 'STG', 'Staging', 'PRD', 'Production')]
    [string]
    $Channel = 'DEV'
)

<##########################################
    Functions
##########################################>

<##########################################
    Write-ChangeLog
##########################################>
function Write-ChangeLog {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'UsingFilePath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingFilePath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid },
            ErrorMessage = "FilePath '{0}' is not a valid path leaf")]
        [string]
        $FilePath,

        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [string[]]
        $Content,

        [Parameter(ParameterSetName = 'UsingVariable')]
        [ValidateNotNullOrEMpty()]
        [string]
        $Variable
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if (($null -eq $Content) -or ($Content.Length -lt 1)) {
            if ($PSCmdlet.ShouldProcess('Appending NewLine to Content File', $CmdletName)) {
                if ($PSCmdlet.ParameterSetName -eq 'UsingVariable') {
                    [System.Environment]::NewLine | Tee-Object -Variable $Variable | Write-Output
                }
                else {
                    [System.Environment]::NewLine | Tee-Object -FilePath $FilePath -Append -Encoding 'utf8' | Write-Output
                }
            }
        }
        elseif (($PSCmdlet.ParameterSetName -eq 'UsingFilePath') -and (Test-Path -LiteralPath $FilePath -PathType Leaf)) {
            if ($PSCmdlet.ShouldProcess('Appending to Content File', $CmdletName)) {
                $Content | Tee-Object -FilePath $FilePath -Append -Encoding 'utf8' | Write-Output
            }
        }
        else {
            if ($PSCmdlet.ShouldProcess('Creating Content File or Variable', $CmdletName)) {
                if ($PSCmdlet.ParameterSetName -eq 'UsingVariable') {
                    $Content | Tee-Object -Variable $Variable | Write-Output
                }
                else {
                    $Content | Tee-Object -FilePath $FilePath -Encoding 'utf8' | Write-Output
                }
            }
        }
    }

    <#
        .SYNOPSIS
        Writes a change log to a file path.

        .DESCRIPTION
        `Write-ChangeLog` writes a change log to a file path.  The change log is written in markdown format and echoed to standard output.

        .PARAMETER FilePath
        Specifies the path to the file to write or append the change log.

        .PARAMETER Content
        Specifies the content to write or append to `FilePath`.  Content maybe null or empty, in which case a newline is appended to `FilePath`.

        .PARAMETER Variable
        Specifies the variable to store the content instead of writing it to `FilePath`.

        .INPUTS
        [string].  `Write-ChangeLog` content as a string array from the PowerShell pipeline as input.

        .OUTPUTS
        None.  `Write-ChangeLog` does not output to the pipeline.  It writes or appends it's output to `FilePath`.

        .EXAMPLE
        PS> $Content = @('This is a change log entry', 'This is another change log entry')
        PS> $Content | Write-ChangeLog -FilePath $FilePath

        This is a change log entry
        This is another change log entry

        The two lines are written or appended to $FilePath and echoed to standard output.

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Tee-Object

        .LINK
        Write-Output
    #>
}

<##########################################
    Write-ChangeLogHeader
##########################################>
function Write-ChangeLogHeader {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'UsingFilePath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingFilePath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid },
            ErrorMessage = "FilePath '{0}' is not a valid path leaf")]
        [string]
        $FilePath,

        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Header,

        [Parameter(Mandatory, ParameterSetName = 'UsingVariable')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Variable,

        [ValidateRange(1, 127)]
        [int]
        $Level = 1
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($Header -match '(.*)(https://.*)') {
            $Header = ('{0}<{1}>' -f $Matches[1], $Matches[2])
        }

        if ($PSCmdlet.ShouldProcess($Header, $CmdletName)) {
            if ([string]::IsNullOrWhiteSpace($Header)) {
                $Header = $null
            }
            elseif ($Level -eq 1) {
                $Header = ('# {0}' -f $Header)
            }
            else {
                $Header = ('{0} {1}' -f ('#' * $Level), $Header)
            }

            if ($PSCmdlet.ParameterSetName -eq 'UsingVariable') {
                $Header | Write-ChangeLog -Variable $Variable | Write-Output
            }
            else {
                $Header | Write-ChangeLog -FilePath $FilePath | Write-Output
            }
        }
    }

    <#
        .SYNOPSIS
        Writes a change log header to the file path.

        .DESCRIPTION
        `Write-ChangeLogHeader` writes a change log header to the file path.  It appends markdown formatted text to `FilePath`.

        .PARAMETER FilePath
        Specifies the path to the file to write the header.

        .PARAMETER Variable
        Specifies the variable to store the header instead of writing it to `FilePath`.

        .PARAMETER Header
        Specifies the header to write to `FilePath`.

        .PARAMETER Level
        Specifies the indentatino level of the header.  The default value is 1.

        .INPUTS
        None.  `Write-ChangeLogHeader` does not accept pipeline input.

        .OUTPUTS
        None.  `Write-ChangeLogHeader` does not output to the pipeline.  It appends the header to `FilePath`.

        .EXAMPLE
        PS> $Header = 'This is a change log header'
        PS> Write-ChangeLogHeader -Header $Header -FilePath $FilePath

        # This is a change log header

        Appends the level one header to $FilePath.

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced
    #>
}

<##########################################
    Script
##########################################>
$ScriptFIle = Initialize-PSScript -MyInvocation $MyInvocation

if ($MyInvocation.InvocationName -ne '.') {
    $ScriptFIle = Initialize-PSScript -MyInvocation $MyInvocation

    $RepositoryName = Get-GitRepositoryName

    if ($PSCmdlet.ShouldProcess('Writing Title', $ScriptFile)) {
        Write-ChangeLogHeader -FilePath $FilePath -Header "$Channel CHANGE LOG for $RepositoryName" -Level 1 | Write-Output
        $null | Write-ChangeLog -FilePath $FilePath | Write-Output
    }

    if ($PSCmdlet.ShouldProcess('Writing Clone URL', $ScriptFile)) {
        $Source = Get-GitRepositoryUrl
        Write-ChangeLogHeader -FilePath $FilePath -Header "Clone URL:  $Source" -Level 2 | Write-Output
        $null | Write-ChangeLog -FilePath $FilePath | Write-Output
    }

    if ($PSCmdlet.ShouldProcess("Create or Append to Git Log Data File", $ScriptFile)) {
        Get-GitFormattedLog | Write-ChangeLog -FilePath $FilePath | Write-Output
        $null | Write-ChangeLog -FilePath $FilePath | Write-Output
    }
}
else {
    $FilePath = '.\CHANGELOG.md'
    Write-Warning -Message "$($criptFile) : This script has been dot-sourced, and should only be under test."
}

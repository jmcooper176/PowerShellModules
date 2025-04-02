<#
 =============================================================================
<copyright file="GitModule.psm1" company="John Merryweather Cooper
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
<date>Created:  2025-1-27</date>
<summary>
This file "GitModule.psm1" is part of "GitModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<##########################################
    Get-GitBranchRemote
##########################################>
function Get-GitBranchRemote {
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "WorkingDirectory '{0}' is not a valid path container")]
        [string]
        $WorkingDirectory = $PWD,

        [switch]
        $Local
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    Push-Location $WorkingDirectory

    if ($Local.IsPresent) {
        & git branch --remotes |
            ForEach-Object -Process { ($_ -replace 'origin/').Trim() | Where-Object -FilterScript { $_ -notmatch '^.*\-\>.*$' } | Write-Output }
    }
    else {
        & git branch --remotes | ForEach-Object -Process { $_ | Where-Object -FilterScript { $_ -notmatch '^.*\-\>.*$' } | Write-Output }
    }

    Pop-Location
}

<##########################################
    Get-GitShow
##########################################>
function Get-GitShow {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Branch = 'main',

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Format,

        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "WorkingDirectory '{0}' is not a valid path container")]
        [string]
        $WorkingDirectory = $PWD
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        Push-Location $WorkingDirectory
        $currentBranch = Get-GitBranch -WorkingDirectory $WorkingDirectory
    }

    PROCESS {
        $Branch | ForEach-Object -Process {
            & git checkout $_ | Out-Null
            & git show "--format='$($Format)'" | ForEach-Object -Process { $_ | Write-Output }
        }
    }

    END {
        & git checkout $currentBranch | Out-Null
        Pop-Location
    }
}

<##########################################
    Get-GitRevisionParse
##########################################>
function Get-GitRevisionParse {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "WorkingDirectory '{0}' is not a valid path container")]
        [string]
        $WorkingDirectory = $PWD,

        [switch]
        $AbbreviateReference,

        [switch]
        $Short,

        [switch]
        $ShowTopLevel
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    Push-Location $WorkingDirectory

    if ($AbbreviateReference.IsPresent) {
        & git rev-parse --abbrev-ref HEAD | Write-Output
    }
    elseif ($Short.IsPresent) {
        & git rev-parse --short HEAD | Write-Output
    }
    elseif ($ShowTopLevel.IsPresent) {
        & git rev-parse --show-toplevel | Write-Output
    }
    else {
        & git rev-parse HEAD | Write-Output
    }

    Pop-Location
}

<##########################################
    Get-GitAuthorHead
##########################################>
function Get-GitAuthorHead {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Branch = 'main',

        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "WorkingDirectory '{0}' is not a valid path container")]
        [string]
        $WorkingDirectory = $PWD
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $Branch | ForEach-Object -Process {
            Get-GitBranchRemote -WorkingDirectory $WorkingDirectory -Local |
                Where-Object -FilterScript { $_ -ne 'HEAD' } |
                Get-GitShow -Format '%an' -WorkingDirectory $WorkingDirectory |
                Select-Object -First 1 } |
                Write-Output
    }

    <#
        .SYNOPSIS
        Gets the Git author at HEAD from the specified branch.

        .DESCRIPTION
        `Get-GitAuthorHead` gets the Git author at HEAD from the specified branch.

        .PARAMETER Branch
        Specifies the branch to get the author from.  Defaults to 'main'.

        .INPUTS
        [string[]]  `Get-GitAuthorHead` accepts a string array of branch names.

        .OUTPUTS
        [string]  `Get-GitAuthorHead` returns the Git author for the specified branch.

        .EXAMPLE
        PS> Get-GitAuthorHead

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Invoke-ToolCommandLine

        .LINK
        Select-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Sort-Object

        .LINK
        Where-Object

        .LINK
        Write-Output
    #>
}

<##########################################
    Get-GitAuthorDateHead
##########################################>
function Get-GitAuthorDateHead {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Branch = 'main',

        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "WorkingDirectory '{0}' is not a valid path container")]
        [string]
        $WorkingDirectory = $PWD
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $Branch | ForEach-Object -Process {
            Get-GitBranchRemote -WorkingDirectory $WorkingDirectory -Local |
                Where-Object -FilterScript { $_ -ne 'HEAD' } |
                Get-GitShow -Format '%ad' |
                Select-Object -First 1 } |
                Write-Output
    }

    <#
        .SYNOPSIS
        Gets the Git author date at HEAD from the specified branch.

        .DESCRIPTION
        `Get-GitAuthorHead` gets the Git author date at HEAD from the specified branch.

        .PARAMETER Branch
        Specifies the branch to get the author from.  Defaults to 'main'.

        .INPUTS
        [string[]]  `Get-GitAuthorDateHead` accepts a string array of branch names.

        .OUTPUTS
        [string]  `Get-GitAuthorDateHead` returns the Git author for the specified branch.

        .EXAMPLE
        PS> Get-GitAuthorDateHead

        2025-01-27 12:00:00

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Invoke-ToolCommandLine

        .LINK
        Select-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Sort-Object

        .LINK
        Where-Object

        .LINK
        Write-Output
    #>
}

<##########################################
    Get-GitCommitMetadata
##########################################>
function Get-GitCommitMetadata {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Get-ChildItem -Path $_ -Recurse | Test-Path -PathType 'Leaf' },
            ErrorMessage = "Path '{0}' is not a valid path leaf")]
        [AllowWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType 'Leaf' },
            ErrorMessage = "LiteralPath '{0}' is not a valid path leaf")]
        [string[]]
        $LiteralPath,

        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "WorkingDirectory '{0}' is not a valid path container")]
        [string]
        $WorkingDirectory = $PWD
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq "UsingLiteralPath") {
            $LiteralPath | ForEach-Object -Process {
                Get-Item -LiteralPath $_ |
                    Get-GitRepositoryMetadata -WorkingDirectory $WorkingDirectory |
                    Select-Object -ExpandProperty CommitMetadata |
                    Write-Output
                }
            }
            else {
                $Path | Resolve-Path | ForEach-Object -Process {
                    Get-Item -Path $_ |
                        Get-GitRepositoryMetadata -WorkingDirectory $WorkingDirectory |
                        Select-Object -ExpandProperty CommitMetadata |
                        Write-Output
                    }
                }
            }

            <#
        .SYNOPSIS
        Get Git commit metadata from the specified leaf location.

        .DESCRIPTION
        `Get-GitCommitMetadata` gets the Git commit metadata from the specified leaf location.

        .PARAMETER LiteralPath
        Specifies a path to one or more locations containing a git repository. The value of LiteralPath is used exactly as it's typed. No characters are
        interpreted as wildcards. If the path includes escape characters, enclose it in single quotation marks. Single quotation
        marks tell PowerShell not to interpret any characters as escape sequences.

        .PARAMETER Path
        Specifies a path to one or more locations containing a git repository.  Wildcards are supported.

        .INPUTS
        [string]  You can pipe a string that contains a path to this cmdlet.

        .OUTPUTS
        [string]  Returns the Git commit metadata for the path.

        .EXAMPLE
        PS> Get-GitCommitMetadata -LiteralPath '.\semver.txt'

        Returns the Git commit metadata for the file `semver.txt`

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather.  All Rights Reserved

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Get-GitRepositoryMetadata

        .LINK
        Get-Item

        .LINK
        Select-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output
    #>
        }

        <##########################################
    Get-GitCommitterHead
##########################################>
        function Get-GitCommitterHead {
            [CmdletBinding()]
            [OutputType([string])]
            param (
                [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
                [ValidateNotNullOrEmpty()]
                [string[]]
                $Branch = 'main',

                [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
                    ErrorMessage = "WorkingDirectory '{0}' is not a valid path container")]
                [string]
                $WorkingDirectory = $PWD
            )

            BEGIN {
                Set-StrictMode -Version 3.0
                Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
            }

            PROCESS {
                $Branch | ForEach-Object -Process {
                    $branchToProcess = $_

                    Get-GitBranchRemote -WorkingDirectory $WorkingDirectory -Local |
                        Where-Object -FilterScript { $_ -ne 'HEAD' } |
                        Get-GitShow -Format '%cn' |
                        Select-Object -First 1 } |
                        Write-Output
    }

    <#
        .SYNOPSIS
        Get the Git committer from the specified branch.

        .DESCRIPTION
        `Get-GitCommitterHead` gets the Git committer from the specified branch.

        .PARAMETER Branch
        Specifies the branch to get the committer from.  Defaults to 'main'.

        .INPUTS
        [string[]]  `Get-CommitterHead` accepts a string array of branch names.

        .OUTPUTS
        [string]  `Get-CommitterHead` returns the Git committer for the specified branch.

        .EXAMPLE
        PS> Get-GitCommiterHead

        John Merryweather Cooper

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather.  All Rights Reserved

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Invoke-ToolCommandLine

        .LINK
        Select-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Sort-Object

        .LINK
        Where-Object

        .LINK
        Write-Output
    #>
}

<##########################################
    Get-GitCommitterDateHead
##########################################>
function Get-GitCommitterDateHead {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Branch = 'main',

        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "WorkingDirectory '{0}' is not a valid path container")]
        [string]
        $WorkingDirectory = $PWD
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $Branch | ForEach-Object -Process {
            $branchToProcess = $_

            Get-GitBranchRemote -WorkingDirectory $WorkingDirectory -Local |
                Where-Object -FilterScript { $_ -ne 'HEAD' } |
                Get-GitShow -Format '%cd' |
                Select-Object -First 1 } |
                Write-Output
    }

    <#
        .SYNOPSIS
        Get the Git committer date from the specified branch.

        .DESCRIPTION
        `Get-GitCommitterDateHead` gets the Git committer date from the specified branch.

        .PARAMETER Branch
        Specifies the branch to get the committer date from.  Defaults to 'main'.

        .INPUTS
        [string[]]  `Get-CommitterDateHead` accepts a string array of branch names.

        .OUTPUTS
        [string]  `Get-CommitterDateHead` returns the Git committer date for the specified branch.

        .EXAMPLE
        PS> Get-GitCommiterDateHead

        2025-01-27 12:00:00

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather.  All Rights Reserved

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Invoke-ToolCommandLine

        .LINK
        Select-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Sort-Object

        .LINK
        Where-Object

        .LINK
        Write-Output
    #>
}

<##########################################
    Get-GitRepositoryMetadata
##########################################>
function Get-GitRepositoryMetadata {
    [CmdletBinding()]
    [OutputType([psobject])]
    param (
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "WorkingDirectory '{0}' is not a valid path container")]
        [string]
        $WorkingDirectory = $PWD
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    $gitRepository = New-Object -TypeName System.Management.Automation.PSObject

    $gitRepository | Add-Member -MemberType NoteProperty -Name 'Author' -Value (Get-GitAuthorHead -WorkingDirectory $WorkingDirectory)
    $gitRepository | Add-Member -MemberType NoteProperty -Name 'AuthorDate' -Value (Get-GitAuthorDateHead -WorkingDirectory $WorkingDirectory)
    $gitRepository | Add-Member -MemberType NoteProperty -Name 'Branch' -Value (Get-GitBranch -WorkingDirectory $WorkingDirectory)
    $gitRepository | Add-Member -MemberType NoteProperty -Name 'Committer' -Value (Get-GitCommitterHead -WorkingDirectory $WorkingDirectory)
    $gitRepository | Add-Member -MemberType NoteProperty -Name 'CommitterData' -Value (Get-GitCommitterDateHead -WorkingDirectory $WorkingDirectory)
    $gitRepository | Add-Member -MemberType NoteProperty -Name 'LongId' -Value (Get-GitLongId -WorkingDirectory $WorkingDirectory)
    $gitRepository | Add-Member -MemberType NoteProperty -Name 'GitLongRef' -Value (Get-GitLongRef -WorkingDirectory $WorkingDirectory)
    $gitRepository | Add-Member -MemberType NoteProperty -Name 'CommitMetadata' -Value (Get-GitCommitMetadata -WorkingDirectory $WorkingDirectory)
    $gitRepository | Add-Member -MemberType NoteProperty -Name 'GitRef' -Value (Get-GitRef -WorkingDirectory $WorkingDirectory)
    $gitRepository | Add-Member -MemberType NoteProperty -Name 'RepositoryName' -Value (Get-GitRepositoryName -WorkingDirectory $WorkingDirectory)
    $gitRepository | Add-Member -MemberType NoteProperty -Name 'RepositoryPath' -Value (Get-GitRepositoryPath -WorkingDirectory $WorkingDirectory)
    $gitRepository | Add-Member -MemberType NoteProperty -Name 'RepositoryUrl' -Value (Get-GitRepositoryUrl -WorkingDirectory $WorkingDirectory)
    $gitRepository | Add-Member -MemberType NoteProperty -Name 'ShortId' -Value (Get-GitShortId -WorkingDirectory $WorkingDirectory)
    $gitRepository | Add-Member -MemberType NoteProperty -Name 'Tag' -Value (Get-GitTag -WorkingDirectory $WorkingDirectory)
    $gitRepository | Add-Member -MemberType NoteProperty -Name 'Version' -Value (Get-GitVersion -WorkingDirectory $WorkingDirectory)

    $gitRepository | Write-Output

    <#
        .SYNOPSIS
        Gets the current repository's metadata.

        .DESCRIPTION
        `Get-GitRepositoryMetadata` gets the current repository's metadata.

        .INPUTS
        None.  `Get-GitRepositoryMetadata` does not accept input.

        .OUTPUTS
        [psobject]  Returns the current repository's metadata as a PSObject.

        .EXAMPLE
        PS> Get-GitRepositoryMetadata | Format-List

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather.  All Rights Reserved

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Add-Member

        .LINK
        Get-GitAuthorHead

        .LINK
        Get-GitAuthorDateHead

        .LINK
        Get-GitBranch

        .LINK
        Get-GitCommitterHead

        .LINK
        Get-GitCommitterDateHead

        .LINK
        Get-GitLongId

        .LINK
        Get-GitLongRef

        .LINK
        Get-GitRepositoryName

        .LINK
        Get-GitRepositoryPath

        .LINK
        Get-GitRepositoryUrl

        .LINK
        Get-GitShortId

        .LINK
        Get-GitTag

        .LINK
        Get-GitVersion

        .LINK
        New-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output
    #>
}

<##########################################
    Get-GitShortId
##########################################>
function Get-GitShortId {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "WorkingDirectory '{0}' is not a valid path container")]
        [string]
        $WorkingDirectory = $PWD
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    Get-GitRevisionParse -WorkingDirectory $WorkingDirectory -Short | Write-Output

    <#
        .SYNOPSIS
        Get the short Git ID.

        .DESCRIPTION
        `Get-GitShortId` gets the short Git ID.

        .INPUTS
        None.  `Get-GitShortId` does not accept input.

        .OUTPUTS
        [string]  `Get-GitShortId` returns the short Git ID.

        .EXAMPLE
        PS> Get-GitShortId

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather.  All Rights Reserved

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Invoke-ToolCommandLine

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output
    #>
}

<##########################################
    Get-GitLongId
##########################################>
function Get-GitLongId {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "WorkingDirectory '{0}' is not a valid path container")]
        [string]
        $WorkingDirectory = $PWD
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    Get-GitRevisionParse -WorkingDirectory $WorkingDirectory | Write-Output

    <#
        .SYNOPSIS
        Get the long Git ID.

        .DESCRIPTION
        `Get-GitLongId` gets the long Git ID.

        .INPUTS
        None.  `Get-GitLongId` does not accept input.

        .OUTPUTS
        [string]  `Get-GitLongId` returns the short Git ID.

        .EXAMPLE
        PS> Get-GitLongId

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather.  All Rights Reserved

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Invoke-ToolCommandLine

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output
    #>
}

<##########################################
    Get-GitRef
##########################################>
function Get-GitRef {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "WorkingDirectory '{0}' is not a valid path container")]
        [string]
        $WorkingDirectory = $PWD
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    Push-Location $WorkingDirectory
    & git symbolic-ref --short HEAD | Write-Output
    Pop-Location

    <#
        .SYNOPSIS
        Get the Git reference.

        .DESCRIPTION
        `Get-GitRef` gets the Git reference.

        .INPUTS
        None.  `Get-GitRef` does not accept input.

        .OUTPUTS
        [string]  `Get-GitRef` returns the Git reference as a string..

        .EXAMPLE
        PS> Get-GitRef

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather.  All Rights Reserved

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Invoke-ToolCommandLine

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output
    #>
}

<##########################################
    Get-GitLongRef
##########################################>
function Get-GitLongRef {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "WorkingDirectory '{0}' is not a valid path container")]
        [string]
        $WorkingDirectory = $PWD
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    Push-Location $WorkingDirectory
    & git symbolic-ref HEAD | Write-Output
    Pop-Location

    <#
        .SYNOPSIS
        Get the Git long reference.

        .DESCRIPTION
        `Get-GitLongRef` gets the Git long reference.

        .INPUTS
        None.  `Get-GitLongRef` does not accept input.

        .OUTPUTS
        [string]  `Get-GitLongRef` returns the Git long reference as a string..

        .EXAMPLE
        PS> Get-GitLongRef

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather.  All Rights Reserved

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Invoke-ToolCommandLine

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output
    #>
}

<##########################################
    Get-GitBranch
##########################################>
function Get-GitBranch {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "WorkingDirectory '{0}' is not a valid path container")]
        [string]
        $WorkingDirectory = $PWD
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    Push-Location $WorkingDirectory
    & git branch --show-current | Write-Output
    Pop-Location

    <#
        .SYNOPSIS
        Get the current Git branch.

        .DESCRIPTION
        `Get-GitBranch` gets the current Git branch.

        .INPUTS
        None.  `Get-GitBranch` does not accept input.

        .OUTPUTS
        [string]  `Get-GitBranch` returns the current Git branch as a string..

        .EXAMPLE
        PS> Get-GitBranch

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather.  All Rights Reserved

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Invoke-ToolCommandLine

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output
    #>
}

<##########################################
    Get-GitCommitMetadata
##########################################>
function Get-GitCommitMetadata {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "WorkingDirectory '{0}' is not a valid path container")]
        [string]
        $WorkingDirectory = $PWD
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    Push-Location $WorkingDirectory
    & git log -1 '--pretty=format:"%H %s"' | Write-Output
    Pop-Location

    <#
        .SYNOPSIS
        Gets the Git commit metadata.

        .DESCRIPTION
        `Get-GitCommitMetadata` gets the Git commit metadata.

        .INPUTS
        None.  `Get-GitCommitMetadata` does not accept input.

        .OUTPUTS
        [string]  `Get-GitCommitMetadata` returns the Git commit metadata as a string..

        .EXAMPLE
        PS> Get-GitCommitMetadata

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather.  All Rights Reserved

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Invoke-ToolCommandLine

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output
    #>
}

<##########################################
    Get-GitFormattedLog
##########################################>
function Get-GitFormattedLog {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "WorkingDirectory '{0}' is not a valid path container")]
        [string]
        $WorkingDirectory = $PWD
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    Push-Location $WorkingDirectory
    & git log --no-merges --pretty=short | Write-Output
    Pop-Location

    <#
        .SYNOPSIS
        Gets a Git short formatted log.

        .DESCRIPTION
        `Get-GitFormattedLog` gets a Git short formatted log.

        .INPUTS
        None.  `Get-GitFormattedLog` does not accept input.

        .OUTPUTS
        [string]  `Get-GitFormattedLog` returns the Git reference as a string..

        .EXAMPLE
        PS> Get-GitFormattedLog

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather.  All Rights Reserved

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Invoke-ToolCommandLine

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output
    #>
}

<##########################################
    Get-GitRepositoryName
##########################################>
function Get-GitRepositoryName {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "WorkingDirectory '{0}' is not a valid path container")]
        [string]
        $WorkingDirectory = $PWD
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    Get-GitRepositoryPath -WorkingDirectory $WorkingDirectory | Split-Path -Leaf | Write-Output

    <#
        .SYNOPSIS
        Gets the current Git repository name.

        .DESCRIPTION
        `Get-GitRepositoryName` gets the current Git repository name.

        .INPUTS
        None.  `Get-GitRepositoryName` does not accept input.

        .OUTPUTS
        [string]  `Get-GitRepositoryName` returns the current Git repository name as a string.

        .EXAMPLE
        PS> Get-GitRepositoryName

        PSInstallCom

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather.  All Rights Reserved

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Get-GitRepositoryPath

        .LINK
        Invoke-ToolCommandLine

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Split-Path

        .LINK
        Write-Output
    #>
}

<##########################################
    Get-GitRepositoryPath
##########################################>
function Get-GitRepositoryPath {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "WorkingDirectory '{0}' is not a valid path container")]
        [string]
        $WorkingDirectory = $PWD
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    Get-GitRevisionParse -WorkingDirectory $WorkingDirectory -ShowTopLevel | Write-Output

    <#
        .SYNOPSIS
        Gets the current Git repository full path.

        .DESCRIPTION
        `Get-GitRepositoryName` gets the current Git full path.

        .INPUTS
        None.  `Get-GitRepositoryPath` does not accept input.

        .OUTPUTS
        [string]  `Get-GitRepositoryPath` returns the current Git repository full path as a string.

        .EXAMPLE
        PS> Get-GitRepositoryPath

        ./GitHub/PSInstallCom

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather.  All Rights Reserved

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Invoke-ToolCommandLine

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Split-Path

        .LINK
        Write-Output
    #>
}

<##########################################
    Get-GitRepositoryUrl
##########################################>
function Get-GitRepositoryUrl {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "WorkingDirectory '{0}' is not a valid path container")]
        [string]
        $WorkingDirectory = $PWD
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    Push-Location $WorkingDirectory
    & git remote get-url origin | Write-Output
    Pop-Location

    <#
        .SYNOPSIS
        Gets the current Git repository URL.

        .DESCRIPTION
        `Get-GitRepositoryUrl` gets the current Git repository URL.

        .INPUTS
        None.  `Get-GitRepositoryUrl` does not accept input.

        .OUTPUTS
        [string]  `Get-GitRepositoryUrl` returns the current Git repository URL as a string.

        .EXAMPLE
        PS> Get-GitRepositoryUrl

        https://github.com/OPM-jmcooper176/PowerShellModules

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather.  All Rights Reserved

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Invoke-ToolCommandLine

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Split-Path

        .LINK
        Write-Output
    #>
}

<##########################################
    Get-GitTag
##########################################>
function Get-GitTag {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "WorkingDirectory '{0}' is not a valid path container")]
        [string]
        $WorkingDirectory = $PWD
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    Push-Location $WorkingDirectory

    if (Test-HasTag -WorkingDirectory $WorkingDirectory) {
        & git describe --tags --abbrev=0 | Write-Output
    }
    else {
        [string]::Empty | Write-Output
    }

    Pop-Location

    <#
        .SYNOPSIS
        Gets the current Git repository tag.

        .DESCRIPTION
        `Get-GitTag` gets the current Git repository tag.

        .INPUTS
        None.  `Get-GitTag` does not accept input.

        .OUTPUTS
        [string]  `Get-GitTag` returns the current Git repository tag as a string.

        .EXAMPLE
        PS> Get-GitTag

        1.2.3.4

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather.  All Rights Reserved

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Invoke-ToolCommandLine

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Split-Path

        .LINK
        Write-Output
    #>
}

<##########################################
    Get-GitVersion
##########################################>
function Get-GitVersion {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "WorkingDirectory '{0}' is not a valid path container")]
        [string]
        $WorkingDirectory = $PWD
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    Get-GitTag -WorkingDirectory $WorkingDirectory | Write-Output

    <#
        .SYNOPSIS
        Gets the current Git repository version.

        .DESCRIPTION
        `Get-GitVersion` gets the current Git repository version.

        .INPUTS
        None.  `Get-GitVersion` does not accept input.

        .OUTPUTS
        [string]  `Get-GitVersion` returns the current Git repository version as a string.

        .EXAMPLE
        PS> Get-GitVersion

        1.2.3.4

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather.  All Rights Reserved

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Invoke-ToolCommandLine

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Split-Path

        .LINK
        Write-Output
    #>
}

<##########################################
    Test-GitRepository
##########################################>
function Test-GitRepository {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "WorkingDirectory '{0}' is not a valid path container")]
        [string]
        $WorkingDirectory = $PWD
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    Push-Location $WorkingDirectory
    Test-Path -LiteralPath '.\.git' -PathType Container | Write-Output
    Pop-Location

    <#
        .SYNOPSIS
        Tests if the current directory is a Git repository.

        .DESCRIPTION
        `Test-GitRepository` tests if the current directory is a Git repository by looking for a `.git` subdirectory.

        .INPUTS
        None.  `Test-GitRepository` does not accept input.

        .OUTPUTS
        [bool]  `Test-GitRepository` returns `$true` if the current directory is a Git repository; otherwise, it returns `$false`.

        .EXAMPLE
        PS> Test-GitRepository

        True

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather.  All Rights Reserved

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Join-Path

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Test-Path

        .LINK
        Write-Output
    #>
}

<##########################################
    Test-HasTag
##########################################>
function Test-HasTag {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "WorkingDirectory '{0}' is not a valid path container")]
        [string]
        $WorkingDirectory = $PWD,

        [ValidateNotNullOrEmpty()]
        [string]
        $Tag
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    Push-Location $WorkingDirectory

    if ($PSBoundParameters.ContainsKey('Tag')) {
        $result = & git show-ref --tags $Tag --quiet | Out-Null
        [bool]$result | Write-Output
    }
    else {
        $result = & git rev-parse '--tags=$TAG' | Out-Null
        [bool]$result | Write-Output
    }

    Pop-Location
}

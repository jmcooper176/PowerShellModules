<#
 =============================================================================
<copyright file="GitHubModule.psm1" company="John Merryweather Cooper">
    Copyright © 2022-2025, John Merryweather Cooper.
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
This file "GitHubModule.psm1" is part of "GitHubModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

#
# GitHubModule.psm1
#

<#
    Add-MultilineStepSummary
#>
function Add-MultilineStepSummary {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Content,

        [switch]
        $Echo
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ShouldProcess($Content, $CmdletName)) {
            $Content | Export-EnvironmentVariableFile -EnvironmentFile 'GITHUB_STEP_SUMMARY' -Echo:$Echo.IsPresent
        }
    }

    <#
        .SYNOPSIS
        Add a multi-line step summary to a running GitHub workflow.

        .DESCRIPTION
        `Add-MultilineStepSummary` adds a multi-line step summary to a running GitHub workflow.

        .PARAMETER Content
        Specifies the content of the multi-line step summary.

        .PARAMETER Echo
        When set, `Add-Content` is set to pass through and the name=value pair is output.

        .INPUTS
        [string[]] `Add-MultilineStepSummary` receives content input from the pipeline.

        .OUTPUTS
        [string]  If `Echo` is true, `Add-MultilineStepSummary` outputs the name=value pair to the PowerShell pipeline; otherwise, there is no output.

        .EXAMPLE
        PS> 'This is a multi-line step summary' | Add-MultilineStepSummary

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Export-EnvironmentVariableFile

        .LINK
        Initialize-PSCmdlet

        .LINK
        Write-Verbose
    #>
}

<#
    Add-StepSummary
#>
function Add-StepSummary {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Content,

        [switch]
        $Echo
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ShouldProcess($Content, $CmdletName)) {
            $Content | Export-EnvironmentVariableFile -EnvironmentFile 'GITHUB_STEP_SUMMARY' -Echo:$Echo.IsPresent
        }
    }

    <#
        .SYNOPSIS
        Adds a single-line step summary to a running GitHub workflow.

        .DESCRIPTION
        `Add-StepSummary` adds a single-line step summary to a running GitHub workflow.

        .PARAMETER Content
        Specifies the line of content to add.

        .PARAMETER Echo
        When set, `Add-Content` is set to pass through and the name=value pair is output.

        .INPUTS
        [string] `Add-StepSummary` receives content input from the pipeline.

        .OUTPUTS
        [string]  If `Echo` is true, `Add-StepSummary` outputs the name=value pair to the PowerShell pipeline; otherwise, there is no output.

        .EXAMPLE
        PS> 'This is a single-line step summary' | Add-StepSummary

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Export-EnvironmentVariableFile

        .LINK
        Initialize-PSCmdlet

        .LINK
        Write-Verbose
    #>
}

<#
    Add-SystemPath
#>
function Add-SystemPath {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingLiteralPath', ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
        [string]
        $LiteralPath,

        [Parameter(Mandatory, ParameterSetName = 'UsingPath', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Get-ChildItem -Path $_ -Recurse | Test-Path -PathType Container })]
        [SupportsWildcards()]
        [string]
        $Path,

        [switch]
        $Echo
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ShouldProcess($PSCmdlet.ParameterSetName, $CmdletName)) {
            if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
                $LiteralPath | Export-EnvironmentVariableFile -EnvironmentFile 'GITHUB_PATH' -Echo:$Echo.IsPresent
            } else {
                $Path | Resolve-Path | Select-Object -First 1 | Export-EnvironmentVariableFile -EnvironmentFile 'GITHUB_PATH' -Echo:$Echo.IsPresent
            }
        }
    }

    <#
        .SYNOPSIS
        Adds a path to the GitHub system path.

        .DESCRIPTION
        `Add-SystemPath` adds a path to the GitHub system path.

        .PARAMETER LiteralPath
        Specifies the literal path to add.  No wildcards are expanded.  The path is taken exactly as it is passed.  The path must exists and it must be a container.

        .PARAMETER Path
        Specifies the path to add.  Wildcards are expanded.  The path is resolved to a full path.  The path must exist and it must be a container.  Only the first path to resolve will be use.

        .PARAMETER Echo
        When set, `Add-Content` is set to pass through and the name=value pair is output.

        .INPUTS
        [string] `Add-SystemPath` receives path input from the pipeline.

        .OUTPUTS
        [string]  If `Echo` is true, `Add-SystemPath` outputs the name=value pair to the PowerShell pipeline; otherwise, there is no output.

        .EXAMPLE
        PS> 'C:\Program Files\Git\cmd' | Add-SystemPath

        Adds the path to 'git' to the GITHUB_PATH.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Export-EnvironmentVariableFile

        .LINK
        Initialize-PSCmdlet

        .LINK
        Resolve-Path

        .LINK
        Select-Object

        .LINK
        Test-Path

        .LINK
        Write-Verbose
    #>
}

<#
    ConvertTo-Tuple
#>
function ConvertTo-Tuple {
    [CmdletBinding()]
    [OutputType([object])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Value
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
        Set-Variable -Name KEY_VALUE_REGEX -Option Constant -Value '([\w_]+)\,\s*(.*)'
    }

    PROCESS {
        Write-Verbose -Message "$($CmdletName) : Passed Value '$($Value)'"

        if ("$Value" -match $KEY_VALUE_REGEX) {
            Write-Verbose -Message "$($CmdletName) : Value '$($Value)' matched regular expression"
            $outputProperty = $Matches[1]
            $filePath = $Matches[2]
            [System.Tuple]::Create($outputProperty, $filePath) | Write-Output
        } else {
            Write-Warning -Message "Value '$($Value)' did not match regular expression"
            $Value | Write-Output
        }
    }

    <#
        .SYNOPSIS
        Converts an environment variable comma-separated name/value pair to a [System.Tuple].

        .DESCRIPTION
        `ConvertTo-Tuple` converts an environment variable comma-separated name/value pair to a [System.Tuple].

        .PARAMETER Value
        Specifies the environment variable name/value pair.

        .INPUTS
        [string]  `ConvertTo-Tuple` receives value input from the pipeline.

        .OUTPUTS
        [System.Tuple]  `ConvertTo-Tuple` outputs a [System.Tuple] or $null to the PowerShell pipeline.

        .EXAMPLE
        PS> 'GITHUB_ENV, D:\a\_temp\_runner_file_commands\set_env_325ac9ee-3615-4c18-bc1c-a7b02d0cef95' | ConvertTo-Tuple

        Item1      Item2                                                                         Length
        -----      -----                                                                         ------
        GITHUB_ENV D:\a\_temp\_runner_file_commands\set_env_325ac9ee-3615-4c18-bc1c-a7b02d0cef95 2

        Returns a tuple representing the environment name/value pair.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Initialize-PSCmdlet

        .LINK
        Set-Variable

        .LINK
        Write-Output

        .LINK
        Write-Verbose

        .LINK
        Write-Warning
    #>
}

<#
    Export-EnvironmentVariableFile
#>
function Export-EnvironmentVariableFile {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('GITHUB_ENV', 'GITHUB_OUTPUT', 'GITHUB_PATH', 'GITHUB_SAVE', 'GITHUB_STEP_SUMMARY')]
        [string]
        $EnvironmentFile,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Content,

        [switch]
        $Echo
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        $tuple = Get-EnvironmentVariable -Name $EnvironmentFile -AsString | ConvertTo-Tuple

        if (-not (Test-Path -LiteralPath $tuple.Item2 -PathType Leaf)) {
            Write-Warning -Message "$($CmdletName):  File Path '$($tuple.Item2)' should exist.  Touching"
            New-Item -Path $tuple.Item2 -ItemType File
        }
    }

    PROCESS {
        Write-Verbose -Message "$($CmdletName):  Writing content '$($Content)' to '$($EnvironmentFile)' at file path $($tuple.Item2)"

        try {
            Add-Content -LiteralPath $tuple.Item2 -Value $Content -Encoding UTF8 -PassThru:$Echo.IsPresent
        } catch {
            $Error | Write-Fatal
        }
    }

    <#
        .SYNOPSIS
        Asynchronously writes content to file paths stored in GitHub environment variables.

        .DESCRIPTION
        `Export-EnvironmentVariableFile` asynchronously writes content to file paths stored in GitHub environment variables.

        .PARAMETER EnvironmentFile
        Specifies the GitHub environment variable pointing to a file path to use.

        Allowed values are:

        * GITHUB_ENV
        * GITHUB_OUTPUT
        * GITHUB_PATH
        * GITHUB_SAVE
        * GITHUB_STEP_SUMMARY

        .PARAMETER Content
        Specifies the content to write to the file path referenced in the GitHub environment variable.

        .PARAMETER Echo
        If present, Add-Content will pass the content to the pipeline.  This is a change in behavior as PassThru was the default.

        .INPUTS
        [string]  `Export-EnvironmentVariableFile` receives content input from the pipeline.

        .OUTPUTS
        [string]  `Export-EnvironmentVariableFile` outputs a name=value pair string to the PowerShell pipeline when `Echo` is passed; otherwise nothing is output to the pipeline.

        .EXAMPLE
        PS> 'This is a test' | Export-EnvironmentVariableFile -EnvironmentFile 'GITHUB_STEP_SUMMARY'

        Adds the content to the file path stored in the GITHUB_STEP_SUMMARY environment variable.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Add-Content

        .LINK
        Initialize-PSCmdlet

        .LINK
        Set-Variable

        .LINK
        Wait-Job

        .LINK
        Write-Fatal

        .LINK
        Write-Verbose
    #>
}

<#
    Get-GitHubEnvironmentVariable
#>
function Get-GitHubEnvironmentVariable {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('ACTIONS_RUNNER_ACTION_ARCHIVE_CACHE', 'CI',
            'GITHUB_ACTION', 'GITHUB_ACTION_REF',
            'GITHUB_ACTION_REPOSITORY', 'GITHUB_ACTIONS', 'GITHUB_ACTOR',
            'GITHUB_ACTOR_ID', 'GITHUB_API_URL', 'GITHUB_BASE_REF', 'GITHUB_ENV',
            'GITHUB_EVENT_NAME', 'GITHUB_EVENT_PATH', 'GITHUB_GRAPHQL_URL',
            'GITHUB_HEAD_REF', 'GITHUB_JOB', 'GITHUB_OUTPUT', 'GITHUB_PATH',
            'GITHUB_REF', 'GITHUB_REF_NAME', 'GITHUB_REF_PROTECTED',
            'GITHUB_REF_TYPE', 'GITHUB_REPOSITORY', 'GITHUB_REPOSITORY_ID',
            'GITHUB_REPOSITORY_OWNER', 'GITHUB_REPOSITORY_OWNER_ID',
            'GITHUB_RETENTION_DAYS', 'GITHUB_RUN_ATTEMPT', 'GITHUB_RUN_ID',
            'GITHUB_RUN_NUMBER', 'GITHUB_SERVER_URL', 'GITHUB_SHA',
            'GITHUB_STATE', 'GITHUB_STEP_SUMMARY', 'GITHUB_TRIGGERING_ACTOR',
            'GITHUB_WORKFLOW', 'GITHUB_WORKFLOW_REF', 'GITHUB_WORKFLOW_SHA',
            'GITHUB_WORKSPACE', 'RUNNER_ARCH', 'RUNNER_ENVIRONMENT',
            'RUNNER_NAME', 'RUNNER_OS', 'RUNNER_PERFLOG', 'RUNNER_TEMP',
            'RUNNER_TOOL_CACHE', 'RUNNER_TRACKING_ID', 'RUNNER_WORKSPACE')]
        [string]
        $Name
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if (Test-EnvironmentVariable -Name $Name) {
        Write-Verbose -Message "$($CmdletName) : Process Environment Variable '$($Name)' found"
        Get-EnvironmentVariable -Name $Name | Write-Output
    } else {
        Write-Warning -Message "$($CmdletName) : Process Environment Variable '$($Name)' not found"
        [string]::Empty | Write-Output
    }

    <#
        .SYNOPSIS
        Gets the value of a GitHub runner environment variable.

        .DESCRIPTION
        `Get-GitHubEnvironmentVariable` gets the value of a GitHub runner environment variable.

        .PARAMETER Name
        Specifies the name of the GitHub runner environment variable to get.

        Allowed Names are:

        * ACTIONS_RUNNER_ACTION_ARCHIVE_CACHE  : Path to the runner action archive cache.
        * CI                                   : Indicates if the runner is running in a CI environment.  Should be set to false for Deploy environments.
        * GITHUB_ACTION                        : The name of the current action being executed.
        * GITHUB_ACTION_REF
        * GITHUB_ACTION_REPOSITORY
        * GITHUB_ACTIONS                       : Always set to true when GitHub Actions is running the workflow.
        * GITHUB_ACTOR                         : The name of the person or app that initiated the workflow.
        * GITHUB_ACTOR_ID                      : The ID of the person or app that initiated the workflow.
        * GITHUB_API_URL                       : The URL of the GitHub API.
        * GITHUB_BASE_REF
        * GITHUB_ENV                           : The file path to the GitHub environment.
        * GITHUB_EVENT_NAME                    : The name of the event that triggered the workflow.
        * GITHUB_EVENT_PATH                    : The path to the event JSON file.
        * GITHUB_GRAPHQL_URL                   : The URL of the GraphQL API.
        * GITHUB_HEAD_REF
        * GITHUB_JOB                           : The job_id of the currently executing job.
        * GITHUB_OUTPUT                        : The file path to GitHub output.
        * GITHUB_PATH                          : The file path to the GitHub PATH.
        * GITHUB_REF                           : The 'git' source control ref for the branch being built.
        * GITHUB_REF_NAME                      : The 'git' short source control ref name for the branch being built.
        * GITHUB_REF_PROTECTED                 : Indicates if the source control ref is protected.  Should be true.
        * GITHUB_REF_TYPE                      : The 'git' source control ref type which should always be branch.
        * GITHUB_REPOSITORY                    : The Organization/Repository URI of the repository being built.
        * GITHUB_REPOSITORY_ID                 : The repository ID.
        * GITHUB_REPOSITORY_OWNER              : Synonym for the Organization.
        * GITHUB_REPOSITORY_OWNER_ID           : The Organization ID.
        * GITHUB_RETENTION_DAYS                : Number of days to retain this build.
        * GITHUB_RUN_ATTEMPT                   : Count of run attempts for this workflow.
        * GITHUB_RUN_ID                        : The run_id of the currently executing run.
        * GITHUB_RUN_NUMBER                    : The historical run number of the currently executing run.
        * GITHUB_SERVER_URL                    : The scheme/server of the GitHub URL.  Should always be:  https://github.com
        * GITHUB_SHA                           : The 'git' commit SHA for HEAD for the current build.
        * GITHUB_STATE                         : The file path to the GitHub state space.
        * GITHUB_STEP_SUMMARY                  : The file path to the GitHub step summary.
        * GITHUB_TRIGGERING_ACTOR              : The name of the person or app that triggered the workflow.  Should be the same as GITHUB_ACTOR.
        * GITHUB_WORKFLOW                      : The friendly name of the current GitHub workflow.
        * GITHUB_WORKFLOW_REF                  : The URI path for the current GitHub workflow.
        * GITHUB_WORKFLOW_SHA                  : The 'git' commit SHA for HEAD for the current build.  Should be the same as GITHUB_SHA.
        * GITHUB_WORKSPACE                     : The path to the root of source control in the repository.

        .INPUTS
        None.  `Get-GitHubEnvironmentVariable` receives no input from the pipeline.

        .OUTPUTS
        [string]  `Get-GitHubEnvironmentVariable` outputs the value of the GitHub runner environment variable to the PowerShell pipeline.

        .EXAMPLE
        PS> Get-GitHubEnvironmentVariable -Name 'GITHUB_WORKFLOW'

        NuGet Deploy Build

        Returns the value of the GITHUB_WORKFLOW environment variable.

        Dump of Example Environment:

        Variable                             Values Like
        -----------------------------------  ----------------------
        ACTIONS_RUNNER_ACTION_ARCHIVE_CACHE  C:\actionarchivecache\
        CI                                   true
        GITHUB_ACTION                        __run]
        GITHUB_ACTION_REF
        GITHUB_ACTION_REPOSITORY
        GITHUB_ACTIONS                       true
        GITHUB_ACTOR                         John-Cooper2_opmgov
        GITHUB_ACTOR_ID                      159469325
        GITHUB_API_URL                       https://api.github.com
        GITHUB_BASE_REF
        GITHUB_ENV                           D:\a\_temp\_runner_file_commands\set_env_325ac9ee-3615-4c18-bc1c-a7b02d0cef95
        GITHUB_EVENT_NAME                    workflow_run
        GITHUB_EVENT_PATH                    D:\a\_temp\_github_workflow\event.json
        GITHUB_GRAPHQL_URL                   https://api.github.com/graphql
        GITHUB_HEAD_REF
        GITHUB_JOB                           test
        GITHUB_OUTPUT                        D:\a\_temp\_runner_file_commands\set_output_325ac9ee-3615-4c18-bc1c-a7b02d0cef95
        GITHUB_PATH                          D:\a\_temp\_runner_file_commands\add_path_325ac9ee-3615-4c18-bc1c-a7b02d0cef95
        GITHUB_REF                           refs/heads/main
        GITHUB_REF_NAME                      main
        GITHUB_REF_PROTECTED                 true
        GITHUB_REF_TYPE                      branch
        GITHUB_REPOSITORY                    OPM-OCIO-DEVSECOPS/SkyOps-NuGet
        GITHUB_REPOSITORY_ID                 784921339
        GITHUB_REPOSITORY_OWNER              OPM-OCIO-DEVSECOPS
        GITHUB_REPOSITORY_OWNER_ID           168688749
        GITHUB_RETENTION_DAYS                90
        GITHUB_RUN_ATTEMPT                   1
        GITHUB_RUN_ID                        9423590121
        GITHUB_RUN_NUMBER                    57
        GITHUB_SERVER_URL                    https://github.com
        GITHUB_SHA                           070eca72e4cd84b4f5a8df341938cec434a16c33
        GITHUB_STATE                         D:\a\_temp\_runner_file_commands\save_state_325ac9ee-3615-4c18-bc1c-a7b02d0cef95
        GITHUB_STEP_SUMMARY                  D:\a\_temp\_runner_file_commands\step_summary_325ac9ee-3615-4c18-bc1c-a7b02d0cef95
        GITHUB_TRIGGERING_ACTOR              John-Cooper2_opmgov
        GITHUB_WORKFLOW                      NuGet Deploy Build
        GITHUB_WORKFLOW_REF                  OPM-OCIO-DEVSECOPS/SkyOps-NuGet/.github/workflows/nuget-Deploy-Build.yml@refs/heads/main
        GITHUB_WORKFLOW_SHA                  070eca72e4cd84b4f5a8df341938cec434a16c33
        GITHUB_WORKSPACE                     D:\a\SkyOps-NuGet\SkyOps-NuGet

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Get-EnvironmentVariable

        .LINK
        Initialize-PSCmdlet

        .LINK
        Test-EnvironmentVariable

        .LINK
        Write-Output

        .LINK
        Write-Verbose

        .LINK
        Write-Warning
    #>
}

<#
    Remove-StepSummary
#>
function Remove-StepSummary {
    [CmdletBinding(SupportsShouldProcess)]
    param ()

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    try {
        Get-EnvironmentVariable -Name 'GITHUB_STEP_SUMMARY' -AsString |
            ConvertTo-Tuple |
                Where-Object -FilterScript { Test-Path -LiteralPath $_.Item2 -PathType Leaf } |
                    ForEach-Object -Process { Remove-Item -LiteralPath $_.Item2 -Recurse }
    }
    catch {
        $Error | Write-Fatal
    }

    <#
        .SYNOPSIS
        Delete the file path stored in the GITHUB_STEP_SUMMARY environment variable.

        .DESCRIPTION
        `Remove-StepSummary` deletes the file path stored in the GITHUB_STEP_SUMMARY environment variable.

        .INPUTS
        None.  `Remove-StepSummary` receives no input from the pipeline.

        .OUTPUTS
        None.  `Remove-StepSummary` outputs nothing to the PowerShell pipeline.

        .EXAMPLE
        PS> Remove-StepSummary

        Deletes the file pointed to by GITHUB_STEP_SUMMARY.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ConvertTo-Tuple

        .LINK
        Get-EnvironmentVariable

        .LINK
        Initialize-PSCmdlet

        .LINK
        Write-Fatal

        .LINK
        Write-Verbose
    #>
}

<#
    Set-GitHubEnvironmentVariable
#>
function Set-GitHubEnvironmentVariable {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ ($_ -notlike 'GITHUB_*') -and ($_ -notlike 'RUNNER_*') })]
        [string]
        $Name,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Value,

        [switch]
        $Echo
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $Value | ForEach-Object -Process {
            $pair = ('{0}={1}' -f $Name, $_)

            if ($PSCmdlet.ShouldProcess($pair, $CmdletName)) {
                $pair | Export-EnvironmentVariableFile -EnvironmentFile 'GITHUB_ENV' -Echo:$Echo.IsPresent
            }
        }
    }

    <#
        .SYNOPSIS
        Sets a GitHub environment variable to value.

        .DESCRIPTION
        `Set-GitHubEnvironmentVariable` sets a GitHub environment variable to value.

        .PARAMETER Name
        Specifies the name of the GitHub environment variable to set.  It may not begin with 'GITHUB_' or 'RUNNER_'.

        .PARAMETER Value
        Specifies the value to set the GitHub environment variable to.

        .INPUTS
        [string]  `Set-GitHubEnvironmentVariable` receives value input from the pipeline.

        .OUTPUTS
        [string]  If `Echo` is true, `Set-GitHubEnvironmentVariable` outputs the name=value pair to the PowerShell pipeline; otherwise, there is no output.

        .EXAMPLE
        PS> 'This is a test' | Set-GitHubEnvironmentVariable -Name 'MY_ENVIRONMENT_VARIABLE'
        PS> Get-GitHubEnvironmentVariable -Name 'MY_ENVIRONMENT_VARIABLE'

        This is a test

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Export-EnvironmentVariableFile

        .LINK
        Initialize-PSCmdlet
    #>
}

<#
    Set-MultilineEnvironmentVariable
#>
function Set-MultilineEnvironmentVariable {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [AllowNull()]
        [System.Object]
        $Delimiter,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Value,

        [switch]
        $Echo
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        $buffer = New-StringBuilder -Value $Name
    }

    PROCESS {
        if ($PSCmdlet.ShouldProcess($Value, $CmdletName)) {
            $Value | ForEach-Object -Process {
                Add-End -Buffer $buffer -InputObject $Delimiter
                Add-End -Buffer $buffer -String $_
            }

            ConvertTo-String -Buffer $buffer | Export-EnvironmentVariableFile -EnvironmentFile 'GITHUB_ENV' -Echo:$Echo.IsPresent
        }
    }

    END {
        Clear-Buffer -Buffer $buffer
    }

    <#
        .SYNOPSIS
        Sets a multi-line environment variable.

        .DESCRIPTION
        `Set-MultilineEnvironmentVariable` sets a multi-line environment variable.

        .PARAMETER Delimiter
        Specifies the delimiter between the lines of the multi-line environment variable.

        .PARAMETER Name
        Specifies the name of the multi-line environment variable.

        .PARAMETER Value
        Specifies the string or array of values to assign to `Name`.

        .PARAMETER Echo
        If present, `Add-Content` will be set to pass through and the name=value pair will be output.

        .INPUTS
        [string[]]  `Set-MultilineEnvironmentVariable` receives value input from the pipeline.

        .OUTPUTS
        [string]  If `Echo` is true, `Set-MultilineEnvironmentVariable` outputs the name=value pair to the PowerShell pipeline; otherwise, there is no output.

        .EXAMPLE
        PS> 'This is a test' | Set-MultilineEnvironmentVariable -Name 'MY_ENVIRONMENT_VARIABLE'
        PS> Get-GitHubEnvironmentVariable -Name 'MY_ENVIRONMENT_VARIABLE'

        This is a test

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Add-End

        .LINK
        Clear-Buffer

        .LINK
        ConvertTo-String

        .LINK
        Export-EnvironmentVariableFile

        .LINK
        ForEach-Object

        .LINK
        Initialize-PSCmdlet

        .LINK
        New-StringBuilder
    #>
}

<#
    Set-MultilineStepSummary
#>
function Set-MultilineStepSummary {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Content,

        [switch]
        $Echo
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ShouldProcess($Content, $CmdletName)) {
            $Content | Export-EnvironmentVariableFile -EnvironmentFile 'GITHUB_STEP_SUMMARY' -Echo:$Echo.IsPresent
        }
    }

    <#
        .SYNOPSIS
        Sets a multi-line step summary.

        .DESCRIPTION
        `Set-MultilineStepSummary` sets a multi-line step summary.

        .PARAMETER Content
        Specifies the content of the multi-line step summary.

        .INPUTS
        [string[]] `Set-MultilineStepSummary` receives content input from the pipeline.

        .OUTPUTS
        [string]  If `Echo` is true, `Set-MultilineStepSummary` outputs the name=value pair to the pipeline; otherwise, there is no output.

        .EXAMPLE
        PS> 'This is a multi-line step summary' | Set-MultilineStepSummary

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Export-EnvironmentVariableFile

        .LINK
        Initialize-PSCmdlet
    #>
}

<#
    Set-OutputParameter
#>
function Set-OutputParameter {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Value,

        [switch]
        $Echo
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $Value | ForEach-Object -Process {
            $pair = ('{0}={1}' -f $Name, $_)

            if ($PSCmdlet.ShouldProcess($pair, $CmdletName)) {
                $pair | Export-EnvironmentVariableFile -EnvironmentFile 'GITHUB_OUTPUT' -Echo:$Echo.IsPresent
            }
        }
    }

    <#
        .SYNOPSIS
        Writes name=value pairs to the file location pointed to by GITHUB_OUTPUT.

        .DESCRIPTION
        `Set-OutputParameter` writes name=value pairs to the file location pointed to by GITHUB_OUTPUT.

        .PARAMETER Name
        Specifies the output variable short name.

        .PARAMETER Value
        Specifies the output variable value.

        .PARAMETER Echo
        If present, `Add-Content` will be set to pass through and the name=value pair will be output.

        .INPUTS
        [string]  `Set-OutputParameter` accepts string input as value from the pipeline.

        .OUTPUTS
        [string]  If `Echo` is true, `Set-OutParameter` outputs the name=value pair to the PowerShell pipeline; otherwise, there is no output.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Export-EnvironmentVariableFile

        .LINK
        ForEach-Object

        .LINK
        Initialize-PSCmdlet
    #>
}

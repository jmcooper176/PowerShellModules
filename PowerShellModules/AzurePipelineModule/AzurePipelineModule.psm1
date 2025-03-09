<#
 =============================================================================
<copyright file="AzurePipelineModule.psm1" company="John Merryweather Cooper">
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
This file "AzurePipelineModule.psm1" is part of "AzurePipelineModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#
    Format-AddAttachment
#>
function Format-AddAttachment {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $FilePath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $AttachmentType,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $AttachmentName
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ShouldProcess($FilePath, $CmdletName)) {
            ('##vso[task.addattachment type={0};name={1};]{2}' -f $AttachmentType, $AttachmentName, $FilePath) | Write-Output
        }
    }

    <#
        .SYNOPSIS
        A brief description of function `Format-AddAttachment`.

        .DESCRIPTION
        A detailed description of function `Format-AddAttachment`.

        .PARAMETER FilePath

        .PARAMETER AttachmentType

        .PARAMETER AttachmentName

        .INPUTS
        [System.String].  `Format-AddAttachment` takes a string representing the
        file path to log to as input from the pipeline.

        .OUTPUTS
        [System.String].  `Format-AddAttachment` returns a formatted string to the
        pipeline.

        .EXAMPLE
        PS> Format-AddAttachment -FilePath $FilePath -AttachmentType 'test' -AttachmentName 'TestRun'

        ##vso[task.addattachment type=test;name=TestRun]

        .EXAMPLE
        PS> $FilePath | Format-AddAttachment -AttachmentType 'test' -AttachmentName 'TestRun'

        ##vso[task.addattachment type=test;name=TestRun]

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        Show-Detail

        .LINK
        Write-Output
    #>
}

<#
    Format-AddBuildTag
#>
function Format-AddBuildTag {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]
        $BuildTag
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ShouldProcess($BuildTag, $CmdletName)) {
            ('##vso[build.addbuildtag]{0}' -f $BuildTag) | Write-Output
        }
    }

    <#
        .SYNOPSIS
        A brief description of function `Format-AddBuildTag`.

        .DESCRIPTION
        A detailed description of function `Format-AddBuildTag`.

        .PARAMETER BuildTag

        .EXAMPLE
        PS> Format-AddBuildTag -BuildTag 'UnitTestSucceeded'

        ##vso[build.addbuildtag]UnitTestSucceeded

        .INPUTS
        [System.String].  `Format-AddBuildTag` takes build tags as input to the pipeline.

        .OUTPUTS
        [System.String].  `Format-AddBuildTag` outputs a formatted string to the
        pipeline.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        Show-Detail

        .LINK
        Write-Output
    #>
}

<#
    Format-ArtifactAssociate
#>
function Format-ArtifactAssociate {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ArtifactName,

        [Parameter(Mandatory)]
        [ValidateSet('container', 'filepath', 'versioncontrol', 'gitref', 'tfvclabel')]
        [string]
        $ArtifactType,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Value
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        switch ($ArtifactType) {
            'container' {
                $toStdOut = '##vso[artifact.associate type=container;artifactname={0}]#{1}' -f $ArtifactName, $Value
                break
            }

            'versioncontrol' {
                $toStdOut = '##vso[artifact.associate type=versioncontrol;artifactname={0}]${1}' -f $ArtifactName, $Value
                break
            }

            default {
                $toStdOut = '##vso[artifact.associate type={0};artifactname={1}]{2}' -f $ArtifactType, $ArtifactName, $Value
                break
            }
        }

        if ($PSCmdlet.ShouldProcess($Value, $CmdletName)) {
            $toStdOut | Write-Output
        }
    }

    <#
        .SYNOPSIS
        A brief description of function `Format-ArtifactAssociate`.

        .DESCRIPTION
        A detailed description of function `Format-ArtifactAssociate`.

        .PARAMETER AttachmentType

        .PARAMETER AttachmentName

        .PARAMETER FilePath

        .EXAMPLE

        .INPUTS
        [System.String].  `Format-ArtifactAssociate` takes attachment name strings as input from the pipeline.
        [System.String].  `Format-ArtifactAssociate` takes value strings as input from the pipeline.

        .OUTPUTS
        [System.String].  `Format-ArtifactAssociate` outputs a formatted string to
        the pipeline.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        Show-Detail

        .LINK
        Write-Output
    #>
}

<#
    Format-SetEndpoint
#>
function Format-SetEndpoint {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Id,

        [Parameter(Mandatory)]
        [ValidateSet('authParameter', 'dataParameter', 'url')]
        [string]
        $Field,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Value,

        [ValidateNotNullOrEmpty()]
        [string]
        $Key
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    switch ($Field) {
        'authParameter' {
            $toStdOut = '##vso[task.setendpoint id={0};field={1};key={2}]{3}' -f $Id, $Field, $Key, $Value
            break
        }

        'dataParameter' {
            $toStdOut = '##vso[task.setendpoint id={0};field={1};key={2}]{3}' -f $Id, $Field, $Key, $Value
            break
        }

        'url' {
            $toStdOut = '##vso[task.setendpoint id={0};field={1};]{2}' -f $Id, $Field, $Value
        }

        default {
            throw "Illegal Field $Field Value"
        }
    }

    if ($PSCmdlet.ShouldProcess($Value, "Setting Endpoint Field $($Field)")) {
        $toStdOut | Write-Output
    }

    <#
        .SYNOPSIS
        A brief description of function `Format-SetEndpoint`.

        .DESCRIPTION
        A detailed description of function `Format-SetEndpoint`.

        .PARAMETER Id

        .PARAMETER Field

        .PARAMETER Value

        .PARAMETER Key

        .EXAMPLE

        .INPUTS
        None.  `Format-SetEndpoint` does not take input from the pipeline.

        .OUTPUTS
        [System.String].  `Format-SetEndpoint` outputs a formatted string to the
        pipeline.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        Show-Detail

        .LINK
        Write-Output
    #>
}

<#
    Format-Complete
#>
function Format-Complete {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Succeeded', 'SucceededWithIssues', 'Failed')]
        [string]
        $ResultType,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Message
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    ('##vso[task.complete result={0};]{1}' -f $ResultType, $Message) | Write-Output

    <#
        .SYNOPSIS
        A brief description of function `Format-Complete`.

        .DESCRIPTION
        A detailed description of function `Format-Complete`.

        .PARAMETER ResultType

        .PARAMETER Message

        .EXAMPLE
        PS> Format-Complete -ResultType 'error' -Message 'Log Succeeded'

        ##vso[task.complete result=Succeeded;]Log Succeeded

        .INPUTS
        None.  `Format-Complete` does not take input from the pipeline.

        .OUTPUTS
        [System.String].  `Format-Complete` outputs a formatted string to the
        pipeline.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        Show-Detail

        .LINK
        Write-Output
    #>
}

<#
    Format-LogEntry
#>
function Format-LogEntry {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('group', 'warning', 'error', 'section', 'debug', 'command', 'endgroup')]
        [string]
        $FormatType,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Message
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    ('##[{0}]{1}' -f $FormatType, $Message) | Write-Output

    <#
        .SYNOPSIS
        A brief description of function `Format-LogEntry`.

        .DESCRIPTION
        A detailed description of function `Format-LogEntry`.

        .PARAMETER FormatType

        .PARAMETER Message

        .EXAMPLE
        PS> Format-LogEntry -FormatType 'error' -Message 'Error Message'

        ##[error]Error Message

        .INPUTS
        None.  `Format-LogEntry` does not take input from the pipeline.

        .OUTPUTS
        [System.String].  `Format-LogEntry` outputs a formatted string to the
        pipeline.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        Show-Detail

        .LINK
        Write-Output
    #>
}

<#
    Format-LogIssue
#>
function Format-LogIssue {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('error', 'warning')]
        [string]
        $IssueType,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Message,

        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
        [string]
        $SourcePath,

        [ValidateRange(0, 2147483647)]
        [int]
        $LineNumber = 0,

        [ValidateRange(0, 2147483647)]
        [int]
        $ColumnNumber = 0,

        [ValidateRange(0, 65535)]
        [int]
        $Code = 0
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if (Test-PSParameter -Name 'SourcePath' -Parameters $PSBoundParameters) {
        $toStdOut = '##vso[task.logissue type={0};sourcepath={1};linenumber={2};columnnumber={3};code={4}]{5}' -f $IssueType, $SourcePath, $LineNumber, $ColumnNumber, $Code, $Message
    }
    else {
        $toStdOut = '##vso[task.logissue type={0}]{1}' -f $IssueType, $Message
    }

    $toStdOut | Write-Output

    <#
        .SYNOPSIS
        A brief description of function `Format-LogIssue`.

        .DESCRIPTION
        A detailed description of function `Format-LogIssue`.

        .PARAMETER IssueType
        The type of issue to log.  This parameter is mandatory.  It must be one
        of the following values:  'error', 'warning'.

        .PARAMETER Message
        The message to log.  This parameter is mandatory.  It must not be null
        or empty.

        .PARAMETER SourcePath
        The path to the source file.  This parameter is optional.  It must be a
        valid path to a file.

        .PARAMETER LineNumber
        The line number of the issue.  This parameter is optional.  It must be a
        number between 0 and 2147483647.

        .PARAMETER ColumnNumber
        The column number of the issue.  This parameter is optional.  It must be
        a number between 0 and 2147483647.

        .PARAMETER Code
        The code of the issue.  This parameter is optional.  It must be a number
        between 0 and 65535.

        .EXAMPLE
        PS> Format-LogIssue -IssueType 'error' -Message 'Error Message'

        ##vso[task.logissue type=error]Error Message

        .EXAMPLE
        PS> Format-LogIssue -IssueType 'error' -Message 'Error Message' -SourcePath 'C:\TEMP\Error.log'

        ##vso[task.logissue type=error;sourcepath=C:\TEMP\Error.log]Error Message

        .INPUTS
        None.  `Format-LogIssue` takes no input from
        the pipeline.

        .OUTPUTS
        [System.String].  `Format-LogIssue` outputs a formatted string to the
        pipeline.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        Show-Detail

        .LINK
        .Write-Output
    #>
}

<#
    Format-ArtifactUpload
#>
function Format-ArtifactUpload {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $FilePath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ArtifactName,

        [ValidateNotNullOrEmpty()]
        [string]
        $ContainerFolder
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if (Test-PSParameter -Name 'ContainerFolder' -Parameters $PSBoundParameters) {
            $toStdOut = '##vso[artifact.upload containerfolder={0};artifactname={1}]{2}' -f $ContainerFolder, $ArtifactName, $FilePath
        }
        else {
            $toStdOut = '##vso[artifact.upload artifactname={0}]{1}' -f $ArtifactName, $FilePath
        }

        if ($PSCmdlet.ShouldProcess($FilePath, "Uploading as Artifact Name $($ArtifactName)")) {
            $toStdOut | Write-Output
        }
    }

    <#
        .SYNOPSIS
        A brief description of function `Format-ArtifactUpload`.

        .DESCRIPTION
        A detailed description of function `Format-ArtifactUpload`.

        .PARAMETER AttachmentName
        The artifact name.  This parameter is mandatory.

        .PARAMETER FilePath
        The file path to the artifact to publish.  This parameter is mandatory.  It
        must be a valid and existing file.

        .PARAMETER ContainerFolder
        The container for the artifact.  This parameter is optional.  It must not
        be null or empty.

        .INPUTS
        [System.String].  `Format-ArtifactUpload` takes file path strings as input from the pipeline.

        .OUTPUTS
        [System.String].  `Format-ArtifactUpload` outputs a formatted string to the pipeline.

        .EXAMPLE
        PS> Format-ArtifactUpload -AttachmentName 'Installer' -FilePath 'C:\TEMP\Installer.msi'

        .EXAMPLE
        PS> Format-ArtifactUpload -AttachmentName 'Installer' -FilePath 'C:\TEMP\Installer.msi' -ContainerFolder 'Installer'

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        Show-Detail

        .LINK
        .Write-Output
    #>
}

<#
    Format-UploadLog
#>
function Format-UploadLog {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $FilePath
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ShouldProcess($LogPath, "Uploading as Log")) {
            ('##vso[build.uploadlog]{0}' -f $FilePath) | Write-Output
        }
    }

    <#
        .SYNOPSIS
        A brief description of function `Format-UploadLog`.

        .DESCRIPTION
        A detailed description of function `Format-UploadLog`.

        .PARAMETER FilePath
        The path to the log file.  This parameter is mandatory.  It must be a valid
        and existing path to a file.

        .EXAMPLE
        PS> Format-UploadLog -FilePath 'C:\TEMP\MSI.log'

        .INPUTS
        [System.String].  `Format-UploadLog` takes file path strings as input from the pipeline.

        .OUTPUTS
        [System.String].  `Format-UploadLog` outputs a formatted string to the
        pipeline.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        Show-Detail

        .LINK
        .Write-Output
    #>
}

<#
    Format-SetProgress
#>
function Format-SetProgress {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Title,

        [Parameter(Mandatory)]
        [ValidateRange(0, 100)]
        [int]
        $Percent
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    ('##vso[task.setprogress value={0};]{1}' -f $Percent, $Title) | Write-Output

    <#
        .SYNOPSIS
        A brief description of function `Format-SetProgress`.

        .DESCRIPTION
        A detailed description of function `Format-SetProgress`.

        .PARAMETER Title
        The title of the progress.  This parameter is mandatory.  It must not be
        null or empty.

        .PARAMETER Percent
        The percentage of the progress.  This parameter is mandatory.  It must be
        a number between 0 and 100.

        .EXAMPLE
        PS> Format-SetProgress -Title 'Progress Title' -Percent 50

        ##vso[task.setprogress value=50;]Progress Title

        .INPUTS
        None.  `Format-SetProgress` does not take input from the pipeline.

        .OUTPUTS
        [System.String].  `Format-SetProgress` outputs a formatted string to the
        pipeline.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        Show-Detail

        .LINK
        Write-Output
    #>
}

<#
    Format-SetVariable
#>
function Format-SetVariable {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory)]
        [AllowNull()]
        [string]
        $Value,

        [Parameter(Mandatory, ParameterSetName = 'UsingOutput')]
        [switch]
        $IsOutput,

        [Parameter(Mandatory, ParameterSetName = 'UsingReadonly')]
        [switch]
        $IsReadonly,

        [Parameter(Mandatory, ParameterSetName = 'UsingSecret')]
        [switch]
        $IsSecret
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if ($IsOutput.IsPresent) {
        $toStdOut = '##vso[task.setvariable variable={0};isoutput=true]{1}' -f $Name, $Value
    }
    elseif ($IsReadonly.IsPresent) {
        $toStdOut = '##vso[task.setvariable variable={0};isreadonly=true]{1}' -f $Name, $Value
    }
    elseif ($IsSecret.IsPresent) {
        $toStdOut = '##vso[task.setvariable variable={0};issecret=true]{1}' -f $Name, $Value
    }
    else {
        $toStdOut = '##vso[task.setvariable variable={0};]{1}' -f $Name, $Value
    }

    if ($PSCmdlet.ShouldProcess($Value, "Setting Variable $($Name)")) {
        $toStdOut | Write-Output
    }

    <#
        .SYNOPSIS
        A brief description of function `Format-SetVariable`.

        .DESCRIPTION
        A detailed description of function `Format-SetVariable`.

        .PARAMETER Name
        The name of the variable to set.  This parameter is mandatory.  It must
        not be null or empty.

        .PARAMETER Value
        The value to set the variable to.  This parameter is mandatory.  It can
        be null or empty.

        .PARAMETER IsOutput
        A switch parameter to set the variable as an output.  This parameter is
        optional.

        .PARAMETER IsReadonly
        A switch parameter to set the variable as read-only.  This parameter is
        optional.

        .PARAMETER IsSecret
        A switch parameter to set the variable as a secret.  This parameter is
        optional.

        .EXAMPLE
        PS> Format-SetVariable -Name 'VariableName' -Value 'VariableValue'

        ##vso[task.setvariable variable=VariableName;]VariableValue

        Set the variable `VariableName` to `VariableValue`.

        .EXAMPLE
        PS> Format-SetVariable -Name 'VariableName' -Value 'VariableValue' -IsOutput

        ##vso[task.setvariable variable=VariableName;isoutput=true]VariableValue

        Set the variable `VariableName` to `VariableValue` as an output.

        .INPUTS
        None.  `Format-SetVariable` does not take input from the pipeline.

        .OUTPUTS
        [System.String].  `Format-SetVariable` outputs a formatted string to the
        pipeline.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        Show-Detail

        .LINK
        .Write-Output
    #>
}

<#
    Format-UploadSummary
#>
function Format-UploadSummary {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $FilePath
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ShouldProcess($FilePath, "Uploading as Summary")) {
            ('##vso[task.uploadsummary]{0}' -f $FilePath) | Write-Output
        }
    }

    <#
        .SYNOPSIS
        A brief description of function `Format-UploadSummary`.

        .DESCRIPTION
        A detailed description of function `Format-UploadSummary`.

        .PARAMETER FilePath
        The file path of the summary to attach to the workflow.  This parameter is
        mandatory.  It must be a path to an existing file.

        .EXAMPLE
        PS> Format-UploadSummary -FilePath 'C:\TEMP\Summary.md'

        ##vso[task.uploadsummary]C:\TEMP\Summary.md

        Uploads the `C:\TEMP\Summary.md` mark-up file.

        .INPUTS
        [System.String].  `Format-UploadSummary` takes file path strings as input from the pipeline.

        .OUTPUTS
        [System.String].  `Format-UploadSummary` outputs a formatted string to the
        pipeline.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        Show-Detail

        .LINK
        .Write-Output
    #>
}

<#
    Format-UploadFile
#>
function Format-UploadFile {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $FilePath
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ShouldProcess($FilePath, "Uploading File")) {
            ('##vso[task.uploadfile]{0}' -f $FilePath) | Write-Output
        }
    }

    <#
        .SYNOPSIS
        A brief description of function `Format-UploadFile`.

        .DESCRIPTION
        A detailed description of function `Format-UploadFile`.

        .PARAMETER FilePath
        The file path to be submitted with the workflow.

        .EXAMPLE
        PS> Format-UploadFile -FilePath 'C:\TEMP\temp.tmp'

        ##vso[task.uploadfile]C:\TEMP\temp.tmp

        Upload the `C:\TEMP\temp.tmp` file.

        .INPUTS
        [System.String].  `Format-UploadFile` takes file path strings as input from the pipeline.

        .OUTPUTS
        [System.String].  `Format-UploadFile` outputs a formatted string to the
        pipeline.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        Show-Detail

        .LINK
        Write-Output
    #>
}

<#
    Format-PrependPath
#>
function Format-PrependPath {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
        [string]
        $Path
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ShouldProcess($Path, "Pre-pending to PATH")) {
            ('##vso[task.prependpath]{0}' -f $Path) | Write-Output
        }
    }

    <#
        .SYNOPSIS
        A brief description of function `Format-PrependPath`.

        .DESCRIPTION
        A detailed description of function `Format-PrependPath`.

        .PARAMETER Path
        The path to prepend to the `PATH` environment variable.  This parameter is
        mandatory.  It must be a valid and existing container.

        .EXAMPLE
        PS> Format-PrependPath -Path 'C:\Windows\System32'

        $env:PATH
        C:\Windows\System32; . . .

        Pre-pends `C:\Windows\System32' to the front of $env:PATH

        .INPUTS
        [System.String].  `Format-PrependPath` takes path strings as input from the pipeline.

        .OUTPUTS
        [System.String].  `Format-PrependPath` outputs a formatted string to the
        pipeline.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        Show-Detail

        .LINK
        Write-Output
    #>
}

<#
    Format-UpdateBuildNumber
#>
function Format-UpdateBuildNumber {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'UsingBuildNumber')]
        [ValidateNotNullOrEmpty()]
        [string]
        $BuildNumber,

        [Parameter(Mandatory = $true, ParameterSetName = 'UsingBuildVersion')]
        [ValidateNotNullOrEmpty()]
        [Version]
        $BuildVersion
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if ($PSCmdlet.ParameterSetName -eq 'UsingBuildNumber') {
        if ($PSCmdlet.ShouldProcess($BuildNumber, "Updating BuildNumber")) {
            ('##vso[build.updatebuildnumber]{0}' -f $BuildNumber) | Write-Output
        }
    }
    else {
        if ($PSCmdlet.ShouldProcess($BuildVersion, "Updating BuildNumber")) {
            ('##vso[build.updatebuildnumber]{0}' -f $BuildVersion.ToString()) | Write-Output
        }
    }

    <#
        .SYNOPSIS
        A brief description of function `Format-UpdateBuildNumber`.

        .DESCRIPTION
        A detailed description of function `Format-UpdateBuildNumber`.

        .PARAMETER BuildNumber
        The build number string to update.

        .PARAMETER BuildVersion
        The build version quad to update.

        .EXAMPLE
        PS> Format-UpdateBuildNumber -BuildNumber '1.2.3-RC1'

        ##vso[build.updatebuildnumber]1.2.3-RC1

        Updates the BuildNumber with a semantic version build number string.

        .EXAMPLE
        PS> Format-UpdateBuildNumber -BuildVersion 1.2.3.4

        ##vso[build.updatebuildnumber]1.2.3.4

        Updates the BuildNumber to a [System.Version] build number.

        .INPUTS
        None.  `Format-UpdateBuildNumber` does not take input from the pipeline.

        .OUTPUTS
        [System.String].  `Format-UpdateBuildNumber` outputs a formatted string to the
        pipeline.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        Show-Detail

        .LINK
        Write-Output
    #>
}

<#
    Format-UpdateReleaseName
#>
function Format-UpdateReleaseName {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ReleaseName
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if ($PSCmdlet.ShouldProcess($ReleaseName, "Updating ReleaseName")) {
        ('##vso[release.updatereleasename]{0}' -f $ReleaseName) | Write-Output
    }

    <#
        .SYNOPSIS
        A brief description of function `Format-UpdateReleaseName`.

        .DESCRIPTION
        A detailed description of function `Format-UpdateReleaseName`.

        .PARAMETER ReleaseName
        The new release name to use.

        .EXAMPLE
        PS> Format-UpdateReleaseName -ReleaseName 'This_Is_a_Release'

        ##vso[release.updatereleasename]This_Is_a_Release

        Updates the ReleaseName to This_Is_a_Release when passed to `Write-Host`.

        .INPUTS
        None.  `Format-UpdateReleaseName` does not take input from the pipeline.

        .OUTPUTS
        [System.String].  `Format-UpdateReleaseName` outputs a formatted string to the
        pipeline.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        Show-Detail

        .LINK
        Write-Output
    #>
}

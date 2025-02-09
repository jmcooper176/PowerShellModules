<#
 =============================================================================
<copyright file="UriModule.psm1" company="U.S. Office of Personnel
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
This file "UriModule.psm1" is part of "UriModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#
    Format-UriDataString
#>
function Format-UriDataString {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Uri -Uri $_ -Kind RelativeOrAbsolute })]
        [string]
        $StringToEscape,
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $StringToEscape | ForEach-Object -Process {
            Write-Verbose -Message "Escaping data string"
            [uri]::EscapeDataString($_) | Write-Output
        }
    }

    <#
        .SYNOPSIS
        Escapes the characters in an otherwise well-formed relative or absolute [uri].

        .DESCRIPTION
        `Format-UriDataString` escapes characters in an otherwise well-formed relative or absolute [uri].

        .PARAMETER StringToEscape
        Specifies the original [uri] string to escape.

        .INPUTS
        [string]  `Format-UriDataString` accepts a [string] original [uri] string as input.

        .OUTPUTS
        [string]  `Format-UriDataString` outputs a escaped [string] version of the original [uri] string.

        .EXAMPLE
        PS C:\> 'http://www.contoso.com/index.htm?name=John Doe' | Format-UriDataString

        This command escapes the characters in the original [uri] string.

        .NOTES
        Copyright © 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Test-Uri

        .LINK
        Write-Output

        .LINK
        Write-Verbose
    #>
}

<#
    Join-Uri
#>
function Join-Uri {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-SchemeName -SchemeName $_ })]
        [string]
        $Scheme,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-HostName -HostName $_ })]
        [string]
        $HostName,

        [ValidateRange(-1, 65535)]
        [int]
        $Port,

        [ValidateNotNullOrEmpty()]
        [string]
        $Path = '/',

        [ValidateNotNullOrEmpty()]
        [string]
        $Query
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ((Test-PSParameter -Name 'Port' -Parameters $PSBoundParameters) -and (Test-PSParameter -Name 'Path' -Parameters $PSBoundParameters) -and (Test-PSParameter -Name 'Query' -Parameters $PSBoundParameters)) {
            Write-Verbose -Message "$($CmdletName) : Joining Uri with Scheme, HostName, Port, Path, and Query"
            [UriBuilder]::new($Scheme, $HostName, $Port, $Path, $Query).ToString() | Format-UriDataString | Write-Output
        }
        elseif ((Test-PSParameter -Name 'Port' -Parameters $PSBoundParameters) -and (Test-PSParameter -Name 'Path' -Parameters $PSBoundParameters)) {
            Write-Verbose -Message "$($CmdletName) : Joining Uri with Scheme, HostName, Port, and Path"
            [UriBuilder]::new($Scheme, $HostName, $Port, $Path).ToString() | Format-UriDataString | Write-Output
        }
        elseif (Test-PSParameter -Name 'Port' -Parameters $PSBoundParameters) {
            Write-Verbose -Message "$($CmdletName) : Joining Uri with Scheme, HostName, and Port"
            [UriBuilder]::new($Scheme, $HostName, $Port).ToString() | Format-UriDataString | Write-Output
        }
        else {
            Write-Verbose -Message "$($CmdletName) : Joining Uri with Scheme and HostName"
            [UriBuilder]::new($Scheme, $HostName).ToString() | Format-UriDataString | Write-Output
        }
    }

    <#
        .SYNOPSIS
        Joins [uri] components to create a new [uri].

        .DESCRIPTION
        `Join-Uri` joins [uri] components to create a new [uri].

        .PARAMETER Scheme
        Specifies the scheme component of the [uri].  Validation is performed by the `Test-SchemeName` function.

        .PARAMETER HostName
        Specifies the host name component of the [uri].  Validation is performed by the `Test-HostName` function.

        .PARAMETER Port
        Specifies the port component of the [uri].  Port must be between -1 and 65535 inclusive.

        .PARAMETER Path
        Specifies the path portion of the [uri].  Defaults to '/' if not provided.

        .PARAMETER Query
        Specifies the query portion of the [uri].

        .INPUTS
        [string]  `Join-Uri` accepts [string] for components `Scheme` and `HostName`.

        .OUTPUTS
        `Join-Uri` returns an original [uri] string comprised of the component(s) to the PowerShell pipeline.

        .EXAMPLE
        PS> Join-Uri -Scheme 'http' -HostName 'www.contoso.com' -Port 80 -Path '/index.htm' -Query 'name=John Doe'

        http://www.contoso.com:80/index.htm?name=John%20Doe

        Returns a new [uri] original string.

        .NOTES
        Copyright © 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced
    #>
}

<#
    New-RelativeUri
#>
function New-RelativeUri {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([uri])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Uri -Uri $_ })]
        [uri]
        $Base,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Uri -Uri $_ -Kind RelativeOrAbsolute })]
        [uri]
        $Uri
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name -WhatIf:$false
    }

    PROCESS {
        $Base | ForEach-Object -Process {
            if ($PSCmdlet.ShouldProcess($Uri, $CmdletName)) {
                if (Test-BaseOf -Base $_ -Uri $Uri) {
                    Write-Verbose -Message "$($CmdletName) : Creating relative Uri to Base"
                    $_.MakeRelativeUri($Uri) | Write-Output
                }
                else {
                    Write-Warning -Message "$($CmdletName) : Parameter 'Base' is not the base of Parameter 'Uri'"
                    $Uri | Write-Output
                }
            }
        }
    }

    <#
        .SYNOPSIS
        Creates a new relative [uri] from a base [uri].

        .DESCRIPTION
        `New-RelativeUri` creates a new relative [uri] from a base [uri].  The Parameter `Base` is processed as the base.  The Parameter `Uri` must have `Base` as a possible root.  If `Base` in not the base of `Uri`, the original `Uri` is returned.

        .PARAMETER Base
        Specifies the base [uri] to use as the root for the new relative [uri].  Validation is performed by the `Test-Uri` function.

        .PARAMETER Uri
        Specifies the [uri] to use as the source for the new relative [uri].  Validation is performed by the `Test-Uri` function.

        .INPUTS
        [uri]  Both Parameters `Base` and `Uri` are accepted as input from the pipeline.  `Uri` must be from a property of that name on the pipeline object.  `Base` can either be passed by value or as a property of the pipeline object.

        .OUTPUTS
        [uri]  `New-RelativeUri` returns a new relative [uri] to the PowerShell pipeline.

        .EXAMPLE
        PS> $base = 'http://www.contoso.com/'
        PS> $uri = 'http://www.contoso.com/employee/index.htm?name=John%20Doe'
        PS> $uri | New-RelativeUri -Base $base

        employee/index.htm?name=John%20Doe

        Returns a new relative [uri] string.

        .NOTES
        Copyright © 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced
    #>
}

<#
    Split-Uri
#>
function Split-Uri {
    [CmdletBinding(DefaultParameterSetName = 'UsingAbsoluteUri')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Uri -Uri $_ })]
        [uri]
        $Source,

        [ValidateSet('UriEscaped', 'Unescaped', 'SafeUnescaped')]
        [UriFormat]
        $Format = 'SafeUnescaped',

        [Parameter(Mandatory, ParameterSetName = 'UsingAbsoluteUri')]
        [switch]
        $AbsoluteUri,

        [Parameter(Mandatory, ParameterSetName = 'UsingFragment')]
        [switch]
        $Fragment,

        [Parameter(Mandatory, ParameterSetName = 'UsingHost')]
        [switch]
        $Host,

        [Parameter(Mandatory, ParameterSetName = 'UsingHostAndPort')]
        [switch]
        $HostAndPort,

        [Parameter(Mandatory, ParameterSetName = 'UsingHttpRequestUrl')]
        [switch]
        $HttpRequestUrl,

        [Parameter(Mandatory, ParameterSetName = 'UsingNormalizedHost')]
        [switch]
        $NormalizedHost,

        [Parameter(Mandatory, ParameterSetName = 'UsingPath')]
        [switch]
        $Path,

        [Parameter(Mandatory, ParameterSetName = 'UsingPathAndQuery')]
        [switch]
        $PathAndQuery,

        [Parameter(Mandatory, ParameterSetName = 'UsingPort')]
        [switch]
        $Port,

        [Parameter(Mandatory, ParameterSetName = 'UsingQuery')]
        [switch]
        $Query,

        [Parameter(Mandatory, ParameterSetName = 'UsingScheme')]
        [switch]
        $Scheme,

        [Parameter(Mandatory, ParameterSetName = 'UsingSchemeAndServer')]
        [switch]
        $SchemeAndServer,

        [Parameter(Mandatory, ParameterSetName = 'UsingSerializationInfoString')]
        [switch]
        $SerializeationInfoString,

        [Parameter(Mandatory, ParameterSetName = 'UsingStrongAuthority')]
        [switch]
        $trongAuthority,

        [Parameter(Mandatory, ParameterSetName = 'UsingStrongPort')]
        [switch]
        $StrongPort,

        [Parameter(Mandatory, ParameterSetName = 'UsingUserInfo')]
        [switch]
        $UserInfo,

        # Can be applied to Query, Fragment, Scheme, UserInfo, Port, and Path.  Has no effect for all others.
        [switch]
        $KeepDelimiter
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $Source | ForEach-Object -Process {
            switch ($PSCmdlet.ParameterSetName) {
                'UsingAbsoluteUri' {
                    $component = [UriComponents]::AbsoluteUri
                    Write-Verbose -Message "$($CmdletName) : Attempting to convert Component to Absolute Uri"
                    $_.GetComponents($component, $Format) | Write-Output
                    break
                }

                'UsingFragment' {
                    $component = [UriComponents]::Fragment

                    if ($KeepDelimiter.IsPresent) {
                        Write-Verbose -Message "$($CmdletName) : Keeping delimiter for Fragment component"
                        $component = [UriComponents]::Fragment -bor [UriComponents]::KeepDelimiter
                    }

                    Write-Verbose -Message "$($CmdletName) : Returning Fragment component"
                    $_.GetComponents($component, $Format) | Write-Output
                    break
                }

                'UsingHost' {
                    $component = [UriComponents]::Host
                    Write-Verbose -Message "$($CmdletName) : Returning Host component"
                    $_.GetComponents($component, $Format) | Write-Output
                    break
                }

                'UsingHostAndPort' {
                    $component = [UriComponents]::HostAndPort
                    Write-Verbose -Message "$($CmdletName) : Returning Host and Port components"
                    $_.GetComponents($component, $Format) | Write-Output
                    break
                }

                'UsingHttpRequestUrl' {
                    $component = [UriComponents]::HttpRequestUrl
                    Write-Verbose -Message "$($CmdletName) : Returning HTTP Request URL component"
                    $_.GetComponents($component, $Format) | Write-Output
                    break
                }

                'UsingNormalizedHost' {
                    $component = [UriComponents]::NormalizedHost
                    Write-Verbose -Message "$($CmdletName) : Returning Normalized Host component"
                    $_.GetComponents($component, $Format) | Write-Output
                    break
                }

                'UsingPath' {
                    $component = [UriComponents]::Path

                    if ($KeepDelimiter.IsPresent) {
                        Write-Verbose -Message "$($CmdletName) : Keeping delimiter for Path component"
                        $component = [UriComponents]::Path -bor [UriComponents]::KeepDelimiter
                    }

                    Write-Verbose -Message "$($CmdletName) : Returning Path component"
                    $_.GetComponents($component, $Format) | Write-Output
                    break
                }

                'UsingPathAndQuery' {
                    $component = [UriComponents]::PathAndQuery
                    Write-Verbose -Message "$($CmdletName) : Returning Path and Query components"
                    $_.GetComponents($component, $Format) | Write-Output
                    break
                }

                'UsingPort' {
                    $component = [UriComponents]::Port

                    if ($KeepDelimiter.IsPresent) {
                        Write-Verbose -Message "$($CmdletName) : Keeping delimiter for Port component"
                        $component = [UriComponents]::Port -bor [UriComponents]::KeepDelimiter
                    }

                    Write-Verbose -Message "$($CmdletName) : Returning Port component"
                    $_.GetComponents($component, $Format) | Write-Output
                    break
                }

                'UsingQuery' {
                    $component = [UriComponents]::Query

                    if ($KeepDelimiter.IsPresent) {
                        Write-Verbose -Message "$($CmdletName) : Keeping delimiter for Query component"
                        $component = [UriComponents]::Query -bor [UriComponents]::KeepDelimiter
                    }

                    Write-Verbose -Message "$($CmdletName) : Returning Query component"
                    $_.GetComponents($component, $Format) | Write-Output
                    break
                }

                'UsingScheme' {
                    $component = [UriComponents]::Scheme

                    if ($KeepDelimiter.IsPresent) {
                        Write-Verbose -Message "$($CmdletName) : Keeping delimiter for Scheme component"
                        $component = [UriComponents]::Scheme -bor [UriComponents]::KeepDelimiter
                    }

                    Write-Verbose -Message "$($CmdletName) : Returning Scheme component"
                    $_.GetComponents($component, $Format) | Write-Output
                    break
                }

                'UsingSchemeAndServer' {
                    $component = [UriComponents]::SchemeAndServer
                    Write-Verbose -Message "$($CmdletName) : Returning Scheme and Server components"
                    $_.GetComponents($component, $Format) | Write-Output
                    break
                }

                'UsingSerializationInfoString' {
                    $component = [UriComponents]::SerializationInfoString
                    Write-Verbose -Message "$($CmdletName) : Returning Serialization Info String component"
                    $_.GetComponents($component, $Format) | Write-Output
                    break
                }

                'UsingStrongAuthority' {
                    $component = [UriComponents]::StrongAuthority
                    Write-Verbose -Message "$($CmdletName) : Returning Strong Authority component"
                    $_.GetComponents($component, $Format) | Write-Output
                    break
                }

                'UsingStrongPort' {
                    $component = [UriComponents]::StrongPort
                    Write-Verbose -Message "$($CmdletName) : Returning Strong Port component"
                    $_.GetComponents($component, $Format) | Write-Output
                    break
                }

                'UsingUserInfo' {
                    $component = [UriComponents]::UserInfo

                    if ($KeepDelimiter.IsPresent) {
                        Write-Verbose -Message "$($CmdletName) : Keeping delimiter for UserInfo component"
                        $component = [UriComponents]::UserInfo -bor [UriComponents]::KeepDelimiter
                    }

                    Write-Verbose -Message "$($CmdletName) : Returning UserInfo component"
                    $_.GetComponents($component, $Format) | Write-Output
                    break
                }
            }
        }
    }

    <#
        .NOTES
        Copyright © 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced
    #>
}

<#
    Test-BaseOf
#>
function Test-BaseOf {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Uri -Uri $_ })]
        [uri]
        $Base,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Uri -Uri $_ -Kind RelativeOrAbsolute })]
        [uri]
        $Uri
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $Base | ForEach-Object -Process {
            Write-Verbose -Message "$($CmdletName) : Validating Parameter 'Base' is base of Parameter 'Uri'"
            $_.IsBaseOf($Uri) | Write-Output
        }
    }

    <#
        .NOTES
        Copyright © 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced
    #>
}

<#
    Test-HostName
#>
function Test-HostName {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $HostName
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $HostName | ForEach-Object -Process {
            if ([string]::IsNullOrWhiteSpace($_)) {
                Write-Warning -Message "$($CmdletName) : Parameter 'HostName' is null, empty, or all whitespace"
                $false | Write-Output
            }
            else {
                Write-Verbose -Message "$($CmdletName) : Validating Parameter 'HostName'"
                [uri]::CheckHostName($_) -ne [UriHostNameType]::Unknown | Write-Output
            }
        }
    }

    <#
        .NOTES
        Copyright © 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced
    #>
}

<#
    Test-SchemeName
#>
function Test-SchemeName {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $SchemeName
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $SchemeName | ForEach-Object -Process {
            if ([string]::IsNullOrWhiteSpace($_)) {
                Write-Warning -Message "$($CmdletName) : Parameter 'SchemeName' is null, empty, or all whitespace"
                $false | Write-Output
            }
            else {
                Write-Verbose -Message "$($CmdletName) : Validating Parameter 'SchemeName'"
                [uri]::CheckSchemeName($_) | Write-Output
            }
        }
    }

    <#
        .NOTES
        Copyright © 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced
    #>
}

<#
    Test-Uri
#>
function Test-Uri {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [uri]
        $Uri,

        [ValidateSet('RelativeOrAbsolute', 'Absolute', 'Relative')]
        [UriKind]
        $Kind = 'Absolute'
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $Uri | ForEach-Object -Process {
            if ($_ -eq $null) {
                Write-Warning -Message "$($CmdletName) : Parameter 'Uri' is null"
                $false | Write-Output
            }
            else {
                $str = $_.ToString()

                if ([string]::IsNullOrWhiteSpace($str)) {
                    Write-Warning -Message "$($CmdletName) : Parameter 'Uri' original string is null, empty, or all whitespace"
                    $false | Write-Output
                }
                elseif (-not $str.IsWellFormedOriginalString()) {
                    "Parameter 'Uri' original string is not well-formed" | Write-Warning
                    $false | Write-Output
                }
                else {
                    Write-Verbose -Message "$($CmdletName) : Validating Parameter 'Uri' is well-formed"
                    [uri]::IsWellFormedUriString($str, $Kind) | Write-Output
                }
            }
        }
    }

    <#
        .SYNOPSIS
        Tests a [uri] as to whether it is a well-formed original [uri] string for Parameter `Kind` [urikind].

        .DESCRIPTION
        `Test-Uri` tests a [uri] as to whether it is a well-formed original [uri] string for Parameter `Kind` [urikind].

        .PARAMETER Uri
        Specifies the [uri] under test.

        .PARAMETER Kind
        Specifies the [urikind] of the [uri] under test.  Defaults to 'Absolute'.

        .INPUTS
        [uri]  `Test-Uri` accepts a [uri] for testing from the pipeline.

        .OUTPUTS
        [bool]  `Test-Uri` returns a boolean value to the PowerShell pipeline; `true` if the [uri] is well-formed; `false` otherwise.

        .EXAMPLE
        PS> 'http://www.contoso.com/index.htm?name=John%20Doe' | Test-Uri

        True

        The pipe [uri] is a well-formed [uri] of kind 'Absolute'.

        .NOTES
        Copyright © 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output

        .LINK
        Write-Warning

        .LINK
        Write-Verbose
    #>
}

<#
    Undo-UriDataString
#>
function Undo-UriDataString {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Uri -Uri $_ -Kind RelativeOrAbsolute })]
        [string]
        $StringToUnescape,
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $StringToEscape | ForEach-Object -Process {
            Write-Verbose -Message "$($cmdletName) : Unescaping data string"
            [uri]::UnescapeDataString($_) | Write-Output
        }
    }

    <#
        .SYNOPSIS
        Un-escapes a [uri] original data string.

        .DESCRIPTION
        `Uri-UriDataString` un-escapes a [uri] original data string.

        .PARAMETER
        StringToUnescape
        Specifies the escaped [uri] string to un-escape.

        .INPUTS
        [string]  `Undo-UriDataString` takes a string to unescape as input.

        .OUTPUTS
        [string]  `Undo-UriDataString returns an un-escaped string to the PowerShell pipeline.

        .NOTES
        Copyright © 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Test-Uri

        .LINK
        Write-Output
    #>
}
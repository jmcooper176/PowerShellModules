#
# VersionModule.psm1
#

<#
    Compare-PerlVersion
#>
function Compare-PerlVersion {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(Mandatory)]
        [version]
        $Left,

        [Parameter(Mandatory)]
        [double]
        $Right
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    switch ($Right) {
        { $Left -lt (ConvertFrom-PerlVersion -PerlVersion $_) } { return -1 }
        { $Left -gt (ConvertFrom-PerlVersion -PerlVersion $_) } { return 1 }
        default { return 0 }
    }

    <#
        .SYNOPSIS
        Compare a Perl version to a System.Version object.

        .DESCRIPTION
        The `Compare-PerlVersion` cmdlet compares a Perl version to a System.Version object.

        .PARAMETER Left
        The System.Version object to compare.

        .PARAMETER Right
        The Perl version to compare.

        .INPUTS
        None.  You cannot pipe objects to `Compare-PerlVersion`.

        .OUTPUTS
        [int]  Returns -1 if the Left version is less than the Right version, 1 if the Left version is greater than the Right version, and 0 if the versions are equal.

        .EXAMPLE
        PS> Compare-PerlVersion -Left (New-Version -Major 5 -Minor 10 -Build 1 -Revision 0) -Right 5.0101

        0

        Compare the Perl version 5.0101 to the System.Version object with a major version of 5, a minor version of 10, a build version of 1, and a revision of 0.

        .NOTES
        Copyright © 2024-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ConvertFrom-PerlVersion

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable
    #>
}

<#
    Compare-PythonVersion
#>
function Compare-PythonVersion {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(Mandatory)]
        [version]
        $Left,

        [Parameter(Mandatory)]
        [string]
        $Right
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    switch ($Right) {
        { $Left -lt (ConvertFrom-PythonVersion -PythonVersion $_) } { return -1 }
        { $Left -gt (ConvertFrom-PythonVersion -PythonVersion $_) } { return 1 }
        default { return 0 }
    }

    <#
        .SYNOPSIS
        Compare a Python version to a System.Version object.

        .DESCRIPTION
        The `Compare-PythonVersion` cmdlet compares a Python version to a System.Version object.

        .PARAMETER Left
        The System.Version object to compare.

        .PARAMETER Right
        The Python version to compare.

        .INPUTS
        None.  You cannot pipe objects to `Compare-PythonVersion`.

        .OUTPUTS
        [int]  Returns -1 if the Left version is less than the Right version, 1 if the Left version is greater than the Right version, and 0 if the versions are equal.

        .EXAMPLE
        PS> Compare-PythonVersion -Left (New-Version -Major 3 -Minor 9 -Build 1 -Revision 0) -Right '3.9.1'

        0

        Compare the Python version 3.9.1 to the System.Version object with a major version of 3, a minor version of 9, a build version of 1, and a revision of 0.

        .NOTES
        Copyright © 2024-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ConvertFrom-PythonVersion

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable
    #>
}

<#
    Compare-StringVersion
#>
function Compare-StringVersion {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(Mandatory)]
        [version]
        $Left,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Right
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    switch ($Right) {
        { $Left -lt (ConvertFrom-StringVersion -Version $_) } { return -1 }
        { $Left -gt (ConvertFrom-StringVersion -Version $_) } { return 1 }
        default { return 0 }
    }

    <#
        .SYNOPSIS
        Compare a System.Version object to a string version.

        .DESCRIPTION
        The `Compare-StringVersion` cmdlet compares a System.Version object to a string version.

        .PARAMETER Left
        The System.Version object to compare.

        .PARAMETER Right
        The string version to compare.

        .INPUTS
        None.  You cannot pipe objects to `Compare-StringVersion`.

        .OUTPUTS
        [int]  Returns -1 if the Left version is less than the Right version, 1 if the Left version is greater than the Right version, and 0 if the versions are equal.

        .EXAMPLE
        PS> Compare-StringVersion -Left (New-Version -Major 1 -Minor 0 -Build 0 -Revision 0) -Right '1.0.0'

        0

        Compare the System.Version object with a major version of 1, a minor version of 0, a build version of 0, and a revision of 0 to the string version '1.0.0'.

        .NOTES
        Copyright © 2024-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ConvertFrom-StringVersion

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable
    #>
}

<#
    Compare-WindowsVersion
#>
function Compare-WindowsVersion {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(Mandatory)]
        [version]
        $Left,

        [Parameter(Mandatory)]
        [ulong]
        $Right
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    switch ($Right) {
        { $Left -lt (ConvertFrom-WindowsVersion -WindowsVersion $_) } { return -1 }
        { $Left -gt (ConvertFrom-WindowsVersion -WindowsVersion $_) } { return 1 }
        default { return 0 }
    }

    <#
        .SYNOPSIS
        Compare a Windows version to a System.Version object.

        .DESCRIPTION
        The `Compare-WindowsVersion` cmdlet compares a Windows version to a System.Version object.

        .PARAMETER Left
        The System.Version object to compare.

        .PARAMETER Right
        The Windows version to compare.

        .INPUTS
        None.  You cannot pipe objects to `Compare-WindowsVersion`.

        .OUTPUTS
        [int]  Returns -1 if the Left version is less than the Right version, 1 if the Left version is greater than the Right version, and 0 if the versions are equal.

        .EXAMPLE
        PS> Compare-WindowsVersion -Left (New-Version -Major 10 -Minor 0 -Build 19041 -Revision 0) -Right 10.0.19041.0

        0

        Compare the System.Version object with a major version of 10, a minor version of 0, a build version of 19041, and a revision of 0 to the Windows version 10.0.19041.0.

        .NOTES
        Copyright © 2024-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ConvertFrom-WindowsVersion

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable
    #>
}

<#
    ConvertFrom-PerlVersion
#>
function ConvertFrom-PerlVersion {
    [CmdletBinding()]
    [OutputType([version])]
    param (
        [Parameter(Mandatory)]
        [Alias('Version')]
        [double]
        $PerlVersion
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $major = [int]([System.Math]::Floor($PerlVersion))
    $shift = ($PerlVersion - $major) * 1000
    $minor = [int]([System.Math]::Floor($shift))
    $shift = ($shift - $minor) * 1000
    $patch = [int]([System.Math]::Floor($shift))

    New-Version -Major $major -Minor $minor -Build $patch -Revision 0 | Initialize-Version | Write-Output

    <#
        .SYNOPSIS
        Convert a Perl version to a System.Version object.
        .DESCRIPTION
        The `ConvertFrom-PerlVersion` cmdlet converts a Perl version to a System.Version object.

        .PARAMETER PerlVersion
        The Perl version to convert.

        .INPUTS
        None.  You cannot pipe objects to `ConvertFrom-PerlVersion`.

        .OUTPUTS
        [version]  Returns the System.Version object for the Perl version.

        .EXAMPLE
        PS> ConvertFrom-PerlVersion -PerlVersion 5.0101

        Major  Minor  Build  Revision
        -----  -----  -----  --------
            5     10      1        0

        Convert the Perl version 5.0101 to a System.Version object.

        .NOTES
        Copyright © 2024-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        New-Version

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output
    #>
}

<#
    ConvertFrom-PythonVersion
#>
function ConvertFrom-PythonVersion {
    [CmdletBinding()]
    [OutputType([version])]
    param (
        [Parameter(Mandatory)]
        [Alias('Version')]
        [string]
        $PythonVersion
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if ($PythonVersion.Contains("!")) {
        $parts = $PythonVersion -split '!'
        $elements = $parts[1] -split '.'
    } else {
        $elements = $PythonVersion -split '.'
    }

    if ($elements[0] -match '\d+') {
        $major = [int]$Matches[0]
    } else {
        $major = 0
    }

    if ($elements[1] -match '\d+') {
        $minor = [int]$Matches[0]
    } else {
        $minor = 0
    }

    if ($elements[2] -match '\d+') {
        $build = [int]$Matches[0]
    } else {
        $build = 0
    }

    if ($elements[3] -match '\d+') {
        $revision = [int]$Matches[0]
    } else {
        $revision = 0
    }

    New-Version -Major $major -Minor $minor -Build $build -Revision $revision | Initialize-Version | Write-Output

    <#
        .SYNOPSIS
        Convert a Python version to a System.Version object.

        .DESCRIPTION
        The `ConvertFrom-PythonVersion` cmdlet converts a Python version to a System.Version object.

        .PARAMETER PythonVersion
        The Python version to convert.

        .INPUTS
        None.  You cannot pipe objects to `ConvertFrom-PythonVersion`.

        .OUTPUTS
        [version]  Returns the System.Version object for the Python version.

        .EXAMPLE
        PS> ConvertFrom-PythonVersion -PythonVersion '3.9.1'

        Major  Minor  Build  Revision
        -----  -----  -----  --------
            3      9      1        0

        Convert the Python version 3.9.1 to a System.Version object.

        .NOTES
        Copyright © 2024-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        New-Version

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output
    #>
}

<#
    ConvertFrom-SemanticVersion
#>
function ConvertFrom-SemanticVersion {
    [CmdletBinding()]
    [OutputType([version])]
    param (
        [Parameter(Mandatory)]
        [Alias('Version')]
        [semver]
        $SemanticVersion
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $major = $SemanticVersion.Major
    $minor = $SemanticVersion.Minor
    $build = ($SemanticVersion.Patch -band 0xFFFF0000) -shr 16
    $revision = [Math]::Min(($SemanticVersion.Patch -band 0x0000FFFF), 65534)

    New-Version -Major $major -Minor $minor -Build $build -Revision $revision | Initialize-Version | Write-Output

    <#
        .SYNOPSIS
        Convert a Semantic version to a System.Version object.

        .DESCRIPTION
        The `ConvertFrom-SemanticVersion` cmdlet converts a Semantic version to a System.Version object.

        .PARAMETER SemanticVersion
        The Semantic version to convert.

        .INPUTS
        None.  You cannot pipe objects to `ConvertFrom-SemanticVersion`.

        .OUTPUTS
        [version]  Returns the System.Version object for the Semantic version.

        .EXAMPLE
        PS> ConvertFrom-SemanticVersion -SemanticVersion '1.0.0'

        Major  Minor  Build  Revision
        -----  -----  -----  --------
            1      0      0        0

        Convert the Semantic version 1.0.0 to a System.Version object.

        .NOTES
        Copyright © 2024-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        New-Version

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output
    #>
}

<#
    ConvertFrom-StringVersion
#>
function ConvertFrom-StringVersion {
    [CmdletBinding()]
    [OutputType([version])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Version,

        [switch]
        $Strict
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    [ref]$result = $null

    if ([System.Management.Automation.SemanticVersion]::TryParse($Version, $result)) {
        ConvertFrom-SemanticVersion -SemanticVersion $result.Value | Write-Output
    }
    elseif ([version]::TryParse($Version, $result)) {
        Initialize-Version -Version $result.Value -PE:$Strict.IsPresent | Write-Output
    }
    else {
        New-Version -Major 0 -Minor 0 -Build 0 -Revision 0 | Write-Output
    }

    <#
        .SYNOPSIS
        Convert a string version to a System.Version object.

        .DESCRIPTION
        The `ConvertFrom-StringVersion` cmdlet converts a string version to a System.Version object.

        .PARAMETER Version
        The string version to convert.

        .PARAMETER Strict
        Indicates that the conversion should be strict; that is, satisfy the requirements of the Windows PE object file header.

        .INPUTS
        None.  You cannot pipe objects to `ConvertFrom-StringVersion`.

        .OUTPUTS
        [version]  Returns the System.Version object for the string version.

        .EXAMPLE
        PS> ConvertFrom-StringVersion -Version '1.0.0'

        Major  Minor  Build  Revision
        -----  -----  -----  --------
            1      0      0        0

        Convert the string version '1.0.0' to a System.Version object.

        .EXAMPLE
        PS> ConvertFrom-StringVersion -Version '1.0.0' -Strict

        Major  Minor  Build  Revision
        -----  -----  -----  --------
            1      0      0        0

        Convert the string version '1.0.0' to a System.Version object with strict requirements.

        .NOTES
        Copyright © 2024-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        New-Version

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output
    #>
}

<#
    ConvertFrom-WindowsVersion
#>
function ConvertFrom-WindowsVersion {
    [CmdletBinding()]
    [OutputType([version])]
    param (
        [Parameter(Mandatory)]
        [Alias('Version')]
        [ulong]
        $WindowsVersion
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $revision = ($WindowsVersion) -band 0xFFFF
    $build = ($WindowsVersion -shr 16) -band 0xFFFF
    $minor = ($WindowsVersion -shr 32) -band 0xFFFF
    $major = ($windowsVersion -shr 48) -band 0xFFFF

    New-Version -Major $major -Minor $minor -Build $build -Revision $revision | Write-Output

    <#
        .SYNOPSIS
        Convert a Windows version to a System.Version object.

        .DESCRIPTION
        The `ConvertFrom-WindowsVersion` cmdlet converts a Windows version to a System.Version object.

        .PARAMETER WindowsVersion
        The Windows version to convert.

        .INPUTS
        None.  You cannot pipe objects to `ConvertFrom-WindowsVersion`.

        .OUTPUTS
        [version]  Returns the System.Version object for the Windows version.

        .EXAMPLE
        PS> ConvertFrom-WindowsVersion -WindowsVersion 2814751014977536

        Major  Minor  Build  Revision
        -----  -----  -----  --------
           10      0  19041        0

        Convert the Windows version 10.0.19041.0 to a System.Version object.

        .NOTES
        Copyright © 2024-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        New-Version

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output
    #>
}

<#
    Get-AssemblyVersion
#>
function Get-AssemblyVersion {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([version])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingPath', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -Path $_ -PathType 'Leaf' })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType 'Leaf' })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        try {
            if ($PSCmdlet.ParameterSetName -eq 'LiteralPath') {
                $LiteralPath | ForEach-Object -Process {
                    [System.Reflection.AssemblyName]::GetAssemblyName($_).Version | Write-Output
                }
            } else {
                $Path | Resolve-Path | ForEach-Object -Process {
                    [System.Reflection.AssemblyName]::GetAssemblyName($_).Version | Write-Output
                }
            }
        }
        catch {
            $Error | Write-Fatal
        }
    }

    <#
        .SYNOPSIS
        Get Assembly Version from the specified leaf location.

        .DESCRIPTION
        `Get-AssemblyVersion` gets the file version from the specified leaf location.

        .PARAMETER LiteralPath
        Specifies a path to one or more locations. The value of LiteralPath is used exactly as it's typed. No characters are
        interpreted as wildcards. If the path includes escape characters, enclose it in single quotation marks. Single quotation
        marks tell PowerShell not to interpret any characters as escape sequences.

        .INPUTS
        [string]  You can pipe a string that contains a path (possibly containing wildcards) or a literal path (no wildcards) to this cmdlet.

        .OUTPUTS
        [version]  Returns the file version for the path.

        .EXAMPLE
        PS> Get-AssemblyVersion 'C:\Windows\System32\mydotnetfile.exe'

        1.0.0.0

        Get the assembly version for the file `mydotnetfile.exe` in the `C:\Windows\System32` directory.

        .NOTES
        Copyright © 2023-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Resolve-Path

        .LINK
        Select-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output

        .LINK
        Write-Verbose
    #>
}

<#
    Get-FileVersion
#>
function Get-FileVersion {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType 'Leaf' })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType 'Leaf' })]
        [string[]]
        $LiteralPath,

        [string[]]
        $Exclude,

        [string]
        $Filter,

        [string[]]
        $Include,

        [switch]
        $Force
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Write-Information -MessageData "$($CmdletName):  Begin processing" -Tags @($cmdletName, 'Being', 'Process')

        $getFileVersionInfoSplat = @{
            Force = $Force.IsPresent
        }

        if (Test-PSParameter -Name 'Exclude' -Parameters $PSBoundParameters) {
            $getFileVersionInfoSplat.Add('Exclude', $Exclude)
        }

        if (Test-PSParameter -Name 'Filter' -Parameters $PSBoundParameters) {
            $getFileVersionInfoSplat.Add('Filter', $Filter)
        }

        if (Test-PSParameter -Name 'Include' -Parameters $PSBoundParameters) {
            $getFileVersionInfoSplat.Add('Include', $Include)
        }
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq "UsingLiteralPath") {
            $getFileVersionInfoSplat.Add('LiteralPath', $LiteralPath)
        } else {
            $getFileVersionInfoSplat.Add('Path', $Path)
        }

        Get-FileVersionInfo @getFileVersionInfoSplat | Select-Object -ExpandProperty 'FileVersion' | Write-Output
    }

    <#
        .SYNOPSIS
        Get File Version from the specified leaf location.

        .DESCRIPTION
        `Get-FileVersion` gets the file version from the specified leaf location.

        .PARAMETER Exclude
        Specifies, as a string array, an item or items that this cmdlet excludes in the operation. The value of this parameter
        qualifies the Path parameter. Enter a path element or pattern, such as ` .txt`. Wildcard characters are permitted. The
        Exclude * parameter is effective only when the command includes the contents of an item, such as `C:\Windows*`, where the
        wildcard character specifies the contents of the `C:\Windows` directory.

        .PARAMETER Filter
        Specifies a filter to qualify the Path parameter. Filters are more efficient than other parameters. The provider applies
        filter when the cmdlet gets the objects rather than having PowerShell filter the objects after they're retrieved. The
        filter string is passed to the .NET API to enumerate files. The API only supports `*` and `?` wildcards.

        .PARAMETER Force
        Indicates that this cmdlet gets items that can't otherwise be accessed, such as hidden items. Implementation varies from
        provider to provider. Even using the Force parameter, the cmdlet can't override security restrictions.

        .PARAMETER Include
        Specifies, as a string array, an item or items that this cmdlet includes in the operation. The value of this parameter
        qualifies the Path parameter. Enter a path element or pattern, such as ` .txt`. Wildcard characters are permitted. The
        Include * parameter is effective only when the command includes the contents of an item, such as `C:\Windows*`, where the
        wildcard character specifies the contents of the `C:\Windows` directory.

        .PARAMETER LiteralPath
        Specifies a path to one or more locations. The value of LiteralPath is used exactly as it's typed. No characters are
        interpreted as wildcards. If the path includes escape characters, enclose it in single quotation marks. Single quotation
        marks tell PowerShell not to interpret any characters as escape sequences.

        .PARAMETER Path
        Specifies the path to an item. This cmdlet gets the item at the specified location. Wildcard characters are permitted.
        This parameter is required, but the parameter name Path is optional.

        Use a dot (`.`) to specify the current location. Use the wildcard character (`*`) to specify all the items in the current
        location.

        .INPUTS
        [string]  You can pipe a string that contains a path to this cmdlet.

        .OUTPUTS
        [string]  Returns the file version string for the path.

        .EXAMPLE
        PS> Get-FileVersion 'C:\Windows\System32\notepad.exe'

        10.0.22621.1 (WinBuild.160101.0800)

        Returns the file version for the file `notepad.exe` in the `C:\Windows\System32` directory.

        .NOTES
        Copyright © 2023-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Get-Item

        .LINK
        Set-StrictMode
        .LINK
        Set-Variable

        .LINK
        Select-Object

        .LINK
        Write-Verbose
    #>
}

<#
    Get-FileVersionInfo
#>
function Get-FileVersionInfo {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([System.Diagnostics.FileVersionInfo])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType 'Leaf' })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType 'Leaf' })]
        [string[]]
        $LiteralPath,

        [string[]]
        $Exclude,

        [string]
        $Filter,

        [string[]]
        $Include,

        [switch]
        $Force
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        $getItemSplat = @{
            Force = $Force.IsPresent
        }

        if (Test-PSParameter -Name 'Exclude' -Parameters $PSBoundParameters) {
            $getItemSplat.Add('Exclude', $Exclude)
        }

        if (Test-PSParameter -Name 'Filter' -Parameters $PSBoundParameters) {
            $getItemSplat.Add('Filter', $Filter)
        }

        if (Test-PSParameter -Name 'Include' -Parameters $PSBoundParameters) {
            $getItemSplat.Add('Include', $Include)
        }
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq "UsingLiteralPath") {
            $getItemSplat.Add('LiteralPath', $LiteralPath)
        } else {
            $getItemSplat.Add('Path', $Path)
        }

        Get-Item @getItemSplat | Select-Object -ExpandProperty 'VersionInfo' | Write-Output
    }

    <#
        .SYNOPSIS
        Get File Version from the specified leaf location.

        .DESCRIPTION
        `Get-FileVersion` gets the file version from the specified leaf location.

        .PARAMETER Exclude
        Specifies, as a string array, an item or items that this cmdlet excludes in the operation. The value of this parameter
        qualifies the Path parameter. Enter a path element or pattern, such as ` .txt`. Wildcard characters are permitted. The
        Exclude * parameter is effective only when the command includes the contents of an item, such as `C:\Windows*`, where the
        wildcard character specifies the contents of the `C:\Windows` directory.

        .PARAMETER Filter
        Specifies a filter to qualify the Path parameter. Filters are more efficient than other parameters. The provider applies
        filter when the cmdlet gets the objects rather than having PowerShell filter the objects after they're retrieved. The
        filter string is passed to the .NET API to enumerate files. The API only supports `*` and `?` wildcards.

        .PARAMETER Force
        Indicates that this cmdlet gets items that can't otherwise be accessed, such as hidden items. Implementation varies from
        provider to provider. Even using the Force parameter, the cmdlet can't override security restrictions.

        .PARAMETER Include
        Specifies, as a string array, an item or items that this cmdlet includes in the operation. The value of this parameter
        qualifies the Path parameter. Enter a path element or pattern, such as ` .txt`. Wildcard characters are permitted. The
        Include * parameter is effective only when the command includes the contents of an item, such as `C:\Windows*`, where the
        wildcard character specifies the contents of the `C:\Windows` directory.

        .PARAMETER LiteralPath
        Specifies a path to one or more locations. The value of LiteralPath is used exactly as it's typed. No characters are
        interpreted as wildcards. If the path includes escape characters, enclose it in single quotation marks. Single quotation
        marks tell PowerShell not to interpret any characters as escape sequences.

        .PARAMETER Path
        Specifies the path to an item. This cmdlet gets the item at the specified location. Wildcard characters are permitted.
        This parameter is required, but the parameter name Path is optional.

        Use a dot (`.`) to specify the current location. Use the wildcard character (`*`) to specify all the items in the current
        location.

        .INPUTS
        [string]  You can pipe a string that contains a path to this cmdlet.

        .OUTPUTS
        [string]  Returns the file version string for the path.

        .NOTES
        Copyright © 2023-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .EXAMPLE
        PS> Get-FileVersion 'C:\Windows\System32\notepad.exe'

        10.0.22621.1 (WinBuild.160101.0800)

        Returns the file version for the file `notepad.exe` in the `C:\Windows\System32` directory.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Get-Item

        .LINK
        Select-Object

        .LINK
        Set-StrictMode
        .LINK
        Set-Variable

        .LINK
        Write-Verbose
    #>
}

<#
    Get-InformationalVersion
#>
function Get-InformationalVersion {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType 'Leaf' })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType 'Leaf' })]
        [string[]]
        $LiteralPath,

        [string[]]
        $Exclude,

        [string]
        $Filter,

        [string[]]
        $Include,

        [switch]
        $Force
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        $getFileVersionInfoSplat = @{
            Force = $Force.IsPresent
        }

        if (Test-PSParameter -Name 'Exclude' -Parameters $PSBoundParameters) {
            $getFileVersionInfoSplat.Add('Exclude', $Exclude)
        }

        if (Test-PSParameter -Name 'Filter' -Parameters $PSBoundParameters) {
            $getFileVersionInfoSplat.Add('Filter', $Filter)
        }

        if (Test-PSParameter -Name 'Include' -Parameters $PSBoundParameters) {
            $getFileVersionInfoSplat.Add('Include', $Include)
        }
    }

    PROCESS {
        Write-Verbose -Message "$($CmdletName):  Getting Product/Informational Version"

        if ($PSCmdlet.ParameterSetName -eq "UsingLiteralPath") {
            $getFileVersionInfoSplat.Add('LiteralPath', $LiteralPath)
        } else {
            $getFileVersionInfoSplat.Add('Path', $Path)
        }

        Get-FileVersionInfo @getFileVersionInfoSplat | Select-Object -ExpandProperty 'ProductVersion' | Write-Output
    }

    <#
        .SYNOPSIS
        Get the Informational or Product Version from the specified leaf location.

        .DESCRIPTION
        `Get-InformationalVersion` gets the informational or product version from the specified leaf location.

        .PARAMETER Exclude
        Specifies, as a string array, an item or items that this cmdlet excludes in the operation. The value of this parameter
        qualifies the Path parameter. Enter a path element or pattern, such as ` .txt`. Wildcard characters are permitted. The
        Exclude * parameter is effective only when the command includes the contents of an item, such as `C:\Windows*`, where the
        wildcard character specifies the contents of the `C:\Windows` directory.

        .PARAMETER Filter
        Specifies a filter to qualify the Path parameter. Filters are more efficient than other parameters. The provider applies
        filter when the cmdlet gets the objects rather than having PowerShell filter the objects after they're retrieved. The
        filter string is passed to the .NET API to enumerate files. The API only supports `*` and `?` wildcards.

        .PARAMETER Force
        Indicates that this cmdlet gets items that can't otherwise be accessed, such as hidden items. Implementation varies from
        provider to provider. Even using the Force parameter, the cmdlet can't override security restrictions.

        .PARAMETER Include
        Specifies, as a string array, an item or items that this cmdlet includes in the operation. The value of this parameter
        qualifies the Path parameter. Enter a path element or pattern, such as ` .txt`. Wildcard characters are permitted. The
        Include * parameter is effective only when the command includes the contents of an item, such as `C:\Windows*`, where the
        wildcard character specifies the contents of the `C:\Windows` directory.

        .PARAMETER LiteralPath
        Specifies a path to one or more locations. The value of LiteralPath is used exactly as it's typed. No characters are
        interpreted as wildcards. If the path includes escape characters, enclose it in single quotation marks. Single quotation
        marks tell PowerShell not to interpret any characters as escape sequences.

        .PARAMETER Path
        Specifies the path to an item. This cmdlet gets the item at the specified location. Wildcard characters are permitted.
        This parameter is required, but the parameter name Path is optional.

        Use a dot (`.`) to specify the current location. Use the wildcard character (`*`) to specify all the items in the current
        location.

        .INPUTS
        [string]  You can pipe a string that contains a path to this cmdlet.

        .OUTPUTS
        [string]  Returns the informational or product version string for the path.

        .NOTES
        Copyright © 2023-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .EXAMPLE
        PS> Get-InformationalVersion 'C:\Windows\System32\notepad.exe'

        10.0.22621.1

        Returns the informational or product version for the file `notepad.exe` in the `C:\Windows\System32` directory.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Get-FileVersionInfo

        .LINK
        Select-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Verbose
    #>
}

New-Alias -Name Get-ProductVersion -Value Get-InformationalVersion

<#
    Get-ModuleVersion
#>
function Get-ModuleVersion {
    [CmdletBinding(DefaultParameterSetName = 'UsingModuleManifest')]
    [OutputType([version])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingModuleName')]
        [ValidateNotNullOrEmpty()]
        [Alias('Name')]
        [string]
        $ModuleName,

        [Parameter(ParameterSetName = 'UsingModuleManifest')]
        [ValidateScript({ Test-Path -LiteralPath $_ -Include '*.psd1' -PathType 'Leaf' })]
        [string]
        $ModuleManifest
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if ($PSCmdlet.ParameterSetName -eq 'UsingModuleName') {
        Write-Verbose -Message "$($CmdletName):  Getting Module Version"
        Get-Module -ListAvailable |
            Where-Object -Property Name -EQ $ModuleName |
                Select-Object -ExpandProperty Version -First 1 | Write-Output
    }
    else {
        [version](Test-ModuleManifest -Path $ModuleManifest | Select-Object -ExpandProperty Version) | Write-Output
    }

    <#
        .SYNOPSIS
        Get the version of a module.

        .DESCRIPTION
        `Get-ModuleVersion` gets the version of a module.

        .PARAMETER ModuleName
        The name of the module to get the version of.

        .PARAMETER ModuleManifest
        Specifies the literal path to the module manifest, '.psd1' file.

        .INPUTS
        None.  `Get-ModuleVersion` does not take any PowerShell pipeline input.

        .OUTPUTS
        [version]  `Get-ModuleVersion` returns an instance to the PowerShell pipeline output.

        .NOTES
        Copyright © 2024-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Get-Module

        .LINK
        Select-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Where-Object

        .LINK
        Write-Output
    #>
}

<#
    Initialize-Version
#>
function Initialize-Version {
    [CmdletBinding(DefaultParameterSetName = 'UsingVersion')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingVersion', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [version]
        $Version,

        [Parameter(Mandatory, ParameterSetName = 'UsingSemanticVersion', ValueFromPipelineByPropertyName)]
        [semver]
        $SemanticVersion,

        [Parameter(ParameterSetName = 'UsingVersion')]
        [switch]
        $PE
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingSemanticVersion') {
            Set-Variable -Name MAX_MAJOR -Option Constant -Value 65534
            Set-Variable -Name MAX_MINOR -Option Constant -Value 65534
            Set-Variable -Name MAX_PATCH -Option Constant -Value 2147483647
            Set-Variable -Name MAX_BUILD -Option Constant -Value 21474
            Set-Variable -Name MAX_REVISION -Option Constant -Value 83647
            Set-Variable -Name BUILD_UNIT_REGEX -Option Constant -Value '^([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*)$'
            Set-Variable -Name LABEL_REGEX -Option Constant -Value '^(?<preLabel>(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*)?(?:\+(?<buildLabel>[0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$'
            Set-Variable -Name LABEL_UNIT_REGEX -Option Constant -Value '^((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*)$'
            Set-Variable -Name SEMANTIC_VERSION_PART_REGEX -Option Constant -Value '^(?<major>\d+)(\.(?<minor>\d+))?(\.(?<patch>\d+))?$'

            if ($SemanticVersion.Major -gt $MAX_MAJOR) {
                Write-Warning -Message "$($CmdletName):  Major greater than '$($MAX_MAJOR)' will not be comparable with System.Version"
                $major = $MAX_MAJOR
            } elseif ($SemanticVersion.Major -lt 0) {
                $newErrorRecordSplat = @{
                    Exception = [System.ArgumentException]::new('Version is de-normal with negative Major', 'SemanticVersion')
                    ErrorId = Format-ErrorId -Caller $CmdletName -Name 'ArgumentException' -Position $MyInvocation.ScriptLineNumber
                    ErrorCategory = 'InvalidArgument'
                    TargetObject = $SemanticVersion
                    TargetName = 'SemanticVersion'
                }

                New-ErrorRecord @newErrorRecordSplat | Write-Fatal
            } else {
                $major = $SemanticVersion.Major
            }

            if ($SemanticVersion.Minor -gt $MAX_MINOR) {
                Write-Warning -Message "$($CmdletName):  Minor greater than '$($MAX_MINOR)' will not be comparable with System.Version"
                $minor = $MAX_MINOR
            } elseif ($SemanticVersion.Minor -lt 0) {
                $newErrorRecordSplat = @{
                    Exception = [System.ArgumentException]::new('Version is de-normal with negative Minor', 'SemanticVersion')
                    ErrorId = Format-ErrorId -Caller $CmdletName -Name 'ArgumentException' -Position $MyInvocation.ScriptLineNumber
                    ErrorCategory = 'InvalidArgument'
                    TargetObject = $SemanticVersion
                    TargetName = 'SemanticVersion'
                }

                New-ErrorRecord @newErrorRecordSplat | Write-Fatal
            } else {
                $minor = $SemanticVersion.Minor
            }

            $revision = New-RevisionNumber -MaxRevision $MAX_REVISION

            if ($SemanticVersion.Patch -lt 0) {
                $newErrorRecordSplat = @{
                    Exception = [System.ArgumentException]::new('Version is de-normal with negative Patch', 'SemanticVersion')
                    ErrorId = Format-ErrorId -Caller $CmdletName -Name 'ArgumentException' -Position $MyInvocation.ScriptLineNumber
                    ErrorCategory = 'InvalidArgument'
                    TargetObject = $SemanticVersion
                    TargetName = 'SemanticVersion'
                }

                New-ErrorRecord @newErrorRecordSplat | Write-Fatal
            } elseif ((($SemanticVersion.Patch - $revision) / 100000) -gt $MAX_BUILD) {
                Write-Warning -Message "$($CmdletName):  Patch build part greater than '$($MAX_BUILD)' and will overflow a System.int"
                $build = $MAX_BUILD
                $patch = $build * 100000 + $revision
            } elseif (($SemanticVersion.Patch / 100000) -gt $MAX_REVISION) {
                Write-Warning -Message "$($CmdletName):  Patch revision part greater than '$($MAX_REVISION)' and may overflow a System.int"
                $revision = $MAX_REVISION
                $patch = $build * 100000 + $revision
            } else {
                $patch = $SemanticVersion.Patch
            }

            if (-not ([string]::IsNullOrEmpty($SemanticVersion.PrereleseLabel) -or [string]::IsNullOrEmpty($SemanticVersion.BuildLabel))) {
                New-Object -TypeName System.Management.Automation.SemanticVersion -ArgumentList $major, $minor, $patch, $SemanticVersion.PrereleaseLabel, $SemanticVersion.BuildLabel | Write-Output
            }
            elseif (-not ([string]::IsNullOrEmpty($SemanticVersion.BuildLabel))) {
                New-Object -TypeName System.Management.Automation.SemanticVersion -ArgumentList $major, $minor, $patch, $SemanticVersion.BuildLabel | Write-Output
            }
            else {
                New-Object -TypeName System.Management.Automation.SemanticVersion `
                    -ArgumentList $major, $minor, $patch, $SemanticVersion.PrereleaseLabel | Write-Output
            }
        } else {
            if ($PE.IsPresent) {
                Set-Variable -Name MAX_MAJOR -Option Constant -Value 127
                Set-Variable -Name MAX_MINOR -Option Constant -Value 255
                Set-Variable -Name MAX_BUILD -Option Constant -Value 32767
                Set-Variable -Name MAX_REVISION -Option Constant -Value 65534
            } else {
                Set-Variable -Name MAX_MAJOR -Option Constant -Value 65534
                Set-Variable -Name MAX_MINOR -Option Constant -Value 65534
                Set-Variable -Name MAX_BUILD -Option Constant -Value 65534
                Set-Variable -Name MAX_REVISION -Option Constant -Value 65534
            }

            Set-Variable -Name VERSION_REGEX -Option Constant -Value '^(?<major>\d+)(\.(?<minor>\d+))?(\.(?<build>\d+))?(\.(?<revision>\d+))?$'

            if ($Version.Major -gt $MAX_MAJOR) {
                Write-Warning -Message "$($CmdletName):  Major greater than '$($MAX_MAJOR)' will break all PE Headers including C++ Native and MSI"
                $major = $MAX_MAJOR
            } elseif ($Version.Major -lt 0) {
                $newErrorRecordSplat = @{
                    Exception = [System.ArgumentException]::new('Version is de-normal with negative Major', 'Version')
                    ErrorId = Format-ErrorId -Caller $CmdletName -Name 'ArgumentException' -Position $MyInvocation.ScriptLineNumber
                    ErrorCategory = 'InvalidArgument'
                    TargetObject = $Version
                    TargetName = 'Version'
                }

                New-ErrorRecord @newErrorRecordSplat | Write-Fatal
            } else {
                $major = $Version.Major
            }

            if ($Version.Minor -gt $MAX_MINOR) {
                Write-Warning -Message "$($CmdletName):  Minor greater than '$($MAX_MINOR)' will break all PE Headers including C++ Native and MSI"
                $minor = $MAX_MINOR
            } elseif ($Version.Minor -lt 0) {
                $newErrorRecordSplat = @{
                    Exception = [System.ArgumentException]::new('Version is de-normal with negative Minor', 'Version')
                    ErrorId = Format-ErrorId -Caller $CmdletName -Name 'ArgumentException' -Position $MyInvocation.ScriptLineNumber
                    ErrorCategory = 'InvalidArgument'
                    TargetObject = $Version
                    TargetName = 'Version'
                }

                New-ErrorRecord @newErrorRecordSplat | Write-Fatal
            } else {
                $minor = $Version.Minor
            }

            if ($Version.Build -gt $MAX_BUILD) {
                Write-Warning -Message "$($CmdletName):  Build greater than '$($MAX_BUILD)' may overflow in PE Headers including C++ Native and MSI"
                $build = $MAX_BUILD
            } elseif ($Version.Build -lt 0) {
                $build = 0
            } else {
                $build = $Version.Build
            }

            if ($Version.Revision -gt $MAX_REVISION) {
                Write-Warning -Message "$($CmdletName):  Revision greater than '$($MAX_REVISION)' will break all PE Headers including C++ Native and MSI"
                $revision = $MAX_REVISION
            } elseif ($Version.Revision -lt 0) {
                $revision = 0
            } else {
                $revision = $Version.Revision
            }

            New-Version -Major $major -Minor $minor -Build $build -Revision $revision | Write-Output
        }
    }

    <#
        .SYNOPSIS
        Normalizes a version object.

        .DESCRIPTION
        `Initialize-Version` normalizes a version object.

        .PARAMETER PE
        Indicates that the version is for a Portable Executable (PE) file with restricted ranges for each quad.  The default is to use the full range of a [version] object.

        .PARAMETER SemanticVersion
        The semantic version object to normalize.

        .PARAMETER Version
        The version object to normalize.

        .INPUTS
        None.  `Initialize-Version` does not take any PowerShell pipeline input.

        .OUTPUTS
        [version]  `Initialize-Version` returns an instance to the PowerShell pipeline output.

        .EXAMPLE
        PS> Initialize-Version -Version (New-Version -Major 1 -Minor 0 -Build 1234 -Revision 0)

        Major  Minor  Build  Revision
        -----  -----  -----  --------
            1      0   1234         0

        Normalizes the version object.

        .NOTES
        Copyright © 2024-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        New-ErrorRecord

        .LINK
        New-Object

        .LINK
        New-Version

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Fatal

        .LINK
        Write-Output

        .LINK
        Write-Warning
    #>
}

<#
    New-AssemblyVersion
#>
function New-AssemblyVersion {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([version])]
    param (
        [Parameter(Mandatory)]
        [ValidateRange(1, 65534)]
        [int]
        $Major,

        [Parameter(Mandatory)]
        [ValidateRange(0, 65534)]
        [int]
        $Minor,

        [ValidateRange(0, 66534)]
        [int]
        $Build,

        [Alias('ZeroDay')]
        [DateTime]
        $OffsetFrom = '01/01/2000'
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if (-not (Test-PSParameter -Name 'Build' -Parameters $PSBoundParameters)) {
        $Build = New-BuildNumber -OffsetFrom $OffsetFrom
    }

    if ($PSCmdlet.ShouldProcess(@($Major, $Minor, $Build, 0), $CmdletName)) {
        New-Version -Major $Major -Minor $Minor -Build $Build -Revision 0 | Initialize-Version | Write-Output
    }

    <#
        .SYNOPSIS
        Create a new assembly version from `Major`, `Minor`, `Build`, and `0`.

        .DESCRIPTION
        `New-FileVersion` creates a new assembly version from `Major`, `Minor`, `Build`, and `0`.

        If `Build` is not specified, the build number will be calculated IAW Microsoft QFE standard as the number of days from `OffsetFrom`.

        .PARAMETER Major
        The major portion of a [version].  `Major` must be in the range [1, 65534] and is required.

        .PARAMETER Minor
        The minor portion of a [version].  `Minor` must be in the range [0, 65534] and is required.

        .PARAMETER Build
        The build portion of a [version].  `Build` must be in the range [0, 65534] and is optional.  If not provided, `Build` will be calculated IAW Microsoft QFE standard as the number of days from `OffsetFrom`.

        .PARAMETER OffsetFrom
        The date time from which days are counted to the current UTC day.  Defaults to '01/01/2000'.

        .INPUTS
        None.  `New-AssemblyVersion` does not take any PowerShell pipeline input.

        .OUTPUTS
        [version]  `New-AssemblyVersion` returns an instance to the PowerShell pipeline output.

        .NOTES
        Copyright © 2023-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .EXAMPLE
        PS> New-AssemblyVersion -Major 1 -Minor 0 -Build 1234

        Major  Minor  Build  Revision
        -----  -----  -----  --------
            1      0   1234         0

        Create a new assembly version.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Initialize-Version

        .LINK
        New-BuildNumber

        .LINK
        New-Version

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output
    #>
}

<#
    New-BuildNumber
#>
function New-BuildNumber {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([int])]
    param (
        [Alias('ZeroDay')]
        [datetime]
        $OffsetFrom = '01/01/2000',

        [datetime]
        $Utc
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if (Test-PSParameter -Name 'Utc' -Parameters $PSBoundParameters) {
        Write-Verbose -Message "$($CmdletName):  UTC time '$($Utc)' passed as a parameter"
    } else {
        $Utc = Get-UtcDate
    }

    if ($PSCmdlet.ShouldProcess(@($OffsetFrom, $Utc), $CmdletName)) {
        $Utc.Subtract($OffsetFrom).Days | Write-Output
    }

    <#
        .SYNOPSIS
        Create a new build number from the number of days from `OffsetFrom`.

        .DESCRIPTION
        `New-BuildNumber` creates a new build number from the number of days from `OffsetFrom` following Microsoft QFE practice.

        .PARAMETER OffsetFrom
        The date time from which days are counted to the current UTC day.  Defaults to '01/01/2000'.

        .PARAMETER Utc
        The current UTC date time.  Defaults to the current UTC date time.  Use of this switch is highly recommended.

        .INPUTS
        None.  `New-BuildNumber` does not take any PowerShell pipeline input.

        .OUTPUTS
        [int]  `New-BuildNumber` returns an instance to the PowerShell pipeline output.

        .EXAMPLE
        PS> New-BuildNumber

        1234

        Create a new build number.

        .NOTES
        Copyright © 2024-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Get-UtcDate

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output

        .LINK
        Write-Verbose
    #>
}

<#
    New-CalendarVersion
#>
function New-CalendarVersion {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([version])]
    param (
        [switch]
        $Long,

        [switch]
        $Office,

        [Alias('ZeroDay')]
        [DateTime]
        $OffsetFrom = '01/01/2000'
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    Set-Variable -Name MAX_REVISION -Option Constant -Value 65534 -WhatIf:$false

    $utc = Get-UtcDate

    if ($Long.IsPresent) {
        $year = $utc.Year
    } else {
        $year = $utc.Year % 100
    }

    $midnight = New-RevisionNumber -MaxRevision $MAX_REVISION -OffsetFrom $OffsetFrom -Utc $utc

    if ($Office.IsPresent) {
        $monthDay = ((($utc.Year - $OffsetFrom.Year) * 12) + $utc.Month - $OffsetFrom.Month)
        $monthDay = ($monthDay * 100) + $utc.Day
        $version = New-Version -Major $year -Minor $monthDay -Build $midnight -Revision 0
    } else {
        $month = $utc.Month
        $day = $utc.Day
        $version = New-Version -Major $year -Minor $month -Build $day -Revision $midnight
    }

    if ($PSCmdlet.ShouldProcess($version, $CmdletName)) {
        Initialize-Version -Version $version | Write-Output
    }

    <#
        .SYNOPSIS
        Create a new calendar version from the current UTC date.

        .DESCRIPTION
        `New-CalendarVersion` creates a new calendar version from the current UTC date.

        .PARAMETER Long
        Indicates that the year portion of the version should be the full year.

        .PARAMETER Office
        Indicates that the version should be in the format of an Microsoft Office version.

        .PARAMETER OffsetFrom
        The date time from which days are counted to the current UTC day.  Defaults to '01/01/2000'.

        .INPUTS
        None.  `New-CalendarVersion` does not take any PowerShell pipeline input.

        .OUTPUTS
        [version]  `New-CalendarVersion` returns an instance to the PowerShell pipeline output.

        .EXAMPLE
        PS> New-CalendarVersion

        Major  Minor  Build  Revision
        -----  -----  -----  --------
           24      1      1  1234

        Create a new calendar version.

        .NOTES
        Copyright © 2024-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Get-UtcDate

        .LINK
        Initialize-Version

        .LINK
        New-RevisionNumber

        .LINK
        New-Version

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output
    #>
}

New-Alias -Name New-CalVersion -Value New-CalendarVersion

<#
    New-FileVersion
#>
function New-FileVersion {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([version])]
    param (
        [Parameter(Mandatory)]
        [ValidateRange(0, 65534)]
        [int]
        $Major,

        [Parameter(Mandatory)]
        [ValidateRange(0, 65534)]
        [int]
        $Minor,

        [ValidateRange(0, 66534)]
        [int]
        $Build,

        [ValidateRange(0, 65534)]
        [int]
        $Revision,

        [Alias('ZeroDay')]
        [DateTime]
        $OffsetFrom = '01/01/2000'
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    Set-Variable -Name MAX_REVISION -Option Constant -Value 65534 -WhatIf:$false

    $utc = Get-UtcDate

    if (-not (Test-PSParameter -Name 'Build' -Parameters $PSBoundParameters)) {
        $Build = New-BuildNumber -OffsetFrom $OffsetFrom -Utc $utc
    }

    if (-not (Test-PSParameter -Name 'Revision' -Parameters $PSBoundParameters)) {
        $Revision = New-RevisionNumber -MaxRevision $MAX_REVISION -OffsetFrom $OffsetFrom -Utc $utc
    }

    if ($PSCmdlet.ShouldProcess(@($Major, $Minor, $Build, $Revision), $CmdletName)) {
        New-Version -Major $Major -Minor $Minor -Build $Build -Revision $Revision | Initialize-Version | Write-Output
    }

    <#
        .SYNOPSIS
        Create a new file version from `Major`, `Minor`, `Build`, and `Revision`.

        .DESCRIPTION
        `New-FileVersion` creates a new file version from `Major`, `Minor`, `Build`, and `Revision`.

        If `Build` is not specified, the build number will be calculated IAW Microsoft QFE standard as the number of days from `OffsetFrom`.

        If `Revision` is not specified, the revision number will be calculated as the number of ticks over ticks-per-day modulus the maximum revision number.  The maximum revision number is currently 65534.

        .PARAMETER Major
        The major portion of a [version].  `Major` must be in the range [0, 65534] and is required.

        .PARAMETER Minor
        The minor portion of a [version].  `Minor` must be in the range [0, 65534] and is required.

        .PARAMETER Build
        The build portion of a [version].  `Build` must be in the range [0, 65534] and is optional.  If not provided, `Build` will be calculated IAW Microsoft QFE standard as the number of days from `OffsetFrom`.

        .PARAMETER Revision
        The revision portion of a [version].  `Revision` must be in the range [0, 65534] and is optional.  If `Revision` is not specified, the revision number will be calculated as the number of ticks over ticks-per-day modulus the maximum revision number.  The maximum revision number is currently 65534.

        .PARAMETER OffsetFrom
        The date time from which days are counted to the current UTC day.  Defaults to '01/01/2000'.

        .INPUTS
        None.  `New-FileVersion` does not take any PowerShell pipeline input.

        .OUTPUTS
        [version]  `New-FileVersion` returns an instance to the PowerShell pipeline output.

        .NOTES
        Copyright © 2023-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .EXAMPLE
        PS> New-FileVersion -Major 1 -Minor 0 -Build 1234 -Revision 0

        Major  Minor  Build  Revision
        -----  -----  -----  --------
            1      0   1234         0

        Create a new file version.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Get-UtcDate

        .LINK
        Initialize-Version

        .LINK
        New-BuildNumber

        .LINK
        New-RevisionNumber

        .LINK
        New-Version

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output
    #>
}

<#
    New-InformationalVersion
#>
function New-InformationalVersion {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateRange(0, 65534)]
        [int]
        $Major,

        [Parameter(Mandatory)]
        [ValidateRange(0, 65534)]
        [int]
        $Minor,

        [ValidateRange(0, 66534)]
        [int]
        $Build,

        [ValidateRange(0, 65534)]
        [int]
        $Revision,

        [Alias('ZeroDay')]
        [DateTime]
        $OffsetFrom = '01/01/2000',

        [switch]
        $Release
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    Set-Variable -Name MAX_REVISION -Option Constant -Value 65534 -WhatIf:$false

    $utc = Get-UtcDate

    if (-not (Test-PSParameter -Name 'Build' -Parameters $PSBoundParameters)) {
        $Build = New-BuildNumber -OffsetFrom $OffsetFrom -Utc $utc
    }

    if ($Release.IsPresent) {
        $Revision = 0
    } elseif (-not (Test-PSParameter -Name 'Revision' -Parameters $PSBoundParameters)) {
        $Revision = New-RevisionNumber -MaxRevision $MAX_REVISION -OffsetFrom $OffsetFrom -Utc $utc
    }

    if ($PSCmdlet.ShouldProcess(@($Major, $Minor, $Build, $Revision), $CmdletName)) {
        $version = New-Version -Major $Major -Minor $Minor -Build $Build -Revision $Revision | Initialize-Version
        $version.ToString() | Write-Output
    }

    <#
        .SYNOPSIS
        Create a new file version from `Major`, `Minor`, `Build`, and `Revision`.

        .DESCRIPTION
        `New-InformationalVersion` creates a new file version from `Major`, `Minor`, `Build`, and `Revision`.

        If `Build` is not specified, the build number will be calculated IAW Microsoft QFE standard as the number of days from `OffsetFrom`.

        If `Revision` is not specified, the revision number will be calculated as the number of ticks over ticks-per-day modulus the maximum revision number.  The maximum revision number is currently 65534.

        .PARAMETER Major
        The major portion of a [version].  `Major` must be in the range [0, 65534] and is required.

        .PARAMETER Minor
        The minor portion of a [version].  `Minor` must be in the range [0, 65534] and is required.

        .PARAMETER Build
        The build portion of a [version].  `Build` must be in the range [0, 65534] and is optional.  If not provided, `Build` will be calculated IAW Microsoft QFE standard as the number of days from `OffsetFrom`.

        .PARAMETER Revision
        The revision portion of a [version].  `Revision` must be in the range [0, 65534] and is optional.  If `Revision` is not specified, the revision number will be calculated as the number of ticks over ticks-per-day modulus the maximum revision number.  The maximum revision number is currently 65534.

        .PARAMETER OffsetFrom
        The date time from which days are counted to the current UTC day.  Defaults to '01/01/2000'.

        .PARAMETER Release
        If present, `Release` will be unconditionally set to 0.

        .INPUTS
        None.  `New-InformationalVersion` does not take any PowerShell pipeline input.

        .OUTPUTS
        [string]  `New-InformationalVersion` returns an instance to the PowerShell pipeline output.

        .NOTES
        Copyright © 2023-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .EXAMPLE
        PS> New-InformationalVersion -Major 1 -Minor 0 -Build 1234 -Revision 0

        Major  Minor  Build  Revision
        -----  -----  -----  --------
            1      0   1234         0

        Create a new informational or product version.

        .EXAMPLE
        PS> New-InformationalVersion -Major 1 -Minor 0 -Build 1234 -Revision 33 -Release

        Major  Minor  Build  Revision
        -----  -----  -----  --------
            1      0   1234         0

        Create a new release version with the revision set to 0.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Get-UtcDate

        .LINK
        Initialize-Version

        .LINK
        New-BuildNumber

        .LINK
        New-RevisionNumber

        .LINK
        New-Version

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output
    #>
}

New-Alias -Name New-ProductVersion -Value New-InformationalVersion

<#
    New-JsonVersion
#>
function New-JsonVersion {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $FilePath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ShortId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $LongId,

        [Parameter(Mandatory)]
        [ValidateRange(0, 65534)]
        [int]
        $Major,

        [Parameter(Mandatory)]
        [ValidateRange(0, 65534)]
        [int]
        $Minor,

        [Parameter(Mandatory)]
        [datetime]
        $CommitAuthorDate,

        [Parameter(Mandatory)]
        [datetime]
        $CommitDate,

        [ValidateNotNullOrEmpty()]
        [string[]]
        $BuildMetadata,

        [ValidateNotNullOrEmpty()]
        [string]
        $DevRelease,

        [ValidateNotNullOrEmpty()]
        [string]
        $LocalRelease,

        [ValidateNotNullOrEmpty()]
        [string]
        $PostRelease,

        [ValidateNotNullOrEmpty()]
        [string]
        $Prerelease,

        [ValidateRange(0, 255)]
        [int]
        $PrereleaseVersion,

        [ValidateNotNullOrEmpty()]
        [string[]]
        $Tag,

        [ValidateNotNullOrEmpty()]
        [string]
        $BuildRef = 'refs/heads/main',

        [ValidateNotNullOrEmpty()]
        [string]
        $Branch = 'main',

        [ValidateRange(1, 2147483647)]
        [int]
        $Epoch = 1,

        [switch]
        $PublicRelease,

        [datetime]
        $ZeroDay = '01/01/2000'
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $jsonTemplate =
@'
    {
    "BuildMetadataWithCommitId": [
      "",
      "",
      "g",
    ],
    "VersionOptions": {
      "Version": {
        "BuildMetadata": [
          "0",
          "0",
          "",
          "",
          "refs/heads/main",
        ],
        "LocalRelease": "",
        "PostRelease": "",
        "Prerelease": "",
        "PrereleaseVersion": "",
        "PrereleaseVersionNoLeadingHyphen": false,
        "PrereleaseVersionStrict": true,
        "PublicRelease": false,
        "SimpleVersion": "1.0.0",
        "Version": "1.0.0.0",
        "MajorMinorVersion": "1.0",
        "VersionMajor": 1,
        "VersionMinor": 0,
        "BuildNumber": 0,
        "VersionRevision": 0,
        "Tags": [],
        "ZeroDay": "01/01/2000",
      },
    },
    "AssemblyVersion": {
        "AssemblyVersion": "1.0.0.0",
        "AssemblyFileVersion": "1.0.0.0",
        "AssemblyInformationalVersion": "1.0.0+",
        "AssemblyProductVersion": "1.0.0.0",
    },
    "CalendarVersioning": {
      "CalendarVersion": "2025.1.1.0",
      "CalendarMajorMinorVersion": "2025.1",
      "CalendarYear": 2025,
      "CalendarMonth": 1,
      "CalendarDay": 1,
    },
    "GitVersion": {
        "GitAssemblyInformationalVersion": "1.0.0+",
        "GitAssemblyProductVersion": "1.0.0.0",
        "GitBuildVersion": "1.0.0.0",
        "GitBuildVersionSimple": "1.0.0",
        "BuildingRef": "refs/heads/main",
        "GitCommitAuthorDate": "2025-01-01T00:00:00+00:00",
        "GitCommitDate": "2025-01-01T00:00:00+00:00",
        "GitCommitId": "",
        "GitCommitIdShort": "",
        "GitCommitIdShortPrefixed": "",
    },
    "PerlVersioning": {
      "PerlVersion": 1.0000000,
      "PerlVersionMajorMinor": 1.000,
      "PerlMajor": 1.0,
      "PerlMinor": 0.0,
      "PerlPatch": 0.0,
    },
    "PythonVersioning": {
      "PythonVersion": "1!1.0.0.0",
      "PythonEpoch": 1,
      "PythonReleaseMicroVersion": "1.0",
      "PythonRelease": 1,
      "PythonMicro": 0,
      "PythonBuild": 0,
      "PythonRevision": 0,
      "PythonDevRelease": "",
      "PythonPreRelease": "",
      "PythonPostRelease": "",
      "PythonLocalRelease": "",
    },
    "WindowsVersioning": {
      "WindowsVersion": 0,
      "WindowsMajorMinorVersion": 281474976710656,
      "WindowsMajor": 281474976710656,
      "WindowsMinor": 0,
      "WindowsBuild": 0,
      "WindowsRevision": 0,
    },
    "SemanticVersioning": {
      "BuildMetadata": [],
      "BuildMetadataFragment": "+",
      "PatchNumber": 0,
      "SemanticVersionMajorMinor": "1.0",
      "SemanticVersionMajor": 1,
      "SemanticVersionMinor": 0,
      "SematnicVersionBuild": 0,
      "SemanticVersionPatch": 0,
      "SemanticVersionRevision": 0,
      "SemanticVersionPreRelease": "",
      "SemanticVersionBuildMetadata": "",
      "SemanticVersion": "1.0.0-",
      "SemanticVersionPrefixed": "1.0.0-g",
      "SemanticVersionShort": "1.0.0",
    },
    "PackageVersion": {
      "NuGetPackageVersion": "1.0.0-g",
      "ChocolateyPackageVersion": "1.0.0-g",
      "NpmPackageVersion": "1.0.0-g",
    },
  }
'@

    $json = $jsonTemplate | ConvertFrom-Json

    # BuildMetadataWithCommitId
    $json.BuildMetadataWithCommitId = @($ShortId, $LongId, "g$ShortId")

    # VersionOptions
    $build = New-BuildNumber -OffsetFrom $ZeroDay
    $revision = New-RevisionNumber -MaxRevision 65534 -OffsetFrom $ZeroDay
    $json.VersionOptions.Version.BuildMetadata = @($Major, $Minor, $build, $revision, $BuidlRef)
    $json.VersionOptions.Version.LocalRelease = $LocalRelease
    $json.VersionOptions.Version.PostRelease = $PostRelease
    $json.VersionOptions.Version.Prerelease = $Prerelease
    $json.VersionOptions.Version.PrereleaseVersion = $PrereleaseVersion
    $json.VersionOptions.Version.PublicRelease = $PublicRelease:IsPresent

    $version = New-Version -Major $Major -Minor $Minor -Build $build -Revision $revision

    $json.VersionOptions.Version.SimpleVersion = $version.ToString(3)
    $json.VersionOptions.Version.Version = $version.ToString()
    $json.VersionOptions.Version.MajorMinorVersion = $version.ToString(2)
    $json.VersionOptions.Version.VersionMajor = $Major
    $json.VersionOptions.Version.VersionMinor = $Minor
    $json.VersionOptions.Version.BuildNumber = $build
    $json.VersionOptions.Version.VersionRevision = $revision
    $json.VersionOptions.Version.Tags = $Tag
    $json.VersionOptions.Version.ZeroDay = $ZeroDay.ToString()

    # AssemblyVersion
    $assemblyVersion = Get-AssemblyVersion -LiteralPath $FilePath
    $fileVersion = Get-FileVersion -LiteralPath $FilePath
    $informationalVersion = Get-InformationalVersion -LiteralPath $FilePath
    $productVersion = Get-ProductVersion -LiteralPath $FilePath
    $json.AssemblyVersion.AssemblyVersion = $assemblyVersion.ToString()
    $json.AssemblyVersion.AssemblyFileVersion = $fileVersion
    $json.AssemblyVersion.AssemblyInformationalVersion = $informationalVersion
    $json.AssemblyVersion.AssemblyProductVersion = $productVersion

    # CalendarVersioning
    $calendarVersion = New-CalendarVersion -Long -OffsetFrom $ZeroDay
    $json.CalendarVersioning.CalendarVersion = $calendarVersion.ToString()
    $json.CalendarVersioning.CalendarMajorMinorVersion = $calendarVersion.ToString(2)
    $json.CalendarVersioning.CalendarYear = $calendarVersion.Major
    $json.CalendarVersioning.CalendarMonth = $calendarVersion.Minor
    $json.CalendarVersioning.CalendarDay = $calendarVersion.Build

    # GitVersion
    $patch = New-PatchVersion -OffsetFrom $ZeroDay
    $gitShortSemanticVersion = [semver]::new($Major, $Minor, $patch, $ShortId)
    $gitLongSemanticVersion = [semver]::new($Major, $Minor, $patch, $LongId)
    $json.GitVersion.GitAssemblyInformationalVersion = $gitShortSemanticVersion.ToString()
    $json.GitVersion.GitAssemblyProductVersion = $productVersion
    $json.GitVersion.GitBuildVersion = $version.ToString()
    $json.GitVersion.GitBuildVersionSimple = $version.ToString(3)
    $json.GitVserion.BuildingRef = $BuildRef
    $json.GitVersion.CommitAuthorDate = $CommitAuthorDate.ToString()
    $json.GitVersion.CommitDate = $CommitDate.ToString()
    $json.GitVersion.GitCommitId = $LongId
    $json.GitVersion.GitCommitIdShort = $ShortId
    $json.GitVersion.GitCommitIdShortPrefixed = "g$ShortId"

    # PerlVersioning
    $perlVersion = New-PerlVersion -Major ($Major % 999) -Minor ($Minor % 999) -Patch ($patch % 999)
    $json.PerlVersioning.PerlVersion = $perlVersion
    $json.PerlVersioning.PerlMajor = ($Major % 999) * 1.0
    $json.PerlVersioning.PerlMinor = ($Minor % 999) * 0.0001
    $json.PerlVersioning.PerlPatch = ($patch % 999) * 0.0000001
    $json.PerlVersioning.PerlVersionMajorMinor = $json.PerlVersioning.PerlMajor + $json.PerlVersioning.PerlMinor

    # PythonVersioning
    $pythonVersion = New-PythonVersion -Epoch $Epoch -Major $Major -Minor $Minor -Patch $patch -Prerelease $Prerelease -PrereleaseVersion $PrereleaseVersion -PostRelease $PostRelease -LocalRelease $LocalRelease -BuildRef $BuildRef -Branch $Branch
    $json.PythonVersioning.PythonVersion = $pythonVersion
    $json.PythonVersioning.PythonEpoch = $Epoch
    $json.PythonVersioning.PythonReleaseMicroVersion = ('{0}.{1}' -f $Major, $Minor)
    $json.PythonVersioning.PythonRelease = $Major
    $Long.PythonVersioning.PythonMicro = $Minor
    $json.PythonVersioning.PythonBuild = $build
    $json.PythonVersioning.PythonRevision = $revision
    $json.PythonVersioning.PythonDevRelease = $DevRelease
    $json.PythonVersioning.PythonPreRelease = $Prerelease
    $json.PythonVersioning.PythonPostRelease = $PostRelease
    $json.PythonVersioning.PythonLocalRelease = $LocalRelease

    # WindowsVersioning
    $json.WindowsVersioning.WindowsVersion = New-WindowsVersion -Major $Major -Minor $Minor -Build $build -Revision $revision
    $json.WindowsVersioning.WindowsMajorMinorVersion = ([uint64]$Major -shl 48) -bor ([uint64]$Minor -shl 32)
    $json.WindowsVersioning.WindowsMajor = ([uint64]$Major -shl 48)
    $json.WindowsVersioning.WindowsMinor = ([uint64]$Minor -shl 32)
    $json.WindowsVersioning.WindowsBuild = ([uint64]$build -shl 16)
    $json.WindowsVersioning.WindowsRevision = $revision

    # SemanticVersioning
    $shortSemanticVersion = [semver]::new($Major, $Minor, $patch, $BuildMetadata, $ShortId)
    $json.SemanticVersioning.BuildMetadata = $BuildMetadata
    $json.SemanticVersioning.BuildMetadataFragment = "+$ShortId"
    $json.SemanticVersioning.PatchNumber = $shortSemanticVersion.Patch
    $json.SemanticVersioning.SemanticVersionMajorMinor = $shortSemanticVersion.ToString(2)
    $json.SemanticVersioning.SemanticVersionMajor = $shortSemanticVersion.Major
    $json.SemanticVersioning.SemanticVersionMinor = $shortSemanticVersion.Minor
    $json.SemanticVersioning.SemanticVersionPatch = $shortSemanticVersion.Patch
    $json.SemanticVersioning.SemanticVersionRevision = 0
    $json.SemanticVersioning.SemanticVersionPreRelease = $shortSemanticVersion.PrereleaseLabel
    $json.SemanticVersioning.SemanticVersionBuildMetadata = $shortSemanticVersion.BuildMetadataLabel
    $json.SemanticVersioning.SemanticVersion = $shortSemanticVersion.ToString()
    $json.SemanticVersioning.SemanticVersionPrefixed = $shortSemanticVersion.ToString(3) + $gitShortIdPrefixed
    $json.SemanticVersioning.SemanticVersionShort = $shortSemanticVersion.ToString(3)

    # PackageVersion
    $json.PackageVersion.NugetPackageVersion = $shortSemanticVersion.ToString(3) + $gitShortIdPrefixed
    $json.PackageVersion.ChocolateyPackageVersion = $shortSemanticVersion.ToString(3) + $gitShortIdPrefixed
    $json.PackageVersion.NpmPackageVersion = $shortSemanticVersion.ToString(3) + $gitShortIdPrefixed

    $json | ConvertTo-Json | Write-Output
}

<#
    New-XmlVersion
#>
function New-XmlVersion {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $FilePath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ShortId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $LongId,

        [Parameter(Mandatory)]
        [ValidateRange(0, 65534)]
        [int]
        $Major,

        [Parameter(Mandatory)]
        [ValidateRange(0, 65534)]
        [int]
        $Minor,

        [Parameter(Mandatory)]
        [datetime]
        $CommitAuthorDate,

        [Parameter(Mandatory)]
        [datetime]
        $CommitDate,

        [ValidateNotNullOrEmpty()]
        [string[]]
        $BuildMetadata,

        [ValidateNotNullOrEmpty()]
        [string]
        $DevRelease,

        [ValidateNotNullOrEmpty()]
        [string]
        $LocalRelease,

        [ValidateNotNullOrEmpty()]
        [string]
        $PostRelease,

        [ValidateNotNullOrEmpty()]
        [string]
        $Prerelease,

        [ValidateRange(0, 255)]
        [int]
        $PrereleaseVersion,

        [ValidateNotNullOrEmpty()]
        [string[]]
        $Tag,

        [ValidateNotNullOrEmpty()]
        [string]
        $BuildRef = 'refs/heads/main',

        [ValidateNotNullOrEmpty()]
        [string]
        $Branch = 'main',

        [ValidateRange(1, 2147483647)]
        [int]
        $Epoch = 1,

        [switch]
        $PublicRelease,

        [datetime]
        $ZeroDay = '01/01/2000'
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $newJsonVersion = @{
        FilePath = $FilePath
        ShortId = $ShortId
        LongId = $LongId
        Major = $Major
        Minor = $Minor
        CommitAuthorDate = $CommitAuthorDate
        CommitDate = $CommitDate
        BuildMetadata = $BuildMetadata
        DevRelease = $DevRelease
        LocalRelease = $LocalRelease
        PostRelease = $PostRelease
        Prerelease = $Prerelease
        PrereleaseVersion = $PrereleaseVersion
        Tag = $Tag
        BuildRef = $BuildRef
        Branch = $Branch
        Epoch = $Epoch
        PublicRelease = $PublicRelease:IsPresent
        ZeroDay = $ZeroDay
    }

    New-JsonVersion @newJsonVersion | ConvertFrom-Json | ConvertTo-Xml | Write-Output
}

<#
    New-PatchNumber
#>
function New-PatchNumber {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([int])]
    param (
        [Alias('ZeroDay')]
        [datetime]
        $OffsetFrom = '01/01/2000',

        [datetime]
        $Utc,

        [int]
        $MaxBuild = 21474,

        [int]
        $MaxRevision = 83647
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if (Test-PSParameter -Name 'Utc' -Parameters $PSBoundParameters) {
        Write-Verbose -Message "$($CmdletName) : UTC time '$($Utc)' passed as a parameter"
    } else {
        $Utc = Get-UtcDate
    }

    if ($PSCmdlet.ShouldProcess(@($OffsetFrom, $Utc, $MaxBuild, $MaxRevision), $CmdletName)) {
        $build = New-BuildNumber -OffsetFrom $OffsetFrom -Utc $Utc
        $revision = New-RevisionNumber -MaxRevision $MaxRevision -OffsetFrom $OffsetFrom -Utc $Utc

        if ($build -gt $MaxBuild) {
            $newErrorRecordSplat = @{
                Exception = [System.ArgumentOutOfRange]::new('build', $build, "Build portion of patch is greater than '$($MaxBuild)' and will overflow")
                ErrorId = Format-ErrorId -Caller $CmdletName -Name 'ArgumentException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject = $build
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        } elseif ($revision -gt $MaxRevision) {
            Write-Warning -Message "$($CmdletName) : Revision portion of patch is greater than '$($MaxRevision)' and may overflow"
        } else {
            Write-Verbose -Message "$($CmdletName) : Both the build and revision parts of patch are in range"
        }

        $build * 100000 + $revision | Write-Output
    }

    <#
        .SYNOPSIS
        Create a new patch number from the number of days from `OffsetFrom`.

        .DESCRIPTION
        `New-PatchNumber` creates a new patch number from the number of days from `OffsetFrom` loosely following Microsoft QFE practice.

        .PARAMETER MaxRevision
        The maximum revision number.  Defaults to 83647.

        .PARAMETER OffsetFrom
        The date time from which days are counted to the current UTC day.  Defaults to '01/01/2000'.

        .PARAMETER Utc
        The current UTC date time.  Defaults to the current UTC date time.  Use of this switch is highly recommended.

        .PARAMETER MaxBuild
        The maximum build number.  Defaults to 21474.

        .INPUTS
        None.  `New-PatchNumber` does not take any PowerShell pipeline input.

        .OUTPUTS
        [int]  `New-PatchNumber` returns an instance to the PowerShell pipeline output.

        .EXAMPLE
        PS> New-PatchNumber

        1234

        Create a new patch number.

        .NOTES
        Copyright © 2024-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Get-UtcDate

        .LINK
        Initialize-PSCmdlet

        .LINK
        New-BuildNumber

        .LINK
        New-ErrorRecord

        .LINK
        New-RevisionNumber

        .LINK
        Write-Error

        .LINK
        Write-Fatal

        .LINK
        Write-Verbose

        .LINK
        Write-Warning

        .LINK
        Write-Output
    #>
}

<#
    New-PerlVersion
#>
function New-PerlVersion {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([double])]
    param (
        [Parameter(Mandatory)]
        [ValidateRange(0, 999)]
        [int]
        $Major,

        [Parameter(Mandatory)]
        [ValidateRange(0, 999)]
        [int]
        $Minor,

        [Parameter(Mandatory)]
        [ValidateRange(0, 999)]
        [Alias('Revision')]
        [int]
        $Patch
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if ($PSCmdlet.ShouldProcess(@($Major, $Minor, $Patch), $CmdletName)) {
        ($Major * 1.0) + ($Minor * 0.0001) + ($Patch * 0.0000001) | Write-Output
    }

    <#
        .SYNOPSIS
        Create a new Perl version from `Major`, `Minor`, and `Patch`.

        .DESCRIPTION
        `New-PerlVersion` creates a new Perl version from `Major`, `Minor`, and `Patch`.

        .PARAMETER Major
        The major portion of a Perl version.  `Major` must be in the range [0, 999] and is required.

        .PARAMETER Minor
        The minor portion of a Perl version.  `Minor` must be in the range [0, 999] and is required.

        .PARAMETER Patch
        The patch portion of a Perl version.  `Patch` must be in the range [0, 999] and is required.

        .INPUTS
        None.  `New-PerlVersion` does not take any PowerShell pipeline input.

        .OUTPUTS
        [double]  `New-PerlVersion` returns an instance to the PowerShell pipeline output.

        .EXAMPLE
        PS> New-PerlVersion -Major 5 -Minor 32 -Patch 0

        5.320

        Create a new Perl version.

        .NOTES
        Copyright © 2024-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Initialize-PSCmdlet

        .LINK
        Write-Output
    #>
}

<#
    New-PythonVersion
#>
function New-PythonVersion {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([string])]
    param (
        [ValidateScript({ $_ -ge 0 })]
        [int]
        $Epoch,

        [Parameter(Mandatory)]
        [ValidateScript({ $_ -ge 0 })]
        [int]
        $Release,

        [ValidateScript({ $_ -ge 0 })]
        [int]
        $Micro = 0,

        [ValidateScript({ $_ -ge 0 })]
        [int]
        $Build,

        [ValidateScript({ $_ -ge 0 })]
        [int]
        $Revision,

        [ValidateScript({ Test-CPreRelease -PreRelease $_ })]
        [string]
        $PreRelease,

        [ValidatePattern('post\d*')]
        [string]
        $PostRelease,

        [ValidatePattern('dev\d*')]
        [string]
        $DevRelease,

        [ValidateScript({ $_ -ge 0 })]
        [int]
        $Local
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $buffer = New-StringBuilder

    if ((Test-PSParameter -Name 'Epoch' -Parameters $PSBoundParameters) -and ($Epoch -gt 0)) {
        Add-End -Buffer $buffer -Integer $Epoch
        Add-End -Buffer $buffer -Value '!'
    }

    Add-End -Buffer $buffer -Integer $Release
    Add-End -Buffer $buffer -Integer $Micro

    if (Test-PSParameter -Name 'Build' -Parameters $PSBoundParameters) {
        Add-End -Buffer $buffer -Value '.'
        Add-End -Buffer $buffer -Integer $Build
    }

    if (Test-PSParameter -Name 'Revision' -Parameters $PSBoundParameters) {
        Add-End -Buffer $buffer -Value '.'
        Add-End -Buffer $buffer -Integer $Revision
    }

    if (Test-PSParameter -Name 'PreRelease' -Parameters $PSBoundParameters) {
        Add-End -Buffer $buffer -String $PreRelease
    }

    if (Test-PSParameter -Name 'PostRelease' -Parameters $PSBoundParameters) {
        Write-Warning -Message "$($CmdletName):  Using PostRelease is disfavored under PEP 440 and later"
        Add-End -Buffer $buffer -Value '.'
        Add-End -Buffer $buffer -String $PostRelease
    }

    if (Test-PSParameter -Name 'DevRelease' -Parameters $PSBoundParameters) {
        Add-End -Buffer $buffer -Value '.'
        Add-End -Buffer $buffer -String $DevRelease
    }

    if (Test-PSParameter -Name 'Local' -Parameters $PSBoundParameters) {
        Add-End -Buffer $buffer -Value '-'
        Add-End -Buffer $buffer -Integer $Local
    }

    $version = ConvertTo-String -Buffer $buffer

    if ($PSCmdlet.ShouldProcess($version, $CmdletName)) {
        $version | Write-Output
    }

    <#
        .SYNOPSIS
        Create a new Python version from `Epoch`, `Release`, `Micro`, `Build`, `Revision`, `PreRelease`, `PostRelease`, `DevRelease`, and `Local`.

        .DESCRIPTION
        `New-PythonVersion` creates a new Python version from `Epoch`, `Release`, `Micro`, `Build`, `Revision`, `PreRelease`, `PostRelease`, `DevRelease`, and `Local`.

        .PARAMETER Epoch
        The epoch portion of a Python version.  `Epoch` must be greater than or equal to 0.

        .PARAMETER Release
        The release portion of a Python version.  `Release` must be greater than or equal to 0 and is required.

        .PARAMETER Micro
        The micro portion of a Python version.  `Micro` must be greater than or equal to 0 and is optional.

        .PARAMETER Build
        The build portion of a Python version.  `Build` must be greater than or equal to 0 and is optional.

        .PARAMETER Revision
        The revision portion of a Python version.  `Revision` must be greater than or equal to 0 and is optional.

        .PARAMETER PreRelease
        The pre-release portion of a Python version.  `PreRelease` must be a valid pre-release string.

        .PARAMETER PostRelease
        The post-release portion of a Python version.  `PostRelease` must be a valid post-release string.

        .PARAMETER DevRelease
        The development release portion of a Python version.  `DevRelease` must be a valid development release string.

        .PARAMETER Local
        The local portion of a Python version.  `Local` must be greater than or equal to 0 and is optional.

        .INPUTS
        None.  `New-PythonVersion` does not take any PowerShell pipeline input.

        .OUTPUTS
        [string]  `New-PythonVersion` returns an instance to the PowerShell pipeline output.

        .EXAMPLE
        PS> New-PythonVersion -Release 3 -Micro 7 -Build 1234 -Revision 0 -PreRelease 'a1' -PostRelease 'post1' -DevRelease 'dev1' -Local 123

        3.7.1234.0a1.post1.dev1-123

        Create a new Python version.

        .NOTES
        Copyright © 2024-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Add-End

        .LINK
        ConvertTo-String

        .LINK
        Initialize-PSCmdlet

        .LINK
        New-StringBuilder

        .LINK
        Write-Output

        .LINK
        Write-Warning
    #>
}

<#
    New-RevisionNumber
#>
function New-RevisionNumber {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([int])]
    param (
        [Alias('ZeroDay')]
        [datetime]
        $OffsetFrom = '01/01/2000',

        [datetime]
        $Utc,

        [int]
        $MaxRevision = 65534
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if (Test-PSParameter -Name 'Utc' -Parameters $PSBoundParameters) {
        Write-Verbose "$($CmdletName) : UTC time '$($Utc)' passed as a parameter"
    } else {
        $Utc = Get-UtcDate
    }

    if ($PSCmdlet.ShouldProcess(@($OffsetFrom, $Utc, $MaxRevision), $CmdletName)) {
        ([int]($Utc.TimeOfDay.TotalDays * $MaxRevision)) | Write-Output
    }

    <#
        .SYNOPSIS
        Create a new revision number from the number of days from `OffsetFrom`.

        .DESCRIPTION
        `New-RevisionNumber` creates a new revision number from the number of days from `OffsetFrom`.

        .PARAMETER MaxRevision
        The maximum revision number.  Defaults to 65534.

        .PARAMETER OffsetFrom
        The date time from which days are counted to the current UTC day.  Defaults to '01/01/2000'.

        .PARAMETER Utc
        The current UTC date time.  Defaults to the current UTC date time.  Use of this switch is highly recommended.

        .INPUTS
        None.  `New-RevisionNumber` does not take any PowerShell pipeline input.

        .OUTPUTS
        [int]  `New-RevisionNumber` returns an instance to the PowerShell pipeline output.

        .EXAMPLE
        PS> New-RevisionNumber

        1234

        Create a new revision number.

        .NOTES
        Copyright © 2024-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Get-UtcDate

        .LINK
        Initialize-PSCmdlet

        .LINK
        Write-Output

        .LINK
        Write-Verbose
    #>
}

<#
    New-SemanticVersion
#>
function New-SemanticVersion {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'UsingParts')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingParts')]
        [ValidateRange(0, 65534)]
        [Alias('Current')]
        [int]
        $Major,

        [Parameter(Mandatory, ParameterSetName = 'UsingParts')]
        [ValidateRange(0, 65534)]
        [Alias('Revision')]
        [int]
        $Minor,

        [Parameter(ParameterSetName = 'UsingParts')]
        [ValidateRange(0, 2147483647)]
        [Alias('Build', 'Maintenance', 'Age')]
        [int]
        $Patch,

        [Parameter(ParameterSetName = 'UsingParts')]
        [Alias('ZeroDay')]
        [DateTime]
        $OffsetFrom = '01/01/2000',

        # LabelUnitRegEx from PowerShell source code
        [Parameter(ParameterSetName = 'UsingParts')]
        [ValidatePattern('^((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*)$')]
        [Alias('Suffix', 'PreRelease')]
        [string]
        $PrereleaseLabel,

        # LabelUnitRegEx from PowerShell source code
        [Parameter(ParameterSetName = 'UsingParts')]
        [ValidatePattern('^((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*)$')]
        [Alias('Metadata', 'BuildMetadata')]
        [string[]]
        $BuildLabel,

        [Parameter(ParameterSetName = 'UsingString')]
        [ValidatePattern('^(?<major>\d+)(\.(?<minor>\d+))?(\.(?<patch>\d+))?')]
        [Alias('Version')]
        [string]
        $Value
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    Set-Variable -Name MAX_REVISION -Option Constant -Value 83647 -WhatIf:$false

    if ($PSVersionTable.PSVersion.Major -lt 6) {
        Write-Warning "$($CmdletName) : Semantic Versions are not supported on this PowerShell Major '$($PSVersionTable.PSVersion.Major)' version"

        if (Test-PSParameter -Name 'Patch' -Parameters $PSBoundParameters) {
            return New-FileVersion -Major $Major -Minor $Minor -Build $Patch
        }
        else {
            return New-FileVersion -Major $Major -Minor $Minor
        }
    }

    if ($PSCmdlet.ParameterSetName -eq 'UsingString') {
        try {
            [semver]::new($Value) | Write-Output
        }
        catch {
            $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
            $Error | Write-Fatal
        }
    }
    else {
        $utc = Get-UtcDate
        $build = New-BuildNumber -OffsetFrom $OffsetFrom -Utc $utc
        $revision = New-RevisionNumber -MaxRevision $MAX_REVISION -Utc $utc
        $metadataList = [System.Collections.ArrayList]::new()

        if (-not (Test-PSParameter -Name 'Patch' -Parameters $PSBoundParameters)) {
            $Patch = New-PatchNumber -OffsetFrom $OffsetFrom -Utc $utc
        }

        $metadataList.Add("Build-$($build)") | Out-Null
        $metadataList.Add("Revision-$($revision)") | Out-Null

        if (Test-PSParameter -Name 'BuildLabel' -Parameters $PSBoundParameters) {
            $metadataList.AddRange($BuildLabel) | Out-Null
        }

        $metaData = ($metadataList.ToArray() -join '-')

        if ($PSCmdlet.ShouldProcess(@($Major, $Minor, $Patch, $metaData), $CmdletName)) {
            if ((Test-PSParameter -Name 'PrereleaseLabel' -Parameters $PSBoundParameters) -and ($metaData.Length -gt 0)) {
                Write-Verbose -Message "$($CmdletName) : SemanticVersion is supported.  Using Prerelease and Build Labels"
                [semver]::new($Major, $Minor, $Patch, $PreReleaseLabel, $metadata) | Write-OutPut
            }
            elseif ($metaData.Length -gt 0) {
                Write-Verbose -Message "$($CmdletName) : SemanticVersion is supported.  Using Build Label"
                [semver]::new($Major, $Minor, $Patch, $metadata) | Write-OutPut
            }
            else {
                Write-Verbose -Message "$($CmdletName) : SemanticVersion is supported without metadata" | Write-Verbose
                [semver]::new($Major, $Minor, $Patch) | Write-OutPut
            }
        }
    }

    <#
        .SYNOPSIS
        Create a new semantic version from `Major`, `Minor`, `Patch`,
        `PrereleaseLabel`, and `BuildLabel`.

        .DESCRIPTION
        `New-SemanticVersion` creates a new file version from `Major`, `Minor`,
        `Patch`, `PrereleaseLabel`, and `BuildLabel`.

        If `Patch` is not specified, the revision number will be calculated
        as the number of the number of days from `OffsetFrom` multiplied by
        10000 over ticks-per-day modulus the maximum revision number.  The
        maximum count days is 65534 and the maximum revision number is
        currently 83647.

        .PARAMETER Major
        The major portion of the semantic version.  `Major` must be in the
        range [0, 65534] and is required.

        .PARAMETER Minor
        The minor portion of the semantic version.  `Minor` must be in the
        range [0, 65534] and is required.

        .PARAMETER Patch
        The revision portion of the semantic version.  `Revision` must be in
        the range [0, 2147483647] and is optional.  If `Revision` is not
        specified, the revision number will be calculated as the number of days
        from `OffsetFrom` multiplied by 10000 over ticks-per-day modulus the
        maximum revision number.  The maximum count days is currently 65534.
        The maximum revision number is currently 83647.

        .PARAMETER OffsetFrom
        The date time from which days are counted to the current UTC day.
        Defaults to '01/01/2000'.

        .PARAMETER PrereleaseLabel
        Specifies the PreRelease portion of the SemVer 2.0 semantic version.
        `PrereleaseLabel` may not contain '-' or '+', and it must match the
        regular expression `[preview|alpha|beta|pre|rc|a|b]\d*`.  Only one
        instance of `PrereleaseLabel` may be specified.

        .PARAMETER BuildLabel
        Specifies the `BuildLabel` portion of the SemVer 2.0 semantic version
        as an array of strings.  No string in `BuildMetadata` may contain
        '+'.  By default, `Build-\d+` and `Revision-\d+` are
        always added.

        .PARAMETER Value
        Specifies the string representation of the semantic version.

        .INPUTS
        None.  `New-SemanticVersion` does not take any PowerShell pipeline input.

        .OUTPUTS
        [semver]
        `New-SemanticVersion` returns an instance representing the SemVer 2.0
        semantic version.

        [version]
        If the PowerShell Major version is less than 6, returns an instance
        representing the QFE file version.

        .NOTES
        Copyright © 2023-2025, U.S. Office of Personnel Management.  All
        Rights Reserved.

        .EXAMPLE
        PS> New-SemanticVersion -Major 1 -Minor 0 -PrereleaseLabel 'rc1' -BuildMetadata 'TST'

        Major  Minor  Patch   PreReleaseLabel BuildLabel
        -----  -----  -----   --------------- ----------
        1      0      59710.. rc1             Build-9110..

        Outputs a SemVer 2.0 semantic version with `PrereleaseLabel` and both
        pre-defined and additional `BuildLabel` text.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Get-UtcDate

        .LINK
        Set-Variable

        .LINK
        Test-PSParameter

        .LINK
        Write-Output

        .LINK
        Write-Verbose

        .LINK
        Write-Warning
    #>
}

New-Alias -Name New-SemVersion -Value New-SemanticVersion

<#
    New-Version
#>
function New-Version {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'UsingQuads')]
    [OutputType([version])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingQuads')]
        [ValidateRange(0, 65534)]
        [int]
        $Major,

        [Parameter(ParameterSetName = 'UsingQuads')]
        [ValidateRange(0, 65534)]
        [int]
        $Minor = 0,

        [Parameter(ParameterSetName = 'UsingQuads')]
        [ValidateRange(0, 65534)]
        [int]
        $Build = 0,

        [Parameter(ParameterSetName = 'UsingQuads')]
        [ValidateRange(0, 65534)]
        [int]
        $Revision = 0,

        [Parameter(Mandatory, ParameterSetName = 'UsingString')]
        [ValidatePattern('^(?<major>\d+)(\.(?<minor>\d+))?(\.(?<build>\d+))?(\.(?<revision>\d+))?$')]
        [string]
        $Value
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if ($PSCmdlet.ParameterSetName -eq 'UsingString') {
        try {
            [version]::new($Value) | Write-Output
        }
        catch {
            $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
            $Error | Write-Fatal
        }
    }
    else {
        if ($PSCmdlet.ShouldProcess(@($Major, $Minor, $Build, $Revision), $CmdletName)) {
            New-Object -TypeName System.Version -ArgumentList $Major, $Minor, $Build, $Revision
        }
    }

    <#
        .SYNOPSIS
        Create a new version from `Major`, `Minor`, `Build`, and `Revision`.

        .DESCRIPTION
        `New-Version` creates a new version from `Major`, `Minor`, `Build`, and `Revision`.

        .PARAMETER Major
        The major portion of a [version].  `Major` must be in the range [0, 65534] and is required.

        .PARAMETER Minor
        The minor portion of a [version].  `Minor` must be in the range [0, 65534] and is optional.

        .PARAMETER Build
        The build portion of a [version].  `Build` must be in the range [0, 65534] and is optional.

        .PARAMETER Revision
        The revision portion of a [version].  `Revision` must be in the range [0, 65534] and is optional.

        .PARAMETER Value
        Specifies the string representation of the version to parse and return as a [version].

        .INPUTS
        None.  `New-Version` does not take any PowerShell pipeline input.

        .OUTPUTS
        [version]  `New-Version` returns an instance to the PowerShell pipeline output.
        .EXAMPLE
        PS> New-Version -Major 1 -Minor 0 -Build 1234 -Revision 0

        Major  Minor  Build  Revision
        -----  -----  -----  --------
            1      0   1234         0

        Create a new version.

        .NOTES
        Copyright © 2024-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Initialize-PSCmdlet

        .LINK
        New-Object
    #>
}

<#
    New-WindowsVersion
#>
function New-WindowsVersion {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([ulong])]
    param (
        [Parameter(Mandatory)]
        [uint16]
        $Major,

        [Parameter(Mandatory)]
        [uint16]
        $Minor,

        [Parameter(Mandatory)]
        [uint16]
        $Build,

        [Parameter(Mandatory)]
        [uint16]
        $Revision
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if ($PSCmdlet.ShouldProcess(@($Major, $Minor, $Build, $Revision), $CmdletName)) {
        ([ulong]$Major -shl 48) -bor ([ulong]$Minor -shl 32) -bor ([ulong]$Build -shl 16) -bor [ulong]$Revision | Write-Output
    }

    <#
        .SYNOPSIS
        Create a new Windows version from `Major`, `Minor`, `Build`, and `Revision`.

        .DESCRIPTION
        `New-WindowsVersion` creates a new Windows version from `Major`, `Minor`, `Build`, and `Revision`.

        .PARAMETER Major
        Specifies a [ushort] number for the major portion of the Windows version.  `Major` is required.

        .PARAMETER Minor
        Specifies a [ushort] number for the minor portion of the Windows version.  `Minor` is required.

        .PARAMETER Build
        Specifies a [ushort] number for the build portion of the Windows version.  `Build` is required.

        .PARAMETER Revision
        Specifies the [ushort] number for the revision portion of the Windows version.  `Revision` is required.

        .INPUTS
        None.  `New-WindowsVersion` does not take any PowerShell pipeline input.

        .OUTPUTS
        None.  `New-WindowsVersion` does not return any PowerShell pipeline output.

        .EXAMPLE
        PS> New-WindowsVersion -Major 10 -Minor 0 -Build 19041 -Revision 572

        2814751014978108

        Generates a windows version number.

        .NOTES
        Copyright © 2024-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Initialize-PSCmdlet
    #>
}

<#
    Test-CPreRelease
#>
function Test-CPreRelease {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $PreRelease
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    switch ($PreRelease) {
        { $_ -cmatch '^preview\d+$' } {
            return $true
        }

        { $_ -cmatch '^alpha\d+$' } {
            return $true
        }

        { $_ -cmatch '^beta\d+$' } {
            return $true
        }

        { $_ -cmatch '^pre\d+$' } {
            return $true
        }

        { $_ -cmatch '^rc\d+$' } {
            return $true
        }

        { $_ -cmatch '^r\d+$' } {
            return $true
        }

        { $_ -cmatch '^a\d+$' } {
            return $true
        }

        { $_ -cmatch '^b\d+$' } {
            return $true
        }

        default {
            return $false
        }
    }

    <#
        .SYNOPSIS
        Test if a string is a valid, case-sensitive pre-release label.

        .DESCRIPTION
        `Test-CPreRelease` tests if a string is a valid, case-sensitive pre-release label.

        .PARAMETER PreRelease
        The pre-release label to test.  `PreRelease` must be a valid pre-release label.

        .INPUTS
        None.  `Test-CPreRelease` does not take any PowerShell pipeline input.

        .OUTPUTS
        [bool]  `Test-CPreRelease` returns an instance to the PowerShell pipeline output.

        .EXAMPLE
        PS> Test-CPreRelease -PreRelease 'rc1'

        True

        Test if a string is a valid pre-release label.

        .NOTES
        Copyright © 2024-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Initialize-PSCmdlet
    #>
}

<#
    Test-PreRelease
#>
function Test-PreRelease {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [Alias('PreRelease')]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $PrereleaseLabel
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    switch ($PrereleaseLabel) {
        { $_ -match '^preview\d+$' } {
            return $true
        }

        { $_ -match '^alpha\d+$' } {
            return $true
        }

        { $_ -match '^beta\d+$' } {
            return $true
        }

        { $_ -match '^pre\d+$' } {
            return $true
        }

        { $_ -match '^rc\d+$' } {
            return $true
        }

        { $_ -match '^r\d+$' } {
            return $true
        }

        { $_ -match '^a\d+$' } {
            return $true
        }

        { $_ -match '^b\d+$' } {
            return $true
        }

        default {
            return $false
        }
    }

    <#
        .SYNOPSIS
        Test if a string is a valid, case-insensitive pre-release label.

        .DESCRIPTION
        `Test-PreRelease` tests if a string is a valid, case-insensitive pre-release label.

        .PARAMETER PrereleaseLabel
        The pre-release label to test.  `PrereleaseLabel` must be a valid pre-release label.

        .INPUTS
        None.  `Test-PreRelease` does not take any PowerShell pipeline input.

        .OUTPUTS
        [bool]  `Test-PreRelease` returns an instance to the PowerShell pipeline output.

        .EXAMPLE
        PS> Test-PreRelease -PrereleaseLabel 'rc1'

        True

        Test if a string is a valid pre-release label.

        .NOTES
        Copyright © 2024-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Initialize-PSCmdlet
    #>
}

<#
    Write-AssemblyVersionToAssemblyInfo
#>
function Write-AssemblyVersionToAssemblyInfo {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType 'Leaf' })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType 'Leaf' })]
        [string[]]
        $LiteralPath,

        [Parameter(Mandatory)]
        [version]
        $Version
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
        Set-Variable -Name AssemblyVersionPattern -Option Constant -Value '^\[assembly: AssemblyVersion\("(.*)"\)\]$'
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | ForEach-Object -Process {
                $fileName = $_.Name
                $fullName = $_.FullName
                $backupPath = Join-Path -Path $env:TEMP -ChildPath $fileName

                Get-Content -LiteralPath $fullName | ForEach-Object -Process {
                    if ($_ -match $AssemblyVersionPattern) {
                        $_ -replace $AssemblyVersionPattern, ('[assembly: AssemblyVersion("{0}")]' -f $Version)
                    }
                    else {
                        # output line as is
                        $_
                    }
                } | Set-Content -LiteralPath $backupPath

                Move-Item -LiteralPath $backupPath -Destination $fullName -Force

                Write-Verbose -Message ("$($CmdletName) : AssemblyVersion in File '{0}' updated to '{1}'" -f $fullName, $Version)
            }
        }
        else {
            $Path | Resolve-Path | Get-Item | ForEach-Object -Process {
                $fileName = $_.Name
                $fullName = $_.FullName
                $backupPath = Join-Path -Path $env:TEMP -ChildPath $fileName

                Get-Content -Path $fullName | ForEach-Object -Process {
                    if ($_ -match $AssemblyVersionPattern) {
                        $_ -replace $AssemblyVersionPattern, ('[assembly: AssemblyVersion("{0}")]' -f $Version)
                    }
                    else {
                        # output line as is
                        $_
                    }
                } | Set-Content -Path $backupPath

                Move-Item -Path $backupPath -Destination $fullName -Force

                Write-Verbose -Message ("$($CmdletName) : AssemblyVersion in File '{0}' updated to '{1}'" -f $fullName, $Version)
            }
        }
    }

    <#
        .SYNOPSIS
        Updates the AssemblyVersion attribute in an AssemblyInfo.cs-style file.

        .DESCRIPTION
        `Write-AssemblyVersionToAssemblyInfo` updates the AssemblyVersion attribute in an AssemblyInfo.cs-style file.

        .PARAMETER Path
        Specifies the path, possibly with wildcards, to the AssemblyInfo.cs-style file.

        .PARAMETER LiteralPath
        Specifies the literal path to the AssemblyInfo.cs-style file.

        .PARAMETER Version
        Specifies the version to write.

        .INPUTS
        [string[]]. `Write-AssemblyVersionToAssemblyInfo` takes path strings as input from the PowerShell pipeline.

        .OUTPUTS
        None. `Write-AssemblyVersion` does not output to the PowerShell pipeline.

        .EXAMPLE
        PS> Write-AssemblyVersionToAssemblyInfo -Path 'C:\Path\To\AssemblyInfo.cs' -Version '1.2.3.4' -Verbose

        VERBOSE: AssemblyVersion in File 'C:\Path\To\AssemblyInfo.cs' updated to '1.2.3.4'

        .NOTES
        Copyright © 2023-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Get-Content

        .LINK
        Get-Item

        .LINK
        Initialize-PSCmdlet

        .LINK
        Join-Path

        .LINK
        Move-Item

        .LINK
        Set-Content

        .LINK
        Set-Variable
    #>
}

<#
    Write-AssemblyFileVersionToAssemblyInfo
#>
function Write-AssemblyFileVersionToAssemblyInfo {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType 'Leaf' })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType 'Leaf' })]
        [string[]]
        $LiteralPath,

        [Parameter(Mandatory)]
        [version]
        $Version
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
        Set-Variable -Name AssemblyFileVersionPattern -Option Constant -Value '^\[assembly: AssemblyFileVersion\("(.*)"\)\]$'
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | ForEach-Object -Process {
                $fileName = $_.Name
                $fullName = $_.FullName
                $backupPath = Join-Path -Path $env:TEMP -ChildPath $fileName

                Get-Content -LiteralPath $fullName | ForEach-Object -Process {
                    if ($_ -match $AssemblyFileVersionPattern) {
                        $_ -replace $AssemblyFileVersionPattern, ('[assembly: AssemblyFileVersion("{0}")]' -f $Version)
                    }
                    else {
                        # output line as is
                        $_
                    }
                } | Set-Content -LiteralPath $backupPath

                Move-Item -LiteralPath $backupPath -Destination $fullName -Force

                Write-Verbose -Message ("$($CmdletName) : AssemblyFileVersion in File '{0}' updated to '{1}'" -f $fullName, $Version)
            }
        }
        else {
            $Path | Resolve-Path | Get-Item | ForEach-Object -Process {
                $fileName = $_.Name
                $fullName = $_.FullName
                $backupPath = Join-Path -Path $env:TEMP -ChildPath $fileName

                Get-Content -Path $fullName | ForEach-Object -Process {
                    if ($_ -match $AssemblyFileVersionPattern) {
                        $_ -replace $AssemblyFileVersionPattern, ('[assembly: AssemblyFileVersion("{0}")]' -f $Version)
                    }
                    else {
                        # output line as is
                        $_
                    }
                } | Set-Content -Path $backupPath

                Move-Item -Path $backupPath -Destination $fullName -Force

                Write-Verbose -Message ("$($CmdletName) : AssemblyFileVersion in File '{0}' updated to '{1}'" -f $fullName, $Version)
            }
        }
    }

    <#
        .SYNOPSIS
        Updates the AssemblyFileVersion attribute in an AssemblyInfo.cs-style file.

        .DESCRIPTION
        `Write-FileVersion` updates the AssemblyFileVersion attribute in an AssemblyInfo.cs-style file.

        .PARAMETER Path
        Specifies the path, possibly with wildcards, to the AssemblyInfo.cs-style file.

        .PARAMETER LiteralPath
        Specifies the literal path to the AssemblyInfo.cs-style file.

        .PARAMETER Version
        Specifies the version to write.

        .INPUTS
        None. `Write-AssemblyFileVersionToAssemblyInfo` does not take input from the PowerShell pipeline.

        .OUTPUTS
        None. `Write-AssemblyFileVersionToAssemblyInfo` does not output to the PowerShell pipeline.

        .EXAMPLE
        PS> Write-AssemblyFileVersionToAssemblyInfo -Path 'C:\Path\To\AssemblyInfo.cs' -Version '1.2.3.4' -Verbose

        VERBOSE: AssemblyFileVersion in File 'C:\Path\To\AssemblyInfo.cs' updated to '1.2.3.4'

        .NOTES
        Copyright © 2023-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Format-Version

        .LINK
        Get-Content

        .LINK
        Get-Item

        .LINK
        Initialize-PSCmdlet

        .LINK
        Join-Path

        .LINK
        Move-Item

        .LINK
        Resolve-Path

        .LINK
        Select-Object

        .LINK
        Set-Content

        .LINK
        Set-Variable

        .LINK
        Write-Verbose
    #>
}

<#
    Write-FileVersionToSdkProj
#>
function Write-FileVersionToSdkProj {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -Include '*.csproj' -PathType 'Leaf' })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -Include '*.csproj' -PathType 'Leaf' })]
        [string[]]
        $LiteralPath,

        [Parameter(Mandatory)]
        [string]
        $Version
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | ForEach-Object -Process {
                $fileName = $_.Name
                $fullName = $_.FullName
                $backupPath = Join-Path -Path $env:TEMP -ChildPath $fileName

                $sdkProj = [xml](Get-Content -LiteralPath $fullName)

                if (Select-Xml -Xml $sdkProj -XPath '//Project/PropertyGroup/FileVersion') {
                    $sdkProj.Project.PropertyGroup.FileVersion = $Version
                    $sdkProj.Save($backupPath)
                    Move-Item -LiteralPath $backupPath -Destination $fullName -Force
                    Write-Verbose -Message ("$($CmdletName) : File Version in File '{0}' updated to '{1}'" -f $fullName, $Version)
                }
                else {
                    Write-Warning -Message ("$($CmdletName) : FileVersion element not found in File '{0}'" -f $fullName)
                }
            }
        }
        else {
            $Path | Resolve-Path | Get-Item | ForEach-Object -Process {

                $fileName = $_.Name
                $fullName = $_.FullName
                $backupPath = Join-Path -Path $env:TEMP -ChildPath $fileName

                if (Select-Xml -Path $fullName -XPath '//Project/PropertyGroup/FileVersion') {
                    $sdkProj = [xml](Get-Content -LiteralPath $fullName)
                    $sdkProj.Project.PropertyGroup.FileVersion = $Version
                    $sdkProj.Save($backupPath)
                    Move-Item -LiteralPath $backupPath -Destination $fullName -Force
                    Write-Verbose -Message ("$($CmdletName) : File Version in File '{0}' updated to '{1}'" -f $fullName, $Version)
                }
                else {
                    Write-Warning -Message ("$($CmdletName) : FileVersion element not found in File '{0}'" -f $fullName)
                }
            }
        }
    }

    <#
        .SYNOPSIS
        Updates the `FileVersion` element inner text with `Version` in an SDK .csproj file.

        .DESCRIPTION
        `Write-FileVersionToSdkProj` updates the `FileVersion` element inner text with `Version` in an SDK .csproj file.

        .PARAMETER Path
        Specifies one or more paths to SDK .csproj files to update.  Wildcards are supported.

        .PARAMETER LiteralPath
        Specifies one or more literal paths to SDK .csproj files to update.  Wildcards are not supports, and each path is treated
        exactly as it is passed.

        .PARAMETER Version
        Specifies the version to write.

        .INPUTS
        [string[]]  `Write-FileVersionToSdkProj` takes path strings as input from the PowerShell pipeline.

        .OUTPUTS
        None.  `Write-FileVersionToSdkProj` does not output to the PowerShell pipeline.

        .EXAMPLE
        PS> Write-FileVersionToSdkProj -Path 'C:\Path\To\SdkProject.csproj' -Version '1.2.3.4' -Verbose

        VERBOSE: FileVersion in File 'C:\Path\To\SdkProject.csproj' updated to '1.2.3.4'

        .NOTES
        Copyright © 2023-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Get-Content

        .LINK
        Get-Item

        .LINK
        Initialize-PSCmdlet

        .LINK
        Join-Path

        .LINK
        Move-Item

        .LINK
        Resolve-Path

        .LINK
        Write-Output

        .LINK
        Write-Verbose
    #>
}

<#
    Write-AssemblyInformationalVersionToAssemblyInfo
#>
function Write-AssemblyInformationalVersionToAssemblyInfo {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType 'Leaf' })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ParameterSetName = 'UsingLiteralPath')]
        [Parameter(Mandatory, ParameterSetName = 'UsingXPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType 'Leaf' })]
        [string[]]
        $LiteralPath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Version
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
        Set-Variable -Name InformationalVersionPattern -Option Constant -Value '^\[assembly: AssemblyInformationalVersion\("(.*)"\)\]$'
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | ForEach-Object -Process {
                $fileName = $_.Name
                $fullName = $_.FullName
                $backupPath = Join-Path -Path $env:TEMP -ChildPath $fileName

                Get-Content -LiteralPath $fullName | ForEach-Object -Process {
                    if ($_ -match $AssemblyFileVersionPattern) {
                        $_ -replace $AssemblyInformationalVersionPattern, ('[assembly: AssemblyInformationalVersion("{0}")]' -f $Version)
                    }
                    else {
                        # output line as is
                        $_
                    }
                } | Set-Content -LiteralPath $backupPath

                Move-Item -LiteralPath $backupPath -Destination $fullName -Force

                Write-Verbose -Message ("$($CmdletName) : AssemblyInformationalVersion in File '{0}' updated to '{1}'" -f $fullName, $Version)
            }
        }
        else {
            $Path | Resolve-Path | Get-Item | ForEach-Object -Process {
                $fileName = $_.Name
                $fullName = $_.FullName
                $backupPath = Join-Path -Path $env:TEMP -ChildPath $fileName

                Get-Content -Path $fullName | ForEach-Object -Process {
                    if ($_ -match $AssemblyFileVersionPattern) {
                        $_ -replace $AssemblyInformationalVersionPattern, ('[assembly: AssemblyInformationalVersion("{0}")]' -f $Version)
                    }
                    else {
                        # output line as is
                        $_
                    }
                } | Set-Content -Path $backupPath

                Move-Item -Path $backupPath -Destination $fullName -Force

                Write-Verbose -Message ("$($CmdletName) : AssemblyInformationalVersion in File '{0}' updated to '{1}'" -f $fullName, $Version)
            }
        }
    }

    <#
        .SYNOPSIS
        Updates the AssemblyInformationalVersion attribute in an AssemblyInfo.cs-style file.

        .DESCRIPTION
        `Write-AssemblyInformationalVersionToAssemblyInfo` updates the AssemblyInformationalVersion attribute in an
        AssemblyInfo.cs-style file.

        .PARAMETER Path
        Specifies the path, possibly with wildcards, to the AssemblyInfo.cs-style file.

        .PARAMETER LiteralPath
        Specifies the literal path to the AssemblyInfo.cs-style file.

        .PARAMETER Version
        Specifies the Informational or Product Version to write.

        .INPUTS
        [string[]]  `Write-AssemblyInformationalVersionToAssemblyInfo` takes path strings as input from the PowerShell pipeline.

        .OUTPUTS
        None.  `Write-AssemblyInformationalVersionToAssemblyInfo` does not output to the PowerShell pipeline.

        .EXAMPLE
        PS> Write-AssemblyInformationalVersionToAssemblyInfo -Path 'C:\Path\To\AssemblyInfo.cs' -Version '1.2.0.0' -Verbose

        VERBOSE: AssemblyInformationalVersion in File 'C:\Path\To\AssemblyInfo.cs' updated to '1.2.0.0'

        .NOTES
        Copyright © 2023-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Get-Content

        .LINK
        Get-Item

        .LINK
        Initialize-PSCmdlet

        .LINK
        Join-Path

        .LINK
        Move-Item

        .LINK
        Resolve-Path

        .LINK
        Select-Object

        .LINK
        Set-Content

        .LINK
        Set-Variable

        .LINK
        Write-Verbose
    #>
}

<#
    Write-InformationalVersionToSdkProj
#>
function Write-InformationalVersionToSdkProj {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -Include '*.csproj' -PathType 'Leaf' })]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -Include '*.csproj' -PathType 'Leaf' })]
        [string[]]
        $LiteralPath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Version
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | ForEach-Object -Process {
                $fileName = $_.Name
                $fullName = $_.FullName
                $backupPath = Join-Path -Path $env:TEMP -ChildPath $fileName

                if (Select-Xml -Path $fullName -XPath '//Project/PropertyGroup/InformationalVersion') {
                    $sdkProj = [xml](Get-Content -LiteralPath $fullName)
                    $sdkProj.Project.PropertyGroup.InformationalVersion = $Version
                    $sdkProj.Save($backupPath)
                    Move-Item -LiteralPath $backupPath -Destination $fullName -Force
                    Write-Verbose -Message ("$($CmdletName) : Informational Version in File '{0}' updated to '{1}'" -f $fullName, $Version)
                }
                else {
                    Write-Warning -Message ("$($CmdletName) : InformationalVersion element not found in File '{0}'" -f $fullName)
                }
            }
        }
        else {
            $Path | Resolve-Path | Get-Item | ForEach-Object -Process {

                $fileName = $_.Name
                $fullName = $_.FullName
                $backupPath = Join-Path -Path $env:TEMP -ChildPath $fileName

                if (Select-Xml -Path $fullName -XPath '//Project/PropertyGroup/InformationalVersion') {
                    $sdkProj = [xml](Get-Content -LiteralPath $fullName)
                    $sdkProj.Project.PropertyGroup.InformationalVersion = $Version
                    $sdkProj.Save($backupPath)
                    Move-Item -LiteralPath $backupPath -Destination $fullName -Force
                    Write-Verbose -Message ("$($CmdletName) : Informational Version in File '{0}' updated to '{1}'" -f $fullName, $Version)
                }
                else {
                    Write-Warning -Message ("$($CmdletName) : InformationalVersion element not found in File '{0}'" -f $fullName)
                }
            }
        }
    }

    <#
        .SYNOPSIS
        Updates the `InformationalVersion` element inner text with `Version` in an SDK .csproj file.

        .DESCRIPTION
        `Write-InformationalVersionToSdkProj` updates the `InformationalVersion` element inner text with `Version` in an SDK .csproj file.

        .PARAMETER Path
        Specifies one or more paths to SDK .csproj files to update.  Wildcards are supported.

        .PARAMETER LiteralPath
        Specifies one or more literal paths to SDK .csproj files to update.  Wildcards are not supports, and each path is treated
        exactly as it is passed.

        .PARAMETER Version
        Specifies the version to write.

        .INPUTS
        [string[]]  `Write-InformationalVersionToSdkProj` takes path strings as input from the PowerShell pipeline.

        .OUTPUTS
        None.  `Write-InformationalVersionToSdkProj` does not output to the PowerShell pipeline.

        .EXAMPLE
        PS> Write-InformationalVersionToSdkProj -Path 'C:\Path\To\SdkProject.csproj' -Version '1.2.3.4' -Verbose

        VERBOSE: InformationalVersion in File 'C:\Path\To\SdkProject.csproj' updated to '1.2.3.4'

        .NOTES
        Copyright © 2023-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Get-Content

        .LINK
        Get-Item

        .LINK
        Initialize-PSCmdlet

        .LINK
        Join-Path

        .LINK
        Move-Item

        .LINK
        Resolve-Path

        .LINK
        Write-Output

        .LINK
        Write-Verbose
    #>
}

<#
    Write-ModuleVersion
#>
function Write-ModuleVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -Path $_ -Include '*.psd1' -PathType 'Leaf' })]
        [string]
        $Path,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Version
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    Update-ModuleManifest -Path $Path -ModuleVersion $Version

    <#
        .SYNOPSIS
        Writes the version to a module manifest.

        .DESCRIPTION
        `Write-ModuleVersion` writes the version to a module manifest.

        .PARAMETER Path
        Specifies the literal path to the module manifest (.psd1) file.

        .PARAMETER Version
        Specifies the update version string.

        .INPUTS
        None.  `Write-ModuleVersion` does not take any PowerShell pipeline input.

        .OUTPUTS
        None.  `Write-ModuleVersion` does not return any PowerShell pipeline output.

        .NOTES
        Copyright © 2023-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Initialize-PSCmdlet

        .LINK
        Test-Path

        .LINK
        Update-ModuleManifest
    #>
}

<#
    Write-VersionToSdkProj
#>
function Write-VersionToSdkProj {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -Include '*.csproj' -PathType 'Leaf' })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -Include '*.csproj' -PathType 'Leaf' })]
        [string[]]
        $LiteralPath,

        [Parameter(Mandatory)]
        [string]
        $Version
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | ForEach-Object -Process {
                $fileName = $_.Name
                $fullName = $_.FullName
                $backupPath = Join-Path -Path $env:TEMP -ChildPath $fileName

                if (Select-Xml -Path $fullName -XPath '//Project/PropertyGroup/Version') {
                    $sdkProj = [xml](Get-Content -LiteralPath $fullName)
                    $sdkProj.Project.PropertyGroup.Version = $Version
                    $sdkProj.Save($backupPath)
                    Move-Item -LiteralPath $backupPath -Destination $fullName -Force
                    Write-Verbose -Message ("$($CmdletName) : Version in File '{0}' updated to '{1}'" -f $fullName, $Version)
                }
                else {
                    Write-Warning -Message ("$($CmdletName) : Version element not found in File '{0}'" -f $fullName)
                }
            }
        }
        else {
            $Path | Resolve-Path | Get-Item | ForEach-Object -Process {

                $fileName = $_.Name
                $fullName = $_.FullName
                $backupPath = Join-Path -Path $env:TEMP -ChildPath $fileName

                if (Select-Xml -Path $fullName -XPath '//Project/PropertyGroup/Version') {
                    $sdkProj = [xml](Get-Content -LiteralPath $fullName)
                    $sdkProj.Project.PropertyGroup.Version = $Version
                    $sdkProj.Save($backupPath)
                    Move-Item -LiteralPath $backupPath -Destination $fullName -Force
                    Write-Verbose -Message ("$($CmdletName) : Version in File '{0}' updated to '{1}'" -f $fullName, $Version)
                }
                else {
                    Write-Warning -Message ("$($CmdletName) : Version element not found in File '{0}'" -f $fullName)
                }
            }
        }
    }

    <#
        .SYNOPSIS
        Updates the `Version` element inner text with `Version` in an SDK .csproj file.

        .DESCRIPTION
        `Write-VersionToSdkProj` updates the `Version` element inner text with `Version` in an SDK .csproj file.

        .PARAMETER Path
        Specifies one or more paths to SDK .csproj files to update.  Wildcards are supported.

        .PARAMETER LiteralPath
        Specifies one or more literal paths to SDK .csproj files to update.  Wildcards are not supports, and each path is treated
        exactly as it is passed.

        .PARAMETER Version
        Specifies the version to write.

        .INPUTS
        [string[]]  `Write-VersionToSdkProj` takes path strings as input from the PowerShell pipeline.

        .OUTPUTS
        None.  `Write-VersionToSdkProj` does not output to the PowerShell pipeline.

        .EXAMPLE
        PS> Write-VersionToSdkProj -Path 'C:\Path\To\SdkProject.csproj' -Version '1.2.3.4' -Verbose

        VERBOSE: Version in File 'C:\Path\To\SdkProject.csproj' updated to '1.2.3.4'

        .NOTES
        Copyright © 2023-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Get-Content

        .LINK
        Get-Item

        .LINK
        Initialize-PSCmdlet

        .LINK
        Join-Path

        .LINK
        Move-Item

        .LINK
        Resolve-Path

        .LINK
        Write-Output

        .LINK
        Write-Verbose
    #>
}

<#
    Write-XPathVersion
#>
function Write-XPathVersion {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType 'Leaf' })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType 'Leaf' })]
        [string[]]
        $LiteralPath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Version,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $XPath
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | ForEach-Object -Process {
                $fileName = $_.Name
                $fullName = $_.FullName
                $backupPath = Join-Path -Path $env:TEMP -ChildPath $fileName

                $xdocument = [xml](Get-Content -LiteralPath $fullName)
                $xdocument.SelectSingleNode($XPath).Version = $Version
                $xdocument.Save($backupPath)

                Move-Item -LiteralPath $backupPath -Destination $fullName -Force

                Write-Verbose -Message ("$($CmdletName) : Version XPath '{0}' in File '{1}' updated to '{2}'" -f $XPath, $fullName, $Version)
            }
        }
        else {
            $Path | Resolve-Path | Get-Item | ForEach-Object -Process {
                $fileName = $_.Name
                $fullName = $_.FullName
                $backupPath = Join-Path -Path $env:TEMP -ChildPath $fileName

                $xdocument = [xml](Get-Content -LiteralPath $fullName)
                $xdocument.SelectSingleNode($XPath).InnerText = $Version
                $xdocument.Save($backupPath)

                Move-Item -LiteralPath $backupPath -Destination $fullName -Force

                Write-Verbose -Message ("$($CmdletName) : Version XPath '{0}' in File '{1}' updated to '{2}'" -f $XPath, $fullName, $Version)
            }
        }
    }

    <#
        .SYNOPSIS
        Updates the Version Inner Text of `XPath` in an XML file.

        .DESCRIPTION
        `Write-XPathVersion` updates the Version Inner Text of `XPath` in an XML file.

        .PARAMETER Path
        Specifies the path, possibly with wildcards, to the XML file.

        .PARAMETER LiteralPath
        Specifies the literal path to the XML file.

        .PARAMETER Version
        Specifies the version strign to write.

        .PARAMETER XPath
        Specifies the XPath to the Parent Node containing an `InnerText` to be set to `Version`.

        .INPUTS
        [string[]]. `Write-XPathVersion` takes path strings as input from the PowerShell pipeline.

        .OUTPUTS
        None.  `Write-XPathVersion` does not output to the PowerShell pipeline.

        .EXAMPLE
        PS> Write-XPathVersion -Path 'C:\Path\To\SdkProject.csproj' -Version '1.2.3.4' -XPath '//Project/PropertyGroup/Version' -Verbose

        VERBOSE: Version XPath '//Project/PropertyGroup/Version' in File 'C:\Path\To\SdkProject.csproj' updated to '1.2.3.4'

        .NOTES
        Copyright © 2023-2025, U.S. Office of Personnel Management.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Get-Content

        .LINK
        Initialize-PSCmdlet

        .LINK
        Resolve-Path
    #>
}

<#
 =============================================================================
<copyright file="EnvironmentModule.psm1" company="U.S. Office of Personnel
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
<date>Created:  2024-9-12</date>
<summary>
This file "EnvironmentModule.psm1" is part of "EnvironmentModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

#requires -Module ErrorRecordModule
#requires -Module PowerShellModule

#
# EnvironmentModule.psm1
#

<#
    Add-EnvironmentValue
#>
function Add-EnvironmentValue {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Value,

        [switch]
        $Sort
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if (Test-EnvironmentVariable -Name $Name) {
        $path = Get-EnvironmentVariable -Name $Name

        if ($path.Contains([System.IO.Path]::PathSeparator)) {
            $pathList = [System.Collections.ArrayList]::new(($path.Split([System.IO.Path]::PathSeparator, [System.StringSplitOptions]::RemoveEmptyEntries)))
            $pathList.Add($Value) | Out-Null

            if ($Sort.IsPresent) {
                (($pathList.ToArray() | Sort-Object -Descending -Unique) -join [System.IO.Path]::PathSeparator) | Write-Output
            }
            else {
                (($pathList.ToArray() | Sort-Object -Unique) -join [System.IO.Path]::PathSeparator) | Write-Output
            }
        } else {
            Write-Warning -Message "$($CmdletName) : Environment Variable '$($Name)' has nothing to split"
            $path | Write-Output
        }
    } else {
        $newErrorRecordSplat = @{
            Exception = [System.Management.Automation.ItemNotFoundException]::new("Environment Variable '$($Name)' does not exit")
            ErrorCategory = 'ObjectNotFound'
            ErrorId = Format-ErrorId -Caller $CmdletName -Name 'ItemNotFoundException' -Position $MyInvocation.ScriptLineNumber
            TargetObject = $Name
            TargetName = 'Name'
        }

        New-ErrorRecord @newErrorRecordSplat | Write-Fatal
    }

    <#
        .SYNOPSIS
        Add path `Value` to a delimited environment variable.

        .DESCRIPTION
        `Add-EnvironmentValue` adds a path `Value` to a delimited environment variable `Name`.

        .PARAMETER Name
        Specifies the delimited environment variable to which the path `Value` is added.  The delimiter should be the system path separator.

        .PARAMETER Value
        Specifies the path to be added to the environment variable `Name`.

        .PARAMETER Sort
        If set, the paths in the environment variable are sorted in descending order and duplicates are removed; otherwise, only duplicates are removed.

        .INPUTS
        None.  `Add-EnvironmentValue` does not accept pipeline input.

        .OUTPUTS
        [string].  The modified environment variable `Name` is returned.

        .EXAMPLE
        PS> Add-EnvironmentValue -Name 'Path' -Value 'C:\Program Files\MyApp'
        PS> $env:Path.Endswith('C:\Program Files\MyApp')

        True

        `C:\Program Files\MyApp` is appended to the Path environment variable.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Format-ErrorId

        .LINK
        Get-EnvironmentVariable

        .LINK
        New-ErrorRecord

        .LINK
        Out-Null

        .LINK
        Sort-Object

        .LINK
        Test-EnvironmentVariable

        .LINK
        Write-Fatal

        .LINK
        Write-Output

        .LINK
        Write-Warning
    #>
}

<#
    Copy-EnvironmentVariable
#>
function Copy-EnvironmentVariable {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $NewName,

        [switch]
        $Force
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $Name | ForEach-Object -Process {
            $path = Join-Path -Path Env: -ChildPath $_
            $newPath = Join-Path -Path Env: -ChildPath $NewName

            Copy-Item -LiteralPath $path -Destination $newPath -Force:$Force.IsPresent
        }
    }

    <#
        .SYNOPSIS
        Copies an environment variable from `Name` to `NewName`.

        .DESCRIPTION
        `Copy-EnvironmentVariable` copies the environment variable `Name` to `NewName`.

        .PARAMETER Name
        Specifies the source environment variable name to be copied.

        .PARAMETER NewName
        Specifies the destination environment variable name to be copied.

        .PARAMETER Force
        Specifies that the destination environment variable is overwritten if it already exists.

        .INPUTS
        [string[]]  `Copy-EnvironmentVariable` takes an array of strings as the source environment variable input.

        [string]  `Copy-EnvironmentVariable` takes a string as the destination environment variable input.

        .OUTPUTS
        None.  `Copy-EnvironmentVariable` does not return any output.

        .EXAMPLE
        PS> Copy-EnvironmentVariable -Name 'Path' -NewName 'NewPath'
        PS> $env:Path -eq $env:NewPath

        True

        Copied environment variable `Path` to `NewPath`.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Copy-Item

        .LINK
        ForEach-Object

        .LINK
        Initialize-PSCmdlet

        .LINK
        Join-Path
    #>
}

<#
    Get-EnvironmentVariable
#>
function Get-EnvironmentVariable {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Name,

        [switch]
        $AsString,

        [switch]
        $AsHashtable
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $Name | ForEach-Object -Process {
            $path = Join-Path -Path 'Env:' -ChildPath $_

            if ($AsString.IsPresent -and $AsHashtable.IsPresent) {
                $newErrorRecordSplat = @{
                    Exception = [System.ArgumentException]::new("Cannot specify both 'AsString' and 'AsHashtable'")
                    ErrorCategory = 'InvalidArgument'
                    ErrorId = Format-ErrorId -Caller $CmdletName -Name 'ArgumentException' -Position $MyInvocation.ScriptLineNumber
                    TargetObject = @{ AsString = $AsString; AsHashtable = $AsHashtable }
                    TargetName = 'AsString or AsHashtable'
                }

                New-ErrorRecord @newErrorRecordSplat | Write-Fatal
            }
            elseif ($AsString.IsPresent) {
                Get-Item -LiteralPath $path | ForEach-Object -Process { ('{0}, {1}' -f $_.Key, $_.Value) }
            }
            elseif ($AsHashtable.IsPresent) {
                # output as hashtable
                $result = @{}
                Get-Item -LiteralPath $path | ForEach-Object -Process { $result.Add($_.Key, $_.Value) }
                $result | Write-Output
            }
            else {
                Get-Item -LiteralPath $path | Select-Object -ExpandProperty Value | Write-Output
            }
        }
    }

    <#
        .SYNOPSIS
        Gets the value of a process environment variable.

        .DESCRIPTION
        `Get-EnvironmentVarialbe` gets the value of a process environment variable `Name`.

        .PARAMETER Name
        Specifies the name of the environment variable to retrieve.

        .PARAMETER AsString
        Specifies that the environment variable is returned as a string suitable for convertion to a [System.Tuple].  This switch is mutually exclusive with `AsHashtable`.

        .PARAMETER AsHashtable
        Specifies that the environment variable is returned as a hashtable.  This switch is mutually exclusive with `AsString`.

        .INPUTS
        [string[]]  `Get-EnvironmentVariable` takes an array of strings as the environment variable input.

        .OUTPUTS
        [string]  `Get-EnvironmentVariable` returns the value of the environment variable as a string.

        .EXAMPLE
        PS> Get-EnvironmentVariable -Name 'Path'

        Returns the value of the process environment variable 'Path'.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Get-Item

        .LINK
        New-ErrorRecord

        .LINK
        Out-Hashtable

        .LINK
        Select-Object

        .LINK
        Write-Fatal

        .LINK
        Write-Output
    #>
}

<#
    Get-EnvironmentHashtable
#>
function Get-EnvironmentHashtable {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param ()

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $result = @{}

    Get-ChildItem -LiteralPath Env: | ForEach-Object -Process {
        $result.Add($_.Key, $_.Value)
    }

    $result | Write-Output

    <#
        .SYNOPSIS
        Gets all process environment variables as a hashtable.

        .DESCRIPTION
        `Get-EnvironmentHashtable` gets all process environment variables as a hashtable.

        .INPUTS
        None.  `Get-EnvironmentHashtable` does not accept pipeline input.

        .OUTPUTS
        [hashtable]  `Get-EnvironmentHashtable` returns all process environment variables as a hashtable.

        .EXAMPLE
        PS> Get-EnvironmentHashtable


        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .EXAMPLE
        PS> Get-EnvironmentHashtable


        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Get-ChildItem

        .LINK
        Initialize-PSCmdlet

        .LINK
        Write-Output
    #>
}

<#
    Join-EnvironmentVariable
#>
function Join-EnvironmentVariable {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Value,

        [switch]
        $Descending,

        [switch]
        $NoSort,

        [switch]
        $PassThru
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        if (Test-EnvironmentVariable =Name $Name) {
            $path = Get-EnvironmentVariable -Name $Name

            if ($path.Contains([System.IO.Path]::PathSeparator)) {
                $pathList = [System.Collections.ArrayList]::new(($path -split [System.IO.Path]::PathSeparator)) | Out-Null
            } else {
                Write-Warning -Message "$($CmdletName):  Environment Variable '$($Name)' has nothing to split"
                return
            }
        }
        else {
            Write-Error -Message "$($CmdletName):  Environment Variable '$($Name)' does not exit" -ErrorAction Continue
            return
        }
    }

    PROCESS {
        $Value | ForEach-Object -Process {
            $pathList.Add($_) | Out-Null
        }

        if ($NoSort.IsPresent) {
            (($pathList.ToArray() -join [System.IO.Path]::PathSeparator) |
                Set-EnvironmentVariable -Name $Name -PassThru:$PassThru.IsPresent) |
                    Write-Output
        }
        else {
            (($pathList.ToArray() | Sort-Object -Descending:$Descending.IsPresent -Unique) -join [System.IO.Path]::PathSeparator) |
                Set-EnvironmentVariable -Name $Name -PassThru:$PassThru.IsPresent |
                    Write-Output
        }
    }

    <#
        .SYNOPSIS
        Appends `Value` to a delimited environment variable.

        .DESCRIPTION
        `Join-EnvironmentVariable` appends `Value` to a delimited environment variable `Name`.

        The delimiter is expected to be the system path separator.

        All the `Values` are sorted for uniqueness, unless `NoSort` is passed.

        The new value string, joined with the system path separator, is assigned to environment variable `Name` in the process environment space.

        If `NoSort` is passed, the `Value's are all appended in order to the end.  Duplicate values will remain.

        A warning is issued if the environment variable `Name` does not contain the system path separator.

        An non-terminating error is issued if environment variable `Name` does not exist.

        .PARAMETER Name
        Specifies the delimited environment variable to which `Value` is appended.

        .PARAMETER Value
        Specifies the value to append to `Name` delimited environment variable.

        .PARAMETER Descending
        If specified, and `NoSort` is not specified, the values are sorted in descending order.

        .PARAMETER NoSort
        If specified, the values are appended in order to the end.  Duplicate values will remain.

        .PARAMETER PassThru
        If specified, the modified environment variable `Name` is returned.

        .INPUTS
        [string[]]  `Join-EnvironmentVariable` takes an array of strings as the `Value` input from the pipeline.

        .OUTPUTS
        [string]  If `PassThru` is present, the modified environment variable `Name` is returned to the PowerShell pipeline.

        .EXAMPLE
        PS> Join-EnvironmentVariable -Name 'Path' -Value 'C:\Program Files\MyApp'

        Appends `C:\Program Files\MyApp` to the Path environment variable and sorts the values for uniqueness descending.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Get-EnvironmentVariable

        .LINK
        Initialize-PSCmdlet

        .LINK
        Set-EnvironmentVariable

        .LINK
        Sort-Object

        .LINK
        Test-EnvironmentVariable

        .LINK
        Write-Error

        .LINK
        Write-Output

        .LINK
        Write-Warning
    #>
}

<#
    New-EnvironmentVariable
#>
function New-EnvironmentVariable {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Value
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
        $path = Join-Path -Path Env: -ChildPath $Name
    }

    PROCESS {
        $Value | New-Item -LiteralPath $path
    }

    <#
        .SYNOPSIS
        Creates a new environment variable `Name` with value `Value` in the process environment space.

        .DESCRIPTION
        `New-EnvironmentVariable` creates a new environment variable `Name` with value `Value` in the process environment space.

        .PARAMETER Name
        Specifies the name of the environment variable to create.

        .PARAMETER Value
        Specifies the value to assign to the new environment variable.

        .INPUTS
        [string]  `New-EnvironmentVariable` takes a string as the environment variable value input from the pipeline.

        .OUTPUTS
        None.  `New-EnvironmentVariable` does not return any output to the PowerShell pipeline.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .EXAMPLE
        PS> New-EnvironmentVariable -Name 'NewPath' -Value 'C:\Program Files\MyApp'
        PS> $env:NewPath -eq 'C:\Program Files\MyApp'

        True

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Initialize-PSCmdlet

        .LINK
        Join-Path

        .LINK
        New-Item
    #>
}

<#
    Out-ArrayList
#>
function Out-ArrayList {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'UsingElements')]
    [OutputType([System.Collections.ArrayList])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingCollection')]
        [System.Collections.ICollection]
        $Collection,

        [Parameter(Mandatory, ParameterSetName = 'UsingCapacity')]
        [ValidateRange(0, 2147483647)]
        [int]
        $Capacity,

        [Parameter(Mandatory, ParameterSetName = 'UsingElements', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [System.Object[]]
        $Element
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        switch ($PSCmdlet.ParameterSetName) {
            'UsingCollection' {
                if ($PSCmdlet.ShouldProcess('Collection Interface', $CmdletName)) {
                    [System.Collections.ArrayList]::new($Collection) | Write-Output
                }

                break
            }

            'UsingCapacity' {
                if ($Capacity -gt 0) {
                    if ($PSCmdlet.ShouldProcess($Capacity, $CmdletName)) {
                        [System.Collections.ArrayList]::new($Capacity) | Write-Output
                    }
                } else {
                    if ($PSCmdlet.ShouldProcess('Default', $CmdletName)) {
                        [System.Collections.ArrayList]::new() | Write-Output
                    }
                }

                break
            }

            default {
                if ($PSCmdlet.ShouldProcess('Elements', $CmdletName)) {
                    $arrayList = [System.Collections.ArrayList]::new() | Out-Null
                    $Element | ForEach-Object -Process { $arrayList.Add($_) }
                    $arrayList | Write-Output
                }

                break
            }
        }
    }

    END {
        $arrayList.Clear() | Out-Null
    }

    <#
        .SYNOPSIS
        Outputs a [System.Collections.ArrayList] object.

        .DESCRIPTION
        `Out-ArrayList` outputs a [System.Collections.ArrayList] object.

        .PARAMETER Collection
        Specifies a [System.Collections.ICollection] object to wrap into a [System.Collections.ArrayList] object.

        .PARAMETER Capacity
        Specifies the initial capacity for an empty [System.Collections.ArrayList] object.  If `Capacity` is zero, the default capacity will be used.

        .PARAMETER Element
        Specifies one or more [System.Object] elemnts to add to the [System.Collections.ArrayList] object.

        .INPUTS
        [System.Object]  `Out-ArrayList` accepts [System.Object] input.

        .OUTPUTS
        [System.Collections.ArrayList]  `Out-ArrayList` returns a [System.Collections.ArrayList] object.

        .EXAMPLE
        PS> Out-ArrayList -Element 'Element1', 'Element2'

        Value
        -----
        Element1
        Element2


        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Initialize-PSCmdlet

        .LINK
        Out-Null

        .LINK
        Write-Output
    #>
}

<#
    Out-Hashtable
#>
function Out-Hashtable {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'UsingDictinoary')]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingKeyValue', ValueFromPipelineByPropertyName)]
        [string[]]
        $Key,

        [Parameter(Mandatory, ParameterSetName = 'UsingKeyValue', ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [System.Object[]]
        $Value,

        [Parameter(Mandatory, ParameterSetName = 'UsingDictionaryEntry', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Collections.DictionaryEntry[]]
        $DictionaryEntry,

        [Parameter(Mandatory, ParameterSetName = 'UsingKeyValuePair', ValueFromPipelineByPropertyName)]
        [System.Collections.Generic.KeyValuePair[[string], [System.Object]][]]
        $KeyValuePair,

        [Parameter(Mandatory, ParameterSetName = 'UsingDictionary', ValueFromPipelineByPropertyName)]
        [System.Collections.IDictionary]
        $Dictionary,

        [Parameter(Mandatory, ParameterSetName = 'UsingCapacity')]
        [ValidateRange(0, 2147483647)]
        [int]
        $Capacity,

        [Parameter(ParameterSetName = 'UsingCapacity')]
        [ValidateScript({ ($_ -gt 0.0) -and ($_ -lt 1.0) })]
        [float]
        $LoadFactor
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        $CaseInsensitiveComparer = [System.Collections.IEqualityComparer.CaseInsensitiveComparer]::new([System.Globalization.CultureInfo]::InvariantCulture)

        if (($Capacity -gt 0) -and (Test-PSParameter -Name 'LoadFactor' -Parameters $PSBoundParameters)) {
            $resultHash = [System.Collections.Hashtable]::new($Capacity, $LoadFactor, $CaseInsensitiveComparer)
        } elseif ($Capacity -gt 0) {
            $resultHash = [System.Collections.Hashtable]::new($Capacity, $CaseInsensitiveComparer)
        } else {
            $resultHash = [System.Collections.Hashtable]::new($CaseInsensitiveComparer)
        }
    }

    PROCESS {
        switch ($PSCmdlet.ParameterSetName) {
            'UsingCapacity' {
                if ($PSCmdlet.ShouldProcess('Capacity', $CmdletName)) {
                    $resultHash.Clear() | Out-Null
                    Write-Verbose -Message "$($CmdletName) : Outputting empty Hashtable"
                    $resultHash | Write-Output
                }

                break
            }

            'UsingDictionaryEntry' {
                if ($PSCmdlet.ShouldProcess('Dictionary Entries', $CmdletName)) {
                    $resultHash.Clear() | Out-Null

                    $DictionaryEntry | ForEach-Object -Process {
                        if ($resultHash.ContainsKey($_.Key)) {
                            Write-Warning -Message "$($CmdletName) : Key '$($_.Key)' is non-unique.  Overwriting"
                            $resultHash[$_.Key] = $_.Value
                        } else {
                            $resultHash.Add($_.Key, $_.Value) | Out-Null
                        }
                    }

                    $resultHash | Write-Output
                }

                break
            }

            'UsingKeyValue' {
                if ($PSCmdlet.ShouldProcess('Key and Value Arrays', $CmdletName)) {
                    if ($Key.Length -ne $Value.Length) {
                        $newErrorRecordSplat = @{
                            Exception = [System.ArgumentException]::new("Key and Value arrays must be the same length")
                            ErrorCategory = 'InvalidArgument'
                            ErrorId = Format-ErrorId -Caller $CmdletName -Name 'ArgumentException' -Position $MyInvocation.ScriptLineNumber
                            TargetObject = @{ KeyLength = $Key.Length; ValueLength = $Value.Length }
                            TargetName = 'Key or Value'
                        }

                        New-ErrorRecord @newErrorRecordSplat | Write-Fatal
                    }

                    if ($PSCmdlet.ShouldProcess('Key Value Pair(s)', $CmdletName)) {
                        $resultHash.Clear() | Out-Null

                        for ($i = 0; $i -lt $Key.Length; $i++) {
                            if ($resultHash.ContainsKey($Key[$i])) {
                                Write-Warning -Message "$($CmdletName) : Key '$($Key[$i])' is non-unique.  Overwriting"
                                $resultHash[$Key[$i]] = $Value[$i]
                            }
                            else {
                                $resultHash.Add($Key[$i], $Value[$i]) | Out-Null
                            }
                        }

                        $resultHash | Write-Output
                    }
                }

                break
            }

            'UsingKeyValuePair' {
                if ($PSCmdlet.ShouldProcess('Key Value Pair(s)', $CmdletName)) {
                    $resultHash.Clear() | Out-Null

                    $KeyValuePair | ForEach-Object -Process {
                        if ($resultHash.ContainsKey($_.Key)) {
                            Write-Warning -Message "$($CmdletName) : Key '$($_.Key)' is non-unique.  Overwriting"
                            $resultHash[$_.Key] = $_.Value
                        } else {
                            $resultHash.Add($_.Key, $_.Value) | Out-Null
                        }
                    }

                    $resultHash | Write-Output
                }

                break
            }

            default {
                if ($PSCmdlet.ShouldProcess('Dictionary Interface', $CmdletName)) {
                    $resultHash.Clear() | Out-Null

                    $Dictionary | ForEach-Object -Process {
                        if ($resultHash.ContainsKey($_.Key)) {
                            Write-Warning -Message "$($CmdletName) : Key '$($_.Key)' is non-unique.  Overwriting"
                            $resultHash[$_.Key] = $_.Value
                        } else {
                            $resultHash.Add($_.Key, $_.Value) | Out-Null
                        }
                    }

                    $resultHash | Write-Output
                }

                break
            }
        }
    }

    END {
        $resultHash.Clear() | Out-Null
    }

    <#
        .SYNOPSIS
        Converts input data into a [hashtable].

        .DESCRIPTION
        `Out-Hashtable` converts input data into a [hashtable].

        .PARAMETER Key
        Specifies an array of one or more string key names.  Used together with the object array `Value`.

        .PARAMETER Value
        Specifies an array of one or more object values.  Used together with the string array `Key`.

        .PARAMETER DictionaryEntry
        Specifies an array of one or more [System.Collections.DictionaryEntry] objects.

        .PARAMETER KeyValuePair
        Specifies an array of one or more [System.Collections.Generic.KeyValuePair] objects.

        .PARAMETER Dictionary
        Specifies a [System.Collections.IDictionary] object.

        .PARAMETER Capacity
        Specifies the initial capacity for an empty [hashtable].

        .PARAMETER LoadFactor
        Specifies the load factor for the empty [hashtable].

        .INPUTS
        * ParameterSetName      Key      Value                                                          Notes
          ----------------      ---      -----                                                          -----
          UsingKeyValue         string[] object[]                                                       Value Key and Value arrays must be the same length
          UsingDictionaryEntry  [System.Collections.DictionaryEntry[]]                                  Array of [System.Collections.DictionaryEntry]
          UsingKeyValuePair     [System.Collections.Generic.KeyValuePair[[string], [System.Object]][]]  Array of [System.Collections.Generic.KeyValuePair]
          UsingDictionary       [System.Collections.IDictionary]                                        [System.Collections.IDictionary] object

        .OUTPUTS
        [hastable]  `Out-Hashtable` returns a [hashtable] object.

        .EXAMPLE
        PS> Out-Hashtable -Key 'Key1', 'Key2' -Value 'Value1', 'Value2'

        Key   Value
        ---   -----
        Key1  Value1
        Key2  Value2

        Creates a hashtable with two key-value pairs.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Format-ErrorId

        .LINK
        New-ErrorRecord

        .LINK
        Out-Null

        .LINK
        Write-Fatal

        .LINK
        Write-Output

        .LINK
        Write-Verbose

        .LINK
        Write-Warning
    #>
}

<#
    Remove-EnvironmentVariable
#>
function Remove-EnvironmentVariable {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $path = Join-Path -Path Env: -ChildPath $Name
    Remove-Item -LiteralPath $path

    <#
        .SYNOPSIS
        Removes a process environment variable.

        .DESCRIPTION
        `Remove-EnvironmentVariable` removes a process environment variable `Name`.

        .PARAMETER Name
        Specifies the name of the environment variable to remove.

        .INPUTS
        None.  `Remove-EnvironmentVariable` does not accept pipeline input.

        .OUTPUTS
        None.  `Remove-EnvironmentVariable` does not return any PowerShell pipeline output.

        .EXAMPLE
        PS> Test-EnvironmentVariable -Name 'NewPath'

        True

        PS> Remove-EnvironmentVariable -Name 'NewPath'
        PS> Test-EnvironmentVariable -Name 'NewPath'

        False

        Removes the 'NewPath' process environment variable.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Initialize-PSCmdlet

        .LINK
        Join-Path

        .LINK
        Remove-Item
    #>
}

<#
    Rename-EnvironmentVariable
#>
function Rename-EnvironmentVariable {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-EnvironmentVariable -Name $_ })]
        [string]
        $Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $NewName,

        [switch]
        $Force
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $path = Join-Path -Path Env: -ChildPath $Name
    Rename-Item -LiteralPath $path -NewName $NewName -Force:$Force.IsPresent

    <#
        .SYNOPSIS
        Renames an existing process environment variable.

        .DESCRIPTION
        `Rename-EnvironmentVariable` renames an existing process environment variable `Name` to `NewName`.

        .PARAMETER Name
        .PARAMETER NewName
        .INPUTS
        .OUTPUTS
        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
        .EXAMPLE
        .LINK
        about_CommonParameters
        .LINK
        about_Functions_Advanced
    #>
}

<#
    Set-EnvironmentVariable
#>
function Set-EnvironmentVariable {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Value,

        [switch]
        $PassThru
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        $path = Join-Path -Path Env: -ChildPath $Name
    }

    PROCESS {
        $Value | Set-Item -LiteralPath $path -PassThru:$PassThru.IsPresent | Write-Output
    }

    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER Name
        .PARAMETER Value
        .INPUTS
        .OUTPUTS
        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
        .EXAMPLE
        .LINK
        about_CommonParameters
        .LINK
        about_Functions_Advanced
    #>
}

<#
    Test-EnvironmentVariable
#>
function Test-EnvironmentVariable {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [AllowEmptyString()]
        [string[]]
        $Name,

        [ValidateSet('Bash', 'CMD', 'PowerShell')]
        [string]
        $ReservedWordSet = 'PowerShell'
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Set-Variable -Name RESERVED_WORD_BASH -Option Constant -Value @(
            'if', 'elif', 'else', 'then',
            'while', 'do',
            'done',
            'for',
            'until',
            'case', 'esac',
            'continue',
            'break',
            'function'
        )

        Set-Variable -Name RESERVED_WORD_CMD -Option Constant -Value @(
            'assoc',
            'call', 'exit', 'pause', 'prompt', 'shift', 'start',
            'cls', 'color', 'type',
            'cd', 'copy', 'dir', 'del', 'dir', 'erase', 'md', 'mklink', 'move', 'popd', 'pushd', 'ren', 'rd',
            'date', 'time',
            'echo',
            'endlocal', 'path', 'set', 'setlocal',
            'ftype',
            'for', 'if', 'else', 'goto', 'then',
            'rem',
            'title',
            'ver',
            'verify',
            'vol'
        )

        Set-Variable -Name RESERVED_WORD_PS -Option Constant -Value @(
            'assembly', 'exit', 'process',
            'base', 'filter', 'public',
            'begin', 'finally', 'return',
            'break', 'for', 'sequence',
            'catch', 'foreach', 'static',
            'class', 'from', 'switch',
            'command', 'function', 'throw',
            'configuration', 'hidden', 'trap',
            'continue', 'if', 'try',
            'data', 'in', 'type',
            'define', 'inlinescript', 'until',
            'do', 'interface', 'using',
            'dynamicparam', 'module', 'var',
            'else', 'namespace', 'while',
            'elseif', 'parallel', 'workflow',
            'end', 'param',
            'enum', 'private'
        )
    }

    PROCESS {
        if ([string]::IsNullOrWhiteSpace($Name)) {
            $false | Write-Output
        }
        elseif ($Name -notmatch '^[a-zA-Z_][a-zA-Z0-9_]{0,254}$') {
            $false | Write-Output
        }
        elseif (($ReservedWordSet -eq 'Bash') -and ($Name -in $RESERVED_WORD_BASH)) {
            $false | Write-Output
        }
        elseif (($ReservedWordSet -eq 'CMD') -and ($Name -in $RESERVED_WORD_CMD)) {
            $false | Write-Output
        }
        elseif (($ReservedWordSet -eq 'PowerShell') -and ($Name -in $RESERVED_WORD_PS)) {
            $false | Write-Output
        }
        else {
            $path = Join-Path -Path Env: -ChildPath $Name
            Test-Path -LiteralPath $path | Write-Output
        }
    }

    <#
        .SYNOPSIS
        Tests process environment variable `Name`.

        .DESCRIPTION
        `Test-EnvironmentVariable` tests process environment variable `Name` for whether:

        1) it is null, empty, or all whitespace;
        2) it is a valid environment variable name; and
        3) it exists.

        .PARAMETER Name
        Specifies the name of the process environment variable.

        To validate:

        1) it must not be null, empty, or all whitespace;

        2) it must be a valid environment variable name, which is a string that:
            a) starts with a letter or underscore;
            b) contains only letters, digits, and underscores;
            c) is at most 255 characters long; and
            d) is not a reserved environment variable name in the selected reserved word set.

        .PARAMETER ReservedWordSet
        Specifies the reserved word set to test against.  The default is 'PowerShell'.  Process environment variables that match the reserved word set are considered invalid.

        .INPUTS
        [string[]]  `Test-EnvironmentVariable` takes an array of strings as the environment variable input.

        .OUTPUTS
        [bool]  `Test-EnvironmentVariable` returns $true if the process environment variable `Name` is valid and exists; otherwise, $false.

        .EXAMPLE
        PS> Test-EnvironmentVariable -Name 'Path'

        True

        Environment variable 'Path' is valid and exists with the PowerShell reserved word set.

        Note, it would fail with the CMD reserved set because 'Path' matches an internal command.

        .EXAMPLE
        PS> Test-EnvironmentVariable -Name '1Path'

        False

        Environment variable '1Path' is invalid because it starts with a digit.

        .EXAMPLE
        PS> Test-EnvironmentVariable -Name 'Path.'

        False

        Environment variable 'Path.' is invalid because it contains a period.

        PS> Test-EnvironmentVariable -Name 'NewPath'

        False

        Environment variable 'NewPath' is valid but does not exist.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Join-Path

        .LINK
        Test-Path

        .LINK
        Write-Output
    #>
}

<#
 =============================================================================
<copyright file="PowerShellModule.psm1" company="U.S. Office of Personnel
Management">
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
<date>Created:  2025-1-27</date>
<summary>
This file "PowerShellModule.psm1" is part of "PowerShellModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#
    Add-Entry
#>
function Add-Entry {
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [hashtable]
        $Map,

        [Parameter(Mandatory)]
        [string]
        $Key,

        [Parameter(Mandatory)]
        [AllowNull()]
        [System.Object]
        $Value
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if ($Map.ContainsKey($Key)) {
        $Map[$Key] = $Value
    }
    else {
        $Map.Add($Key, $Value) | Out-Null
    }

    <#
        .SYNOPSIS
        Add an entry to a [hashtable]

        .DESCRIPTION
        `Add-Entry` is a helper function that adds an entry to a [hashtable] object.

        .PARAMETER Key
        Specifies the key into the [hashtable] 'Map'.

        .PARAMETER Map
        Specifies the [hashtable] object to which the entry is added.

        .PARAMETER Value
        Specifies the value to be added to the [hashtable] 'Map'.

        .INPUTS
        None.  `Add-Entry` does not accept pipeline input.

        .OUTPUTS
        None.  `Add-Entry` does not return any objects to the PowerShell pipeline.

        .EXAMPLE
        PS> Add-PSEntry -Map $MyMap -Key 'MyKey' -Value 'MyValue'

        Added 'MyKey' = 'MyValue' to 'MyMap'.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Initialize-Cmdlet

        .LINK
        Out-Null
    #>
}

<#
    Add-Parameter
#>
function Add-Parameter {
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        [Alias('Parameter')]
        [string]
        $Name,

        [Parameter(Mandatory)]
        [Alias('Bound')]
        [hashtable]
        $Parameters,

        [AllowNull()]
        [System.Object]
        $Value = $null
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    Add-Entry -Map $Parameters -Key $Name -Value $Value

    <#
        .SYNOPSIS
        Add an parameter to 'PSBoundParameters'.

        .DESCRIPTION
        `Add-Parameter` is a helper function that adds a parameter to 'PSBoundParameters'.

        .PARAMETER Name
        Specifies the name of the parameter to be added.

        .PARAMETER Parameters
        Specifies the PSBoundParameters [hashtable].

        .PARAMETER Value
        Specifies the value of the parameter to be added.

        .INPUTS
        None.  `Add-Parameter` does not accept input from the pipeline.

        .OUTPUTS
        None.  `Add-Parameter` does not return any objects to the PowerShell pipeline.

        .EXAMPLE
        PS> Add-PSParameter -Parameters $PSBoundParameters -Name 'MyKey' -Value 'MyValue'

        Added 'MyKey' = 'MyValue' to 'PSBoundParameters'.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Add-Entry

        .LINK
        Initialize-Cmdlet
    #>
}

<#
    Enter-Block
#>
function Enter-Block {
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        [scriptblock]
        $ScriptBlock,

        [ValidateRange(1, 3600)]
        [int]
        $Seconds = 15,

        [ValidateRange(3, 255)]
        [int]
        $Retries = 5
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    do {
        try {
            Invoke-Command -ScriptBlock $ScriptBlock
            Write-Verbose -Message "$($CmdletName) : ScriptBlock successfully executed"
            break
        }
        catch {
            Write-Warning -Message "$(CmdletName) : ScriptBlock threw with '$($_.Exception.GetType().Name)' and '$($_.Exception.Message)'"
            $Retries--
            Start-Sleep -Seconds $seconds
            $seconds *= 2

            if ($Retries -le 0) {
                $newErrorRecordSplat = @{
                    Exception = $_.Exception
                    Message = 'Retried ScriptBlock without success'
                    Category = 'InvalidOperation'
                    TargetObject = $ScriptBlock
                    ErrorId = Format-ErrorId -Caller $CmdletName -Name $_.Exception.GetType().Name -Position $MyInvocation.ScriptLineNumber
                }

                New-ErrorRecord @newErrorRecordSplat | Write-Fatal
            }
        }
    } while ($Retries -gt 0)

    <#
        .SYNOPSIS
        Executes a script block with retries and a delay.

        .DESCRIPTION
        `Enter-Block` is a helper function that executes a script block with retries and a delay.

        .PARAMETER ScriptBlock
        Specifies the script block to be executed.

        .PARAMETER Retries
        Specifies the number of retries.

        .PARAMETER Seconds
        Specifies the number of seconds to delay between retries.

        .INPUTS
        None.  `Enter-Block` does not accept input from the pipeline.

        .OUTPUTS
        None.  `Enter-Block` does not return any objects to the PowerShell pipeline.

        .EXAMPLE
        PS> Enter-Block -ScriptBlock { Get-Process } -Seconds 5 -Retries 3

         NPM(K)    PM(M)      WS(M)     CPU(s)      Id  SI ProcessName
        ------    -----      -----     ------      --  -- -----------
         11       5.33      11.75       0.00   12684    0 AggregatorHost
         18      23.46      19.30       0.30   44692    2 ai
         20       8.64      21.70       0.00    4696    0 AppHelperCap
         29      21.79      37.02       0.42    3140    2 ApplicationFrameHost
        120      21.52      19.94       0.00    9756    0 AppVClient
         29      64.98      58.64      25.86   52932    2 AppVStreamingUX
         31      99.55     104.21      49.52   69132    2 ArcControl
         17      11.41      16.20       0.25    3496    2 ArcControlAssist
         23      13.64      24.71     129.66   16268    2 ArcControlAssist
         48     215.31     175.83      47.53   18168    2 ArcControlAssist
         29      42.71      80.57      19.69   19340    2 ArcControlAssist

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Initialize-Cmdlet

        .LINK
        Invoke-Command

        .LINK
        New-ErrorRecord

        .LINK
        Start-Sleep

        .LINK
        Write-Fatal

        .LINK
        Write-Verbose

        .LINK
        Write-Warning
    #>
}

<#
    Get-BuildVersion
#>
function Get-BuildVersion {
    [CmdletBinding()]
    [OutputType([int])]
    param ()

    $major = Get-MajorVersion

    if ($major -ge 7) {
        Set-StrictMode -Version Latest
    }
    elseif ($major -ge 3) {
        Set-StrictMode -Version 3.0
    }
    elseif ($major -ge 2) {
        Set-StrictMode -Version 2.0
    }
    else {
        Set-StrictMode -Version 1.0
    }

    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    if (Get-MajorVersion -ge 6) {
        ($PSVersionTable.PSVersion) | Select-Object -ExpandProperty Patch | Write-Output
    }
    else {
        ($PSVersionTable.PSVersion) | Select-Object -ExpandProperty Build | Write-Output
    }

    <#
        .SYNOPSIS
        Gets the PowerShell 'Build' or 'Patch' version.

        .DESCRIPTION
        `Get-BuildVersion` is a helper function that gets the PowerShell 'Build' or 'Patch' version.

        .INPUTS
        None.  `Get-BuildVersion` does not accept input from the pipeline.

        .OUTPUTS
        [int]  `Get-BuildVersion` returns an integer to the PowerShell pipeline representing the PowerShell `Build` or `Patch` version.

        .EXAMPLE
        PS> Get-PSBuildVersion

        6

        Gets the PowerShell build or patch number.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Get-MajorVersion

        .LINK
        Select-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable
    #>
}

<#
    Get-MajorVersion
#>
function Get-MajorVersion {
    [CmdletBinding()]
    [OutputType([int])]
    param ()

    $major = ($PSVersionTable.PSVersion) | Select-Object -ExpandProperty Major

    if ($major -ge 7) {
        Set-StrictMode -Version Latest
    }
    elseif ($major -ge 3) {
        Set-StrictMode -Version 3.0
    }
    elseif ($major -ge 2) {
        Set-StrictMode -Version 2.0
    }
    else {
        Set-StrictMode -Version 1.0
    }

    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    $major | Write-Output

    <#
        .SYNOPSIS
        Gets the PowerShell major version.

        .DESCRIPTION
        `Get-MajorVersion` is a helper function that gets the PowerShell major version.

        .INPUTS
        None.  `Get-MajorVersion` does not accept input from the pipeline.

        .OUTPUTS
        [int] `Get-MajorVersion` returns an integer to the PowerShell pipeline representing the PowerShell major version.

        .EXAMPLE
        PS> Get-PSMajorVersion

        7

        Gets the PowerShell major number.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output
    #>
}

<#
    Get-MinorVersion
#>
function Get-MinorVersion {
    [CmdletBinding()]
    [OutputType([int])]
    param ()

    $major = ($PSVersionTable.PSVersion) | Select-Object -ExpandProperty Minor

    if ($major -ge 7) {
        Set-StrictMode -Version Latest
    }
    elseif ($major -ge 3) {
        Set-StrictMode -Version 3.0
    }
    elseif ($major -ge 2) {
        Set-StrictMode -Version 2.0
    }
    else {
        Set-StrictMode -Version 1.0
    }

    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    ($PSVersionTable.PSVersion) | Select-Object -ExpandProperty Minor | Write-Output

    <#
        .SYNOPSIS
        Gets the PowerShell minor version.

        .DESCRIPTION
        `Get-MinorVersion` is a helper function that gets the PowerShell minor version.

        .INPUTS
        None.  `Get-MinorVersion` does not accept input from the pipeline.

        .OUTPUTS
        [int] `Get-MinorVersion` returns an integer to the PowerShell pipeline representing the PowerShell minor version.

        .EXAMPLE
        PS> Get-PSMinorVersion

        6

        Gets the PowerShell minor number.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output
    #>
}

<#
    Get-Parameter
#>
function Get-Parameter {
    [CmdletBinding()]
    [OutputType([object])]
    param (
        [Parameter(Mandatory)]
        [Alias('Parameter')]
        [string]
        $Name,

        [Parameter(Mandatory)]
        [Alias('Bound')]
        [hashtable]
        $Parameters
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if (Test-Parameter -Name $Name -Parameters $Parameters) {
        $Parameters[$Name] | Write-Output
    }

    <#
        .SYNOPSIS
        Gets a parameter from 'PSBoundParameters'.

        .DESCRIPTION
        `Get-Parameter` is a helper function that gets a parameter from 'PSBoundParameters'.

        .PARAMETER Name
        Specifies the name of the parameter to get.

        .PARAMETER Parameters
        Specifies the PSBoundParameters [hashtable].

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .INPUTS
        None.  `Get-Parameter` does not accept input from the pipeline.

        .OUTPUTS
        [System.Object]  `Get-Parameter` returns an object to the PowerShell pipeline representing the parameter value.

        .EXAMPLE
        PS> Get-PSParameter -Name 'MyKey' -Parameters $PSBoundParameters

        Tests

        Gets the bound parameter value for 'MyKey'.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Set-Variable
        .LINK
        Set-StrictMode
        .LINK
        Test-Parameter
    #>
}

<#
    Get-Version
#>
function Get-Version {
    [CmdletBinding()]
    [OutputType([version])]
    param ()

    if ((Get-MajorVersion) -ge 6) {
        [System.Version]::new((Get-MajorVersion), (Get-MinorVersion), (Get-BuildVersion), 0) | Write-Output
    }
    else {
        $PSVersionTable | Select-Object -ExpandProperty PSVersion | Write-Output
    }

    <#
        .SYNOPSIS
        Gets the PowerShell version.

        .DESCRIPTION
        `Get-Version` is a helper function that gets the PowerShell version.

        .INPUTS
        .OUTPUTS

        .EXAMPLE
        PS> Get-PSVersion

        7.4.5

        Gets the PowerShell version number.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
        .LINK
        about_Functions_Advanced
        .LINK
        about_Functions_Advanced_Methods
        .LINK
        about_Functions_Advanced_Parameters
        .LINK
        Out-Null
        .LINK
        Set-Variable
        .LINK
        Set-StrictMode
    #>
}

<#
    Initialize-Class
#>
function Initialize-Class {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('ClassName')]
        [string]
        $Name
    )

    $major = ($PSVersionTable.PSVersion) | Select-Object -ExpandProperty Major

    if ($major -ge 7) {
        Set-StrictMode -Version Latest
    }
    elseif ($major -ge 3) {
        Set-StrictMode -Version 3.0
    }
    elseif ($major -ge 2) {
        Set-StrictMode -Version 2.0
    }
    else {
        Set-StrictMode -Version 1.0
    }

    Set-Variable -Name ClassName -Option ReadOnly  -Value $Name -WhatIf:$false
    Write-Verbose -Message "$($ClassName) : PowerShell Edition '$($PSVersionTable.PSEdition)' v'$($PSVersionTable.PSVersion)' on '$($PSVersionTable.Platform)'"
    $ClassName | Write-Output

    <#
        .SYNOPSIS
        Initializes a PowerShell class.

        .DESCRIPTION
        `Initialize-Class` is a helper function that initializes a PowerShell class.

        .PARAMETER Name
        Specifies the name of the class.

        .INPUTS
        .OUTPUTS

        .EXAMPLE
        PS> Initiliaze-PSClass -Name 'List'

        List

        Initialized a class.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
        .LINK
        about_Functions_Advanced
        .LINK
        about_Functions_Advanced_Methods
        .LINK
        about_Functions_Advanced_Parameters
        .LINK
        Out-Null
        .LINK
        Set-Variable
        .LINK
        Set-StrictMode
    #>
}

<#
    Initialize-Cmdlet
#>
function Initialize-Cmdlet {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'UsingName')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingName')]
        [ValidateNotNullOrEmpty()]
        [Alias('CmdletName')]
        [string]
        $Name,

        [Parameter(Mandatory, ParameterSetName = 'UsingInvocation')]
        [Alias('MyInvocation')]
        [System.Management.Automation.InvocationInfo]
        $Invocation
    )

    $major = ($PSVersionTable.PSVersion) | Select-Object -ExpandProperty Major

    if ($major -ge 7) {
        Set-StrictMode -Version Latest
    }
    elseif ($major -ge 3) {
        Set-StrictMode -Version 3.0
    }
    elseif ($major -ge 2) {
        Set-StrictMode -Version 2.0
    }
    else {
        Set-StrictMode -Version 1.0
    }

    if ($PSCmdlet.ParameterSetName -eq 'UsingInvocation') {
        Set-Variable -Name CmdletName -Option ReadOnly  -Value $Invocation.MyCommand.Name -WhatIf:$false
    }
    else {
        Set-Variable -Name CmdletName -Option ReadOnly  -Value $Name -WhatIf:$false
    }

    Write-Verbose -Message "$($CmdletName) : PowerShell Edition '$($PSVersionTable.PSEdition)' v'$($PSVersionTable.PSVersion)' on '$($PSVersionTable.Platform)'"
    $CmdletName | Write-Output

    <#
        .SYNOPSIS
        Initializes a PowerShell cmdlet.

        .DESCRIPTION
        `Initialize-Cmdlet` is a helper function that initializes a PowerShell cmdlet.

        .PARAMETER Name
        Specifies the name of the cmdlet.

        .PARAMETER Invocation
        Specifies the invocation information for the cmdlet.

        .INPUTS
        .OUTPUTS

        .EXAMPLE
        PS> Initiliaze-PSCmdlet -Name 'Measure-My'

        Measure-My

        Initialized a cmdlet.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
        .LINK
        about_Functions_Advanced
        .LINK
        about_Functions_Advanced_Methods
        .LINK
        about_Functions_Advanced_Parameters
        .LINK
        Out-Null
        .LINK
        Set-Variable
        .LINK
        Set-StrictMode
    #>
}

<#
    Initialize-Function
#>
function Initialize-Function {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'UsingName')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingName')]
        [ValidateNotNullOrEmpty()]
        [Alias('FunctionName')]
        [string]
        $Name,

        [Parameter(Mandatory, ParameterSetName = 'UsingInvocation')]
        [Alias('MyInvocation')]
        [System.Management.Automation.InvocationInfo]
        $Invocation
    )

    $major = ($PSVersionTable.PSVersion) | Select-Object -ExpandProperty Major

    if ($major -ge 7) {
        Set-StrictMode -Version Latest
    }
    elseif ($major -ge 3) {
        Set-StrictMode -Version 3.0
    }
    elseif ($major -ge 2) {
        Set-StrictMode -Version 2.0
    }
    else {
        Set-StrictMode -Version 1.0
    }

    if ($PSCmdlet.ParameterSetName -eq 'UsingInvocation') {
        Set-Variable -Name FunctionName -Option ReadOnly  -Value $Invocation.MyCommand.Name -WhatIf:$false
    }
    else {
        Set-Variable -Name FunctionName -Option ReadOnly  -Value $Name -WhatIf:$false
    }

    Write-Verbose -Message "$($FunctionName) : PowerShell Edition '$($PSVersionTable.PSEdition)' v'$($PSVersionTable.PSVersion)' on '$($PSVersionTable.Platform)'"
    $FunctionName | Write-Output

    <#
        .SYNOPSIS
        Initializes a PowerShell function.

        .DESCRIPTION
        `Initialize-Function` is a helper function that initializes a PowerShell function.

        .PARAMETER Name
        Specifies the name of the function.

        .PARAMETER Invocation
        Specifies the invocation info for the function.

        .INPUTS
        .OUTPUTS

        .EXAMPLE
        PS> Initiliaze-PSFunction -Name 'Measure-My'

        Measure-My

        Initialized a function.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Functions_Advanced
        .LINK
        about_Functions_Advanced_Methods
        .LINK
        about_Functions_Advanced_Parameters
        .LINK
        Out-Null
        .LINK
        Set-Variable
        .LINK
        Set-StrictMode
    #>
}

<#
    Initialize-Method
#>
function Initialize-Method {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'UsingName')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingName')]
        [ValidateNotNullOrEmpty()]
        [Alias('MemberName')]
        [string]
        $Name,

        [Parameter(Mandatory, ParameterSetName = 'UsingInvocation')]
        [ValidateNotNullOrEmpty()]
        [Alias('MyInvocation')]
        [System.Management.Automation.InvocationInfo]
        $Invocation
    )

    $major = ($PSVersionTable.PSVersion) | Select-Object -ExpandProperty Major

    if ($major -ge 7) {
        Set-StrictMode -Version Latest
    }
    elseif ($major -ge 3) {
        Set-StrictMode -Version 3.0
    }
    elseif ($major -ge 2) {
        Set-StrictMode -Version 2.0
    }
    else {
        Set-StrictMode -Version 1.0
    }

    if ($PSCmdlet.ParameterSetName -eq 'UsingInvocation') {
        Set-Variable -Name MethodName -Option ReadOnly  -Value $Invocation.MyCommand.Name -WhatIf:$false
    }
    else {
        Set-Variable -Name MethodName -Option ReadOnly  -Value $Name -WhatIf:$false
    }

    Write-Verbose -Message "$($MethodName) : PowerShell Edition '$($PSVersionTable.PSEdition)' v'$($PSVersionTable.PSVersion)' on '$($PSVersionTable.Platform)'"
    $MethodName | Write-Output

    <#
        .SYNOPSIS
        Initializes a PowerShell method.

        .DESCRIPTION
        `Initialize-Method` is a helper function that initializes a PowerShell method.

        .PARAMETER Name
        Specifies the name of the method.

        .PARAMETER Invocation
        Specifies the invocation info for the method.

        .INPUTS
        .OUTPUTS

        .EXAMPLE
        PS> Initiliaze-PSMethod -Name 'MyCount'

        MyCount

        Initialized a method.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
        .LINK
        about_Functions_Advanced
        .LINK
        about_Functions_Advanced_Methods
        .LINK
        about_Functions_Advanced_Parameters
        .LINK
        Out-Null
        .LINK
        Set-Variable
        .LINK
        Set-StrictMode
    #>
}

<#
    Initialize-Script
#>
function Initialize-Script {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'UsingName')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingName')]
        [ValidateNotNullOrEmpty()]
        [Alias('ScriptName')]
        [string]
        $Name,

        [Parameter(Mandatory, ParameterSetName = 'UsingInvocation')]
        [Alias('MyInvocation')]
        [System.Management.Automation.InvocationInfo]
        $Invocation
    )

    $major = ($PSVersionTable.PSVersion) | Select-Object -ExpandProperty Major

    if ($major -ge 7) {
        Set-StrictMode -Version Latest
    }
    elseif ($major -ge 3) {
        Set-StrictMode -Version 3.0
    }
    elseif ($major -ge 2) {
        Set-StrictMode -Version 2.0
    }
    else {
        Set-StrictMode -Version 1.0
    }

    if ($PSCmdlet.ParameterSetName -eq 'UsingInvocation') {
        Set-Variable -Name ScriptName -Option ReadOnly  -Value $Invocation.MyCommand.Name -WhatIf:$false
    }
    else {
        Set-Variable -Name ScriptName -Option ReadOnly  -Value $Name -WhatIf:$false
    }

    Write-Verbose -Message "$($ScriptName) : PowerShell Edition '$($PSVersionTable.PSEdition)' v'$($PSVersionTable.PSVersion)' on '$($PSVersionTable.Platform)'"
    $ScriptName | Write-Output

    <#
        .SYNOPSIS
        Initializes a PowerShell script.

        .DESCRIPTION
        `Initialize-Script` is a helper function that initializes a PowerShell script.

        .PARAMETER Name
        Specifies the name of the script.

        .PARAMETER Invocation
        Specifies the invocation info for the script.

        .INPUTS
        .OUTPUTS

        .EXAMPLE
        PS> Initiliaze-PSScript -Name 'MyScript.ps1'

        MyScript.ps1

        Initialized a script.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
        .LINK
        about_Functions_Advanced
        .LINK
        about_Functions_Advanced_Methods
        .LINK
        about_Functions_Advanced_Parameters
        .LINK
        Out-Null
        .LINK
        Set-Variable
        .LINK
        Set-StrictMode
    #>
}

<#
    Initialize-Test
#>
function Initialize-Test {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('UnitUnderTestName')]
        [string]
        $Name,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $Path
    )

    $major = ($PSVersionTable.PSVersion) | Select-Object -ExpandProperty Major

    if ($major -ge 7) {
        Set-StrictMode -Version Latest
    }
    elseif ($major -ge 3) {
        Set-StrictMode -Version 3.0
    }
    elseif ($major -ge 2) {
        Set-StrictMode -Version 2.0
    }
    else {
        Set-StrictMode -Version 1.0
    }

    Update-Variable -Name UnitUnderTestName -Option ReadOnly -Value $Name -Force
    Write-Verbose -Message "$($Name) : PowerShell Edition '$($PSVersionTable.PSEdition)' v'$($PSVersionTable.PSVersion)' on '$($PSVersionTable.Platform)'"

    # Script Constants
    Update-Variable -Name MINIMUM_DESCRIPTION_LENGTH -Option Constant -Scope Global  -Value 30
    Update-Variable -Name MINIMUM_SYNOPSIS_LENGTH -Option Constant -Scope Global -Value 25
    Update-Variable -Name COMPANY_NAME_STRING -Option Constant -Scope Global  -Value 'John Merryweather Cooper'
    Update-Variable -Name COPYRIGHT_STRING -Option Constant -Scope Global -Value 'Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.'

    $fileInfo = Get-Item -LiteralPath $Path
    $ScriptExtension = $fileInfo | Select-Object -ExpandProperty Extension
    $ScriptName = $fileInfo | Select-Object -ExpandProperty Name
    $ScriptBaseName = ($fileInfo | Select-Object -ExpandProperty BaseName) -replace '.tests'
    $DotSourceFile = $ScriptBaseName + '.ps1'
    $SourceToTestPath = Join-Path -Path (Get-Location) -ChildPath $DotSourceFile
    $ModuleName = $ScriptBaseName + '.psm1'
    $ModulePath = Join-Path -Path (Get-Location) -ChildPath $ModuleName
    $ManifestName = $ScriptBaseName + '.psd1'
    $ManifestPath = Join-Path -Path (Get-Location) -ChildPath $ManifestName

    Update-Variable -Name ScriptExtension -Option ReadOnly -Value $ScriptExtension -Force
    Update-Variable -Name ScriptName -Option ReadOnly -Value $ScriptName -Force
    Update-Variable -Name ScriptBaseName -Option ReadOnly -Value $ScriptBaseName -Force

    # Dot Sourced ReadOnly Variables
    Update-Variable -Name DotSourceFile -Option ReadOnly -Value $DotSourceFile -Force
    Update-Variable -Name SourceToTestPath -Option ReadOnly -Value $SourceToTestPath -Force

    # Module ReadOnly Variables
    Update-Variable -Name ModuleName -Option ReadOnly -Value $ModuleName -Force
    Update-Variable -Name ModulePath -Option ReadOnly -Value $ModulePath -Force
    Update-Variable -Name ManifestName -Option ReadOnly -Value $ManifestName -Force
    Update-Variable -Name ManifestPath -Option ReadOnly -Scope Global -Value $ManifestPath -Force

    $Name | Write-Output

    <#
        .SYNOPSIS
        Initializes a PowerShell Pester test suite.

        .DESCRIPTION
        `Initialize-Test` is a helper function that initializes a PowerShell Pester test suite.

        .PARAMETER Name
        Specifies the name of the test suite.

        .PARAMETER Path
        Specifies the path to the test suite.

        .INPUTS
        .OUTPUTS

        .EXAMPLE
        PS> Initiliaze-PSTest -Name 'Test-MyFunction' -Path 'C:\Scripts\Test-MyFunction.tests.ps1'

        Test-MyFunction

        Initialized test suite.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
        .LINK
        about_Functions_Advanced
        .LINK
        about_Functions_Advanced_Methods
        .LINK
        about_Functions_Advanced_Parameters
        .LINK
        Out-Null
        .LINK
        Set-Variable
        .LINK
        Set-StrictMode
    #>
}

<#
    Measure-String
#>
function Measure-String {
    [CmdletBinding(DefaultParameterSetName = 'UsingString')]
    [OutputType([iht])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingString')]
        [AllowNull()]
        [AllowEmptyString()]
        [string[]]
        $Value,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingObject')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [psobject]
        $InputObject
    )

    BEGIN {
        $Cmdlet = Initialize-PSCmdlet -MyInvocation $MyInvocation

        $length = 0
    }

    PROCESS {
        $length = 0

        if ($PSCmdlet.ParameterSetName -eq 'UsingObject') {
            if (($null -eq $InputObject)) {
                $length | Write-Output
            }
            else {
                $InputObject | Measure-Object -Character | Select-Object -ExpandProperty Characters | Write-Output
            }
        }
        else {
            if (($null -eq $Value) -or ($Value.Count -lt 1)) {
                $length | Write-Output
            }
            else {
                $Value | ForEach-Object -Process {
                    $length += $_.Length
                }

                $length | Write-Output
            }
        }
    }

    <#
        .SYNOPSIS
        Measures the length of a string.

        .DESCRIPTION
        `Measure-String` is a helper function that measures the length of a string.

        .PARAMETER IgnoreWhiteSpace
        Specify to ignore whitespace in the string.

        .PARAMETER TotalCharacter
        Specify to measure the total number of characters in the string.

        .PARAMETER TotalLine
        Specify to measure the total number of lines in the string.

        .PARAMETER TotalWord
        Specify to measure the total number of words in the string.

        .PARAMETER Value
        Specifies the string to be measured.

        .INPUTS
        .OUTPUTS

        .EXAMPLE
        PS> "0123456789" | Measure-String

        10

        String is 10 characters long.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
        .LINK
        about_Functions_Advanced
        .LINK
        about_Functions_Advanced_Methods
        .LINK
        about_Functions_Advanced_Parameters
        .LINK
        Out-Null
        .LINK
        Set-Variable
        .LINK
        Set-StrictMode
    #>
}

<#
    Set-TeeContent
#>
function Set-TeeContent {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([void])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingPath')]
        [ValdiateScript(Get-ChildItem -Path $_ | Test-Path -PathType Leaf)]
        [string[]]
        $Path,

        [Parameter(Mandatory, ParameterSetName = 'UsingLiteralPath')]
        [ValdiateScript(Test-Path -LiteralPath $_ -PathType Leaf)]
        [string[]]
        $LiteralPath,

        [Parameter(Mandatory, ParameterSetName = 'UsingVariable')]
        [ValidateNotNullOrEmpty]
        [string]
        $Variable,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [object[]]
        $Value,

        [System.Text.Encoding]
        $Encoding = 'UTF8',

        [switch]
        $Force
    )

    BEGIN {
        $Cmdlet = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $Value | Set-Content -LiteralPath $Path -Encoding $Encoding -Force:$Force.IsPresent
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'UsingVariable') {
            $Value | ForEach-Object -Process { Tee-Object -InputObject $_ -Variable $Variable -Encoding $Encoding -Append | Out-Null }
        }
        else {
            $Value | Set-Content -Path $Path
        }
    }
}

<#
    Set-Parameter
#>
function Set-Parameter {
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        [Alias('Parameter')]
        [string]
        $Name,

        [Parameter(Mandatory)]
        [Alias('Bound')]
        [hashtable]
        $Parameters,

        [Parameter(Mandatory)]
        [AllowNull()]
        [object]
        $Value
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if (Test-Parameter -Name $Name -Parameters $Parameters) {
        $Parameters[$Name] = $Value
    }
    else {
        Add-Parameter -Name $Name -Parameters $Parameters -Value $Value
    }

    <#
        .SYNOPSIS
        Gets a parameter from 'PSBoundParameters'.

        .DESCRIPTION
        `Get-Parameter` is a helper function that gets a parameter from 'PSBoundParameters'.

        .PARAMETER Name
        Specifies the name of the parameter to get.

        .PARAMETER Parameters
        Specifies the PSBoundParameters [hashtable].

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .INPUTS
        None.  `Get-Parameter` does not accept input from the pipeline.

        .OUTPUTS
        [System.Object]  `Get-Parameter` returns an object to the PowerShell pipeline representing the parameter value.

        .EXAMPLE
        PS> Get-PSParameter -Name 'MyKey' -Parameters $PSBoundParameters

        Tests

        Gets the bound parameter value for 'MyKey'.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Set-Variable
        .LINK
        Set-StrictMode
        .LINK
        Test-Parameter
    #>
}

<#
    Test-Prerequisites
#>
function Test-Prerequisites {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias('Prerequisite')]
        [string[]]
        $Name
    )

    BEGIN {
        $Cmdlet = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $Name | ForEach-Object -Process {
            if (Get-Module -ListAvailable | Where-Object -Property Name -EQ $_ ) {
                $true | Write-Output
            }
            else {
                Write-Warning -Message "$($CmdletName) : Module '$_' is not available"
                $false | Write-Output
            }
        }
    }

    <#
        .SYNOPSIS
        Test a list of prerequisite modules for availability.

        .DESCRIPTION
        `Test-Prerequisites` is a helper function that tests a list of prerequisite modules for availability.  By test for availability, it is meant that the module is installed and available for use.

        .PARAMETER Name
        Specifies an array of module names to test for availability.

        .INPUTS
        [string[]]  `Test-Prerequisites` accepts an array of strings from the pipeline.

        .OUTPUTS
        [bool]  `Test-Prerequisites` returns a boolean value to the pipeline.  `True` if the module is available; otherwise `False` if the module is not available.

        .NOTES
        Copyright © 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

       .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Get-Module

        .LINK
        Initialize-Cmdlet

        .LINK
        Where-Object

        .LINK
        Write-Output

        .LINK
        Write-Warning
    #>
}

<#
    Update-Variable
#>
function Update-Variable {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string[]]
        $Name,

        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [System.Object]
        $Value,

        [ValidateNotNullOrEmpty()]
        [string]
        $Description,

        [ValidateSet('None', 'ReadOnly', 'Constant', 'AllScope')]
        [System.Management.Automation.ScopedItemOptions]
        $Option = 'None',

        [ValidateSet('Global', 'Local', 'Script', 'Private')]
        [string]
        $Scope = 'Local',

        [switch]
        $Force
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $Name | ForEach-Object -Process {
            $variableName = $_

            if (-not (Test-PSParameter -Name 'Description' -Parameters $PSBoundParameters)) {
                $Description = "Variable '$($variableName)' created by '$($CmdletName)' with Option '$($Option)'"
            }

            switch ($Option) {
                'ReadOnly' {
                    if (-not (Test-Path -LiteralPath variable:$variableName)) {
                        if ($PSCmdlet.ShouldProcess("Creating ReadOnly Variable '$($variableName)' in '$($Scope)' with Description", $CmdletName)) {
                            Set-Variable -Name $variableName -Value $Value -Option $_ -Scope $Scope -Description $Description
                        }
                    }
                    elseif ($Force.IsPresent) {
                        if ($PSCmdlet.ShouldProcess("Forcefully setting ReadOnly Variable '$($variableName)' in '$($Scope)'", $CmdletName)) {
                            Set-Variable -Name $variableName -Value $Value -Option $_ -Scope $Scope -Force
                        }
                    }
                    else {
                        Write-Warning -Message "$($CmdletName):  ReadOnly Variable '$($variableName)' already exists and cannot be updated"
                    }

                    break
                }

                'Constant' {
                    if (-not (Test-Path -LiteralPath variable:$variableName)) {
                        if ($PSCmdlet.ShouldProcess("Creating Constant Variable '$($variableName)' in '$($Scope)' with Description", $CmdletName)) {
                            Set-Variable -Name $variableName -Value $Value -Option $_ -Scope $Scope -Description $Description
                        }
                    }
                    else {
                        Write-Warning -Message "$($CmdletName):  Constant Variable '$($variableName)' already exists and cannot be updated"
                    }

                    break
                }

                'AllScope' {
                    if (Test-Path -LiteralPath variable:$variableName) {
                        if ($PSCmdlet.ShouldProcess("Updating AllScope Variable '$($variableName)' in '$($Scope)' with Description", $CmdletName)) {
                            Set-Variable -Name $variableName -Value $Value -Option $_ -Scope $Scope -Description $Description
                        }
                    }
                    else {
                        if ($PSCmdlet.ShouldProcess("Creating AllScope Variable '$($variableName)' in '$($Scope)' with Default Description", $CmdletName)) {
                            Set-Variable -Name $variableName -Value $Value -Option $_ -Scope $Scope -Description $Description
                        }
                    }

                    break
                }

                default {
                    if (Test-Path -LiteralPath variable:$variableName) {
                        if ($PSCmdlet.ShouldProcess("Updating Variable '$($variableName)' in '$($Scope)' with Description", $CmdletName)) {
                            Set-Variable -Name $variableName -Value $Value -Option $_ -Scope $Scope -Description $Description
                        }
                    }
                    else {
                        if ($PSCmdlet.ShouldProcess("Creating Variable '$($variableName)' in '$($_)' with Default Description", $CmdletName)) {
                            Set-Variable -Name $variableName -Value $Value -Option $_ -Scope $Scope -Description $Description
                        }
                    }

                    break
                }
            }
        }
    }

    <#
        .SYNOPSIS
        Updates a PowerShell variable.

        .DESCRIPTION
        `Update-Variable` is a helper function that updates a PowerShell variable.

        .PARAMETER Name
        Specifies the name of the variable to add or update.

        .PARAMETER Value
        Specifies the value of the variable to add or update.

        .PARAMETER Description
        Specifies an optional description for the variable.

        .PARAMETER Option
        Specifies the option for the variable.

        .PARAMETER Scope
        Specifies the scope for the variable.

        .PARAMETER Force
        Specified to force the update of a read-only variable.  Will not override constants, however.

        .INPUTS
        .OUTPUTS

        .EXAMPLE
        PS> Update-PSVariable -Name Test -Value 7 -Option ReadOnly -Force

        Updates variable 'Test' with the value '7' and overrides the option 'ReadOnly' with the 'Force' switch.

        Reports that the current version of PowerShell is greater than 7.x
        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
        .LINK
        about_Functions_Advanced
        .LINK
        about_Functions_Advanced_Methods
        .LINK
        about_Functions_Advanced_Parameters
        .LINK
        Out-Null
        .LINK
        Set-Variable
        .LINK
        Set-StrictMode
    #>
}

<#
    Test-Parameter
#>
function Test-Parameter {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [Alias('Parameter')]
        [string]
        $Name,

        [Parameter(Mandatory)]
        [Alias('Bound')]
        [hashtable]
        $Parameters
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $Parameters.ContainsKey($Name) | Write-Output

    <#
        .SYNOPSIS
        Tests for the existance of a parameter in 'PSBoundParameters'.

        .DESCRIPTION
        `Test-Parameter` is a helper function that tests for the existance of a parameter in 'PSBoundParameters'.

        .PARAMETER Name
        Specifies the name of the parameter.

        .PARAMETER Parameters
        Specifies the PSBoundParameters [hashtable].

        .INPUTS
        .OUTPUTS

        .EXAMPLE
        PS> Test-PSParameter -Name Farce -Parameters $PSBoundParameters

        False

        Reports 'Farce' is not present in $PSBoundParameters

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
        .LINK
        about_Functions_Advanced
        .LINK
        about_Functions_Advanced_Methods
        .LINK
        about_Functions_Advanced_Parameters
        .LINK
        Set-Variable
        .LINK
        Set-StrictMode
    #>
}

<#
    Test-Version
#>
function Test-Version {
    [CmdletBinding(DefaultParameterSetName = 'UsingBuild')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [ValidateRange(0, 65534)]
        [int]
        $Major,

        [ValidateRange(0, 65534)]
        [int]
        $Minor = 0,

        [Parameter(Mandatory, ParameterSetName = 'UsingBuild')]
        [ValidateRange(0, 65534)]
        [int]
        $Build = 0,

        [Parameter(Mandatory, ParameterSetName = 'UsingPatch')]
        [ValidateRange(0, 2147483647)]
        [int]
        $Patch = 0,

        [Parameter(Mandatory, ParameterSetName = 'UsingVersionString')]
        [string]
        $VersionString,

        [switch]
        $Equal,

        [switch]
        $GreaterThan,

        [switch]
        $LessThan,

        [switch]
        $LessThanOrEqual,

        [switch]
        $NotEqual
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if ($PSCmdlet.ParameterSetName -eq 'UsingVersionString') {
        if ((Get-MajorVersion) -ge 6) {
            $test = [System.Management.Automation.SemanticVersion]::new($VersionString)
        }
        else {
            $test = [System.Version]::new($VersionString)
        }
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'UsingPatch') {
        if ((Get-MajorVersion) -ge 6) {
            $test = [System.Management.Automation.SemanticVersion]::new($Major, $Minor, $Patch)
        }
        else {
            $test = [System.Version]::new($Major, $Minor, $Build, 0)
        }
    }
    else {
        if ((Get-MajorVersion) -ge 6) {
            $test = [System.Management.Automation.SemanticVersion]::new($Major, $Minor, $Build)
        }
        else {
            $test = [System.Version]::new($Major, $Minor, $Build, 0)
        }
    }

    # order matters because the left side determines the coerced type of the right side
    if ($Equal.IsPresent) {
        ($test -eq $PSVersionTable.PSVersion) | Write-Output
    }
    elseif ($NotEqual.IsPresent) {
        ($test -ne $PSVersionTable.PSVersion) | Write-Output
    }
    elseif ($LessThan.IsPresent) {
        ($test -gt $PSVersionTable.PSVersion) | Write-Output
    }
    elseif ($LessThanOrEqual.IsPresent) {
        ($test -ge $PSVersionTable.PSVersion) | Write-Output
    }
    elseif ($GreaterThan.IsPresent) {
        ($test -lt $PSVersionTable.PSVersion) | Write-Output
    }
    else {
        # GreaterThanOrEqual is the default
        ($test -le $PSVersionTable.PSVersion) | Write-Output
    }

    <#
        .SYNOPSIS
        Tests a provided Version against the run-time environment of the script.

        .DESCRIPTION
        `Test-PSVersion` tests a provided Version against the run-time environment of the script.

        The comparison defaults to `GreaterThanOrEqual`.  Other comparisons can be done by selecting one of:
        - Equal:  The Version must exactly match the `$PSVersionTable.PSVersion` properties `Major`, `Minor`, and `Patch`.
        - GreaterThan : The Version must be greater than the `$PSVersionTable.PSVersion` properties `Major`, `Minor`, and `Patch`.
        - LessThan: The Version must be less than the `$PSVersionTable.PSVersion` properties `Major`, `Minor`, and `Patch`.
        - LessThanOrEqual: The Version must be less than or equal to the `$PSVersionTable.PSVersion` properties `Major`, `Minor`, and `Patch`.
        - NotEqual: The Version must not be equal to the `$PSVersionTable.PSVersion` properties `Major`, `Minor`, and `Patch`.

        Version can be supplied as:

        - VersionString:  A [string] in either [System.Version] or [System.Management.Automation.SemanticVersion].  NOTE:  `SemanticVersion` is only available in PowerShell 6 and later.  Also, for PowerShell 6 and later, ensure that no more than `Major`, `Minor`, or `Patch` are provided.  Do not provide a `Revision` number.
        - Major:  An [int] plus optionally `Minor` (defaults to zero) or `Patch` (defaults to zero).

        .PARAMETER Equal
        Specifies that the Version must exactly match the `$PSVersionTable.PSVersion` properties `Major`, `Minor`, and `Patch`.

        .PARAMETER GreaterThan
        Specifies that the Version must be greater than the `$PSVersionTable.PSVersion` properties `Major`, `Minor`, and `Patch`.

        .PARAMETER LessThan
        Specifies that the Version must be less than the `$PSVersionTable.PSVersion` properties `Major`, `Minor`, and `Patch`.

        .PARAMETER LessThanOrEqual
        Specifies that the Version must be less than or equal to the `$PSVersionTable.PSVersion` properties `Major`, `Minor`, and `Patch`.

        .PARAMETER Major
        Specifies the Major part of the Version.

        .PARAMETER Minor
        Specifies the Minor part of the Version.

        .PARAMETER NotEqual
        Specifies that the Version must not be equal to the `$PSVersionTable.PSVersion` properties `Major`, `Minor`, and `Patch`.

        .PARAMETER Patch
        Specifies the Build or Patch part of the Version.

        .PARAMETER VersionString
        Specifies the Version as a [string] in either [System.Version] or [System.Management.Automation.SemanticVersion].

        .INPUTS
        None.  `Test-PSVersion` does not take input from the PowerShell pipeline.

        .OUTPUTS
        [bool].  `Test-PSVersion` outputs the evaluation of the Version comparison as either `True` if satisfied; otherwise `False`.

        .EXAMPLE
        PS> Test-PSVersion -Major 7 -GreaterThan

        True

        Reports that the current version of PowerShell is greater than 7.x

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Functions_Advanced

        .LINK
        about_Functions_Advanced_Methods

        .LINK
        about_Functions_Advanced_Parameters

        .LINK
        Set-Variable

        .LINK
        Set-StrictMode
    #>
}

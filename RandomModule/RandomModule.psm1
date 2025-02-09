<#
 =============================================================================
<copyright file="RandomModule.psm1" company="U.S. Office of Personnel
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
This file "RandomModule.psm1" is part of "RandomModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#
    Script-scoped variables
#>
$ByteArray = @([byte]0) * ([Environment]::SystemPageSize / ([byte]0).GetByteCount())

$FloatArray = @([float]0.0) * ([Environment]::SystemPageSize / ([float]0.0).GetExponentByteCount() + ([float]0.0).GetSignificandByteCount())

$DoubleArray = @(0.0) * ([Environment]::SystemPageSize / (0.0).GetExponentByteCount() + (0.0).GetSignificandByteCount())

$IntegerArray = @(0) * ([Environment]::SystemPageSize / (0).GetByteCount())

$LongArray = @([long]0) * ([Environment]::SystemPageSize / ([long]0).GetByteCount())

$IsInitialized = $false

<#
    Get-RandomByte
#>
function Get-RandomByte {
    [CmdletBinding()]
    [OutputType([byte])]
    param (
        [ValidateRange(0, 255)]
        [byte]
        $Minimum = 0,

        [ValidateRange(0, 255)]
        [byte]
        $Maximum = 255
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    if ($Minimum -ge $Maximum) {
        $message = 'The minimum value must be less than the maximum value.'
        $exception = [System.ArgumentOutOfRangeException]::new('Minimum', $Minimum, $message)
        
        $writeErrorSplat = @{
            Exception    = $exception
            ErrorId      = "$($CmdletName)-MinimumGreaterThanMaximum-01"
            Category     = 'InvalidArgument'
            TargetObject = $Minimum
            ErrorAction  = 'Continue'
        }

        Write-Error @writeErrorSplat
        throw $exception
    }

    if (-not $Script:IsInitialized) {
        Write-Warning -Message "$($CmdletName) : Random number generator has not been initialized. Initializing now."
        Initialize-Random
    }

    $index = $Script:Random.Next(0, $Script:ByteArray.Length - 1)
    Write-Debug -Message "$($CmdletName) : Index = $index"

    try {
        Write-Verbose -Message "$($CmdletName) : Generating random signed byte."
        [byte](($Script:ByteArray[$index] % ($Maximum - $Minimum + 1)) + $Minimum) | Write-Output
    }
    finally {
        Write-Debug -Message "$($CmdletName) : Initializing byte array element $index."
        $Script:ByteArray[$index] = [byte]$Random.Next(0, [byte]::MaxValue)
    }

    <#
        .SYNOPSIS
        Generates a random byte.

        .DESCRIPTION
        Generates a random byte between the specified minimum and maximum values.  If no minimum and maximum values are specified, the range is from 0 to 255.

        .PARAMETER Minimum
        The minimum value of the random byte.

        .PARAMETER Maximum
        The maximum value of the random byte.

        .INPUTS
        None.  You cannot pipe objects to Get-RandomByte.

        .OUTPUTS
        [byte].  Get-RandomByte generates a random byte.

        .EXAMPLE
        PS> Get-RandomByte

        223

        Generates a random long integer between 0 and 255.

        .EXAMPLE
        PS> Get-RandomByte -Maximum 128

        122

        Generates a random long integer between 0 and 128.

        .EXAMPLE
        PS> Get-RandomByte -Minimum 128 -Maximum 192

        130

        Generates a random long integer between 128 and 192.


        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Initialize-Random

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Debug

        .LINK
        Write-Output

        .LINK
        Write-Verbose

        .LINK
        Write-Warning
    #>
}

<#
    Get-RandomDouble
#>
function Get-RandomDouble {
    [CmdletBinding()]
    [OutputType([double])]
    param ()

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    if (-not $Script:IsInitialized) {
        Write-Warning -Message "$($CmdletName) : Random number generator has not been initialized. Initializing now."
        Initialize-Random
    }

    $index = $Script:Random.Next(0, $Script:DoubleArray.Length - 1)
    Write-Debug -Message "$($CmdletName) : Index = $index"

    try {
        Write-Verbose -Message "$($CmdletName) : Generating random double-precision floating-point number."
        $Script:DoubleArray[$index] | Write-Output
    }
    finally {
        Write-Debug -Message "$($CmdletName) : Initializing double array element $index."
        $Script:DoubleArray[$index] = $Random.NextDouble()
    }

    <#
        .SYNOPSIS
        Generates a random double-precision floating-point number.

        .DESCRIPTION
        Generates a random double-precision floating-point number between 0.0 and 1.0.

        .INPUTS
        None.  You cannot pipe objects to Get-RandomDouble.

        .OUTPUTS
        [double].  Get-RandomDouble generates a random double-precision floating-point number.

        .EXAMPLE
        PS> Get-RandomDouble

        0.223841752495543

        Generates a random double-precision floating-point number between 0.0 and 1.0.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Initialize-Random

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Debug

        .LINK
        Write-Output

        .LINK
        Write-Verbose

        .LINK
        Write-Warning
    #>
}

<#
    Get-RandomFloat
#>
function Get-RandomFloat {
    [CmdletBinding()]
    [OutputType([float])]
    param ()

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    if (-not $Script:IsInitialized) {
        Write-Warning -Message "$($CmdletName) : Random number generator has not been initialized. Initializing now."
        Initialize-Random
    }

    $index = $Script:Random.Next(0, $Script:FloatArray.Length - 1)
    Write-Debug -Message "$($CmdletName) : Index = $index"

    try {
        Write-Verbose -Message "$($CmdletName) : Generating random floating-point number."
        $Script:FloatArray[$index] | Write-Output
    }
    finally {
        Write-Debug -Message "$($CmdletName) : Initializing float array element $index."
        $Script:FloatArray[$index] = $Random.NextSingle()
    }

    <#
        .SYNOPSIS
        Generates a random floating-point number.

        .DESCRIPTION
        Generates a random floating-point number between 0.0 and 1.0.
        
        .INPUTS
        None.  You cannot pipe objects to Get-RandomFloat.

        .OUTPUTS
        [float].  Get-RandomFloat generates a random floating-point number.

        .EXAMPLE
        PS> Get-RandomFloat

        0.5653152

        Generates a random floating-point number between 0.0 and 1.0.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Initialize-Random

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Debug

        .LINK
        Write-Output

        .LINK
        Write-Verbose

        .LINK
        Write-Warning
    #>
}

<#
    Get-RandomInteger
#>
function Get-RandomInteger {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [ValidateRange(-2147483648, 2147483647)]
        [int]
        $Minimum = 0,

        [ValidateRange(-2147483648, 2147483647)]
        [int]
        $Maximum = 2147483647
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    if (-not $Script:IsInitialized) {
        Write-Warning -Message "$($CmdletName) : Random number generator has not been initialized. Initializing now."
        Initialize-Random
    }

    if ($Minimum -ge $Maximum) {
        $message = 'The minimum value must be less than the maximum value.'
        $exception = [System.ArgumentOutOfRangeException]::new('Minimum', $Minimum, $message)
        
        $writeErrorSplat = @{
            Exception    = $exception
            ErrorId      = "$($CmdletName)-MinimumGreaterThanMaximum-01"
            Category     = 'InvalidArgument'
            TargetObject = $Minimum
            ErrorAction  = 'Continue'
        }

        Write-Error @writeErrorSplat
        throw $exception
    }

    $index = $Script:Random.Next(0, $Script:IntegerArray.Length - 1)
    
    try {
        Write-Verbose -Message "$($CmdletName) : Generating random integer."

        do {
            $result = [int](($Script:IntegerArray[$index] % ($Maximum - $Minimum + 1)) + $Minimum)
        }
        while ($result -lt $Minimum -or $result -gt $Maximum)

        $result | Write-Output
    }
    finally {
        Write-Debug -Message "$($CmdletName) : Initializing integer array element $index."
        $Script:IntegerArray[$index] = $Script:Random.Next(0, [int]::MaxValue)
    }

    <#
        .SYNOPSIS
        Generates a random integer.

        .DESCRIPTION
        Generates a random integer between the specified minimum and maximum values.  If no minimum and maximum values are specified, the range is from 0 to 2147483647.

        .PARAMETER Minimum
        The minimum value of the random integer.

        .PARAMETER Maximum
        The maximum value of the random integer.

        .INPUTS
        None.  You cannot pipe objects to Get-RandomInteger.

        .OUTPUTS
        [int].  Get-RandomInteger generates a random integer.

        .EXAMPLE
        PS> Get-RandomInteger

        746151833

        Generates a random integer between 0 and 2147483647.

        .EXAMPLE
        PS> Get-RandomInteger -Maximum 100

        28

        Generates a random integer between 0 and 100.

        .EXAMPLE
        PS> Get-RandomInteger -Minimum 100 -Maximum 200

        159

        Generates a random integer between 100 and 200.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Initialize-Random

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Debug

        .LINK
        Write-Output

        .LINK
        Write-Verbose

        .LINK
        Write-Warning
    #>
}

<#
    Get-RandomLong
#>
function Get-RandomLong {
    [CmdletBinding()]
    [OutputType([long])]
    param (
        [ValidateRange(-9223372036854775808, 9223372036854775807)]
        [long]
        $Minimum = 0,

        [ValidateRange(-9223372036854775808, 9223372036854775807)]
        [long]
        $Maximum = 9223372036854775807
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    if ($Minimum -ge $Maximum) {
        $message = 'The minimum value must be less than the maximum value.'
        $exception = [System.ArgumentOutOfRangeException]::new('Minimum', $Minimum, $message)
        
        $writeErrorSplat = @{
            Exception    = $exception
            ErrorId      = "$($CmdletName)-MinimumGreaterThanMaximum-01"
            Category     = 'InvalidArgument'
            TargetObject = $Minimum
            ErrorAction  = 'Continue'
        }

        Write-Error @writeErrorSplat
        throw $exception
    }

    if (-not $Script:IsInitialized) {
        Write-Warning -Message "$($CmdletName) : Random number generator has not been initialized. Initializing now."
        Initialize-Random
    }

    $index = $Script:Random.Next(0, $Script:LongArray.Length - 1)
    Write-Debug -Message "$($CmdletName) : Index = $index"
    
    try {
        do {
            $result = [long](($Script:LongArray[$index] % ($Maximum - $Minimum + 1)) + $Minimum)
        }
        while ($result -lt $Minimum -or $result -gt $Maximum)

        $result | Write-Output
    }
    finally {
        Write-Debug -Message "$($CmdletName) : Initializing long integer array element $index."
        $Script:IntegerArray[$index] = $Random.NextInt64(0, [long]::MaxValue)
    }

    <#
        .SYNOPSIS
        Generates a random long integer.

        .DESCRIPTION
        Generates a random long integer between the specified minimum and maximum values.  If no minimum and maximum values are specified, the range is from 0 to 9223372036854775807.

        .PARAMETER Minimum
        The minimum value of the random long integer.

        .PARAMETER Maximum
        The maximum value of the random long integer.

        .INPUTS
        None.  You cannot pipe objects to Get-RandomLong.

        .OUTPUTS
        [long].  Get-RandomLong generates a random long integer.

        .EXAMPLE
        PS> Get-RandomLong

        4.09590614013807E+18

        Generates a random long integer between 0 and 9223372036854775807.

        .EXAMPLE
        PS> Get-RandomLong -Maximum 100

        16

        Generates a random long integer between 0 and 100.

        .EXAMPLE
        PS> Get-RandomLong -Minimum 100 -Maximum 200

        169

        Generates a random long integer between 100 and 200.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Initialize-Random

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Debug

        .LINK
        Write-Output

        .LINK
        Write-Verbose

        .LINK
        Write-Warning
    #>
}

<#
    Initialize-Random
#>
function Initialize-Random {
    [CmdletBinding()]
    param (
        [ValidateRange(-2147483648, 2147483647)]
        [int]
        $Seed,

        [switch]
        $DefaultSeed
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    if (-not (Test-PSParameter -Name 'Seed' -Parameters $PSBoundParameters) -and -not $DefaultSeed.IsPresent) {
        Write-Verbose -Message "$($CmdletName) : No seed specified. Using current UTC time in ticks as seed."
        $Seed = [int](((Get-Date -AsUTC) | Select-Object -ExpandProperty Ticks) % [int]::MaxValue)
    }
    elseif ($DefaultSeed.IsPresent) {
        Write-Verbose -Message "$($CmdletName) : Using default seed of 0."
        $Seed = 0
    }

    [Random]::new($Seed) | Set-Variable -Name Random -Option ReadOnly -Scope Script

    for ($i = 0; $i -lt $Script:ByteArray.Length; $i++) {
        Write-Debug -Message "$($CmdletName) : Initializing byte array element $i."
        $Script:ByteArray[$i] = [byte]$Random.Next(0, [byte]::MaxValue)
    }

    for ($i = 0; $i -lt $Script:DoubleArray.Length; $i++) {
        Write-Debug -Message "$($CmdletName) : Initializing double array element $i."
        $Script:DoubleArray[$i] = $Random.NextDouble()
    }

    for ($i = 0; $i -lt $Script:FloatArray.Length; $i++) {
        Write-Debug -Message "$($CmdletName) : Initializing float array element $i."
        $Script:FloatArray[$i] = $Random.NextSingle()
    }

    for ($i = 0; $i -lt $Script:IntegerArray.Length; $i++) {
        Write-Debug -Message "$($CmdletName) : Initializing integer array element $i."
        $Script:IntegerArray[$i] = $Random.Next(0, [int]::MaxValue)
    }

    for ($i = 0; $i -lt $Script:LongArray.Length; $i++) {
        Write-Debug -Message "$($CmdletName) : Initializing long integer array element $i."
        $Script:LongArray[$i] = $Random.NextInt64(0, [long]::MaxValue)
    }

    Write-Verbose -Message "$($CmdletName) : Random number generator initialized."
    $Script:IsInitialized = $true

    <#
        .SYNOPSIS
        Initializes the random number generator.

        .DESCRIPTION
        Initializes the random number generator with the specified seed. If no seed is specified, the current time in ticks convert to an integer is used as the seed.  If '-DefaultSeed' is specified, the seed is set to 0.

        .PARAMETER Seed
        The seed to use for the random number generator.

        .PARAMETER DefaultSeed
        Use the default seed of 0.

        .INPUTS
        None.  You cannot pipe objects to Initialize-Random.

        .OUTPUTS
        None.  Initialize-Random does not generate any output.

        .EXAMPLE
        PS> Initialize-Random

        Initializes the random number generator with the current UTC time in ticks as the seed.

        .EXAMPLE
        PS> Initialize-Random -Seed 12345

        Initializes the random number generator with a seed of 12345.

        .EXAMPLE
        PS> Initialize-Random -DefaultSeed

        Initializes the random number generator with a seed of 0.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Get-Date

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Debug

        .LINK
        Write-Verbose
    #>
}
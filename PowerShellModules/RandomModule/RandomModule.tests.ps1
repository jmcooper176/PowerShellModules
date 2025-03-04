<#
 =============================================================================
<copyright file="RandomModule.tests.ps1" company="U.S. Office of Personnel
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
This file "RandomModule.tests.ps1" is part of "RandomModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

BeforeAll {
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '.\RandomModule.psd1'
    $ModuleName = $ModulePath | Get-ItemProperty -Name BaseName
    Import-Module -Name $ModulePath -Verbose
}

AfterAll {
    Get-Module -Name 'RandomModule' | Remove-Module -Verbose
}

Describe -Name 'RandomModule' {
    Context -Name 'Module Manifest' {
        It 'should exist' {
            # Arrange and Act
            $ModuleManifest = Test-Path -Path '.\RandomModule.psd1'

            # Assert
            $ModuleManifest | Should -Be $true
        }

        It 'should parse' {
            $inputSource = Get-Content -LiteralPath $ModulePath -Raw

            [ref] $tokens = @()
            [ref] $errors = @()
            $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $ModuleFileName, $tokens, $errors)

            $errors.Value | ForEach-Object -Process {
                $message = ('{0} at {1}:  Parse error generating abstract syntax tree' -f $ModuleName, $ModulePath)
                $writeErrorSplat = @{
                        Exception    = [System.Management.Automation.ParseException]::new($message)
                        Category     = 'ParseError'
                        ErrorId      = ('{0}-ParseException-{1}' -f $ModuleName, $MyInvocation.ScriptLineNumber)
                        TargetObject = $_
                        ErrorAction  = 'Continue'
                    }

                    Write-Error @writeErrorSplat -ErrorAction Continue
                    $PSCmdlet.ThrowTerminatingError($writeErrorHash)
                }
        }

        It 'should have a RootModule of RandomModule.psm1' {
            # Arrange and Act
            $RootModule = Test-ModuleManifest -Path '.\RandomModule.psd1' | Select-Object -ExpandProperty 'RootModule'

            # Assert
            $RootModule | Should -Be 'RandomModule.psm1'
        }

        It 'should have a ModuleVersion of 0.0.1' {
            # Arrange and Act
            $ModuleVersion = Test-ModuleManifest -Path '.\RandomModule.psd1' | Select-Object -ExpandProperty 'Version'

            # Assert
            $ModuleVersion | Should -Be '0.0.1'
        }

        It 'should have a GUID of E62EF891-3230-41B9-ABCA-3776C1C42661' {
            # Arrange and Act
            $Guid = Test-ModuleManifest -Path '.\RandomModule.psd1' | Select-Object -ExpandProperty 'GUID'

            # Assert
            $Guid | Should -Be 'E62EF891-3230-41B9-ABCA-3776C1C42661'
        }

        It 'should have an Author of John Merryweather Cooper' {
            # Arrange and Act
            $Author = Test-ModuleManifest -Path '.\RandomModule.psd1' | Select-Object -ExpandProperty 'Author'

            # Assert
            $Author | Should -Be 'John Merryweather Cooper'
        }

        It 'should have a CompanyName of Ram Tuned Mega Code' {
            # Arrange and Act
            $CompanyName = Test-ModuleManifest -Path '.\RandomModule.psd1' | Select-Object -ExpandProperty 'CompanyName'

            # Assert
            $CompanyName | Should -Be 'Ram Tuned Mega Code'
        }

        It 'should have a Copyright of Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.' {
            # Arrange and Act
            $Copyright = Test-ModuleManifest -Path '.\RandomModule.psd1' | Select-Object -ExpandProperty 'Copyright'

            # Assert
            $Copyright | Should -Be 'Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.'
        }

        It 'should have a Description of Cmdlets/functions for the generation of pseudo-random numbers.' {
            # Arrange and Act
            $Description = Test-ModuleManifest -Path '.\RandomModule.psd1' | Select-Object -ExpandProperty 'Description'

            # Assert
            $Description | Should -Be 'Cmdlets/functions for the generation of pseudo-random numbers.'
        }

        It 'should have a PowerShellVersion of 5.1' {
            # Arrange and Act
            $PowerShellVersion = Test-ModuleManifest -Path '.\RandomModule.psd1' | Select-Object -ExpandProperty 'PowerShellVersion'

            # Assert
            $PowerShellVersion | Should -Be '5.1'
        }

        It 'should have ExportedCmdlets count should equal ExportedFunctions count' {
            # Arrange
            $exportedCmdlets = Test-ModuleManifest -Path $ModulePath |
                Select-Object -ExpandProperty 'ExportedCmdlets' |
                    Sort-Object -Unique
            $exportedFunctions = Test-ModuleManifest -Path $ModulePath |
                Select-Object -ExpandProperty 'ExportedFunctions' |
                    Sort-Object -Unique

            # Act And Assert
            $exportedCmdlets.Count | Should -Be $exportedFunctions.Count
        }

        It 'should have ExportedCmdlets equal to ExportedFunctions' {
            # Arrange
            $exportedCmdlets = Test-ModuleManifest -Path $ModulePath |
                Select-Object -ExpandProperty 'ExportedCmdlets' |
                    Sort-Object -Unique
            $exportedFunctions = Test-ModuleManifest -Path $ModulePath |
                Select-Object -ExpandProperty 'ExportedFunctions' |
                    Sort-Object -Unique

            # Act
            for ($i = 0; $i -lt $exportedCmdlets.Count; $i++) {
                $result = $exportedCmdlets[$i] -eq $exportedFunctions[$i]

                if (-not $result) {
                    break
                }
            }

            # Assert
            $result | Should -BeTrue
        }
    }

    Context -Name 'Get-RandomByte' {
        It 'should return a byte' {
            # Arrange
            $Byte = Get-RandomByte

            # Assert
            $Byte | Should -BeOfType 'byte'
        }

        It 'should return a byte between 0 and [byte]::MaxValue' {
            # Arrange
            $Byte = Get-RandomByte

            # Assert
            $Byte -ge 0 -and $Byte -lt [byte]::MaxValue | Should -BeTrue
        }
    }

    Context -Name 'Get-RandomInteger' {
        It 'should return an integer' {
            # Arrange
            $Int = Get-RandomInteger

            # Assert
            $Int | Should -BeOfType 'int'
        }

        It 'should return an integer between 0 and [int]::MaxValue' {
            # Arrange
            $Int = Get-RandomInteger

            # Assert
            $Int -ge 0 -and $Int -lt [int]::MaxValue | Should -BeTrue
        }
    }

    Context -Name 'Get-RandomLong' {
        It 'should return a long' {
            # Arrange
            $Long = Get-RandomLong

            # Assert
            $Long | Should -BeOfType 'long'
        }

        It 'should return a long between 0 and [long]::MaxValue' {
            # Arrange
            $Long = Get-RandomLong

            # Assert
            $Long -ge 0 -and $Long -lt [long]::MaxValue | Should -BeTrue
        }
    }

    Context -Name 'Get-RandomFloat' {
        It 'should return a float' {
            # Arrange
            $Float = Get-RandomFloat

            # Assert
            $Float | Should -BeOfType 'float'
        }

        It 'should return a float between 0.0 and 1.0' {
            # Arrange
            $Float = Get-RandomFloat

            # Assert
            $Float -ge 0.0 -and $Float -lt 1.0 | Should -BeTrue
        }
    }

    Context -Name 'Get-RandomDouble' {
        It 'should return a double' {
            # Arrange
            $Double = Get-RandomDouble

            # Assert
            $Double | Should -BeOfType 'double'
        }

        It 'should return a double between 0.0 and 1.0' {
            # Arrange
            $Double = Get-RandomDouble

            # Assert
            $Double -ge 0 -and $Double -lt 1.0 | Should -BeTrue
        }
    }

    Context -Name 'Initialize-Random' {
        BeforeEach {
            Import-Module -Name $ModulePath -Verbose
        }

        AfterEach {
            Get-Module -Name 'RandomModule' | Remove-Module -Verbose
        }

        It 'should not throw no arguments' {
            # Arrange, Act, and Assert
            { Initialize-Random } | Should -Not -Throw
        }

        It 'should not throw default seed' {
            # Arrange, Act, and Assert
            { Initialize-Random -DefaultSeed } | Should -Not -Throw
        }

        It 'should not throw truncated ticks seed' {
            # Arrange
            $seed = [int](((Get-Date -AsUTC) | Select-Object -ExpandProperty Ticks) % [int]::MaxValue)

            # Act, and Assert
            { Initialize-Random -Seed $seed } | Should -Not -Throw
        }

        It 'byte array should be initialized' {
            # Arrange
            $seed = [int](((Get-Date -AsUTC) | Select-Object -ExpandProperty Ticks) % [int]::MaxValue)

            # Act
            Initialize-Random -Seed $seed

            # Assert
            $Script:ByteArray | Where-Object -FilterScript { $_ -ge 0 -or $_ -le [byte]::MaxValue } | Measure-Object | Select-Object -ExpandProperty Count | Should -Be $Script:ByteArray.Length
        }

        It 'byte array should be initialized and in range' {
            # Arrange
            $seed = [int](((Get-Date -AsUTC) | Select-Object -ExpandProperty Ticks) % [int]::MaxValue)

            # Act
            Initialize-Random -Seed $seed

            # Assert
            $Script:ByteArray | Where-Object -FilterScript { $_ -lt 0 -or $_ -ge [byte]::MaxValue } | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 0
        }

        It 'integer array should be initialized' {
            # Arrange
            $seed = [int](((Get-Date -AsUTC) | Select-Object -ExpandProperty Ticks) % [int]::MaxValue)

            # Act
            Initialize-Random -Seed $seed

            # Assert
            $Script:IntegerArray | Where-Object -FilterScript { $_ -ge 0 -or $_ -lt [int]::MaxValue } | Measure-Object | Select-Object -ExpandProperty Count | Should -Be $Script:IntegerArray.Length
        }

        It 'integer array should be initialized and in range' {
            # Arrange
            $seed = [int](((Get-Date -AsUTC) | Select-Object -ExpandProperty Ticks) % [int]::MaxValue)

            # Act
            Initialize-Random -Seed $seed

            # Assert
            $Script:IntegerArray | Where-Object -FilterScript { $_ -lt 0 -or $_ -ge [int]::MaxValue } | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 0
        }

        It 'long array should be initialized' {
            # Arrange
            $seed = [int](((Get-Date -AsUTC) | Select-Object -ExpandProperty Ticks) % [int]::MaxValue)

            # Act
            Initialize-Random -Seed $seed

            # Assert
            $Script:LongArray | Where-Object -FilterScript { $_ -ge 0 -or $_ -lt [long]::MaxValue } | Measure-Object | Select-Object -ExpandProperty Count | Should -Be $Script:LongArray.Length
        }

        It 'long array should be initialized and in range' {
            # Arrange
            $seed = [int](((Get-Date -AsUTC) | Select-Object -ExpandProperty Ticks) % [int]::MaxValue)

            # Act
            Initialize-Random -Seed $seed

            # Assert
            $Script:LongArray | Where-Object -FilterScript { $_ -lt 0 -or $_ -ge [long]::MaxValue } | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 0
        }

        It 'float array should be initialized' {
            # Arrange
            $seed = [int](((Get-Date -AsUTC) | Select-Object -ExpandProperty Ticks) % [int]::MaxValue)

            # Act
            Initialize-Random -Seed $seed

            # Assert
            $Script:FloatArray | Where-Object -FilterScript { $_ -ge [float]0.0 -or $_ -lt [float]1.0 } | Measure-Object | Select-Object -ExpandProperty Count | Should -Be $Script:FloatArray.Length
        }

        It 'float array should be initialized and in range' {
            # Arrange
            $seed = [int](((Get-Date -AsUTC) | Select-Object -ExpandProperty Ticks) % [int]::MaxValue)

            # Act
            Initialize-Random -Seed $seed

            # Assert
            $Script:FloatArray | Where-Object -FilterScript { $_ -lt [float]0.0 -or $_ -ge [float]1.0 } | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 0
        }

        It 'double array should be initialized' {
            # Arrange
            $seed = [int](((Get-Date -AsUTC) | Select-Object -ExpandProperty Ticks) % [int]::MaxValue)

            # Act
            Initialize-Random -Seed $seed

            # Assert
            $Script:DoubleArray | Where-Object -FilterScript { $_ -ge 0.0 -or $_ -lt 1.0 } | Measure-Object | Select-Object -ExpandProperty Count | Should -Be $Script:DoubleArray.Length
        }

        It 'double array should be initialized and in range' {
            # Arrange
            $seed = [int](((Get-Date -AsUTC) | Select-Object -ExpandProperty Ticks) % [int]::MaxValue)

            # Act
            Initialize-Random -Seed $seed

            # Assert
            $Script:DoubleArray | Where-Object -FilterScript { $_ -lt 0.0 -or $_ -ge 1.0 } | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 0
        }
    }
}

function Get-ChiSquaredFromFrequency {
    [CmdletBinding()]
    [OutputType([double])]
    param (
        [Parameter(Mandatory = $true)]
        [int[]]
        $Observed,

        [Parameter(Mandatory = $true)]
        [double[]]
        $Expected
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    if ($Observed.Length -ne $Expected.Length) {
        $Message   = 'Observed and Expected arrays must be the same length.'
        $Exception = [System.ArgumentOutOfRangeException]::new('Observed', $Observed.Length, $Message)

        $writeErrorSplat = @{
            Exception    = $Exception
            ErrorId      = "$($CmdletName)-InvalidArgument-01"
            Category     = 'InvalidArgument'
            TargetObject = $Observed
            ErrorAction = 'Continue'
        }

        Write-Error @writeErrorSplat
        throw $Exception
    }

    [double]$sum = 0.0

    for ($i = 0; $i -lt $Observed.Length; $i++) {
        $sum += [Math]::Pow(($Observed[$i] - $Expected[$i]), 2) / $Expected[$i]
    }

    $sum | Write-Output
}

function Get-ExpectedFromProbability {
    [CmdletBinding()]
    [OutputType([double[]])]
    param (
        [Parameter(Mandatory)]
        [double[]]
        $Probability,

        [Parameter(Mandatory)]
        [int]
        $N
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    [double[]]$Expected = @(0.0) * $Probability.Length

    for ($i = 0; $i -lt $Probability.Length; $i++) {
        $Expected[$i] = $Probability[$i] * $N
    }

    $Expected | Write-Output
}

function Get-ChiSquareFromProbability {
    [CmdletBinding()]
    [OutputType([double])]
    param (
        [Parameter(Mandatory)]
        [int[]]
        $Observed,

        [Parameter(Mandatory = $true)]
        [double[]]
        $Probability
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    if ($Observed.Length -ne $Probability.Length) {
        $Message   = 'Observed and Probability arrays must be the same length.'
        $Exception = [System.ArgumentOutOfRangeException]::new('Observed', $Observed.Length, $Message)

        $writeErrorSplat = @{
            Exception    = $Exception
            ErrorId      = "$($CmdletName)-InvalidArgument-01"
            Category     = 'InvalidArgument'
            TargetObject = $Observed
            ErrorAction = 'Continue'
        }

        Write-Error @writeErrorSplat
        throw $Exception
    }

    [int]$sum = 0

    for ($i = 0; $i -lt $Observed.Length; $i++) {
        $sum += $Observed[$i]
    }

    [double[]]$Expected = Get-ExpectedFromProbability -Probability $Probability -N $sum
    Get-ChiSquaredFromFrequency -Observed $Observed -Expected $Expected | Write-Output
}

function Get-ChiSquarePValue {
    [CmdletBinding()]
    [OutputType([double])]
    param (
        [Parameter(Mandatory)]
        [double]
        $ChiSquareValue,

        [Parameter(Mandatory)]
        [int]
        $DegreesOfFreedom
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    [double]$chiSquare = Get-ChiSquareFromProbability -Observed $Observed -Probability $Probability
    [double]$pValue    = [Math]::Exp(-$chiSquare / 2)

    $pValue | Write-Output
}

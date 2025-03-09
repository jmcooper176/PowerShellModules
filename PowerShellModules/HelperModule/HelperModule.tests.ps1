<#
 =============================================================================
<copyright file="HelperModule.tests.ps1" company="John Merryweather Cooper">
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
This file "HelperModule.tests.ps1" is part of "HelperModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

#requires -Module Pester
#requires -Module ConvertModule
#requires -Module PowerShellModule

BeforeAll {
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '.\HelperModule.psd1'
    $RootModule = ($ModulePath -replace '.psd1', '.psm1') | Get-ItemProperty -Name Name
    $ModuleName = $ModulePath | Get-ItemProperty -Name BaseName
    Import-Module -Name $ModulePath -Verbose
    Initialize-PSTest -Name 'HelperModule' -Path $ModulePath
}

AfterAll {
    Get-Module -Name 'HelperModule' | Remove-Module -Verbose -Force
}

Describe -Name 'HelperModule' -Tag 'Module', 'Under', 'Test' {
    Context -Name 'Module Manifest' -Tag 'Manifest', 'Under', 'Test' {
        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleManifest = Test-ModuleManifest -Path $ModulePath

            # Assert
            $ModuleManifest | Should -Not -BeNullOrEmpty
        }

        It -Name 'should parse' -Tag 'Unit', 'Test' {
            # Arrange
            $inputSource = Get-Content -LiteralPath $ModulePath -Raw

            [ref] $tokens = @()
            [ref] $errors = @()
            $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)
            $success = $true

            # Act
            $errors.Value | ForEach-Object -Process {
                $success = $false
                $message = ('{0}@{1} : Parse error generating abstract syntax tree' -f $ModulePath, $ModuleName)
                $newErrorRecordSplat = @{
                    Exception    = [System.Management.Automation.ParseException]::new($message)
                    Category     = 'ParseError'
                    ErrorId      = ('{0}-ParseException-{1}' -f $ModuleName, $MyInvocation.ScriptLineNumber)
                    TargetObject = $_
                }

                New-ErrorRecord @newErrorRecordSplat | Write-Error -ErrorAction Continue
            }

            # Assert
            $success | Should -BeTrue
        }

        It -Name 'should have a RootModule of HelperModule.psm1' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $RootModule = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'RootModule'

            # Assert
            $RootModule | Should -Be 'HelperModule.psm1'
        }

        It -Name 'should have a ModuleVersion greater than  1.3.0' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleVersion = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Version'

            # Assert
            $ModuleVersion | Should -BeGreaterThan '1.3.0'
        }

        It -Name 'should have a GUID of 6e424d77-583b-40f8-968d-686ebea12ee1' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Guid = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'GUID'

            # Assert
            $Guid | Should -Be '6e424d77-583b-40f8-968d-686ebea12ee1'
        }

        It -Name 'should have an Author of John Merryweather Cooper' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Author = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Author'

            # Assert
            $Author | Should -Be 'John Merryweather Cooper'
        }

        It -Name 'should have a CompanyName of John Merryweather Cooper' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $CompanyName = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'CompanyName'

            # Assert
            $CompanyName | Should -Be $COMPANY_NAME_STRING
        }

        It -Name 'should have a Copyright of Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Copyright = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Copyright'

            # Assert
            $Copyright | Should -Be $COPYRIGHT_STRING
        }

        It -Name 'should have a Description length greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Description'

            # Assert
            $Description | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have a Description of Enhanced interface to Process Environment Variables.' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Description'

            # Assert
            $Description | Should -Be 'Enhanced interface to Process Environment Variables.'
        }

        It -Name 'should have a PowerShellVersion of 5.1' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $PowerShellVersion = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'PowerShellVersion'

            # Assert
            $PowerShellVersion | Should -Be '5.1'
        }

        It -Name 'should have ExportedCmdlets count should equal ExportedFunctions count' -Tag 'Unit', 'Test' {
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

        It -Name 'should have ExportedCmdlets equal to ExportedFunctions' -Tag 'Unit', 'Test' {
            # Arrange
            $exportedCmdlets = Test-ModuleManifest -Path $ModulePath |
                Select-Object -ExpandProperty 'ExportedCmdlets' |
                Sort-Object -Unique -Descending
            $exportedFunctions = Test-ModuleManifest -Path $ModulePath |
                Select-Object -ExpandProperty 'ExportedFunctions' |
                Sort-Object -Unique -Descending

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

    Context -Name 'Add-EnvironmentValue' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Add-EnvironmentValue'

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Add-EnvironmentValue'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Add-EnvironmentValue' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Get-Help -Name 'Add-EnvironmentValue' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have a module name of HelperModule' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Add-EnvironmentValue' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'HelperModule'
        }
    }
}

BeforeAll {
    # Arrange
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'HelperModule.psd1' -Resolve
    $ConvertModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\ConvertModule\ConvertModule.psd1' -Resolve
    $TypeAcceleratorPath = Join-Path -Path $PSScriptRoot -ChildPath '..\TypeAccelerator\TypeAccelerator.psd1' -Resolve

    # Act
    Import-Module -Name $ModulePath -Force -Verbose
    Import-Module -Name $TypeAcceleratorPath -Force -Verbose

    # Assert
    Get-Module -Name 'HelperModule' | Should -Not -BeNull
    Get-Module -Name 'TypeAccelerator' | Should -Not -BeNull
}

AfterAll {
    # Act
    Get-Module -Name 'HelperModule' | Remove-Module -Verbose
    Get-Module -Name 'TypeAccelerator' | Remove-Module -Verbose

    # Assert
    Get-Module -Name 'HelperModule' | Should -BeNull
    Get-Module -Name 'TypeAccelerator' | Should -BeNull
}

Describe -Name 'HelperModule' -Tag 'Module', 'Under', 'Test' {
    Context -Name 'Module Manifest' -Tag 'Manifest', 'Under', 'Test' {
        It -Name 'should have a RootModule of HelperModule.psm1' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $RootModule = Test-ModuleManifest -Path '.\HelperModule.psd1' | Select-Object -ExpandProperty 'RootModule'

            # Assert
            $RootModule | Should -Be 'HelperModule.psm1'
        }

        It -Name 'should have a ModuleVersion of 1.1.0' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleVersion = Test-ModuleManifest -Path '.\HelperModule.psd1' | Select-Object -ExpandProperty 'Version'

            # Assert
            $ModuleVersion | Should -Be '1.1.0'
        }

        It -Name 'should have a GUID of 196e2256-561c-4cdf-87dc-5146720c69c2' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Guid = Test-ModuleManifest -Path '.\HelperModule.psd1' | Select-Object -ExpandProperty 'GUID'

            # Assert
            $Guid | Should -Be '196e2256-561c-4cdf-87dc-5146720c69c2'
        }

        It -Name 'should have an Author of John Merryweather Cooper' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Author = Test-ModuleManifest -Path '.\HelperModule.psd1' | Select-Object -ExpandProperty 'Author'

            # Assert
            $Author | Should -Be 'John Merryweather Cooper'
        }

        It -Name 'should have a CompanyName of John Merryweather Cooper' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $CompanyName = Test-ModuleManifest -Path '.\HelperModule.psd1' | Select-Object -ExpandProperty 'CompanyName'

            # Assert
            $CompanyName | Should -Be 'John Merryweather Cooper'
        }

        It -Name 'should have a Copyright of Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Copyright = Test-ModuleManifest -Path '.\HelperModule.psd1' | Select-Object -ExpandProperty 'Copyright'

            # Assert
            $Copyright | Should -Be 'Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.'
        }

        It -Name 'should have a Description of Unit test helper functions for PowerShell.' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Test-ModuleManifest -Path '.\HelperModule.psd1' | Select-Object -ExpandProperty 'Description'

            # Assert
            $Description | Should -Be 'Unit test helper functions for PowerShell.'
        }

        It -Name 'should have a PowerShellVersion of 5.1' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $PowerShellVersion = Test-ModuleManifest -Path '.\HelperModule.psd1' | Select-Object -ExpandProperty 'PowerShellVersion'

            # Assert
            $PowerShellVersion | Should -Be '5.1'
        }

        It -Name 'should have a NestedModule of ConvertModule' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $NestedModules = Test-ModuleManifest -Path '.\HelperModule.psd1' | Select-Object -ExpandProperty 'NestedModules'

            # Assert
            $NestedModules | Should -Be 'ConvertModule'
        }
    }

    Context -Name 'Select-ModuleByFilter' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'Should exist'  -Tag 'Unit', 'Test' {
            # Arrange
            $testPathSplat = @{
                LiteralPath     = 'Function:\Select-ModuleByFilter'
                PathType = 'Leaf'
            }

            # Act and Assert
            Test-Path @testPathSplat | Should -BeTrue
        }

        It -Name 'Should return the the same module'  -Tag 'Unit', 'Test' {
            # Arrange
            $Expected = $ModulePath

            # Act
            $Module = Select-ModuleByFilter -Path $Expected -Filter { $true }

            # Assert
            $Module | Select-Object -ExpandProperty Path | Should -Be $Expected
        }
    }

    Context -Name 'Select-ModuleByProperty' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'exists'  -Tag 'Unit', 'Test' {
            # Arrange
            $testPathSplat = @{
                LiteralPath     = 'Function:\Select-ModuleByProperty'
                PathType = 'Leaf'
            }

            # Act and Assert
            Test-Path @testPathSplat | Should -BeTrue
        }

        It -Name 'Should return the the same module'  -Tag 'Unit', 'Test' {
            # Arrange
            $Expected = $ModulePath

            # Act
            $Module = Select-ModuleByProperty -Path $Expected -Property 'Path' -Value $Expected

            # Assert
            $Module | Select-Object -ExpandProperty Path | Should -Be $Expected
        }
    }

    Context -Name 'Test-HasMember' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'exists'  -Tag 'Unit', 'Test' {
            # Arrange
            $testPathSplat = @{
                LiteralPath     = 'Function:\Test-HasMember'
                PathType = 'Leaf'
            }

            # Act and Assert
            Test-Path @testPathSplat | Should -BeTrue
        }

        It -Name 'Should throw an ArgumentNullException'  -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            { 'Name' | Test-HasMember -Object $null -Strict } | Should -Throw '*ArgumentNullException*'
        }

        It -Name 'Should return $true'  -Tag 'Unit', 'Test' {
            # Arrange
            $Object = Get-Item -LiteralPath $env:ComSpec

            # Act and Assert
            'FullName' | Test-HasMember -Object $Object -Strict | Should -BeTrue
        }
    }

    Context -Name 'Test-HasMethod' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'exists'  -Tag 'Unit', 'Test' {
            # Arrange
            $testPathSplat = @{
                LiteralPath     = 'Function:\Test-HasMethod'
                PathType = 'Leaf'
            }

            # Act and Assert
            Test-Path @testPathSplat | Should -BeTrue
        }

        It -Name 'Should throw a ArgumentNullException'  -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            { 'Name' | Test-HasMethod -Object $null -Strict } | Should -Throw '*ArgumentNullException*'
        }

        It -Name 'Should return $true'  -Tag 'Unit', 'Test' {
            # Arrange
            $Object = Get-Item -LiteralPath $env:COMSPEC

            # Act and Assert
            'GetType' | Test-HasMethod -Object $Object -Strict | Should -BeTrue
        }
    }

    Context -Name 'Test-HasProperty' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'exists'  -Tag 'Unit', 'Test' {
            # Arrange
            $testPathSplat = @{
                LiteralPath     = 'Function:\Test-HasMethod'
                PathType = 'Leaf'
            }

            # Act and Assert
            Test-Path @testPathSplat | Should -BeTrue
        }

        It -Name 'Should throw a ArgumentNullException'  -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            { 'Name' | Test-HasMethod -Object $null -Strict } | Should -Throw '*ArgumentNullException*'
        }

        It -Name 'Should return $true'  -Tag 'Unit', 'Test' {
            # Arrange
            $Object = [PSCustomObject]@{
                Name = 'John'
            }

            # Act and Assert
            $Object | Test-HasProperty -Object $Object -Strict | Should -BeTrue
        }
    }

    Context -Name 'Test-ModuleProperty' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'exists'  -Tag 'Unit', 'Test' {
            # Arrange
            $testPathSplat = @{
                LiteralPath     = 'Function:\Test-ModuleProperty'
                PathType = 'Leaf'
            }

            # Act and Assert
            Test-Path @testPathSplat | Should -BeTrue
        }

        It -Name 'Should return $true'  -Tag 'Unit', 'Test' {
            # Arrange
            $Expected = 'Path'

            # Act and Assert
            $ModulePath | Test-ModuleProperty -Property $Expected | Should -BeTrue
        }
    }
}
